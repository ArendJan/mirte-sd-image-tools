#!/bin/bash
set -xe
set -o pipefail
image_url=$1
image_checksum=$2
image_name=$3

mkdir git_local || true
mkdir workdir || true
mkdir logs || true
mkdir build || true
sudo packer build -var "image_url=$image_url" -var "image_checksum=$image_checksum" -var "image_name=$image_name" build_params.pkr.hcl | tee logs/log-"$(date +"%Y-%m-%d %H:%M:%S")".txt logs/current_log.txt

./scripts/finalize.sh "$(realpath "./workdir/$image_name.img")"
set +o pipefail
