   
//--------------------------------------------------------------------------------
// This module generates the clock signal.
// The module is driven by "clock_active" signal, coming from "StimTasks" module.
// 
// (NB: Tasks of StimTasks module are invoked in "Stimuli" module).
//--------------------------------------------------------------------------------
`timescale 1ns / 1ns
    
    
module ClockGenerator (clock_active, CLK);

`include "include/FM_DevParam.h"

input clock_active;
output CLK;
reg CLK;
   
   
    always begin : clock_generator

        if (clock_active) begin
            CLK = 1; #(T/2);
            CLK = 0; #(T/2);
        end else begin
            CLK = 0;
            @ clock_active;
        end

    end



endmodule    
