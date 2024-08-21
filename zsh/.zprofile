export XDG_CACHE_HOME=${HOME}/.cache/
export XDG_CONFIG_HOME=$HOME/.config/
export XDG_DATA_HOME=${HOME}/.local/share

export GPG_TTY=$(tty)
export GOPROXY=direct
export LESSHISTFILE="-"

export EDITOR=nvim

[[ -d "$HOME/.bin" ]] && PATH="$HOME/.bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && PATH="$HOME/.local/bin:$PATH"
