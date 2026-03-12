#!/bin/bash

text=$(wl-paste -p 2>/dev/null | tr '\n' ' ' | head -c 100)
if [ -z "$text" ]; then
    notify-send "Translator" "No text selected"
    exit
fi

translation=$(argos-translate --from-lang en --to-lang es "$text")

notify-send "$text" "$translation"
