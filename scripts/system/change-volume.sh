#!/usr/bin/env bash
old_vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | \
  awk -F'/' '{print $2}' | awk '{print $1}' | tr -d '%')
[ -n "$old_vol" ] && echo "$old_vol" > /tmp/volume_osd_level

stdbuf -oL pactl subscribe 2>/dev/null | \
while read -r line; do
  case "$line" in
    # Cambio de volumen en el sink principal → solo si varió
    *"change"*"sink "*)
      vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | \
        awk -F'/' '{print $2}' | awk '{print $1}' | tr -d '%')
      if [ -n "$vol" ] && [ "$vol" != "$old_vol" ]; then
        echo "$vol" > /tmp/volume_osd_level
        old_vol="$vol"
      fi
    ;;
    # Inicio/fin de reproducción → siempre muestra popup
    *"new"*"sink-input"*|*"remove"*"sink-input"*)
      vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | \
        awk -F'/' '{print $2}' | awk '{print $1}' | tr -d '%')
      if [ -n "$vol" ]; then
        echo "$vol" > /tmp/volume_osd_level
        old_vol="$vol"
      fi
    ;;
  esac
done
