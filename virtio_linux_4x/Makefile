# SPDX-License-Identifier: GPL-2.0
kernelver ?= $(shell uname -r)
SUB_KERNEL_VER ?= $(shell echo $(kernelver) |awk -F "." '{print $$2}')
obj-$(CONFIG_VIRTIO) += virtio.o virtio_ring.o
obj-$(CONFIG_VIRTIO_MMIO) += virtio_mmio.o
obj-$(CONFIG_VIRTIO_PCI) += virtio_pci.o
virtio_pci-y := virtio_pci_modern.o virtio_pci_common.o
virtio_pci-$(CONFIG_VIRTIO_PCI_LEGACY) += virtio_pci_legacy.o
obj-$(CONFIG_VIRTIO_BALLOON) += virtio_balloon.o
obj-$(CONFIG_VIRTIO_INPUT) += virtio_input.o

# 4.14 kernel add virtio_net for ethtool to get network stats
ifeq ("$(SUB_KERNEL_VER)","14")
	obj-m += virtio_net.o
endif

all:
	$(MAKE) -C /lib/modules/$(kernelver)/build M=$(CURDIR) modules

clean:
	$(MAKE) -C /lib/modules/$(kernelver)/build M=$(CURDIR) clean
