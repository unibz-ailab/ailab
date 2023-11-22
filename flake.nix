{
  description = "Software for AI course labs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    # use `flake-parts` for multiple architectures
    #   see <https://ayats.org/blog/no-flake-utils/>
    #   and <https://github.com/hercules-ci/flake-parts/blob/main/template/default/flake.nix>
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: let
        defEnv = pkgs.buildEnv {
          name = "ailab";
          paths = with pkgs; [
            micromamba
            fast-downward
            gojq
            just
          ];
        };
      in {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        packages.${defEnv.name} = defEnv;
        packages.default = defEnv;
      };
    };

}