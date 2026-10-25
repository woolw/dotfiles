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
    gamescope
  ];

  # GameMode
  programs.gamemode.enable = true;

  # Don't throttle processes that do split locks. With the default (1) the
  # kernel deliberately stalls the offending thread on every bus lock as a
  # penalty — Steam/Proton games trip this constantly (journal showed
  # thousands of traps), causing hitches/freezes. SteamOS ships 0 as well.
  boot.kernel.sysctl."kernel.split_lock_mitigate" = 0;
}
