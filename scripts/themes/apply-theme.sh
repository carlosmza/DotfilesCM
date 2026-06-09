#!/usr/bin/env bash

# Explicación de Flags: 
# -e: Termina el script si un comando falla.
# -u: Lanza un error si se intenta usar una variable no declarada.
# -o pipefail: Captura errores dentro de pipelines (|).
set -euo pipefail

echo "=== $(date '+%Y-%m-%d %H:%M:%S') ==="

# 1. Verificación del argumento obligatorio
THEME="${1:-}" # Asigna cadena vacía si no se pasa el parámetro $1 para evitar error de 'set -u'
if [[ -z "$THEME" ]]; then
    echo "ERROR: No se especificó ningún tema como argumento." >&2
    exit 1
fi
echo "Aplicando tema: $THEME"

# 2. Verificación de Dependencias Críticas
# Estructura: Comprobamos si las herramientas base están disponibles en el PATH
for cmd in jq hyprctl lua; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "ERROR: La dependencia requerida '$cmd' no está instalada." >&2
        exit 1
    fi
done

# 3. Verificación del Archivo de Origen
THEME_SOURCE="$HOME/.config/system-themes/themes/${THEME}.json"
if [[ ! -f "$THEME_SOURCE" ]]; then
    echo "ERROR: El archivo de tema no existe en: $THEME_SOURCE" >&2
    exit 1
fi

THEME_SYSTEM="$HOME/.config/system-themes/themes/current.json"

# Extraer variante con jq (seguro gracias a pipefail)
MODE=$(jq -r '.variant // "dark"' "$THEME_SOURCE") # '// "dark"' provee un fallback si la llave no existe

# __________ GENERAL __________
echo "Modificando tema global"
ln -sf "$THEME_SOURCE" "$THEME_SYSTEM"

# __________ HYPRLAND LUA __________
echo "Recargando Hyprland y ejecutando script de Lua..."
hyprctl reload || echo "Aviso: hyprctl reload falló (¿estás fuera de una sesión de Hyprland?)" >&2
lua "$HOME/.config/hypr/lua/scripts/read_theme.lua"

# __________ ZELLIJ __________
echo "Modificando tema de Zellij..."
ZELLIJ_THEME_FILE="$HOME/.config/zellij/themes/current.kdl"
if "$HOME/.config/scripts/themes/json-to-kdl.py" "$THEME_SYSTEM" --output "$ZELLIJ_THEME_FILE"; then
    chmod +x "$ZELLIJ_THEME_FILE"
    echo >> "$HOME/.config/zellij/config.kdl"
else
    echo "Aviso: No se pudo generar el archivo KDL para Zellij." >&2
fi

# __________ ROFI __________
echo "Modificando tema de Rofi..."
"$HOME/.config/scripts/themes/json-to-rasi.py" "$THEME_SYSTEM" -o \
    "$HOME/.config/rofi/themes/current.rasi"

# __________ QUICKSHELL __________
echo "Notificando a Quickshell..."
# Usamos '|| true' para que el script no muera si quickshell ipc no responde en ese instante
quickshell ipc call colores recargar || echo "Aviso: No se pudo comunicar con Quickshell IPC." >&2

# __________ DARK/LIGHT MODE __________
if [[ "$MODE" =~ dark ]]; then
    echo "Modo detectado: Oscuro"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
else
    echo "Modo detectado: Claro"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
fi

# __________ KITTY __________
echo "Modificando tema de Kitty..."
KITTY_CONF="$HOME/.config/kitty/current.conf"
EXPECTED_NAME=$(jq -r '.name // empty' "$THEME_SYSTEM")

if [[ -n "$EXPECTED_NAME" ]]; then
    VERIFIED=false
    for attempt in 1 2 3 4; do
        if "$HOME/.config/scripts/themes/json-to-kitty.py" "$THEME_SYSTEM" --output "$KITTY_CONF"; then
            READ_NAME=$(head -1 "$KITTY_CONF" 2>/dev/null | sed 's/^# name: //')
            if [[ "$READ_NAME" == "$EXPECTED_NAME" ]]; then
                echo "  ✓ Verificado con éxito (intento $attempt)"
                VERIFIED=true
                break
            fi
        fi
        echo "  ⚠ Desajuste de nombre o fallo en script, reintentando (intento $attempt)..."
        sleep 0.2
    done

    if [ "$VERIFIED" = true ]; then
        "$HOME/.config/scripts/system/reload-kitty.sh"
    else
        echo "ERROR: No se pudo verificar la consistencia del tema de Kitty tras 4 intentos." >&2
    fi
else
    echo "Aviso: El JSON del tema no contiene una propiedad '.name' válida." >&2
fi

# __________ Oh-my-posh __________
echo "Modificando tema Oh-my-posh..."
"$HOME/.config/scripts/themes/json-to-prompt.py" "$THEME_SYSTEM" "$HOME/.config/oh-my-posh/current.json"
pkill -USR1 fish || true

# Mantenemos tu lógica para terminales interactivas
[[ -t 0 ]] && exec fish
exit 0
