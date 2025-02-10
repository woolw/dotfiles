#!/bin/bash

function noop_exit() {
    echo 'no operations have been implemented for this case'
    exit 0
}

os_name=$(uname)
if [ "$os_name" == "Linux" ]; then
    echo "You are running Linux."
    ./linux.sh

elif [ "$os_name" == "Darwin" ]; then
    echo "You are running macOS."

    curl -L https://nixos.org/nix/install | sh
    nix run nix-darwin --experimental-features "nix-command flakes" -- switch --flake ~/.dotfiles/nix-darwin#mba

elif [ "$os_name" == "CYGWIN"* ] || [ "$os_name" == "MINGW"* ]; then
    echo "You are running Windows (Cygwin or MinGW)."
    noop_exit
else
    echo "Unknown operating system: $os_name."
    noop_exit
fi
