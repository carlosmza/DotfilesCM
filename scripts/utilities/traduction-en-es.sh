#!/bin/bash

text=$(wl-paste -p 2>/dev/null | tr '\n' ' ' | head -n 5)
if [ -z "$text" ]; then
    notify-send "Translator" "No text selected"
    exit
fi

translation=$(argos-translate --from-lang en --to-lang es "$text")

notify-send -a "translate" "$text" "$translation"
