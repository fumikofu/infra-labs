# infra-labs

Image-based VM lab infrastructure using QEMU/libvirt and OpenTofu.

## Architecture

```
    - [x] alpine-base.qcow2 (minimal Alpine)
                        ↓
    - [ ] common.qcow2 (ssh, curl, git, qemu-guest-agent, k3s)
                        ↓
              ┌────────────────────┴────────────────────┐
              ↓                                         ↓
    - [ ] control.qcow2 (k3s cp)            - [ ] worker.qcow2 (k3s wp)
              ↓                                         ↓
    - [ ] disposable VM overlays
```

## Structure

```
infra-labs/
├── images/
│   └── alpine/
│       ├── base/
│       └── common/
├── lab/
│   └── alpine-k3s/
│       ├── control/
│       ├── worker/
│       └── *.tf
├── scripts/
│   └── install-base.sh
└── Makefile
```

## Usage

1. Build base image: `make base`
2. Deploy VMs: `tofu -chdir=lab/alpine-k3s apply`

## TODO

- [ ] Introduce Packer
- [ ] Introduce Debian with k8s
- [ ] Add GPG verification
- [ ] Centralize QEMU vars (RAM, CPUs, disk, NIC) shared by install-*.sh and Terraform
