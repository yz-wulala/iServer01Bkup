//APB BUS SPI MASTER CTRL
//by his honourable Yizhou jiang
//Fudan University, Shanghai, China

module spi_master_ctrl(
    ctrl_reg_busy,
    ctrl_reg_rx_data,
    ctrl_reg_rd_en,
    reg_ctrl_bc,
    reg_ctrl_tx_data,
    reg_ctrl_oe,
    reg_ctrl_tran,
    rst_b,
    clk,
    sclk,
    sdo,
    sdi
);

//Ports
input  [ 2:0]   reg_ctrl_bc;           
input  [63:0]   reg_ctrl_tx_data;      
input           reg_ctrl_oe;           
input           reg_ctrl_tran;         
input           rst_b;                 
input           clk;                   
input           sdi;                   
                                       
output          ctrl_reg_busy;         
output [63:0]   ctrl_reg_rx_data;      
output          ctrl_reg_rd_en;        
output          sclk;                  
output          sdo;                   


//Regs
reg             ctrl_reg_busy;         
reg    [63:0]   ctrl_reg_rx_data;      
                                       
reg             sdo_reg;               
reg             sclk_reg;              
reg    [ 6:0]   bit_cnt;               
reg             busy_delay;            
reg    [63:0]   tx_data_delay;         

//Wires
wire   [ 2:0]   reg_ctrl_bc;           
wire   [63:0]   reg_ctrl_tx_data;      
wire            reg_ctrl_oe;           
wire            reg_ctrl_tran;         
wire            rst_b;                 
wire            clk;                   
wire            sdi;                   
wire            sclk;                  
wire            sdo;                   
wire            tran_end;              
wire            ctrl_reg_rd_en;        

assign sdo = reg_ctrl_oe ? sdo_reg : 1'b0;
assign sclk = reg_ctrl_oe ? sclk_reg : 1'b0;
assign ctrl_reg_rd_en = tran_end;

assign tran_end = ((reg_ctrl_bc[2:0] == bit_cnt[6:4]) && (bit_cnt[3:0] == 4'b1111));

always @(posedge clk or negedge rst_b) begin
    if(!rst_b) begin
        ctrl_reg_busy <= 1'b0;
    end
    else if(tran_end) begin
       ctrl_reg_busy <= 1'b0;
    end
    else if(reg_ctrl_tran) begin
       ctrl_reg_busy <= 1'b1;
    end
end

always @(posedge clk or negedge rst_b) begin
    if(!rst_b) begin
        busy_delay <= 1'b0;
    end
    else begin
       busy_delay <= ctrl_reg_busy;
    end
end

always @(posedge clk or negedge rst_b) begin
    if(!rst_b) begin
        bit_cnt <= 7'b0;
    end
    else if(tran_end) begin
        bit_cnt <= 7'b0;
    end
    else if(busy_delay && ctrl_reg_busy) begin
       bit_cnt <= bit_cnt + 1'b1;
    end
end

always @(posedge clk or negedge rst_b) begin
    if(!rst_b) begin
        tx_data_delay[63:0] <= 64'b0;
    end
    else if(~ctrl_reg_busy) begin
        tx_data_delay[63:0] <= reg_ctrl_tx_data[63:0];
    end
    else if(ctrl_reg_busy && busy_delay && ~ (bit_cnt[0])) begin
        tx_data_delay[63:0] <= {tx_data_delay[62:0],1'b0};
    end
end

always @(posedge clk or negedge rst_b) begin
    if(!rst_b) begin
        sdo_reg <= 1'b0;
    end
    else if((~busy_delay) && ctrl_reg_busy) begin
        sdo_reg <= tx_data_delay[63];
    end
    else if(bit_cnt[0] && busy_delay && ctrl_reg_busy) begin
        sdo_reg <= tx_data_delay[63];
    end
end

always @(posedge clk or negedge rst_b) begin
    if(!rst_b) begin
        sclk_reg <= 1'b0;
    end
    else if(bit_cnt[0] && busy_delay && ctrl_reg_busy) begin
        sclk_reg <= 1'b0;
    end
    else if((~bit_cnt[0]) && busy_delay && ctrl_reg_busy) begin
       sclk_reg <= 1'b1;
    end
end

always @(posedge sclk or negedge rst_b) begin
    if(!rst_b) begin
        ctrl_reg_rx_data <= 64'b0;
    end
    else begin
        ctrl_reg_rx_data[63:0] <= {ctrl_reg_rx_data[62:0],sdi};
    end
end
endmodule
