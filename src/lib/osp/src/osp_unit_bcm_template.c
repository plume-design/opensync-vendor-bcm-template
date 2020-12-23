#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "build_version.h"
#include "util.h"
#include "log.h"
#include "os_nif.h"

#include "osp_unit.h"

static bool util_if_mac_get(void *buff, size_t buffsz, char *if_name)
{
    memset(buff, 0, buffsz);

    os_macaddr_t mac;
    size_t n;

    // get if MAC address
    if (true == os_nif_macaddr(if_name, &mac))
    {
        n = snprintf(buff, buffsz, PRI(os_macaddr_plain_t), FMT(os_macaddr_t, mac));
        if (n >= buffsz) {
            LOG(ERR, "buffer not large enough");
            return false;
        }
        return true;
    }
    LOG(ERR, "Unable to retrieve MAC address for %s.", if_name);

    return false;
}


bool osp_unit_serial_get(char *buff, size_t buffsz)
{
    char macstr[64];
    size_t n;

    memset(buff, 0, buffsz);
    // get eth0 MAC address
    if (true == util_if_mac_get(macstr, sizeof(macstr), "eth0"))
    {
        n = snprintf(buff, buffsz, "%s%s",
                CONFIG_OSP_UNIT_BCM_TEMPLATE_SERIAL_PREFIX, macstr);
        if (n >= buffsz)
        {
            LOG(ERR, "buffer not large enough");
            return false;
        }
        return true;
    }

    return false;
}

bool osp_unit_id_get(char *buff, size_t buffsz)
{
    return osp_unit_serial_get(buff, buffsz);
}

bool osp_unit_model_get(char *buff, size_t buffsz)
{
    strscpy(buff, CONFIG_TARGET_MODEL, buffsz);
    return true;
}

bool osp_unit_sku_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_hw_revision_get(char *buff, size_t buffsz)
{
    snprintf(buff, buffsz, "%s", "Rev 1.0");
    return true;
}

bool osp_unit_platform_version_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_sw_version_get(char *buff, size_t buffsz)
{
    strscpy(buff, app_build_ver_get(), buffsz);
    return true;
}

bool osp_unit_vendor_name_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_vendor_part_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_manufacturer_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_factory_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_mfg_date_get(char *buff, size_t buffsz)
{
    return false;
}

bool osp_unit_dhcpc_hostname_get(void *buff, size_t buffsz)
{
    char serial_num[100] = { 0 };
    char model_name[100] = { 0 };

    if (osp_unit_serial_get(serial_num, sizeof(serial_num)) != true)
    {
        LOG(ERR, "Unable to get serial number");
        return false;
    }
    if (osp_unit_model_get(model_name, sizeof(model_name)) != true)
    {
        LOG(ERR, "Unable to get model name");
        return false;
    }

    snprintf(
            buff,
            buffsz,
            "%s_%s",
            serial_num,
            model_name);

    return true;
}

