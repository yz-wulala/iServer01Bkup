#include "dacsocket.h"
#include "config.h"

/*
 * @brief  open a DAC device, use id to select
 *         if more than one DAC devices exist in SOC
 * @param  dacsocket_device: dacsocket device handler
 * @param  id: dacsocket_device device ID
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_dacsocket_open(p_wll_dacsocket_device dacsocket_device, uint32_t id)
{
    if (id == 0)
    {
        dacsocket_device->dacsocket_id = 0;
        dacsocket_device->register_map = (uint32_t*)DAC_BASE_ADDR;
        return 0;
    }
    else
    {
        return 1;
    }
}


/*
 * @brief  close DAC device handler
 * @param  dacsocket_device: dacsocket device handler
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_dacsocket_close(p_wll_dacsocket_device dacsocket_device)
{
    dacsocket_device->dacsocket_id = 0xFFFF;
    return 0;
}

/*
 * @brief  Write DAC
 * @param  dacsocket_device: dacsocket device handler
 * @param  dac_value: DAC output value
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_dacsocket_write(p_wll_dacsocket_device dacsocket_device, uint32_t dac_value)
{
    if (dacsocket_device->dacsocket_id == 0xFFFF)
        return 1;
    *(reg32_t*)(dacsocket_device->register_map) = dac_value;
    
    return 0;
}
