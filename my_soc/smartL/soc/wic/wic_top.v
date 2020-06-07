// * This file and all its contents are properties of C-Sky Microsystems. The  *
// * information contained herein is confidential and proprietary and is not   *
// * to be disclosed outside of C-Sky Microsystems except under a              *
// * Non-Disclosure Agreement (NDA).                                           *
// *                                                                           *
// *****************************************************************************
// FILE NAME       : wic_top.vp
// AUTHOR          : Tao Jiang
// ORIGINAL TIME   : 2017.06.02
// FUNCTION        : 1.sample int 
//                 : 2.send int req to pmu unit and intc unit
//                 :
//                 :   
//                 :   
// RESET           : Async reset
// DFT             :
// DFP             :
// VERIFICATION    :
// RELEASE HISTORY :
// *****************************************************************************


// &Depend("cpu_cfig.h"); @23
// &ModuleBeg; @24
module wic_top(
  biu_pad_psr,
  ctl_xx_awake_enable,
  intraw_vld,
  pad_cpu_rst_b,
  pad_vic_int_cfg,
  pad_vic_int_vld,
  pad_wic_int_vld,
  wic_clk
);

// &Ports; @25
input   [31:0]  biu_pad_psr;             
input   [31:0]  ctl_xx_awake_enable; 
input           pad_cpu_rst_b;      
input           wic_clk;    
input   [31:0]  pad_wic_int_vld;        
output          intraw_vld;         
output  [31:0]  pad_vic_int_cfg;    
output  [31:0]  pad_vic_int_vld;    

// &Regs; @26
reg     [31:0]  arb_int_ack;        
reg     [31:0]  arb_int_ack_ff;     

// &Wires; @27
wire    [31:0]  arb_int_ack_clr;    
wire    [31:0]  biu_pad_psr;              
wire    [31:0]  ctl_xx_awake_enable; 
wire    [7 :0]  gpio_vic_int;       
wire    [4 :0]  int_ack_vec;        
wire    [31:0]  int_pending;        
wire            intraw_vld;         
wire            pad_cpu_rst_b;      
wire    [31:0]  pad_vic_int_cfg;    
wire    [31:0]  pad_vic_int_vld;    
wire    [31:0]  pad_wic_int_cfg;    
wire    [31:0]  pad_wic_int_vld;    
wire    [31:0]  wic_awake_en;
wire    [31:0]  pending_clr;        
wire            pulse_int;          
wire            vec_int;            
wire            wic_clk;            



// &Force("bus", "biu_pad_psr", 31, 0); @30

assign vec_int = biu_pad_psr[23:21] == 3'b001;
assign int_ack_vec[4:0] = biu_pad_psr[20:16];

always @( int_ack_vec[4:0])
begin
  case(int_ack_vec[4:0])
    5'd0   : arb_int_ack[31:0] = 32'b00000000000000000000000000000001;
    5'd1   : arb_int_ack[31:0] = 32'b00000000000000000000000000000010;
    5'd2   : arb_int_ack[31:0] = 32'b00000000000000000000000000000100;
    5'd3   : arb_int_ack[31:0] = 32'b00000000000000000000000000001000;
    5'd4   : arb_int_ack[31:0] = 32'b00000000000000000000000000010000;
    5'd5   : arb_int_ack[31:0] = 32'b00000000000000000000000000100000;
    5'd6   : arb_int_ack[31:0] = 32'b00000000000000000000000001000000;
    5'd7   : arb_int_ack[31:0] = 32'b00000000000000000000000010000000;
    5'd8   : arb_int_ack[31:0] = 32'b00000000000000000000000100000000;
    5'd9   : arb_int_ack[31:0] = 32'b00000000000000000000001000000000;
    5'd10  : arb_int_ack[31:0] = 32'b00000000000000000000010000000000;
    5'd11  : arb_int_ack[31:0] = 32'b00000000000000000000100000000000;
    5'd12  : arb_int_ack[31:0] = 32'b00000000000000000001000000000000;
    5'd13  : arb_int_ack[31:0] = 32'b00000000000000000010000000000000;
    5'd14  : arb_int_ack[31:0] = 32'b00000000000000000100000000000000;
    5'd15  : arb_int_ack[31:0] = 32'b00000000000000001000000000000000;
    5'd16  : arb_int_ack[31:0] = 32'b00000000000000010000000000000000;
    5'd17  : arb_int_ack[31:0] = 32'b00000000000000100000000000000000;
    5'd18  : arb_int_ack[31:0] = 32'b00000000000001000000000000000000;
    5'd19  : arb_int_ack[31:0] = 32'b00000000000010000000000000000000;
    5'd20  : arb_int_ack[31:0] = 32'b00000000000100000000000000000000;
    5'd21  : arb_int_ack[31:0] = 32'b00000000001000000000000000000000;
    5'd22  : arb_int_ack[31:0] = 32'b00000000010000000000000000000000;
    5'd23  : arb_int_ack[31:0] = 32'b00000000100000000000000000000000;
    5'd24  : arb_int_ack[31:0] = 32'b00000001000000000000000000000000;
    5'd25  : arb_int_ack[31:0] = 32'b00000010000000000000000000000000;
    5'd26  : arb_int_ack[31:0] = 32'b00000100000000000000000000000000;
    5'd27  : arb_int_ack[31:0] = 32'b00001000000000000000000000000000;
    5'd28  : arb_int_ack[31:0] = 32'b00010000000000000000000000000000;
    5'd29  : arb_int_ack[31:0] = 32'b00100000000000000000000000000000;
    5'd30  : arb_int_ack[31:0] = 32'b01000000000000000000000000000000;
    5'd31  : arb_int_ack[31:0] = 32'b10000000000000000000000000000000;
    default: arb_int_ack[31:0] = 32'bx;
  endcase
end

assign arb_int_ack_clr[31:0] = vec_int ? arb_int_ack[31:0] : 32'b0;  

always@(posedge wic_clk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
    arb_int_ack_ff[31:0] <= 32'b0;
  else
    arb_int_ack_ff[31:0] <= arb_int_ack_clr[31:0];
end



//     &Force("nonport", "arb_int_ack"); @88
//     &Force("nonport", "arb_int_ack_ff"); @89
  assign pending_clr[31:0] = arb_int_ack_clr[31:0] & ~arb_int_ack_ff[31:0];




assign pad_wic_int_cfg[31:0] = 32'b0;

assign intraw_vld =|(int_pending[31:0] & ctl_xx_awake_enable[31:0]);
assign pad_vic_int_vld[31:0] = int_pending[31:0];
assign pad_vic_int_cfg[31:0] = 32'b0;
// &Force("nonport", "wic_awake_en"); @166


// &Instance("wic_awake_en_32", "x_wic_awake_en"); @170
wic_awake_en_32  x_wic_awake_en (
  .awake_data            (32'b0                ),
  .awake_disable         (1'b0                 ),
  .awake_enable          (1'b0                 ),
  .int_cfg               (pad_wic_int_cfg[31:0]),
  .int_exit              (32'hffffffff         ),
  .int_pending           (int_pending[31:0]    ),
  .int_vld               (pad_wic_int_vld[31:0]),
  .pad_cpu_rst_b         (pad_cpu_rst_b        ),
  .pending_clr           (pending_clr          ),
  .wic_awake_en          (wic_awake_en[31:0]   ),
  .wic_clk               (wic_clk              )
);


endmodule












