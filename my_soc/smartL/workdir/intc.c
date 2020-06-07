#include "datatype.h"
#include "stdio.h"

#define TCIP_BASE                 0xE000E000
#define VIC_BASE                  0xE000E100



//config the interrupt controller
void ck_intc_init(uint32_t intrindex)
{
	int *picr = TCIP_BASE;
        *picr = 0x0;
        
        // Write ISER
        int *piser = VIC_BASE;
        *piser = intrindex;
}
