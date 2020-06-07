#ifndef __SPI_SLAVE_H__
#define __SPI_SLAVE_H__

#include "datatype.h"

#define SPI_SLAVE_BASE_ADDR  0x4001B000

typedef struct {
    uint32_t spi_slave_id;
    uint32_t* register_map;
} t_wll_spi_slave_device, *p_wll_spi_slave_device;

uint8_t wll_spi_slave_reg_get(p_wll_spi_slave_device, uint8_t);

uint32_t wll_spi_slave_reg_set(p_wll_spi_slave_device, uint8_t, uint8_t);

uint32_t wll_spi_slave_open(p_wll_spi_slave_device, uint32_t);

uint32_t wll_spi_slave_close(p_wll_spi_slave_device);

#endif

