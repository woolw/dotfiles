{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Determinate Nix manages its own daemon — disable nix-darwin's Nix management
  nix.enable = false;

  networking.hostName = "darwin";

  programs.zsh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = "woolw";

  system.stateVersion = 5;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      "com.apple.swipescrolldirection" = true; # natural scroll
    };
    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 48;
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
    };
    casks = [
      "brave-browser"
      "claude-code"
      "discord"
      "element"
      "font-jetbrains-mono-nerd-font"
      "gimp"
      "hot"
      "iina"
      "protonvpn"
      "steam"
      "syncplay"
      "vscodium"
      "wezterm"
    ];
    brews = [
      "mpv"
      "ffmpeg"
      "yt-dlp"
      "aria2"
      "fzf"
    ];
  };

  environment.systemPackages = with pkgs; [
    curl
    wget
    htop
    btop
    jq
    python3
  ];

  users.users.woolw = {
    name = "woolw";
    home = "/Users/woolw";
  };
}
