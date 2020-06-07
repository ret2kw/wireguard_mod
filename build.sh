#!/bin/sh

# https://github.com/linuxkit/linuxkit/issues/3402
# homeboy made a docker image that can read out the kernel image name from the cd docker-desktop boots from
DOCKER_VER=$(docker run --rm --device=/dev/sr0 quay.io/steigr/docker-for-desktop-get-kernel-image:latest)
docker build --build-arg DOCKER_VER=${DOCKER_VER} -t wg_mod .

#now we just run the container to load the module, this needs to happen after every reboot
docker run --rm --privileged wg_mod

