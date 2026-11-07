#!/usr/bin/env python3
"""Toggle Yazi theme by writing the selected flavour into theme.toml."""

import sys
import os

YAZI_THEME = os.path.expanduser("~/.config/yazi/theme.toml")

LIGHT_FLAVOURS: frozenset[str] = frozenset({
    "gruvbox-light",
    "rose-pine-dawn",
    "catppuccin-latte",
})

FLAVOUR_MAP: dict[str, str] = {
    # "Nombre del tema en system-themes": "flavour de Yazi"
    "catppuccin-latte":     "catppuccin-latte",
    "catppuccin-macchiato": "catppuccin-macchiato",
    "gruvbox-dark-hard":    "gruvbox-dark",
    "gruvbox-light":        "gruvbox-light",
    "lain":                 "lain",
    "rose-pine-dawn":       "rose-pine-dawn",
    "tokyo-night":          "tokyo-night",
}

PREFIX_RULES: list[tuple[str, str]] = [
    ("gruvbox-dark", "gruvbox-dark"),
    ("gruvbox-light", "gruvbox-light"),
]


def resolve_flavour(key: str) -> str | None:
    flavour = FLAVOUR_MAP.get(key)
    if flavour:
        return flavour
    for prefix, target in PREFIX_RULES:
        if key.startswith(prefix):
            return target
    return None


def main() -> None:
    available = ", ".join(sorted(FLAVOUR_MAP))

    if len(sys.argv) < 2:
        print(f"Uso: {sys.argv[0]} <tema>", file=sys.stderr)
        print(f"Temas disponibles: {available}", file=sys.stderr)
        sys.exit(1)

    key = sys.argv[1].lower()
    flavour = resolve_flavour(key)

    if flavour is None:
        print(f"Error: tema '{sys.argv[1]}' no reconocido.", file=sys.stderr)
        print(f"Temas disponibles: {available}", file=sys.stderr)
        sys.exit(1)

    mode = "light" if flavour in LIGHT_FLAVOURS else "dark"
    content = f"[flavor]\n{mode} = \"{flavour}\"\n"

    with open(YAZI_THEME, "w") as f:
        f.write(content)

    print(f"✓ Tema Yazi cambiado a: {flavour} ({mode})")


if __name__ == "__main__":
    main()
