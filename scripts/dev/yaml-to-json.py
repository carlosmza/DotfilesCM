#!/usr/bin/env python3
"""
Convierte un archivo YAML a JSON.
Uso:
    ./yaml2json.py entrada.yaml
    ./yaml2json.py entrada.yaml -o salida.json
    cat entrada.yaml | ./yaml2json.py
    cat entrada.yaml | ./yaml2json.py -o salida.json
"""

import sys
import json
import argparse

try:
    import yaml
except ImportError:
    print("Error: PyYAML no está instalado. Instálalo con: pip install PyYAML", file=sys.stderr)
    sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Convierte YAML a JSON.")
    parser.add_argument("input", nargs="?", help="Archivo YAML (si se omite, lee de stdin)")
    parser.add_argument("-o", "--output", help="Archivo JSON de salida (si se omite, imprime en stdout)")
    parser.add_argument("--indent", type=int, default=2, help="Indentación del JSON (por defecto: 2)")
    parser.add_argument("--compact", action="store_true", help="JSON sin espacios ni saltos de línea")
    args = parser.parse_args()

    # Leer YAML
    try:
        if args.input:
            with open(args.input, "r", encoding="utf-8") as f:
                data = yaml.safe_load(f)
        else:
            if sys.stdin.isatty():
                print("Error: se espera entrada desde archivo o stdin.", file=sys.stderr)
                sys.exit(1)
            data = yaml.safe_load(sys.stdin)
    except Exception as e:
        print(f"Error al leer YAML: {e}", file=sys.stderr)
        sys.exit(1)

    if data is None:
        print("Aviso: el YAML está vacío o solo contiene comentarios.", file=sys.stderr)
        data = {}

    # Convertir a JSON
    indent = None if args.compact else args.indent
    json_str = json.dumps(data, indent=indent, ensure_ascii=False)

    # Escribir salida
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(json_str)
            f.write("\n")  # nueva línea final
        print(f"JSON guardado en '{args.output}'", file=sys.stderr)
    else:
        print(json_str)

if __name__ == "__main__":
    main()
