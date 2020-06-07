#ifndef __DACSOCKET_H__
#define __DACSOCKET_H__

#include "datatype.h"

#define DAC_BASE_ADDR  0x4001C000


typedef struct{
    uint32_t dacsocket_id;
    uint32_t* register_map;
}t_wll_dacsocket_device, *p_wll_dacsocket_device;

uint32_t wll_dacsocket_open(p_wll_dacsocket_device, uint32_t);

uint32_t wll_dacsocket_close(p_wll_dacsocket_device);

uint32_t wll_dacsocket_write(p_wll_dacsocket_device, uint32_t);

#endif
