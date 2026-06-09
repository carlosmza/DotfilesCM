#!/usr/bin/env python3

import json
import sys
from pathlib import Path


def load_base16_theme(path: str) -> dict:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def build_omp_theme(base16: dict) -> dict:
    palette = base16["palette"]
    prompt_color = palette["base0D"]

    return {
        "$schema": (
            "https://raw.githubusercontent.com/"
            "JanDeDobbeleer/oh-my-posh/main/themes/schema.json"
        ),
        "version": 3,
        "final_space": True,
        "blocks": [
            {
                "type": "prompt",
                "alignment": "left",
                "segments": [
                    {
                        "type": "path",
                        "style": "plain",
                        "foreground": palette["base05"],
                        "properties": {
                            "style": "folder"
                        }
                    },
                    {
                        "type": "text",
                        "style": "plain",
                        "foreground": palette["base0D"],
                        "template": "❯"
                    }
                ]
            }
        ]
    }


def main():
    if len(sys.argv) != 3:
        print(
            f"Uso: {Path(sys.argv[0]).name} "
            "<tema-base16.json> <omp-theme.json>"
        )
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    theme = load_base16_theme(input_file)
    omp_theme = build_omp_theme(theme)

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(omp_theme, f, indent=2)

    print(f"Tema generado: {output_file}")


if __name__ == "__main__":
    main()
