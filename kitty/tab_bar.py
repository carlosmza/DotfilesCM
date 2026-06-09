import json
import os
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, TabBarData, ExtraData, as_rgb

JSON_PATH = os.path.expanduser("~/.config/system-themes/themes/current.json")

def hex_to_kitty_color(hex_str: str) -> int:
    hex_str = hex_str.lstrip('#')
    return as_rgb(int(hex_str, 16))

def load_palette():
    default_palette = {
        "active_bg": as_rgb(0x66b0ef),
        "active_fg": as_rgb(0x23262b),
        "inactive_bg": as_rgb(0x303337),
        "inactive_fg": as_rgb(0xbab9b6),
    }

    if not os.path.exists(JSON_PATH):
        return default_palette

    try:
        with open(JSON_PATH, "r") as f:
            data = json.load(f)
            palette = data.get("palette", {})
            return {
                "active_bg": hex_to_kitty_color(palette.get("base00")),
                "active_fg": hex_to_kitty_color(palette.get("base0E")),
                "inactive_bg": hex_to_kitty_color(palette.get("base00")),
                "inactive_fg": hex_to_kitty_color(palette.get("base03")),
            }
    except Exception:
        return default_palette

# Cargamos la paleta una sola vez al inicializar el script para evitar I/O lento en cada renderizado
COLORS = load_palette()

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
    activity = "●" if tab.has_activity_since_last_focus else " "
    tab_text = f" {index} {activity} {tab.title} "

    # Guardar los colores originales del cursor para no romper el resto de la barra
    orig_fg = screen.cursor.fg
    orig_bg = screen.cursor.bg

    if tab.is_active:
        # Aplicamos colores de pestaña activa basándonos en tu JSON (base0D y base00)
        screen.cursor.bg = COLORS["active_bg"]
        screen.cursor.fg = COLORS["active_fg"]
        screen.draw(tab_text)
    else:
        # Aplicamos colores de pestaña inactiva (base01 y base05)
        screen.cursor.bg = COLORS["inactive_bg"]
        screen.cursor.fg = COLORS["inactive_fg"]
        screen.draw(tab_text)

    # Restaurar los colores por defecto del renderizador de Kitty
    screen.cursor.fg = orig_fg
    screen.cursor.bg = orig_bg

    return screen.cursor.x
