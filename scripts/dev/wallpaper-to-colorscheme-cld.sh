#!/usr/bin/env bash
# wallpaper-to-colorscheme.sh
# Genera esquemas de color desde wallpapers usando matugen
# Mejoras: luminancia perceptual Rec.709, variante vibrant para mayor contraste

WALLDIR="$HOME/Pictures/Wallpapers"
COLORDIR="$HOME/.config/system-themes/wallpaper-colorschemes"
VARIANT="${1:-vibrant}"  # Default: vibrant. Opciones: tonal_spot, vibrant, expressive, fidelity, fruit_salad

mkdir -p "$COLORDIR"

for img in "$WALLDIR"/*; do
    [ -f "$img" ] || continue

    name=$(basename -- "$img")
    name="${name%.*}"

    # --- Métricas de imagen ---
    # Luminancia perceptual (Rec. 709): L = 0.2126R + 0.7152G + 0.0722B
    # Más preciso que Gray simple para percepción humana
    lum=$(magick "$img" -colorspace Rec709Luma -format "%[fx:mean*100]" info:)

    # Desviación estándar perceptual (rango dinámico de la imagen)
    std=$(magick "$img" -colorspace Rec709Luma -format "%[fx:standard_deviation*100]" info:)

    # Saturación media (imágenes muy grises pueden necesitar ajuste)
    sat=$(magick "$img" -colorspace HSL -channel G -separate \
          -format "%[fx:mean*100]" info: 2>/dev/null || echo "50")

    # --- Detección de modo claro/oscuro ---
    # Umbral basado en luminancia perceptual (más fiable que median lineal)
    if (( $(echo "$lum > 60" | bc -l) )); then
        mode="light"
    elif (( $(echo "$lum > 45 && $std > 20" | bc -l) )); then
        # Alta variación con luminancia media → prefiere light para evitar fondos grises
        mode="light"
    else
        mode="dark"
    fi

    outfile="$COLORDIR/${name}.json"

    echo "[$name] lum: $(printf '%.1f' $lum) | std: $(printf '%.1f' $std) | sat: $(printf '%.1f' $sat) → modo: $mode | variante: $VARIANT"

    # --variant: vibrant/expressive dan colores más saturados y con mejor contraste
    # --json hex: salida en formato hexadecimal
    matugen image "$img" \
        --mode "$mode" \
        --variant "$VARIANT" \
        --json hex > "$outfile"

    # Inyectar el modo en el JSON para que otros scripts lo lean
    tmp=$(mktemp)
    jq --arg m "$mode" '. + {mode: $m}' "$outfile" > "$tmp" && mv "$tmp" "$outfile"

done

echo ""
echo "✅ Colorschemes generados en: $COLORDIR"
echo "   Uso: $0 [variante]  → ej: $0 expressive"
