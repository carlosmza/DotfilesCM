#!/usr/bin/env python3
"""
Genera theme.rasi enriquecido para Rofi a partir de scheme.json.
Incluye propiedades adicionales: selección, urgencia, activo, resaltado y fondo de ventana.
Uso:
    ./generate_rofi_theme.py scheme.json
    ./generate_rofi_theme.py scheme.json -o output.rasi
    cat scheme.json | ./generate_rofi_theme.py
"""

import sys
import json
import argparse

# Mapeo base de propiedades esenciales
BASE_ROFI_MAP = {
    "bg": "background",
    "bg-alt": "surfaceVariant",
    "fg": "onBackground",
    "fg-alt": "onSurfaceVariant",
    "accent": "primary",
}

# Propiedades extendidas (se añadirán después de las básicas)
EXTRA_ROFI_MAP = {
    "selected-normal-bg": "primaryContainer",
    "selected-normal-fg": "onPrimaryContainer",
    "urgent-bg": "error",
    "urgent-fg": "onError",
    "active-bg": "secondaryContainer",
    "active-fg": "onSecondaryContainer",
    "highlight": "error",        # texto resaltado al buscar
    "window-bg": "background",     # fondo del diálogo (antes transparente)
}

def main():
    parser = argparse.ArgumentParser(description="Convierte scheme.json a theme.rasi (completo)")
    parser.add_argument("input", nargs="?", help="Archivo scheme.json (stdin si se omite)")
    parser.add_argument("-o", "--output", default="theme.rasi", help="Archivo de salida (por defecto: theme.rasi)")
    args = parser.parse_args()

    # Leer JSON
    if args.input:
        with open(args.input, "r", encoding="utf-8") as f:
            data = json.load(f)
    else:
        if sys.stdin.isatty():
            print("Error: se espera entrada desde archivo o stdin.", file=sys.stderr)
            sys.exit(1)
        data = json.load(sys.stdin)

    colours = data.get("colours", {})
    if not colours:
        print("Error: el JSON no contiene la clave 'colours'.", file=sys.stderr)
        sys.exit(1)

    # Verificar claves necesarias (las de ambos mapeos)
    required_keys = set(BASE_ROFI_MAP.values()) | set(EXTRA_ROFI_MAP.values())
    missing = [k for k in required_keys if k not in colours]
    if missing:
        print(f"Error: faltan las siguientes claves en el JSON: {', '.join(missing)}", file=sys.stderr)
        sys.exit(1)

    # Construir líneas del tema
    lines = ["* {"]

    # Propiedades básicas
    lines.append(f"    bg:               #{colours[BASE_ROFI_MAP['bg']]};")
    lines.append(f"    bg-alt:           #{colours[BASE_ROFI_MAP['bg-alt']]};")
    lines.append(f"    fg:               #{colours[BASE_ROFI_MAP['fg']]};")
    lines.append(f"    fg-alt:           #{colours[BASE_ROFI_MAP['fg-alt']]};")
    lines.append(f"    accent:           #{colours[BASE_ROFI_MAP['accent']]};")

    # Propiedades extendidas
    for rofi_var, json_key in EXTRA_ROFI_MAP.items():
        if rofi_var == "window-bg":
            # Para la ventana se usa el fondo principal (background)
            lines.append(f"    {rofi_var}:       #{colours[json_key]};")
        else:
            lines.append(f"    {rofi_var}:       #{colours[json_key]};")

    # Transparencia y referencia a fg (se mantienen)
    lines.append("    background-color: transparent;")
    lines.append("    text-color:       @fg;")

    lines.append("}")

    with open(args.output, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

    print(f"Archivo '{args.output}' generado correctamente con propiedades extendidas.")

if __name__ == "__main__":
    main()
