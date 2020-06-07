#ifndef __SPI_MASTER_H__
#define __SPI_MASTER_H__

#include "datatype.h"

#define SPI_MASTER_BASE_ADDR  0x4001C000
/* SPI registers addr definition */
#define WLL_SPI_MASTER_TXL      0x00
#define WLL_SPI_MASTER_TXH      0x01
#define WLL_SPI_MASTER_RXL      0x02
#define WLL_SPI_MASTER_RXH      0x03
#define WLL_SPI_MASTER_DL       0x1D
#define WLL_SPI_MASTER_SC       0x1E
#define WLL_SPI_MASTER_SS       0x1F
/* SPI master register bit definitions */
#define WLL_BYTECNT_1           0x00000000   /* the data length is 1 Bytes */
#define WLL_BYTECNT_2           0x00010000   /* the data length is 2 Bytes */
#define WLL_BYTECNT_3           0x00020000   /* the data length is 3 Bytes */
#define WLL_BYTECNT_4           0x00030000   /* the data length is 4 Bytes */
#define WLL_BYTECNT_5           0x00040000   /* the data length is 5 Bytes */
#define WLL_BYTECNT_6           0x00050000   /* the data length is 6 Bytes */
#define WLL_BYTECNT_7           0x00060000   /* the data length is 7 Bytes */
#define WLL_BYTECNT_8           0x00070000   /* the data length is 8 Bytes */


typedef enum {
    OE_DISABLE,
    OE_ENABLE
} t_wll_spi_master_oe;

typedef enum {
    EN_DISABLE,
    EN_ENABLE
} t_wll_spi_master_en;

typedef struct {
    uint32_t   baudrate;
    uint32_t   bytecnt;
} t_wll_spi_master_cfig, *p_wll_spi_master_cfig;

typedef struct {
    uint32_t spi_master_id;
    uint32_t* register_map;
    uint32_t baudrate;
    uint32_t bytecnt;
    t_wll_spi_master_oe oe;
    t_wll_spi_master_en en;
} t_wll_spi_master_device, *p_wll_spi_master_device;


uint32_t wll_spi_master_open(p_wll_spi_master_device, uint32_t);

uint32_t wll_spi_master_init(p_wll_spi_master_device, p_wll_spi_master_cfig);

uint32_t wll_spi_master_close(p_wll_spi_master_device);

uint32_t wll_spi_master_transfer(p_wll_spi_master_device, uint8_t*);

uint32_t wll_spi_master_status(p_wll_spi_master_device);

void wll_spi_master_release(p_wll_spi_master_device, uint8_t*);

#endif

