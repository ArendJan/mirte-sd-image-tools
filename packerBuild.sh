#!/bin/bash
set -xe
set -o pipefail

only_flags=""
if (($# > 0)); then
	only_flags="--only virtualbox-iso.$1"
fi
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
