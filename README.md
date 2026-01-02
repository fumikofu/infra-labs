# infra-labs

Image-based VM lab infrastructure using QEMU/libvirt and OpenTofu.

## Architecture

```
    - [x] alpine-base.qcow2 (minimal Alpine)
                        ↓
    - [x] common.qcow2 — immutable software layer shared by all Alpine lab nodes
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
│   ├── install-base.sh
│   └── install-common.sh
└── Makefile
```

## Usage

1. Build base image: `make base`
2. Build common image: `make common`
3. Deploy VMs: `tofu -chdir=lab/alpine-k3s apply`

## TODO

- [ ] Introduce Packer
- [ ] Introduce Debian with k8s
- [ ] Add GPG verification
- [ ] Centralize QEMU vars (RAM, CPUs, disk, NIC) shared by install-*.sh and Terraform
