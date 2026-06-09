# if status is-interactive
# # Commands to run in interactive sessions can go here
# end
# export QML2_IMPORT_PATH="$HOME/.config/quickshell/config"
# source ~/.config/system-themes/env
~/.local/bin/oh-my-posh init fish --config '~/.config/oh-my-posh/current.json' | source
zoxide init fish | source
set -gx EDITOR nvim

# opencode
fish_add_path /home/carlosm/.opencode/bin
if status is-interactive
    if not set -q ZELLIJ
        if test "$TERM" = "foot"
            exec zellij
        end
    end
end
# Inicializar Atuin para el historial interactivo
atuin init fish | source
# Reemplazos de ls con eza (con colores e iconos)
alias ls="eza --color=always --icons=always --group-directories-first"
alias la="eza --color=always --icons=always --group-directories-first -a --long --header --git"
alias tree="eza --color=always --icons=always --group-directories-first --tree"
alias y="yazi"

function reload_prompt --on-signal USR1
    source (oh-my-posh init fish \
        --config ~/.config/oh-my-posh/current.json | psub)

    commandline -f repaint
end
