#!/usr/bin/env bash

WALLDIR="$HOME/Pictures/Wallpapers"
COLORDIR="$HOME/.config/system-themes/wallpaper-colorschemes"

mkdir -p "$COLORDIR"

for img in "$WALLDIR"/*; do
    [ -f "$img" ] || continue

    name=$(basename -- "$img")
    name="${name%.*}"

		median=$(magick "$img" -colorspace Gray -format "%[fx:median*100]" info:)
    std=$(magick "$img" -colorspace Gray -format "%[fx:standard_deviation*100]" info:)

    if (( $(echo "$median > 55" | bc -l) )); then
        mode="light"
    elif (( $(echo "$std > 25 && $median > 40" | bc -l) )); then
        mode="light"
    else
        mode="dark"
    fi
    outfile="$COLORDIR/${name}.json"

    echo "[$name] brillo: $brightness → modo: $mode"
		echo "[$name] → median: $median | std: $std → $mode"

    matugen image "$img" --mode "$mode" --json hex > "$outfile"

done
