# create rootfs with some extra installed packages

- run packerInstall.sh from root dir or install packer by hand + sudo packer init addDebs.prk.hcl
- run sudo packer build -only=arm-image.mirte_orangepizero_jammy addDebs.pkr.hcl (sudo required for mounting and stuff)
- output will be in workdir/mirte_orangepizero_with_debs.img
- Add any command to addDebs.sh or addDebs.pkr.hcl

- addDebs.pkr.hcl will download the image from surfdrive, store in /root/.cache/packer/..., copy to workdir, expand to desired size, mount it to /tmp/armimg-XXX, copy the scripts folder and start addDebs.sh