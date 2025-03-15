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
    wofi
    xdg-desktop-portal-wlr-git
    grim
    slurp
    swappy
    thunar
    steam
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
    waybar
    swaybg
    mako
    wezterm
    brave-bin
    discord
)

if [ ! -f /sbin/paru ]; then
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    paru -Syu --noconfirm
    cd ..
fi

for SOFTWR in ${install_stage[@]}; do
    paru -S --noconfirm --needed $SOFTWR
done

sudo systemctl enable --now bluetooth.service
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting

######PROTON GE####################################################################################################################################################################

# make temp working directory
echo "Creating temporary working directory..."
rm -rf /tmp/proton-ge-custom
mkdir /tmp/proton-ge-custom
cd /tmp/proton-ge-custom

# download tarball
echo "Fetching tarball URL..."
tarball_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)
tarball_name=$(basename $tarball_url)
echo "Downloading tarball: $tarball_name..."
curl -# -L $tarball_url -o $tarball_name 2>&1

# download checksum
echo "Fetching checksum URL..."
checksum_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)
checksum_name=$(basename $checksum_url)
echo "Downloading checksum: $checksum_name..."
curl -# -L $checksum_url -o $checksum_name 2>&1

# check tarball with checksum
echo "Verifying tarball $tarball_name with checksum $checksum_name..."
sha512sum -c $checksum_name
# if result is ok, continue

# make steam directory if it does not exist
echo "Creating Steam directory if it does not exist..."
mkdir -p ~/.steam/root/compatibilitytools.d

# extract proton tarball to steam directory
echo "Extracting $tarball_name to Steam directory..."
tar -xf $tarball_name -C ~/.steam/root/compatibilitytools.d/
echo "All done :)"

###################################################################################################################################################################################

#stow configs
