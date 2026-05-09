#!/usr/bin/env bash
# Normalize one raw clip → 1080×1920 30fps + color grade + captions + loudnorm audio
#
# Usage:
#   ./01_normalize_clip.sh INPUT OUTPUT TRIM_DURATION CAPTION1 [CAPTION2 ...]
#   Caption format: "text|t_start|t_end"
#   TRIM_DURATION = 0 for full clip, else seconds
#
# Optional env: CUT_START + CUT_END to remove an internal section
#   CUT_START=8 CUT_END=9 ./01_normalize_clip.sh in.mp4 out.mp4 0 "Hi|0|3"

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../presets/caption.preset.sh"
source "$SCRIPT_DIR/../presets/grade.preset.sh"

INPUT="$1"
OUTPUT="$2"
TRIM="$3"
shift 3
CAPTIONS=("$@")

# Build caption filter chain
CAP_CHAIN=""
for C in "${CAPTIONS[@]}"; do
  IFS='|' read -r TXT T1 T2 <<< "$C"
  CAP_CHAIN="${CAP_CHAIN},$(caption_filter "$TXT" "$T1" "$T2")"
done

BASE="$(base_video_filter)${CAP_CHAIN}"

TRIM_FLAG=""
if [ "$TRIM" != "0" ] && [ -n "$TRIM" ]; then
  TRIM_FLAG="-t $TRIM"
fi

# Audio chain
AUDIO_FILTER="highpass=f=80,loudnorm=I=-16:LRA=11:TP=-1.5"

if [ -n "$CUT_START" ] && [ -n "$CUT_END" ]; then
  # Internal cut: split video + audio, drop CUT_START–CUT_END section, concat
  ffmpeg -y $TRIM_FLAG -i "$INPUT" \
    -filter_complex "[0:v]trim=0:${CUT_START},setpts=PTS-STARTPTS[v1];[0:v]trim=${CUT_END},setpts=PTS-STARTPTS[v2];[v1][v2]concat=n=2:v=1[vc];[vc]${BASE}[v];[0:a]atrim=0:${CUT_START},asetpts=PTS-STARTPTS[a1];[0:a]atrim=${CUT_END},asetpts=PTS-STARTPTS[a2];[a1][a2]concat=n=2:v=0:a=1,${AUDIO_FILTER}[a]" \
    -map "[v]" -map "[a]" \
    -c:v libx264 -profile:v high -preset medium -crf 21 -pix_fmt yuv420p \
    -c:a aac -b:a 192k -ar 48000 -ac 2 \
    "$OUTPUT"
else
  # No internal cut
  ffmpeg -y $TRIM_FLAG -i "$INPUT" \
    -vf "$BASE" \
    -af "$AUDIO_FILTER" \
    -c:v libx264 -profile:v high -preset medium -crf 21 -pix_fmt yuv420p \
    -c:a aac -b:a 192k -ar 48000 -ac 2 \
    "$OUTPUT"
fi

echo "✓ $OUTPUT"
