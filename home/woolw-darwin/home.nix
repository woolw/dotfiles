{
  pkgs,
  lib,
  fenix,
  ...
}:

{
  imports = [ ../shared ];

  home.username = "woolw";
  home.homeDirectory = "/Users/woolw";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.ssh = {
    enableDefaultConfig = false;
    settings."git.woolw.dev" = {
      IdentityFile = "~/.ssh/darwin_ed25519";
      IdentitiesOnly = true;
      Port = 2222;
    };
  };

  programs.git.settings.user.signingkey = "~/.ssh/darwin_ed25519.pub";

  home.activation.updateAllowedSigners = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.config/git
    if [ -f ~/.ssh/darwin_ed25519.pub ]; then
      echo "git@woolw.dev $(cat ~/.ssh/darwin_ed25519.pub)" > ~/.config/git/allowed_signers
    fi
  '';

  # Build tools for Neovim plugins (telescope-fzf-native needs C compiler)
  home.packages = with pkgs; [
    gcc
    gnumake
    fenix.packages.${pkgs.stdenv.hostPlatform.system}.stable.toolchain
  ];

  # Wallpapers symlink
  home.file."Pictures/Wallpapers".source = ../../wallpapers;
}
