#!/usr/bin/env python3
"""
Genera un archivo .conf para Kitty a partir de un JSON Base16.
Uso: json-to-kitty.py <current.json> [--output <theme.conf>]
"""

import json
import argparse
import sys
from pathlib import Path


KITTY_MAP = {
    "background": "base00",
    "foreground": "base05",
    "cursor": "base05",
    "cursor_text_color": "base00",
    "url_color": "base0d",
    "selection_foreground": "base05",
    "selection_background": "base02",
    "color0": "base00",
    "color1": "base08",
    "color2": "base0b",
    "color3": "base0a",
    "color4": "base0d",
    "color5": "base0e",
    "color6": "base0c",
    "color7": "base05",
    "color8": "base03",
    "color9": "base08",
    "color10": "base0b",
    "color11": "base0a",
    "color12": "base0d",
    "color13": "base0e",
    "color14": "base0c",
    "color15": "base07",
}

TAB_MAP = {
    "active_tab_foreground": "base05",
    "active_tab_background": "base0a",
    "inactive_tab_foreground": "base05",
    "inactive_tab_background": "base01",
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


def hex_to_kitty(value):
    return value.lstrip("#").lower()


def generate_conf(hex_palette, name, variant):
    lines = []

    lines.append("# name: "+ name)
    lines.append("# variant: "+ variant)
    lines.append("selection_foreground    #" + hex_to_kitty(hex_palette[KITTY_MAP["selection_foreground"]]))
    lines.append("selection_background    #" + hex_to_kitty(hex_palette[KITTY_MAP["selection_background"]]))
    lines.append("")
    lines.append("background              #" + hex_to_kitty(hex_palette[KITTY_MAP["background"]]))
    lines.append("foreground              #" + hex_to_kitty(hex_palette[KITTY_MAP["foreground"]]))
    lines.append("")

    for key in ("color0", "color1", "color2", "color3", "color4", "color5",
                "color6", "color7", "color8", "color9", "color10", "color11",
                "color12", "color13", "color14", "color15"):
        lines.append(f"{key:<22} #" + hex_to_kitty(hex_palette[KITTY_MAP[key]]))

    lines.append("")
    lines.append("cursor                  #" + hex_to_kitty(hex_palette[KITTY_MAP["cursor"]]))
    lines.append("cursor_text_color       #" + hex_to_kitty(hex_palette[KITTY_MAP["cursor_text_color"]]))
    lines.append("")
    lines.append("url_color               #" + hex_to_kitty(hex_palette[KITTY_MAP["url_color"]]))
    lines.append("")
    for key, base_key in TAB_MAP.items():
        lines.append(f"{key:<22} #" + hex_to_kitty(hex_palette[base_key]))
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(
        description="Genera un archivo .conf para Kitty desde un JSON Base16."
    )
    parser.add_argument("input", help="Archivo JSON del tema (current.json).")
    parser.add_argument(
        "--output", "-o",
        default=str(Path.home() / ".config/kitty/current-theme.conf"),
        help="Archivo .conf de salida (default: current-theme.conf).",
    )
    args = parser.parse_args()

    try:
        hex_palette, name, variant = load_palette(args.input)
    except Exception as e:
        print(f"Error al leer el JSON: {e}", file=sys.stderr)
        sys.exit(1)

    conf_content = generate_conf(hex_palette, name, variant)

    try:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(conf_content)
        print(f"Tema Kitty generado: {args.output}")
    except Exception as e:
        print(f"Error al escribir el archivo: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
