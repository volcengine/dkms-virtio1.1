#!/bin/bash

set -x

curdir=$(pwd)
LSB_UBUNTU_18_04=$(lsb_release -d | grep -ie "Ubuntu 18.04")
KERNEL_4_18_05=$(uname -r | grep -ie "4.18.5")

dpkg -i $curdir/*.deb
if [[ $? -ne 0 ]]; then
	exit 0
fi

echo virtio_v11 >>/etc/initramfs-tools/modules
echo virtio_ring_v11 >>/etc/initramfs-tools/modules
echo virtio_pci_v11 >>/etc/initramfs-tools/modules

if [[ -n "$LSB_UBUNTU_18_04" || -n "$KERNEL_4_18_05" ]]; then
	echo virtio_net >>/etc/initramfs-tools/modules
	echo virtio_blk >>/etc/initramfs-tools/modules
	echo "_main \"virtio_net\" \"virtio_blk\"" >>$curdir/rebind.sh
else
	echo virtio_net_v11 >>/etc/initramfs-tools/modules
	echo virtio_blk_v11 >>/etc/initramfs-tools/modules
	echo "_main \"virtio_net_v11\" \"virtio_blk_v11\"" >>$curdir/rebind.sh
fi

cp $curdir/rebind.sh /etc/initramfs-tools/scripts/init-premount/ -f
cp $curdir/flock /usr/share/initramfs-tools/hooks -f

depmod
update-initramfs -u
