// ****************************************************************************
// AUTHOR     : lin chen
// CSKYCPU    : 801 802 803 804
// HWCFIG     : 
// SMART_R    : yes 
// FUNCTION   : usi to uart
// METHOD     : 
// NOTE       : 
// *************************************************************

#include "uart.h"
#include "config.h"
#include "datatype.h"
#include "stdio.h"



///uart config/////
#define MODULE_EN  0x00
#define MODULE_SEL 0x04
#define CKOCK_DIV  0x10
#define UART_CTRL  0x18
#define TX_BUFFER  0x08
#define USI_UART_BUSY 0x1c

#define USI_BASE_ADDR  0x4001D000
//////


//usi to uart initilizal
void usi_uart_init(reg8_t MOD_EN, reg8_t MOD_UART,reg8_t CLK_DIV, reg8_t UART_CTR)
{
  
  *(reg8_t *)(USI_BASE_ADDR+MODULE_EN) = MOD_EN;
}


// get uart status
uint32_t usi_uart_status()
{
    uint8_t uart_lsr;
    
    uart_lsr = *(reg8_t*)(USI_BASE_ADDR+USI_UART_BUSY);
    if (uart_lsr !=0x00)
        return 0;
    else
        return 1;
}

// input char in tx buffer

uint32_t usi_uart_tx(reg8_t c)
{
  *(reg8_t*)(USI_BASE_ADDR+TX_BUFFER ) = c;
}



int main(void)
{
  reg8_t MOD_EN = 0x0F;
  reg8_t MOD_UART = 0x00;
  reg8_t CLK_DIV = 0x12;
  reg8_t UART_CTR = 0x03;

  reg8_t c = 0x55;
  usi_uart_init(MOD_EN,MOD_UART,CLK_DIV,UART_CTR);
  usi_uart_tx(c);
  
  while(!usi_uart_status());
  printf("finished");
  return 0;

}