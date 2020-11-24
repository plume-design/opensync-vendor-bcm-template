#include "log.h"
#include "const.h"
#include "osp_tm.h"


static const char *pm_tm_temp_srcs[] =
{
    "wl0",
    "wl1",
};

static const struct osp_tm_therm_state pm_tm_therm_tbl[] =
{
    {{ 0,  0  }, { 15, 3 }, 0 },
    {{ 85, 85 }, { 3,  1 }, 5500 }
};


int osp_tm_init(
        const struct osp_tm_therm_state **tbl,
        unsigned int *therm_state_cnt,
        unsigned int *temp_src_cnt,
        void **priv)
{
    LOGN("osp_tm: Dummy implementation of %s", __func__);

    *tbl = pm_tm_therm_tbl;
    *therm_state_cnt = ARRAY_SIZE(pm_tm_therm_tbl);
    *temp_src_cnt = ARRAY_SIZE(pm_tm_temp_srcs);
    *priv = NULL;

    return 0;
}

void osp_tm_deinit(void *priv)
{
    LOGN("osp_tm: Dummy implementation of %s", __func__);
}

const char* osp_tm_get_temp_src_name(void *priv, int idx)
{
    LOGN("osp_tm: Dummy implementation of %s", __func__);
    return "foo";
}

int osp_tm_get_temperature(void *priv, int idx, int *temp)
{
    LOGN("osp_tm: Dummy implementation of %s", __func__);
    return 0;
}

int osp_tm_get_fan_rpm(void *priv, unsigned int *rpm)
{
    LOGN("osp_tm: Dummy implementation of %s", __func__);
    return 0;
}

int osp_tm_set_fan_rpm(void *priv, unsigned int rpm)
{
    LOGN("osp_tm: Dummy implementation of %s", __func__);
    return 0;
}
