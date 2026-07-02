# NixOS-specific Home Manager configuration
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ../shared # Cross-platform config
  ];

  home.username = "woolw";
  home.homeDirectory = "/home/woolw";
  home.stateVersion = "25.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  programs.ssh = {
    enableDefaultConfig = false;
    settings."git.woolw.dev" = {
      IdentityFile = "~/.ssh/nixos_ed25519";
      IdentitiesOnly = true;
      Port = 2222;
    };
  };

  programs.git.settings.user.signingkey = "~/.ssh/nixos_ed25519.pub";

  home.activation.updateAllowedSigners = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.config/git
    if [ -f ~/.ssh/nixos_ed25519.pub ]; then
      echo "git@woolw.dev $(cat ~/.ssh/nixos_ed25519.pub)" > ~/.config/git/allowed_signers
    fi
  '';

  # KDE's icon loader (KIconLoader) persists a disk cache of resolved icon
  # theme + name lookups. Icon overrides under ~/.local/share/icons dropped
  # by home.file won't be picked up by already-cached names/themes until
  # this is cleared.
  home.activation.clearIconCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f "$HOME/.cache/icon-cache.kcache"
  '';

  home.file."Pictures/Screenshots/.keep".text = "";

  home.pointerCursor = {
    name = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
    gtk.enable = true;
  };

  # GTK dark theme
  gtk = {
    enable = true;
    gtk4.theme = null;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      size = 24;
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = "Noto Sans";
      size = 10;
      package = pkgs.noto-fonts;
    };
    gtk2.extraConfig = ''
      gtk-enable-animations=1
      gtk-primary-button-warps-slider=1
      gtk-toolbar-style=3
      gtk-menu-images=1
      gtk-button-images=1
      gtk-cursor-blink-time=1000
      gtk-cursor-blink=1
      gtk-sound-theme-name="ocean"
    '';
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-button-images = true;
      gtk-cursor-blink = true;
      gtk-cursor-blink-time = 1000;
      gtk-decoration-layout = "icon:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-menu-images = true;
      gtk-primary-button-warps-slider = true;
      gtk-sound-theme-name = "ocean";
      gtk-toolbar-style = 3;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-cursor-blink = true;
      gtk-cursor-blink-time = 1000;
      gtk-decoration-layout = "icon:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-primary-button-warps-slider = true;
      gtk-sound-theme-name = "ocean";
    };
    gtk4.extraCss = "@import 'colors.css';";
  };
  gtk.gtk2.force = true;

  programs.plasma = {
    enable = true;
    workspace = {
      colorScheme = "BreezeDark";
      iconTheme = "breeze-dark";
      wallpaper = ../../wallpapers/od_nixos.png;
      wallpaperFillMode = "preserveAspectCrop";
    };

    # Separate from both the SDDM greeter theme and the desktop wallpaper —
    # this is what shows on the lock screen after inactivity/sleep/resume,
    # and defaults to Breeze's own stock wallpaper unless set explicitly.
    kscreenlocker.appearance.wallpaper = ../../wallpapers/od_nixos.png;

    panels = [
      {
        location = "top";
        height = 44;
        widgets = [
          {
            kickoff.icon = "nix-snowflake-white";
          }
          {
            pager.general = {
              showWindowOutlines = false;
              displayedText = "none";
            };
          }
          {
            iconTasks = {
              launchers = [
                "applications:org.wezfurlong.wezterm.desktop"
                "applications:brave-browser.desktop"
                "applications:steam.desktop"
              ];
            };
          }
          {
            systemMonitor = {
              title = "CPU";
              displayStyle = "org.kde.ksysguard.textonly";
              showTitle = true;
              sensors = [
                {
                  name = "cpu/all/usage";
                  color = "61,174,233";
                  label = "CPU %";
                }
              ];
              # totalSensors/textOnlySensors go through plasma-manager's
              # toEscapedList, which double-escapes quotes (writes literal
              # `\\"` into the ini instead of `"`), leaving the widget with
              # zero parseable sensors. `settings` bypasses that broken path
              # since it isn't pre-escaped, so this is the actual fix, not a
              # duplicate of the above.
              settings.Sensors = {
                highPrioritySensorIds = ''["cpu/all/usage"]'';
                totalSensors = ''["cpu/all/usage"]'';
                lowPrioritySensorIds = ''["cpu/all/averageTemperature", "cpu/all/averageFrequency"]'';
              };
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            systemMonitor = {
              title = "GPU";
              displayStyle = "org.kde.ksysguard.textonly";
              showTitle = true;
              sensors = [
                {
                  name = "gpu/gpu0/usage";
                  color = "209,17,65";
                  label = "GPU %";
                }
              ];
              settings.Sensors = {
                highPrioritySensorIds = ''["gpu/gpu0/usage"]'';
                totalSensors = ''["gpu/gpu0/usage"]'';
                lowPrioritySensorIds = ''["gpu/gpu0/temperature"]'';
              };
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            systemMonitor = {
              title = "RAM";
              displayStyle = "org.kde.ksysguard.textonly";
              showTitle = true;
              sensors = [
                {
                  name = "memory/physical/usedPercent";
                  color = "39,174,96";
                  label = "RAM %";
                }
              ];
              settings.Sensors = {
                highPrioritySensorIds = ''["memory/physical/usedPercent"]'';
                totalSensors = ''["memory/physical/usedPercent"]'';
                lowPrioritySensorIds = ''["memory/physical/used", "memory/physical/total"]'';
              };
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          {
            digitalClock = {
              time.format = "24h";
              date = {
                enable = true;
                position = "besideTime";
                format = "isoDate";
              };
            };
          }
        ];
      }
    ];

    # Keep the desktop empty: point the desktop containment's Folder View at
    # a directory that's never written to instead of the default `desktop:/`
    # (~/Desktop), so no icons ever appear regardless of what lands there.
    startup.desktopScript."empty_desktop" = {
      text = ''
        let allDesktops = desktops();
        for (const d of allDesktops) {
          d.currentConfigGroup = ["General"];
          d.writeConfig("url", "file://${config.home.homeDirectory}/.local/share/empty-desktop");
        }
      '';
      priority = 3;
    };
  };

  home.file.".local/share/empty-desktop/.keep".text = "";

  # KRunner's window icon is looked up by theme name "krunner" (see
  # org.kde.krunner.desktop), resolved via Plasma's active icon theme
  # (breeze-dark, see kdeglobals [Icons] Theme). Overriding it in place
  # requires shadowing that exact theme + relative path, since generic name
  # lookup stops at the first theme in the inheritance chain that has it.
  home.file.".local/share/icons/breeze-dark/preferences/32/krunner.svg".source =
    "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  # NixOS-specific packages
  home.packages = with pkgs; [
    nixos-icons
    odin
    ols
    mangayomi
    qmk
    # Build tools for nvim plugins (telescope-fzf-native)
    gcc
    gnumake
    # Rust toolchain (mason needs cargo/rustc to build some LSP servers)
    cargo
    rustc
  ];
}
