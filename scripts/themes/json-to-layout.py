#!/usr/bin/env python3

import json
import argparse
import sys
import re
from pathlib import Path

COLOR_MAP = {
    # Modes
    "mode_normal": "base0d",
    "mode_locked": "base08",
    "mode_pane": "base0b",
    "mode_tab": "base0c",
    "mode_scroll": "base09",
    "mode_enter_search": "base0a",
    "mode_search": "base0e",
    "mode_resize": "base08",
    "mode_rename_tab": "base0f",
    "mode_move": "base09",
    "mode_rename_pane": "base0f",
    "mode_session": "base0c",
    "mode_prompt": "base0a",

    # Tabs
    "tab_normal": "base04",
    "tab_active": "base0d",
    "tab_rename": "base08",

    # Misc
    "border_format": "base03",
    "command_git_branch_format": "base0d",
}

NOTIFICATION_FG = "base0d"
NOTIFICATION_BG = "base00"
TAB_RENAME_BG = "base00"

FG_PATTERN = r'fg=#([a-fA-F0-9]{6})'
BG_PATTERN = r'bg=#([a-fA-F0-9]{6})'


def load_palette(json_path):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    palette = data.get("palette")

    if palette is None:
        raise ValueError(
            "No se encontró la clave 'palette' en el JSON."
        )

    palette = {k.lower(): v.lstrip("#") for k, v in palette.items()}

    for i in range(16):
        key = f"base{i:02x}"
        if key not in palette:
            raise ValueError(
                f"Falta el color {key} en la paleta."
            )

    return palette


def replace_fg(line, color):
    return re.sub(
        FG_PATTERN,
        f"fg=#{color}",
        line,
        count=1
    )


def replace_bg(line, color):
    return re.sub(
        BG_PATTERN,
        f"bg=#{color}",
        line,
        count=1
    )


def process_line(line, palette):
    stripped = line.strip()

    # Notifications
    if stripped.startswith("notification_format"):
        line = replace_fg(
            line,
            palette[NOTIFICATION_FG]
        )

        line = replace_bg(
            line,
            palette[NOTIFICATION_BG]
        )

        return line

    # Tab rename requiere fg y bg
    if stripped.startswith("tab_rename"):
        line = replace_fg(
            line,
            palette[COLOR_MAP["tab_rename"]]
        )

        line = replace_bg(
            line,
            palette[TAB_RENAME_BG]
        )

        return line

    # Todas las demás reglas
    for key, base_key in COLOR_MAP.items():
        if re.match(rf"^{re.escape(key)}\b", stripped):
            return replace_fg(
                line,
                palette[base_key]
            )

    return line


def generate_layout(palette, template_path):
    template_path = Path(template_path)

    if not template_path.exists():
        raise FileNotFoundError(
            f"No existe la plantilla: {template_path}"
        )

    template = template_path.read_text(
        encoding="utf-8"
    )

    if not template.strip():
        raise ValueError(
            f"La plantilla '{template_path}' está vacía."
        )

    result = []

    for line in template.splitlines():
        result.append(
            process_line(line, palette)
        )

    return "\n".join(result) + "\n"


def main():
    parser = argparse.ArgumentParser(
        description="Genera current.kdl usando una paleta Base16."
    )

    parser.add_argument(
        "input",
        help="Archivo JSON con la paleta Base16."
    )

    parser.add_argument(
        "--template",
        default=str(
            Path.home()
            / ".config/zellij/layouts/template.kdl"
        ),
        help="Plantilla KDL."
    )

    parser.add_argument(
        "--output",
        "-o",
        default=str(
            Path.home()
            / ".config/zellij/layouts/current.kdl"
        ),
        help="Archivo KDL generado."
    )

    args = parser.parse_args()

    try:
        palette = load_palette(args.input)

        kdl_content = generate_layout(
            palette,
            args.template
        )

        Path(args.output).write_text(
            kdl_content,
            encoding="utf-8"
        )

        print(
            f"✓ Layout generado correctamente: {args.output}"
        )

    except Exception as e:
        print(
            f"Error: {e}",
            file=sys.stderr
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
