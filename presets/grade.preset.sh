#!/usr/bin/env bash
# Color grade preset — warm tropical/outdoor lift

GRADE_CONTRAST="${GRADE_CONTRAST:-1.06}"
GRADE_SATURATION="${GRADE_SATURATION:-1.12}"
GRADE_GAMMA="${GRADE_GAMMA:-0.98}"
GRADE_BRIGHTNESS="${GRADE_BRIGHTNESS:-0}"

# Output dimensions
OUT_W="${OUT_W:-1080}"
OUT_H="${OUT_H:-1920}"
OUT_FPS="${OUT_FPS:-30}"

# Returns the base video filter chain (scale + fps + grade)
base_video_filter() {
  echo "scale=${OUT_W}:${OUT_H}:flags=lanczos,fps=${OUT_FPS},eq=contrast=${GRADE_CONTRAST}:saturation=${GRADE_SATURATION}:gamma=${GRADE_GAMMA}:brightness=${GRADE_BRIGHTNESS}"
}
