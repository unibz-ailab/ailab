#!/usr/bin/env bash

# Script to setup a Linux host with software for the AI labs

# stop the script on error
set -e

########
## install Nix package manager

NIX_VERSION=2.13.1

sh -x <(curl -L https://releases.nixos.org/nix/nix-${NIX_VERSION}/install) --no-daemon --yes

source ~/.nix-profile/etc/profile.d/nix.sh

nix-env -iA nixpkgs.fast-downward

########
## install MambaForge

mambaforge_installer="Mambaforge-$(uname)-$(uname -m).sh"

curl -L -o "/tmp/${mambaforge_installer}" "https://github.com/conda-forge/miniforge/releases/latest/download/${mambaforge_installer}"
sh "/tmp/${mambaforge_installer}" -b

~/mambaforge/condabin/conda init
~/mambaforge/condabin/mamba init
~/mambaforge/condabin/conda config --set auto_activate_base false
