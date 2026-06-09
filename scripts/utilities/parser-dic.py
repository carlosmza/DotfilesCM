#!/usr/bin/env python3
import sys
import argparse

def parse_sdcv_output(text: str, dict_name: str) -> str:
    """Limpia la salida según el diccionario indicado."""
    lines = text.splitlines()
    clean_lines = []

    if dict_name == "collins":
        for line in lines:
            # Eliminar los separadores "* * *"
            if line.strip() == "* * *":
                continue
            # Si la línea contiene "\-->", extraer solo el texto después del último "\-->"
            if "\\-->" in line:
                line = line.split("\\-->")[-1]
            clean_lines.append(line)
        return "\n".join(clean_lines)

    if dict_name == "english-spanish":
        line_main = ""
        for i, line in enumerate(lines):
            if i == 0:
                continue
            if "-->" in line:
                line = line.split("-->")[-1]

            clean_lines.append(line)
        return "\n".join(clean_lines)

    else:
        return "Return 1"
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Limpia la salida de sdcv + html2text para diferentes diccionarios."
    )
    parser.add_argument(
        "--diccionario",
        choices=["english-spanish", "collins", "wordnet", "oxford-advanced"],
        default="collins",
        help="Nombre del diccionario usado (determina las reglas de limpieza)."
    )
    args = parser.parse_args()

    input_text = sys.stdin.read()
    parsed = parse_sdcv_output(input_text, args.diccionario)
    print(parsed, end="")
