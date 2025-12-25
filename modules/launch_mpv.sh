#!/bin/bash

. /opt/muos/script/var/func.sh

# ALWAYS restore Love on exit (normal, crash, kill)
trap 'SET_VAR "system" "foreground_process" "love"' EXIT

MPV_BIN="$1"
STREAM_URL="$2"

# Stop any existing gptokeyb
killall -q gptokeyb2.armhf

# Set mpv as foreground
SET_VAR "system" "foreground_process" "mpv"

Start gptokeyb profile for mpv
/opt/muos/emulator/gptokeyb/gptokeyb2.armhf \
#    -c /MUOS/emulator/gptokeyb/mpv.gptk &

# ---- BLOCKING ----
"$MPV_BIN" "$STREAM_URL"

# ---- mpv exited ----

# Cleanup
killall -q gptokeyb2.armhf

# Restore Love input mapping
# /opt/muos/emulator/gptokeyb/gptokeyb2.armhf \
#    -c /MUOS/emulator/gptokeyb/love.gptk &
