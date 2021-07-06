SDK := dl/bcm963xx_5.02L.07p1_data_full_release.tar.gz
SDK_DATA := bcm963xx_5.02L.07p1_data_src.tar.gz
OVS := dl/bcm963xx_5.02L.07p1_ovs.tar.gz
OVS_DATA := bcm963xx_5.02L.07p1_data_ovs.tar.gz
WLAN := dl/wlan-all-src-17.10.157.2802.cpe5.02L.07p1.tgz
IMPLVER := 69
WLCHIPS = 43684b0
PROFILE = 947622GW+256SQUBI+NOCMS+OPENSYNC+IMPL69
OPENSYNC_TARGET = OS_BCM947622DVT_EXT
define SERIES_DIRS
private-bcm
public-opensync
partner-opensync
endef

