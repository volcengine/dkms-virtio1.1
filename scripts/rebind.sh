#!/bin/sh

pcidrv="/sys/bus/pci/drivers/virtio-pci"
v11_pcidrv="/sys/bus/pci/drivers/virtio-pci-v11"
v11_virtiodrv="/sys/bus/virtio-v11/drivers"
kmsg="/dev/kmsg"

do_virtio_device_rebind() {
	driver_1=$1
	driver_2=$2

	echo "rebind virtio driver: $driver_1 $driver_2" >$kmsg

	if [ ! -e $v11_virtiodrv/$driver_1 ]; then
		echo $v11_virtiodrv/$driver_1": No such file or directory" >$kmsg
		return 0
	fi

	if [ ! -e $v11_virtiodrv/$driver_2 ]; then
		echo $v11_virtiodrv/$driver_2": No such file or directory" >$kmsg
		return 0
	fi

	for device in $(find $pcidrv -type l | sort); do
		dev_id=$(readlink -f $device | awk -F"/" '{ print $(NF) }')
		echo "pci id: $dev_id" >$kmsg
		if [ "$dev_id" != "virtio_pci" ]; then
			class=$(cat $device/class)
			if [ "$class" = "0x010000" ] || [ "$class" = "0x020000" ]; then

				echo "rebind device: "$pcidrv/$dev_id >$kmsg
				echo "device class: "$class >$kmsg

				echo $dev_id >$pcidrv/unbind
				echo $dev_id >$v11_pcidrv/bind
			else
				echo "Skip device: $dev_id of class $class" >$kmsg
			fi
		else
			echo "Skip $pcidrv/$dev_id"
		fi
	done
}

_main() {
	(
		flock -xw 5 3 || exit 1
		do_virtio_device_rebind "$@"
	) 3>/var/lock/rebind.lock
}
