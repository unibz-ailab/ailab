#!/usr/bin/env bash
set -ex

### Install nix and required packages
###   see <https://github.com/DeterminateSystems/nix-installer>
#
NIX_INST_VERSION="v0.15.1"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix/tag/${NIX_INST_VERSION} | sh -s -- install --no-confirm
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

## Install default profile
AILAB_FLAKE="github:unibz-ailab/ailab#ailab"
nix profile install "${AILAB_FLAKE}"

### Install Miniforge
###   see <https://github.com/conda-forge/miniforge#downloading-the-installer-as-part-of-a-ci-pipeline>
#
MINIFORGE_VERSION=23.3.1-1
MINIFORGE_PATH="${HOME}/conda"
miniforge_installer="Miniforge3-$(uname)-$(uname -m).sh"
curl -L -o "/tmp/${miniforge_installer}" "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/${miniforge_installer}"
sh "/tmp/${miniforge_installer}" -b -p "${MINIFORGE_PATH}"
"${MINIFORGE_PATH}/bin/mamba" init $(basename "${SHELL:-bash}")
"${MINIFORGE_PATH}/bin/conda" config --set auto_activate_base false
