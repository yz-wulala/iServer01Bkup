// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : zhaor
// CSKYCPU    : 801 802 803 804
// HWCFIG     : 
// SMART_R    : yes 
// FUNCTION   : gpio test
// METHOD     : 
// NOTE       : 
// ***************************************************************************
module gpio_intr();
`define intr_pclk tb.x_soc.x_apb.x_gpio.pclk_intr
`define ext_int tb.x_soc.b_pad_gpio_porta[7:0]
//`define ext_int1 tb.x_soc.b_pad_gpio_porta[1]
//`define ext_int2 tb.x_soc.b_pad_gpio_porta[2]
//`define ext_int3 tb.x_soc.b_pad_gpio_porta[3]
//`define ext_int4 tb.x_soc.b_pad_gpio_porta[4]
//`define ext_int5 tb.x_soc.b_pad_gpio_porta[5]
//`define ext_int6 tb.x_soc.b_pad_gpio_porta[6]
//`define ext_int7 tb.x_soc.b_pad_gpio_porta[7]

`define int_cpu0 tb.x_soc.x_apb.x_gpio.gpio_intr[0]
`define int_cpu1 tb.x_soc.x_apb.x_gpio.gpio_intr[1]
`define int_cpu2 tb.x_soc.x_apb.x_gpio.gpio_intr[2]
`define int_cpu3 tb.x_soc.x_apb.x_gpio.gpio_intr[3]
`define int_cpu4 tb.x_soc.x_apb.x_gpio.gpio_intr[4]
`define int_cpu5 tb.x_soc.x_apb.x_gpio.gpio_intr[5]
`define int_cpu6 tb.x_soc.x_apb.x_gpio.gpio_intr[6]
`define int_cpu7 tb.x_soc.x_apb.x_gpio.gpio_intr[7]

`define int_enable tb.x_soc.x_apb.x_gpio.x_gpio_apbif.gpio_inten[7:0]
initial
begin
  wait(`int_enable == 8'b11111111);
  $display("*********TEST INT BEGIN*********");
  force `ext_int = 8'b0000_0001;
  wait(`int_cpu0 == 1'b1);
  wait(`int_cpu0 == 1'b0);
  force `ext_int = 8'b0000_0000;
  $display("*********INT[0] SUCCESS!*********");
  
  force `ext_int = 8'b0000_0010;
  wait(`int_cpu1 == 1'b1);
  wait(`int_cpu1 == 1'b0);
  force `ext_int = 8'b0000_0000;
  $display("*********INT[1] SUCCESS!*********");

  force `ext_int = 8'b0000_0100;
  wait(`int_cpu2 == 1'b1);
  wait(`int_cpu2 == 1'b0);
  force `ext_int = 8'b0000_0000;
  $display("*********INT[2] SUCCESS!*********");

  force `ext_int = 8'b0000_1000;
  wait(`int_cpu3 == 1'b1);
  wait(`int_cpu3 == 1'b0);
  force `ext_int = 8'b0000_0000;
  $display("*********INT[3] SUCCESS!*********");
  
  force `ext_int = 8'b0001_0000;
  wait(`int_cpu4 == 1'b1);
  wait(`int_cpu4 == 1'b0);
  force `ext_int = 8'b0000_0000;
  $display("*********INT[4] SUCCESS!*********");

  force `ext_int = 8'b0010_0000;
  wait(`int_cpu5 == 1'b1);
  wait(`int_cpu5 == 1'b0);
  force `ext_int = 8'b0000_0000;
  $display("*********INT[5] SUCCESS!*********");

  force `ext_int = 8'b0100_0000;
  wait(`int_cpu6 == 1'b1);
  wait(`int_cpu6 == 1'b0);
  force `ext_int = 8'b0000_0000;
  $display("*********INT[6] SUCCESS!*********");
  
  force `ext_int = 8'b1000_0000;
  wait(`int_cpu7 == 1'b1);
  wait(`int_cpu7 == 1'b0);
  force `ext_int = 8'b0000_0000;
  $display("*********INT[7] SUCCESS!*********");

end
endmodule

