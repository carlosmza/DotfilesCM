# if status is-interactive
# # Commands to run in interactive sessions can go here
# end
# export QML2_IMPORT_PATH="$HOME/.config/quickshell/config"
# source ~/.config/system-themes/env
~/.local/bin/oh-my-posh init fish --config '~/.config/oh-my-posh/current.json' | source
zoxide init fish | source
set -gx EDITOR nvim
