OpenSync BCM Template
=====================

Reference/template BCM vendor layer implementation provides support for reference
BCM based targets.

This vendor layer provides an example target implementation for the following
reference board (described below):
* `OS_BCM947622DVT_BCM54` - gateway and extender mode (BCM96755REF1)

#### Reference software versions

* Components and versions:

    | Component                    | Version  |         |
    |------------------------------|----------|---------|
    | OpenSync core                | 6.4.x    | public  |
    | OpenSync vendor/bcm-template | 6.4.x    | public  |
    | OpenSync platform/bcm        | 6.4.x    | public  |
    | BCM SDK                      | 5.04L.02 | private |

#### Reference board information

* Reference board: BCM96755REF1

* Chipset: BCM6755 + BCM43684

* Interfaces:

    | Interface     | Description                                       |
    |---------------|---------------------------------------------------|
    | eth0          | WAN ethernet interface                            |
    | br-home       | LAN bridge                                        |
    | wl0           | 5G (Lower) wireless phy interface (BCM43684)      |
    | wl1           | 2.4G wireless phy interface (BCM6755)             |
    | wl2           | 5G (Upper) wireless phy interface (BCM6755)       |


OpenSync root dir
-----------------

OpenSync build system requires a certain directory structure in order to ensure
modularity. Key components are:

