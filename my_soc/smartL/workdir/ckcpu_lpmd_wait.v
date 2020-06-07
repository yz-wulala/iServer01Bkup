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
module ckcpu_lpmd_wait();

`define ext_in tb.x_soc.x_apb.gpio_porta_in[0]


reg ext;

assign `ext_in=ext;

initial
begin
    ext=1'b0;
    $display("************ ************");
    #55000
    
    #5000
    ext=~ext;
    #5000
    ext=~ext;
    #5000
    ext=~ext;
    #5000
    ext=~ext;
    #5000
    ext=~ext;
    #5000
    ext=~ext;
    #5000
    ext=~ext;
    #5000
    ext=~ext;
    #5000
    ext=~ext;
    #5000
    ext=~ext;
    #5000
    ext=~ext;
    #5000
    ext=~ext;
    #5000
    ext=~ext;
end
endmodule

