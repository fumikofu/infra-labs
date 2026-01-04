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

  output_directory = "../../images/alpine-base"
  vm_name          = "alpine-base-3.24.1.qcow2"

  format      = "qcow2"
  accelerator = "kvm"

  disk_size = "5G"
  memory    = 512
  cpus      = 2

  net_device     = "virtio-net"
  disk_interface = "virtio"

  headless = false

  http_content = {
    "/answers"        = file("${path.root}/http/answers")
    "/id_ed25519.pub" = file(pathexpand("~/.ssh/id_ed25519.pub"))
  }

  ssh_username         = "root"
  ssh_private_key_file = "~/.ssh/id_ed25519"
  ssh_timeout          = "1m"

  boot_wait = "7s"
  boot_key_interval = "10ms"
  boot_command = [
    "root<enter><wait>",
    "ifconfig eth0 up && udhcpc -i eth0<enter><wait>",
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answers<enter><wait>",
    "ERASE_DISKS=/dev/vda BOOT_SIZE=48 setup-alpine -e -f answers<enter><wait5>",
    "mount /dev/vda2 /mnt && mkdir -p /mnt/root/.ssh && wget -q http://{{ .HTTPIP }}:{{ .HTTPPort }}/id_ed25519.pub -O /mnt/root/.ssh/authorized_keys && chmod 700 /mnt/root/.ssh && chmod 600 /mnt/root/.ssh/authorized_keys && sed -i 's/^#PermitRootLogin prohibit-password$/PermitRootLogin yes/' /mnt/etc/ssh/sshd_config && umount /mnt<enter><wait>",
    "reboot<enter>"
  ]
  shutdown_command = "poweroff"
}

build {
  sources = ["source.qemu.alpine"]
}
