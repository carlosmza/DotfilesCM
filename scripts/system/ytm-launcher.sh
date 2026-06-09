# ~/.local/bin/toggle-ytm
#!/bin/bash
TERMINAL="/home/carlosm/.config/scripts/system/kitty-launch.sh"
WS="ytm"

hyprctl dispatch togglespecialworkspace "$WS"

# Si después de togglear no hay cliente en special:ytm, lanzar terminal
# sleep 0.2
# if ! hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:'"$WS"'") | .class' | grep -q .; then
#   "$TERMINAL" ytm
# fi
