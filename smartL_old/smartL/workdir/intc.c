#include "datatype.h"
#include "uart.h"
#include "stdio.h"

#define TCIP_BASE                 0xE000E000
#define VIC_BASE                  0xE000E100

//config the interrupt controller
void ck_intc_init()
{
	int *picr = (int*)TCIP_BASE;
        *picr = 0x0;
        
        // Write ISER
        int *piser = (int*)VIC_BASE;
        *piser = 0x200000;
}
