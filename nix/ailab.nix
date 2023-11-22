{ pkgs ? import <nixpkgs> {} }:
pkgs.buildEnv {
  name = "ailab";
  paths = with pkgs; [
    fast-downward
    gojq
    just
    mani
    micromamba
  ];
}