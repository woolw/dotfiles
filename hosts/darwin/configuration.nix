{ pkgs, inputs, ... }:

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
      extraFlags = [ "--force" ];
    };
    casks = [
      "brave-browser"
      "claude-code"
      "element"
      "font-jetbrains-mono-nerd-font"
      "gimp"
      "hot"
      "iina"
      "protonvpn"
      "signal"
      "steam"
      "syncplay"
      "tailscale-app"
      "xppen-pentablet"
      "zed"
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
    inputs.ani-cli-woolw.packages.aarch64-darwin.default
    inputs.syncplay-rs.packages.aarch64-darwin.default
    curl
    wget
    htop
    btop
    fastfetch
    jq
    python3
  ];

  users.users.woolw = {
    name = "woolw";
    home = "/Users/woolw";
  };
}
