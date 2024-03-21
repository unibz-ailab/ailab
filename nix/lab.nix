{ pkgs ? import <nixpkgs> {}
, lib
, stdenv
}:
pkgs.buildEnv {
  name = "ailab";
  paths = with pkgs; [
    # AI tools
    fast-downward

    # Other tools
    jq
    gojq
    go-task
    just
    mani
    micromamba
    pipx
    pixi
    rsync
  ];
}