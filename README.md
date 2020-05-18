## Prerequisites

You need singularity container >=2.3. On Ubuntu (16.10+):
   ```
   $ sudo apt install singularity-container
   ```

For other versions of Ubuntu you can follow the installation guide on the [Singularity website](https://sylabs.io/guides/3.0/user-guide/installation.html#install-the-debian-ubuntu-package-using-apt).

## Installing the image builder

1. Clone this repository
   ```
   $ git clone https://gitlab.tudelft.nl/rcj_zoef/zoef_sd_card_image
   ```
2. Install the sigularity image
   ```
   $ cd /zoef_sd_card_image
   $ sudo ./install.sh
   ```

## Generating the Zoef SD image

1. Create the sd card image (this will take some time) (NOTE: this will overwrite existing images)
   ```
   $ sudo ./run.sh build_sd_card
   ```
2. This will generate a zoef_sd.img in the current directory
3. Use an image burning tool (e.g. dd or etcher ([link](https://www.balena.io/etcher/)) to burn it to an SD card

## Generating an SD card image using branches of Zoef repos

1. In the repository folder create a file called repos.yaml.
   ```
   $ nano repos.yaml
   ```
2. This yaml format used is the same as [vcstool](https://github.com/dirk-thomas/vcstool). The example below will create an image with the my_branch branch of the Zoef web_interface repository. For an overview of all the repositories used, have a look at the version in [install_scripts](https://gitlab.tudelft.nl/rcj_zoef/zoef_install_scripts/blob/master/repos.yaml).
```yaml
repositories:
  web_interface:
    type: git
    url: https://gitlab.tudelft.nl/rcj_zoef/web_interface
    version: my_branch
```

3. Create the sd card image (this will take some time) (NOTE: this will overwrite existing images)
   ```
   $ sudo ./run.sh build_sd_card
   ```

## (For Developer) Generating an SD card image using a local repository

1. Make sure you have one or more local repositories in <zoef_sd_card_image>/git_local/.

```bash
.
├── git_local
│   └── zoef_install_scripts
```

2. Now create (or use an existing) repos.yaml, but now use another url by prepeding "/working_dir/" as can be seen in the example below. Please note that this will checkout the branch mentioned, so you need to commit changes to that branch.

```yaml
repositories:
  zoef_install_scripts:
    type: git
    url: /working_dir/git_local/zoef_install_scripts
    version: master
```

3. Create the sd card image (this will take some time) (NOTE: this will overwrite existing images)
   ```
   $ sudo ./run.sh build_sd_card
   ```

## (For Developer) Generating an SD card image using modifications made on a Zoef robot


## (For Developer) Run clean Armbian image on non ARM machine

1. Start an ARM shell
   ```
   $ sudo ./run.sh shell
   ```
2. You can now run commands as if it was on ARM
   ```
   $ uname -a
   ```

## (For Developer) Run created Armbian image on non ARM machine
1. Make sure you have a Zoef image called zoef_sd.img in the repository directory

2. Start an ARM shell
   ```
   $ sudo ./run.sh shell_local
   ```
3. You can now find all zoef repositories in /usr/local/src/zoef
   ```
   $ ls /usr/local/src/zoef
   ```
