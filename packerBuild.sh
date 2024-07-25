#!/bin/bash
set -xe
set -o pipefail

only_flags=""
if (($# > 0)); then
	only_flags="--only virtualbox-iso.$1"
fi
echo virtualbox-ext-pack virtualbox-ext-pack/license select true | sudo debconf-set-selections
wget https://dl.armbian.com/uefi-arm64/archive/Armbian_24.5.1_Uefi-arm64_jammy_current_6.6.31.img.xz
unzip Armbian_24.5.1_Uefi-arm64_jammy_current_6.6.31.img.xz
mv Armbian_24.5.1_Uefi-arm64_jammy_current_6.6.31.img /tmp/armbianx64.iso
sudo apt install virtualbox virtualbox-ext-pack -y

mkdir git_local || true
mkdir workdir || true
mkdir logs || true
mkdir build || true
sudo packer build $only_flags build.pkr.hcl | tee logs/log-"$(date +"%Y-%m-%d %H:%M:%S")".txt logs/current_log.txt

if (($# > 0)); then
	./scripts/finalize.sh "$(realpath "./workdir/$1.img")"
else

	# ./scripts/finalize.sh "$(realpath "./workdir/mirte_orangepizero.img")" & # not default type
	./scripts/finalize.sh "$(realpath "./workdir/mirte_orangepizero2.img")" &
	./scripts/finalize.sh "$(realpath "./workdir/mirte_orangepi3b.img")" &
	./scripts/finalize.sh "$(realpath "./workdir/mirte_rpi4b.img")" &
	wait
fi
set +o pipefail
