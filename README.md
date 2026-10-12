# stella2nix

Stella compiler extracted from the pinned `fizruk/stella` docker image and repackaged to nix.

## Run

```console
nix run github:dmfrpro/stella2nix -- compile input.stella
```

## flake-parts

```nix
{
  inputs.stella2nix.url = "github:dmfrpro/stella2nix";

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem = { pkgs, system, ... }: {
        # as a package output
        packages.stella = inputs.stella2nix.packages.${system}.stella;

        # or in a dev shell
        devShells.default = pkgs.mkShell {
          packages = [ inputs.stella2nix.packages.${system}.stella ];
        };
      };
    };
}
```
