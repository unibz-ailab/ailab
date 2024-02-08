{ pkgs ? import <nixpkgs> {}
, lib
, stdenv
}:
pkgs.buildEnv {
  name = "ailab";
  paths = with pkgs; [
    # AI tools
    fast-downward
    minizinc

    # Other tools
    gojq
    go-task
    just
    mani
    micromamba
    pixi
    rsync
  ];
}