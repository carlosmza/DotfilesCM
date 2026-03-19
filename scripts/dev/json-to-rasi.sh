#!/usr/bin/env bash

JSONDIR="$HOME/.config/system-themes/wallpaper-colorschemes"
RASIDIR="$HOME/.config/rofi/themes"

mkdir -p "$RASIDIR"

for json in "$JSONDIR"/*.json; do
    [ -f "$json" ] || continue

    name=$(basename -- "$json")
    name="${name%.json}"

    outfile="$RASIDIR/$name.rasi"

		mode=$(jq -r '.mode' "$json")

    echo "Generando theme rofi para $name (modo: $mode)"

    bg=$(jq -r ".colors.surface.${mode}.color" "$json")
    bg_alt=$(jq -r ".colors.surface_variant.${mode}.color" "$json")
    fg=$(jq -r ".colors.on_surface.${mode}.color" "$json")
    fg_alt=$(jq -r ".colors.outline.${mode}.color" "$json")
    accent=$(jq -r ".colors.primary.${mode}.color" "$json")

    cat > "$outfile" <<EOF
* {
    bg:               ${bg};
    bg-alt:           ${bg_alt};
    fg:               ${fg};
    fg-alt:           ${fg_alt};
    accent:           ${accent};
    background-color: transparent;
    text-color:       @fg;
}
EOF

done
