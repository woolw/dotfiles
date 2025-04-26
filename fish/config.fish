alias ll='ls -lah'

set -gx EDITOR nvim
if test -d "$HOME/.cargo/bin"
    set -gx PATH $HOME/.cargo/bin $PATH
end
if test -d "$HOME/go/bin"
    set -gx PATH $HOME/go/bin $PATH
end

if type -q fastfetch
    fastfetch
end