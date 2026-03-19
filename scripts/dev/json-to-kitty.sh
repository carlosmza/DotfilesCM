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

    # Función helper para base16
    get_color() {
        jq -r ".base16.$1.$mode.color" "$json"
    }

    background=$(get_color base00)
    foreground=$(get_color base05)
    cursor=$(jq -r ".colors.primary.$mode.color" "$json")
		selection_background=$(get_color base02)
		selection_foreground=$(get_color base06)
		cursor_trail_color=$cursor

    color0=$(get_color base00)
    color1=$(get_color base08)
    color2=$(get_color base0b)
    color3=$(get_color base0a)
    color4=$(get_color base0d)
    color5=$(get_color base0e)
    color6=$(get_color base0c)
    color7=$(get_color base05)

    color8=$(get_color base03)
    color9=$(get_color base08)
    color10=$(get_color base0b)
    color11=$(get_color base0a)
    color12=$(get_color base0d)
    color13=$(get_color base0e)
    color14=$(get_color base0c)
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
