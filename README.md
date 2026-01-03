# infra-labs

Image-based VM lab infrastructure using QEMU/libvirt and OpenTofu.

## Architecture

```mermaid
flowchart TB
    A["packer build base.pkr.hcl<br/>(creates alpine-base-3.24.1.qcow2, minimal Alpine installation)"]
    B["?<br/>(alpine-common.qcow2, shared software layer)"]

    C["?<br/>(control.qcow2, k3s control plane layer)"]
    D["?<br/>(worker.qcow2, k3s worker layer)"]

    E["?<br/>(disposable VM overlays + cluster)"]

    A --> B
    B --> C
    B --> D
    C --> E
    D --> E
```

## TODO

- [ ] Introduce Debian with k8s
- [ ] Utilize HCL: SSH keys, variables, etc.
- [ ] Add GPG verification
- [ ] Centralize QEMU vars (RAM, CPUs, disk, NIC) shared by Packer and Terraform
