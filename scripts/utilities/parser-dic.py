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
        for line in lines:
            if not line.strip():
                continue
            if "\\-->" in line:
                line = line.split("\\-->")[-1]
            clean_lines.append(line)
        return "\n".join(clean_lines)

    if dict_name == "wordnet":
        return _format_wordnet(text)


def _format_wordnet(text: str) -> str:
    import re

    if "\\-->" in text:
        text = text.split("\\-->")[-1]

    parts = text.split(None, 2)
    if len(parts) >= 3 and parts[0] == parts[1]:
        text = parts[2]

    m = re.match(r"(\w+)\s+(\d+):\s+", text)
    if not m:
        return text
    pos = m.group(1)
    tail = text[m.end():]

    senses = re.split(r"\s+(\d+):\s+", tail)
    buf = []
    word = parts[0]
    pos_pat = re.compile(r"\b(\w+)\s+(v|n|adj|adv|r)\s*$")

    for i in range(0, len(senses), 2):
        body = senses[i]
        num = 1 if i == 0 else int(senses[i - 1])

        pm = pos_pat.search(body)
        if pm:
            body = body[: pm.start()]
            next_pos = pm.group(2)
        else:
            next_pos = None

        examples = re.findall(r'"([^"]*)"', body)
        clean = re.sub(r'\s*"[^"]*"\s*', " ", body)
        clean = re.sub(r"\s*\[[^\]]*\]", "", clean)
        clean = re.sub(r";\s*;", ";", clean)
        clean = re.sub(r"\s+", " ", clean).strip().rstrip("; ")

        buf.append(f"{word} {pos} {num}: {clean}")
        for ex in examples:
            buf.append(f'  "{ex}"')

        if next_pos:
            pos = next_pos

    return "\n".join(buf)

    # oxford-advanced: remove header line and empty lines
    if dict_name == "oxford-advanced":
        return "\n".join(l for l in lines if l.strip())

    # fallback: return as-is
    return "\n".join(lines)
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Limpia la salida de sdcv + html2text para diferentes diccionarios."
    )
    parser.add_argument(
        "--diccionario",
        default="collins",
        help="Nombre del diccionario usado (determina las reglas de limpieza)."
    )
    args = parser.parse_args()

    input_text = sys.stdin.read()
    parsed = parse_sdcv_output(input_text, args.diccionario)
    print(parsed, end="")
