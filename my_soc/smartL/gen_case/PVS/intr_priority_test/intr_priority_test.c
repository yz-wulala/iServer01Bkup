
// ****************************************************************************
// AUTHOR     : Lei Ye
// CSKYCPU    : 801 802 803 804
// HWCFIG     :
// SMART_R    : yes  
// CTS        : no
// FUNCTION   : wake cpu up from wait mode using int
// METHOD     : 
// NOTE       : 
// ****************************************************************************


#include "datatype.h"
#include "gpio.h"


#define ATTRIBUTE_ISR __attribute__((isr))
#define CSI_INTRPT_ENTER()
#define CSI_INTRPT_EXIT()

extern void ck_intc_init(uint32_t);

t_wll_gpio_device gpio0 = {0xFFFF};


ATTRIBUTE_ISR void GPIO0_IRQHandler(void)
{
    uint32_t i=0;
    CSI_INTRPT_ENTER();
    printf("\nGPIO_0 Interrupt begin!\n");
    for(i=0;i++;i<4000000000);
    printf("\nGPIO_0 Interrupt end!\n");
    wll_gpio_intr_clr(&gpio0,WLL_GPIO_0);
    CSI_INTRPT_EXIT();
    return;
}

ATTRIBUTE_ISR void GPIO1_IRQHandler(void)
{
    CSI_INTRPT_ENTER();
    printf("\nGPIO_1 Interrupt!\n");
    wll_gpio_intr_clr(&gpio0,WLL_GPIO_1);
    CSI_INTRPT_EXIT();
    return;
}


int main (void)
{
  //--------------------------------------------------------
  // setup gpio
  //--------------------------------------------------------
  t_wll_gpio_init gpio_init;
  t_wll_gpio_intr_init gpio_intr_init;
  gpio_init.pin=WLL_GPIO_0|WLL_GPIO_1;
  gpio_init.out=0x00;
  gpio_init.dir=WLL_GPIO_DIR_IN;
  gpio_intr_init.pin=WLL_GPIO_0|WLL_GPIO_1;
  gpio_intr_init.level=WLL_GPIO_INTR_LVL_EDGE;
  gpio_intr_init.polar=WLL_GPIO_INTR_PLR_1;
  
  wll_gpio_open(&gpio0, 0);
  wll_gpio_init(&gpio0, &gpio_init);
  wll_gpio_intr_init(&gpio0, &gpio_intr_init);
  

  //--------------------------------------------------------
  // setup interrupt
  //--------------------------------------------------------
  ck_intc_init(0x0C);
  //set intr22 priority 1
  *(reg32_t*)(0xE000E400)=0x00400000;
  
  //--------------------------------------------------------
  // loop
  //--------------------------------------------------------
  while(1)
  {
    
    ;
  }
  
  return 0;
}
