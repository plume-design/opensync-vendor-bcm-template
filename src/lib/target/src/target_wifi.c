/**
 * Target WiFi implementation for OS_GATEWAY_BCM52.
 *
 * Note that target WiFi implementation depends on HW configuration of
 * WiFi interfaces. For HW details see README.md.
 */
#define _GNU_SOURCE /* for alloca */

/* std libc */
#include <string.h>

/* internal */
#include <log.h>
#include <target.h>
#include <bcmwl.h>
#include <bcmwl_nas.h>
#include <bcmwl_wps.h>

#define MODULE_ID LOG_MODULE_ID_TARGET

static void target_radio_init_uapsd_war(void)
{
    /*
     * FIXME: This is ugly but avoids radio down/up to change uapsd
     *        setting in driver. This is best-effort. It'll work only
     *        on initial wm startup when radios are down. Only home ap
     *        is expected to have uapsd enabled by default. This will
     *        obviously stop working (as intended) if uapsd default
     *        setting in cloud changes.
     */
    WL("wl0", "wme_apsd", "0");
    WL("wl0.1", "wme_apsd", "0");
    WL("wl0.2", "wme_apsd", "1");
    WL("wl1", "wme_apsd", "0");
    WL("wl1.1", "wme_apsd", "0");
    WL("wl1.2", "wme_apsd", "1");
}

static void target_radio_init_steer_war(void)
{
    /*
     * FIXME: These settings can be configured by cloud via VIF_Config. However
     *        driver is limited to apply them only when radio is down. Downing
     *        radio introduces a severe service interruption so it's best to
     *        avoid it if possible. These settings are for BM which works on
     *        home-vaps only. It is expected that these will always be either
     *        [set,[]] or 1 in ovsdb for home vifs.
     */
    WL("wl0.2", "rrm", "+2");
    WL("wl1.2", "rrm", "+2");
    WL("wl0.2", "wnm", "+1");
    WL("wl1.2", "wnm", "+1");
}

static void target_bcmwl_wps_set_script(void)
{
    char wps_script[64] = { 0 };

    snprintf(wps_script, sizeof(wps_script)-1, "%s/wps_state_change.sh", target_bin_dir());
    if (access(wps_script, X_OK) == 0)
    {
        bcmwl_wps_set_on_state_change_script(wps_script);
    }
}

bool target_radio_init(const struct target_radio_ops *ops)
{
    if (WARN_ON(!bcmwl_init(ops)))
        return false;
    if (WARN_ON(!bcmwl_init_wm()))
        return false;

    bcmwl_vap_prealloc("wl0", 3, bcmwl_vap_mac_xfrm); /* wl0.1, wl0.2, wl0.3 */
    bcmwl_vap_prealloc("wl1", 3, bcmwl_vap_mac_xfrm); /* wl1.1, wl1.2, wl1.3 */
    target_bcmwl_wps_set_script();
    target_radio_init_uapsd_war();
    target_radio_init_steer_war();

    return true;
}

bool target_radio_config_set2(
        const struct schema_Wifi_Radio_Config *rconf,
        const struct schema_Wifi_Radio_Config_flags *rchanged)
{
    return bcmwl_radio_update2(rconf, rchanged);
}

bool target_vif_config_set2(
        const struct schema_Wifi_VIF_Config *vconf,
        const struct schema_Wifi_Radio_Config *rconf,
        const struct schema_Wifi_Credential_Config *cconfs,
        const struct schema_Wifi_VIF_Config_flags *vchanged,
        int num_cconfs)
{

#ifdef TARGET_OS_GATEWAY_BCM52
    // Add home interfaces into br-home for gateway model to simulate
    // pre-configured LAN network
    if (strcmp(vconf->if_name, "wl0.2") == 0 ||
        strcmp(vconf->if_name, "wl1.2") == 0)
    {
        strexa("ovs-vsctl", "add-port", "br-home", vconf->if_name);
    }
#endif

    return bcmwl_vap_update2(vconf, rconf, cconfs, vchanged, num_cconfs);
}

const char* target_vif_get_sta_ifname(const char *phy)
{
    // For BCM sta ifname is same as radio
    return phy;
}
