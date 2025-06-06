#!/bin/bash

# Helper to run commands silently
run_silent() {
    "$@" >/dev/null
}

DOTFILES_DIR="$HOME/dotfiles"

# Update system
echo "🌟 Updating system first..."
run_silent sudo pacman -Syu --noconfirm

# Install paru if missing
if ! command -v paru &>/dev/null; then
    echo "🚀 Installing paru (AUR helper)..."
    run_silent sudo pacman -S --noconfirm --needed paru
fi

# Install packages
echo "📦 Installing repo and AUR packages..."
run_silent paru -S --noconfirm --needed \
    rustup \
    steam \
    ani-cli \
    mpv \
    ttf-jetbrains-mono-nerd \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-cjk \
    vulkan-radeon \
    lib32-vulkan-radeon \
    fastfetch \
    wezterm \
    discord \
    neovim \
    base-devel \
    wget \
    unzip \
    nodejs \
    npm \
    yarn \
    go \
    dotnet-sdk \
    aspnet-runtime \
    dotnet-runtime \
    syncplay \
    pyside6 \
    brave-bin \
    mako \
    waybar \
    fuzzel \
    grim \
    slurp \
    wl-clipboard \
    udiskie \
    blueman \
    network-manager-applet \
    netcoredbg \
    shfmt \
    shellcheck \
    bash-language-server \
    thunar \
    pamixer \
    wlr-randr \
    krita \
    inotify-tools \
    cliphist \
    greetd-regreet \
    hyprland \
    hyprlock \
    hyprshot \
    hyprpaper \
    hyprcursor \
    fish

# Refresh font cache
run_silent fc-cache -fv

# Set up development environments
echo "💻 Setting up development environments..."

run_silent rustup default stable

# Install global Node.js packages
echo "📦 Installing global Node.js packages..."
run_silent sudo npm install -g \
    typescript \
    ts-node \
    eslint \
    prettier \
    vite

# Link dotfiles
echo "🔗 Setting up dotfiles..."

mkdir -p ~/.config

rm -rf ~/.config/fastfetch
ln -s "$DOTFILES_DIR/fastfetch" ~/.config/fastfetch

rm -f ~/.wezterm.lua
ln -s "$DOTFILES_DIR/wezterm/wezterm.lua" ~/.wezterm.lua

mkdir -p ~/.config/fish
rm -f ~/.config/fish/config.fish
ln -s "$DOTFILES_DIR/fish/config.fish" ~/.config/fish/config.fish

rm -rf ~/.config/nvim
ln -s "$DOTFILES_DIR/nvim" ~/.config/nvim

rm -rf ~/.config/waybar
ln -s "$DOTFILES_DIR/waybar" ~/.config/waybar

rm -rf ~/.config/hypr
ln -s "$DOTFILES_DIR/hypr" ~/.config/hypr

rm -rf ~/.config/fuzzel
ln -s "$DOTFILES_DIR/fuzzel" ~/.config/fuzzel

rm -rf ~/.config/mako
ln -s "$DOTFILES_DIR/mako" ~/.config/mako

echo "🛡️ Dotfiles linked successfully."

# Proton GE setup

echo "🎮 Do you want to install Proton-GE? (y/n)"
read -r install_proton_ge

if [[ "$install_proton_ge" == "y" || "$install_proton_ge" == "Y" ]]; then
    echo "🚀 Setting up Proton-GE..."

    WORKDIR="/tmp/proton-ge-custom"
    STEAM_COMPAT_DIR="$HOME/.steam/root/Steam/compatibilitytools.d"

    # Clean temp working directory
    echo "🧹 Cleaning temporary working directory..."
    rm -rf "$WORKDIR"
    mkdir -p "$WORKDIR"

    # Fetch tarball and checksum URLs
    echo "🔗 Fetching Proton-GE release info..."
    tarball_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep '.tar.gz')
    checksum_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep '.sha512sum')

    tarball_name=$(basename "$tarball_url")
    checksum_name=$(basename "$checksum_url")

    # Download tarball and checksum
    echo "⬇️ Downloading Proton-GE tarball..."
    run_silent curl -L "$tarball_url" -o "$WORKDIR/$tarball_name"

    echo "⬇️ Downloading checksum..."
    run_silent curl -L "$checksum_url" -o "$WORKDIR/$checksum_name"

    # Verify checksum
    echo "🛡️ Verifying Proton-GE tarball integrity..."
    cd "$WORKDIR"
    sha512sum -c "$checksum_name"

    # Prepare Steam compatibilitytools.d folder
    echo "📂 Ensuring Steam compatibility tools directory exists..."
    mkdir -p "$STEAM_COMPAT_DIR"

    # Extract Proton-GE
    echo "📦 Extracting Proton-GE to Steam directory..."
    tar -xf "$tarball_name" -C "$STEAM_COMPAT_DIR"

    # Cleanup temp directory
    echo "🧹 Cleaning up temporary files..."
    rm -rf "$WORKDIR"

    echo "✅ Proton-GE installation completed successfully!"

elif [[ "$install_proton_ge" == "n" || "$install_proton_ge" == "N" ]]; then
    echo "⚡ Skipping Proton-GE installation."
else
    echo "❗ Invalid input. Please enter 'y' or 'n'."
    exit 1
fi

# GitHub SSH setup
echo "💬 Do you want to setup GitHub SSH? (y/n)"
read -r user_input
if [[ "$user_input" == "n" || "$user_input" == "N" ]]; then
    echo "Skipping GitHub SSH setup."
elif [[ "$user_input" == "y" || "$user_input" == "Y" ]]; then
    echo "Continuing with GitHub SSH setup..."

    echo "📧 Please enter your GitHub username:"
    read -r user_name

    echo "📧 Please enter your GitHub email:"
    read -r user_email

    git config --global user.name "$user_name"
    git config --global user.email "$user_email"

    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -C "$user_email" -f ~/.ssh/github_ed25519

    PUBKEY=$(cat ~/.ssh/github_ed25519.pub)
    TITLE=$(hostname)

    echo "🔐 Please enter your GitHub personal access token (with admin:public_key scope):"
    read -r TOKEN

    RESPONSE=$(curl -s -H "Authorization: token ${TOKEN}" \
        -X POST --data-binary "{\"title\":\"${TITLE}\",\"key\":\"${PUBKEY}\"}" \
        https://api.github.com/user/keys)

    echo "✅ Public SSH key deployed to GitHub."

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/github_ed25519

    echo "✅ SSH key added to agent."

    echo "🛡️ Setting up Git auto-signing with SSH key..."
    git config --global gpg.format ssh
    git config --global user.signingkey ~/.ssh/github_ed25519.pub
    git config --global commit.gpgsign true

    ssh -T git@github.com
else
    echo "❌ Invalid input. Please enter 'y' or 'n'."
    exit 1
fi

echo "🎉 All setup complete! Enjoy your new machine! 🎉"
