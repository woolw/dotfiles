{
    description = "woolw's Darwin system flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        nix-darwin.url = "github:LnL7/nix-darwin";
        nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
	nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    };

    outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
    let configuration = { pkgs, config, ... }: {

        environment.systemPackages = [
            pkgs.mkalias
            pkgs.neovim
            pkgs.tmux
            pkgs.ripgrep
        ];

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        services.nix-daemon.enable = true;
        nix.settings.experimental-features = "nix-command flakes";
        programs.zsh.enable = true;  # default shell on catalina
        system.configurationRevision = self.rev or self.dirtyRev or null;
        nixpkgs.hostPlatform = "aarch64-darwin";

        security.pam.enableSudoTouchIdAuth = true;
        system.defaults = {
            dock.autohide = true;
            dock.mru-spaces = false;
            finder.AppleShowAllExtensions = true;
            finder.FXPreferredViewStyle = "clmv";
            loginwindow.GuestEnabled  = false;
            NSGlobalDomain.AppleICUForce24HourTime = true;
            NSGlobalDomain.AppleInterfaceStyle = "Dark";
            screencapture.location = "~/Pictures/screenshots";
            screensaver.askForPasswordDelay = 10;
        };

        homebrew = {
            enable = true;
            brews = [
                "yt-dlp"
                "zoxide"
                "fzf"
                "stow"
                "odin"
            ];
            casks = [
                "brave-browser"
                "discord"
                "hot"
                "iina"
                "syncplay"
                "steam"
                "zed"
                "protonvpn"
                "wezterm"
		"zen-browser"
		"spotify"
            ];
            masApps = {
            };
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
        };

        fonts.packages = [
            (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];

        system.activationScripts.applications.text = let
            env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = "/Applications";
            };
        in
            pkgs.lib.mkForce ''
                # Set up applications.
                echo "setting up /Applications..." >&2
                rm -rf /Applications/Nix\ Apps
                mkdir -p /Applications/Nix\ Apps
                find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
                while read src; do
                app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
                done
            '';
    };
    in
    {
        # Build darwin flake using:
        # $ darwin-rebuild switch --flake ~/.dotfiles/nix-darwin#mba
        darwinConfigurations."mba" = nix-darwin.lib.darwinSystem {
            modules = [
           	    configuration
    	        nix-homebrew.darwinModules.nix-homebrew
                {
          		    nix-homebrew = {
          		        enable = true;
             			enableRosetta = true;
             			user = "woolw";
             			autoMigrate = true;
      		        };
                }
            ];
        };

        # Expose the package set, including overlays, for convenience.
        darwinPackages = self.darwinConfigurations."mba".pkgs;
    };
}
