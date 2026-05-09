#!/usr/bin/env bash
# Generate 5.5s outro card with staggered text reveals + Claude Code credit
#
# Usage:
#   ./03_gen_outro.sh OUTPUT
#
# Override text via env vars:
#   OUTRO_TITLE, OUTRO_SUBTITLE, OUTRO_HANDLE, OUTRO_PS, OUTRO_CREDIT

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../presets/caption.preset.sh"
source "$SCRIPT_DIR/../presets/grade.preset.sh"

OUTPUT="$1"
WORK="$(dirname "$OUTPUT")"
TMP="$WORK/_outro_p1.mp4"

OUTRO_BG_COLOR="${OUTRO_BG_COLOR:-0x0d1a3a}"
OUTRO_PANEL_COLOR="${OUTRO_PANEL_COLOR:-0x1f3a8a@0.35}"
OUTRO_ACCENT_COLOR="${OUTRO_ACCENT_COLOR:-0xfbbf24}"
OUTRO_DURATION="${OUTRO_DURATION:-5.5}"

OUTRO_TITLE="${OUTRO_TITLE:-Thanks for watching}"
OUTRO_SUBTITLE="${OUTRO_SUBTITLE:-Short vlog from Bali}"
OUTRO_HANDLE="${OUTRO_HANDLE:-@waseemnasir}"
OUTRO_PS="${OUTRO_PS:-P.S. I did not edit this vlog}"
OUTRO_CREDIT="${OUTRO_CREDIT:-Claude Code did it for me}"

# Pass 1 — bg + panel + top 3 lines (drawbox needs ih/iw)
ffmpeg -y \
  -f lavfi -i "color=c=${OUTRO_BG_COLOR}:s=${OUT_W}x${OUT_H}:r=${OUT_FPS}:d=${OUTRO_DURATION}" \
  -f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=48000:d=${OUTRO_DURATION}" \
  -vf "drawbox=x=0:y=ih*0.30:w=iw:h=ih*0.40:color=${OUTRO_PANEL_COLOR}:t=fill,drawtext=fontfile='${CAPTION_FONT}':text='${OUTRO_TITLE}':fontcolor=${OUTRO_ACCENT_COLOR}:fontsize=92:x=(w-text_w)/2:y=h*0.34:shadowcolor=black@0.7:shadowx=4:shadowy=4:enable='gte(t,0.4)',drawtext=fontfile='${CAPTION_FONT_LIGHT}':text='${OUTRO_SUBTITLE}':fontcolor=white:fontsize=58:x=(w-text_w)/2:y=h*0.43:shadowcolor=black@0.6:shadowx=2:shadowy=2:enable='gte(t,1.2)',drawtext=fontfile='${CAPTION_FONT_LIGHT}':text='${OUTRO_HANDLE}':fontcolor=0xa3a3a3:fontsize=40:x=(w-text_w)/2:y=h*0.49:enable='gte(t,2.0)'" \
  -c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest \
  "$TMP" 2>&1 | tail -1

# Pass 2 — divider + P.S. + credit + fades
ffmpeg -y -i "$TMP" \
  -vf "drawbox=x=iw*0.20:y=ih*0.56:w=iw*0.60:h=2:color=${OUTRO_ACCENT_COLOR}@0.6:t=fill,drawtext=fontfile='${CAPTION_FONT_ITALIC}':text='${OUTRO_PS}':fontcolor=0xe5e5e5:fontsize=44:x=(w-text_w)/2:y=h*0.61:enable='gte(t,3.0)',drawtext=fontfile='${CAPTION_FONT}':text='${OUTRO_CREDIT}':fontcolor=${OUTRO_ACCENT_COLOR}:fontsize=52:x=(w-text_w)/2:y=h*0.66:shadowcolor=black@0.6:shadowx=2:shadowy=2:enable='gte(t,3.8)',fade=t=in:st=0:d=0.5,fade=t=out:st=$(awk "BEGIN{print $OUTRO_DURATION-0.6}"):d=0.6" \
  -c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p -c:a copy \
  "$OUTPUT" 2>&1 | tail -1

rm -f "$TMP"
echo "✓ $OUTPUT"
