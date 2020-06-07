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
  ctim_int_vld,
  ctl_xx_awake_enable,
  gpio_vic_int,
  intraw_vld,
  pad_cpu_rst_b,
  pad_vic_int_cfg,
  pad_vic_int_vld,
  pulse_int,
  stim_vic_int,
  tim_vic_int,
  uart0_vic_int,
  wic_clk
);

// &Ports; @25
input   [31:0]  biu_pad_psr;        
input           ctim_int_vld;       
input   [31:0]  ctl_xx_awake_enable; 
input   [7 :0]  gpio_vic_int;       
input           pad_cpu_rst_b;      
input           pulse_int;          
input   [3 :0]  stim_vic_int;       
input   [3 :0]  tim_vic_int;        
input           uart0_vic_int;      
input           wic_clk;            
output          intraw_vld;         
output  [31:0]  pad_vic_int_cfg;    
output  [31:0]  pad_vic_int_vld;    

// &Regs; @26
reg     [31:0]  arb_int_ack;        
reg     [31:0]  arb_int_ack_ff;     

// &Wires; @27
wire    [31:0]  arb_int_ack_clr;    
wire    [31:0]  biu_pad_psr;        
wire            ctim_int_vld;       
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
wire    [31:0]  pending_clr;        
wire            pulse_int;          
wire    [3 :0]  stim_vic_int;       
wire    [3 :0]  tim_vic_int;        
wire            uart0_vic_int;      
wire            vec_int;            
wire    [31:0]  wic_awake_en;       
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

//----------------------------------------------------------
// instantiate wic
//-------------------------------------------------------------------------

// &Force("nonport", "wic_awake_en"); @119
// &Instance("wic_awake_en_64", "x_wic_awake_en"); @123
// &Connect(.awake_enable   (vic_wic_awake_enable     ), @125
//          .awake_disable  (vic_wic_awake_disable    ), @126
//          .awake_data     (vic_wic_awake_data[63:0] ), @127
//          .int_exit       (vic_wic_int_exit[63:0]   ), @128
//          .pending_set    (vic_wic_pending_set[63:0]), @129
//          .pending_clr    (vic_wic_pending_clr[63:0]), @130
//          .int_vld        (pad_wic_int_vld[63:0]    ), @131
//          .int_cfg        (pad_wic_int_cfg[63:0]    ), @132
//          .wic_awake_en   (wic_awake_en[63:0]       ), @133
//          .int_pending    (int_pending[63:0]        ) @134
//          ); @135
// &Connect(.awake_enable   (1'b0                     ), @137
//          .awake_disable  (1'b0                     ), @138
//          .awake_data     (64'b0                    ), @139
//          .int_exit       (64'hffffffff_ffffffff    ), @140
//          .pending_set    (64'b0                    ), @141
//    //      .pending_clr    (32'b0                    ), @142
//          .int_vld        (pad_wic_int_vld[63:0]    ), @143
//          .int_cfg        (pad_wic_int_cfg[63:0]    ), @144
//          .wic_awake_en   (wic_awake_en[63:0]       ), @145
//          .int_pending    (int_pending[63:0]        ) @146
//          ); @147


assign pad_wic_int_vld[31:0] = {12'b0,pulse_int,stim_vic_int[3:0],gpio_vic_int[7:0],1'b0,
                                tim_vic_int[3:0],ctim_int_vld,uart0_vic_int};
