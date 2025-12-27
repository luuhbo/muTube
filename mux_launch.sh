#!/bin/bash
# HELP: Scrappy
# ICON: scrappy
# GRID: Scrappy

. /opt/muos/script/var/func.sh

# Define global variables

if pgrep -f "playbgm.sh" >/dev/null; then
	killall -q "playbgm.sh" "mpg123"
fi

echo app >/tmp/act_go

# Define paths and commands
LOVEDIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/application/muTube/"
# GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/gptokeyb/gptokeyb2.armhf"
STATICDIR="$LOVEDIR/static/"
BINDIR="$LOVEDIR/bin"

# Export environment variables
SETUP_SDL_ENVIRONMENT
export XDG_DATA_HOME="$STATICDIR"
export HOME="$STATICDIR"
export LD_LIBRARY_PATH="$BINDIR/libs.aarch64:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$BINDIR/plugins"

# mpv and yt-dlp binaries for TrimUI
export MUTUBE_MPV="$BINDIR/mpv"
export MUTUBE_YTDLP="$BINDIR/yt-dlp"
export MUTUBE_FORMAT="worst"
export MUTUBE_NODE="$BINDIR/node"

export SCREEN_WIDTH=$(GET_VAR device mux/width)
export SCREEN_HEIGHT=$(GET_VAR device mux/height)
export SCREEN_RESOLUTION="${SCREEN_WIDTH}x${SCREEN_HEIGHT}"

export GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/PortMaster/gptokeyb2.armhf"
export GPTOKEY_MPV_CONFIG="/opt/muos/share/emulator/gptokeyb/ext-mpv-general.gptk"

export FUNC_SCRIPT="/opt/muos/script/var/func.sh"


# Launcher
cd "$LOVEDIR" || exit
SET_VAR "system" "foreground_process" "love"

echo "${SCREEN_RESOLUTION}"

# Run Application
./bin/love . "${SCREEN_RESOLUTION}" > "$LOVEDIR/output.log" 2>&1

kill -9 "$(pidof gptokeyb2.armhf)"