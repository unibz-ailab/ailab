#!/usr/bin/env sh
set -ex

: "${FLAKE_URL=github:unibz-ailab/ailab?ref=main#ailab}"

setup_nix() {
    ### Install nix and required packages
    ###   see <https://github.com/DeterminateSystems/nix-installer>
    #
    NIX_INST_VERSION="v0.16.0"
    curl --proto '=https' --tlsv1.2 -sSf -L "https://install.determinate.systems/nix/tag/${NIX_INST_VERSION}" | sh -s -- install --no-confirm

    # add an extra cache
    printf "\nextra-substituters = https://nix-community.cachix.org\nextra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=\n" \
        | sudo tee -a /etc/nix/nix.conf

    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
}

setup_miniforge() {
    ### Install Miniforge
    ###   see <https://github.com/conda-forge/miniforge#downloading-the-installer-as-part-of-a-ci-pipeline>
    #
    MINIFORGE_VERSION=23.11.0-0
    MINIFORGE_PATH="${HOME}/conda"

    temp_dir="$(mktemp -d)" || return 1
    script_name="Miniforge3-$(uname)-$(uname -m).sh"
    script_file="${temp_dir}/${script_name}"

    curl -L -o "${script_file}" "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/${script_name}"
    sh -- "${script_file}" -b -p "${MINIFORGE_PATH}"
    rm -rf "${temp_dir}"

    "${MINIFORGE_PATH}/bin/mamba" init "$(basename "${SHELL:-bash}")"
    "${MINIFORGE_PATH}/bin/conda" config --set auto_activate_base false

    . "${MINIFORGE_PATH}/etc/profile.d/conda.sh"
    . "${MINIFORGE_PATH}/etc/profile.d/mamba.sh"
}

main() {
    setup_nix
    setup_miniforge

    nix profile install --accept-flake-config "${FLAKE_URL}"
}

main
