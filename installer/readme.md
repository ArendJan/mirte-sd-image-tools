# Installer system MIRTE

Ventoy like system to automatically install images on a different storage medium.


Source locations:
- installer image:
  - 2 partitions:
    - 1st: install system
    - 2nd: storage for image files
- USB:
  - If inserted: then use this instead of SD 2nd partition
- Ethernet/Wifi:
  - Use NFS or http to download image based on config on installer image.

- Files:
  - .img[.xz][.zip]: any img will be used to flash
    - checksum: if not, then create checksum, used after flashing to check.
  - .uf2: uploaded to pico
  - mirte_user_config.yaml: config
  - mirte_master_config.yaml: config
  - install_script.sh: chrooted on the image after copy to setup files
  - provisioning file: other settings, copied to the provisioning partition.




## SD image
- 1st partition: armbi_root
- 2nd partition: exfat, images

## USB:
- img partition: exfat/nfts/fat/... 



## Check
- can installer also be put on USB (is USB bootable by UBoot or check in OS to boot different disk)
- 