#!/usr/bin/env bash

# Archivo temporal para guardar el estado de los workspaces
OPCIONES="󰍺  Extender\n  Duplicar"
LAYOUT="$HOME/.config/rofi/menus/power-menu.rasi"
ELEGIDO=$(echo -e "$OPCIONES" | rofi -dmenu -p "Monitors:" -theme "$LAYOUT")


case "$ELEGIDO" in
    "󰍺  Extender")
        # Rompemos el mirror previo si existía y posicionamos los monitores
        hyprctl eval "hl.monitor({ output = 'eDP-1',    mode = '1920x1080@60',  position = '0x0',    scale = '1', mirror = '' })"
        hyprctl eval "hl.monitor({ output = 'HDMI-A-1', mode = '1920x1080@100', position = '1920x0', scale = '1', mirror = '' })"
        hyprctl dispatch moveworkspacetomonitor "1 eDP-1"
        hyprctl dispatch moveworkspacetomonitor "2 HDMI-A-1"
        ;;
    "  Duplicar")
        hyprctl eval "hl.monitor({ output = 'eDP-1',    mode = '1920x1080@60', position = '0x0', scale = '1' })"
        hyprctl eval "hl.monitor({ output = 'HDMI-A-1', mode = '0', position = '0x0', mirror = 'eDP-1' })"
        ;;
esac
