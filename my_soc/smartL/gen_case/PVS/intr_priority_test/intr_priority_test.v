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
module intr_priority_test();

`define in_a tb.x_soc.x_apb.x_gpio.gpio_porta_in[0]
`define in_b tb.x_soc.x_apb.x_gpio.gpio_porta_in[1]

reg test_a; // intr 0x22; 04
reg test_b; // intr 0x23; 08

assign `in_a = test_a;
assign `in_b = test_b;

initial
begin

    $display("************ ************");
    test_a = 0;
    test_b = 0;
    #100000
    $display("signal a rising edge");
    test_a = 1;
    #6500
    $display("signal b rising edge");
    test_b = 1;
    #50000;
    $finish;
end
endmodule

