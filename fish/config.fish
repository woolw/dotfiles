alias ll='ls -lah'

set -gx EDITOR nvim

if test -d "$HOME/.cargo/bin"
    set -gx PATH $HOME/.cargo/bin $PATH
end
if test -d "$HOME/go/bin"
    set -gx PATH $HOME/go/bin $PATH
end

set -q SSH_AUTH_SOCK; or eval (ssh-agent -c)
ssh-add -l | grep -q (ssh-keygen -lf ~/.ssh/github_ed25519 | awk '{print $2}') 
or ssh-add ~/.ssh/github_ed25519

if type -q fastfetch
    fastfetch
end
