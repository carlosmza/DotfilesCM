#!/usr/bin/env python3
"""
Genera archivos theme.rasi para Rofi a partir de JSON con paleta base16.
Estructura esperada:
{
  "palette": {
    "base00": "#...",
    ...
    "base0F": "#..."
  }
}

Modos de uso:
  1. Archivo único:   ./json-to-rasi.py entrada.json
  2. Directorio:      ./json-to-rasi.py --dir ./carpeta_jsons/
  3. Desde stdin:     cat entrada.json | ./json-to-rasi.py
  4. Especificar salida: ./json-to-rasi.py entrada.json -o output.rasi
  5. Directorio con carpeta de salida: ./json-to-rasi.py --dir ./jsons/ --output-dir ./rasis/
"""

import sys
import json
import argparse
from pathlib import Path

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


def convert_json_to_rasi(json_path: Path, output_dir: Path = None):
    """
    Lee un JSON con paleta base16 y escribe su correspondiente archivo .rasi.
    Si output_dir es None, se guarda en el mismo directorio del JSON con extensión .rasi.
    Retorna True en caso de éxito, False en caso de error.
    """
    # Leer JSON
    try:
        with open(json_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error al leer {json_path}: {e}", file=sys.stderr)
        return False

    palette = data.get("palette")
    if not palette:
        print(f"Error: '{json_path.name}' no contiene la clave 'palette'.", file=sys.stderr)
        return False

    # Verificar claves necesarias
    required = set(ROFI_BASE16_MAP.values())
    missing = required - set(palette.keys())
    if missing:
        print(f"Error: en '{json_path.name}' faltan las claves base: {', '.join(missing)}", file=sys.stderr)
        return False

    # Ruta de salida
    if output_dir:
        out_path = output_dir / (json_path.stem + ".rasi")
    else:
        out_path = json_path.with_suffix(".rasi")

    out_path.parent.mkdir(parents=True, exist_ok=True)

    # Construir contenido
    lines = ["* {"]
    for rofi_var, base_key in ROFI_BASE16_MAP.items():
        hex_color = palette[base_key].lstrip("#")
        lines.append(f"    {rofi_var}:       #{hex_color};")
    lines.append("    background-color: transparent;")
    lines.append("    text-color:       @fg;")
    lines.append("}")

    try:
        with open(out_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")
    except Exception as e:
        print(f"Error al escribir {out_path}: {e}", file=sys.stderr)
        return False

    print(f"✓ {json_path.name} → {out_path.name}", file=sys.stderr)
    return True


def main():
    parser = argparse.ArgumentParser(description="Convierte JSON base16 a theme.rasi para Rofi")
    grupo = parser.add_mutually_exclusive_group()
    grupo.add_argument("input", nargs="?", help="Archivo JSON de entrada (o stdin si se omite, y no se usa --dir)")
    grupo.add_argument("--dir", "-d", type=str, help="Directorio con archivos .json para convertir en lote")

    parser.add_argument("-o", "--output", help="Archivo .rasi de salida (solo con archivo único)")
    parser.add_argument("--output-dir", help="Directorio de salida para los .rasi (solo con --dir)")
    parser.add_argument("--recursive", action="store_true", help="(con --dir) Procesa subdirectorios recursivamente")
    args = parser.parse_args()

    # Modo directorio
    if args.dir:
        input_dir = Path(args.dir)
        if not input_dir.is_dir():
            print(f"Error: '{input_dir}' no es un directorio válido.", file=sys.stderr)
            sys.exit(1)

        json_files = list(input_dir.glob("**/*.json" if args.recursive else "*.json"))
        if not json_files:
            print(f"No se encontraron archivos .json en '{input_dir}'.", file=sys.stderr)
            sys.exit(0)

        output_dir = Path(args.output_dir) if args.output_dir else None
        if output_dir:
            output_dir.mkdir(parents=True, exist_ok=True)

        success = 0
        fail = 0
        for jf in json_files:
            if convert_json_to_rasi(jf, output_dir):
                success += 1
            else:
                fail += 1

        print(f"\nProcesados: {success} éxito(s), {fail} error(es)", file=sys.stderr)
        sys.exit(0 if fail == 0 else 1)

    # Modo archivo único
    if args.input:
        input_file = Path(args.input)
        if not input_file.is_file():
            print(f"Error: '{input_file}' no es un archivo.", file=sys.stderr)
            sys.exit(1)

        if args.output:
            output_path = Path(args.output)
        else:
            output_path = input_file.with_suffix(".rasi")

        # Convertir explicitamente al directorio padre
        if convert_json_to_rasi(input_file, output_path.parent):
            # Si el nombre generado por defecto difiere del solicitado, renombrar
            default_out = input_file.with_suffix(".rasi")
            if output_path.name != default_out.name:
                default_out.rename(output_path)
            sys.exit(0)
        else:
            sys.exit(1)

    # Modo stdin
    if sys.stdin.isatty():
        print("Error: se espera entrada desde archivo, directorio (--dir) o stdin.", file=sys.stderr)
        parser.print_help()
        sys.exit(1)

    try:
        data = json.load(sys.stdin)
    except Exception as e:
        print(f"Error al leer JSON de stdin: {e}", file=sys.stderr)
        sys.exit(1)

    palette = data.get("palette")
    if not palette:
        print("Error: el JSON no contiene la clave 'palette'.", file=sys.stderr)
        sys.exit(1)

    missing = set(ROFI_BASE16_MAP.values()) - set(palette.keys())
    if missing:
        print(f"Error: faltan las claves en la paleta: {', '.join(missing)}", file=sys.stderr)
        sys.exit(1)

    out_file = args.output if args.output else "theme.rasi"
    lines = ["* {"]
    for rofi_var, base_key in ROFI_BASE16_MAP.items():
        hex_color = palette[base_key].lstrip("#")
        lines.append(f"    {rofi_var}:       #{hex_color};")
    lines.append("    background-color: transparent;")
    lines.append("    text-color:       @fg;")
    lines.append("}")

    try:
        with open(out_file, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")
        print(f"Archivo '{out_file}' generado correctamente.")
    except Exception as e:
        print(f"Error al escribir {out_file}: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
