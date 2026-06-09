#!/usr/bin/env bash

APP="$1"
# [[ -z "$APP" ]] && exit 1

SOCKET="/tmp/kitty.sock"
KITTY="/usr/bin/kitty"

if [ -S "$SOCKET" ]; then
    $KITTY @ --to unix:$SOCKET launch --type=os-window "$APP"
else
    $KITTY --listen-on unix:$SOCKET --single-instance & "$APP"
		sleep 0.2
fi
