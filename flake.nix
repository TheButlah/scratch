# save this as flake.nix
{
  description = "A disko images example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, disko, nixpkgs }@inputs:
    let
      system = "x86_64-linux";
    in
    rec {
      nixosConfigurations.ryan-worldcoin-hil = nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = {
          inherit inputs system;
          username = "worldcoin";
          hostname = "ryan-worldcoin-hil";
        };
        modules = [
          # You can get this file from here: https://github.com/nix-community/disko/blob/master/example/simple-efi.nix
          ./base-nixos.nix
          ./disko-bios-uefi.nix
          disko.nixosModules.disko
          ({ config, ... }: {
            # shut up state version warning
            system.stateVersion = config.system.nixos.version;
            # Adjust this to your liking.
            # WARNING: if you set a too low value the image might be not big enough to contain the nixos installation
            disko.devices.disk.main = {
              imageSize = "6G";
              device = "/dev/sda";
            };
          })
        ];
      };
      packages.${system} = {
        disko = disko.packages.${system}.disko;
        disko-install = disko.packages.${system}.disko-install;
        # buildLiveUsb = self.nixosConfigurations.self.config.system.build.diskoImagesScript;
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
