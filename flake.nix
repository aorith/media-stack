{
  description = "Media Stack as a NixOS systemd-nspawn container.";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: let
    forAllSystems = inputs.nixpkgs.lib.genAttrs ["aarch64-linux" "x86_64-linux"];
  in {
    formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
    packages = forAllSystems (system: {
      default = let
        nixos = inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [./configuration.nix ./nspawn-rootSystem.nix];
        };
      in
        nixos.config.system.build.rootSystem;
    });
  };
}
