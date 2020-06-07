// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : JiangPeng
// CSKYCPU    : 801 802 803 804
// HWCFIG     :
// SMART_R    : yes  
// FUNCTION   : Test performance for memory set
// METHOD     : 1) load flog to check cpu is power up or reset  
// NOTE       :
// ****************************************************************************

#include "datatype.h"
#include "stdio.h"
#include "timer.h"

static __inline__ void Set_timer_int_server();
int Loop_Num = 0;

int main (void)
{
//  int *TIMER_ADDR;
//  TIMER_ADDR = 0x40011008;
//  //config the interrupt controller
//  ck_intc_init();
//  Timer_Interrupt_Init();
  Set_timer_int_server();
  ck_intc_init();
  //--------------------------------------------------------
  // start main memory copy
  //--------------------------------------------------------
//  start_set_timer(0x800);
  asm (
       "mfcr r0,cr<31,0>\n"
       "bseti r0,0x4\n"
       "mtcr r0,cr<31,0>\n"
       "psrset ee,ie\n"
       );
  printf("\nINT SPEC is enable !\n");
  while(1){};
  return 0;
}

static __inline__ void Set_timer_int_server()
{
asm("lrw  r1, SEVICER_BEGIN\n"
    "mfcr r2, cr<1, 0>\n"
    "movi r3, 34\n"
    "lsli r3, r3, 2\n"
    "addu r2, r2, r3\n"
    "st.w r1, (r2,0)\n"
//  set wake up enable 
    "lrw  r2,0xe000e140\n"
    "lrw r1,0xffffffff\n"
    "st.w r1, (r2,0)\n"
    "br SEVICER_END\n"
//  int server
    "SEVICER_BEGIN:\n"
    "psrclr ie \n"
    "rte\n"
    "SEVICER_END:");
}



