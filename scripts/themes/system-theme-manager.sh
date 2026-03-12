#!/usr/bin/env bash

WALLDIR="$HOME/Pictures/Wallpapers"
THUMBDIR="$HOME/.cache/wallpaper-thumbs"
PRESETS_FILE="$HOME/.config/swww/swww-presets.conf"

PRESET=$(grep -v '^\s*#' "$PRESETS_FILE" | grep -v '^\s*$' | shuf -n 1)

if [[ -z "$PRESET" ]]; then
    echo "Error: no se pudo leer ningún preset del archivo" >&2
    exit 1
fi

mkdir -p "$THUMBDIR"

# Generar thumbnails si no existen
for img in "$WALLDIR"/*; do
    name=$(basename "$img")
    thumb="$THUMBDIR/$name"

    if [ ! -f "$thumb" ]; then
        magick "$img" -thumbnail 400x400^ -gravity center -extent 400x400 "$thumb"
    fi
done

# Generación de paleta de colores dados los wallpapers -x-x
# Crear menú para rofi
MENU_THEME="~/.config/rofi/layouts/grid.rasi" #Por alguna razon esto no se puede pasar como parametro
choice=$(for img in "$WALLDIR"/*; do
    name=$(basename "$img")
    thumb="$THUMBDIR/$name"
    echo -en "$name\0icon\x1f$thumb\n"
done | rofi -dmenu -show-icons -theme "$MENU_THEME")

[ -n "$choice" ] && swww img "$WALLDIR/$choice" $PRESET
