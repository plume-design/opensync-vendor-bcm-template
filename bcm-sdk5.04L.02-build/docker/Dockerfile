FROM ubuntu:18.04

# ubuntu 18.04 satisfies dependencies for SDK 5.4.2 for:
# host gcc >= 6
# openssl 1.1.1

# Tested on x86_64/amd64 system only.
RUN dpkg --add-architecture i386

# Run apt-get update at each install step because of docker cache
ARG PKGINSTALL="eval apt-get update && apt-get -y install"

# On older distros "xxd" is in vim-common.
RUN $PKGINSTALL libtiff5-dev libtiff5 liblzo2-dev uuid-dev bison flex libc6:i386 libstdc++6:i386 libc6-dev-i386 bzip2 make vim-common automake build-essential pkg-config dos2unix bc gawk libtool python python-six git python3 openvswitch-switch dropbear-bin ncurses-dev ccache hexec python3-pip quilt wget unzip libssl-dev

# If you want to add more packages please append it AT THE END
# so that docker image cache can be utilized.
# Use RUN $PKGINSTALL to avoid having stale repo list with outdated
# package versions that no longer exist (http 404) in upstream:
#   RUN $PKGINSTALL XXX YYY

# Toolchain (Rel1.12), obtained from bcm (compatible with their sdk)
ADD crosstools-arm-gcc-9.2-linux-4.19-glibc-2.30-binutils-2.32.Rel1.12.tar.bz2 /
ADD crosstools-aarch64-gcc-9.2-linux-4.19-glibc-2.30-binutils-2.32.Rel1.12.tar.bz2 /

# Install kconfiglib required for menuconfig
RUN pip3 install kconfiglib

# This toolchain is requried to build dongle code
#
# This might also be doable with a regular
# arm-none- toolchain from distro as long as its
# properly symlinked to /projects/hnd/.. Let's use
# a tested solution until it breaks.
RUN $PKGINSTALL stow
RUN mkdir -p /projects/hnd/tools/linux \
&&	cd /projects/hnd/tools/linux \
&&	git clone https://github.com/RMerl/am-toolchains
RUN	cd /projects/hnd/tools/linux \
&&	ln -srf am-toolchains/brcm-arm-sdk/hndtools-armeabi-2011.09 hndtools-armeabi-2011.09 \
&&	ln -srf am-toolchains/brcm-arm-sdk/hndtools-armeabi-2013.11 hndtools-armeabi-2013.11

# Dongle code building requires extra tools from
# bcm to be available system-wide
ADD post-process-tools.tgz /projects/hnd/tools/linux/
RUN cd /projects/hnd/tools/linux/ \
&&	chmod +x post-process-tools/* \
&&	mkdir -p bin \
&&	mv post-process-tools/* bin/
ENV PATH="/projects/hnd/tools/linux/:${PATH}"

#RUN $PKGINSTALL gcc-arm-none-eabi

ENV GOPATH=/usr/src/local/go
RUN $PKGINSTALL golang-1.10
RUN /usr/lib/go-1.10/bin/go get -d -v github.com/git-lfs/git-lfs
RUN git -C /usr/src/local/go/src/github.com/git-lfs/git-lfs checkout origin/release-2.7
RUN /usr/lib/go-1.10/bin/go install -v github.com/git-lfs/git-lfs
RUN ln -srf $GOPATH/bin/git-lfs /usr/local/bin

# Additions for device-sdk-bcm-5.2-ax:
RUN $PKGINSTALL cpio

# Addition for EMMC images
RUN $PKGINSTALL gdisk
RUN cd /projects && ln -sf hnd bca
RUN $PKGINSTALL pigz

# Install cmake (for building odhcp6c)
RUN $PKGINSTALL cmake

RUN pip3 install Jinja2

# needed to access signing server
RUN pip3 install requests
RUN $PKGINSTALL pbzip2

# Needed for the stam generator
RUN eval $PKGINSTALL python3-pydot

# uboot requires gcc >= 6
# ubuntu 18.04 already has gcc-7 as default
# alternatively gcc-6 can be installed instead and specified with HOSTCC or GCC6
# RUN $PKGINSTALL gcc-6

# buildFS requires rsync
RUN $PKGINSTALL rsync

# /etc/mtab is required to fix this build error:
# ext2fs_check_mount_point: Can't check if filesystem is mounted due to
# missing mtab file while determining whether .../rootfs.ext4 is mounted.
RUN [ -e /etc/mtab ] || ln -sf /proc/mounts /etc/mtab

# Broadcom buildsystem requires bash as /bin/sh.
# This must be last docker step to avoid confusing
# the system in case it assumes non-bash shell
# itself.
RUN ln -sf /bin/bash /bin/sh
