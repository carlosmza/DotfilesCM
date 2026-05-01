#!/usr/bin/env python3
"""
Genera un archivo theme.conf para Hyprland a partir de un scheme.json.
Uso:
    ./generate_theme.py scheme.json            # escribe theme.conf en el directorio actual
    ./generate_theme.py scheme.json -o output.conf  # especifica ruta de salida
    cat scheme.json | ./generate_theme.py      # lee desde stdin y escribe theme.conf
    cat scheme.json | ./generate_theme.py -o tema.conf
"""

import sys
import json
import argparse
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description="Convierte scheme.json a theme.conf para Hyprland")
    parser.add_argument("input", nargs="?", help="Archivo scheme.json (o stdin si no se especifica)")
    parser.add_argument("-o", "--output", default="theme.conf", help="Archivo de salida (por defecto: theme.conf)")
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

    # Extraer el diccionario de colores
    colours = data.get("colours", {})
    if not colours:
        print("Error: el JSON no contiene la clave 'colours'.", file=sys.stderr)
        sys.exit(1)

    # Escribir theme.conf
    with open(args.output, "w", encoding="utf-8") as out:
        for key, value in colours.items():
            # Formato: $nombre = valor (sin #, tal cual el hex)
            out.write(f"${key} = {value}\n")

    print(f"Archivo '{args.output}' generado correctamente.")

if __name__ == "__main__":
    main()
