zstyle ':completion:*' completer _complete _ignored
zstyle :compinstall filename '/home/woolw/.zshrc'

autoload -Uz compinit
compinit

HISTFILE=~/.zsh/.zsh-history
HISTSIZE=1000000
SAVEHIST=1000000

setopt beep nomatch notify
unsetopt autocd extendedglob
bindkey -v

# Aliases
alias zshrc='nvim ~/.zshrc'
alias zpr='nvim ~/.zprofile'
alias l='exa -lahF --color=always --icons --sort=size --group-directories-first'
alias ls='ls -lahF --color=always'
alias c='clear'
alias hst='history 1 -1 | cut -c 8- | sort | uniq | fzf | wl-copy'
alias gst='git status'
alias gm='git commit -S'
alias ga='git add .'
alias gma='git commit -aS'
alias gp='git push'
alias gpull='git pull --all'

# Load on startup
_startup() {
  # Beam shape cursor
  echo -ne '\e[5 q'
  # Print an empty line on each new prompt
  echo ""
}

precmd_functions+=(_startup)

# Source plugins
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh