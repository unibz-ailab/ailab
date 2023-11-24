# use with https://github.com/casey/just
#

_default:
    @just --list

tmpdir  := `mktemp -d`

_cleanup:
    [ -d "{{tmpdir}}"] && rm -rf "{{tmpdir}}" || true

_create_cloudinit cloudinit_yml:
    tar -cvzf - {{ if os() == "macos" { "-s" } else { "--transform" } }} '|^|ailab/|' flake.* nix| base64 > "{{tmpdir}}/flake.tar.gz.base64"
    sed 's|github:unibz-ailab/ailab|file:///run/flake.tar.gz|g' <"{{justfile_directory()}}/setup.sh" > "{{tmpdir}}/setup.sh"
    gojq --yaml-input --yaml-output --rawfile setup_script "{{tmpdir}}/setup.sh" --rawfile flake_tar "{{tmpdir}}/flake.tar.gz.base64" '.runcmd[0] |= ["sh", "--", "/run/ailab_setup.sh", "file:///run/setup.sh"] | .write_files += [{content: $setup_script, path: "/run/setup.sh", permissions: "0755", owner: "root", defer: true}, {content: ("!!binary|" + $flake_tar), path: "/run/flake.tar.gz", permissions: "0644", owner: "root", defer: true}]' ailab_cloudinit.yml \
    | perl -0777 -pe 's/(\|\n\s+?)!!binary\|/!!binary $1/g'> "{{cloudinit_yml}}"

mpass_vm_image := '22.04'
mpass_vm_params := '--memory 4G --disk 10G --cpus 2'

# Creates a new test VM, delete existing one with the same name
_create_vm vm_name cloud_init: (_delete_vm vm_name)
    multipass launch {{mpass_vm_image}} {{mpass_vm_params}} --name {{vm_name}} --cloud-init "{{cloud_init}}"

_delete_vm vm_name:
    multipass info {{vm_name}} >/dev/null 2>&1 &&  multipass delete --purge {{vm_name}} || true

_shell_vm vm_name:
    multipass info {{vm_name}} >/dev/null 2>&1 && multipass shell {{vm_name}}

vm_name := "ailab"
vm_name_test := vm_name + "test"
cloudinit_test := tmpdir + "/cloudinit.yml"

# Create and log into a multipass VM using the local configuration
test_vm: (_create_cloudinit cloudinit_test) (_create_vm vm_name_test cloudinit_test) (_shell_vm vm_name_test)

# Create and log into a multipass VM using the repo configuration
vm: (_create_vm vm_name "https://github.com/unibz-ailab/ailab/raw/main/ailab_cloudinit.yml") (_shell_vm vm_name)
