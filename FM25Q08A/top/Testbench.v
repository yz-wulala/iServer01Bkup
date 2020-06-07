/*---------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------

            TESTBENCH

-----------------------------------------------------------
-----------------------------------------------------------
---------------------------------------------------------*/


`timescale 1ns / 1ns

module Testbench;

    `include "include/FM_DevParam.h"

    wire CS, CLK;
    wire [`VoltageRange] VCC; 
    wire clock_active;   
    wire DI_DQ0, DO_DQ1;
    wire WP_DQ2; 
    wire HOLD_DQ3;


        FM25Q08A DUT (CS, CLK, HOLD_DQ3, DI_DQ0, DO_DQ1, VCC, WP_DQ2);

        Stimuli stim (CS, HOLD_DQ3, DI_DQ0, DO_DQ1, VCC, WP_DQ2);

        StimTasks tasks (CS, HOLD_DQ3, DI_DQ0, DO_DQ1, VCC, WP_DQ2, clock_active);

        ClockGenerator ck_gen (clock_active, CLK);

   initial
    begin
     $fsdbDumpfile ("FM25Q08A_debug.fsdb");
     $fsdbDumpvars (0,Testbench);
    end
		


endmodule    
