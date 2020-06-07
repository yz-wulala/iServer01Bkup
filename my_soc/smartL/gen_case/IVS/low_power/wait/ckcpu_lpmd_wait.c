
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
#include "pmu.h"

#define ATTRIBUTE_ISR __attribute__((isr))
#define CSI_INTRPT_ENTER()
#define CSI_INTRPT_EXIT()


extern void ck_intc_init(uint32_t);

t_wll_gpio_device gpio0 = {0xFFFF};

volatile uint8_t intr_cnt=0;

ATTRIBUTE_ISR void GPIO0_IRQHandler(void)
{
    CSI_INTRPT_ENTER();
    intr_cnt++;
    wll_gpio_intr_clr(&gpio0,WLL_GPIO_0);
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
  gpio_init.pin=WLL_GPIO_0;
  gpio_init.out=0x01;
  gpio_init.dir=WLL_GPIO_DIR_IN;
  gpio_intr_init.pin=WLL_GPIO_0;
  gpio_intr_init.level=WLL_GPIO_INTR_LVL_EDGE;
  gpio_intr_init.polar=WLL_GPIO_INTR_PLR_1;
  
  wll_gpio_open(&gpio0, 0);
  wll_gpio_init(&gpio0, &gpio_init);
  wll_gpio_intr_init(&gpio0, &gpio_intr_init);
  

  //--------------------------------------------------------
  // setup interrupt
  //--------------------------------------------------------
  ck_intc_init(0x0C);
  *(reg32_t*)(0xE000E140)=0x04;
  //*(reg32_t*)(0x40016000)=0x01;
  wll_pmu_set_config(WLL_PMU_INTR_EN);
  
  //--------------------------------------------------------
  // goto wait
  //--------------------------------------------------------
  while(intr_cnt<5)
  {
    
    asm (
      "wait\n"
    );
    //intr_cnt++;
  }
  
  return 0;
}
