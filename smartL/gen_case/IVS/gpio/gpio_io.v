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
// ****************************************************************************

module gpio_io();

`define b_pad_porta tb.x_soc.b_pad_gpio_porta[7:0]

initial
begin

  wait(`b_pad_porta == 8'hff);
  $display("************gpio port a output test pass!************");
  
  force `b_pad_porta = 8'hff;
end
endmodule
