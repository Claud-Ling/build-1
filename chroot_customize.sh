#!/bin/sh

##############################
# we are inside chroot

set -e

install_packages() {
	apt update
	apt -y install openssh-server net-tools resolvconf
}

customize_debian() {
	# configure network
	cat << EOT > /etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
auto lo
iface lo inet loopback
source-directory /etc/network/interfaces.d
EOT

	cat << EOT > /etc/network/interfaces.d/eth0
allow-hotplug eth0
iface eth0 inet dhcp
EOT

	cat << EOT > /etc/resolv.conf
nameserver 8.8.8.8
# For China only
nameserver 114.114.114.114
EOT

	# Debian9 strech: enable ssh root login
	sed -i 's/\#PermitRootLogin prohibit\-password/PermitRootLogin yes/' /etc/ssh/sshd_config
	# Debian 8 jessie: enable ssh root login
	#sed -i 's/PermitRootLogin without\-password/PermitRootLogin yes/' /etc/ssh/sshd_config

	echo tinyDebian > /etc/hostname

	echo root:tinyDebian | chpasswd

	# misc
	echo "" >> /root/.bashrc
	echo "alias ll='ls -alF'"  >> /root/.bashrc
}

install_packages
customize_debian

# exit chroot
exit 0
