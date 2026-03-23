Contexto:
Actualmente uso el siguiente script Wallpaper-to-colorscheme.sh para obtener una palelta de colores la cual luego es usada para generar un coloscheme para kitty usando
json-to-kitty.sh
Conflicto: Los esquemas de colores no me han gustado lo suficiente para usarlos en mi kitty-terminal. Quiero tener un mejor contraste en mis colorschemes para poder ser
apreciados mejor visualmente. Dime que metricas ajustar para obtener un mejor colorscheme.

# Wallpaper-to-colorscheme.sh
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

# json-to-kitty.sh
#!/usr/bin/env bash

JSONDIR="$HOME/.config/system-themes/wallpaper-colorschemes"
KITTYDIR="$HOME/.config/kitty/themes"

mkdir -p "$KITTYDIR"

for json in "$JSONDIR"/*.json; do
    [ -f "$json" ] || continue

    name=$(basename -- "$json")
    name="${name%.json}"

    outfile="$KITTYDIR/$name.conf"

    echo "Generando kitty theme para $name"

    # Detectar modo desde JSON
    mode=$(jq -r '.mode' "$json")
		echo "mode:" "$mode"

		# if $mode == "dark"; then
		if [[ $mode =~ dark ]]; then
			background=$"#000000"
		else
			background=$"#ffffff"
		fi


    # Función helper para base16
    get_color() {
        jq -r ".base16.$1.$mode.color" "$json"
    }

		selection_background=$(get_color base02)
		selection_foreground=$(get_color base06)
		cursor_trail_color=$cursor
		# background=$(get_color base00)
		background=$background
		
		foreground=$(get_color base05)

		color0=$(get_color base00)
		color8=$(get_color base03)

		# Acentos desde Material You
		color1=$(jq -r ".colors.error.$mode.color" "$json")
		color2=$(jq -r ".colors.primary.$mode.color" "$json")
		color3=$(jq -r ".colors.tertiary.$mode.color" "$json")
		color4=$(jq -r ".colors.secondary.$mode.color" "$json")

		# secundarios más suaves
		color5=$(get_color base0e)
		color6=$(get_color base0c)
		color7=$(get_color base05)

		# bright
		color9=$color1
		color10=$color2
		color11=$color3
		color12=$color4
		color13=$color5
		color14=$color6
		color15=$(get_color base07)

    cat > "$outfile" <<EOF
# Auto-generated from $name

background $background
foreground $foreground
cursor $cursor
selection_background $selection_background
selection_foreground $selection_foreground
cursor_trail_color $cursor_trail_color

color0  $color0
color1  $color1
color2  $color2
color3  $color3
color4  $color4
color5  $color5
color6  $color6
color7  $color7

color8  $color8
color9  $color9
color10 $color10
color11 $color11
color12 $color12
color13 $color13
color14 $color14
color15 $color15
EOF
 
done

