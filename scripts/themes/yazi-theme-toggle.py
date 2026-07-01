#!/usr/bin/env python3
"""Toggle Yazi theme by writing the selected flavour into theme.toml."""

import sys
import os

YAZI_THEME = os.path.expanduser("~/.config/yazi/theme.toml")

LIGHT_FLAVOURS: frozenset[str] = frozenset({
    "gruvbox-light",
    "rose-pine-dawn",
})

FLAVOUR_MAP: dict[str, str] = {
# "Theme name": "flavour name"
    "ashes":               "lain",
    "gruvbox-dark-medium":        "gruvbox-dark",
    "gruvbox-light-soft":  "gruvbox-light",
    "rose-pine-dawn":      "rose-pine-dawn",
    "tokyo-night-dark":    "tokyo-night",
}

def main() -> None:
    if len(sys.argv) < 2:
        print(f"Uso: {sys.argv[0]} <tema>", file=sys.stderr)
        print(f"Temas disponibles: {', '.join(sorted(set(FLAVOUR_MAP.values())))}", file=sys.stderr)
        sys.exit(1)

    key = sys.argv[1].lower()
    flavour = FLAVOUR_MAP.get(key)

    if flavour is None:
        print(f"Error: tema '{sys.argv[1]}' no reconocido.", file=sys.stderr)
        print(f"Temas disponibles: {', '.join(sorted(set(FLAVOUR_MAP.values())))}", file=sys.stderr)
        sys.exit(1)

    mode = "light" if flavour in LIGHT_FLAVOURS else "dark"
    content = f"[flavor]\n{mode} = \"{flavour}\"\n"

    with open(YAZI_THEME, "w") as f:
        f.write(content)

    print(f"✓ Tema Yazi cambiado a: {flavour} ({mode})")


if __name__ == "__main__":
    main()
