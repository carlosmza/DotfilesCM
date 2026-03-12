# #!/usr/bin/env bash
STATE_FILE="/home/carlosm/.config/theme/current"
LAST_THEME=$(cat "$STATE_FILE" || echo "dark")
/home/carlosm/.config/scripts/apply-theme.sh "$LAST_THEME"
