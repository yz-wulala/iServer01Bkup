
////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1995 - 2010 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    PS/RPH  Dec. 21, 1994/Aug 21, 2002
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 21bd5af1
// DesignWare_release: D-2010.03-DWBB_1003
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Multiplier-Adder
//           signed or unsigned operands       
//           ie. TC = '1' => signed 
//               TC = '0' => unsigned 
//
// MODIFIED:
//      Bob Tong: 12/07/98 
//                STAR 59142
//  RPH 07/17/2002 
//      Rewrote to comply with the new guidelines
//
//  DLL 03/21/2006
//      Replaced behavioral code 'always' block with DW02_prod_sum1.h
//
//
//----------------------------------------------------------------------
module DW02_prod_sum1(A,B,C,TC,SUM);
   
  parameter A_width = 8;
  parameter B_width = 8;
  parameter SUM_width = 16;

  input [A_width-1:0] A;
  input [B_width-1:0] B;
  input [SUM_width-1:0] C;
  input TC;
  output [SUM_width-1:0] SUM;
  
  integer i,j;
  reg [SUM_width-1:0] temp1,temp2;
  reg [SUM_width-1:0] prod2,prodsum;
  reg [A_width+B_width-1:0] prod1;
  reg [A_width-1:0] abs_a;
  reg [B_width-1:0] abs_b;

  always @(A or B or C or TC) 
   begin
     abs_a = (A[A_width-1])? (~A + 1'b1) : A;
     abs_b = (B[B_width-1])? (~B + 1'b1) : B;
 
     temp1 = abs_a * abs_b;
     temp2 = ~(temp1 - 1'b1);
 
     prod1 = (TC) ? (((A[A_width-1] ^ B[B_width-1]) && (|temp1))?
              temp2 : temp1) : A*B;
 
       prodsum = prod1+C;
   end
  assign SUM = prodsum;
endmodule


