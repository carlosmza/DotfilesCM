#!/usr/bin/env bash

LAYOUT="/$HOME/.config/rofi/layouts/list-dashboard.rasi"
options=$("Dark"\n"Light")
MODE=$(echo -e "Dark\nLight" | rofi -dmenu -p "Mode" -theme "$LAYOUT")
if [[ $MODE == "Dark" ]]; then
	# echo "Dark Mode"
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
else
	# echo "Light Mode"
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
fi

echo "$MODE" > /$HOME/.config/system-themes/current
