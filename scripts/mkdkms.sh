#!/bin/bash

pkg=virtio
version=1.1.0
uspath=/usr/src/$pkg-$version
curdir=$(pwd)

if [[ $curdir -ef $uspath ]]; then
	echo "Error: cannot run this script under path:" $curdir
	exit 1
fi

KVERSION=$(uname -r | awk -F "." '{print $1}')
SUB_KVERSION=$(uname -r | awk -F "." '{print $2}')
LSB_CENTOS=$(lsb_release -d | grep -i "CentOS")
LSB_UBUNTU_1804=$(lsb_release -d | grep -ie "Ubuntu 18.04")
LSB_UBUNTU_1604=$(lsb_release -d | grep -ie "Ubuntu 16.04")

if [[ -n "$LSB_UBUNTU_1604" ]]; then
	cat >dkms.conf <<-EOF
		PACKAGE_NAME="virtio"
		PACKAGE_VERSION="1.1.0"
		BUILT_MODULE_NAME[0]="virtio_net_v11"
		DEST_MODULE_LOCATION[0]="/kernel/drivers/net"
		BUILT_MODULE_NAME[1]="virtio_blk_v11"
		DEST_MODULE_LOCATION[1]="/kernel/drivers/block"
		BUILT_MODULE_NAME[2]="virtio_v11"
		DEST_MODULE_LOCATION[2]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[3]="virtio_ring_v11"
		DEST_MODULE_LOCATION[3]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[4]="virtio_pci_v11"
		DEST_MODULE_LOCATION[4]="/kernel/drivers/virtio"
		AUTOINSTALL="yes"
		CLEAN="make clean"
		MAKE="kernelver=\${kernelver} make all"
		REMAKE_INITRD="yes"
	EOF
elif [[ -n "$LSB_UBUNTU_1804" ]]; then
	cat >dkms.conf <<-EOF
		PACKAGE_NAME="virtio"
		PACKAGE_VERSION="1.1.0"
		BUILT_MODULE_NAME[0]="virtio_net"
		DEST_MODULE_LOCATION[0]="/kernel/drivers/net"
		BUILT_MODULE_NAME[1]="virtio_blk"
		DEST_MODULE_LOCATION[1]="/kernel/drivers/block"
		BUILT_MODULE_NAME[2]="virtio_v11"
		DEST_MODULE_LOCATION[2]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[3]="virtio_ring_v11"
		DEST_MODULE_LOCATION[3]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[4]="virtio_pci_v11"
		DEST_MODULE_LOCATION[4]="/kernel/drivers/virtio"
		AUTOINSTALL="yes"
		CLEAN="make clean"
		MAKE="kernelver=\${kernelver} make all"
		REMAKE_INITRD="yes"
	EOF
elif [[ $KVERSION == "3" ]]; then
	cat >dkms.conf <<-EOF
		PACKAGE_NAME="virtio"
		PACKAGE_VERSION="1.1.0"
		BUILT_MODULE_NAME[0]="virtio"
		DEST_MODULE_LOCATION[0]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[1]="virtio_ring"
		DEST_MODULE_LOCATION[1]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[2]="virtio_pci"
		DEST_MODULE_LOCATION[2]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[3]="virtio_balloon"
		DEST_MODULE_LOCATION[3]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[4]="virtio_input"
		DEST_MODULE_LOCATION[4]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[5]="virtio_net"
		DEST_MODULE_LOCATION[5]="/kernel/drivers/net"
		AUTOINSTALL="yes"
		CLEAN="make clean"
		MAKE="kernelver=\${kernelver} make all"
		REMAKE_INITRD="yes"
	EOF
