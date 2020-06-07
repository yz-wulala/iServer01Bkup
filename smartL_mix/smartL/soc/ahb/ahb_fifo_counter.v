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
// FILE NAME       : fifo_counter
// AUTHOR          : Tao Jiang
// FUNCTION        : pop fifo entries when counts down to 0
// PROJECT         : SMART
// RESET           : Async
// VERIFICATION    : 
// RELEASE HISTORY :
// *****************************************************************************
// &ModuleBeg; @19
module ahb_fifo_counter(
  counter_done,
  counter_en,
  counter_load,
  cpu_clk,
  cpu_rst_b
);

// &Ports; @20
input           counter_en;   
input   [31:0]  counter_load; 
input           cpu_clk;      
input           cpu_rst_b;    
output          counter_done; 

// &Regs; @21
reg     [31:0]  counter;      
reg             counter_en_ff; 

// &Wires; @22
wire            counter_done; 
wire            counter_en;   
wire    [31:0]  counter_load; 
wire            cpu_clk;      
wire            cpu_rst_b;    
wire            load_cnt_en;  


always @(posedge cpu_clk or negedge cpu_rst_b)
begin
  if(!cpu_rst_b)
  begin
    counter_en_ff <= 1'b0;
  end
  else
  begin
    counter_en_ff <=counter_en ;
  end
end

assign load_cnt_en= (counter_en && !counter_en_ff);
                   /// || !(|counter[31:0]);

always @(posedge cpu_clk or negedge cpu_rst_b)
begin
  if(!cpu_rst_b)
  begin
    counter[31:0] <= 32'h0;
  end
  else if (load_cnt_en)
  begin
    counter[31:0] <= counter_load[31:0];
  end
  else if (counter_done)
    counter[31:0] <= 32'b0;
  else 
    counter[31:0] <= counter[31:0] -1'b1;
 end

assign counter_done = (counter[31:0] == 32'b0) ;
// &Force("output","counter_done"); @56
// &ModuleEnd; @57
endmodule


