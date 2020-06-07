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
// AUTHOR       : Tao Jiang
// CSKYCPU      : 801 802 803 804
// HWCFIG       : 
// SMART_R      : yes 
// FUNCTION     : test wakeup by writing jtag
// CTS          : no
// METHOD       : 
// NOTE         : run this file with ckcpu_lpmd_dbg.s
// ****************************************************************************


module had_test();
`define JTAG_PATH                        tb.x_soc.x_cpu_sub_system_ahb

`define pad_had_jtg_tclk                 `JTAG_PATH.pad_had_jtg_tclk
`define pad_had_jtg_tms_i                `JTAG_PATH.pad_had_jtg_tms_i
`define pad_had_jtg_trst_b               `JTAG_PATH.pad_had_jtg_trst_b
`define biu_pad_lpmd_b                   `JTAG_PATH.biu_pad_lpmd_b

reg [143:0] jtag_data_in  = 32'h8000;
reg [7:0]   ir_value      = 7'b0001101;//hcr
reg [1:0]   lpmd_b        =  2'b00;
reg [31:0]  rst_cycle     = 100;
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
  for(i=0; i<rst_cycle; i=i+1) begin
    @(negedge `pad_had_jtg_tclk);
  end
  force `pad_had_jtg_trst_b = 1'b1;
  //drive TAP state machine into IDLE state
  @(negedge `pad_had_jtg_tclk);
  @(negedge `pad_had_jtg_tclk);
  force `pad_had_jtg_tms_i = 1'b1;
  #10;
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

    #1000;
    if(`biu_pad_lpmd_b != 2'b11)
    begin
    $display("ERROR!!:sorry,jtag signal didn't wake up lpmd");
    $finish;
    end
    else
    begin
    $display("**************************************************");  
    $display("*********** Congratulation!:Wake up success*******");
    $display("**************************************************");
    FILE = $fopen("run_case.report","w");
    $fdisplay(FILE,"TEST PASS");
    $finish;
    end
 end    
endmodule
