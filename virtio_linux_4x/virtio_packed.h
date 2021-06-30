// SPDX-License-Identifier: GPL-2.0
#ifndef _DRIVERS_VIRTIO_PACKED_H
#define _DRIVERS_VIRTIO_PACKED_H

#include "linux_version.h"

/* This feature indicates support for the packed virtqueue layout. */
#define VIRTIO_F_RING_PACKED		34
/*
+ * This feature indicates that memory accesses by the driver and the
+ * device are ordered in a way described by the platform.
+ */
#ifndef VIRTIO_F_ORDER_PLATFORM
#define VIRTIO_F_ORDER_PLATFORM		36
#endif

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4, 18, 0)
#define V11_VIRTIO_TRANSPORT_F_END      VIRTIO_TRANSPORT_F_END
#else
#define V11_VIRTIO_TRANSPORT_F_END      38
#endif

/*
 * Mark a descriptor as available or used in packed ring.
 * Notice: they are defined as shifts instead of shifted values.
 */
#define VRING_PACKED_DESC_F_AVAIL	7
#define VRING_PACKED_DESC_F_USED	15

/* Enable events in packed ring. */
#define VRING_PACKED_EVENT_FLAG_ENABLE	0x0
/* Disable events in packed ring. */
#define VRING_PACKED_EVENT_FLAG_DISABLE	0x1
/*
 * Enable events for a specific descriptor in packed ring.
 * (as specified by Descriptor Ring Change Event Offset/Wrap Counter).
 * Only valid if VIRTIO_RING_F_EVENT_IDX has been negotiated.
 */
#define VRING_PACKED_EVENT_FLAG_DESC	0x2

/*
 * Wrap counter bit shift in event suppression structure
 * of packed ring.
 */
#define VRING_PACKED_EVENT_F_WRAP_CTR	15

struct vring_packed_desc_event {
	/* Descriptor Ring Change Event Offset/Wrap Counter. */
	__le16 off_wrap;
	/* Descriptor Ring Change Event Flags. */
	__le16 flags;
};

struct vring_packed_desc {
	/* Buffer Address. */
	__le64 addr;
	/* Buffer Length. */
	__le32 len;
	/* Buffer ID. */
	__le16 id;
	/* The flags depending on descriptor type. */
	__le16 flags;
};

struct vring_packed {
	unsigned int num;

	struct vring_packed_desc *desc;

	struct vring_packed_desc_event *driver;

	struct vring_packed_desc_event *device;
};

#endif
