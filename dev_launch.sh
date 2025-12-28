#!/bin/bash

# Dev launcher for muTube (host system)

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"


# Set Screen Width and Height
export SCREEN_WIDTH="1024"
export SCREEN_HEIGHT="768"
export SCREEN_RESOLUTION="${SCREEN_WIDTH}x${SCREEN_HEIGHT}"


# Set directories for where mpv, yt-dlp, and nodejs is installed in your dev environment
export MUTUBE_MPV="/usr/bin/mpv"
export MUTUBE_YTDLP="/home/beans-dev/.local/bin/yt-dlp"
export MUTUBE_FORMAT="worst"
export MUTUBE_NODE="/usr/bin/node"

# Optional: isolate Love2D data
export XDG_DATA_HOME="$PROJECT_DIR/.devdata"
export HOME="$PROJECT_DIR/.devdata"

mkdir -p "$XDG_DATA_HOME"

echo "${SCREEN_RESOLUTION}"

cd "$PROJECT_DIR" || exit 1
love .  --console "${SCREEN_RESOLUTION}"
~
