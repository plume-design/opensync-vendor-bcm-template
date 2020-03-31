/*
 * Band Steering Abstraction Layer API for OS_GATEWAY_BCM52.
 */

#define _GNU_SOURCE
#include <errno.h>
#include <time.h>
#include <limits.h>
#include <arpa/inet.h>

#include "proto/ethernet.h"
#include "proto/bcmevent.h"
#include "proto/802.11.h"

#include "target.h"
#include "bcmwl_debounce.h"
#include "bcmwl_nvram.h"
#include "bcmwl.h"
#include "bcm_bsal.h"

static struct ev_loop *_ev_loop = NULL;
static const char *ifnames[] = { "wl0", "wl1", "br-home", NULL };

int target_bsal_init(
        bsal_event_cb_t callback,
        struct ev_loop *loop)
{
    bool res;

    /* TODO: Add multiple ifaces */
    res = bcm_bsal_init(loop, ifnames, callback);
    if (res) {
        _ev_loop = loop;
    }

    return (res ? 0 : -1);
}

int target_bsal_cleanup(void)
{
    bool res;

    res = bcm_bsal_finalize(_ev_loop, ifnames);
    _ev_loop = NULL;

    return (res ? 0 : -1);
}

int target_bsal_iface_add(const bsal_ifconfig_t *ifcfg)
{
    return bcm_bsal_iface_add(ifcfg) ? 0 : -1;
}

int target_bsal_iface_update(const bsal_ifconfig_t *ifcfg)
{
    return bcm_bsal_iface_update(ifcfg) ? 0 : -1;
}

int target_bsal_iface_remove(const bsal_ifconfig_t *ifcfg)
{
    return bcm_bsal_iface_remove(ifcfg) ? 0 : -1;
}

int target_bsal_client_add(
        const char *ifname,
        const uint8_t *mac_addr,
        const bsal_client_config_t *conf)
{
    return bcm_bsal_add_client(ifname, mac_addr, conf) ? 0 : -1;
}

int target_bsal_client_update(
        const char *ifname,
        const uint8_t *mac_addr,
        const bsal_client_config_t *conf)
{
    return bcm_bsal_update_client(ifname, mac_addr, conf) ? 0 : -1;
}

int target_bsal_client_remove(
        const char *ifname,
        const uint8_t *mac_addr)
{
    return bcm_bsal_remove_client(ifname, mac_addr) ? 0 : -1;
}

int target_bsal_client_measure(
        const char *ifname,
        const uint8_t *mac_addr,
        int num_samples)
{
    return bcm_bsal_client_measure(ifname, mac_addr, num_samples) ? 0 : -1;
}

int target_bsal_client_disconnect(
        const char *ifname,
        const uint8_t *mac_addr,
        bsal_disc_type_t type,
        uint8_t reason)
{
    return bcm_bsal_client_disconnect(ifname, mac_addr, type, reason) ? 0 : -1;
}

int target_bsal_bss_tm_request(
        const char *ifname,
        const uint8_t *mac_addr,
        const bsal_btm_params_t *btm_params)
{
    return bcm_bsal_bss_tm_request(ifname, mac_addr, btm_params) ? 0 : -1;
}

int target_bsal_rrm_beacon_report_request(
        const char *ifname,
        const uint8_t *mac_addr,
        const bsal_rrm_params_t *rrm_params)
{
    return bcm_bsal_rrm_beacon_report_request(ifname, mac_addr, rrm_params) ? 0 : -1;
}
