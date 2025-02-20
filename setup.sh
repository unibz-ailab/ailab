#!/usr/bin/env sh
set -ex

: "${FLAKE_URL=github:unibz-ailab/ailab?ref=ay2024#ailab}"

setup_nix() {
    ### Install nix and required packages
    ###   see <https://github.com/DeterminateSystems/nix-installer>
    #
    NIX_INST_VERSION="v0.36.4"
    curl --proto '=https' --tlsv1.2 -sSf -L "https://install.determinate.systems/nix/tag/${NIX_INST_VERSION}" | sh -s -- install --no-confirm

    # add an extra cache
    printf "\nextra-substituters = https://nix-community.cachix.org\nextra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=\n" \
        | sudo tee -a /etc/nix/nix.conf

    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
}

main() {
    setup_nix

    nix profile install --accept-flake-config "${FLAKE_URL}"
}

main
