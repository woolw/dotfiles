{ pkgs, fenix, ... }:

{
  imports = [ ../shared ];

  home.username = "woolw";
  home.homeDirectory = "/Users/woolw";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Disable default SSH config generation (we manage it in shared)
  programs.ssh.enableDefaultConfig = false;

  # Build tools for Neovim plugins (telescope-fzf-native needs C compiler)
  home.packages = with pkgs; [
    gcc
    gnumake
    fenix.packages.${pkgs.system}.stable.toolchain
  ];

  # Wallpapers symlink
  home.file."Pictures/Wallpapers".source = ../../wallpapers;
}
