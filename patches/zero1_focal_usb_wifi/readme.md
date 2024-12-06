Armbian for zero1 focal 5.4 had wifi mac issues

armbian self-compiled 6.6 had usb (libcomposite issues)

6.11 had wifi issues. 

How fixed:
- use 6.11 armbian
- change file lib/functions/compilation/patch/drivers_network.sh
  - remove part of the condition such that it always is true and adds parts for xradio (systemd stuff)
  - example: `if linux-version compare "${version}" ge 4.19; then`
- copy patch for usb_otg to userpatches/kernel/archive/sunxi-6.11/fix_test_kernel.patch (this changes dr_mode=peripheral to =otg)
- compile
- compile https://github.com/fifteenhex/xradio with path to 6.11 (pre-compiled in this folder from 14f9b94581669b7f24d7639adcdcd2f9b7a58f70) (if the pull request is merged)
  - make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -C ../sources/linux-kernel-worktree/6.11__sunxi__armhf M=$PWD modules
- copy to /lib/modules/..../ folder
- depmod
  - if running chroot `depmod <kernel folder>`