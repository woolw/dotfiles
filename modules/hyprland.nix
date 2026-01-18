{
  config,
  lib,
  pkgs,
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
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Shared keyring for both KDE and Hyprland (for Brave, etc.)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Minimal Hyprland-specific packages
  # Reusing KDE for: screenshots (Spectacle), clipboard (Klipper), audio control
  environment.systemPackages = with pkgs; [
    # Hyprland ecosystem
    hyprlock # Screen locker
    hyprpaper # Wallpaper daemon

    # Window manager essentials
    fuzzel # App launcher (Super+Space)
    waybar # Status bar
    swaynotificationcenter # Notifications with history management

    # Standalone tray applets (for Hyprland, KDE has integrated versions)
    networkmanagerapplet # nm-applet
    blueman # blueman-applet
  ];
}
