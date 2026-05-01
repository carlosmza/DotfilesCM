# ~/.local/bin/argos-client

#!/bin/bash
# Need deamon-argos.py

text=$(wl-paste -p 2>/dev/null | tr '\n' ' ' | head -c 500)

translation=$(echo -n "$text" | nc -N 127.0.0.1 5005)

notify-send -t 10000 -a translate "$text" "$translation"
