#!/bin/sh

install_stage=(
    stow
    qt5-wayland
    qt5ct
    qt6-wayland
    qt6ct
    pipewire
    wireplumber
    wl-clipboard
    cliphist   
    alacritty
    wofi
    xdg-desktop-portal-wlr-git
    grim
    slurp
    swappy
    thunar
    steam
    brave-bin
    ani-cli
    mpv
    pamixer
    pavucontrol
    brightnessctl
    bluez
    bluez-utils
    blueman
    network-manager-applet
    ttf-jetbrains-mono-nerd
    noto-fonts-emoji
    xfce4-settings
    vulkan-radeon
    lib32-vulkan-radeon
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk
    element-desktop
    zsh
    fastfetch
    river
    waybar-git
    swaybg
    mako
)

# function that will test for a package and if not found it will attempt to install it
install_software() {
    yay -S --noconfirm --needed $1
}

if [ ! -f /sbin/yay ]; then  
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    yay -Suy --noconfirm
    cd ..
fi

for SOFTWR in ${install_stage[@]}; do
    install_software $SOFTWR 
done

sudo systemctl enable --now bluetooth.service

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting

stow alacritty &
stow gtk &
stow mako &
stow river &
stow waybar &
stow wofi &
stow xdg-desktop-portal &
stow zsh &

./proton-ge.sh

exit
