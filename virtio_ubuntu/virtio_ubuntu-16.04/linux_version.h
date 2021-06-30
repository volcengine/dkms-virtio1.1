// SPDX-License-Identifier: GPL-2.0
#ifndef _DRIVERS_VIRTIO_LINUX_VERSION_H
#define _DRIVERS_VIRTIO_LINUX_VERSION_H

#ifndef LINUX_VERSION_CODE
#include <linux/version.h>
#else
#define KERNEL_VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))
#endif

#endif

