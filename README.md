virtio 1.1 drivers
===
These drivers are supplementary to support virtio 1.1 new feature
on CentOS 7.6, CentOS 7.9, Ubuntu 16.04, Ubuntu 18.04 and Debian 10.

Build package:
---

```
./mkpkg.sh
```

Installation:
---

1. Centos 7.x:
   ```
   rpm -ivh release/virtio_centos-7.6-7.7-v11.noarch.rpm
   or
   rpm -ivh release/virtio_centos-7.8-7.9-v11.noarch.rpm
   ```
2. Ubuntu 16.04 (kernel-4.4 or kernel-4.18):
   ```
   tar xvf release/virtio_ubuntu-16.04-kernel-4.18/4.4-v11.tar; cd virtio_ubuntu-16.04-kernel-4.18/4.4-v11; ./install.sh
   ```
2. Ubuntu 18.04:
   ```
   tar xvf release/virtio_ubuntu-18.04-v11.tar; cd virtio_ubuntu-18.04-v11; ./install.sh
   ```
3. Debian 10:
   ```
   dpkg -i release/virtio-dkms_1.1.0_amd64.deb
   ```
