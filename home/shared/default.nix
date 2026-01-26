# Cross-platform Home Manager configuration
# Shared between NixOS and nix-darwin
{ pkgs, ... }:

{
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
    initContent = ''
      # Source our cross-platform zshrc
      if [ -f ~/dotfiles/zsh/zshrc ]; then
        source ~/dotfiles/zsh/zshrc
      fi
    '';
  };

  # Cross-platform config symlinks
  xdg.configFile = {
    # WezTerm configuration (pure Lua config)
    "wezterm/wezterm.lua".source = ../../wezterm/wezterm.lua;

    # Neovim configuration (pure Lua config with lazy.nvim)
    "nvim".source = ../../nvim;
  };

  # Cross-platform packages
  home.packages = with pkgs; [
    # Neovim and dependencies
    neovim
    ripgrep # for telescope live_grep
    fd # for telescope find_files
    nodejs # mason installs TS/JS LSPs via npm
    cargo # mason builds some servers (nil_ls) from source
    rustc
    unzip # mason extracts server archives (ols/omnisharp)
    lazygit # git TUI
  ];
}
