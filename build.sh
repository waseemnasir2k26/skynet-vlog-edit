#!/usr/bin/env bash
# Master build — read config, run all 4 stages, output final MP4
#
# Usage:
#   ./build.sh examples/bali-day.config.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$1"

if [ -z "$CONFIG" ] || [ ! -f "$CONFIG" ]; then
  echo "Usage: $0 <config.sh>"
  echo "  Example configs in examples/"
  exit 1
fi

source "$CONFIG"

WORK="$SCRIPT_DIR/output/${VIDEO_NAME}_work"
mkdir -p "$WORK"
N=${#CLIPS[@]}

echo "=== skynet-vlog-edit: ${VIDEO_NAME} (${N} clips) ==="

# Stage 1 — normalize each clip
for ((i=0; i<N; i++)); do
  IDX=$(printf "%02d" $((i+1)))
  CLIP_VAR="CAPTIONS_${IDX}[@]"
  TRIM_VAR="TRIM_${IDX}"
  CUT_VAR="CUT_${IDX}[@]"

  CAPS=("${!CLIP_VAR}")
  TRIM="${!TRIM_VAR:-0}"
  CUT=("${!CUT_VAR}")

  ENV_PREFIX=""
  if [ ${#CUT[@]} -eq 2 ]; then
    ENV_PREFIX="CUT_START=${CUT[0]} CUT_END=${CUT[1]}"
  fi

  echo "[1/4] clip $IDX: ${CLIPS[$i]}"
  eval $ENV_PREFIX "$SCRIPT_DIR/pipeline/01_normalize_clip.sh" "${CLIPS[$i]}" "$WORK/clip_$IDX.mp4" "$TRIM" "${CAPS[@]}"
done

# Stage 2 — outro
echo "[2/4] outro"
"$SCRIPT_DIR/pipeline/03_gen_outro.sh" "$WORK/outro.mp4"

# Stage 3 — compute total duration for music
TOTAL=0
for ((i=0; i<N; i++)); do
  IDX=$(printf "%02d" $((i+1)))
  D=$(ffprobe -v error -select_streams v -show_entries stream=duration -of csv=p=0 "$WORK/clip_$IDX.mp4" | head -1)
  TOTAL=$(awk "BEGIN{print $TOTAL + $D}")
done
TOTAL=$(awk "BEGIN{print int($TOTAL + 6)}")  # +6s margin for outro + fade

echo "[3/4] music ($TOTAL s)"
"$SCRIPT_DIR/pipeline/02_gen_music.sh" "$WORK/music.wav" "$TOTAL"

# Stage 4 — stitch
echo "[4/4] stitch"
CLIPS_ARG=""
for ((i=0; i<N; i++)); do
  IDX=$(printf "%02d" $((i+1)))
  CLIPS_ARG="$CLIPS_ARG $WORK/clip_$IDX.mp4"
done

OUT="$SCRIPT_DIR/output/${VIDEO_NAME}.mp4"
"$SCRIPT_DIR/pipeline/04_stitch.sh" "$OUT" "$WORK/music.wav" $CLIPS_ARG "$WORK/outro.mp4"

echo ""
echo "=== DONE ==="
echo "Output: $OUT"
ls -lh "$OUT"
