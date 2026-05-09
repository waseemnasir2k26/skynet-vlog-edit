#!/usr/bin/env bash
# Generate royalty-free background music — Am→F→C→G chord progression
# Loops to fill any duration.
#
# Usage:
#   ./02_gen_music.sh OUTPUT_WAV TARGET_DURATION_SECONDS

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../presets/music.preset.sh"

OUTPUT="$1"
DURATION="$2"
WORK="$(dirname "$OUTPUT")/_music_tmp"
mkdir -p "$WORK"

# Generate 4 chord pads (4s each)
gen_chord_pad "$WORK/am.wav" "${CHORD_AM[@]}"
gen_chord_pad "$WORK/f.wav"  "${CHORD_F[@]}"
gen_chord_pad "$WORK/c.wav"  "${CHORD_C[@]}"
gen_chord_pad "$WORK/g.wav"  "${CHORD_G[@]}"

# Concat into 16s progression
{
  echo "file '$WORK/am.wav'"
  echo "file '$WORK/f.wav'"
  echo "file '$WORK/c.wav'"
  echo "file '$WORK/g.wav'"
} > "$WORK/list.txt"
ffmpeg -y -f concat -safe 0 -i "$WORK/list.txt" -c copy "$WORK/progression16.wav" 2>&1 | tail -1

# Loop to target duration + apply post-fx + fades
LOOPS=$(awk "BEGIN{print int(($DURATION/16)+1)}")
ffmpeg -y -stream_loop $LOOPS -i "$WORK/progression16.wav" -t "$DURATION" \
  -af "tremolo=f=${MUSIC_TREMOLO_F}:d=${MUSIC_TREMOLO_D},aecho=${MUSIC_ECHO},lowpass=f=${MUSIC_LOWPASS},highpass=f=${MUSIC_HIGHPASS},afade=t=in:st=0:d=2,afade=t=out:st=$(awk "BEGIN{print $DURATION-3}"):d=3" \
  -ar 48000 -ac 2 -c:a pcm_s16le "$OUTPUT" 2>&1 | tail -1

rm -rf "$WORK"
echo "✓ $OUTPUT (${DURATION}s)"
