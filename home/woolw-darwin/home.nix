{ pkgs, fenix, ... }:

{
  imports = [ ../shared ];

  home.username = "woolw";
  home.homeDirectory = "/Users/woolw";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.ssh = {
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        IdentityFile = "~/.ssh/darwin_ed25519";
        IdentitiesOnly = true;
      };
      "git.woolw.dev" = {
        IdentityFile = "~/.ssh/darwin_ed25519";
        IdentitiesOnly = true;
        Port = 2222;
      };
    };
  };

  programs.git.settings.user.signingkey = "~/.ssh/darwin_ed25519.pub";

  # Build tools for Neovim plugins (telescope-fzf-native needs C compiler)
  home.packages = with pkgs; [
    gcc
    gnumake
    fenix.packages.${pkgs.system}.stable.toolchain
  ];

  # Wallpapers symlink
  home.file."Pictures/Wallpapers".source = ../../wallpapers;
}
