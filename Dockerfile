
# heavily inspired by https://github.com/singe/linuxkit-mac80211_hwsim/blob/master/Dockerfile

# this is the kernel sources released for docker desktop
ARG DOCKER_VER=docker/for-desktop-kernel:4.19.76-83885d3b4cff391813f4262099b36a529bca2df8-amd64

FROM ${DOCKER_VER} AS ksrc

FROM alpine AS build
ARG KERNEL_VER=4.19.76

RUN apk update && apk add \
    argp-standalone \
    automake \
    bash \
    bc \
    binutils-dev \
    bison \
    build-base \
    curl \
    diffutils \
    flex \
    git \
    gmp-dev \
    gnupg \
    installkernel \
    kmod \
    elfutils-dev \
    linux-headers \
    mpc1-dev \
    mpfr-dev \
    ncurses-dev \
    openssl-dev \
    patch \
    sed \
    squashfs-tools \
    tar \
    xz \
    xz-dev \
    zlib-dev

COPY --from=ksrc /kernel-dev.tar /
RUN tar xf kernel-dev.tar

COPY --from=ksrc /linux.tar.xz /
RUN tar xf linux.tar.xz -C /usr/src/

RUN git clone https://git.zx2c4.com/wireguard-linux-compat

WORKDIR /usr/src/linux/
RUN cp ../linux-headers-${KERNEL_VER}-linuxkit/.config ../linux-headers-${KERNEL_VER}-linuxkit/Module.symvers .
RUN cp ../linux-headers-${KERNEL_VER}-linuxkit/scripts/gcc-plugins/randomize_layout_seed.h scripts/gcc-plugins/randomize_layout_seed.h \
    && mkdir include/generated \
    && cp ../linux-headers-${KERNEL_VER}-linuxkit/include/generated/randomize_layout_hash.h include/generated/randomize_layout_hash.h

RUN /wireguard-linux-compat/kernel-tree-scripts/jury-rig.sh /usr/src/linux

RUN echo "CONFIG_WIREGUARD=m" >> .config
RUN make olddefconfig && make modules_prepare
RUN make M=net/wireguard/

FROM alpine AS loadmod

COPY --from=build /usr/src/linux/net/wireguard/wireguard.ko /
CMD insmod /wireguard.ko
