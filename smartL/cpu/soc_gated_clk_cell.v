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
//FILE NAME       : gated_clk_cell
//AUTHOR          : Jiebing Wang
//FUNCTION        : This module models the gated clock macro cell.
//RESET           : 
//DFT             :
//DFP             :  
//VERIFICATION    : 
//RELEASE HISTORY :
//$Id: soc_gated_clk_cell.v,v 1.1 2017/06/02 09:38:23 jiangt Exp $
// ****************************************************************************

module soc_gated_clk_cell(
  clk_in,
  external_en,
  SE,
  clk_out
);

input  clk_in;
input  external_en ;
input  SE;
output clk_out;

reg    clk_en_af_latch;
always @(clk_in or external_en)
begin
  if(!clk_in)
    clk_en_af_latch <= external_en;
end

reg clk_en ;
always @ (SE or clk_en_af_latch )
begin
    clk_en <= clk_en_af_latch || SE ;
end
assign clk_out = clk_in && clk_en ;
   
endmodule   
