//APB BUS SPI MASTER REG
//by his honourable Yizhou jiang
//Fudan University, Shanghai, China

module spi_master_apb_reg(
  apb_spi_paddr,
  apb_spi_penable,
  apb_spi_psel,
  apb_spi_pwdata,
  apb_spi_pwrite,
  ctrl_reg_busy,
  ctrl_reg_rx_data,
  ctrl_reg_rd_en,
  reg_clkgen_dl,
  reg_clkgen_en,
  reg_ctrl_bc,
  reg_ctrl_tx_data,
  reg_ctrl_oe,
  reg_ctrl_tran,
  rst_b,
  sys_clk,
  spi_apb_prdata,
);

//Ports
input   [31:0]  apb_spi_paddr;       
input           apb_spi_penable;     
input           apb_spi_psel;        
input   [31:0]  apb_spi_pwdata;      
input           apb_spi_pwrite;      
input           ctrl_reg_busy;        
input   [63:0]  ctrl_reg_rx_data;      
input           ctrl_reg_rd_en;     
input           rst_b;                
input           sys_clk;              
output  [15:0]  reg_clkgen_dl;   
output          reg_clkgen_en; 
output  [ 2:0]  reg_ctrl_bc; 
output  [63:0]  reg_ctrl_tx_data;     
output          reg_ctrl_oe;     
output          reg_ctrl_tran;     
output  [31:0]  spi_apb_prdata;             

//Regs
reg     [15:0]  reg_clkgen_dl;   
reg             reg_clkgen_en;
reg     [ 2:0]  reg_ctrl_bc;  
reg             reg_ctrl_oe;     
reg             reg_ctrl_tran;     

reg     [31:0]  tx_buffer_l;             
reg     [31:0]  tx_buffer_h;             
reg     [31:0]  rx_buffer_l;             
reg     [31:0]  rx_buffer_h; 
                   
reg     [31:0]  spi_reg_data_pre;
reg             spi_busy;

//Wires 
wire    [63:0]  reg_ctrl_tx_data;    
wire    [31:0]  apb_spi_paddr;       
wire            apb_spi_penable;     
wire            apb_spi_psel;        
wire    [31:0]  apb_spi_pwdata;      
wire            apb_spi_pwrite;      
wire            ctrl_reg_busy;        
wire    [63:0]  ctrl_reg_rx_data;      
wire            ctrl_reg_rd_en;     
wire            rst_b;                
wire            sys_clk;               
wire            wr_acc;
wire            rd_acc;
wire            tx_buffer_l_wen;
wire            tx_buffer_h_wen;
wire            reg_dl_wen;
wire    [ 5:0]  apb_reg_addr;       

parameter          TBL = 6'h00;
parameter          TBH = 6'h01;
parameter          RBL = 6'h02;
parameter          RBH = 6'h03;
parameter          DLR = 6'h1D;
parameter          SCR = 6'h1E;
parameter          SSR = 6'h1F;

assign reg_ctrl_tx_data[63:0] = {tx_buffer_h[31:0],tx_buffer_l[31:0]};
assign apb_reg_addr[5:0] = apb_spi_paddr[7:2];
assign wr_acc  = apb_spi_psel && apb_spi_pwrite && apb_spi_penable;
assign rd_acc  = apb_spi_psel && !apb_spi_pwrite && apb_spi_penable; 

//==================================================================================
//          ahb write the spi register
//==================================================================================

assign tx_buffer_l_wen = ~spi_busy && wr_acc && (apb_reg_addr[5:0] == TBL);
assign tx_buffer_h_wen = ~spi_busy && wr_acc && (apb_reg_addr[5:0] == TBH);
assign reg_dl_wen = wr_acc && (apb_reg_addr[5:0] == DLR);
assign reg_sc_wen = wr_acc && (apb_reg_addr[5:0] == SCR);


always @(posedge sys_clk or negedge rst_b)
begin
  if(!rst_b)
    tx_buffer_l[31:0] <= 32'h0;
  else if(tx_buffer_l_wen)
    tx_buffer_l[31:0] <= apb_spi_pwdata[31:0];
