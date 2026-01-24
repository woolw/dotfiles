{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.ags.homeManagerModules.default ];
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

  # AGS (Aylur's GTK Shell) for custom shell widgets
  programs.ags = {
    enable = true;
    configDir = null; # We'll symlink manually
    extraPackages = with inputs.ags.packages.${pkgs.system}; [
      apps
      battery
      hyprland
      mpris
      network
      notifd
      tray
      wireplumber
    ];
  };

  # Symlink AGS config directory
  xdg.configFile."ags".source = ../../ags;

  # WezTerm configuration (pure Lua config)
  xdg.configFile."wezterm/wezterm.lua".source = ../../wezterm/wezterm.lua;

  # Helix configuration (pure TOML configs)
  xdg.configFile."helix".source = ../../helix;

  # Hyprland ecosystem configs
  xdg.configFile."hypr".source = ../../hypr;
  xdg.configFile."swaync".source = ../../swaync;

  # GTK dark theme (preserving existing KDE/Breeze settings)
  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
    cursorTheme = {
      name = "breeze_cursors";
      size = 24;
      package = pkgs.kdePackages.breeze;
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

  # Qt uses KDE platform for proper integration with kdeglobals
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "breeze";
  };

  # Additional home packages
  home.packages = with pkgs; [
    mangayomi
    zed-editor
  ];
}
