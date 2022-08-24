{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    satysfi-upstream.url = "github:SnO2WMaN/SATySFi/sno2wman/nix-flake";
    satyxin.url = "github:SnO2WMaN/satyxin/add-class-yabaitech-and-etc";

    # dev
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = with inputs; [
            devshell.overlay
            satyxin.overlays.default
            (final: prev: {
              satysfi = satysfi-upstream.packages.${system}.satysfi;
            })
          ];
        };
      in rec {
        packages = rec {
          satysfi-dist = pkgs.satyxin.buildSatysfiDist {
            packages = with pkgs.satyxinPackages; [
              dist
              class-yabaitech
            ];
          };
        };

        devShell = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            satysfi
          ];
        };
      }
    );
}
