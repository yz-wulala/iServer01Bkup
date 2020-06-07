// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : 
// CSKYCPU    : 801 802 803 804
// HWCFIG     :
// SMART_R    : yes  
// FUNCTION   : 
// METHOD     : 
// NOTE       : this cace tells user to know how to control jtag signal to
//              let CPU enter the debug mode
// ****************************************************************************
//*****************************************************************************
//Attention!!!:the main purpose of this case is give an example to user,and
//             let user to know how to force jtag signal in debug mode.If
//             you wanna to run this case ,please instance this module in
//             your test banch ,and set the path of cpu Jtag signal in your
//             SOC.                
//*****************************************************************************
module int_ack_test();
`define VCUNT_LVL                        tb
`ifdef CK801
  `define CPU_TOP                          tb.x_soc.x_cpu_sub_system_ahb.x_ck801
`endif
`ifdef CK802
  `define CPU_TOP                          tb.x_soc.x_cpu_sub_system_ahb.x_ck802
`endif
`ifdef CK803S
  `define CPU_TOP                          tb.x_soc.x_cpu_sub_system_ahb.x_ck803s
`endif
`ifdef CK804
  `define CPU_TOP                          tb.x_soc.x_cpu_sub_system_ahb.x_ck804
`endif
`define CPU_CLK      `CPU_TOP.pll_core_cpuclk
`define INT_VLD      `CPU_TOP.pad_vic_int_vld[2]
//`define INT_SEC      `CPU_TOP.x_vg_tcip_top.intc_cpu_int_sec
`ifdef CK801
  `define RETIRE_VLD   `CPU_TOP.iu_pad_inst_retire
`elsif CK802
  `define RETIRE_VLD   `CPU_TOP.iu_pad_inst_retire
`else
  `define RETIRE_VLD   `CPU_TOP.rtu_pad_inst_retire
`endif
reg [143:0] jtag_data_in  = 32'h8000;
reg [8:0]   jtag_data_len = 32;
reg [7:0]   ir_value      = 7'b0001101;//hcr
//reg [31:0]  cycles;
reg [143:0] jtag_data_out;
static integer FILE;
integer cycles;

initial
begin
  #100; 
  wait (`VCUNT_LVL.virtual_counter[31:0]==32'h600);
  force `INT_VLD=1'b1;
//  force `INT_SEC= 1'b1;
  @(posedge `CPU_CLK);
  @(posedge `CPU_CLK);
  @(posedge `CPU_CLK);
  @(posedge `CPU_CLK);
  @(posedge `CPU_CLK);
  wait  (`RETIRE_VLD == 1'b1);
  cycles = `VCUNT_LVL.virtual_counter[31:0];
  cycles = cycles - 32'h600;
  #1000
    $display("*********** Congratulation!:HAD TEST PASS  *******");
    $display("The time from int vald to first instruction of INT service retire");  
    $display("cost %d cpu cycles!,include excute nir ipush",cycles);  
    $display("**************************************************");
    FILE = $fopen("run_case.report","w");
    $fdisplay(FILE,"TEST PASS");
    $finish;
 end    
endmodule
