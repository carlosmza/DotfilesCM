#!/usr/bin/env python3
"""
Genera theme.rasi para Rofi a partir de un archivo JSON con paleta base16.
Estructura esperada:
{
  "palette": {
    "base00": "#...",
    "base01": "#...",
    ...
    "base0F": "#..."
  }
}

Uso:
    ./json-to-rasi.py entrada.json
    ./json-to-rasi.py entrada.json -o output.rasi
    cat entrada.json | ./json-to-rasi.py
"""

import sys
import json
import argparse

# Mapeo de variables Rofi a claves de la paleta base16
ROFI_BASE16_MAP = {
    "bg": "base00",
    "bg-alt": "base01",
    "fg": "base05",
    "fg-alt": "base04",
    "accent": "base0D",
    "selected-normal-bg": "base0D",
    "selected-normal-fg": "base00",
    "urgent-bg": "base08",
    "urgent-fg": "base00",
    "active-bg": "base02",
    "active-fg": "base05",
    "highlight": "base09",
    "window-bg": "base00",
}

def main():
    parser = argparse.ArgumentParser(description="Convierte JSON base16 a theme.rasi")
    parser.add_argument("input", nargs="?", help="Archivo JSON (stdin si se omite)")
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

    # Verificar que existe "palette"
    palette = data.get("palette")
    if not palette:
        print("Error: el JSON no contiene la clave 'palette'.", file=sys.stderr)
        sys.exit(1)

    # Verificar que existen todas las claves base necesarias
    required_base_keys = set(ROFI_BASE16_MAP.values())
    missing = [k for k in required_base_keys if k not in palette]
    if missing:
        print(f"Error: faltan las siguientes claves en la paleta: {', '.join(missing)}", file=sys.stderr)
        sys.exit(1)

    # Construir contenido del tema Rofi
    lines = ["* {"]
    for rofi_var, base_key in ROFI_BASE16_MAP.items():
        hex_color = palette[base_key].lstrip("#")
        lines.append(f"    {rofi_var}:       #{hex_color};")
    lines.append("    background-color: transparent;")
    lines.append("    text-color:       @fg;")
    lines.append("}")

    with open(args.output, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

    print(f"Archivo '{args.output}' generado correctamente.")

if __name__ == "__main__":
    main()
