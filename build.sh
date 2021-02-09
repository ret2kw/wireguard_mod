#!/bin/sh

# pulling the kernel image from /etc/linuxkit.yml on the host with a complete disregard for all decency be just downloading an entire python project and jq just to parse the yaml on the command line
DOCKER_VER=$(docker run --rm --privileged --pid=host alpine sh -c 'apk add py-pip > /dev/null 2>&1 && apk add jq > /dev/null 2>&1 && pip install yq > /dev/null 2>&1 && nsenter -m -t 1 cat /etc/linuxkit.yml | yq -r .kernel.image')

# terrible way of pulling the particular kernel version, could probably just uname during build but meh
KERNEL_VER=$(echo $DOCKER_VER | cut -f 2 -d : | cut -f 1 -d -)

docker build --no-cache --build-arg DOCKER_VER=${DOCKER_VER} --build-arg KERNEL_VER=${KERNEL_VER} -t wg_mod .

#now we just run the container to load the module, this needs to happen after every reboot
docker run --rm --privileged wg_mod

