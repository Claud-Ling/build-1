#!/bin/bash

# Note:
# - root priviledge is needed for losetup and accessing loop device /dev/loopx
# - generated bootable sdcard image is ../out/sdcard/sdcard.img
# - "sudo dd if=sdcard.img of=/dev/sdX bs=4M && sync" to write image to sdcard
#   note: replace /dev/sdX with correct device for sdcard
#
# Can use commands similar to below (may not be exact) to check:
# $ sudo apt install kpartx
# $ sudo kpartx -av sdcard.img
# $ sudo mount /dev/mapper/loop1p2 temp
# $ sudo umount temp/
# $ sudo kpartx -d sdcard.img
#
# sdcard layout for 1024MiB sdcard:
# 16MiB:   MBR + U-Boot
# 40MiB:   boot partition
# 968MiB:  rootfs partition

# Pre-requisite:
# Need to build below first:
# - run ./build_u-boot.sh to build U-Boot
# - run ./build kernel.sh to build kernel
# - run ./build_debian.sh to build rootfs

set -e

readonly CUR_DIR=`pwd`
readonly OUT_DIR=`pwd`/../out
readonly TARGET_DIR=$OUT_DIR/sdcard

readonly BOOT_IMG=$TARGET_DIR/boot.img
readonly ROOTFS_IMG=$TARGET_DIR/rootfs.img
readonly SDCARD_IMG=$TARGET_DIR/sdcard.img

gen_boot_part() {
	local loop_dev

	echo
	echo "--- Generating boot partition ..."
	echo

	rm -f $BOOT_IMG

	dd if=/dev/zero of=$BOOT_IMG bs=1M count=40
	loop_dev=`sudo losetup --find --show $BOOT_IMG`
	echo "--- loop_dev = $loop_dev"
	sudo mkfs.fat -F 16 -n "BOOT" $loop_dev

	mkdir -p $TARGET_DIR/boot
	sudo mount $loop_dev $TARGET_DIR/boot/

	# copy kernel + device tree
	sudo cp $OUT_DIR/kernel/Image                     $TARGET_DIR/boot/
	sudo cp $OUT_DIR/kernel/sun50i-h5-nanopi-neo2.dtb $TARGET_DIR/boot/
	# copy boot.scr
	sudo cp $OUT_DIR/u-boot/boot.scr                  $TARGET_DIR/boot/

	sync
	sudo umount $TARGET_DIR/boot/
	sudo losetup --detach $loop_dev
	sudo rm -rf $TARGET_DIR/boot/
}

gen_rootfs_part() {
	local loop_dev

	echo
	echo "--- Generating rootfs partition ..."
	echo

	rm -f $ROOTFS_IMG

	dd if=/dev/zero of=$ROOTFS_IMG bs=1M count=968
	loop_dev=`sudo losetup --find --show $ROOTFS_IMG`
	echo "--- loop_dev = $loop_dev"
	sudo mkfs.ext4 -F -L "ROOTFS" $loop_dev

	mkdir -p $TARGET_DIR/rootfs
	sudo mount $loop_dev $TARGET_DIR/rootfs/

	# copy debian rootfs
	sudo cp -a $OUT_DIR/debian_rootfs/* $TARGET_DIR/rootfs/
	# copy kernel modules
	sudo cp -a $OUT_DIR/kernel/lib      $TARGET_DIR/rootfs/

	sync
	sudo umount $TARGET_DIR/rootfs/
	sudo losetup --detach $loop_dev
	sudo rm -rf $TARGET_DIR/rootfs/
}

gen_sdcard() {
	local loop_dev

	echo
	echo "--- Generating 1GiB sdcard image ..."
	echo

	rm -f $SDCARD_IMG $SDCARD_IMG.md5

	# clear possible residual MBR
	dd if=/dev/zero of=$SDCARD_IMG count=1 bs=512
	# allocate space
	fallocate -l 1G $SDCARD_IMG

	# set MBR partition style
	parted --script $SDCARD_IMG mklabel msdos

	# BOOT partition
	parted -a optimal --script $SDCARD_IMG mkpart primary fat32 16MiB 56MiB
	# ROOTFS partition
	parted -a optimal --script $SDCARD_IMG mkpart primary ext4 56MiB 100%

	# make BOOT partition bootable
	parted --script $SDCARD_IMG set 1 boot on

	# copy u-boot
	loop_dev=`sudo losetup --find --show $SDCARD_IMG`
	sudo dd if=$OUT_DIR/u-boot/sunxi-spl.bin of=$loop_dev bs=1K seek=8
	sudo dd if=$OUT_DIR/u-boot/u-boot.itb    of=$loop_dev bs=1K seek=40

	# write BOOT partition
	sudo dd if=$BOOT_IMG   of=$loop_dev bs=1M seek=16
	# write ROOTFS partition
	sudo dd if=$ROOTFS_IMG of=$loop_dev bs=1M seek=56

	sync
	sudo losetup --detach $loop_dev

	md5sum $SDCARD_IMG > $SDCARD_IMG.md5
}

mkdir -p $OUT_DIR
mkdir -p $TARGET_DIR

gen_boot_part
gen_rootfs_part
gen_sdcard

exit 0
