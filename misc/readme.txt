####################################################################################
On boot, U-Boot looks for a file called boot.scr which it will try to run.

Users can create such a script to do boot time configuration of the board,
do low-level testing, or set up the U-Boot environment.

The boot.cmd is a plaintext file that can be converted to boot.scr
by adding the required header to it using mkimage utility:

mkimage -C none -A arm -T script -d boot.cmd boot.scr

