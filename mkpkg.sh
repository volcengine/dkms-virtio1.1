#!/bin/bash

echo "Build virtio1.1 drivers on: $(lsb_release -ds)"

. scripts/mkdkms.sh

test -e *.rpm && mv *.rpm release
test -e *.tar && mv *.tar release
test -e *.deb && mv *.deb release
