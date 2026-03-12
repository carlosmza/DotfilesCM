#!/usr/bin/env bash
MODE=$(printf "Fullscreen\nSelection" | rofi -dmenu -p "si")

[ -z "$MODE" ] && exit 0

case "$MODE" in
  "Selection")
		grim -g "$(slurp)" ~/Pictures/Screenshots/Screenshot-From-$(date +"%Y-%m-%d_%H-%M-%S").png
    ;;

  "Fullscreen")
		grim ~/Pictures/Screenshots/Screenshot-From-$(date +"%Y-%m-%d_%H-%M-%S").png
		# grim ~/Pictures/full-$(date +"%Y-%m-%d_%H-%M-%S").png
    ;;
esac
