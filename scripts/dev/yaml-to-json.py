#!/usr/bin/env python3
"""
Convierte archivos YAML a JSON.
Modos de uso:
  1. Archivo único:           ./script.py archivo.yaml
  2. Directorio:              ./script.py --dir directorio/
  3. Desde stdin:             cat archivo.yaml | ./script.py
  4. Especificar salida:      ./script.py archivo.yaml -o salida.json
  5. Directorio con carpeta de salida distinta:
                              ./script.py --dir entrada/ --output-dir salida/
"""

import sys
import json
import argparse
from pathlib import Path

try:
    import yaml
except ImportError:
    print("Error: PyYAML no está instalado. Instálalo con: pip install PyYAML", file=sys.stderr)
    sys.exit(1)


def convert_file(yaml_path: Path, output_dir: Path = None, indent: int = None, compact: bool = False):
    """
    Lee un archivo YAML y lo convierte a JSON.
    Si output_dir es None, se guarda en el mismo directorio del YAML con extensión .json.
    """
    try:
        with open(yaml_path, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
    except Exception as e:
        print(f"Error al leer {yaml_path}: {e}", file=sys.stderr)
        return False

    if data is None:
        print(f"Aviso: {yaml_path} está vacío o solo tiene comentarios.", file=sys.stderr)
        data = {}

    # Construir ruta de salida
    if output_dir:
        output_path = output_dir / (yaml_path.stem + ".json")
    else:
        output_path = yaml_path.with_suffix(".json")

    # Asegurar que el directorio de salida exista
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Escribir JSON
    json_indent = None if compact else indent if indent else 2
    try:
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=json_indent, ensure_ascii=False)
            f.write("\n")  # nueva línea final
    except Exception as e:
        print(f"Error al escribir {output_path}: {e}", file=sys.stderr)
        return False

    print(f"✓ {yaml_path.name} → {output_path.name}", file=sys.stderr)
    return True


def main():
    parser = argparse.ArgumentParser(description="Convierte YAML a JSON (archivo único o directorio).")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("input", nargs="?", help="Archivo YAML de entrada (si se omite y no se usa --dir, lee de stdin)")
    group.add_argument("--dir", "-d", type=str, help="Directorio con archivos YAML para convertir en lote")

    parser.add_argument("-o", "--output", help="Archivo JSON de salida (solo con archivo único)")
    parser.add_argument("--output-dir", help="Directorio de salida para los JSON (solo con --dir)")
    parser.add_argument("--indent", type=int, default=2, help="Indentación del JSON (por defecto: 2)")
    parser.add_argument("--compact", action="store_true", help="JSON sin espacios ni saltos de línea")
    parser.add_argument("--recursive", action="store_true", help="(con --dir) Procesar subdirectorios recursivamente")
    args = parser.parse_args()

    indent = args.indent
    compact = args.compact

    # Caso 1: Modo directorio
    if args.dir:
        input_dir = Path(args.dir)
        if not input_dir.is_dir():
            print(f"Error: '{input_dir}' no es un directorio válido.", file=sys.stderr)
            sys.exit(1)

        # Patrón de búsqueda (yaml y yml)
        pattern = "**/*.yaml" if args.recursive else "*.yaml"
        yaml_files = list(input_dir.glob(pattern))
        # Agregar también .yml si no se encontraron o para no discriminar
        yml_pattern = "**/*.yml" if args.recursive else "*.yml"
        yaml_files.extend(input_dir.glob(yml_pattern))

        # Eliminar duplicados (por si acaso)
        yaml_files = list(set(yaml_files))

        if not yaml_files:
            print(f"No se encontraron archivos .yaml/.yml en '{input_dir}'.", file=sys.stderr)
            sys.exit(0)

        output_dir = Path(args.output_dir) if args.output_dir else None
        if output_dir:
            output_dir.mkdir(parents=True, exist_ok=True)

        success = 0
        fail = 0
        for yf in yaml_files:
            if convert_file(yf, output_dir, indent, compact):
                success += 1
            else:
                fail += 1

        print(f"\nProcesados: {success} éxito(s), {fail} error(es)", file=sys.stderr)
        sys.exit(0 if fail == 0 else 1)

    # Caso 2: Archivo único
    if args.input:
        input_file = Path(args.input)
        if not input_file.is_file():
            print(f"Error: '{input_file}' no es un archivo.", file=sys.stderr)
            sys.exit(1)

        if args.output:
            output_path = Path(args.output)
        else:
            output_path = input_file.with_suffix(".json")

        if convert_file(input_file, output_path.parent, indent, compact):  # Pasamos el directorio padre como output_dir
            sys.exit(0)
        else:
            sys.exit(1)

    # Caso 3: stdin
    if sys.stdin.isatty():
        print("Error: se espera entrada desde archivo, directorio (--dir) o stdin.", file=sys.stderr)
        parser.print_help()
        sys.exit(1)

    try:
        data = yaml.safe_load(sys.stdin)
    except Exception as e:
        print(f"Error al leer YAML de stdin: {e}", file=sys.stderr)
        sys.exit(1)

    if data is None:
        data = {}

    json_indent = None if compact else indent
    json_str = json.dumps(data, indent=json_indent, ensure_ascii=False)
    print(json_str)


if __name__ == "__main__":
    main()
