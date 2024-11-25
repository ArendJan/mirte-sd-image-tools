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
  iso_url = "https://mirte.arend-jan.com/files/test/Armbian-unofficial_24.11.0-trunk_Orangepizero2_focal_edge_6.11.2.img.xz"
  iso_checksum = "sha256:a30c27cabc7185dc3c622e5a13405f7f9f8e88a55978d8ff46b6923acfb21b16"
  output_filename = "./workdir/mirte_orangepizero2.img"
  target_image_size = 15*1024*1024*1024
  qemu_binary = "qemu-aarch64-static"
}

source "arm-image" "mirte_orangepizero" {
  image_type = "armbian"
  iso_url = "https://mirte.arend-jan.com/files/test/Armbian-unofficial_24.11.0-trunk_Orangepizero_focal_current_6.6.54.img.xz"
  iso_checksum = "sha256:00f5d818e5d218e0168bbd2915b797fe6e847c63c7d883e4674237739bcd07a7"
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
  sources = ["source.arm-image.mirte_orangepizero2", "source.arm-image.mirte_orangepizero",  "source.arm-image.mirte_orangepi3b", "source.arm-image.mirte_rpi4b"]
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