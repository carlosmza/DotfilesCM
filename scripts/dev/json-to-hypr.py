#!/usr/bin/env python3
"""
Genera archivos theme.conf para Hyprland a partir de archivos JSON con paleta.
Modos de uso:
  1. Archivo único:   ./generate_theme_batch.py esquema.json
  2. Directorio:      ./generate_theme_batch.py --dir ./mis_esquemas/
  3. Desde stdin:     cat esquema.json | ./generate_theme_batch.py
  4. Especificar salida: ./generate_theme_batch.py esquema.json -o tema.conf
  5. Directorio con carpeta de salida: ./generate_theme_batch.py --dir ./json/ --output-dir ./conf/
"""

import sys
import json
import argparse
from pathlib import Path


def convert_json_to_conf(json_path: Path, output_dir: Path = None):
    """
    Lee un JSON, extrae su 'palette' y escribe un archivo .conf.
    Si output_dir es None, guarda en el mismo directorio del JSON con extensión .conf.
    """
    # Leer JSON
    try:
        with open(json_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error al leer {json_path}: {e}", file=sys.stderr)
        return False

    palette = data.get("palette", {})
    if not palette:
        print(f"Error: '{json_path.name}' no contiene la clave 'palette'.", file=sys.stderr)
        return False

    # Ruta de salida
    if output_dir:
        out_path = output_dir / (json_path.stem + ".conf")
    else:
        out_path = json_path.with_suffix(".conf")

    out_path.parent.mkdir(parents=True, exist_ok=True)

    # Escribir .conf
    try:
        with open(out_path, "w", encoding="utf-8") as out:
            for key, value in palette.items():
                # Eliminar el '#' inicial (si existe) y escribir $clave = valor
                hex_color = value[1:] if value.startswith("#") else value
                out.write(f"${key} = {hex_color}\n")
    except Exception as e:
        print(f"Error al escribir {out_path}: {e}", file=sys.stderr)
        return False

    print(f"✓ {json_path.name} → {out_path.name}", file=sys.stderr)
    return True


def main():
    parser = argparse.ArgumentParser(description="Convierte JSON con paleta a theme.conf para Hyprland")
    grupo = parser.add_mutually_exclusive_group()
    grupo.add_argument("input", nargs="?", help="Archivo JSON de entrada (o stdin si se omite, y no se usa --dir)")
    grupo.add_argument("--dir", "-d", type=str, help="Directorio con archivos .json para convertir en lote")

    parser.add_argument("-o", "--output", help="Archivo .conf de salida (solo con archivo único)")
    parser.add_argument("--output-dir", help="Directorio de salida para los .conf (solo con --dir)")
    parser.add_argument("--recursive", action="store_true", help="(con --dir) Procesa subdirectorios recursivamente")
    args = parser.parse_args()

    # ------------------------------------------------------------------
    # Modo directorio
    # ------------------------------------------------------------------
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
            if convert_json_to_conf(jf, output_dir):
                success += 1
            else:
                fail += 1

        print(f"\nProcesados: {success} éxito(s), {fail} error(es)", file=sys.stderr)
        sys.exit(0 if fail == 0 else 1)

    # ------------------------------------------------------------------
    # Modo archivo único
    # ------------------------------------------------------------------
    if args.input:
        input_file = Path(args.input)
        if not input_file.is_file():
            print(f"Error: '{input_file}' no es un archivo.", file=sys.stderr)
            sys.exit(1)

        if args.output:
            output_path = Path(args.output)
        else:
            output_path = input_file.with_suffix(".conf")

        # Pasar el directorio padre como output_dir para respetar la ruta
        if convert_json_to_conf(input_file, output_path.parent):
            # Si el nombre de salida no coincide con input.stem + '.conf', renombramos
            if output_path.name != (input_file.stem + ".conf"):
                # Ya se escribió con el nombre por defecto, lo movemos
                default_out = input_file.with_suffix(".conf")
                if default_out != output_path:
                    default_out.rename(output_path)
            sys.exit(0)
        else:
            sys.exit(1)

    # ------------------------------------------------------------------
    # Modo stdin (entrada estándar)
    # ------------------------------------------------------------------
    if sys.stdin.isatty():
        print("Error: se espera entrada desde archivo, directorio (--dir) o stdin.", file=sys.stderr)
        parser.print_help()
        sys.exit(1)

    try:
        data = json.load(sys.stdin)
    except Exception as e:
        print(f"Error al leer JSON de stdin: {e}", file=sys.stderr)
        sys.exit(1)

    palette = data.get("palette", {})
    if not palette:
        print("Error: el JSON no contiene la clave 'palette'.", file=sys.stderr)
        sys.exit(1)

    # Salida por defecto cuando se usa stdin
    out_file = args.output if args.output else "theme.conf"
    try:
        with open(out_file, "w", encoding="utf-8") as out:
            for key, value in palette.items():
                hex_color = value[1:] if value.startswith("#") else value
                out.write(f"${key} = {hex_color}\n")
        print(f"Archivo '{out_file}' generado correctamente.")
    except Exception as e:
        print(f"Error al escribir {out_file}: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
