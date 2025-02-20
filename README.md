# Build Mirte image using Packer
 
## Install
run sudo `./packerInstall.sh` to download required packages.

## Build
Run sudo `./packerBuild.sh` to build the image. Will take some time
Put your local files in `git_local/` and they will be copied
edit `settings.sh` to select features and extra scripts and edit `repos.yaml` to select the repositories/branches.

## Build as workflow in Docker
Install [act](https://github.com/nektos/act) and run `./actBuild.sh`. It will run the workflows and copy the artifacts to `./artifacts/`. This will not use any changes in git_local or repos.yaml.

## Shell to edit
run ./shell.sh \<img file> and you will get a shell after some time. You can create new shells by using `sudo chroot /tmp/armimg-XXX`. Stop by removing the `/stopshell` file. It will create your fresh image in `shell_workdir`.

# /bin/sh Exec format error:
```sh
sudo apt remove qemu-user-static -y && sudo apt install qemu-user-static
```

# VCS issues:
When you get 
```
=== ./mirte-arduino-libraries (git) ===
    arm-image.mirte_orangepizero: Could not clone repository 'https://github.com/arendjan/mirte-arduino-libraries.git': fatal: destination path '.' already exists and is not an empty directory.
```
when building for orange pi Zero (1), you have a qemu version that has some issues, including a ``` qemu: uncaught target signal 11 (segmentation fault) - core dumped``` when using git. Update the qemu installation on your host computer by adding a ppa ( ```sh sudo add-apt-repository ppa:canonical-server/server-backports```) and updating qemu. This should resolve the issues.

# TODOS:
- npm prebuilt

# Editing the latest build
Install gh or download from releases.
```
gh run download #select type
sudo ./shell.sh ...
# at end, exit out of the chroot
# output in shell_workdir/....shrunk_$date.img.xz
```