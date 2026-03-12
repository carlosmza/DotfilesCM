#!/usr/bin/env bash

THEME_LIST="/$HOME/.config/system-themes/themes.list"
LAYOUT="/$HOME/.config/rofi/layouts/list-spotlight.rasi"
THEME=$(rofi -dmenu < "$THEME_LIST" -p "Themes" -theme "$LAYOUT")

[ -z "$THEME" ] && exit 0

echo "$THEME" > /home/carlosm/.config/theme/current

/home/carlosm/.config/scripts/apply-theme.sh "$THEME"

