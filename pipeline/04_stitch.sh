#!/usr/bin/env bash
# Stitch normalized clips + outro with xfade transitions, mix bg music, final encode
#
# Usage:
#   ./04_stitch.sh OUTPUT MUSIC_WAV CLIP1 CLIP2 ... OUTRO
#
# Optional env:
#   TRANSITIONS="fade fadewhite slideleft dissolve fade fadeblack"
#     (one per cut point, count = N_clips - 1 + 1 to outro)
#   TRANS_DUR=0.4  (seconds per transition)
#   MUSIC_VOLUME=0.22

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../presets/music.preset.sh"

OUTPUT="$1"
MUSIC="$2"
shift 2
CLIPS=("$@")
N=${#CLIPS[@]}

# Defaults
DEFAULT_TRANS=(fade fadewhite slideleft dissolve fade fadeblack fade fade fade fade)
TRANSITIONS=(${TRANSITIONS:-${DEFAULT_TRANS[@]}})
TRANS_DUR="${TRANS_DUR:-0.4}"
TRANS_FADEBLACK_DUR="${TRANS_FADEBLACK_DUR:-0.5}"
TRANS_FADEWHITE_DUR="${TRANS_FADEWHITE_DUR:-0.3}"

# Get duration of each clip
DURATIONS=()
for C in "${CLIPS[@]}"; do
  D=$(ffprobe -v error -select_streams v -show_entries stream=duration -of csv=p=0 "$C" | head -1)
  DURATIONS+=("$D")
done

# Build inputs
INPUTS=""
for C in "${CLIPS[@]}"; do
  INPUTS="$INPUTS -i $C"
done
INPUTS="$INPUTS -i $MUSIC"
MUSIC_IDX=$N

# Build xfade chain — compute cumulative offsets
FILTER_V=""
FILTER_A=""
RUNNING=0
PREV_LABEL="0:v"
PREV_LABEL_A="0:a"

for ((i=1; i<N; i++)); do
  PREV_DUR="${DURATIONS[$((i-1))]}"
  T="${TRANSITIONS[$((i-1))]}"
  case "$T" in
    fadeblack) D="$TRANS_FADEBLACK_DUR" ;;
    fadewhite) D="$TRANS_FADEWHITE_DUR" ;;
    *) D="$TRANS_DUR" ;;
  esac
  RUNNING=$(awk "BEGIN{printf \"%.4f\", $RUNNING + $PREV_DUR - $D}")
  V_OUT="v$i"
  A_OUT="a$i"
  FILTER_V="${FILTER_V}[$PREV_LABEL][$i:v]xfade=transition=$T:duration=$D:offset=$RUNNING[$V_OUT];"
  FILTER_A="${FILTER_A}[$PREV_LABEL_A][$i:a]acrossfade=d=$D:c1=tri:c2=tri[$A_OUT];"
  PREV_LABEL="$V_OUT"
  PREV_LABEL_A="$A_OUT"
done

# Add running duration of final clip
FINAL_DUR=$(awk "BEGIN{printf \"%.4f\", $RUNNING + ${DURATIONS[$((N-1))]}}")
FADE_OUT_START=$(awk "BEGIN{printf \"%.2f\", $FINAL_DUR - 3}")

FILTER="${FILTER_V}${FILTER_A}[${MUSIC_IDX}:a]volume=${MUSIC_VOLUME},afade=t=in:st=0:d=2,afade=t=out:st=${FADE_OUT_START}:d=2.5[abg];[$PREV_LABEL_A][abg]amix=inputs=2:duration=first:dropout_transition=2,loudnorm=I=-14:LRA=11:TP=-1.5[aout]"

ffmpeg -y $INPUTS \
  -filter_complex "$FILTER" \
  -map "[$PREV_LABEL]" -map "[aout]" \
  -c:v libx264 -profile:v high -preset slow -crf 21 -pix_fmt yuv420p \
  -c:a aac -b:a 192k -ar 48000 -ac 2 \
  -movflags +faststart \
  "$OUTPUT" 2>&1 | tail -3

echo "✓ $OUTPUT (${FINAL_DUR}s)"
