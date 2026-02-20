{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  boot.kernelModules = [ "rtw89_8852ce" ];

  # Locale
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ];

  # Display
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # User
  users.users.woolw = {
    isNormalUser = true;
    description = "woolw";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # Flatpak
  services.flatpak.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.enable = true;
  environment.sessionVariables.XDG_DATA_DIRS = lib.mkAfter [
    "/var/lib/flatpak/exports/share"
    "/home/woolw/.local/share/flatpak/exports/share"
  ];

  # Programs
  programs.git.enable = true;
  programs.zsh.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable nix-ld for running dynamically linked binaries (Mason LSPs)
  programs.nix-ld.enable = true;

  # Qt Wayland support
  qt.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Browsers & Communication
    brave
    discord

    # Development & Editors
    wezterm
    vscodium
    claude-code

    # Media
    ani-cli
    mpv
    syncplay
    python313Packages.pyside6

    # Qt Wayland
    libsForQt5.qtwayland
    qt6.qtwayland

    # Utilities
    wget
    curl
    htop
    btop
    fastfetch
    jq
    ripgrep
    fuzzel # for clipboard history picker
    cliphist
  ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
}
