#!/usr/bin/env bash

INTERNAL="eDP-1"
EXTERNAL="HDMI-A-1"


[ -z "$MODE" ] && exit 0

if hyprctl monitors | grep -q "$EXTERNAL"; then
	MODE=$(printf "Solo pantalla\nSolo proyector\nExtender\nEspejo" | rofi -dmenu -p "Display")
else
	MODE=$(printf "Solo pantalla" | rofi -dmenu -p "Display")

case "$MODE" in
  "Solo pantalla")
    hyprctl keyword monitor "$EXTERNAL,disable"
    hyprctl keyword monitor "$INTERNAL,preferred,0x0,1"
    ;;

  "Solo proyector")
    hyprctl keyword monitor "$INTERNAL,disable"
    hyprctl keyword monitor "$EXTERNAL,preferred,0x0,1"
    ;;

  "Extender")
    hyprctl keyword monitor "$INTERNAL,preferred,auto-left,1"
    hyprctl keyword monitor "$EXTERNAL,preferred,auto-right,1"
    ;;

  "Espejo")
    hyprctl keyword monitor "$INTERNAL,preferred,0x0,1"
    hyprctl keyword monitor "$EXTERNAL,preferred,0x0,1,mirror,$INTERNAL"
    ;;
esac
