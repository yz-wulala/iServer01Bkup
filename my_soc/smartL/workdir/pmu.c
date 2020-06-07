#include "pmu.h"
#include "config.h"



/*
 * @brief  Configurate PMU control reg
 * @param  pmu_config: PMU config
 * @retval 0 
 */
uint32_t wll_pmu_set_config(uint32_t pmu_config)
{
    *(reg32_t*)(PMU_BASE_ADDR+WLL_PMU_CTRL) = pmu_config;
    return 0;
}


/*
 * @brief  Configurate PMU counter reg
 * @param  pmu_counter: PMU counter
 * @retval 0 
 */
uint32_t wll_pmu_set_counter(uint32_t pmu_counter)
{
    *(reg32_t*)(PMU_BASE_ADDR+WLL_PMU_CNTR) = pmu_counter;
    return 0;
}

