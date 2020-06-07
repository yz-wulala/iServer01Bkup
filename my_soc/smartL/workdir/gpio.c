#include "gpio.h"
#include "config.h"

/*
 * @brief  open a GPIO device, use id to select
 *         if more than one GPIO devices exist in SOC
 * @param  gpio_device: gpio device handler
 * @param  id: gpio_device device ID
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_gpio_open(p_wll_gpio_device gpio_device, uint32_t id)
{
    if (id == 0)
    {
        gpio_device->gpio_id = 0;
        gpio_device->register_map = (uint32_t*)GPIO_BASE_ADDR;
        return 0;
    }
    else
    {
        return 1;
    }
}

/*
 * @brief  Initialize GPIO configurations from gpio_init data structure
 * @param  gpio_device: GPIO device handler
 * @param  gpio_init: GPIO initial collection, a structure datatype
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_gpio_init(p_wll_gpio_device gpio_device, p_wll_gpio_init gpio_init)
{
    if (gpio_device->gpio_id == 0xFFFF)
        return 1;
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_OUT) &= ~(gpio_init->pin);
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_OUT) |= ((gpio_init->pin) & (gpio_init->out));   
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_DIR) &= ~(gpio_init->pin);
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_DIR) |= ((gpio_init->pin) & (gpio_init->dir));
    return 0;
}

/*
 * @brief  Deinitialize GPIO configurations from gpio_init data structure to default states
 * @param  gpio_device: GPIO device handler
 * @param  gpio_pin: GPIO pin enume
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_gpio_deinit(p_wll_gpio_device gpio_device, uint32_t gpio_pin)
{
    if (gpio_device->gpio_id == 0xFFFF)
        return 1;
    //reset sfrs
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_OUT) &= (~gpio_pin);
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_DIR) &= (~gpio_pin);
    return 0;
}

/*
 * @brief  Initialize GPIO interrupt configurations from gpio_intr_init data structure
 * @param  gpio_device: GPIO device handler
 * @param  gpio_intr_init: GPIO interrupt initial collection, a structure datatype
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_gpio_intr_init(p_wll_gpio_device gpio_device, p_wll_gpio_intr_init gpio_intr_init)
{
    if (gpio_device->gpio_id == 0xFFFF)
        return 1;
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_INTR_LVL) &= ~(gpio_intr_init->pin);
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_INTR_LVL) |= ((gpio_intr_init->pin) & (gpio_intr_init->level));
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_INTR_PLR) &= ~(gpio_intr_init->pin);
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_INTR_PLR) |= ((gpio_intr_init->pin) & (gpio_intr_init->polar));
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_INTR_EN)  &= ~(gpio_intr_init->pin);
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_INTR_EN)  |=  (gpio_intr_init->pin);
    return 0;
}

/*
 * @brief  Deinitialize GPIO interrupt configurations from gpio_intr_init data structure
 * @param  gpio_device: GPIO device handler
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_gpio_intr_deinit(p_wll_gpio_device gpio_device, uint32_t gpio_pin)
{
    if (gpio_device->gpio_id == 0xFFFF)
        return 1;
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_INTR_EN)   &= (~gpio_pin);
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_INTR_LVL)  &= (~gpio_pin);
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_INTR_PLR)  &= (~gpio_pin);
    return 0;
}

/*
 * @brief  close GPIO device handler
 * @param  gpio_device: GPIO handler
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_gpio_close(p_wll_gpio_device gpio_device)
{
    gpio_device->gpio_id = 0xFFFF;
    return 0;
}

/*
 * @brief  Write GPIO
 * @param  gpio_device: GPIO device handler
 * @param  gpio_pin: GPIO pin enume
 * @param  gpio_out: GPIO output set
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_gpio_write(p_wll_gpio_device gpio_device, uint32_t gpio_pin, uint32_t gpio_out)
{
    if (gpio_device->gpio_id == 0xFFFF)
        return 1;
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_OUT) &= ~(gpio_pin);
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_OUT) |= ((gpio_pin) & (gpio_out));   

    return 0;
}


/*
 * @brief  Read GPIO
 * @param  gpio_device: GPIO device handler
 * @retval data
 */
uint8_t wll_gpio_read(p_wll_gpio_device gpio_device)
{
    uint8_t data;
    data = (uint8_t)((*(reg32_t*)(gpio_device->register_map+WLL_GPIO_EXT)) & 0x000000FF );
    return data;
}

/*
 * @brief  Clear GPIO INTR
 * @param  gpio_device: GPIO device handler
 * @param  gpio_pin: GPIO pin enume
 * @retval data
 */
uint8_t wll_gpio_intr_clr(p_wll_gpio_device gpio_device, uint32_t gpio_pin)
{
    if (gpio_device->gpio_id == 0xFFFF)
        return 1;
    *(reg32_t*)(gpio_device->register_map+WLL_GPIO_INTR_CLR) = gpio_pin;  

    return 0;
}
