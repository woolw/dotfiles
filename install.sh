#!/bin/sh

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install alacritty arc iina steam syncplay font-jetbrains-mono-nerd-font odin stow git neovim firefox zoxide

stow alacritty &
stow zsh &
