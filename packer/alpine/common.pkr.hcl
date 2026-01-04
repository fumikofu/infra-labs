source "qemu" "alpine-common" {
  iso_url          = "../../images/alpine-base/alpine-base-3.24.1.qcow2"
  iso_checksum     = "none"

  disk_image       = true
  use_backing_file = true
  format           = "qcow2"

  output_directory = "../../images/alpine-common"
  vm_name          = "alpine-common-3.24.1.qcow2"

  accelerator = "kvm"
  cpus        = 2
  memory      = 512
  disk_size   = "5G"
  headless    = false

  ssh_username         = "root"
  ssh_private_key_file = "~/.ssh/id_ed25519"
  ssh_timeout          = "10m"

  shutdown_command = "poweroff"
}

build {
  sources = ["source.qemu.alpine-common"]

  provisioner "shell" {
    inline = [
      "apk add --no-cache openssh curl git qemu-guest-agent"
    ]
  }
}
