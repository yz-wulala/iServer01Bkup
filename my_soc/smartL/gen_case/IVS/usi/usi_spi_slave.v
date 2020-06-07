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
// FUNCTION   : usi spi slave test
// METHOD     : 
// NOTE       : 
// ***************************************************************************
module usi_spi_slave();

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

`define nss_in tb.x_soc.x_apb.usi0_nss_in
`define nss_ie tb.x_soc.x_apb.usi0_nss_ie
`define nss_out tb.x_soc.x_apb.usi0_nss_out
`define nss_oe tb.x_soc.x_apb.usi0_nss_oe

`define rst tb.x_soc.pad_cpu_rst_b

parameter delay=500;

wire miso;
reg mosi;
reg sck;
reg nss;
reg [15:0] test_data;

//assign sck = `sck_oe?`sck_out:1'bz;
assign `sck_in = `sck_ie?sck:1'bz;

//assign mosi = `mosi_oe?`mosi_out:1'bz;
assign `mosi_in = `mosi_ie?mosi:1'bz;

assign miso = `miso_oe?`miso_out:1'bz;
assign `miso_in = `miso_ie?miso:1'bz;

//assign nss = `nss_oe?`nss_out:1'bz;
assign `nss_in = `nss_ie?nss:1'bz;

task spi_do;
    input [7:0]spi_in;
    begin
    #(2*delay)
    nss=1'b0;
    mosi=spi_in[7];
    #(delay)
    sck=1'b1;
    #(delay)
    sck=1'b0;
    mosi=spi_in[6];
    #(delay)
    sck=1'b1;
    #(delay)
    sck=1'b0;
    mosi=spi_in[5];
    #(delay)
    sck=1'b1;
    #(delay)
    sck=1'b0;
    mosi=spi_in[4];
    #(delay)
    sck=1'b1;
    #(delay)
    sck=1'b0;
    mosi=spi_in[3];
    #(delay)
    sck=1'b1;
    #(delay)
    sck=1'b0;
    mosi=spi_in[2];
    #(delay)
    sck=1'b1;
    #(delay)
    sck=1'b0;
    mosi=spi_in[1];
    #(delay)
    sck=1'b1;
    #(delay)
    sck=1'b0;
    mosi=spi_in[0];
    #(delay)
    sck=1'b1;
    #(delay)
    sck=1'b0;
    #(delay)
    nss=1'b1;
    end
endtask


initial
begin
   $display("************Test Begin************");
   #55000
   nss=1'b1;
   sck=1'b0;
   $display("************SPI Trans 0x12************");
   spi_do(8'h12);
   $display("************SPI Trans 0x34************");
   spi_do(8'h34);
   $display("************SPI Trans 0x56************");
   spi_do(8'h56);
   $display("************SPI Trans 0x78************");
   spi_do(8'h78);
end
endmodule

