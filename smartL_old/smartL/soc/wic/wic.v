// *****************************************************************************
// *                                                                           *
// * C-Sky Microsystems Confidential                                           *
// * -------------------------------                                           *
// * This file and all its contents are properties of C-Sky Microsystems. The  *
// * information contained herein is confidential and proprietary and is not   *
// * to be disclosed outside of C-Sky Microsystems except under a              *
// * Non-Disclosure Agreement (NDA).                                           *
// *                                                                           *
// *****************************************************************************
// FILE NAME       : wic.vp
// AUTHOR          : Tao Jiang
// ORIGINAL TIME   : 2017.05.22
// FUNCTION        : sample pulse sensitive int,event and debug write in lpmd
//                 : and generate intraw signal
//                 :
//                 :   
//                 :   
// RESET           : Async reset
// DFT             :
// DFP             :
// VERIFICATION    :
// RELEASE HISTORY :
// *****************************************************************************
// &Depend("cpu_cfig.h"); @25
// &Depend("environment.h"); @26

// &ModuleBeg; @28
module wic(
  awake_data,
  awake_disable,
  awake_enable,
  int_cfg,
  int_exit,
  int_pending,
  int_vld,
  pad_cpu_rst_b,
  pending_clr,
  wic_awake_en,
  wic_clk
);

// &Ports; @29
input        awake_data;   
input        awake_disable; 
input        awake_enable; 
input        int_cfg;      
input        int_exit;     
input        int_vld;      
input        pad_cpu_rst_b; 
input        pending_clr;  
input        wic_clk;      
output       int_pending;  
output       wic_awake_en; 

// &Regs; @30
reg          int_pending;  
reg          int_vld_ff;   
reg          wic_awake_en; 

// &Wires; @31
wire         awake_data;   
wire         awake_disable; 
wire         awake_enable; 
wire         int_cfg;      
wire         int_exit;     
wire         int_level;    
wire         int_pulse;    
wire         int_vld;      
wire         pad_cpu_rst_b; 
wire         pending_clr;  
wire         wic_clk;      


//always@(posedge wic_clk or negedge pad_cpu_rst_b)
//begin
//  if (!pad_cpu_rst_b)
//    pending_ctrl_ff <= 1'b0;
//  else 
//    pending_ctrl_ff <= pending_ctrl;
//end

 
always@(posedge wic_clk or negedge pad_cpu_rst_b)
begin
  if (!pad_cpu_rst_b)
    wic_awake_en <= 1'b0;
  else if (awake_enable && awake_data)
    wic_awake_en <= 1'b1;
  else if (awake_disable && awake_data)
    wic_awake_en <= 1'b0;
end
//------------------------------------------------
//   sample level-sensitive interrupt
//------------------------------------------------

assign int_level = int_vld && !int_cfg && int_exit; 

//------------------------------------------------
//   sample pulse-sensitive interrupt
//------------------------------------------------
always@(posedge wic_clk or negedge pad_cpu_rst_b)
begin
  if (!pad_cpu_rst_b)
    int_vld_ff <= 1'b0;
  else 
    int_vld_ff <= int_vld;
end

assign int_pulse = int_vld && !int_vld_ff;

//------------------------------------------------
//        int  pending
//------------------------------------------------
always@(posedge wic_clk or negedge pad_cpu_rst_b)
begin
  if(!pad_cpu_rst_b)
    int_pending <= 1'b0;
  else if (!int_cfg)
    int_pending <= int_level;
  else if (pending_clr)
    int_pending <= 1'b0;
  else if(int_cfg)
    int_pending <= int_pulse;
end
// &ModuleEnd; @98
endmodule



