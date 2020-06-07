//APB BUS SPI MASTER TOP
//by his honourable Yizhou jiang
//Fudan University, Shanghai, China

module spi_master(
    apb_spi_paddr,
    apb_spi_penable,
    apb_spi_psel,
    apb_spi_pwdata,
    apb_spi_pwrite,

    rst_b,
    sys_clk,
    spi_apb_prdata,

    sclk,
    sdi,
    sdo
);

//ports
input   [31:0]  apb_spi_paddr;        
input           apb_spi_penable;      
input           apb_spi_psel;         
input   [31:0]  apb_spi_pwdata;       
input           apb_spi_pwrite;       
input           rst_b;                
input           sys_clk;              
input           sdi;                  
output          sclk;                 
output  [31:0]  spi_apb_prdata;       
output          sdo;                  
//wires
wire    [31:0]  apb_spi_paddr;        
wire            apb_spi_penable;      
wire            apb_spi_psel;         
wire    [31:0]  apb_spi_pwdata;       
wire            apb_spi_pwrite;       
wire            rst_b;                
wire            sys_clk;              
wire            sclk;                 
wire            sdi;                  
wire    [31:0]  spi_apb_prdata;       
wire            sdo;                  

wire            ctrl_reg_busy;        
wire    [63:0]  ctrl_reg_rx_data;     
wire            ctrl_reg_rd_en;       
wire    [15:0]  reg_clkgen_dl;        
wire            reg_clkgen_en;        
wire    [ 2:0]  reg_ctrl_bc;          
wire    [63:0]  reg_ctrl_tx_data;     
wire            reg_ctrl_oe;          
wire            reg_ctrl_tran;        
wire            clkgen_ctrl_clk;      

 
    spi_master_apb_reg spi_master_apb_regx(
        .apb_spi_paddr(apb_spi_paddr),
        .apb_spi_penable(apb_spi_penable),
        .apb_spi_psel(apb_spi_psel),
        .apb_spi_pwdata(apb_spi_pwdata),
        .apb_spi_pwrite(apb_spi_pwrite),
        .ctrl_reg_busy(ctrl_reg_busy),
        .ctrl_reg_rx_data(ctrl_reg_rx_data),
        .ctrl_reg_rd_en(ctrl_reg_rd_en),
        .reg_clkgen_dl(reg_clkgen_dl),
        .reg_clkgen_en(reg_clkgen_en),
        .reg_ctrl_bc(reg_ctrl_bc),
        .reg_ctrl_tx_data(reg_ctrl_tx_data),
        .reg_ctrl_oe(reg_ctrl_oe),
        .reg_ctrl_tran(reg_ctrl_tran),
        .rst_b(rst_b),
        .sys_clk(sys_clk),
        .spi_apb_prdata(spi_apb_prdata)
    );

    spi_master_clkgen spi_master_clkgenx(
        .reg_clkgen_dl(reg_clkgen_dl),
        .reg_clkgen_en(reg_clkgen_en),
        .rst_b(rst_b),
        .sys_clk(sys_clk),
        .clkgen_ctrl_clk(clkgen_ctrl_clk)
    );
    
    
    spi_master_ctrl spi_master_ctrlx(
        .ctrl_reg_busy(ctrl_reg_busy),
        .ctrl_reg_rx_data(ctrl_reg_rx_data),
        .ctrl_reg_rd_en(ctrl_reg_rd_en),
        .reg_ctrl_bc(reg_ctrl_bc),
        .reg_ctrl_tx_data(reg_ctrl_tx_data),
        .reg_ctrl_oe(reg_ctrl_oe),
        .reg_ctrl_tran(reg_ctrl_tran),
        .rst_b(rst_b),
        .clk(clkgen_ctrl_clk),
        .sclk(sclk),
        .sdo(sdo),
        .sdi(sdi)
    );
    
    
endmodule