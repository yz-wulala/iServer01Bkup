//APB BUS SPI SLAVE REG
//by his honourable Yizhou jiang
//Fudan University, Shanghai, China

module spi_slave_apb_reg(
  apb_spi_paddr,
  apb_spi_penable,
  apb_spi_psel,
  apb_spi_pwdata,
  apb_spi_pwrite,

  spi_reg_wr_en,
  spi_reg_addr,
  spi_reg_data,
  spi_reg_rd_en,
  
  rst_b,
  sys_clk,
  spi_apb_prdata,
  
  reg_spi_data,
  spi_vic_int,
  
  csb
);

// default value for the regs
parameter default00 = 8'b00000000;
parameter default01 = 8'b00010001;
parameter default02 = 8'b00100010;
parameter default03 = 8'b00110011;
parameter default04 = 8'b01000100;
parameter default05 = 8'b01010101;
parameter default06 = 8'b01100110;
parameter default07 = 8'b01110111;
parameter default08 = 8'b10001000;
parameter default09 = 8'b10011001;
parameter default0A = 8'b10101010;
parameter default0B = 8'b10111011;
parameter default0C = 8'b11001100;
parameter default0D = 8'b11011101;
parameter default0E = 8'b11101110;
parameter default0F = 8'b11111111;


//ports
input   [31:0]  apb_spi_paddr;          
input           apb_spi_penable;        
input           apb_spi_psel;           
input   [31:0]  apb_spi_pwdata;         
input           apb_spi_pwrite;         
input           spi_reg_wr_en;          
input           spi_reg_addr;           
input           spi_reg_data;           
input           spi_reg_rd_en;          
input           rst_b;                  
input           sys_clk;              
input           csb;                      
output  [ 7:0]  reg_spi_data;           
output  [31:0]  spi_apb_prdata;         
output          spi_vic_int;            

//reg     
reg     [7 :0]  spi_reg_00;             
reg     [7 :0]  spi_reg_01;             
reg     [7 :0]  spi_reg_02;             
reg     [7 :0]  spi_reg_03;             
reg     [7 :0]  spi_reg_04;             
reg     [7 :0]  spi_reg_05;             
reg     [7 :0]  spi_reg_06;             
reg     [7 :0]  spi_reg_07;             
reg     [7 :0]  spi_reg_08;             
reg     [7 :0]  spi_reg_09;             
reg     [7 :0]  spi_reg_0A;             
reg     [7 :0]  spi_reg_0B;             
reg     [7 :0]  spi_reg_0C;             
reg     [7 :0]  spi_reg_0D;             
reg     [7 :0]  spi_reg_0E;             
reg     [7 :0]  spi_reg_0F;             
reg     [31:0]  spi_reg_data_pre;       
reg             spi_vic_int;            
reg             spi_reg_wr_en_temp;     
reg     [7 :0]  spi_reg_addr_temp;      
reg     [7 :0]  spi_reg_data_temp;      
reg             spi_reg_rd_en_temp;     
reg             spi_reg_wr_en_sync;     
reg     [7 :0]  spi_reg_addr_sync;      
reg     [7 :0]  spi_reg_data_sync;      
reg             spi_reg_rd_en_sync;     
reg     [7 :0]  reg_spi_data;           
reg             spi_vic_int_ready;

//wire

wire    [31:0]  spi_apb_prdata;         
wire            rd_acc;                 
wire            spi_reg_wr_en;          
wire    [7 :0]  spi_reg_addr;           
wire    [7 :0]  spi_reg_data;           
wire            spi_reg_rd_en;          
wire            wr_acc;                 
wire    [7 :0]  apb_spi_pwdata_endian_0;
wire    [7 :0]  apb_spi_pwdata_endian_1;
wire    [7 :0]  apb_spi_pwdata_endian_2;
wire    [7 :0]  apb_spi_pwdata_endian_3;
wire            apb_reg_read_vld;       
wire            spi_reg_write_vld;      
wire    [31:0]  apb_spi_paddr;          
wire    [5 :0]  apb_reg_addr;           
wire            csb;                    

assign apb_reg_addr[5:0] = apb_spi_paddr[7:2];
assign wr_acc  = apb_spi_psel && apb_spi_pwrite && apb_spi_penable;
assign rd_acc  = apb_spi_psel && !apb_spi_pwrite && apb_spi_penable;
assign apb_spi_pwdata_endian_0  = apb_spi_pwdata[7 :0 ];
assign apb_spi_pwdata_endian_1  = apb_spi_pwdata[15:8 ];
assign apb_spi_pwdata_endian_2  = apb_spi_pwdata[23:16];
assign apb_spi_pwdata_endian_3  = apb_spi_pwdata[31:24];
assign apb_reg_read_vld = rd_acc;
assign spi_reg_write_vld = spi_reg_wr_en_sync;

