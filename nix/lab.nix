{ pkgs ? import <nixpkgs> {}
, lib
, stdenv
}:
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