#!/usr/bin/env python3
import sys
import argparse
import re

DICT_NAMES = {
    "English - Spanish",
    "WordNet",
    "dictd_www.dict.org_gcide",
    "quick_english-spanish",
    "Collins Cobuild 5",
    "Oxford Advanced Learner's Dictionary",
    "Free On-Line Dictionary of Computing",
}


def parse_sdcv_output(text: str, _dict_name: str = "") -> str:
    lines = text.splitlines()
    result = []

    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue

        # Collins: skip * * * separators
        if stripped == "* * *":
            continue

        # Remove "Found N items..." prefix (may share the line with content)
        found_match = re.match(
            r'^(Found \d+ items?,?\s+similar to[^.]*\.)\s*', stripped
        )
        if found_match:
            rest = stripped[found_match.end():]
            if not rest:
                continue
            stripped = rest

        # Unify \--> and --> separators into \-->
        normalized = re.sub(r'\\?-->', '\\-->', stripped)

        if "\\-->" in normalized:
            parts = normalized.split("\\-->")
            kept = []
            for part in parts:
                p = part.strip()
                if not p or p in DICT_NAMES:
                    continue
                kept.append(p)
            if not kept:
                continue
            line = " ".join(kept)
        else:
            line = stripped

        line = re.sub(r'\s+(\d+(?::\s*|\s+))', r'\n\1', line)
        result.append(line)

    return "\n".join(result).strip()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Limpia la salida de sdcv + html2text para diferentes diccionarios."
    )
    parser.add_argument(
        "--diccionario",
        choices=sorted(DICT_NAMES),
        default="Collins Cobuild 5",
        help="Nombre del diccionario usado (determina las reglas de limpieza).",
    )
    args = parser.parse_args()

    input_text = sys.stdin.read()
    parsed = parse_sdcv_output(input_text, args.diccionario)
    print(parsed, end="")
