// ****************************************************************************
// AUTHOR     : yizhou jiang
// CSKYCPU    : 801 802 803 804
// HWCFIG     : 
// SMART_R    : yes 
// FUNCTION   : spi interrupt
// METHOD     : 
// NOTE       : 
// ****************************************************************************

#include "datatype.h"
#include "spi_master.h"
#include "spi_slave.h"
#include "gpio.h"

#define ATTRIBUTE_ISR __attribute__((isr))
#define CSI_INTRPT_ENTER()
#define CSI_INTRPT_EXIT()


extern void ck_intc_init();

t_wll_spi_master_device spim0 = {0xFFFF};
t_wll_spi_slave_device spis0 = {0xFFFF};
t_wll_gpio_device gpio0 = {0xFFFF};

uint8_t tx_buffer[8];
uint8_t rx_buffer[8];
uint8_t temp;

ATTRIBUTE_ISR void SPISLAVE_IRQHandler(void)
{
    CSI_INTRPT_ENTER();
    temp=wll_spi_slave_reg_get(&spis0, 0x06);
    CSI_INTRPT_EXIT();
    return;
}

int main (void)
{
  //--------------------------------------------------------
  // setup spi_master
  //--------------------------------------------------------
  t_wll_spi_master_cfig spi_master_cfig;
  spi_master_cfig.baudrate = 5000000;       // any integer value is allowed
  spi_master_cfig.bytecnt = WLL_BYTECNT_6;    // from WLL_BYTECNT_1 to WLL_BYTECNT_8
  // open SPI_MASTER device with id = 0 (SPI_MASTER0)
  wll_spi_master_open(&spim0, 0);
  // initialize spi_master using spi_master_cfig structure
  wll_spi_master_init(&spim0, &spi_master_cfig);
  
  //--------------------------------------------------------
  // setup spi_slave
  //--------------------------------------------------------
  // open SPI_SLAVE device with id = 0 (SPI_SLAVE0)
  wll_spi_slave_open(&spis0, 0);

  //--------------------------------------------------------
  // setup gpio
  //--------------------------------------------------------
  t_wll_gpio_init gpio_init;
  gpio_init.pin=WLL_GPIO_0 | WLL_GPIO_2;
  gpio_init.out=0x01;
  gpio_init.dir=WLL_GPIO_DIR_OUT;
  wll_gpio_open(&gpio0, 0);
  wll_gpio_init(&gpio0, &gpio_init);
  //*(reg32_t*)(0x40019004)=0x0F;
  //*(reg32_t*)(0x40019000)=0x0F;
  
  //--------------------------------------------------------
  // setup interrupt
  //--------------------------------------------------------
  ck_intc_init();

  //--------------------------------------------------------
  // spi master read from slave
  //--------------------------------------------------------
  // set tx_buffer
  tx_buffer[0]=0xE5;
  tx_buffer[1]=0x0F;
  tx_buffer[2]=0xFF;
  tx_buffer[3]=0xFF;
  tx_buffer[4]=0xFF;
  tx_buffer[5]=0xFF;
  
  // spi_master transfer
  wll_gpio_write(&gpio0,WLL_GPIO_0,WLL_GPIO_OUT_LOW);
  wll_spi_master_transfer(&spim0, tx_buffer);
  //wait until not busy
  while (wll_spi_master_status(&spim0));
  wll_gpio_write(&gpio0,WLL_GPIO_0,WLL_GPIO_OUT_HIGH);
  //get rx buffer
  wll_spi_master_release(&spim0, rx_buffer);
  
  //--------------------------------------------------------
  // spi master write to slave
  //--------------------------------------------------------
  //set tx buffer
  tx_buffer[0]=0x65;
  tx_buffer[1]=0x0B;
  tx_buffer[2]=rx_buffer[2];
  tx_buffer[3]=rx_buffer[3];
  tx_buffer[4]=rx_buffer[4];
  tx_buffer[5]=rx_buffer[5];
  
  // spi_master transfer
  wll_gpio_write(&gpio0,WLL_GPIO_0,WLL_GPIO_OUT_LOW);
  wll_spi_master_transfer(&spim0, tx_buffer);
  //wait until not busy
  while (wll_spi_master_status(&spim0));
  wll_gpio_write(&gpio0,WLL_GPIO_0,WLL_GPIO_OUT_HIGH);
  
  // spi_master transfer
  wll_gpio_write(&gpio0,WLL_GPIO_0,WLL_GPIO_OUT_LOW);
  wll_spi_master_transfer(&spim0, tx_buffer);
  //wait until not busy
  while (wll_spi_master_status(&spim0));
  wll_gpio_write(&gpio0,WLL_GPIO_0,WLL_GPIO_OUT_HIGH);
  
  // spi_master transfer
  wll_gpio_write(&gpio0,WLL_GPIO_0,WLL_GPIO_OUT_LOW);
  wll_spi_master_transfer(&spim0, tx_buffer);
  //wait until not busy
  while (wll_spi_master_status(&spim0));
  wll_gpio_write(&gpio0,WLL_GPIO_0,WLL_GPIO_OUT_HIGH);
  return 0;
}