//==================================================================================
//          spi to reg signals cross clock domain sync
//==================================================================================
always @(posedge sys_clk)
begin
    spi_reg_wr_en_temp<=spi_reg_wr_en;
    spi_reg_wr_en_sync<=spi_reg_wr_en_temp;
    spi_reg_addr_temp[7:0]<=spi_reg_addr[7:0];
    spi_reg_addr_sync[7:0]<=spi_reg_addr_temp[7:0];
    spi_reg_data_temp[7:0]<=spi_reg_data[7:0];
    spi_reg_data_sync[7:0]<=spi_reg_data_temp[7:0];
    spi_reg_rd_en_temp<=spi_reg_rd_en;
    spi_reg_rd_en_sync<=spi_reg_rd_en_temp;
end
//==================================================================================
//          ahb and spi write the spi register
//==================================================================================
//begin//>>>>>>>>>>Copy From spi_write.wll<<<<<<<<<<
//reg_00
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_00 <= default00;
    end
    else if(wr_acc && (apb_reg_addr == 6'h00)) begin
        spi_reg_00[7:0] <= apb_spi_pwdata_endian_0[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h00)) begin
        spi_reg_00[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_01
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_01 <= default01;
    end
    else if(wr_acc && (apb_reg_addr == 6'h00)) begin
        spi_reg_01[7:0] <= apb_spi_pwdata_endian_1[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h01)) begin
        spi_reg_01[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_02
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_02 <= default02;
    end
    else if(wr_acc && (apb_reg_addr == 6'h00)) begin
        spi_reg_02[7:0] <= apb_spi_pwdata_endian_2[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h02)) begin
        spi_reg_02[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_03
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_03 <= default03;
    end
    else if(wr_acc && (apb_reg_addr == 6'h00)) begin
        spi_reg_03[7:0] <= apb_spi_pwdata_endian_3[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h03)) begin
        spi_reg_03[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_04
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_04 <= default04;
    end
    else if(wr_acc && (apb_reg_addr == 6'h01)) begin
        spi_reg_04[7:0] <= apb_spi_pwdata_endian_0[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h04)) begin
        spi_reg_04[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_05
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_05 <= default05;
    end
    else if(wr_acc && (apb_reg_addr == 6'h01)) begin
        spi_reg_05[7:0] <= apb_spi_pwdata_endian_1[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h05)) begin
        spi_reg_05[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_06
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_06 <= default06;
    end
    else if(wr_acc && (apb_reg_addr == 6'h01)) begin
        spi_reg_06[7:0] <= apb_spi_pwdata_endian_2[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h06)) begin
        spi_reg_06[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_07
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_07 <= default07;
    end
    else if(wr_acc && (apb_reg_addr == 6'h01)) begin
        spi_reg_07[7:0] <= apb_spi_pwdata_endian_3[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h07)) begin
        spi_reg_07[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_08
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_08 <= default08;
    end
    else if(wr_acc && (apb_reg_addr == 6'h02)) begin
        spi_reg_08[7:0] <= apb_spi_pwdata_endian_0[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h08)) begin
        spi_reg_08[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_09
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_09 <= default09;
    end
    else if(wr_acc && (apb_reg_addr == 6'h02)) begin
        spi_reg_09[7:0] <= apb_spi_pwdata_endian_1[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h09)) begin
        spi_reg_09[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_0A
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_0A <= default0A;
    end
    else if(wr_acc && (apb_reg_addr == 6'h02)) begin
        spi_reg_0A[7:0] <= apb_spi_pwdata_endian_2[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h0A)) begin
        spi_reg_0A[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_0B
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_0B <= default0B;
    end
    else if(wr_acc && (apb_reg_addr == 6'h02)) begin
        spi_reg_0B[7:0] <= apb_spi_pwdata_endian_3[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h0B)) begin
        spi_reg_0B[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_0C
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_0C <= default0C;
    end
    else if(wr_acc && (apb_reg_addr == 6'h03)) begin
        spi_reg_0C[7:0] <= apb_spi_pwdata_endian_0[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h0C)) begin
        spi_reg_0C[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_0D
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_0D <= default0D;
    end
    else if(wr_acc && (apb_reg_addr == 6'h03)) begin
        spi_reg_0D[7:0] <= apb_spi_pwdata_endian_1[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h0D)) begin
        spi_reg_0D[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_0E
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_0E <= default0E;
    end
    else if(wr_acc && (apb_reg_addr == 6'h03)) begin
        spi_reg_0E[7:0] <= apb_spi_pwdata_endian_2[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h0E)) begin
        spi_reg_0E[7:0] <= spi_reg_data_sync[7:0];
    end
end
//reg_0F
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_reg_0F <= default0F;
    end
    else if(wr_acc && (apb_reg_addr == 6'h03)) begin
        spi_reg_0F[7:0] <= apb_spi_pwdata_endian_3[7:0];
    end
    else if(spi_reg_wr_en_sync && (spi_reg_addr_sync == 8'h0F)) begin
        spi_reg_0F[7:0] <= spi_reg_data_sync[7:0];
    end
end

//end//>>>>>>>>>>END Copy From spi_write.wll<<<<<<<<<<

//==================================================================================
//            apb read the SPI register
//==================================================================================
assign spi_apb_prdata[31:0] = rd_acc ? spi_reg_data_pre[31:0] : 32'bx;

always @(  spi_reg_00[7:0]
        or spi_reg_01[7:0]
        or spi_reg_02[7:0]
        or spi_reg_03[7:0]
        or spi_reg_04[7:0]
        or spi_reg_05[7:0]
        or spi_reg_06[7:0]
        or spi_reg_07[7:0]
        or spi_reg_08[7:0]
        or spi_reg_09[7:0]
        or spi_reg_0A[7:0]
        or spi_reg_0B[7:0]
        or spi_reg_0C[7:0]
        or spi_reg_0D[7:0]
        or spi_reg_0E[7:0]
        or spi_reg_0F[7:0]
        or apb_spi_paddr[31:0])
begin
    case(apb_reg_addr[5:0])
        6'h00: spi_reg_data_pre[31:0] = {spi_reg_03[7:0],spi_reg_02[7:0],spi_reg_01[7:0],spi_reg_00[7:0]};
        6'h01: spi_reg_data_pre[31:0] = {spi_reg_07[7:0],spi_reg_06[7:0],spi_reg_05[7:0],spi_reg_04[7:0]};
        6'h02: spi_reg_data_pre[31:0] = {spi_reg_0B[7:0],spi_reg_0A[7:0],spi_reg_09[7:0],spi_reg_08[7:0]};
        6'h03: spi_reg_data_pre[31:0] = {spi_reg_0F[7:0],spi_reg_0E[7:0],spi_reg_0D[7:0],spi_reg_0C[7:0]};
        default:spi_reg_data_pre[31:0] = 32'b0;     
    endcase 
end

//==================================================================================
//            spi read the SPI register
//==================================================================================
always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        reg_spi_data <= 8'b0;
    end
    else if(spi_reg_rd_en_sync) begin
        case(spi_reg_addr_sync)
        8'h00  :  reg_spi_data[7:0] <= spi_reg_00[7:0];
        8'h01  :  reg_spi_data[7:0] <= spi_reg_01[7:0];
        8'h02  :  reg_spi_data[7:0] <= spi_reg_02[7:0];
        8'h03  :  reg_spi_data[7:0] <= spi_reg_03[7:0];
        8'h04  :  reg_spi_data[7:0] <= spi_reg_04[7:0];
        8'h05  :  reg_spi_data[7:0] <= spi_reg_05[7:0];
        8'h06  :  reg_spi_data[7:0] <= spi_reg_06[7:0];
        8'h07  :  reg_spi_data[7:0] <= spi_reg_07[7:0];
        8'h08  :  reg_spi_data[7:0] <= spi_reg_08[7:0];
        8'h09  :  reg_spi_data[7:0] <= spi_reg_09[7:0];
        8'h0A  :  reg_spi_data[7:0] <= spi_reg_0A[7:0];
        8'h0B  :  reg_spi_data[7:0] <= spi_reg_0B[7:0];
        8'h0C  :  reg_spi_data[7:0] <= spi_reg_0C[7:0];
        8'h0D  :  reg_spi_data[7:0] <= spi_reg_0D[7:0];
        8'h0E  :  reg_spi_data[7:0] <= spi_reg_0E[7:0];
        8'h0F  :  reg_spi_data[7:0] <= spi_reg_0F[7:0];
        default:  reg_spi_data[7:0] <= 8'b0;
    endcase
    end
end

//==================================================================================
//            interrupt
//==================================================================================

always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_vic_int_ready <= 1'b0;
    end
    else if(apb_reg_read_vld) begin
        spi_vic_int_ready <= 1'b0;
    end
    else if(spi_reg_write_vld) begin
        spi_vic_int_ready <= 1'b1;
    end
end

always @(posedge sys_clk or negedge rst_b)
begin
    if(!rst_b) begin
        spi_vic_int <= 1'b0;
    end
    else if(apb_reg_read_vld) begin
        spi_vic_int <= 1'b0;
    end
    else if(csb && spi_vic_int_ready) begin
        spi_vic_int <= 1'b1;
    end
end

endmodule


