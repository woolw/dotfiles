{ config, pkgs, ... }:

{
  home.username = "woolw";
  home.homeDirectory = "/home/woolw";
  home.stateVersion = "25.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "woolw";
      user.email = "gh@woolw.dev";
      init.defaultBranch = "main";
      pull.rebase = false;
      # SSH signing
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/github_ed25519.pub";
      commit.gpgsign = true;
      # Additional git settings
      fetch.prune = true;
      core.longpaths = true;
      core.ignorecase = false;
      core.autocrlf = false;
      core.eol = "lf";
    };
  };

  # SSH configuration
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/github_ed25519";
        identitiesOnly = true;
      };
    };
  };

  # Zsh configuration (using pure zshrc from dotfiles)
  programs.zsh = {
    enable = true;
    # Don't let Home Manager manage zshrc - we use our own
    initContent = ''
      # Source our cross-platform zshrc
      if [ -f ~/dotfiles/zsh/zshrc ]; then
        source ~/dotfiles/zsh/zshrc
      fi
    '';
  };

  # WezTerm configuration (pure Lua config)
  xdg.configFile."wezterm/wezterm.lua".source = ../../wezterm/wezterm.lua;

  # Helix configuration (pure TOML configs)
  xdg.configFile."helix".source = ../../helix;

  # Hyprland ecosystem configs
  xdg.configFile."hypr".source = ../../hypr;
  xdg.configFile."waybar".source = ../../waybar;
  xdg.configFile."swaync".source = ../../swaync;
  xdg.configFile."fuzzel".source = ../../fuzzel;

  # Additional home packages
  home.packages = with pkgs; [
    mangayomi
  ];
}
