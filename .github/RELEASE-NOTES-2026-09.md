# 2026.09 — Maintenance release

- Maintenance review of skynet-vlog-edit — a reusable ffmpeg/bash pipeline that turns raw vertical phone or drone clips into ready-to-post 1080×1920 videos for IG Reels, TikTok, YT Shorts and FB Reels.
- Status: `build.sh` driving four pipeline stages (`01_normalize_clip`, `02_gen_music`, `03_gen_outro`, `04_stitch`) with three tunable presets (caption, grade, music) and one worked config in `examples/bali-day.config.sh`. Produces a warm grade, bottom-positioned captions, xfade transitions with matching audio crossfades, a synthesized royalty-free Am–F–C–G music bed, an animated outro card, loudnorm at -14 LUFS and the faststart flag. Licensed; no build system beyond ffmpeg and bash.
- Reviewed September 2026: docs refreshed, CHANGELOG started, released as v2026.09. No pipeline, preset or example changes.
- Known gaps: the pipeline is Windows-bound by default — `presets/caption.preset.sh` points at `C:/Windows/Fonts/` for Segoe UI Black and Segoe UI, and the README says other operating systems require editing that preset. There is no font-path fallback.
- Known gaps: the repo is still at its initial release (single commit, 2026-05-10); nothing here has been re-run or re-verified against a current ffmpeg build, and there are no tests or sample output to prove the stages still render.
- Repo hygiene: LICENSE present; no CHANGELOG before this release, no CI workflow, and no version manifest, so there is no machine-readable version to bump.
