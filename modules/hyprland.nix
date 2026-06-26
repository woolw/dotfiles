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

  # XDG Portal for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

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

    # Standalone tray applets
    networkmanagerapplet # nm-applet
    blueman # blueman-applet
  ];
}
