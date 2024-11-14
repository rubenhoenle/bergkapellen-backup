{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, agenix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      apps.devshell = self.outputs.devShell.${system}.flakeApp;
      formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      packages = {
        nixosConfigurations =
          let
            inherit (nixpkgs.lib) nixosSystem;
          in
          {
            raspberry-pi_4 = nixosSystem {
              system = "aarch64-linux";
              modules = [
                "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
                ./configuration.nix
                {
                  sdImage.compressImage = false;
                }

                # agenix
                agenix.nixosModules.default
                {
                  _module.args.agenix = agenix.packages.${system}.default;
                }
              ];
            };
          };
      };
    });
}
