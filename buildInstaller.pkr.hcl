packer {
  required_plugins {
    arm-image = {
      version = ">= 0.2.11"
      source  = "github.com/arendjan/arm-image"
    }
  }
}

variable "image_url" {
  type = string
  default = "build/mirte_orangepi3b.img.xz"
}
# source "arm-image" "mirte_orangepizero2" {
#   image_type = "armbian"
#   iso_url = "https://surfdrive.surf.nl/files/index.php/s/Zoep7yE9GlX3o7m/download?path=%2F&files=Armbian_22.02.2_Orangepizero2_focal_legacy_4.9.255.img.xz"
#   iso_checksum = "sha256:d2a6e59cfdb4a59fbc6f8d8b30d4fb8c4be89370e9644d46b22391ea8dff701d"
#   output_filename = "./workdir/mirte_orangepizero2.img"
#   target_image_size = 15*1024*1024*1024
#   qemu_binary = "qemu-aarch64-static"
# }

# source "arm-image" "mirte_orangepizero" {
#   image_type = "armbian"
#   iso_url = "https://surfdrive.surf.nl/files/index.php/s/Zoep7yE9GlX3o7m/download?path=%2F&files=Armbian_21.02.3_Orangepizero_focal_current_5.10.21.img.xz"
#   iso_checksum = "sha256:44ceec125779d67c1786b31f9338d9edf5b4f64324cc7be6cfa4a084c838a6ca"
#   output_filename = "./workdir/mirte_orangepizero.img"
#   target_image_size = 15*1024*1024*1024
# }
source "arm-image" "mirte_orangepi3b" {
    image_type = "armbian"
  iso_url = "https://mirte.arend-jan.com/files/test/Armbian-unofficial_24.8.1_Orangepi3b_jammy_edge_6.10.3.img"
  iso_checksum = "sha256:c0cc3ef76cd453a9bf25cbe3a1b10a4c866ab86df774d0b919756e291a7ec4e1"
  output_filename = "./workdir/mirte_orangepi3b_installer.img"
  target_image_size = 15*1024*1024*1024
  qemu_binary = "qemu-aarch64-static"
}

# source "arm-image" "mirte_rpi4b" { # TODO: change to armbian image
#   image_type = "raspberrypi"
#   iso_url = "https://cdimage.ubuntu.com/releases/20.04.5/release/ubuntu-20.04.5-preinstalled-server-armhf+raspi.img.xz"
#   iso_checksum = "sha256:065c41846ddf7a1c636a1aac5a7d49ebcee819b141f9d57fd586c5f84b9b7942"
#   output_filename = "./workdir/mirte_rpi4b.img"
#   target_image_size = 15*1024*1024*1024 # 15GB
# }


build {
  sources = ["source.arm-image.mirte_orangepi3b"]
  provisioner "file" {
    source = "installer/"
    destination = "/root/"
  }
#  provisioner "file" {
#     source = "build/mirte_orangepi3b_2024-02-01_21_00_25.img"
#     destination = "/root/mirte_orangepi3b.img"
#  }
provisioner "file" {
    source = "${var.image_url}"
    destination = "/root/mirte_orangepi3b.img.xz"
 }
 provisioner "file" {
    source = "installer/install.sh"
    destination = "/root/install.sh"
 }
 provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    inline = [
      "chmod +x /root/install.sh",
      "/root/install.sh"
    
    ]
  }
}