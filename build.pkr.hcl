packer {
  required_plugins {
    arm-image = {
      version = ">= 0.2.11"
      source  = "github.com/arendjan/arm-image"
    }
  }
}


source "arm-image" "mirte_orangepizero2" {
  image_type = "armbian"
  iso_url = "https://github.com/ArendJan/mirte_base_images/releases/download/25.2.3/Armbian-unofficial_25.2.3_Orangepizero2_jammy_current_6.6.62.img.xz"
  iso_checksum = "sha256:f37f28d2c0b6c8b26933ca0e9622d88be3d0ece81aec985f7fe7fa0a0cbbc6d9"
  output_filename = "./workdir/mirte_orangepizero2.img"
  target_image_size = 15*1024*1024*1024
  image_arch = "arm64"
}

source "arm-image" "mirte_orangepizero2_noble" {
  image_type = "armbian"
  iso_url = "https://imola.armbian.com/archive/orangepizero2/archive/Armbian_24.5.1_Orangepizero2_noble_current_6.6.31.img.xz"
  iso_checksum = "none"
  output_filename = "./workdir/mirte_orangepizero2.img"
  target_image_size = 15*1024*1024*1024
  image_arch = "arm64"
}

source "arm-image" "mirte_orangepi3b" {
  image_type = "armbian"
  iso_url = "https://github.com/ArendJan/mirte_base_images/releases/download/25.2.3/Armbian-unofficial_25.2.3_Orangepi3b_jammy_edge_6.12.0.img.xz"
  iso_checksum = "sha256:53be4439ed94fb6a3c6e9f3f38b577ff672c45eee61aa5563a49e5cc802f5ebc"
  output_filename = "./workdir/mirte_orangepi3b.img"
  target_image_size = 15*1024*1024*1024
  # qemu_binary = ""
  image_arch = "arm64"
}

source "arm-image" "mirte_x86" {
  image_type = "armbian"
  iso_url = "/home/arendjan/Downloads/Armbian-unofficial_25.02.0-trunk_Uefi-x86_jammy_current_6.12.10 (1).img"
  iso_checksum = "sha256:d847269f9be318be2c8bbbfde3ea43418686ce9f779e3552979a45d01cc030e8"
  target_image_size = 15*1024*1024*1024
  image_mounts = [ "", "", "/" ]
}


# source "arm-image" "mirte_rpi4b" { # TODO: change to armbian image
#   image_type = "raspberrypi"
#   iso_url = "https://cdimage.ubuntu.com/releases/20.04.5/release/ubuntu-20.04.5-preinstalled-server-armhf+raspi.img.xz"
#   iso_checksum = "sha256:065c41846ddf7a1c636a1aac5a7d49ebcee819b141f9d57fd586c5f84b9b7942"
#   output_filename = "./workdir/mirte_rpi4b.img"
#   target_image_size = 15*1024*1024*1024 # 15GB
# }

build {
  sources = ["source.arm-image.mirte_orangepizero2", "source.arm-image.mirte_orangepizero2_noble", "source.arm-image.mirte_orangepi3b", "source.arm-image.mirte_x86"]
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
