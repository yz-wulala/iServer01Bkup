module Stimuli (CS, HOLD_DQ3, DI_DQ0, DO_DQ1, VCC, WP_DQ2);

    `include "include/FM_DevParam.h"
   
   
    output CS;
    output [`VoltageRange] VCC;

    inout DI_DQ0, DO_DQ1; 

    inout WP_DQ2;

    inout HOLD_DQ3; 
   
   
