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
// FILE NAME       : px_had_sync.vp
// AUTHOR          : huanghuanhuan
// ORIGINAL TIME   : Dec.04 2013
// FUNCTION        : common sync logic for synchronization between two different
//                   clock domain. 
// RESET           : Asynchronous Reset
// VERIFICATION    :
// RELEASE HISTORY : First Release
// $Id: px_had_sync.vp,v 1.1 2017/06/09 03:02:30 jiangt Exp $
// *****************************************************************************
// &ModuleBeg; @21
module px_had_sync(
  clk1,
  clk2,
  rst1_b,
  rst2_b,
  sync_in,
  sync_out
);

// &Ports; @22
input        clk1;         
input        clk2;         
input        rst1_b;       
input        rst2_b;       
input        sync_in;      
output       sync_out;     

// &Regs; @23
reg          sync_ff1_clk1; 
reg          sync_ff2_clk1; 
reg          sync_ff3_clk1; 
reg          sync_ff_clk2; 

// &Wires; @24
wire         clk1;         
wire         clk2;         
wire         rst1_b;       
wire         rst2_b;       
wire         sync_in;      
wire         sync_out;     

  

//==============================================================================
// sync logic from clk2 to clk1
// step 1. flop once in clk2 domain
// step 2. flop twice in clk1 domain
// result: a pulse signal in clk1 domain
// constraint: slow clock --> fast clock
//==============================================================================

always @(posedge clk2 or negedge rst2_b)
begin
  if (!rst2_b)
    sync_ff_clk2 <= 1'b0;
  else
    sync_ff_clk2 <= sync_in;
end

always @(posedge clk1 or negedge rst1_b)
begin
  if (!rst1_b) begin
    sync_ff1_clk1 <= 1'b0;
    sync_ff2_clk1 <= 1'b0;
  end
  else begin
    sync_ff1_clk1 <= sync_ff_clk2;
    sync_ff2_clk1 <= sync_ff1_clk1;
  end   
end

// generates a pulse signal in clk1 domain
always @(posedge clk1 or negedge rst1_b)
begin
  if (!rst1_b)
    sync_ff3_clk1 <= 1'b0;
  else
    sync_ff3_clk1 <= sync_ff2_clk1;
end

assign sync_out = !sync_ff3_clk1 && sync_ff2_clk1;

// &ModuleEnd;  @66
endmodule



