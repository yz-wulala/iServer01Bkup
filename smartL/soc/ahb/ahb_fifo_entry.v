// *****************************************************************************
// *                                                                           *
// * C-Sky Microsystems Confidential                                           *
// * -------------------------------                                           *
// * This file and all its contents are properties of C-Sky Microsystems. The  *
// * information contained herein is confidential and proprietary and is not   *
// * to be disclosed outside of C-Sky Microsystems except under a              *
// * Non-Disclosure Agreement (NDA).                                           *
// *                                                                           *
// *****************************************************************************
// FILE NAME       : ahb_fifo_entry
// AUTHOR          : Tao Jiang
// FUNCTION        : 
// PROJECT         : SMART
// RESET           : Async
// VERIFICATION    : 
// RELEASE HISTORY :
// *****************************************************************************
// &ModuleBeg; @19
module ahb_fifo_entry(
  create_en,
  data_in,
  data_out,
  entry_clk,
  entry_rst_b
);

// &Ports; @20
input           create_en;  
input   [54:0]  data_in;    
input           entry_clk;  
input           entry_rst_b; 
output  [54:0]  data_out;   

// &Regs; @21
reg     [54:0]  data_out;   

// &Wires; @22
wire            create_en;  
wire    [54:0]  data_in;    
wire            entry_clk;  
wire            entry_rst_b; 


always @(posedge entry_clk or negedge entry_rst_b)
begin
  if (!entry_rst_b)
    data_out[54:0] <= 54'b0;
  else if (create_en)
    data_out[54:0] <= data_in[54:0];
  else
    data_out[54:0] <= data_out[54:0];
end

// &Force("output","data_out"); @34




// &ModuleEnd; @39
endmodule


