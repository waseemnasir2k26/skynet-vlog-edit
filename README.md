# skynet-vlog-edit

Turn a folder of raw phone or drone clips into one captioned vertical vlog (1080x1920) with a shell script and ffmpeg. No editor, no subscription, no licensed music.

- Scales each clip to 1080x1920 at 30 fps with a warm colour grade.
- Burns bottom captions from a per-clip list (white text, drop shadow, no banner box).
- Joins clips with ffmpeg `xfade` transitions and matching audio crossfades.
- Synthesises a background chord pad with ffmpeg sine sources, so there is nothing to license.
- Renders a short animated outro card from text you set in the config.
- Exports H.264 with loudness normalised to -14 LUFS and the faststart flag.

## Quickstart

```bash
git clone https://github.com/waseemnasir2k26/skynet-vlog-edit.git && cd skynet-vlog-edit
cp examples/bali-day.config.sh examples/my-video.config.sh
# edit my-video.config.sh: CLIPS, CAPTIONS_01..N, optional TRIM_NN and CUT_NN
./build.sh examples/my-video.config.sh
```

The finished MP4 lands in `output/`.

## Pipeline

| Stage | Script                          | What it does                                               |
| ----- | ------------------------------- | ---------------------------------------------------------- |
| 1     | `pipeline/01_normalize_clip.sh` | Scale, grade, caption, normalise audio, one clip at a time |
| 2     | `pipeline/02_gen_music.sh`      | Generate the chord-pad music bed                           |
| 3     | `pipeline/03_gen_outro.sh`      | Render the outro card (text via `OUTRO_*` variables)       |
| 4     | `pipeline/04_stitch.sh`         | Transitions, audio crossfades, music mix, final encode     |

Look and feel live in `presets/`: `caption.preset.sh`, `grade.preset.sh`, `music.preset.sh`. Config options (trim, cut ranges, transitions, music volume, outro text) are shown in `examples/bali-day.config.sh`.

## Requirements

- ffmpeg built with libx264, drawtext and xfade.
- Bash (Git Bash works on Windows).
- The caption presets point at Segoe UI fonts in `C:/Windows/Fonts/`. On macOS or Linux, change the font path in `presets/caption.preset.sh`.

## For you if

You edit the same kind of vertical clip over and over and would rather keep a config file per video than open an editor.

## Status and limits

- Built around one real project, a Bali day vlog (`examples/bali-day.config.sh`, 6 clips plus outro). The example paths and captions are from that project; replace them.
- The default outro text credits Claude Code. It is a string you can change.
- No GUI and no speech-to-text: captions are text you write per clip.
- Only the author has run it so far, on Windows.

## License

MIT, see [LICENSE](LICENSE).

---

Built by SkynetLabs. Contact: info@skynetjoe.com

Need this wired into your business? SkynetLabs builds voice agents, n8n back offices and sites that convert → https://skynetjoe.com
