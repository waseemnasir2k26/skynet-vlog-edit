#!/usr/bin/env bash
# Bali day vlog config — Pakistani-bule-in-Bali series
# Reproduces Bali-Day-LongForm-v6.mp4 from raw DJI clips

VIDEO_NAME="bali-day"

CLIPS=(
  "D:/DCIM/DJI_001/DJI_20260507134146_0137_D.MP4"   # 01 Waseem intro Murtaja
  "D:/DCIM/DJI_001/DJI_20260507134240_0138_D.MP4"   # 02 walking w/ Yasir
  "D:/DCIM/DJI_001/DJI_20260507134404_0139_D.MP4"   # 03 Murtaja cheers
  "D:/DCIM/DJI_001/DJI_20260507134919_0143_D.MP4"   # 04 drinks fridge haram
  "D:/DCIM/DJI_001/DJI_20260507140243_0146_D.MP4"   # 05 burrito acquired
  "D:/DCIM/DJI_001/DJI_20260507143446_0153_D.MP4"   # 06 Torst caramel macchiato
)

# Per-clip captions: array of "text|t_start|t_end"
CAPTIONS_01=("Bali morning|0.5|6" "Meet Murtaja|6.5|9.7")
CAPTIONS_02=("Breakfast hunt w/ Yasir|0.5|5" "Mission Circle K|5.5|10")
CAPTIONS_03=("Cheers from Murtaja|0.3|3.7")
CAPTIONS_04=("Bro... yeh sab haram|0.5|9" "Next aisle|10|19")
CAPTIONS_05=("Burrito acquired|0.5|8")
CAPTIONS_06=("Torst Cafe|0.5|7" "Caramel macchiato|7.5|17" "It is amazing|17.5|21")

# Trim each clip to N seconds (0 = full)
TRIM_01=0
TRIM_02=10.23
TRIM_03=0
TRIM_04=0
TRIM_05=0
TRIM_06=21

# Internal cuts — remove t_start to t_end (e.g. duplicate "habibi habibi")
CUT_01=(8.0 9.0)

# Transitions between clips (n-1 + 1 to outro = n total)
TRANSITIONS="fade fadewhite slideleft dissolve fade fadeblack"

# Music + outro overrides
MUSIC_VOLUME=0.22
OUTRO_TITLE="Thanks for watching"
OUTRO_SUBTITLE="Short vlog from Bali"
OUTRO_HANDLE="@waseemnasir"
OUTRO_PS="P.S. I did not edit this vlog"
OUTRO_CREDIT="Claude Code did it for me"
