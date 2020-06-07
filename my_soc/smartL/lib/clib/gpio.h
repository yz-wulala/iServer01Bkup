#ifndef __GPIO_H__
#define __GPIO_H__

#include "datatype.h"

#define GPIO_BASE_ADDR  0x40019000
/* GPIO registers addr definition */
#define WLL_GPIO_OUT         0x00
#define WLL_GPIO_DIR         0x01

#define WLL_GPIO_INTR_EN     0x0C
#define WLL_GPIO_INTR_MSK    0x0D
#define WLL_GPIO_INTR_LVL    0x0E
#define WLL_GPIO_INTR_PLR    0x0F
#define WLL_GPIO_INTR_STA    0x10
#define WLL_GPIO_INTR_CLR    0x13
#define WLL_GPIO_EXT         0x14

/* GPIO register bit definitions */
#define WLL_GPIO_0           0x00000001   /* GPIO_0   is selected */
#define WLL_GPIO_1           0x00000002   /* GPIO_1   is selected */
#define WLL_GPIO_2           0x00000004   /* GPIO_2   is selected */
#define WLL_GPIO_3           0x00000008   /* GPIO_3   is selected */
#define WLL_GPIO_4           0x00000010   /* GPIO_4   is selected */
#define WLL_GPIO_5           0x00000020   /* GPIO_5   is selected */
#define WLL_GPIO_6           0x00000040   /* GPIO_6   is selected */
#define WLL_GPIO_7           0x00000080   /* GPIO_7   is selected */
#define WLL_GPIO_ALL         0x000000FF   /* GPIO_ALL is selected */


#define WLL_GPIO_OUT_HIGH    0x000000FF
#define WLL_GPIO_OUT_LOW     0x00000000

#define WLL_GPIO_DIR_IN      0x00000000
#define WLL_GPIO_DIR_OUT     0x000000FF

#define WLL_GPIO_INTR_LVL_LVL    0x00000000
#define WLL_GPIO_INTR_LVL_EDGE   0x000000FF

#define WLL_GPIO_INTR_PLR_0      0x00000000
#define WLL_GPIO_INTR_PLR_1      0x000000FF

typedef struct{
    uint32_t   pin;
    uint32_t   level;
    uint32_t   polar;
}t_wll_gpio_intr_init, *p_wll_gpio_intr_init;

typedef struct{
    uint32_t   pin;
    uint32_t   out;
    uint32_t   dir;
}t_wll_gpio_init, *p_wll_gpio_init;

typedef struct{
    uint32_t gpio_id;
    uint32_t* register_map;
}t_wll_gpio_device, *p_wll_gpio_device;

uint32_t wll_gpio_open(p_wll_gpio_device, uint32_t);

uint32_t wll_gpio_init(p_wll_gpio_device, p_wll_gpio_init);

uint32_t wll_gpio_deinit(p_wll_gpio_device, uint32_t);

uint32_t wll_gpio_intr_init(p_wll_gpio_device, p_wll_gpio_intr_init);

uint32_t wll_gpio_intr_deinit(p_wll_gpio_device, uint32_t);

uint32_t wll_gpio_close(p_wll_gpio_device);

uint32_t wll_gpio_write(p_wll_gpio_device, uint32_t, uint32_t);

uint8_t wll_gpio_read(p_wll_gpio_device);
#endif
