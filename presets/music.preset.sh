#!/usr/bin/env bash
# Music preset — Am→F→C→G chord progression
# Each chord = root + 5th + octave sine waves, 4s sustain
# Output looped to fill any duration

# Chord frequencies (Hz). Keep root in 80-130 range to sit below voice.
# Default = Am F C G progression (sad/contemplative pop standard)
CHORD_AM=(110.00 164.81 220.00)   # A2 E3 A3
CHORD_F=(87.31 130.81 174.61)     # F2 C3 F3
CHORD_C=(130.81 196.00 261.63)    # C3 G3 C4
CHORD_G=(98.00 146.83 196.00)     # G2 D3 G3

# Volumes per voice (0-1). Lower harmonics = quieter to avoid muddiness.
CHORD_V1="${CHORD_V1:-0.25}"
CHORD_V2="${CHORD_V2:-0.18}"
CHORD_V3="${CHORD_V3:-0.13}"

# Post-processing chain on full progression
MUSIC_TREMOLO_F="${MUSIC_TREMOLO_F:-0.4}"
MUSIC_TREMOLO_D="${MUSIC_TREMOLO_D:-0.25}"
MUSIC_ECHO="${MUSIC_ECHO:-0.65:0.5:1100:0.4}"
MUSIC_LOWPASS="${MUSIC_LOWPASS:-2300}"
MUSIC_HIGHPASS="${MUSIC_HIGHPASS:-60}"

# Volume in final mix (0-1). 0.18-0.25 = subtle bg.
MUSIC_VOLUME="${MUSIC_VOLUME:-0.22}"

# Generate one 4s chord pad at $1=output_path with frequencies $2 $3 $4
gen_chord_pad() {
  local OUT="$1" F1="$2" F2="$3" F3="$4"
  ffmpeg -y \
    -f lavfi -i "sine=f=$F1:d=4" \
    -f lavfi -i "sine=f=$F2:d=4" \
    -f lavfi -i "sine=f=$F3:d=4" \
    -filter_complex "[0:a]volume=${CHORD_V1}[a];[1:a]volume=${CHORD_V2}[b];[2:a]volume=${CHORD_V3}[c];[a][b][c]amix=inputs=3:duration=longest,afade=t=in:st=0:d=0.3,afade=t=out:st=3.6:d=0.4" \
    -ar 48000 -ac 2 -c:a pcm_s16le "$OUT" 2>&1 | tail -1
}
