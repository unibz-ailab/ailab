{
  description = "Software for AI course labs";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    unstableNixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, unstableNixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
          pkgs = nixpkgs.legacyPackages.${system};
          uPkgs = unstableNixpkgs.legacyPackages.${system};
          envName = "ailab";
          defEnv = pkgs.buildEnv {
                    name = "${envName}";
                    paths = [
                      pkgs.micromamba
                      pkgs.fast-downward
                      pkgs.gojq
                    ];
          };
      in
      {
        packages.${envName} = defEnv;
        packages.default = defEnv;
      }
    );
}