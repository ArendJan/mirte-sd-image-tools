#!/bin/bash

set -ex

# image=$1
# if [ -z "$image" ]; then
# 	echo "Usage: $0 <path to image.img>"
# 	exit 1
# fi

# ls build

# mkdir -p installer_workdir
# cp ${image} installer_workdir/
# # cd installer_workdir
# image=installer_workdir/$(basename ${image})

# # if the image is not compressed, compress it
# if [[ ! ${image} =~ \.xz$ ]]; then
# 	xz -z -k ${image}
# 	image=${image}.xz
# fi
# xzcat ${image} | md5sum >build/mirte_orangepi3b.img.md5sum
# cd ..
df -h

# ls -l build
# df -h
sudo packer build buildInstaller.pkr.hcl # create installer image
# df -h
./scripts/finalize.sh "$(realpath './workdir/mirte_orangepi3b_installer.img')" # finalize installer
# df -h


# TODO: create extra partition for image file
# TODO: update install.sh to use image from extra partition or use image from external usb drive
# TODO: install.sh: copy configuration files


echo "Installer image created in build/ folder"
