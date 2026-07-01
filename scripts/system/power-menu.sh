#!/bin/bash

# Usamos prefijos para evitar colisiones con comandos reales
op_shutdown="  Poweroff"
op_reboot="  Reboot"
op_lock="  Locked"
op_suspend="  Suspend"

options="$op_suspend\n$op_shutdown\n$op_reboot\n$op_lock"

# Ejecutamos rofi asegurándonos de que no herede problemas de foco
LAYOUT="$HOME/.config/rofi/menus/power-menu.rasi"
chosen=$(echo -e "$options" | rofi -dmenu -p "System:" -theme "$LAYOUT")

# Si el usuario presiona ESC o cierra rofi sin elegir, salimos del script inmediatamente
if [[ -z "$chosen" ]]; then
    exit 0
fi

case "$chosen" in
    "$op_shutdown") /usr/bin/shutdown now ;;
    "$op_reboot") /usr/bin/reboot ;;
    "$op_lock") hyprlock;;
    "$op_suspend") /usr/bin/systemctl suspend ;;
		# "op_lock") /home/carlosm/noqs.sh ;;
esac
