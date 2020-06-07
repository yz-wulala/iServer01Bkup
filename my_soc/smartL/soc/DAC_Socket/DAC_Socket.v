// * -------------------------------                                          *
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
//FILE NAME       : DAC_Socket.v
//AUTHOR          : Lei Ye
//FUNCTION        : 
//RESET           : 
//DFT             :
//DFP             :  
//VERIFICATION    : 
//RELEASE HISTORY :
// ****************************************************************************

module DAC_Socket(
  apb_dac_paddr,
  apb_dac_penable,
  apb_dac_psel,
  apb_dac_pwdata,
  apb_dac_pwrite,
  rst_b,
  sys_clk,
  dac_value,
  dac_apb_prdata
);

// default value for the dac
parameter dac_default = 12'b000000000000;

//ports
input   [31:0]  apb_dac_paddr;          
input           apb_dac_penable;        
input           apb_dac_psel;           
input   [31:0]  apb_dac_pwdata;         
input           apb_dac_pwrite;         
input           rst_b;                  
input           sys_clk;              
output  [11:0]  dac_value;         
output  [31:0]  dac_apb_prdata;
//reg     
reg     [11:0]  dac_value;       
reg     [31:0]  dac_data_pre;
//wire              
wire            wr_acc;   
wire            rd_acc;              
wire            addr_vld;
wire    [31:0]  apb_dac_pwdata;  
wire    [31:0]  apb_dac_paddr;   
wire    [31:0]  dac_apb_prdata;       
wire            apb_dac_penable;
wire            apb_dac_psel;
wire            rst_b;
wire            sys_clk;
        
assign addr_vld = (apb_dac_paddr[7:2] == 6'b000000);
assign wr_acc  = apb_dac_psel && apb_dac_pwrite && apb_dac_penable;
assign rd_acc  = apb_dac_psel && ~apb_dac_pwrite && apb_dac_penable;

//==================================================================================
//          apb write the dac
//==================================================================================
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        dac_value <= dac_default;
    end
    else if(wr_acc && addr_vld) begin
        dac_value[11:0] <= apb_dac_pwdata[11:0];
    end
end

//==================================================================================
//            apb read the dac
//==================================================================================
assign dac_apb_prdata[31:0] = rd_acc ? dac_data_pre[31:0] : 32'bx;

always @(  dac_value[11:0] or apb_dac_paddr[31:0])
begin
    if(addr_vld) begin
        dac_data_pre[31:0] = {20'b0,dac_value[11:0]};
    end
    else begin
        dac_data_pre[31:0] = 32'b0;     
    end
end


endmodule


