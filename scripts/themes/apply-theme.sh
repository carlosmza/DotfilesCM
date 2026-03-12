#!/usr/bin/env bash
PRESETS_FILE="$HOME/.config/swww/swww-presets.conf"
# ─── Elegir preset aleatorio ──────────────────────────────────────────────────
# Filtra líneas vacías y comentarios (líneas que empiezan con #)
# PRESET=$(grep -v '^\s*#' "$PRESETS_FILE" | grep -v '^\s*$' | shuf -n 1)
PRESET=$(grep -v '^\s*#' "$PRESETS_FILE" | sed '/^\s*$/d' | shuf -n1)

if [[ -z "$PRESET" ]]; then
    echo "Error: no se pudo leer ningún preset del archivo" >&2
    exit 1
fi

# recibe 1 solo argumento
THEME="$1"
[ -z "$THEME" ] && exit 1

# asignacion del argumento a un var
export THEME_COLOR="$THEME"
echo "export THEME_COLOR=$THEME" > /home/carlosm/.config/theme/env

if [ "$THEME" = "dark" ]; then
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  swww img "/home/carlosm/Pictures/Wallpapers/jinx-arcane-sit-dark.jpg" $PRESET
	ln -sf ~/.config/rofi/themes/dark.rasi ~/.config/rofi/themes/theme.rasi
	KITTY_THEME="$HOME/.config/kitty/themes/dark.conf"
	  ln -sf ~/.config/oh-my-posh/dark.json ~/.config/oh-my-posh/current.json
else
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  swww img "/home/carlosm/Pictures/Wallpapers/berserker-light.png" $PRESET
	ln -sf ~/.config/rofi/themes/light.rasi ~/.config/rofi/themes/theme.rasi
	KITTY_THEME="$HOME/.config/kitty/themes/light.conf"
	  ln -sf ~/.config/oh-my-posh/light.json ~/.config/oh-my-posh/current.json
fi

ln -sf "$KITTY_THEME" ~/.config/kitty/themes/current.conf
kitty @ set-colors -a "$KITTY_THEME"
exec fish
# nvim --server "$NVIM_LISTEN_ADDRESS" --remote-send "<cmd>colorscheme $NVIM_THEME<CR>" 2>/dev/null
