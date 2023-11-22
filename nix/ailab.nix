{ pkgs ? import <nixpkgs> {} }:
pkgs.buildEnv {
  name = "ailab";
  paths = with pkgs; [
    devbox
    fast-downward
    gojq
    just
    mani
    micromamba
  ];
}