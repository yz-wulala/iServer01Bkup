// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : Lei Ye
// CSKYCPU    : 801 802 803 804
// HWCFIG     : 
// SMART_R    : yes 
// FUNCTION   : usi uart test
// METHOD     : 
// NOTE       : 
// ***************************************************************************
module usi_uart();

`define rxd_in tb.x_soc.x_apb.usi0_sclk_in
`define rxd_ie tb.x_soc.x_apb.usi0_sclk_ie
`define rxd_out tb.x_soc.x_apb.usi0_sclk_out
`define rxd_oe tb.x_soc.x_apb.usi0_sclk_oe

`define txd_in tb.x_soc.x_apb.usi0_sd0_in
`define txd_ie tb.x_soc.x_apb.usi0_sd0_ie
`define txd_out tb.x_soc.x_apb.usi0_sd0_out
`define txd_oe tb.x_soc.x_apb.usi0_sd0_oe

wire txd;
wire rxd;

assign `txd_in=`txd_ie?txd:1'bz;
assign txd=`txd_oe?`txd_out:1'bz;

assign `rxd_in=`rxd_ie?rxd:1'bz;
assign rxd=`rxd_oe?`rxd_out:1'bz;

assign rxd=txd;

initial
begin

  $display("************ ************");

end
endmodule

