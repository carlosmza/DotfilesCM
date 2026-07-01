#!/usr/bin/env bash

# Archivo temporal para guardar el estado de los workspaces
OPCIONES="󰍺  Extender\n  Duplicar"
LAYOUT="$HOME/.config/rofi/menus/power-menu.rasi"
ELEGIDO=$(echo -e "$OPCIONES" | rofi -dmenu -p "Monitors:" -theme "$LAYOUT")


case "$ELEGIDO" in
    "Extender")
        # 1. Rompemos mirror previo si existía
        hyprctl eval "hl.monitor({ output = 'HDMI-A-1', mode = '1920x1080@100', position = '1920x0', scale = '1', mirror = '' })"
        
        # 2. Encendemos y posicionamos los monitores
        hyprctl eval "hl.monitor({ output = 'eDP-1', mode = '1920x1080@60', position = '0x0', scale = '1' })"
        hyprctl eval "hl.monitor({ output = 'HDMI-A-1', mode = '1920x1080@100', position = '1920x0', scale = '1' })"
        
				# Configuración por defecto si no hay un estado previo en /tmp/
				hyprctl eval "hl.workspace_rule({ workspace = '1', monitor = 'eDP-1' })"
				hyprctl eval "hl.workspace_rule({ workspace = '2', monitor = 'HDMI-A-1' })"
				hyprctl dispatch moveworkspacetomonitor "1 eDP-1"
				hyprctl dispatch moveworkspacetomonitor "2 HDMI-A-1"
        
        ;;
        
    "Duplicar")
        save_current_workspaces
        hyprctl eval "hl.monitor({ output = 'eDP-1', mode = '1920x1080@60', position = '0x0', scale = '1' })"
        hyprctl eval "hl.monitor({ output = 'HDMI-A-1', mode = '1920x1080@100', position = '0x0', scale = '1', mirror = 'eDP-1' })"
        
        ;;
esac
