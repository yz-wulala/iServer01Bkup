// ****************************************************************************
// *                                                                          *
// * C-Sky Microsystems Confidential                                          *
// * -------------------------------                                          *
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR       : Tao Jiang
// CSKYCPU      : 801 802 803 804
// HWCFIG       : INT_NUM_32
// SMART_R      : yes 
// FUNCTION     : demonstration of pulse int
// CTS          : no
// METHOD       : 
// NOTE         : run this file with pulse_int_test.v
// ****************************************************************************
`include "environment.h" 
module pulse_int_test();

//*******************************************************************************//
//*************** please set the path of each module top signal******************//
//*******************************************************************************//

`define WIC_PATH                         tb.x_soc.x_apb.x_wic_top
`define CPU_TOP_PATH                     tb.x_soc.x_cpu_sub_system_ahb



//********************************************************************************//
//                              MAIN TEST PROGRAM                                 //
//********************************************************************************//
//test signal define 
`define CLK                              `CPU_TOP_PATH.cpu_clk
initial
begin
     $display("load success");
     #4000 
     @(posedge `CLK); 
     #1
     force `WIC_PATH.pulse_int = 1'b1;
     $display("generate pulse");
     @(posedge `CLK); 
     @(posedge `CLK); 
     @(posedge `CLK); 
     release `WIC_PATH.pulse_int;



  end

endmodule
