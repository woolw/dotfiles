{ pkgs, inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # shellcheck source build is broken in this nixpkgs rev; stub it out since
  # it's only used by darwin-uninstaller's internal lint step
  nixpkgs.overlays = [
    (final: prev: {
      shellcheck = prev.runCommand "shellcheck-stub" { passthru.compiler.bootstrapAvailable = false; } ''
        mkdir -p $out/bin
        printf '#!/bin/sh\nexit 0\n' > $out/bin/shellcheck
        chmod +x $out/bin/shellcheck
      '';
      shellcheck-minimal = final.shellcheck;
    })
  ];

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
      "maccy"
      "protonvpn"
      "signal"
      "steam"
      "syncplay"
      "tailscale-app"
      "xppen-pentablet"
      "vscodium"
      "wezterm"
    ];
    brews = [
      "mpv"
      "ffmpeg"
      "yt-dlp"
      "aria2"
      "fzf"
      "odin"
      "ols"
    ];
  };

  environment.systemPackages = with pkgs; [
    inputs.ani-cli-woolw.packages.aarch64-darwin.default
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
