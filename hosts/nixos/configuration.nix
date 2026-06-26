{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  boot.kernelModules = [ "rtw89_8852ce" ];

  # Locale
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ];

  # Display
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.extraConfig = {
      # Prevent DP/HDMI audio nodes from being suspended when idle.
      # Without this, the audio device disappears after a period of silence
      # and doesn't always recover when the DP connection renegotiates.
      "10-dp-audio-no-suspend" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = "~alsa_output.pci-*.hdmi.*"; } ];
            actions.update-props = {
              "session.suspend-timeout-seconds" = 0;
              "node.pause-on-idle" = false;
            };
          }
        ];
      };
    };
  };

  # Printing
  services.printing.enable = true;

  # User
  users.users.woolw = {
    isNormalUser = true;
    description = "woolw";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "plugdev"
    ];
    shell = pkgs.zsh;
  };

  # macOS-style Super+key → Ctrl+key for copy/paste/etc.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          leftmeta = "layer(super)";
          rightmeta = "layer(super)";
        };
        # :M hint passes all unmapped Super+key combos through to Hyprland unchanged
        "super:M" = {
          a = "C-a";
          c = "C-c";
          r = "C-r";
          s = "C-s";
          t = "C-t";
          v = "C-v";
          w = "C-w";
          x = "C-x";
          z = "C-z";
          "shift+z" = "C-S-z";
        };
      };
    };
  };

  # Tailscale
  services.tailscale.enable = true;

  # Gnome Keyring — provides libsecret backend for Electron/Chromium apps
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Flatpak
  services.flatpak.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.enable = true;
  environment.sessionVariables.XDG_DATA_DIRS = lib.mkAfter [
    "/var/lib/flatpak/exports/share"
    "/home/woolw/.local/share/flatpak/exports/share"
  ];

  # Programs
  programs.git.enable = true;
  programs.zsh.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable nix-ld for running dynamically linked binaries (Mason LSPs)
  programs.nix-ld.enable = true;

  # QMK keyboard firmware flashing
  hardware.keyboard.qmk.enable = true;

  # XPPen tablet (Deco Pro LW Gen 2)
  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Browsers & Communication
    (pkgs.symlinkJoin {
      name = "brave";
      paths = [ pkgs.brave ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/brave \
          --add-flags "--password-store=gnome-libsecret"
      '';
    })
    discord
    (pkgs.symlinkJoin {
      name = "element-desktop";
      paths = [ pkgs.element-desktop ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/element-desktop \
          --add-flags "--password-store=gnome-libsecret"
      '';
    })
    signal-desktop

    # Development & Editors
    wezterm
    vscodium
    claude-code

    # Media
    ani-cli
    mpv
    syncplay
    python313Packages.pyside6

    qt6.qtwayland

    # Utilities
    wget
    curl
    htop
    btop
    fastfetch
    jq
    ripgrep
    fuzzel # for clipboard history picker
    cliphist
  ];

  # Disable USB mouse wakeup — mouse movement was waking the system from sleep
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{product}=="Razer Cobra Pro", ATTR{power/wakeup}="disabled"
  '';

  # Re-enable Hyprland displays after resume.
  # Without this, turning off the monitor before/during sleep causes Hyprland to
  # lose its output and enter a recovery session on resume.
  powerManagement.resumeCommands = ''
    sleep 2
    uid=$(id -u woolw)
    for sig in /tmp/hypr/*/; do
      [ -d "$sig" ] || continue
      name=''${sig%/}
      name=''${name##*/}
      XDG_RUNTIME_DIR=/run/user/$uid \
      HYPRLAND_INSTANCE_SIGNATURE=$name \
      ${pkgs.hyprland}/bin/hyprctl dispatch dpms on 2>/dev/null || true
    done
  '';

  # Write DRAM speed to a world-readable file so AGS can display it without root
  systemd.services.dmi-memspeed = {
    description = "Export DRAM speed from DMI to /run/dmi-memspeed";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      speed=$(${pkgs.dmidecode}/bin/dmidecode -t 17 2>/dev/null \
        | grep -m1 "Configured Memory Speed:" \
        | grep -oP '\d+(?= MT/s)' || true)
      if [ -z "$speed" ]; then
        speed=$(${pkgs.dmidecode}/bin/dmidecode -t 17 2>/dev/null \
          | grep -m1 "Speed:" \
          | grep -oP '\d+(?= MT/s)' || true)
      fi
      echo -n "''${speed:-0}" > /run/dmi-memspeed
      chmod 644 /run/dmi-memspeed
    '';
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
}
