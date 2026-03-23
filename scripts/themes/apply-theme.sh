#!/usr/bin/env bash

PRESETS_FILE="$HOME/.config/swww/swww-presets.conf"

PRESET=$(grep -v '^\s*#' "$PRESETS_FILE" | sed '/^\s*$/d' | shuf -n1)

[[ -z "$PRESET" ]] && {
    echo "Error leyendo preset"
    exit 1
}

THEME="$1"
[[ -z "$THEME" ]] && exit 1
echo "$THEME"

export THEME_COLOR="$THEME"
echo "export THEME_COLOR=$THEME" > "$HOME/.config/system-themes/env"

ROFI_THEME="$HOME/.config/rofi/themes/$THEME.rasi"
POSH_THEME="$HOME/.config/oh-my-posh/$THEME.json"
KITTY_THEME="$HOME/.config/kitty/themes/$THEME.conf"
WALLPAPER="$HOME/Pictures/Wallpapers/$THEME.jpg"

# Esto ya es manejado por otro script
# Dark / Light
# if [[ $THEME =~ Dark ]]; then
# 	# echo "Dark Mode"
# 	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
# else
# 	# echo "Light Mode"
# 	gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
# fi

# Esto ya es manejado por otro script
# Wallpaper
# if [[ -f "$WALLPAPER" ]]; then
#     swww img "$WALLPAPER" $PRESET
# fi

# Rofi
if [[ -f "$ROFI_THEME" ]]; then
    ln -sf "$ROFI_THEME" ~/.config/rofi/themes/theme-ln.rasi
fi

# Oh My Posh
# if [[ -f "$POSH_THEME" ]]; then
#     ln -sf "$POSH_THEME" ~/.config/oh-my-posh/current.json
# fi
#
# # Kitty
# if [[ -f "$KITTY_THEME" ]]; then
#     ln -sf "$KITTY_THEME" ~/.config/kitty/themes/theme-ln.conf
# 		# echo "asignando socket"
# 		# SOCKET="unix:@mykitty"
# 		SOCKET="unix:/tmp/kitty.sock"
# 		# echo "socket asignado"
# 		# kitty @ --to "$SOCKET" set-colors -a -c "$THEME_FILE" 2>/dev/null \
# 		# || kitty @ set-colors -a -c "$THEME_FILE"
#     # kitty @ set-colors -a -c ~/.config/kitty/themes/theme-ln.conf
#     kitty @ --to "$SOCKET" set-colors -a -c ~/.config/kitty/themes/theme-ln.conf
# 		# kitty @ --to unix:/tmp/kitty.sock set-colors -a -c ~/.config/kitty/themes/theme-ln.conf
# 		echo "Kitty theme:" "$KITTY_THEME"
# fi

exec fish
