{ pkgs, ... }:

{
  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  # Gaming utilities
  environment.systemPackages = with pkgs; [
    protonup-qt # GUI tool to manage Proton-GE installations
    mangohud
    gamemode
    gamescope
  ];

  # GameMode
  programs.gamemode.enable = true;
}
