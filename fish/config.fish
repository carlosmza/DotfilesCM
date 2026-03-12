# if status is-interactive
# # Commands to run in interactive sessions can go here
# end
source ~/.config/theme/env
~/.local/bin/oh-my-posh init fish --config '~/.config/oh-my-posh/current.json' | source
zoxide init fish | source
set -gx EDITOR nvim
