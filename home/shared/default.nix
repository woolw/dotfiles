# Cross-platform Home Manager configuration
# Shared between NixOS and nix-darwin
{ pkgs, ... }:

{
  # Git configuration
  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;
    settings = {
      user.name = "woolw";
      user.email = "git@woolw.dev";
      init.defaultBranch = "main";
      pull.rebase = false;
      # SSH signing
      gpg.format = "ssh";
      commit.gpgsign = true;
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
      # Additional git settings
      fetch.prune = true;
      core.longpaths = true;
      core.ignorecase = false;
      core.autocrlf = false;
      core.eol = "lf";
    };
  };

  # SSH configuration (settings set per device in machine-specific home files)
  programs.ssh.enable = true;

  # Both nixpkgs and HM track unstable; version numbers diverge cosmetically
  home.enableNixpkgsReleaseCheck = false;

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

    # mpv configuration
    "mpv/mpv.conf".source = ../../mpv/mpv.conf;
  };

  # Cross-platform packages
  home.packages = with pkgs; [
    # Neovim and dependencies
    neovim
    ripgrep # for telescope live_grep
    fd # for telescope find_files
    nodejs # mason installs TS/JS LSPs via npm
    unzip # mason extracts server archives (ols/omnisharp)
    lazygit # git TUI
  ];
}
