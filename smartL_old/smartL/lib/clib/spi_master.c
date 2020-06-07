#include "spi_master.h"
#include "config.h"

void wll_spi_master_load_tx_buffer(p_wll_spi_master_device spi_master_device, uint8_t *data)
{
    uint32_t txh;
    uint32_t txl;
    txh=(data[0]<<24)+(data[1]<<16)+(data[2]<<8)+data[3];
    txl=(data[4]<<24)+(data[5]<<16)+(data[6]<<8)+data[7];
    *(reg32_t*)(spi_master_device->register_map+WLL_SPI_MASTER_TXH) = txh;
    *(reg32_t*)(spi_master_device->register_map+WLL_SPI_MASTER_TXL) = txl;
}


void wll_spi_master_set_baudrate(p_wll_spi_master_device spi_master_device, uint32_t baudrate)
{ /* {{{ wll_spi_master_set_baudrate */
    uint32_t baud_div;
    uint32_t *addr = spi_master_device->register_map;
    baud_div = ((APB_FREQ/baudrate) >> 2) -1;
    spi_master_device->baudrate = baudrate;
    *(reg32_t*)(addr+WLL_SPI_MASTER_DL) &= 0xFFFF0000;
    *(reg16_t*)(addr+WLL_SPI_MASTER_DL) |= (baud_div & 0xFFFF);
} /* }}} */


void wll_spi_master_set_bytecnt(p_wll_spi_master_device spi_master_device, uint32_t bytecnt)
{ /* {{{ wll_spi_master_set_bytecnt */
    spi_master_device->bytecnt = bytecnt;
    *(reg32_t*)(spi_master_device->register_map+WLL_SPI_MASTER_DL) &= 0x0000FFFF;
    *(reg32_t*)(spi_master_device->register_map+WLL_SPI_MASTER_DL) |= bytecnt;	
} /* }}} */


void wll_spi_master_set_oe(p_wll_spi_master_device spi_master_device, t_wll_spi_master_oe oe)
{ /* {{{ wll_spi_master_set_oe */
    spi_master_device->oe = oe;
    if(OE_DISABLE)
    {
        *(reg8_t*)(spi_master_device->register_map+WLL_SPI_MASTER_SC) &= 0xFB;
    }
    else
    {
        *(reg8_t*)(spi_master_device->register_map+WLL_SPI_MASTER_SC) |= 0x04;
    }
} /* }}} */

void wll_spi_master_set_en(p_wll_spi_master_device spi_master_device, t_wll_spi_master_en en)
{ /* {{{ wll_spi_master_set_en */
    spi_master_device->en = en;
    if(EN_DISABLE)
    {
        *(reg8_t*)(spi_master_device->register_map+WLL_SPI_MASTER_SC) &= 0xFE;
    }
    else
    {
        *(reg8_t*)(spi_master_device->register_map+WLL_SPI_MASTER_SC) |= 0x01;
    }
} /* }}} */


/*
 * @brief  open a SPI_MASTER device, use id to select
 *         if more than one SPI_MASTER devices exist in SOC
 * @param  spi_master_device: spi_master device handler
 * @param  id: spi_master_device device ID
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_spi_master_open(p_wll_spi_master_device spi_master_device, uint32_t id)
{
    if (id == 0)
    {
        spi_master_device->spi_master_id = 0;
        spi_master_device->register_map = (uint32_t*)SPI_MASTER_BASE_ADDR;
        return 0;
    }
    else
    {
        return 1;
    }
}

/*
 * @brief  Initialize SPI_MASTER configurations from spi_master_cfig data structure
 * @param  spi_master_device: SPI_MASTER device handler
 * @param  spi_master_cfig: SPI_MASTER configurations collection, a structure datatype
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_spi_master_init(p_wll_spi_master_device spi_master_device, p_wll_spi_master_cfig spi_master_cfig)
{
    if (spi_master_device->spi_master_id == 0xFFFF)
        return 1;
    wll_spi_master_set_oe(spi_master_device, OE_ENABLE);
    wll_spi_master_set_en(spi_master_device, EN_ENABLE);
    wll_spi_master_set_baudrate(spi_master_device, spi_master_cfig->baudrate);
    wll_spi_master_set_bytecnt(spi_master_device, spi_master_cfig->bytecnt);

    return 0;
}

/*
 * @brief  close SPI_MASTER device handler
 * @param  spi_master_device: SPI_MASTER handler
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_spi_master_close(p_wll_spi_master_device spi_master_device)
{
    wll_spi_master_set_oe(spi_master_device, OE_DISABLE);
    wll_spi_master_set_en(spi_master_device, OE_DISABLE);
    spi_master_device->spi_master_id = 0xFFFF;
    return 0;
}

/*
 * @brief  transmit data through SPI_MASTER
 * @param  spi_master_device: SPI_MASTER device handler
 * @param  data: address of the data needs to transmit
 * @retval 0 if success, 1 if fail
 */
uint32_t wll_spi_master_transfer(p_wll_spi_master_device spi_master_device, uint8_t *data)
{
    if ((spi_master_device->en == EN_DISABLE) & (spi_master_device->oe == OE_DISABLE))
        return 1;
    // wait until spi_master is not busy
    while (*(reg8_t*)(spi_master_device->register_map+WLL_SPI_MASTER_SS));
    //load data
    wll_spi_master_load_tx_buffer(spi_master_device, data);
    //trans
    *(reg8_t*)(spi_master_device->register_map+WLL_SPI_MASTER_SC) = 0x07;
    return 0;
}

/*
 * @brief  check SPI_MASTER device's status, busy or idle
 * @param  spi_master_device: SPI_MASTER device handler
 * @retval 0 if uart is in idle, 1 if busy
 */
uint32_t wll_spi_master_status(p_wll_spi_master_device spi_master_device)
{
    uint8_t spi_master_ssr;

    spi_master_ssr = *(reg8_t*)(spi_master_device->register_map+WLL_SPI_MASTER_SS);
    if (spi_master_ssr==0x00)
        return 0;
    else
        return 1;
}

/*
 * @brief  get SPI_MASTER device's rx_buffer
 * @param  spi_master_device: SPI_MASTER device handler
 * @retval void
 */
void wll_spi_master_release(p_wll_spi_master_device spi_master_device, uint8_t *data)
{
    uint32_t rxh;
    uint32_t rxl;
    uint8_t i;
    uint8_t btt;
    rxh=*(reg32_t*)(spi_master_device->register_map+WLL_SPI_MASTER_RXH);
    rxl=*(reg32_t*)(spi_master_device->register_map+WLL_SPI_MASTER_RXL);
    btt=(((spi_master_device->bytecnt) >> 16)+1);
    if(btt>4)
    {	
        i=btt-4;
        do
        {
            i--;
            data[i]=(rxh & 0xFF);
            rxh = (rxh >> 8);
        }while(i>0);
        for(i=btt-1;i>btt-5;i--)
        {
            data[i]=(rxl & 0xFF);
            rxl = (rxl >> 8);
        }
    }
    else
    {
        i=btt;
        do
        {
            i--;
            data[i]=(rxl & 0xFF);
            rxl = (rxl >> 8);
        }while(i>0);
    }
}

