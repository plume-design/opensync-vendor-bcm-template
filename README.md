OpenSync BCM Template
=====================

Reference/template BCM vendor layer implementation provides support for reference
BCM based targets.

This vendor layer provides an example target implementation for the following
reference board (described below):
* `OS_BCM947622DVT_EXT` - gateway and extender mode (BCM96755REF1)
* `OS_BCM947622DVTCH6` - gateway and extender mode (BCM96755REF1, WiFi 6E)

#### Reference software versions

* Components and versions:

    | Component                    | Version  |         |
    |------------------------------|----------|---------|
    | OpenSync core                | 6.4.x    | public  |
    | OpenSync vendor/bcm-template | 6.4.x    | public  |
    | OpenSync platform/bcm        | 6.4.x    | public  |
    | BCM SDK                      | 5.02L.07 | private |

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

Note: In OS_BCM947622DVTCH6 target, `wl0` is used as a 6G wireless phy interface.


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
export SDK_ROOT=~/projects/sdk/bcm-52
export SDK_VER=5.02L.07
```


BCM SDK
-------

To integrate OpenSync into BCM SDK, follow the steps below:

1. Go to OpenSync root directory
```
cd $OPENSYNC_ROOT
```

2. Copy target configuration files from bcm-template to `$SDK_ROOT/targets/`

```
$ cp -fr vendor/bcm-template/bcm-sdk${SDK_VER}-build/targets/.  $SDK_ROOT/targets/
```

3. Copy docker files from bcm-template to SDK

```
cp -fr vendor/bcm-template/bcm-sdk${SDK_VER}-build/docker $SDK_ROOT/
```

4. Unpack the OpenSync package and dependencies to `$SDK_ROOT/userspace` dir

```
$ tar xzvf opensync-6.4.X.0-sdk-bcm-5.02L.07-patches-XX.tar.gz -C $SDK_ROOT/userspace
```

NOTE: Provided information is based on BCM SDK `5.02L.07`. In case you are
using some other BCM SDK version, these steps can be used as a general guidance,
but may require some modifications.


Build environment
-----------------

For build environment requirements see `bcm-sdk5.02L.07-build/docker/Dockerfile`,
which is used to create the build environment and run builds in a docker container.

Note that the Dockerfile is tailored for BCM SDK `5.02L.07` and may require some
modifications in case some other BCM SDK version is used.


Build
-----

To build OpenSync package in BCM SDK using docker run the commands below.
Variable `PROFILE` must be set to one of the defined targets, depending on
which variant you wish to build.

Example for target `OS_BCM947622DVT_EXT`:

```
$ cd $SDK_ROOT/
$ docker/dock-run make \
    OPENSYNC_SRC=$OPENSYNC_ROOT \
    PROFILE=OS_BCM947622DVT_EXT
```

The above commands build a full image. To build just the OpenSync package one
can modify the build commands by adding: `-C userspace/opensync/apps/opensync`.

Note that additional build-time variables `BACKHAUL_PASS` and `BACKHAUL_SSID`
used to be passed into the make command but have since been deprecated because
they are set in service-provider repositories based on the chosen
`IMAGE_DEPLOYMENT_PROFILE`. See `Makefile` for details.


Image install
-------------

#### Full image reflash

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
