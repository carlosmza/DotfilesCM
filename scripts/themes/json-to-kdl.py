#!/usr/bin/env python3
"""
Convierte un archivo JSON de esquema base16 a un archivo de tema KDL para Zellij.
Uso: json-to-kdl.py <archivo.json> [--output <salida.kdl>]
"""

import json
import argparse
import sys


FLAT_MAP = {
    "fg": "base05",
    "bg": "base00",
    "black": "base00",
    "white": "base05",
    "red": "base08",
    "green": "base0b",
    "yellow": "base0a",
    "blue": "base0d",
    "magenta": "base0e",
    "cyan": "base0c",
    "orange": "base09",
}


def load_base16_hex(json_path):
    """Carga un JSON base16 y devuelve (theme_name, {clave: #hex})."""
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    if data.get("system") != "base16":
        print("Advertencia: el JSON no tiene 'system': 'base16'. Se continuará de todas formas.")

    raw = data.get("palette")
    if not raw:
        raise ValueError("El JSON no contiene la clave 'palette'.")

    normalized = {k.lower(): v for k, v in raw.items()}

    hex_palette = {}
    for i in range(16):
        key = f"base{i:02x}"
        val = normalized.get(key)
        if not val:
            raise ValueError(f"Falta la clave de paleta: {key}")
        hex_palette[key] = val

    # theme_name = data.get("slug") or data.get("name") or "theme"
    # theme_name = "".join(c for c in theme_name if c.isalnum() or c in "-_")
    theme_name = "current"
    if not theme_name:
        theme_name = "theme"

    return theme_name, hex_palette


def generate_kdl(theme_name, hex_palette):
    indent = "  "
    lines = ["themes {"]
    lines.append(f"{indent}{theme_name} {{")

    for zellij_key, base_key in FLAT_MAP.items():
        hex_val = hex_palette[base_key]
        lines.append(f'{indent}{indent}{zellij_key} "{hex_val}"')

    lines.append(f"{indent}}}")
    lines.append("}")
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(
        description="Convierte un archivo JSON de paleta base16 a un tema KDL para Zellij."
    )
    parser.add_argument("input", help="Archivo JSON de entrada con el esquema base16.")
    parser.add_argument("--output", "-o", help="Archivo KDL de salida (por defecto: <nombre>.kdl). Puede incluir ruta completa.")
    args = parser.parse_args()

    try:
        theme_name, hex_palette = load_base16_hex(args.input)
    except Exception as e:
        print(f"Error al leer el archivo JSON: {e}", file=sys.stderr)
        sys.exit(1)

    kdl_content = generate_kdl(theme_name, hex_palette)

    output_path = args.output if args.output else f"{theme_name}.kdl"
    try:
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(kdl_content)
        print(f"Tema Zellij generado exitosamente: {output_path}")
    except Exception as e:
        print(f"Error al escribir el archivo de salida: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
