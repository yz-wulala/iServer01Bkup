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
// FUNCTION   : usi spi master test
// METHOD     : 
// NOTE       : 
// ***************************************************************************
module usi_spi_master();

`define sck_in tb.x_soc.x_apb.usi0_sclk_in
`define sck_ie tb.x_soc.x_apb.usi0_sclk_ie
`define sck_out tb.x_soc.x_apb.usi0_sclk_out
`define sck_oe tb.x_soc.x_apb.usi0_sclk_oe

`define mosi_in tb.x_soc.x_apb.usi0_sd0_in
`define mosi_ie tb.x_soc.x_apb.usi0_sd0_ie
`define mosi_out tb.x_soc.x_apb.usi0_sd0_out
`define mosi_oe tb.x_soc.x_apb.usi0_sd0_oe

`define miso_in tb.x_soc.x_apb.usi0_sd1_in
`define miso_ie tb.x_soc.x_apb.usi0_sd1_ie
`define miso_out tb.x_soc.x_apb.usi0_sd1_out
`define miso_oe tb.x_soc.x_apb.usi0_sd1_oe

`define rst tb.x_soc.pad_cpu_rst_b

wire miso;
wire mosi;
wire sck;
reg [15:0] test_data;

assign sck = `sck_oe?`sck_out:1'bz;
assign `sck_in = `sck_ie?sck:1'bz;

assign mosi = `mosi_oe?`mosi_out:1'bz;
assign `mosi_in = `mosi_ie?mosi:1'bz;

assign miso = `miso_oe?`miso_out:1'bz;
assign `miso_in = `miso_ie?miso:1'bz;

always @(negedge sck or negedge `rst) begin
    if(~`rst) begin
        test_data <= 16'h203D;
    end
    else begin
        test_data <= {test_data[14:0],test_data[15]};
    end
end
assign miso=test_data[15];

initial
begin

  $display("************ ************");

end
endmodule

