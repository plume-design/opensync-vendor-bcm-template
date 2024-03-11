#include "schema_consts.h"
#include "osp_temp.h"
#include "osp_temp_platform.h"
#include "log.h"
#include "const.h"

#define RADIO_TYPE_STR_2G       SCHEMA_CONSTS_RADIO_TYPE_STR_2G
#define RADIO_TYPE_STR_5GL      SCHEMA_CONSTS_RADIO_TYPE_STR_5GL
#define RADIO_TYPE_STR_5GU      SCHEMA_CONSTS_RADIO_TYPE_STR_5GU

static const struct temp_src osp_temp_srcs[] =
{
    { "wl0", RADIO_TYPE_STR_5GL, osp_temp_get_temperature_wl },
    { "wl1", RADIO_TYPE_STR_2G, osp_temp_get_temperature_wl },
    { "wl2", RADIO_TYPE_STR_5GU, osp_temp_get_temperature_wl },
};

const struct temp_src* osp_temp_get_srcs(void)
{
    return osp_temp_srcs;
}

int osp_temp_get_srcs_cnt(void)
{
    return ARRAY_SIZE(osp_temp_srcs);
}
