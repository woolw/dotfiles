{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # Hyprland compositor
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG Portal for Hyprland (KDE provides its own portal too)
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # KWallet auto-unlock on login (works for both KDE and Hyprland)
  security.pam.services.sddm.kwallet.enable = true;
  security.pam.services.login.kwallet.enable = true;

  # Hyprland-specific packages
  environment.systemPackages = with pkgs; [
    # Hyprland ecosystem
    hyprlock # Screen locker
    hyprpaper # Wallpaper daemon

    # Window manager essentials
    swaynotificationcenter # Notifications with history management

    # Clipboard (Wayland-native)
    wl-clipboard # wl-copy/wl-paste commands
    cliphist # Clipboard history manager

    # Screenshots (Wayland-native)
    hyprshot # Screenshot tool for Hyprland

    # Standalone tray applets (for Hyprland, KDE has integrated versions)
    networkmanagerapplet # nm-applet
    blueman # blueman-applet
  ];
}
