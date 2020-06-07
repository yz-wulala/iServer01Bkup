#include "datatype.h"
#include "dacsocket.h"

t_wll_dacsocket_device dac0 = {0xFFFF};
uint32_t value;

int main (void)
{
  //--------------------------------------------------------
  // setup uart
  //--------------------------------------------------------
 

  // open DAC device with id = 0 (DAC0)
  wll_dacsocket_open(&dac0, 0);

  // DAC write value
  for(value=0;value<4096;value++)
      wll_dacsocket_write(&dac0, value);


  return 0;
}

