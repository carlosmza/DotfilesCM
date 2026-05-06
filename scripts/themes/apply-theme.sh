#!/usr/bin/env bash

THEME="$1"
[[ -z "$THEME" ]] && exit 1
echo "$THEME"

MODE=$(jq -r .variant $HOME/.config/system-themes/themes/"$THEME".json)
HYPR_THEME_DIR="$HOME/.config/hypr/themes/"
ROFI_THEME_DIR="$HOME/.config/rofi/themes/"
GENERAL_THEME_DIR="$HOME/.config/system-themes/themes/"
QUICKSHELL_THEME_DIR="$HOME/.config/quickshell/config/theme/"
# POSH_THEME="$HOME/.config/oh-my-posh/$THEME.json"
# KITTY_THEME="$HOME/.config/kitty/themes/$THEME.conf"
# WALLPAPER="$HOME/Pictures/Wallpapers/$THEME.jpg"
# __________ GENERAL __________
echo "Modify GENERAL_THEME_DIR"
ln -sf "$GENERAL_THEME_DIR""$THEME".json "$GENERAL_THEME_DIR"current.json

# __________ HYPRLAND __________
echo "Modify HYPR_THEME"
ln -sf "$HYPR_THEME_DIR""$THEME".conf "$HYPR_THEME_DIR"current.conf

# __________ ROFI __________
echo "Modify ROFI_THEME"
ln -sf "$ROFI_THEME_DIR""$THEME".rasi "$ROFI_THEME_DIR"theme-ln.rasi

# __________	QUICKSHELL __________
echo "Modify QUICKSHELL"
ln -sf "$GENERAL_THEME_DIR"current.json "$QUICKSHELL_THEME_DIR"current.json
quickshell ipc call colores recargar

# # __________ DARK/LIGHT MODE __________
if [[ $MODE =~ dark ]]; then
	echo "Dark Mode"
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
else
	echo "Light Mode"
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
fi

# Esto ya es manejado por otro script
# Wallpaper
# if [[ -f "$WALLPAPER" ]]; then
#     swww img "$WALLPAPER" $PRESET
# fi


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
