# NixOS-specific Home Manager configuration
{
  config,
  pkgs,
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

  # NixOS-specific: Disable enableDefaultConfig (not available on darwin)
  programs.ssh.enableDefaultConfig = false;

  # AGS (Aylur's GTK Shell) for custom shell widgets - Linux only
  programs.ags = {
    enable = true;
    configDir = null; # We'll symlink manually
    extraPackages = with inputs.ags.packages.${pkgs.system}; [
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

  # Linux-specific config symlinks
  xdg.configFile = {
    # AGS config directory
    "ags".source = ../../ags;

    # Hyprland ecosystem configs
    "hypr".source = ../../hypr;
    "swaync".source = ../../swaync;
  };

  # GTK dark theme (Linux/KDE specific)
  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
    cursorTheme = {
      name = "breeze_cursors";
      size = 24;
      package = pkgs.kdePackages.breeze;
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

  # Qt uses KDE platform for proper integration with kdeglobals
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "breeze";
  };

  # NixOS-specific packages
  home.packages = with pkgs; [
    mangayomi
    # Build tools for nvim plugins (telescope-fzf-native)
    gcc
    gnumake
  ];
}
