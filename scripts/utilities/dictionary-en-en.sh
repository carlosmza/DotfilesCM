#!/usr/bin/env bash
# # Uso: dict <palabra>
#
WORD="$(wl-paste -p 2>/dev/null | tr '\n' ' ' | head -n 1)"

# sdcv sin -c para evitar escape codes ANSI en la notificación
# OUTPUT=$(sdcv -e "$WORD" 2>&1)
OUTPUT=$(sdcv -n -u "quick_english-spanish" "$WORD" | sed -n '5p')

notify-send -a "dictionary" "$WORD" "$OUTPUT"
# word=$(wl-paste -p 2>/dev/null | tr '\n' ' ' | head -c 50)
#
# definition=$(sdcv -n "$word" | head -n 20)
#
# notify-send "$word" "$definition"
#
