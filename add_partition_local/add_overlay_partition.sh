#!/bin/bash
set -ex

image_file=$1
parent_path=$(
	cd "$(dirname "${BASH_SOURCE[0]}")"
	pwd -P
)

add_partition() {
	startLocation=$(sfdisk -l -o end -N1 "$image_file" | tail -1)
	# should be 40960 for zero2, 8192 for zero1

	extraSize="1G"
    startLocation=$((startLocation + 1))
	dd if=/dev/zero bs=1M count=1024 >>"$image_file"
	# echo "+$extraSize" | sfdisk --move-data -N 1 "$image_file"
	echo "$startLocation, $extraSize" | sfdisk -a "$image_file"
	sleep 5
	loop=$(kpartx -av "$image_file")
	echo $loop
	loopvar=$(echo $loop | grep -oP 'loop[0-9]*' | head -1)
	echo $loopvar
	mkfs.ext4 /dev/mapper/${loopvar}p2 -L "mirte_root"
	sleep 5
	kpartx -dv /dev/${loopvar}
}

if sfdisk -l "$image_file" | grep -q '.img2'; then
	echo "Already contains extra partition, only copying default files"
else
	add_partition
fi

$parent_path/../pishrink.sh "$image_file"

echo "done"
