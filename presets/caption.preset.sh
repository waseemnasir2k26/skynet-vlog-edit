#!/usr/bin/env bash
# Caption style preset — TikTok-style bottom captions, no banner

# Font path (Windows). Override for macOS/Linux:
#   macOS: /System/Library/Fonts/Supplemental/Arial Black.ttf
#   Linux: /usr/share/fonts/truetype/dejavu/DejaVu-Sans-Bold.ttf
CAPTION_FONT="${CAPTION_FONT:-C\\:/Windows/Fonts/seguibl.ttf}"
CAPTION_FONT_LIGHT="${CAPTION_FONT_LIGHT:-C\\:/Windows/Fonts/segoeui.ttf}"
CAPTION_FONT_ITALIC="${CAPTION_FONT_ITALIC:-C\\:/Windows/Fonts/segoeuii.ttf}"

CAPTION_SIZE="${CAPTION_SIZE:-72}"
CAPTION_COLOR="${CAPTION_COLOR:-white}"
CAPTION_BORDER_COLOR="${CAPTION_BORDER_COLOR:-black@0.55}"
CAPTION_BORDER_WIDTH="${CAPTION_BORDER_WIDTH:-2}"
CAPTION_SHADOW_COLOR="${CAPTION_SHADOW_COLOR:-black@0.75}"
CAPTION_SHADOW_X="${CAPTION_SHADOW_X:-4}"
CAPTION_SHADOW_Y="${CAPTION_SHADOW_Y:-4}"
CAPTION_Y_POS="${CAPTION_Y_POS:-h*0.82}"   # bottom-center

# Build a single drawtext filter string
# Usage: caption_filter "text" t_start t_end
caption_filter() {
  local TXT="$1" T1="$2" T2="$3"
  echo "drawtext=fontfile='${CAPTION_FONT}':text='${TXT}':fontcolor=${CAPTION_COLOR}:fontsize=${CAPTION_SIZE}:bordercolor=${CAPTION_BORDER_COLOR}:borderw=${CAPTION_BORDER_WIDTH}:shadowcolor=${CAPTION_SHADOW_COLOR}:shadowx=${CAPTION_SHADOW_X}:shadowy=${CAPTION_SHADOW_Y}:x=(w-text_w)/2:y=${CAPTION_Y_POS}:enable='between(t,${T1},${T2})'"
}