assign pad_wic_int_cfg[31:0] = {12'b0,1'b1,19'b0};

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

// &Connect(.awake_enable   (vic_wic_awake_enable     ), @172
//          .awake_disable  (vic_wic_awake_disable    ), @173
//          .awake_data     (vic_wic_awake_data[31:0] ), @174
//          .int_exit       (vic_wic_int_exit[31:0]   ), @175
//          .pending_set    (vic_wic_pending_set[31:0]), @176
//          .pending_clr    (vic_wic_pending_clr[31:0]), @177
//          .int_vld        (pad_wic_int_vld[31:0]    ), @178
//          .int_cfg        (pad_wic_int_cfg[31:0]    ), @179
//          .wic_awake_en   (wic_awake_en[31:0]       ), @180
//          .int_pending    (int_pending[31:0]        ) @181
//          ); @182
// &Connect(.awake_enable   (1'b0                     ), @184
//          .awake_disable  (1'b0                     ), @185
//          .awake_data     (32'b0                    ), @186
//          .int_exit       (32'hffffffff             ), @187
//          .pending_set    (32'b0                    ), @188
//    //      .pending_clr    (32'b0                    ), @189
//          .int_vld        (pad_wic_int_vld[31:0]    ), @190
//          .int_cfg        (pad_wic_int_cfg[31:0]    ), @191
//          .wic_awake_en   (wic_awake_en[31:0]       ), @192
//          .int_pending    (int_pending[31:0]        ) @193
//          ); @194

// &Force("nonport", "wic_awake_en"); @212
// &Instance("wic_awake_en_16", "x_wic_awake_en"); @216
// &Connect(.awake_enable   (vic_wic_awake_enable     ), @218
//          .awake_disable  (vic_wic_awake_disable    ), @219
//          .awake_data     (vic_wic_awake_data[15:0] ), @220
//          .int_exit       (vic_wic_int_exit[15:0]   ), @221
//          .pending_set    (vic_wic_pending_set[15:0]), @222
//          .pending_clr    (vic_wic_pending_clr[15:0]), @223
//          .int_vld        (pad_wic_int_vld[15:0]    ), @224
//          .int_cfg        (pad_wic_int_cfg[15:0]    ), @225
//          .wic_awake_en   (wic_awake_en[15:0]       ), @226
//          .int_pending    (int_pending[15:0]        ) @227
//          ); @228
// &Connect(.awake_enable   (1'b0                     ), @230
//          .awake_disable  (1'b0                     ), @231
//          .awake_data     (16'b0                    ), @232
//          .int_exit       (16'hffff                 ), @233
//          .pending_set    (16'b0                    ), @234
//    //      .pending_clr    (32'b0                    ), @235
//          .int_vld        (pad_wic_int_vld[15:0]    ), @236
//          .int_cfg        (pad_wic_int_cfg[15:0]    ), @237
//          .wic_awake_en   (wic_awake_en[15:0]       ), @238
//          .int_pending    (int_pending[15:0]        ) @239
//          ); @240

// &Force("nonport", "wic_awake_en"); @258
// &Instance("wic_awake_en_8", "x_wic_awake_en"); @262
// &Connect(.awake_enable   (vic_wic_awake_enable     ), @264
//          .awake_disable  (vic_wic_awake_disable    ), @265
//          .awake_data     (vic_wic_awake_data[7:0] ), @266
//          .int_exit       (vic_wic_int_exit[7:0]   ), @267
//          .pending_set    (vic_wic_pending_set[7:0]), @268
//          .pending_clr    (vic_wic_pending_clr[7:0]), @269
//          .int_vld        (pad_wic_int_vld[7:0]    ), @270
//          .int_cfg        (pad_wic_int_cfg[7:0]    ), @271
//          .wic_awake_en   (wic_awake_en[7:0]       ), @272
//          .int_pending    (int_pending[7:0]        ) @273
//          ); @274
// &Connect(.awake_enable   (1'b0                     ), @276
//          .awake_disable  (1'b0                     ), @277
//          .awake_data     (8'b0                    ), @278
//          .int_exit       (8'hff                   ), @279
//          .pending_set    (8'b0                    ), @280
//    //      .pending_clr    (32'b0                    ), @281
//          .int_vld        (pad_wic_int_vld[7:0]    ), @282
//          .int_cfg        (pad_wic_int_cfg[7:0]    ), @283
//          .wic_awake_en   (wic_awake_en[7:0]       ), @284
//          .int_pending    (int_pending[7:0]        ) @285
//          ); @286

// &ModuleEnd; @290
endmodule












