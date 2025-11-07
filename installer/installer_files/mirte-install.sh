#!/bin/bash

set -xe

# STEPS:
# source settings
# get source locations order them by priority
# setup ethernet/wifi/mounts
# write uf2
# write image to emmc
# write uboot to spi/...
# copy files to os
# run script in chroot
# copy back logs
# shutdown


main() {
	echo "Starting Mirte installer"
	source ./default_settings.sh
	setup_locations
	setup_networking
	download_image
	write_image
	write_uboot
	copy_files_to_os
	run_chroot_script
	copy_back_logs
	shutdown_system
}

setup_locations() {
	echo "Setting up source locations"
	# Get source locations and order them by priority
	# mount all possible locations:
	# - other partitions on the installer sdcard
	# - USB drives
	
	# what device is / mounted on
	root_dev=$(findmnt -n -o SOURCE /)
	root_disk=$(echo $root_dev | sed 's/[0-9]*$//')

	# either starting with sd nvm or mmc
	disks=$(lsblk -r |awk '{ print $1 }'|grep -v loop|grep -v md| grep -v sr0 | grep -E '^sd|^nvme|^mmc' | sort | uniq)
	for i in $disks; do
		if [ -z  "$(grep  $i /proc/mounts)" ]
		then  
			mkdir -p /mnt/drives/$i;
			mount /dev/$i /mnt/drives/$i
		fi
	done

	# if any disk that is not on the root disk, then use that
	SRC_LOCATION=()
	for i in $disks; do
		if [[ "$i" != "$(echo $root_disk | sed 's/^\/dev\///')" ]]; then
			SRC_LOCATION="/mnt/drives/$i"
		fi
	done

	if [ -z "$SRC_LOCATION" ]; then
		echo "No source locations found, using root disk partitions"
		# if no other disks found, use other partitions on root disk
		partitions=$(lsblk -r |awk '{ print $1 }'|grep "$(echo $root_disk | sed 's/^\/dev\///')" | grep -v "$(echo $root_dev | sed 's/^\/dev\///')" )
		for p in $partitions; do
			SRC_LOCATION="/mnt/drives/$p"
		done
	fi

	if [ -z "$SRC_LOCATION" ]; then
		echo "No source locations found, exiting"
		exit 1
	fi


	# read config.yaml from source locations
	# for src in "${SRC_LOCATIONS[@]}"; do
	if [ -f "$SRC_LOCATION/config.yaml" ]; then
		echo "Found config.yaml in $SRC_LOCATION"
		# parse config.yaml
		# if target_dev, image_location and download_url are set, use them
		if grep -q 'target_dev:' "$SRC_LOCATION/config.yaml"; then
			echo "Found target_dev in config.yaml"
			TARGET_DEV=$(cat "$SRC_LOCATION/config.yaml" | yq -r -e '.target_dev' || echo "$TARGET_DEV")
		fi

		if grep -q 'image_location:' "$SRC_LOCATION/config.yaml"; then
			echo "Found image_location in config.yaml"
			IMAGE_LOCATION=$(cat "$SRC_LOCATION/config.yaml" | yq -r -e '.image_location' || echo "$IMAGE_LOCATION")
		fi

		if grep -q 'download_url:' "$SRC_LOCATION/config.yaml"; then
			echo "Found download_url in config.yaml"
			DOWNLOAD_URL=$(cat "$SRC_LOCATION/config.yaml" | yq -r -e '.download_url' || echo "$DOWNLOAD_URL")
		fi
		# TODO: nfs values and wifi
		echo "TARGET_DEV: $TARGET_DEV"
		echo "IMAGE_LOCATION: $IMAGE_LOCATION"
		echo "DOWNLOAD_URL: $DOWNLOAD_URL"
	fi

	# if download is empty and image_location is empty, use file from source location that has .img[.xz][.zip] extension
	if [ -z "$DOWNLOAD_URL" ] && [ -z "$IMAGE_LOCATION" ]; then
		for file in "$SRC_LOCATION"/*; do
			if [[ "$file" == *.img || "$file" == *.img.xz || "$file" == *.img.zip ]]; then
				IMAGE_LOCATION="$file"
				echo "Found image file: $IMAGE_LOCATION"
				break
			fi
		done
	fi

	echo "Source locations set up: ${SRC_LOCATION}"
}

setup_networking() {
	echo "Setting up networking"
	# TODO: setup ethernet/wifi/nfs based on config.yaml
}

download_image() {
	echo "Downloading image"
	# TODO: implement image writing logic
	# if donwload url is set, download image to temp location
	if [ -n "$DOWNLOAD_URL" ]; then
		# if source location is set, download to there
		if [ -n "$SRC_LOCATION" ]; then
			TEMP_IMAGE="$SRC_LOCATION/$(basename $DOWNLOAD_URL)"
		else
			echo "No source location found, exiting"
			exit 1
		fi
		# if image already exists, skip download
		if [ -f "$TEMP_IMAGE" ]; then
			echo "Image already exists at $TEMP_IMAGE, skipping download"
			IMAGE_LOCATION="$TEMP_IMAGE"
			return
		fi
		echo "Downloading image from $DOWNLOAD_URL"
		wget -O "$TEMP_IMAGE" "$DOWNLOAD_URL"
		IMAGE_LOCATION="$TEMP_IMAGE"
	fi
}

write_image() {
	echo "Writing image to $TARGET_DEV"
	# image is somewhere on a disk at $IMAGE_LOCATION
	if [ -z "$IMAGE_LOCATION" ]; then
		echo "No image location set, exiting"
		exit 1
	fi

	# check if image is compressed
	SIZE=$(stat -c%s "$IMAGE_LOCATION")
	echo "Image size: $SIZE bytes"
	if [[ "$IMAGE_LOCATION" == *.xz ]]; then
		echo "Image is compressed with xz, decompressing and writing to $TARGET_DEV"
		SIZE=$(xz --robot --list "${completepath}" | grep ^totals | cut -f5)
		decompress () {
			xzcat "$IMAGE_LOCATION"
		}
	elif [[ "$IMAGE_LOCATION" == *.gz ]]; then
		SIZE=$(gunzip -l "$IMAGE_LOCATION" | tail -n1 | awk '{print $2}')
		echo "Image is compressed with gzip, decompressing and writing to $TARGET_DEV"
		decompress () {
			gunzip -c "$IMAGE_LOCATION"
		}
	elif [[ "$IMAGE_LOCATION" == *.bz2 ]]; then
		echo "Image is compressed with bzip2, decompressing and writing to $TARGET_DEV"
		decompress () {
			bzcat "$IMAGE_LOCATION"
		}
	elif [[ "$IMAGE_LOCATION" == *.xz.zip ]]; then
		echo "Image is compressed with zip and xz, decompressing and writing to $TARGET_DEV"
		decompress () {
			unzip -p "$IMAGE_LOCATION" | xzcat
		}
	elif [[ "$IMAGE_LOCATION" == *.zip ]]; then
		echo "Image is compressed with zip, decompressing and writing to $TARGET_DEV"
		decompress () {
			unzip -p "$IMAGE_LOCATION"
		}
	elif [[ "$IMAGE_LOCATION" == *.img || "$IMAGE_LOCATION" == *.img.img ]]; then
		echo "Image is uncompressed, writing to $TARGET_DEV"
		decompress () {
			cat "$IMAGE_LOCATION"
		}
	fi

	# write image to emmc with progress and sha256sum
	echo "Writing image to $TARGET_DEV"
	decompress | tee "$TARGET_DEV" | pv | sha256sum > /$SRC_LOCATION/image.sha256sum
	sync
	echo "done!"

}	

write_uboot() {
	echo "Writing u-boot to spi"
	# TODO: implement u-boot writing logic
}

copy_files_to_os() {
	echo "Copying files to OS"
	# TODO: implement file copying logic
}

run_chroot_script() {
	echo "Running chroot script"
	# TODO: implement chroot script execution
}

copy_back_logs() {
	echo "Copying back logs"
	# TODO: implement log copying logic
}

shutdown_system() {
	echo "Shutting down system"
	# TODO: implement shutdown logic
}

main "$@"