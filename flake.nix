{
  description = "woolw's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager for user-level configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/nixos/configuration.nix
            ./hosts/nixos/hardware-configuration.nix
            ./modules/amd-gpu.nix
            ./modules/digital-art.nix
            ./modules/gaming.nix
            ./modules/hyprland.nix

            # Home Manager integration
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.woolw = import ./home/woolw/home.nix;
            }
          ];
        };
      };

      # Formatter for 'nix fmt' (RFC 166 style)
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    };
}
