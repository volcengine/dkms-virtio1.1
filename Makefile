# SPDX-License-Identifier: GPL-2.0
LSB_UBUNTU_1604=$(shell lsb_release -d | grep -ie "Ubuntu 16.04")
LSB_UBUNTU_1804=$(shell lsb_release -d | grep -ie "Ubuntu 18.04")
LSB_CENTOS=$(shell lsb_release -d | grep -ie "CentOS")

ifneq ("$(LSB_UBUNTU_1604)","")
	SRCDIR=virtio_ubuntu/virtio_ubuntu-16.04
else ifneq ("$(LSB_UBUNTU_1804)","")
	SRCDIR=virtio_ubuntu/virtio_ubuntu-18.04
else ifneq ("$(LSB_CENTOS)","")
	kernelver ?= $(shell uname -r)

	# the kernel of 7.6
	ifeq ($(findstring 957,$(kernelver)),957)
		SRCDIR=virtio_centos/virtio_centos-7.6-7.7
	# the kernel of 7.7
	else ifeq ($(findstring 1062,$(kernelver)),1062)
		SRCDIR=virtio_centos/virtio_centos-7.6-7.7
	else
		SRCDIR=virtio_centos/virtio_centos-7.8-7.9
	endif
else
	SRCDIR=virtio_linux_4x
endif

$(info srcdir:$(SRCDIR) lsb_ver:$(shell lsb_release -ds))

all:
	make -C $(SRCDIR)
	cp $(SRCDIR)/*.ko ./

clean:
	make -C $(SRCDIR) clean
	rm -rf *.ko

