# NixOS-specific Home Manager configuration
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.ags.homeManagerModules.default
    ../shared # Cross-platform config
  ];

  home.username = "woolw";
  home.homeDirectory = "/home/woolw";
  home.stateVersion = "25.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  programs.ssh = {
    enableDefaultConfig = false;
    settings."git.woolw.dev" = {
      IdentityFile = "~/.ssh/nixos_ed25519";
      IdentitiesOnly = true;
      Port = 2222;
    };
  };

  programs.git.settings.user.signingkey = "~/.ssh/nixos_ed25519.pub";

  home.activation.updateAllowedSigners = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.config/git
    if [ -f ~/.ssh/nixos_ed25519.pub ]; then
      echo "git@woolw.dev $(cat ~/.ssh/nixos_ed25519.pub)" > ~/.config/git/allowed_signers
    fi
  '';

  # AGS (Aylur's GTK Shell) for custom shell widgets - Linux only
  programs.ags = {
    enable = true;
    configDir = null; # We'll symlink manually
    extraPackages = with inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}; [
      apps
      battery
      bluetooth
      hyprland
      mpris
      network
      notifd
      tray
      wireplumber
    ];
  };

  home.file."Pictures/Screenshots/.keep".text = "";

  home.pointerCursor = {
    name = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
    gtk.enable = true;
  };

  # Linux-specific config symlinks
  xdg.configFile = {
    # AGS config directory
    "ags".source = ../../ags;

    # Hyprland ecosystem configs
    "hypr".source = ../../hypr;
    "swaync".source = ../../swaync;
    "fuzzel".source = ../../fuzzel;
  };

  # GTK dark theme
  gtk = {
    enable = true;
    gtk4.theme = null;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      size = 24;
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = "Noto Sans";
      size = 10;
      package = pkgs.noto-fonts;
    };
    gtk2.extraConfig = ''
      gtk-enable-animations=1
      gtk-primary-button-warps-slider=1
      gtk-toolbar-style=3
      gtk-menu-images=1
      gtk-button-images=1
      gtk-cursor-blink-time=1000
      gtk-cursor-blink=1
      gtk-sound-theme-name="ocean"
    '';
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-button-images = true;
      gtk-cursor-blink = true;
      gtk-cursor-blink-time = 1000;
      gtk-decoration-layout = "icon:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-menu-images = true;
      gtk-primary-button-warps-slider = true;
      gtk-sound-theme-name = "ocean";
      gtk-toolbar-style = 3;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-cursor-blink = true;
      gtk-cursor-blink-time = 1000;
      gtk-decoration-layout = "icon:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-primary-button-warps-slider = true;
      gtk-sound-theme-name = "ocean";
    };
    gtk4.extraCss = "@import 'colors.css';";
  };
  gtk.gtk2.force = true;

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt6;
    };
  };

  # NixOS-specific packages
  home.packages = with pkgs; [
    odin
    ols
    mangayomi
    qmk
    qt6Packages.qt6ct
    adwaita-qt6
    # Build tools for nvim plugins (telescope-fzf-native)
    gcc
    gnumake
    # Rust toolchain (mason needs cargo/rustc to build some LSP servers)
    cargo
    rustc
  ];
}
