#!/usr/bin/env bash
# .yaml -> .json
$HOME/.config/scripts/dev/yaml-to-json.py --dir $HOME/Downloads/schemesYAML/ --output-dir $HOME/.config/system-themes/themes/

# .json -> .conf
$HOME/.config/scripts/dev/json-to-hypr.py --dir $HOME/.config/system-themes/themes/ --output-dir $HOME/.config/hypr/themes/

# .json -> .rasi
$HOME/.config/scripts/dev/json-to-rasi.py --dir $HOME/.config/system-themes/themes/ --output-dir $HOME/.config/rofi/themes/
