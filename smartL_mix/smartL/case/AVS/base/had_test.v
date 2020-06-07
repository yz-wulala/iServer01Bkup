// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : weidy
// CSKYCPU    : 801 802 803
// HWCFIG     :
// SMART_R    : yes  
// FUNCTION   : 
// METHOD     : 
// NOTE       : this cace tells user to know how to control jtag signal to
//              let CPU enter the debug mode
// ****************************************************************************
//*****************************************************************************
//Attention!!!:the main purpose of this case is give an example to user,and
//             let user to know how to force jtag signal in debug mode.If
//             you wanna to run this case ,please instance this module in
//             your test banch ,and set the path of cpu Jtag signal in your
//             SOC.                
//*****************************************************************************
module had_test();
`define JTAG_PATH                        tb.x_soc.x_cpu_sub_system_ahb

`define had_pad_jdb_pm                   `JTAG_PATH.had_pad_jdb_pm[1:0]
`define had_pad_jtg_tap_on               `JTAG_PATH.had_pad_jtg_tap_on
`define pad_sysio_dbgrq_b                `JTAG_PATH.pad_sysio_dbgrq_b
`define pad_had_jdb_req_b                `JTAG_PATH.pad_had_jdb_req_b
`define pad_had_jtg_tap_en               `JTAG_PATH.pad_had_jtg_tap_en
`define pad_had_jtg_tclk                 `JTAG_PATH.pad_had_jtg_tclk
`define pad_had_jtg_tms_i                `JTAG_PATH.pad_had_jtg_tms_i
`define had_pad_jtg_tms_o                `JTAG_PATH.had_pad_jtg_tms_o
`define had_pad_jtg_tms_oe               `JTAG_PATH.had_pad_jtg_tms_oe
`define pad_had_jtg_trst_b               `JTAG_PATH.pad_had_jtg_trst_b
`define sysio_pad_dbg_b                  `JTAG_PATH.biu_pad_dbg_b



reg [143:0] jtag_data_in  = 32'h8000;
reg [8:0]   jtag_data_len = 32;
reg [7:0]   ir_value      = 7'b0001101;//hcr
reg [31:0]  rst_cycle     = 100;
reg [143:0] jtag_data_out;
integer i;
reg  parity;
static integer FILE;
initial
begin
  //reset jtag
  force `pad_had_jtg_trst_b = 1'b1;
  force `pad_had_jtg_tms_i = 1'b1;
  //wait until posedge tclk
  @(negedge `pad_had_jtg_tclk); 
  force `pad_had_jtg_trst_b = 1'b0;

  //wait for user specified cycles
  for(i=0; i<rst_cycle; i=i+1)
    @(negedge `pad_had_jtg_tclk);
  force `pad_had_jtg_trst_b = 1'b1;
  //drive TAP state machine into IDLE state
  @(negedge `pad_had_jtg_tclk);
  @(negedge `pad_had_jtg_tclk);
    force `pad_had_jtg_tms_i = 1'b1;

//****************************************************
// set DR
//****************************************************
    //step1:write value into the IR register to select HCR
    parity = 1'b1;
    @(negedge `pad_had_jtg_tclk); // start
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // read/write
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[0]
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[1]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk);
    for(i=0; i<8; i=i+1)begin
      force `pad_had_jtg_tms_i = ir_value[i];
      parity = parity ^ ir_value[i];
      @(negedge `pad_had_jtg_tclk); // Shift IR 
    end
    force `pad_had_jtg_tms_i = parity;
    @(negedge `pad_had_jtg_tclk); // Parity
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // IDLE
    
    //step2:write_Dr(32'h8000,32)
    //note: write value 32'h8000  shift into the HCR to set DR bit
    parity = 1'b1;
    @(negedge `pad_had_jtg_tclk); // start
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // read/write
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[0]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // RS[1]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk);
    for(i=0; i<32; i=i+1)begin
      force `pad_had_jtg_tms_i = jtag_data_in[i];
      parity = parity ^ jtag_data_in[i];
      @(negedge `pad_had_jtg_tclk); // Shift DR 
    end
    force `pad_had_jtg_tms_i = parity; // Parity
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Drive to IDLE
    force `pad_had_jtg_tms_i = 1'b1;  
//************* NOW CPU IS IN THE DEBUG MODE**********//
//****************************************************
// read register HCR 
//****************************************************
    //step1:write value into the IR register to select HCR
     parity = 1'b1;
    ir_value[7:0] =8'b10001101;
    @(negedge `pad_had_jtg_tclk); // start
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // read/write
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[0]
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[1]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk);
    for(i=0; i<8; i=i+1)begin
      force `pad_had_jtg_tms_i = ir_value[i];
      parity = parity ^ ir_value[i];
      @(negedge `pad_had_jtg_tclk); // Shift IR 
    end
    force `pad_had_jtg_tms_i = parity;
    @(negedge `pad_had_jtg_tclk); // Parity
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // IDLE
    //step2 :read_dr
    //note  :shift the data off from the register ,you can get the data by
    //       had_pad_jtg_tms_o
    jtag_data_out = 144'b0;
    parity = 1'b1;
    @(negedge `pad_had_jtg_tclk); // start
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // read/write
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // RS[0]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // RS[1]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;    
    @(posedge `pad_had_jtg_tclk);
    @(posedge `pad_had_jtg_tclk); // Sync cycle
    for(i=0; i<32; i=i+1)begin
      @(posedge `pad_had_jtg_tclk); // Shift DR 
      jtag_data_out[i] = `had_pad_jtg_tms_o;//shift the data into jtag_data_out[143:0]
    end
    @(posedge `pad_had_jtg_tclk); // Parity
    parity = `had_pad_jtg_tms_o;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // to IDLE
    force `pad_had_jtg_tms_i = 1'b1;    
    if(!(jtag_data_out == 32'h8000))
    begin
    $display("ERROR!!:sorry,jtag signal may not be conected correctly,please check it");
    $finish;
    end
    else
    begin
    $display("**************************************************");  
    $display("*********** Congratulation!:HAD TEST PASS  *******");
    $display("**************************************************");
    FILE = $fopen("run_case.report","w");
    $fdisplay(FILE,"TEST PASS");
    $finish;
    end
 end    
endmodule