end

always @(posedge sys_clk or negedge rst_b)
begin
  if(!rst_b)
    tx_buffer_h[31:0] <= 32'h0;
  else if(tx_buffer_h_wen)
    tx_buffer_h[31:0] <= apb_spi_pwdata[31:0];
end

always @(posedge sys_clk or negedge rst_b)
begin
  if(!rst_b)
    reg_clkgen_dl[15:0] <= 16'h0;
  else if(reg_dl_wen)
    reg_clkgen_dl[15:0] <= apb_spi_pwdata[15:0];
end

always @(posedge sys_clk or negedge rst_b)
begin
  if(!rst_b)
    reg_ctrl_bc[2:0] <= 3'h0;
  else if(reg_dl_wen)
    reg_ctrl_bc[2:0] <= apb_spi_pwdata[18:16];
end

always @(posedge sys_clk or negedge rst_b)
begin
  if(!rst_b)
    reg_ctrl_oe <= 1'h0;
  else if(reg_sc_wen)
    reg_ctrl_oe <= apb_spi_pwdata[2];
end

always @(posedge sys_clk or negedge rst_b)
begin
  if(!rst_b)
    reg_ctrl_tran <= 1'h0;
  else if(ctrl_reg_busy)
    reg_ctrl_tran <= 1'h0;
  else if(reg_sc_wen)
    reg_ctrl_tran <= apb_spi_pwdata[1];
end

always @(posedge sys_clk or negedge rst_b)
begin
  if(!rst_b)
    reg_clkgen_en <= 1'h0;
  else if(reg_sc_wen)
    reg_clkgen_en <= apb_spi_pwdata[0];
end

//==================================================================================
//            apb read the spi register
//==================================================================================
assign spi_apb_prdata[31:0] = rd_acc ? spi_reg_data_pre[31:0] : 32'bx;

always @( tx_buffer_l[31:0]
       or tx_buffer_h[31:0]
       or rx_buffer_l[31:0]
       or rx_buffer_h[31:0]
       or reg_clkgen_dl[15:0]
       or reg_ctrl_oe
       or reg_ctrl_tran
       or reg_clkgen_en
       or spi_busy
       or apb_reg_addr[5:0])
begin
case(apb_reg_addr[5:0])
  TBL:    spi_reg_data_pre[31:0] = tx_buffer_l[31:0];
  TBH:    spi_reg_data_pre[31:0] = tx_buffer_h[31:0];
  RBL:    spi_reg_data_pre[31:0] = rx_buffer_l[31:0];
  RBH:    spi_reg_data_pre[31:0] = rx_buffer_h[31:0];
  DLR:    spi_reg_data_pre[31:0] = {16'b0,reg_clkgen_dl[15:0]};
  SCR:    spi_reg_data_pre[31:0] = {29'b0,reg_ctrl_oe,reg_ctrl_tran,reg_clkgen_en};
  SSR:    spi_reg_data_pre[31:0] = {29'b0,spi_busy};
  default:spi_reg_data_pre[31:0] = 8'b0;     
 endcase 
end


//==================================================================================
//             Interface with spi_master_ctrl
//==================================================================================
//==================================================================================
//          spi_master_ctrl write the spi register
//==================================================================================

always @(posedge sys_clk or negedge rst_b)
begin
  if(!rst_b)
    spi_busy <= 1'b0;
  else
    spi_busy <= ctrl_reg_busy; 
end

always @(posedge sys_clk or negedge rst_b) begin
    if(!rst_b) begin
        rx_buffer_l[31:0] <= 32'b0;
        rx_buffer_h[31:0] <= 32'b0;
    end
    else if(ctrl_reg_rd_en) begin
        rx_buffer_l[31:0] <= ctrl_reg_rx_data[31:0];
        rx_buffer_h[31:0] <= ctrl_reg_rx_data[63:32];
    end
end

endmodule



