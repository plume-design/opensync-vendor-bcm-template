# build env for OpenSync with BCM SDK
# base: ubuntu 16.04 64bit (official image)
FROM ubuntu:16.04

# Tested on x86_64/amd64 system only.
RUN dpkg --add-architecture i386

# Run apt-get update at each install step because of docker cache
ARG PKGINSTALL="eval apt-get update && apt-get -y install"

# On older distros "xxd" is in vim-common.
RUN $PKGINSTALL libtiff5-dev \
        libtiff5 liblzo2-dev uuid-dev bison flex \
        libc6:i386 libstdc++6:i386 libc6-dev-i386 \
        bzip2 make vim-common automake build-essential \
        pkg-config dos2unix bc gawk libtool python \
        python-six git python3 openvswitch-switch \
        dropbear-bin ncurses-dev ccache hexec \
        python3-pip quilt wget unzip libssl-dev

# If you want to add more packages please append it AT THE END
# so that docker image cache can be utilized.
# Use RUN $PKGINSTALL to avoid having stale repo list with outdated
# package versions that no longer exist (http 404) in upstream:
#   RUN $PKGINSTALL XXX YYY

# Toolchain (Rel1.10), obtained from BCM (compatible with their SDK)
# From archive: crosstools-gcc-5.5-linux-4.1-uclibc-1.0.26-glibc-2.26-binutils-2.28.1-Rel1.10-full.tar.bz2
ADD crosstools-arm-gcc-5.5-linux-4.1-glibc-2.26-binutils-2.28.1.Rel1.10.tar.bz2 /

# Old distros such as ubuntu 16.04 have a fairly old openssh which may not
# handle ~/.ssh/config options from the host system. This could be done with a
# ubuntu ppa but is easier to port to non-ubuntu/debian base systems if need
# be.
ENV OPENSSH_COMMIT_ID=30a2c213877a54a44dfdffb6ca8db70be5b457e0
RUN cd /usr/src \
    && wget -O openssh.zip https://github.com/openssh/openssh-portable/archive/$OPENSSH_COMMIT_ID.zip \
    && unzip openssh.zip \
    && cd openssh-portable-* \
    && autoreconf \
    && ./configure \
    && make -j4 \
    && make install

ADD ucw.tar.xz /usr/src/ucw
RUN cd /usr/src/ucw && make install
COPY hucw /usr/local/bin/hucw

# Install kconfiglib required for menuconfig
RUN pip3 install kconfiglib

# This toolchain is required to build dongle code
#
# This might also be doable with a regular
# arm-none- toolchain from the distro as long as it's
# properly symlinked to /projects/hnd/.
RUN $PKGINSTALL stow
RUN mkdir -p /projects/hnd/tools/linux \
    && cd /projects/hnd/tools/linux \
    && git clone https://github.com/RMerl/am-toolchains
RUN cd /projects/hnd/tools/linux \
    && ln -srf am-toolchains/brcm-arm-sdk/hndtools-armeabi-2011.09 hndtools-armeabi-2011.09 \
    && ln -srf am-toolchains/brcm-arm-sdk/hndtools-armeabi-2013.11 hndtools-armeabi-2013.11

# Dongle code building requires extra tools from
# BCM to be available system-wide
ADD post-process-tools.tgz /projects/hnd/tools/linux/
RUN cd /projects/hnd/tools/linux/ \
    && chmod +x post-process-tools/* \
    && mkdir -p bin \
    && mv post-process-tools/* bin/
ENV PATH="/projects/hnd/tools/linux/:${PATH}"

#RUN $PKGINSTALL gcc-arm-none-eabi

# Install cmake (for building odhcp6c)
RUN $PKGINSTALL cmake

RUN pip3 install Jinja2

# Broadcom buildsystem requires bash as /bin/sh.
# This must be last docker step to avoid confusing
# the system in case it assumes non-bash shell
# itself.
RUN ln -sf /bin/bash /bin/sh
