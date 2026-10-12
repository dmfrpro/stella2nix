{
  description = "Stella compiler extracted from stella docker image and repackaged to nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, self', ... }:
        {
          packages = {
            stella = pkgs.callPackage ./package.nix { };
            default = self'.packages.stella;
          };
        };
    };
}
