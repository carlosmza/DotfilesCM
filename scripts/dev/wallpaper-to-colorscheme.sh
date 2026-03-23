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
		mean=$(magick "$img" -colorspace Gray -format "%[fx:mean*100]" info:)
		p10=$(magick "$img" -colorspace Gray -format "%[fx:quantile(0.1)*100]" info:)
		p90=$(magick "$img" -colorspace Gray -format "%[fx:quantile(0.9)*100]" info:)
		contrast=$(echo "$p90 - $p10" | bc -l)

		if (( $(echo "$contrast < 15" | bc -l) )); then
				echo "[$name] descartado (bajo contraste)"
				continue
		fi

		if (( $(echo "$mean > 60 && $contrast > 30" | bc -l) )); then
				mode="light"
		elif (( $(echo "$mean < 45 && $contrast > 25" | bc -l) )); then
				mode="dark"
		elif (( $(echo "$contrast < 20" | bc -l) )); then
				mode="dark"  # evita temas lavados
		else
				mode="dark"
		fi
    outfile="$COLORDIR/${name}.json"

    echo "[$name] brillo: $brightness → modo: $mode"
		echo "[$name] → median: $median | std: $std → $mode"

    matugen image "$img" --mode "$mode" --json hex --contrast 1.2 > "$outfile"

done
