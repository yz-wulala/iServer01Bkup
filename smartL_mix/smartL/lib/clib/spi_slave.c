#include "spi_slave.h"
#include "config.h"


uint32_t wll_spi_slave_reg_set(p_wll_spi_slave_device spi_slave_device, uint8_t spi_addr, uint8_t spi_data)
{
    if((spi_slave_device->spi_slave_id) == 0)
    {
        uint32_t addr;
        uint8_t bias;
        uint32_t data;
        uint32_t mask;
        addr = (uint32_t)(spi_addr >> 2U);
        bias = ((spi_addr & 0x03) << 3);
        mask = ~ (0xFF << bias);
        data = (spi_data << bias);
        *(reg32_t*)(spi_slave_device->register_map+addr) &= mask;
        *(reg32_t*)(spi_slave_device->register_map+addr) |= data;
        return 0;
    }
    else
    {
        return 1;
    }
}

uint8_t wll_spi_slave_reg_get(p_wll_spi_slave_device spi_slave_device, uint8_t spi_addr)
{
    if((spi_slave_device->spi_slave_id) == 0)
    {
        uint32_t addr;
        uint8_t bias;
        uint32_t data;
        uint8_t spi_data;
        addr = (uint32_t)(spi_addr >> 2U);
        bias = ((spi_addr & 0x03) << 3);
        data = *(reg32_t*)(spi_slave_device->register_map+addr);
        spi_data = (uint8_t)((data >> bias) & 0xFFFF);
        return spi_data;
    }
    else
    {
        return 0xFF;
    }
}

/*
 * @brief  open a SPI_SLAVE device, use id to select
 *         if more than one SPI_SLAVE devices exist in SOC
 * @param  spi_slave_device: spi_slave device handler
 * @param  id: spi_slave_device device ID
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_spi_slave_open(p_wll_spi_slave_device spi_slave_device, uint32_t id)
{
    if (id == 0)
    {
        spi_slave_device->spi_slave_id = 0;
        spi_slave_device->register_map = (uint32_t*)SPI_SLAVE_BASE_ADDR;
        return 0;
    }
    else
    {
        return 1;
    }
}

/*
 * @brief  close SPI_SLAVE device handler
 * @param  spi_slave_device: SPI_SLAVE handler
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_spi_slave_close(p_wll_spi_slave_device spi_slave_device)
{
    spi_slave_device->spi_slave_id = 0xFFFF;
    return 0;
}

