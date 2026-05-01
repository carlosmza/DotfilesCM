#!/usr/bin/env bash

INTERNAL="eDP-1"
EXTERNAL="HDMI-A-1"
#
# Check if EXTERNAL is connected
if hyprctl monitors | grep -q "$EXTERNAL"; then
  # $EXTERNAL is connected, extend eDP-1 and enable EXTERNAL
	hyprctl keyword monitor "$INTERNAL,preferred,auto-left,1"
	hyprctl keyword monitor "$EXTERNAL,preferred,auto-right,1"
else
  # $EXTERNAL is disconnected, enable eDP-1 and disable $EXTERNAL
	hyprctl keyword monitor "$EXTERNAL,disable"
	hyprctl keyword monitor "$INTERNAL,preferred,0x0,1"

fi
