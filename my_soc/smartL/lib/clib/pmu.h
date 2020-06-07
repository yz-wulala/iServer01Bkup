#ifndef __PMU_H__
#define __PMU_H__

#include "datatype.h"

#define PMU_BASE_ADDR  0x40016000
/* PMU registers addr definition */
#define WLL_PMU_CTRL         0x00
#define WLL_PMU_CNTR         0x01


/* PMU enable bit definitions */
#define WLL_PMU_CNTR_EN           0x00000008   /* counter enable             */
#define WLL_PMU_JTAG_EN           0x00000004   /* JTAG debug wake up enable  */
#define WLL_PMU_EVENT_EN          0x00000002   /* event wake up enable       */
#define WLL_PMU_INTR_EN           0x00000001   /* interrupt wake up enable   */


uint32_t wll_pmu_set_config(uint32_t);

uint32_t wll_pmu_set_counter(uint32_t);

#endif
