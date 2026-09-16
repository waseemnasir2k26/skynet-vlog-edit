# skynet-vlog-edit

Reusable ffmpeg pipeline for editing raw phone/drone vlog clips into ready-to-post vertical videos (1080×1920) for IG Reels / TikTok / YT Shorts / FB Reels.

## Status

Last reviewed: September 2026 · release v2026.09

Built end-to-end from the **Bali Day longform** edit (Pakistani-bule-in-Bali series).

## What it does

Given N raw vertical clips → outputs single MP4 with:

- **Native 1080×1920** scaled, color-graded warm (contrast/sat/gamma lift)
- **Bottom-positioned captions** (Segoe UI Black, white + drop shadow + thin border, no background banner)
- **Cinematic xfade transitions** between clips (fade / fadewhite / slideleft / dissolve / fadeblack)
- **Audio crossfades** matching video transitions
- **Royalty-free background music** — synthesized Am→F→C→G chord progression w/ tremolo + reverb (no licensing risk)
- **Animated outro card** — staggered text reveals + Claude Code credit
- **Loudnorm -14 LUFS** (IG/TT broadcast spec)
- **faststart** flag (no buffer wait on socials)

## Requirements

- ffmpeg (must support libx264, drawtext, xfade, acrossfade, sine source, anullsrc, drawbox)
- Bash (Git Bash on Windows works)
- Windows fonts at `C:/Windows/Fonts/` (Segoe UI Black `seguibl.ttf`, Segoe UI `segoeui.ttf`) — adapt `presets/caption.preset.sh` for other OS

## Quick start

```bash
# 1. Copy example config + edit
cp examples/bali-day.config.sh examples/my-video.config.sh
# edit my-video.config.sh — point CLIPS array at your raw files,
# set CAPTIONS array (one per clip), pick TRIM seconds if any

# 2. Build
./build.sh examples/my-video.config.sh

# Output → output/<video-name>.mp4
```

## Pipeline stages

| stage | script | what |
|---|---|---|
| 1 | `pipeline/01_normalize_clip.sh` | scale 1080×1920, fps 30, color grade, burn captions, loudnorm audio |
| 2 | `pipeline/02_gen_music.sh` | synthesize Am→F→C→G chord pad (16s loop × N for any duration) |
| 3 | `pipeline/03_gen_outro.sh` | render 5.5s outro card w/ staggered reveals + Claude Code credit |
| 4 | `pipeline/04_stitch.sh` | xfade chain + acrossfade audio + bg music mix → final encode |

`build.sh` runs all 4 in order from a single config file.

## Config schema

See `examples/bali-day.config.sh` for full example.

```bash
VIDEO_NAME="bali-day"

# Source clips (raw mp4, vertical preferred — any aspect handled by scale filter)
CLIPS=(
  "D:/DCIM/DJI_001/DJI_xxxx_0137_D.MP4"
  "D:/DCIM/DJI_001/DJI_xxxx_0138_D.MP4"
  ...
)

# Per-clip caption(s) — array of "text|t_start|t_end" strings, multi-caption per clip allowed
CAPTIONS_01=("Bali morning|0.5|6" "Meet Murtaja|6.5|9.7")
CAPTIONS_02=("Breakfast hunt w/ Yasir|0.5|5" "Mission Circle K|5.5|10")
...

# Optional trim per clip (seconds; 0 = full clip)
TRIM_01=0
TRIM_02=10.23
TRIM_06=21
...

# Optional cut from inside a clip — array "t_start,t_end"
CUT_01=(8.0 9.0)   # remove 8-9s from clip 01

# Outro overrides (optional)
OUTRO_TITLE="Thanks for watching"
OUTRO_SUBTITLE="Short vlog from Bali"
OUTRO_HANDLE="@waseemnasir"
OUTRO_PS="P.S. I did not edit this vlog"
OUTRO_CREDIT="Claude Code did it for me"

# Transitions per cut point (between clip i and i+1)
TRANSITIONS=(fade fadewhite slideleft dissolve fade fadeblack)

# Music settings
MUSIC_VOLUME=0.22       # 0-1, low value = subtle bg
MUSIC_PROGRESSION="Am F C G"   # chord names
```

## Caption style (presets/caption.preset.sh)

Default — TikTok-style bottom captions, no banner:

- Font: Segoe UI Black 72pt
- Color: white
- Shadow: black @ 75% opacity, offset 4×4px
- Border: black @ 55% opacity, 2px (subtle anti-halo)
- Position: y = 82% of frame (bottom-center, safe zone)

Override per video by editing preset file or per-clip via config.

## Color grade (presets/grade.preset.sh)

Default warm lift:
```
eq=contrast=1.06:saturation=1.12:gamma=0.98
```

Tuned for tropical/outdoor footage (Bali day-light, beach, neon café). Adjust for indoor/night.

## Music — synthesis details

100% royalty-free (no copyright risk):

- 4 chord pads generated via `sine=f=N:d=4` (3 frequencies per chord = root + 5th + octave)
- Concatenated to 16s progression (Am 4s → F 4s → C 4s → G 4s)
- Looped to fill final video duration
- Post-processed: `tremolo=f=0.4:d=0.25, aecho=0.65:0.5:1100:0.4, lowpass=f=2300, highpass=f=60`
- Mixed at -22dB under voice → audible in quiet moments, ducks under speech

## Outro card (presets/outro.preset.sh)

5.5s dark navy bg + accent panel, 5 staggered text reveals:

| t | text | style |
|---|---|---|
| 0.4s | Title | gold 92pt Segoe UI Black + drop shadow |
| 1.2s | Subtitle | white 58pt Segoe UI |
| 2.0s | Handle | grey 40pt |
| 2.8s | Divider line | gold 60% width 2px |
| 3.0s | P.S. line | italic light grey 44pt |
| 3.8s | Credit ("Claude Code did it for me") | gold 52pt bold |

All text fully customizable via config.

## Examples

`examples/bali-day.config.sh` — full Pakistani-bule-in-Bali day vlog (76s, 6 clips + outro).

## Output spec

| param | value |
|---|---|
| Resolution | 1080×1920 |
| FPS | 30 |
| Codec | H.264 high profile, crf 21, slow preset |
| Audio | AAC 192k stereo 48kHz |
| Loudnorm | -14 LUFS |
| Faststart | yes |
| Container | MP4 |

Native upload-ready for IG Reels, TikTok, YouTube Shorts, Facebook Reels — no transcode needed.

## Credits

Built with Claude Code (Anthropic) for SkynetLabs vlog content pipeline.

## License

MIT
