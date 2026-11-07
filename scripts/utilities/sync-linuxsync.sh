#!/usr/bin/env bash

set -euo pipefail

notify-send "LinuxSync" "Initiating synchronization..."

if /usr/bin/rclone bisync \
    "$HOME/LinuxSync" \
    "carlos-drive:LinuxSync" \
    --check-access \
    --verbose
then
    notify-send "LinuxSync" "✓ complete synchronization"
else
    notify-send -u critical "LinuxSync" "✗ Error synchronization"
    exit 1
fi