* OpenSync core:             `OPENSYNC_ROOT/core`
* OpenSync BCM platform:     `OPENSYNC_ROOT/platform/bcm`
* OpenSync BCM template:     `OPENSYNC_ROOT/vendor/bcm-template`
* OpenSync service provider: `OPENSYNC_ROOT/service-provider/local` ([local](https://github.com/plume-design/opensync-service-provider-local) given as an example which needs to be replaced with your service provider)

Follow these steps to populate the OPENSYNC_ROOT directory:

```
$ git clone https://github.com/plume-design/opensync.git OPENSYNC_ROOT/core
$ git clone https://github.com/plume-design/opensync-platform-bcm.git OPENSYNC_ROOT/platform/bcm
$ git clone https://github.com/plume-design/opensync-vendor-bcm-template.git OPENSYNC_ROOT/vendor/bcm-template
$ git clone https://github.com/plume-design/opensync-service-provider-local.git OPENSYNC_ROOT/service-provider/local
$ mkdir -p OPENSYNC_ROOT/3rdparty
```

The resulting layout should be as follows:

```
OPENSYNC_ROOT
├── 3rdparty
│   └── ...
├── core
│   ├── 3rdparty -> ../3rdparty
│   ├── build
│   ├── doc
│   ├── images
│   ├── interfaces
│   ├── kconfig
│   ├── Makefile
│   ├── ovsdb
│   ├── platform -> ../platform
│   ├── README.md
│   ├── src
│   ├── vendor -> ../vendor
│   └── work
├── platform
│   └── bcm
├── service-provider
│   └── ...
└── vendor
    └── bcm-template
```

To simplify build commands, it is recommended to create the following
environment variables (assuming location of sources is `~/projects`):

```
export OPENSYNC_ROOT=~/projects/opensync
export SDK_ROOT=~/projects/sdk/bcm-542
```


BCM SDK
-------

To integrate OpenSync into BCM SDK, follow the steps below:

1. Prepare the BCM SDK and build env as instructed by BCM

2. Apply patches and files required by OpenSync

```
cd $SDK_ROOT
mkdir contrib
tar -C contrib -xvf opensync-6.4.X.0-sdk-bcm-5.04L.02-patches-XX.tar.gz
cp -a contrib/files/*/. .
cp -a contrib/patches .
find patches/public-opensync/ patches/partner-opensync/ -name series | xargs cat > series
quilt push -a
```

3. Unpack archive of opensource packages

```
mkdir dl
tar -C dl -xvf opensync-6.4.X.0-sdk-bcm-5.04L.02-dl-XX.tar.gz
```
or download them manually and place them in the dl folder

4. Copy target profiles from bcm-template:
```
cp -a $OPENSYNC_ROOT/vendor/bcm-template/bcm-sdk5.04L.02-build/targets/. $SDK_ROOT/targets/
```

5. Copy docker from bcm-template:
```
cp -a $OPENSYNC_ROOT/vendor/bcm-template/bcm-sdk5.04L.02-build/docker $SDK_ROOT/
```

6. Add toolchain to docker

```
cp -a crosstools*.tar.bz2 $SDK_ROOT/docker/
```

NOTE: Provided information is based on BCM SDK `5.04L.02`. In case you are
using some other BCM SDK version, these steps can be used as a general guidance,
but may require some modifications.


Build environment
-----------------

For build environment requirements see `bcm-sdk5.04L.02-build/docker/Dockerfile`,
which is used to create the build environment and run builds in a docker container.

Note that the Dockerfile is tailored for BCM SDK `5.04L.02` and may require some
modifications in case some other BCM SDK version is used.


Build
-----

To build OpenSync package in BCM SDK using docker run the commands below.
Variable `PROFILE` must be set to one of the defined targets, depending on
which variant you wish to build.

Example for target `OS_BCM947622DVT_BCM54`:

```
$ cd $SDK_ROOT/
$ docker/dock-run make \
    OPENSYNC_SRC=$OPENSYNC_ROOT \
    PROFILE=OS_BCM947622DVT_BCM54
```

The above commands build a full image. To build just the OpenSync package one
can modify the build commands by adding: `-C userspace/opensync/apps/opensync`.

Note that additional build-time variables `BACKHAUL_PASS` and `BACKHAUL_SSID`
used to be passed into the make command but have since been deprecated because
they are set in service-provider repositories based on the chosen
`IMAGE_DEPLOYMENT_PROFILE`. See `Makefile` for details.


Automated preparation of the SDK
--------------------------------

Alternative method of preparing, patching and building the SDK:

Here SDK_ROOT should start as an empty directory
Prepare the SDK dir following these steps:

1. Copy bcm-sdk5.04L.02-build from bcm-template:
```
cp -a $OPENSYNC_SRC/vendor/bcm-template/bcm-sdk5.04L.02-build/. $SDK_ROOT/.
```
2. Add SDK packages as received from BCM to $SDK_ROOT/dl:
```
cp bcm963xx_5.04L.02_data_full_release.tar.gz  $SDK_ROOT/dl/
cp bcm963xx_5.04L.02_ovs.tar.gz                $SDK_ROOT/dl/
cp wlan-all-src-17.10.157.2802.cpe5.04L.02.tgz $SDK_ROOT/dl/
```
3. Copy toolchain to docker:
```
cp crosstools-aarch64-gcc-9.2-linux-4.19-glibc-2.30-binutils-2.32.Rel1.12.tar.bz2 $SDK_ROOT/docker/
cp crosstools-arm-gcc-9.2-linux-4.19-glibc-2.30-binutils-2.32.Rel1.12.tar.bz2     $SDK_ROOT/docker/
```
4. Unpack patches to `contrib` directory:
```
tar -C $SDK_ROOT/contrib -xvf opensync-5.6.X.0-sdk-bcm-5.04L.02-patches-XX.tar.gz
```

5. Unpack archive of opensource packages to `dl` directory:
```
tar -C $SDK_ROOT/dl -xvf opensync-5.6.X.0-sdk-bcm-5.04L.02-dl-XX.tar.gz
```

6. Run build with:
```
cd $SDK_ROOT
./docker/dock-run make build \
    OPENSYNC_SRC=$OPENSYNC_ROOT \
    CONFIG=OS_BCM947622DVT_BCM54
```

7. This will patch the SDK and run the build. The location of the patched SDK will be:
```
$SDK_ROOT/build-OS_BCM947622DVT_BCM54-y/
```


Image install
-------------

#### Full image reflash

Note: when running bcm_flasher the `/var` fs needs free space in the size of the image,
if the image is also stored there then the `/var` fs size needs to be double the size of the image.

```
$ cd /tmp
$ curl -O <image-url>
$ bcm_flasher <image-file>
$ bcm_bootstate 1
```

#### OpenSync package re-install

```
$ cd /tmp
$ curl -O <package-url>
$ tar xzvf <package-file> -C /
```


Run
---

OpenSync will be automatically started at startup -- see `/etc/rc3.d/S99opensync`.

To manually start, stop, or restart OpenSync, use the following command:

```
$ /etc/init.d/opensync stop|start|restart
```


Device access
-------------

The preferred way to access the reference device is through the serial console.

SSH access is also available on all interfaces:
* Username: `osync`
* Password: `osync123`


OpenSync resources
------------------

For further information please visit: https://www.opensync.io/
