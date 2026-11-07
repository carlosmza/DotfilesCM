#!/usr/bin/env python3
"""
Genera un archivo .ini de colores para Foot a partir de un JSON Base16.
Uso: json-to-foot.py <current.json> [--output <theme-current.ini>]

La paleta se escribe en las secciones [colors-dark] y [colors-light]
para que aplique independientemente del modo del sistema. 'alpha' y
'blur' se dejan en foot.ini (preferencia del usuario, no del tema).
"""

import json
import argparse
import sys
from pathlib import Path


FOOT_MAP = {
    "background": "base00",
    "foreground": "base05",
    "selection-foreground": "base05",
    "selection-background": "base02",
    "urls": "base0d",
    "regular0": "base00",
    "regular1": "base08",
    "regular2": "base0b",
    "regular3": "base0a",
    "regular4": "base0d",
    "regular5": "base0e",
    "regular6": "base0c",
    "regular7": "base05",
    "bright0": "base03",
    "bright1": "base08",
    "bright2": "base0b",
    "bright3": "base0a",
    "bright4": "base0d",
    "bright5": "base0e",
    "bright6": "base0c",
    "bright7": "base07",
}


def load_palette(json_path):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    raw = data.get("palette")
    name = data.get("name")
    variant = data.get("variant")
    if not raw:
        raise ValueError("El JSON no contiene la clave 'palette'.")

    normalized = {k.lower(): v for k, v in raw.items()}
    hex_palette = {}
    for i in range(16):
        key = f"base{i:02x}"
        val = normalized.get(key)
        if not val:
            raise ValueError(f"Falta la clave de paleta: {key}")
        hex_palette[key] = val.lstrip("#")

    return hex_palette, name, variant


def generate_ini(hex_palette, name, variant):
    lines = []

    lines.append("# name: " + str(name))
    lines.append("# variant: " + str(variant))

    for section in ("colors-dark", "colors-light"):
        lines.append("")
        lines.append(f"[{section}]")
        for key, base_key in FOOT_MAP.items():
            lines.append(f"{key}={hex_palette[base_key].lower()}")
        cursor_val = f"{hex_palette['base05'].lower()} {hex_palette['base06'].lower()}"
        lines.append(f"cursor={cursor_val}")

    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(
        description="Genera un archivo .ini de colores para Foot desde un JSON Base16."
    )
    parser.add_argument("input", help="Archivo JSON del tema (current.json).")
    parser.add_argument(
        "--output", "-o",
        default=str(Path.home() / ".config/foot/theme-current.ini"),
        help="Archivo .ini de salida (default: theme-current.ini).",
    )
    args = parser.parse_args()

    try:
        hex_palette, name, variant = load_palette(args.input)
    except Exception as e:
        print(f"Error al leer el JSON: {e}", file=sys.stderr)
        sys.exit(1)

    ini_content = generate_ini(hex_palette, name, variant)

    try:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(ini_content)
        print(f"Tema Foot generado: {args.output}")
    except Exception as e:
        print(f"Error al escribir el archivo: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
