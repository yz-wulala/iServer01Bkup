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
// FILE NAME: ck802_had_test_jtag.v
// CSKYCPU    : 802
// AUTHOR: Kuan Zhao
// FUNCTION: Enumerate the methods to enter into debug mode and  access CPU 
//           resource, then exit to debug mode. 
// NOTE:     In ck802, there are no pcfifo, ADR, pad_biu_dbgrq_b,
//           pad_biu_brkrq_b[1:0] and SQC.

`include "../tb/had_drv.h"
module had_test();

`define pad_had_jdb_req_b tb.x_soc.x_cpu_sub_system_ahb.pad_had_jdb_req_b
`define lpmd_b tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_core_top.x_nm_core.x_nm_cp0_top.x_nm_cp0_lpmd.IIOOOOIOOIOOOOOOI[1:0]
//`define jtag_tms tb.x_soc.x_cpu_sub_system_ahb.x_ck802.x_nm_had_top.x_nm_had_sm2.pin_xx_tms_i
`define jtag_tms tb.x_soc.i_pad_jtg_tms
reg[31:0] pc_data_out;
reg[31:0] psr_data_out;
initial
  begin

  `ifdef JTAG_5
    $display("******	Now is JTAG_5!!!	******");
    jtag_rst(32'b10);
    wait(`lpmd_b == 2'b01);
  `else 
    $display("******    Now is JTAG_2!!!        ******");
    jtag_rst(32'b10);
    wait(`lpmd_b == 2'b01);
    repeat (86) @(posedge `jtag_tclk);        //coverage synv reset for HACR. 
  `endif
 
//==============================================//
// enter debug mode through the signal          //
// pad_had_jdb_req_b                            //
//==============================================//
//    force `pad_had_jdb_req_b = 1'b0;
//    wait_debug_mode;
//    $display("Enter debug mode by pad_had_jdb_req_b!");
//    force `pad_had_jdb_req_b = 1'b1;
//    read_hadreg(`pc,pc_data_out);
//    write_hadreg(`pc_go_ex,pc_data_out);
//

//==============================================//
//set DR enter into debug mode and clear DR.    //
//==============================================//
    write_hadreg(`hcr,32'h8000);       //set DR to enter debug mode
    wait_debug_mode;
    write_hadreg(`hcr,0);              //clear DR
    $display("Enter debug mode by DR bit!");
    read_hadreg(`psr,psr_data_out);
    write_hadreg(`psr,32'h0);
    write_hadreg(`psr,psr_data_out);           //coverage for psr
    read_hadreg(`pc,pc_data_out);
//    write_hadreg(`pc_go_ex,pc_data_out);
//
//
////==============================================//
//// enter debug mode through the signal          //
//// pad_biu_dbgrq_b                              //
////==============================================//
//    write_hadreg(`hcr,32'h4000);             //set IDRE
//    force `pad_biu_dbgrq_b = 1'b0;
//    wait_debug_mode;
//    $display("Enter debug mode by pad_biu_dbgrq_b!");
//    force `pad_biu_dbgrq_b = 1'b1;
//    read_hadreg(`pc,pc_data_out);
    write_hadreg(`mbca,8'h2);
    write_hadreg(`bama,8'hff);
    write_hadreg(`baba,pc_data_out);        //prepare registers for memory breakpoint A
    write_hadreg(`csr,16'h80);                  //set FDB
//coverage for bca/bcb
    write_hadreg(`hcr,32'h82);
    write_hadreg(`hcr,32'hc3);
    write_hadreg(`hcr,32'h104);
    write_hadreg(`hcr,32'h145);
    write_hadreg(`hcr,32'h186);

    write_hadreg(`hcr,32'h451);   
    write_hadreg(`hcr,32'h492); 
    write_hadreg(`hcr,32'h4d3);
    write_hadreg(`hcr,32'h514);
    write_hadreg(`hcr,32'h555);
    write_hadreg(`hcr,32'h596);     //user mode

    write_hadreg(`hcr,32'h659);
    write_hadreg(`hcr,32'h69a);
    write_hadreg(`hcr,32'h6db);
    write_hadreg(`hcr,32'h71c);
    write_hadreg(`hcr,32'h75d);
    write_hadreg(`hcr,32'h79e);
//end

    write_hadreg(`hcr,32'h1);                   //enable mbkpt A
    write_hadreg(`pc_go_ex,pc_data_out);


//==============================================//
// enter debug mode through memory breakpoint   //
// A or B                                       //
//==============================================//
    wait_debug_mode;
    $display("Enter debug mode by memory breakpoint A!");
    read_hadreg(`pc,pc_data_out);
    write_hadreg(`mbcb,8'h2);
    write_hadreg(`bamb,8'hff);
    write_hadreg(`babb,pc_data_out);        //prepare registers for memory breakpoint B
    write_hadreg(`csr,16'h80);                  //set FDB
    write_hadreg(`hcr,32'h40);              //enable memory breakpoint B
    write_hadreg(`pc_go_ex,pc_data_out);


//now is memory breakpoint B
    wait_debug_mode;
    $display("Enter debug mode by memory breakpoint B!");
    read_hadreg(`pc,pc_data_out);
    write_hadreg(`tracer,8'h0f);
    write_hadreg(`hcr,32'h2000);                //enable trace mode 
    write_hadreg(`pc_go_ex,pc_data_out);

//==============================================//
// enter debug mode through trace mode          //
//==============================================//
    wait_debug_mode;
    $display("Enter debug mode by trace mode!");
    write_hadreg(`hcr,32'h0);                   //disable trace mode
    write_hadreg(`csr,16'h80);                  //set FDB    
    read_hadreg(`pc,pc_data_out);
    write_hadreg(`pc_go_ex,pc_data_out+2);


    
//==============================================//
// enter debug mode through the inst "bkpt"     //
//==============================================//

    wait_debug_mode;
    $display("Enter debug mode by sbkpt!");
    write_hadreg(`csr,16'h0);                  //clear FDB
//==============================================//
// execute insts in debug mode to access the    //
// CPU resource                                 // 
//==============================================//
    write_hadreg(`csr,16'h0);        //clear FFY
    write_hadreg(`wbbr,32'h0);
    write_hadreg(`ir_go_nex,`MOV_R6_R6);
    write_hadreg(`csr,16'h100);      //set FFY
    write_hadreg(`ir_go_nex,`MOV_R7_R7);          //equal to execute inst "mov r7,r6"

    write_hadreg(`ir_go_nex,32'hc0066421);        //mtcr r6,cr<1,0>
    write_hadreg(`ir_go_nex,32'hc0016022);        //mfcr r2,cr<1,0>
                                        
    write_hadreg(`csr,16'h0);                     //clear FFY
    write_hadreg(`ir_go_nex,32'hdcc52000);        //st.w r6,(r5,0)
    write_hadreg(`ir_go_nex,32'hd8652000);        //ld.w r3,(r5,0)

//==============================================//
// enable DDC mode and download data in memory  //
//==============================================//
    write_hadreg(`hcr,32'h100000);              //enable DDC mode
    write_hadreg(`daddr,32'h0000fff0);
    write_hadreg(`hcr,32'h0);                   //for ddc cvoerage
    write_hadreg(`hcr,32'h100000);              //enable DDC mode
    write_hadreg(`daddr,32'h0000fff0);
    write_hadreg(`ddata,32'hf0);
    write_hadreg(`ddata,32'hff);

    read_hadreg(`pc,pc_data_out);
    write_hadreg(`pc_go_ex,pc_data_out +2);

  end
endmodule
