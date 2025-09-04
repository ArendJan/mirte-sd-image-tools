packer {
  required_plugins {
    arm-image = {
      version = ">= 0.2.10"
      source  = "github.com/arendjan/arm-image"
    }
  }
}

variable "image_url" {
  type = string
}
variable "image_name" {
  type = string
}


# source "arm-image" "mirte_orangepizero2" {
#   image_type = "armbian"
#   iso_url = "${var.image_url}"
#   iso_checksum = "none"
#   qemu_binary = "qemu-aarch64-static"
#   image_mounts = ["/", "/mnt/mirte/"]
#   output_filename = "./shell_workdir/${var.image_name}.img"
#   # target_image_size = 15*1024*1024*1024 # does not work with changed images

# }
source "arm-image" "image" {
  image_type = "armbian"
  iso_url = "${var.image_url}"
  iso_checksum = "none"
  qemu_binary = "qemu-aarch64-static"
  image_mounts = ["/", "/mnt/mirte/"]
  output_filename = "./shell_workdir/${var.image_name}.img"
  target_image_size = 15*1024*1024*1024

}
# source "arm-image" "mirte_orangepizero" {
#   image_type = "armbian"
#   iso_url = "https://archive.armbian.com/orangepizero/archive/Armbian_21.02.3_Orangepizero_focal_current_5.10.21.img.xz"
#   iso_checksum = "sha256:44ceec125779d67c1786b31f9338d9edf5b4f64324cc7be6cfa4a084c838a6ca"
#   output_filename = "./workdir/mirte_orangepizero.img"
#   target_image_size = 15*1024*1024*1024
# }
build {
  sources = ["source.arm-image.image"]
  
 provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    inline = [
      "echo \"${source.name}\"",
      "touch /stopshell",
      "echo \"run rm /stopshell to stop the image.\" ",
      "until [ ! -e /stopshell ]; do sleep 1; done",
      "sleep 1"
    ]
  }
}