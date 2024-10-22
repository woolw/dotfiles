{
    description = "woolw's Darwin system flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        nix-darwin.url = "github:LnL7/nix-darwin";
        nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = inputs@{ self, nix-darwin, nixpkgs }:
    let configuration = { pkgs, ... }: {

        environment.systemPackages = [
            pkgs.vim
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
            screencapture.location = "~/Pictures/screenshots";
            screensaver.askForPasswordDelay = 10;
        };

        # Homebrew needs to be installed on its own!
        homebrew.enable = true;
        homebrew.casks = [
            "alacritty"
            "brave-browser"
            "firefox"
            "discord"
            "hot"
            "iina"
            "syncplay"
            "steam"
        ];
        homebrew.brews = [
            "git"
            "yt-dlp"
            "neovim"
        ];
    };
    in
    {
        # Build darwin flake using:
        # $ darwin-rebuild build --flake .#simple
        darwinConfigurations."mba" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
        };

        # Expose the package set, including overlays, for convenience.
        darwinPackages = self.darwinConfigurations."mba".pkgs;
    };
}
