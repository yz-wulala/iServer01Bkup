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
//FILE NAME       : HVT_CLKLANQHDV8
//AUTHOR          : Ziyi Hao
//FUNCTION        : Behavior Model For SMIC55 HVT Gated Cell
//RESET           : 
//DFT             :
//DFP             :  
//VERIFICATION    : 
//RELEASE HISTORY :
//$Id: HVT_CLKLANQHDV8.v,v 1.3 2014/06/18 11:28:19 haozy Exp $
// ****************************************************************************

module HVT_CLKLANQHDV8 (Q, CK, E, TE);
  output Q;
  input CK, E, TE;
// synopsys translate_off

// simulation model for smic13
// it will be discarded during synthesis
reg    clk_en_af_latch;
always @(CK or E)
begin
  if(!CK)
    clk_en_af_latch <= E;
end

reg clk_en ;
always @ (TE or clk_en_af_latch )
begin
    clk_en <= clk_en_af_latch || TE ;
end
assign Q = CK && clk_en;

// synopsys translate_on

endmodule
