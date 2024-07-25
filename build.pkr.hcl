packer {
  required_plugins {
    arm-image = {
      version = ">= 0.2.11"
      source  = "github.com/arendjan/arm-image"
    }
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
    }

  }
}

source "arm-image" "mirte_orangepizero2" {
  image_type = "armbian"
  iso_url = "https://surfdrive.surf.nl/files/index.php/s/Zoep7yE9GlX3o7m/download?path=%2F&files=Armbian_22.02.2_Orangepizero2_focal_legacy_4.9.255.img.xz"
  iso_checksum = "sha256:d2a6e59cfdb4a59fbc6f8d8b30d4fb8c4be89370e9644d46b22391ea8dff701d"
  output_filename = "./workdir/mirte_orangepizero2.img"
  target_image_size = 15*1024*1024*1024
  qemu_binary = "qemu-aarch64-static"
}

source "virtualbox-iso" "mirte_x64" {
  guest_os_type = "Ubuntu_64"
  # iso_url = "http://releases.ubuntu.com/12.04/ubuntu-12.04.5-server-amd64.iso"
  # iso_checksum = "md5: q"
  ssh_username = "packer"
  ssh_password = "packer"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  iso_url = "https://dl.armbian.com/uefi-arm64/archive/Armbian_24.5.1_Uefi-arm64_jammy_current_6.6.31.img.xz"
  iso_checksum = "none"
  # output_filename = "./workdir/mirte_x64.img"
  # target_image_size = 15*1024*1024*1024
  # qemu_binary = "qemu-aarch64-static"
}

source "arm-image" "mirte_orangepizero" {
  image_type = "armbian"
  iso_url = "https://surfdrive.surf.nl/files/index.php/s/Zoep7yE9GlX3o7m/download?path=%2F&files=Armbian_21.02.3_Orangepizero_focal_current_5.10.21.img.xz"
  iso_checksum = "sha256:44ceec125779d67c1786b31f9338d9edf5b4f64324cc7be6cfa4a084c838a6ca"
  output_filename = "./workdir/mirte_orangepizero.img"
  target_image_size = 15*1024*1024*1024
}
source "arm-image" "mirte_orangepi3b" {
    image_type = "armbian"
  iso_url = "https://surfdrive.surf.nl/files/index.php/s/Zoep7yE9GlX3o7m/download?path=%2F&files=Armbian-unofficial_24.2.0-trunk_Orangepi3b_focal_legacy_5.10.160_msdos.img.xz"
  iso_checksum = "sha256:376656dce00ff2e6404dd20110af4b1f0927b847c3c49d6a705dcf31789aaa34"
  output_filename = "./workdir/mirte_orangepi3b.img"
  target_image_size = 15*1024*1024*1024
  qemu_binary = "qemu-aarch64-static"
}

source "arm-image" "mirte_rpi4b" { # TODO: change to armbian image
  image_type = "raspberrypi"
  iso_url = "https://cdimage.ubuntu.com/releases/20.04.5/release/ubuntu-20.04.5-preinstalled-server-armhf+raspi.img.xz"
  iso_checksum = "sha256:065c41846ddf7a1c636a1aac5a7d49ebcee819b141f9d57fd586c5f84b9b7942"
  output_filename = "./workdir/mirte_rpi4b.img"
  target_image_size = 15*1024*1024*1024 # 15GB
}


build {
  sources = ["source.arm-image.mirte_orangepizero2", "source.arm-image.mirte_orangepizero",  "source.arm-image.mirte_orangepi3b", "source.arm-image.mirte_rpi4b", "source.virtualbox-iso.mirte_x64"]
  provisioner "file" {
    source = "git_local"
    destination = "/usr/local/src/mirte"
  }
  provisioner "file" {
    source = "repos.yaml"
    destination = "/usr/local/src/mirte/"
  }
  provisioner "file" {
    source = "settings.sh"
    destination = "/usr/local/src/mirte/"
  }
  provisioner "file"  {
    source = "wheels"
    destination = "/usr/local/src/mirte/wheels/"
  }
  provisioner "file"  {
    source = "mirte_main_install.sh"
    destination = "/usr/local/src/mirte/"
  }
 provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    inline = [
      "chmod +x /usr/local/src/mirte/mirte_main_install.sh",
      "export type=${source.name}",
      "echo $type",
      "mkdir /usr/local/src/mirte/build_system/",
      "sudo -E /usr/local/src/mirte/mirte_main_install.sh"
    ]
  }
  # provisioner "file" { # Provide the logs to the sd itself, doesn't work as tee deletes it and packer is missing it
  #   source = " logs/current_log.txt"
  #   destination = "/usr/local/src/mirte/build_system/"
  # }
  provisioner "file" { # provide the build script
    source = "build.pkr.hcl"
    destination = "/usr/local/src/mirte/build_system/"
  }
}