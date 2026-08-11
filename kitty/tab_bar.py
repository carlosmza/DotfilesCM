import json
import os
from kitty.fast_data_types import Screen, Color
from kitty.tab_bar import (
    DrawData, TabBarData, ExtraData,
    draw_title, as_rgb,
)
from kitty.utils import color_as_int

JSON_PATH = os.path.expanduser("~/.config/system-themes/themes/current.json")


def hex_to_color(hex_str: str) -> Color:
    hex_str = hex_str.lstrip('#')
    return Color(
        int(hex_str[0:2], 16),
        int(hex_str[2:4], 16),
        int(hex_str[4:6], 16),
    )


def load_palette():
    default = {
        "active_bg": Color(0x66, 0xb0, 0xef),
        "active_fg": Color(0x23, 0x26, 0x2b),
        "inactive_bg": Color(0x30, 0x33, 0x37),
        "inactive_fg": Color(0xba, 0xb9, 0xb6),
        "default_bg": Color(0x1e, 0x1e, 0x2e),
    }
    try:
        with open(JSON_PATH) as f:
            p = json.load(f).get("palette", {})
            return {
                "active_bg": hex_to_color(p.get("base0A", "#66b0ef")),
                "active_fg": hex_to_color(p.get("base00", "#23262b")),
                "inactive_bg": hex_to_color(p.get("base01", "#303337")),
                # "inactive_fg": hex_to_color(p.get("base05", "#bab9b6")),
                "inactive_fg": hex_to_color(p.get("base00", "#23262b")),
                "default_bg": hex_to_color(p.get("base00", "#1e1e2e")),
            }
    except Exception:
        return default


COLORS = load_palette()

MAX_TAB_WIDTH = 28
GAP = 1


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    if tab.is_active:
        bg = as_rgb(color_as_int(COLORS["active_bg"]))
        fg = as_rgb(color_as_int(COLORS["active_fg"]))
    else:
        bg = as_rgb(color_as_int(COLORS["inactive_bg"]))
        fg = as_rgb(color_as_int(COLORS["inactive_fg"]))

    effective_width = min(max_title_length, MAX_TAB_WIDTH)

    screen.cursor.bg = bg
    screen.cursor.fg = fg

    screen.draw(' ')

    title_max = max(0, effective_width - 2)
    draw_title(draw_data, screen, tab, index, title_max)

    extra = screen.cursor.x - before - effective_width
    if extra > 0:
        screen.cursor.x -= extra + 1
        screen.draw('…')

    while screen.cursor.x < before + effective_width:
        screen.draw(' ')

    default_bg = as_rgb(color_as_int(COLORS["default_bg"]))
    screen.cursor.bg = default_bg
    screen.draw(' ' * GAP)

    return screen.cursor.x
