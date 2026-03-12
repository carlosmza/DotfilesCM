#!/bin/bash
cliphist list | rofi -dmenu -theme ~/.config/rofi/layouts/list-compact.rasi | cliphist decode | wl-copy
