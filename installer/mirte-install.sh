#!/bin/bash

EMMC_DEV=/dev/mmcblk0
IMAGE=/root/mirte_orangepi3b.img
# This script is used to install the Mirte image onto the emmc.
picotool load -f /root/Telemetrix4RpiPico.uf2
picotool reboot -f
/root/set-text.sh "Mirte image installation started"
# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	/root/set-text.sh "Please run as root"
	exit
fi

# check image exists
if [ ! -f $IMAGE ]; then
	echo "$IMAGE not found"
	/root/set-text.sh "$IMAGE not found"
	exit
fi

# check if the emmc exists
if [ ! -b $EMMC_DEV ]; then
	echo "emmc not found"
	/root/set-text.sh "emmc not found"
	exit
fi

# write the image to the emmc
echo "Writing $IMAGE to $EMMC_DEV"
/root/set-text.sh "Writing $IMAGE to $EMMC_DEV"

# start while loop in background, store pid
while true; do
	sleep 1
	NEWLINE=$'\n'
	/root/set-text.sh "Writing $IMAGE to $EMMC_DEV${NEWLINE}$(progress)"

done &
PID=$!

# dd if=$IMAGE of=$EMMC_DEV bs=4M status=progress
cat $IMAGE >$EMMC_DEV
# sync
sync
# kill the while loop
kill $PID
/root/set-text.sh "Mirte image written to $EMMC_DEV"
sleep 10
/root/set-text.sh "Verifying image"
# check if the image was written successfully by using checksum
echo "Verifying $IMAGE"
head -c "$(stat -c %s $IMAGE)" $EMMC_DEV | md5sum -c $IMAGE.md5sum

# check return code
if [ $? -eq 0 ]; then
	/root/set-text.sh "Mirte image installed successfully"
	echo "Mirte image installed successfully"
else
	/root/set-text.sh "Mirte image installation failed"
	echo "Mirte image installation failed"
fi
sleep 10
/root/set-text.sh "Installing u-boot to spi"
source /usr/lib/u-boot/platform_install.sh
write_uboot_platform_mtd $DIR /dev/mtdblock0
/root/set-text.sh "Done installing, shutting down!"

shutdown