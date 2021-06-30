# SPDX-License-Identifier: GPL-2.0
CONFIG_MODULE_SIG=n
obj-m += virtio_v11.o virtio_ring_v11.o
virtio_v11-y:= virtio.o
virtio_ring_v11-y:=virtio_ring.o
obj-m += virtio_pci_v11.o
virtio_pci_v11-y := virtio_pci_modern.o virtio_pci_common.o
virtio_pci_v11-y += virtio_pci_legacy.o
obj-m += virtio_net.o
obj-m += virtio_blk.o

kernelver ?= $(shell uname -r)

all:
	$(MAKE) -C /lib/modules/$(kernelver)/build M=$(CURDIR) modules

clean:
	$(MAKE) -C /lib/modules/$(kernelver)/build M=$(CURDIR) clean
