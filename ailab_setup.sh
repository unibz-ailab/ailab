#!/usr/bin/env bash
set -ex

### Install nix and required packages
###   see <https://nixos.org/download#nix-install-linux>
#
NIX_VERSION=2.18.1
sh -x <(curl -L https://releases.nixos.org/nix/nix-${NIX_VERSION}/install) --no-daemon --yes
source ~/.nix-profile/etc/profile.d/nix.sh
nix-env -iA nixpkgs.fast-downward

### Install Miniforge
###   see <https://github.com/conda-forge/miniforge#downloading-the-installer-as-part-of-a-ci-pipeline>
#
MINIFORGE_VERSION=23.3.1-1
MINIFORGE_PATH="${HOME}/conda"
miniforge_installer="Miniforge3-$(uname)-$(uname -m).sh"
curl -L -o "/tmp/${miniforge_installer}" "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/${miniforge_installer}"
sh "/tmp/${miniforge_installer}" -b -p "${MINIFORGE_PATH}"
source "${MINIFORGE_PATH}/etc/profile.d/conda.sh"
source "${MINIFORGE_PATH}/etc/profile.d/mamba.sh"
conda init
mamba init
conda config --set auto_activate_base false

