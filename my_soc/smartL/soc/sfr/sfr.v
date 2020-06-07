// * -------------------------------                                          *
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
//FILE NAME       : sfr.v
//AUTHOR          : Lei Ye
//FUNCTION        : 
//RESET           : 
//DFT             :
//DFP             :  
//VERIFICATION    : 
//RELEASE HISTORY :
// ****************************************************************************

module sfr(
  apb_sfr_paddr,
  apb_sfr_penable,
  apb_sfr_psel,
  apb_sfr_pwdata,
  apb_sfr_pwrite,
  rst_b,
  sys_clk,
  sfr_apb_prdata,
  
  sfr_reg_00,
  sfr_reg_01,
  sfr_reg_02,
  sfr_reg_03,
  sfr_reg_04,
  sfr_reg_05,
  sfr_reg_06,
  sfr_reg_07
);

// default value for the sfrs
parameter default00 = 32'h00000000;
parameter default01 = 32'h00010001;
parameter default02 = 32'h00020002;
parameter default03 = 32'h00030003;
parameter default04 = 32'h00040004;
parameter default05 = 32'h00050005;
parameter default06 = 32'h00060006;
parameter default07 = 32'h00070007;

//ports
input   [31:0]  apb_sfr_paddr;          
input           apb_sfr_penable;        
input           apb_sfr_psel;           
input   [31:0]  apb_sfr_pwdata;         
input           apb_sfr_pwrite;         
input           rst_b;                  
input           sys_clk;              
output  [31:0]  sfr_apb_prdata;         

output  [31:0]  sfr_reg_00;
output  [31:0]  sfr_reg_01;
output  [31:0]  sfr_reg_02;
output  [31:0]  sfr_reg_03;
output  [31:0]  sfr_reg_04;
output  [31:0]  sfr_reg_05;
output  [31:0]  sfr_reg_06;
output  [31:0]  sfr_reg_07;


//reg     
reg     [31:0]  sfr_reg_00;             
reg     [31:0]  sfr_reg_01;             
reg     [31:0]  sfr_reg_02;             
reg     [31:0]  sfr_reg_03;             
reg     [31:0]  sfr_reg_04;             
reg     [31:0]  sfr_reg_05;             
reg     [31:0]  sfr_reg_06;             
reg     [31:0]  sfr_reg_07;             

reg     [31:0]  sfr_reg_data_pre;       

//wire
wire    [31:0]  sfr_apb_prdata;         
wire            rd_acc;                 
wire            wr_acc;                 
wire            apb_sfr_penable;
wire            apb_sfr_psel;
wire            sys_clk;
wire            rst_b;
wire    [31:0]  apb_sfr_pwdata;   
wire    [31:0]  apb_sfr_paddr;          
wire    [5 :0]  apb_reg_addr;           
                 


assign apb_reg_addr[5:0] = apb_sfr_paddr[7:2];
assign wr_acc  = apb_sfr_psel && apb_sfr_pwrite && apb_sfr_penable;
assign rd_acc  = apb_sfr_psel && !apb_sfr_pwrite && apb_sfr_penable;


//==================================================================================
//          apb write the sfr
//==================================================================================
//reg_00
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        sfr_reg_00 <= default00;
    end
    else if(wr_acc && (apb_reg_addr == 6'h00)) begin
        sfr_reg_00[31:0] <= apb_sfr_pwdata[31:0];
    end
end
//reg_01
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        sfr_reg_01 <= default01;
    end
    else if(wr_acc && (apb_reg_addr == 6'h01)) begin
        sfr_reg_01[31:0] <= apb_sfr_pwdata[31:0];
    end
end
//reg_02
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        sfr_reg_02 <= default02;
    end
    else if(wr_acc && (apb_reg_addr == 6'h02)) begin
        sfr_reg_02[31:0] <= apb_sfr_pwdata[31:0];
    end
end
//reg_03
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        sfr_reg_03 <= default03;
    end
    else if(wr_acc && (apb_reg_addr == 6'h03)) begin
        sfr_reg_03[31:0] <= apb_sfr_pwdata[31:0];
    end
end
//reg_04
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        sfr_reg_04 <= default04;
    end
    else if(wr_acc && (apb_reg_addr == 6'h04)) begin
        sfr_reg_04[31:0] <= apb_sfr_pwdata[31:0];
    end
end
//reg_05
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        sfr_reg_05 <= default05;
    end
    else if(wr_acc && (apb_reg_addr == 6'h05)) begin
        sfr_reg_05[31:0] <= apb_sfr_pwdata[31:0];
    end
end
//reg_06
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        sfr_reg_06 <= default06;
    end
    else if(wr_acc && (apb_reg_addr == 6'h06)) begin
        sfr_reg_06[31:0] <= apb_sfr_pwdata[31:0];
    end
end
//reg_07
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        sfr_reg_07 <= default07;
    end
    else if(wr_acc && (apb_reg_addr == 6'h07)) begin
        sfr_reg_07[31:0] <= apb_sfr_pwdata[31:0];
    end
end

//==================================================================================
//            apb read the sfr
//==================================================================================
assign sfr_apb_prdata[31:0] = rd_acc ? sfr_reg_data_pre[31:0] : 32'bx;

always @(  sfr_reg_00[31:0]
        or sfr_reg_01[31:0]
        or sfr_reg_02[31:0]
        or sfr_reg_03[31:0]
        or sfr_reg_04[31:0]
        or sfr_reg_05[31:0]
        or sfr_reg_06[31:0]
        or sfr_reg_07[31:0]
        or apb_sfr_paddr[31:0])
begin
    case(apb_reg_addr[5:0])
        6'h00: sfr_reg_data_pre[31:0] = sfr_reg_00[31:0];
        6'h01: sfr_reg_data_pre[31:0] = sfr_reg_01[31:0];
        6'h02: sfr_reg_data_pre[31:0] = sfr_reg_02[31:0];
        6'h03: sfr_reg_data_pre[31:0] = sfr_reg_03[31:0];
        6'h04: sfr_reg_data_pre[31:0] = sfr_reg_04[31:0];
        6'h05: sfr_reg_data_pre[31:0] = sfr_reg_05[31:0];
        6'h06: sfr_reg_data_pre[31:0] = sfr_reg_06[31:0];
        6'h07: sfr_reg_data_pre[31:0] = sfr_reg_07[31:0];
        default:sfr_reg_data_pre[31:0] = 32'b0;     
    endcase 
end


endmodule