elif [[ $SUB_KVERSION == "14" ]]; then
	cat >dkms.conf <<-EOF
		PACKAGE_NAME="virtio"
		PACKAGE_VERSION="1.1.0"
		BUILT_MODULE_NAME[0]="virtio"
		DEST_MODULE_LOCATION[0]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[1]="virtio_ring"
		DEST_MODULE_LOCATION[1]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[2]="virtio_pci"
		DEST_MODULE_LOCATION[2]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[3]="virtio_balloon"
		DEST_MODULE_LOCATION[3]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[4]="virtio_input"
		DEST_MODULE_LOCATION[4]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[5]="virtio_net"
		DEST_MODULE_LOCATION[5]="/kernel/drivers/net"
		AUTOINSTALL="yes"
		CLEAN="make clean"
		MAKE="kernelver=\${kernelver} make all"
		REMAKE_INITRD="yes"
	EOF
else
	cat >dkms.conf <<-EOF
		PACKAGE_NAME="virtio"
		PACKAGE_VERSION="1.1.0"
		BUILT_MODULE_NAME[0]="virtio"
		DEST_MODULE_LOCATION[0]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[1]="virtio_ring"
		DEST_MODULE_LOCATION[1]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[2]="virtio_pci"
		DEST_MODULE_LOCATION[2]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[3]="virtio_balloon"
		DEST_MODULE_LOCATION[3]="/kernel/drivers/virtio"
		BUILT_MODULE_NAME[4]="virtio_input"
		DEST_MODULE_LOCATION[4]="/kernel/drivers/virtio"
		AUTOINSTALL="yes"
		CLEAN="make clean"
		MAKE="kernelver=\${kernelver} make all"
		REMAKE_INITRD="yes"
	EOF
fi

rm -rf $uspath
mkdir -p $uspath
rsync -rv --exclude=release * $uspath

dkms add $pkg/$version $uspath

if [[ -n "$LSB_CENTOS" ]]; then
	dkms mkrpm $pkg/$version -k $(uname -r)/amd64 --source-only
	LSB_CENTOS=$(lsb_release -d | grep -E "7.6|7.7")
	if [[ x$LSB_CENTOS != x ]]; then
		cp /var/lib/dkms/$pkg/$version/rpm/*.noarch.rpm ./virtio_centos-7.6-7.7-v11.noarch.rpm -f
	else
		cp /var/lib/dkms/$pkg/$version/rpm/*.noarch.rpm ./virtio_centos-7.8-7.9-v11.noarch.rpm -f
	fi
else
	if [[ -z "$LSB_UBUNTU_1804" && -z "$LSB_UBUNTU_1604" ]]; then
		dkms mkdeb $pkg/$version -k $(uname -r)/amd64 --source-only
		cp /var/lib/dkms/$pkg/$version/deb/*.deb ./ -f
	else
		if [[ -n "$LSB_UBUNTU_1804" ]]; then
			srcdir="virtio_ubuntu/virtio_ubuntu-18.04"
			outdir="virtio_ubuntu-18.04-v11"
		else
			srcdir="virtio_ubuntu/virtio_ubuntu-16.04"
			outdir="virtio_ubuntu-16.04-kernel-4.4-v11"

			KERNEL_4_18_05=$(uname -r | grep -ie "4.18.5")
			if [[ -n "$KERNEL_4_18_05" ]]; then
				outdir="virtio_ubuntu-16.04-kernel-4.18-v11"
				cp -rf $srcdir/$(uname -r)/* $srcdir/
			fi
		fi

		dkms mkdeb $pkg/$version -k $(uname -r)/amd64 --source-only
		if [[ -e $outdir ]]; then
			rm -rf $outdir
		fi
		mkdir $outdir

		cp /var/lib/dkms/$pkg/$version/deb/*.deb $outdir -f
		cp $curdir/scripts/rebind.sh $outdir -f
		cp $curdir/scripts/install.sh $outdir -f
		cp $curdir/scripts/flock $outdir -f
		tar -cvf ${outdir}.tar $outdir
		rm -rf $outdir
	fi
fi

dkms remove $pkg/$version --all
