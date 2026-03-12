#!/bin/bash

# Usamos prefijos para evitar colisiones con comandos reales
op_shutdown="  Apagar"
op_reboot="  Reiniciar"
op_lock="  Bloquear"
op_suspend="  Suspender"

options="$op_suspend\n$op_shutdown\n$op_reboot\n$op_lock"

# Ejecutamos rofi asegurándonos de que no herede problemas de foco
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Sistema:" -theme ~/.config/rofi/menus/power-menu.rasi)

# Si el usuario presiona ESC o cierra rofi sin elegir, salimos del script inmediatamente
if [[ -z "$chosen" ]]; then
    exit 0
fi

case "$chosen" in
    "$op_shutdown") /usr/bin/shutdown now ;;
    "$op_reboot") /usr/bin/reboot ;;
    "$op_lock") hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit ;;
    "$op_suspend") /usr/bin/systemctl suspend ;;
esac
