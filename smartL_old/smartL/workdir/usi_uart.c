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
#define CLOCK_DIV  0x10
#define UART_CTRL  0x18
#define TX_BUFFER  0x08
#define USI_UART_BUSY 0x1c
#define USI_INIT_EN 0x50
#define USI_UART_STOP_EN 0x5c

#define USI_UART_INT_CLR 0x60


#define USI_BASE_ADDR  0x4001D000
//////

extern void ck_intc_init();

//usi to uart initilizal
void usi_uart_init(reg8_t MOD_EN, reg8_t MOD_UART,uint32_t CLK_DIV, reg8_t UART_CTR)
{
  
   *(reg8_t *)(USI_BASE_ADDR+MODULE_EN) = MOD_EN;
   *(reg8_t *)(USI_BASE_ADDR+MODULE_SEL) = MOD_UART;
   *(uint32_t *)(USI_BASE_ADDR+CLOCK_DIV) = CLK_DIV;
   *(reg8_t *)(USI_BASE_ADDR+UART_CTRL) = UART_CTR;
}

void usi_uart_stop()
{
  *(reg16_t *)(USI_BASE_ADDR+USI_INIT_EN) = 0x0400;  // start int
  *(reg16_t *)(USI_BASE_ADDR+USI_UART_STOP_EN) = 0xFFFF;   //unmasked
}



// get uart status
uint32_t usi_uart_status()
{
    uint32_t uart_lsr;
    
    uart_lsr = *(uint32_t *)(USI_BASE_ADDR+USI_UART_BUSY);
//    printf("the value is %x\n",uart_lsr);
    printf("\n");
    if (uart_lsr & 0x03)
	return 1;
    else
        return 0;
}



// input char in tx buffer
uint32_t usi_uart_tx(reg8_t c)
{
  *(reg8_t*)(USI_BASE_ADDR+TX_BUFFER ) = c;
}

//*** USI int***//
void USI_IRQHandler()
{
  printf("int generated");
*(uint32_t *)(USI_BASE_ADDR+USI_UART_INT_CLR ) = 0x0400;

}



int main(void)
{
  reg8_t MOD_EN = 0x0F;
  reg8_t MOD_UART = 0x00;
  uint32_t CLK_DIV = 0x12;
  reg8_t UART_CTR = 0x03;

  reg16_t c = 0x5555;
  reg16_t d = 0x0066;
  ck_intc_init();
  usi_uart_init(MOD_EN,MOD_UART,CLK_DIV,UART_CTR);
  usi_uart_stop();

  usi_uart_tx(c);

  usi_uart_tx(d);
  

  while(usi_uart_status());
  printf("finished");
  // }
  return 0;

}
