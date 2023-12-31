#!/usr/bin/env sh
set -ex

setup_nix() {
    ### Install nix and required packages
    ###   see <https://github.com/DeterminateSystems/nix-installer>
    #
    NIX_INST_VERSION="v0.15.1"
    curl --proto '=https' --tlsv1.2 -sSf -L "https://install.determinate.systems/nix/tag/${NIX_INST_VERSION}" | sh -s -- install --no-confirm

    # add an extra cache
    printf "\nextra-substituters = https://nix-community.cachix.org\nextra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=\n" \
        | sudo tee -a /etc/nix/nix.conf

    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

    # install https://direnv.net/ and hook it into bash/zsh
    nix profile install nixpkgs#direnv
    [ -f "${HOME}/.bashrc" ] && echo 'eval "$(direnv hook bash)"' >> "${HOME}/.bashrc"
    [ -f "${HOME}/.zshrc" ] && echo 'eval "$(direnv hook zsh)"' >> "${HOME}/.zshrc"
}

setup_miniforge() {
    ### Install Miniforge
    ###   see <https://github.com/conda-forge/miniforge#downloading-the-installer-as-part-of-a-ci-pipeline>
    #
    MINIFORGE_VERSION=23.3.1-1
    MINIFORGE_PATH="${HOME}/conda"

    temp_dir="$(mktemp -d)" || return 1
    script_name="Miniforge3-$(uname)-$(uname -m).sh"
    script_file="${temp_dir}/${script_name}"

    curl -L -o "${script_file}" "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/${script_name}"
    sh -- "${script_file}" -b -p "${MINIFORGE_PATH}"
    rm -rf "${temp_dir}"

    "${MINIFORGE_PATH}/bin/mamba" init "$(basename "${SHELL:-bash}")"
    "${MINIFORGE_PATH}/bin/conda" config --set auto_activate_base false
    "${MINIFORGE_PATH}/bin/conda" config --set solver libmamba

    . "${MINIFORGE_PATH}/etc/profile.d/conda.sh"
    . "${MINIFORGE_PATH}/etc/profile.d/mamba.sh"
}

main() {
    setup_nix
    setup_miniforge

    ## Configure default Nix profile
    AILAB_FLAKE="github:unibz-ailab/ailab#ailab"
    nix profile install --accept-flake-config "${AILAB_FLAKE}"
}

main
