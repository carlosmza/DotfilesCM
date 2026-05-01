#!/usr/bin/env bash
ls "$HOME/.config/system-themes/themes/" > /$HOME/.config/system-themes/themes.list
THEME_LIST="$HOME/.config/system-themes/themes.list"
LAYOUT="$HOME/.config/rofi/layouts/list-spotlight.rasi"
# TEMP=$(rofi -dmenu < "$THEME_LIST" -p "Themes" -theme "$LAYOUT")
TEMP=$(rofi -dmenu < "$THEME_LIST" -p "Themes")
[ -z "$TEMP" ] && exit 0
THEME="${TEMP%.*}" 

$HOME/.config/scripts/themes/apply-theme.sh "$THEME"

