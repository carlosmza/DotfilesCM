#!/usr/bin/env bash

THEMES_DIR="$HOME/.config/system-themes/themes/"
THEME_LIST="$HOME/.config/system-themes/themes.list"
LAYOUT="$HOME/.config/rofi/layouts/list-spotlight.rasi"
CURRENT_JSON="$THEMES_DIR/current.json"

# Función para obtener el nombre del tema actual desde current.json
get_current_theme_name() {
    if [[ -f "$CURRENT_JSON" ]]; then
        # Si jq está instalado, lo usamos; si no, intentamos con grep/sed
        if command -v jq &>/dev/null; then
            jq -r '.name // "desconocido"' "$CURRENT_JSON" 2>/dev/null || echo "desconocido"
        else
            # Extracción simple con sed (asume "name": "algo")
            sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$CURRENT_JSON" | head -1
            [[ -z "$current_name" ]] && echo "desconocido"
        fi
    else
        echo "ninguno"
    fi
}

CURRENT_THEME=$(get_current_theme_name)

# Genera la lista de temas: solo archivos .json, sin extensión, omitiendo "current"
cd "$THEMES_DIR" || exit 1
shopt -s nullglob
for file in *.json; do
    base="${file%.json}"
    [[ "$base" == "current" ]] && continue
    echo "$base"
done > "$THEME_LIST"

# Construir el prompt con el tema actual
PROMPT="Themes (actual: $CURRENT_THEME)"

# Mostrar rofi
TEMP=$(rofi -dmenu < "$THEME_LIST" -p "$PROMPT" -theme "$LAYOUT")
[ -z "$TEMP" ] && exit 0

# Limpieza por si acaso
THEME="${TEMP%.*}"

# Aplicar el tema seleccionado
"$HOME/.config/scripts/themes/apply-theme.sh" "$THEME"
