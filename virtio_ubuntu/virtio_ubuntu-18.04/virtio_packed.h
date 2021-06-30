// SPDX-License-Identifier: GPL-2.0
#ifndef _DRIVERS_VIRTIO_PACKED_H
#define _DRIVERS_VIRTIO_PACKED_H

#include <linux/types.h>
#include <linux/scatterlist.h>
#include <linux/spinlock.h>
#include <linux/device.h>
#include <linux/mod_devicetable.h>
#include <linux/gfp.h>
#include <linux/vringh.h>
#include <linux/irqreturn.h>
#include <uapi/linux/virtio_ring.h>
#include "linux_version.h"

/* This feature indicates support for the packed virtqueue layout. */
#define VIRTIO_F_RING_PACKED		34
/*
 * This feature indicates that memory accesses by the driver and the
 * device are ordered in a way described by the platform.
 */
#ifndef VIRTIO_F_ORDER_PLATFORM
#define VIRTIO_F_ORDER_PLATFORM		36
#endif

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4, 18, 0)
#define V11_VIRTIO_TRANSPORT_F_END	VIRTIO_TRANSPORT_F_END
#else
#define V11_VIRTIO_TRANSPORT_F_END	38
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

/*
 * Creates a virtqueue and allocates the descriptor ring.  If
 * may_reduce_num is set, then this may allocate a smaller ring than
 * expected.  The caller should query v11_virtqueue_get_vring_size to learn
 * the actual size of the ring.
 */
struct virtqueue *v11_vring_create_virtqueue(unsigned int index,
					 unsigned int num,
					 unsigned int vring_align,
					 struct virtio_device *vdev,
					 bool weak_barriers,
					 bool may_reduce_num,
					 bool ctx,
					 bool (*notify)(struct virtqueue *vq),
					 void (*callback)(struct virtqueue *vq),
					 const char *name);

/* Creates a virtqueue with a custom layout. */
struct virtqueue *__v11_vring_new_virtqueue(unsigned int index,
					struct vring vring,
					struct virtio_device *vdev,
					bool weak_barriers,
					bool ctx,
					bool (*notify)(struct virtqueue *),
					void (*callback)(struct virtqueue *),
					const char *name);

/*
 * Creates a virtqueue with a standard layout but a caller-allocated
 * ring.
 */
struct virtqueue *v11_vring_new_virtqueue(unsigned int index,
				      unsigned int num,
				      unsigned int vring_align,
				      struct virtio_device *vdev,
				      bool weak_barriers,
				      bool ctx,
				      void *pages,
				      bool (*notify)(struct virtqueue *vq),
				      void (*callback)(struct virtqueue *vq),
				      const char *name);

/*
 * Destroys a virtqueue.  If created with vring_create_virtqueue, this
 * also frees the ring.
 */
void v11_vring_del_virtqueue(struct virtqueue *vq);

/* Filter out transport-specific feature bits. */
void v11_vring_transport_features(struct virtio_device *vdev);

irqreturn_t v11_vring_interrupt(int irq, void *_vq);

int v11_virtqueue_add_outbuf(struct virtqueue *vq,
			 struct scatterlist sg[], unsigned int num,
			 void *data,
			 gfp_t gfp);

int v11_virtqueue_add_inbuf(struct virtqueue *vq,
			struct scatterlist sg[], unsigned int num,
			void *data,
			gfp_t gfp);

int v11_virtqueue_add_inbuf_ctx(struct virtqueue *vq,
			    struct scatterlist sg[], unsigned int num,
			    void *data,
			    void *ctx,
			    gfp_t gfp);

int v11_virtqueue_add_sgs(struct virtqueue *vq,
		      struct scatterlist *sgs[],
		      unsigned int out_sgs,
		      unsigned int in_sgs,
		      void *data,
		      gfp_t gfp);

bool v11_virtqueue_kick(struct virtqueue *vq);

bool v11_virtqueue_kick_prepare(struct virtqueue *vq);

bool v11_virtqueue_notify(struct virtqueue *vq);

void *v11_virtqueue_get_buf(struct virtqueue *vq, unsigned int *len);

void *v11_virtqueue_get_buf_ctx(struct virtqueue *vq, unsigned int *len,
			    void **ctx);

void v11_virtqueue_disable_cb(struct virtqueue *vq);

bool v11_virtqueue_enable_cb(struct virtqueue *vq);

unsigned v11_virtqueue_enable_cb_prepare(struct virtqueue *vq);

bool v11_virtqueue_poll(struct virtqueue *vq, unsigned);

bool v11_virtqueue_enable_cb_delayed(struct virtqueue *vq);

void *v11_virtqueue_detach_unused_buf(struct virtqueue *vq);

unsigned int v11_virtqueue_get_vring_size(struct virtqueue *vq);

bool v11_virtqueue_is_broken(struct virtqueue *vq);

const struct vring *v11_virtqueue_get_vring(struct virtqueue *vq);
dma_addr_t v11_virtqueue_get_desc_addr(struct virtqueue *vq);
dma_addr_t v11_virtqueue_get_avail_addr(struct virtqueue *vq);
dma_addr_t v11_virtqueue_get_used_addr(struct virtqueue *vq);

void v11_virtio_add_status(struct virtio_device *dev, unsigned int status);
int v11_register_virtio_device(struct virtio_device *dev);
void v11_unregister_virtio_device(struct virtio_device *dev);

void v11_virtio_break_device(struct virtio_device *dev);

void v11_virtio_config_changed(struct virtio_device *dev);
void v11_virtio_config_disable(struct virtio_device *dev);
void v11_virtio_config_enable(struct virtio_device *dev);
int v11_virtio_finalize_features(struct virtio_device *dev);
#ifdef CONFIG_PM_SLEEP
int v11_virtio_device_freeze(struct virtio_device *dev);
int v11_virtio_device_restore(struct virtio_device *dev);
#endif

int v11_register_virtio_driver(struct virtio_driver *drv);
void v11_unregister_virtio_driver(struct virtio_driver *drv);

/* module_virtio_driver_v11() - Helper macro for drivers that don't do
 * anything special in module init/exit.  This eliminates a lot of
 * boilerplate.  Each module may only use this macro once, and
 * calling it replaces module_init() and module_exit()
 */
#define module_virtio_driver_v11(__virtio_driver) \
	module_driver(__virtio_driver, v11_register_virtio_driver, \
			v11_unregister_virtio_driver)
#endif
