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
// FILE NAME       : nm_UART_baud_gen.vp
// AUTHOR          : shen xiuhong 
// ORIGINAL TIME   : 
// FUNCTION        : 
// RESET           : 
// DFT             :
// DFP             :
// VERIFICATION    :
// RELEASE HISTORY :
// $Id: uart_baud_gen.vp,v 1.1 2014/06/17 11:42:37 yangjun Exp $
// *****************************************************************************

// &ModuleBeg; @23
module uart_baud_gen(
  ctrl_baud_gen_divisor,
  ctrl_baud_gen_set_dllh_vld,
  receive_clk_en,
  rst_b,
  sys_clk,
  trans_clk_en
);

// &Ports; @24
input   [15:0]  ctrl_baud_gen_divisor;     
input           ctrl_baud_gen_set_dllh_vld; 
input           rst_b;                     
input           sys_clk;                   
output          receive_clk_en;            
output          trans_clk_en;              

// &Regs; @25
reg     [15:0]  clk_counter;               
reg             receive_clk_en;            
reg     [3 :0]  trans_clk_counter;         

// &Wires; @26
wire            clk_divisor_start_en;      
wire            clk_negedge_en;            
wire    [15:0]  ctrl_baud_gen_divisor;     
wire            ctrl_baud_gen_set_dllh_vld; 
wire            divisor_more_then_3;       
wire            rst_b;                     
wire            sys_clk;                   
wire            trans_clk_en;              
wire            trans_clk_posedge_en;      


// //&Force("output","receive_clk"); @28
// //&Force("output","trans_clk"); @29

//---------------------------------------
// divisor == 1
//---------------------------------------
//assign clk_divisor_1 = sys_clk;

//---------------------------------------
// divisor == 2
//---------------------------------------
//always@(posedge sys_clk or negedge rst_b)
//begin
//  if(!rst_b)
//    clk_divisor_2 <= 1'b0;
//  else 
//    clk_divisor_2 <= ~clk_divisor_2;
//end
//
//---------------------------------------
// divisor >= 3
//---------------------------------------
assign clk_divisor_start_en = |ctrl_baud_gen_divisor[15:0];
//assign clk_posedge_en  = (clk_counter[15:0] == 16'b10) ? 1 : 0;
assign clk_negedge_en  = (clk_counter[15:0] == ctrl_baud_gen_divisor[15:0]) ? 1 : 0 ;
 
always@(posedge sys_clk or negedge rst_b) 
begin 
  if(!rst_b) 
    clk_counter[15:0] <= 16'b1;
  else if(ctrl_baud_gen_set_dllh_vld)
    clk_counter[15:0] <= 16'b1;
  else if(clk_negedge_en)
    clk_counter[15:0] <= 1'b1; 
  else if(clk_divisor_start_en)
    clk_counter[15:0] <= clk_counter[15:0]+1;
  else
    clk_counter[15:0] <= clk_counter[15:0];
end
//always@(posedge sys_clk or negedge rst_b)
//begin
//  if(!rst_b)
//    clk_divisor_more <= 1'b0;
//  else if(clk_posedge_en)
//    clk_divisor_more <= 1'b1;
//  else if(clk_negedge_en)
//    clk_divisor_more <= 1'b0;
//  else 
//    clk_divisor_more <= clk_divisor_more;
//end

//----------------------------------------
// receive clk
//----------------------------------------

assign divisor_more_then_3 = |ctrl_baud_gen_divisor[15:2];

// &CombBeg; @85
always @( ctrl_baud_gen_divisor[1:0]
       or clk_negedge_en
       or divisor_more_then_3)
begin
casez({divisor_more_then_3,ctrl_baud_gen_divisor[1:0]})
  3'b000: receive_clk_en = 1'b0;
  3'b001: receive_clk_en = 1'b1;
  3'b010: receive_clk_en = clk_negedge_en;
  3'b011,
  3'b1??: receive_clk_en = clk_negedge_en;
  default: receive_clk_en = 1'b0;
endcase
// &CombEnd; @94
end
// &Force("output","receive_clk_en"); @95
//assign receive_clk = receive_clk_reg;
//----------------------------------------
// trans_clk
//----------------------------------------

always@(posedge sys_clk or negedge rst_b)
begin
  if(!rst_b)
   trans_clk_counter[3:0] <= 4'b0;
  else if(receive_clk_en) 
   trans_clk_counter[3:0] <= trans_clk_counter[3:0] + 1'b1;
  else 
   trans_clk_counter[3:0] <= trans_clk_counter[3:0];
end

assign trans_clk_posedge_en = (trans_clk_counter[3:0] == 4'b1111) ? 1 : 0;
//assign trans_clk_negedge_en = !(|trans_clk_counter[3:0]);
assign trans_clk_en  = receive_clk_en && trans_clk_posedge_en;

//always@(posedge receive_clk  or negedge rst_b)
//begin
//  if(!rst_b)
//    trans_clk_reg <= 1'b0;
//  else if(trans_clk_posedge_en)
//    trans_clk_reg <= 1'b1;
//  else if(trans_clk_negedge_en)
//    trans_clk_reg <= 1'b0;
//  else
//    trans_clk_reg <= trans_clk_reg;
//end

//assign trans_clk = trans_clk_reg;

// &ModuleEnd; @129
endmodule


