#include "log.h"
#include "osp.h"

int osp_led_init(int *led_cnt)
{
    LOGW("osp_led: Dummy implementation of %s", __func__);
    return 0;
}

int osp_led_set_state(enum osp_led_state state, uint32_t priority)
{
    LOGW("osp_led: Dummy implementation of %s", __func__);
    return 0;
}

int osp_led_clear_state(enum osp_led_state state)
{
    LOGW("osp_led: Dummy implementation of %s", __func__);
    return 0;
}

int osp_led_reset(void)
{
    LOGW("osp_led: Dummy implementation of %s", __func__);
    return 0;
}

int osp_led_get_state(enum osp_led_state *state, uint32_t *priority)
{
    LOGW("osp_led: Dummy implementation of %s", __func__);
    return 0;
}

