# use with https://github.com/casey/just
#

repo := "https://github.com/unibz-ailab/ailab"
repo_tag := "ay2023"
_repo_raw_url := repo / "raw" / repo_tag

ssh_key := `ssh-agent sh -c 'ssh-add -q; ssh-add -L'`

_local_cloud_init := justfile_directory() / "cloudinit.yml"
remote_clud_init := _repo_raw_url / file_name(_local_cloud_init)
_setup_script := justfile_directory() / "setup.sh"

_remote_tmpdir := "/run/vm_setup"

testing := env("USE_WORKDIR", "false")

vm_name := "ailab" + if testing == "true" { "test" } else { "" }

@_default:
    just --list
    echo "Variables:"
    just --evaluate | sed '/^_/d;s/^/    /'

_create_cloudinit tmpdir:
    mkdir -p "{{tmpdir}}"
    tar -cvzf - --no-xattrs {{ if os() == "macos" { "--no-mac-metadata -s" } else { "--transform" } }} '|^|lab/|' flake.* nix| base64 > "{{tmpdir}}/flake.tar.gz.base64"
    sed 's|\(FLAKE_URL="\)[^#]*\(.*"\)|\1file://{{_remote_tmpdir}}/flake.tar.gz\2|' <"{{_setup_script}}" > "{{tmpdir}}/setup.sh"
    gojq --yaml-input --yaml-output --rawfile setup_script "{{tmpdir}}/setup.sh" --rawfile flake_tar "{{tmpdir}}/flake.tar.gz.base64" '.runcmd[0] += ["file://{{_remote_tmpdir}}/setup.sh"] | .write_files += [{content: $setup_script, path: "{{_remote_tmpdir}}/setup.sh", permissions: "0755", owner: "root", defer: true}, {content: $flake_tar, encoding: "b64", path: "{{_remote_tmpdir}}/flake.tar.gz", permissions: "0644", owner: "root", defer: true}]' "{{_local_cloud_init}}"> "{{tmpdir}}/cloudinit.yml"

mpass_vm_image := '20.04'
mpass_vm_params := '--memory 4G --disk 20G --cpus 2'

# Creates a new test VM, delete existing one with the same name
_create_vm name cloud_init: (_delete_vm name) && (_add_ssh_key name)
    multipass launch {{mpass_vm_image}} {{mpass_vm_params}} --name {{name}} --cloud-init "{{cloud_init}}"

_add_ssh_key name:
    multipass exec -d '.ssh' {{name}} -- sh -c 'grep -qxF "{{ssh_key}}" authorized_keys || echo "{{ssh_key}}" >> authorized_keys'

_delete_vm name:
    multipass info {{name}} >/dev/null 2>&1 &&  multipass delete --purge {{name}} || true

_shell_vm name:
    multipass info {{name}} >/dev/null 2>&1 && multipass shell {{name}}

_stop_vm name:
    multipass stop {{name}}

# Create a multipass VM using the local configuration
vm_test name=vm_name tmpdir=`mktemp -d`: \
        (_create_cloudinit tmpdir) \
        (_create_vm name tmpdir / "cloudinit.yml")
    [ -z ${KEEPTEMP+x} ] && rm -rf "{{tmpdir}}"

# Create a multipass VM using the repo configuration
vm name=vm_name: (_create_vm name remote_clud_init)

# Login into a multipass VM
shell name=vm_name: (_shell_vm name)

# Stop the multipass VM
stop name=vm_name: (_stop_vm name)

# Delete the multipass VM
rm name=vm_name: (_delete_vm name)
