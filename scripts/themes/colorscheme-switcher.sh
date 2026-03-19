#!/usr/bin/env bash
ls ~/.config/system-themes/wallpaper-colorschemes > ~/.config/system-themes/themes.list
THEME_LIST="/$HOME/.config/system-themes/themes.list"

LAYOUT="/$HOME/.config/rofi/layouts/list-spotlight.rasi"
# THEME=$(rofi -dmenu < "$THEME_LIST" -p "Themes" -theme "$LAYOUT")
THEME=$(sed 's/\.json$//' "$THEME_LIST" | rofi -dmenu -p "Themes" -theme "$LAYOUT")

[ -z "$THEME" ] && exit 0

echo "$THEME" > /home/carlosm/.config/system-themes/current

/home/carlosm/.config/scripts/themes/apply-theme.sh "$THEME"
