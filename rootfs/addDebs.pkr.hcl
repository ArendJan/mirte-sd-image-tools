packer {
  required_plugins {
    arm-image = {
      version = ">= 0.2.11"
      source  = "github.com/arendjan/arm-image"
    }
  }
}
 
source "arm-image" "mirte_orangepizero_jammy" {
  image_type = "armbian"
  iso_url = "https://surfdrive.surf.nl/files/index.php/s/npEUJbxlPcVj1AB/download?path=Armbian-unofficial_24.8.2_Orangepizero_jammy_current_6.6.44.img.xz "
  iso_checksum = "sha256:cfae8314b46326a7b8b57cbab5f422d6744dbe6a627f7fb28b7045c5990e5c37"
  output_filename = "./workdir/mirte_orangepizero_with_debs.img"
  target_image_size = 4*1024*1024*1024
}
 

build {
  sources = [ "source.arm-image.mirte_orangepizero_jammy" ]
//   provisioner "file" {
//     source      = "./workdir/src/"
//     destination = "/root/ros2_ws/src/"
//   }
provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    inline = [
        "set -xe",
        "mkdir -p /root/ros2_ws/src",
    ]
  }

//   provisioner "file" {
//     source      = "./workdir/src/"
//     destination = "/root/ros2_ws/src/"
//   }
    provisioner "file" {
        source      = "./scripts/"
        destination = "/root/scripts/"
    }
 provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    inline = [
        "set -xe",
    //   "sudo apt install libtinyxml-dev libtinyxml2-dev libacl1-dev -y",
    //   "sudo -H apt-get install -y libacl1-dev  libbenchmark-dev python3-pytest-timeout python3-pytest-mock python3-mypy libasio-dev zstd libzstd-dev"
    "/root/scripts/addDebs.sh",
    ]
  }
}
