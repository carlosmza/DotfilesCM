#!/usr/bin/env bash

SOCKET="/tmp/kitty.sock"
KITTY="/usr/bin/kitty"

if [ -S "$SOCKET" ]; then
    $KITTY @ --to unix:$SOCKET launch --type=os-window
else
    $KITTY --listen-on unix:$SOCKET --single-instance &
		sleep 0.2
fi
