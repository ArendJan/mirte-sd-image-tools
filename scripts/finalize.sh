#!/bin/bash
. ./settings.sh
imagefile=$1
if $INSTALL_PROVISIONING; then
	sudo ./add_partition_local/add_partition.sh $imagefile
fi
sudo ./add_partition_local/add_overlay_partition.sh $imagefile
sudo ./pishrink.sh $imagefile || true
filename=$(basename $imagefile .img)
newImageFile="build/${filename}_$(date +"%Y-%m-%d_%H_%M_%S").img"
echo "copying to $newImageFile"
sudo cp "$imagefile" "$newImageFile"
echo "zipping"
xz -T0 --keep -v "$newImageFile" || true
ls -alh build/
sha256sum build/*
