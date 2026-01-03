packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

source "qemu" "alpine" {
  iso_url      = "https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/x86_64/alpine-virt-3.24.1-x86_64.iso"
  iso_checksum = "sha256:e73a6241bd5f3c5c2d4d38c02cc52c378c0415a7c888bd292066bf36e0f41a39"

  output_directory = "../../images/alpine"
  vm_name          = "alpine-base-3.24.1.qcow2"

  format      = "qcow2"
  accelerator = "kvm"

  disk_size = "5G"
  memory    = 512
  cpus      = 2

  net_device     = "virtio-net"
  disk_interface = "virtio"

  headless = false

  http_directory = "http"

  ssh_username = "root"
  ssh_password = "PackerAlpineRootPassword"
  ssh_timeout  = "1m"

  boot_wait = "10s"
  boot_key_interval = "10ms"
  boot_command = [
    "root<enter><wait>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait>",
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answers<enter><wait>",
    "ERASE_DISKS=/dev/vda BOOT_SIZE=64 setup-alpine -f answers<enter><wait5>",
    "PackerAlpineRootPassword<enter><wait>",
    "PackerAlpineRootPassword<enter><wait>",
    "mount /dev/vda2 /mnt && sed -i 's/^#PermitRootLogin prohibit-password$/PermitRootLogin yes/' /mnt/etc/ssh/sshd_config && sed -i 's/^#PasswordAuthentication yes$/PasswordAuthentication yes/' /mnt/etc/ssh/sshd_config && umount /mnt<enter><wait>",
    "reboot<enter>"
  ]
  shutdown_command = "poweroff"
}

build {
  sources = ["source.qemu.alpine"]
}
