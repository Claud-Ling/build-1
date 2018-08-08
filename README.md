tinyDebian
==========

**tinyDebian** consists of bare minimal Bash scripts to build Debian image
from scratch. The generated image can be flashed into a Micro SD card
and boot NanoPi Neo2 arm64 board.

It is encouraged to read these Bash scripts before generating the bootable
sdcard image.

## How to:
1) Use the tool of repo to sync the source code.
2) Change directory to build sub-directory.
3) Run './install_tools.sh" to install the necessary tools.
4) Run './build_u-boot.sh' to build U-Boot.
5) Run './build_kernel.sh' to build Linux Kernel.
6) Run './build_debian.sh bootstrap' to bootstrap Debian image for arm64.
7) Run './gen_sdcard_image.sh' to generate bootable SD-card image.
8) Flash bootable sdcard image to Micro SD card:
   - 8.1) In Windows
   - 8.2) In Mac OS
   - 8.3) In Linux, run command as below, ensure /dev/sdX is Micro SD card:
   -      sudo dd if=../out/sdcard/sdcard.img of=/dev/sdX bs=4M
9) Insert Micro SD card into NanoPi Neo2 then power on to boot.

## Philosophies behind tinyDebian:
-  Simple and bare minimal Bash scripts to build Debian image from scratch.
-  Based on mainline u-boot and kernel.
-  Starting point to be forked for complex project.

## Featured forks:

## Contact:
- email: tech[at]tinydebian[dot]com
