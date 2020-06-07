//APB BUS SPI SLAVE TOP
//by his honourable Yizhou jiang
//Fudan University, Shanghai, China

module spi_slave(
    apb_spi_paddr,
    apb_spi_penable,
    apb_spi_psel,
    apb_spi_pwdata,
    apb_spi_pwrite,

    rst_b,
    sys_clk,
    spi_apb_prdata,

    csb,
    sclk,
    sdi,
    sdo_en,
    sdo,
    spi_vic_int
);

//ports
input   [31:0]  apb_spi_paddr;       
input           apb_spi_penable;     
input           apb_spi_psel;     
input   [31:0]  apb_spi_pwdata;       
input           apb_spi_pwrite;   
input           rst_b;
input           sys_clk;
input           csb;
input           sclk;
input           sdi;
output  [31:0]  spi_apb_prdata;
output          sdo_en;
output          sdo;
output          spi_vic_int;
//wires
wire    [31:0]  apb_spi_paddr;       
wire            apb_spi_penable;     
wire            apb_spi_psel;     
wire    [31:0]  apb_spi_pwdata;       
wire            apb_spi_pwrite;  
wire            rst_b;
wire            sys_clk;
wire            csb;
wire            sclk;
wire            sdi;  
wire    [31:0]  spi_apb_prdata;
wire            sdo_en;
wire            sdo;
wire            spi_vic_int;
wire    [ 7:0]  spi_reg_addr;
wire            spi_reg_wr_en;
wire    [ 7:0]  spi_reg_data;
wire            spi_reg_rd_en;
wire    [ 7:0]  reg_spi_data;

    spi_slave_apb_reg x_spi_slave_apb_reg(
        .apb_spi_paddr(apb_spi_paddr),
        .apb_spi_penable(apb_spi_penable),
        .apb_spi_psel(apb_spi_psel),
        .apb_spi_pwdata(apb_spi_pwdata),
        .apb_spi_pwrite(apb_spi_pwrite),
        .spi_reg_wr_en(spi_reg_wr_en),
        .spi_reg_addr(spi_reg_addr),
        .spi_reg_data(spi_reg_data),
        .spi_reg_rd_en(spi_reg_rd_en),
        .rst_b(rst_b),
        .sys_clk(sys_clk),
        .spi_apb_prdata(spi_apb_prdata),
        .reg_spi_data(reg_spi_data),
        .spi_vic_int(spi_vic_int),
        .csb(csb)
    );

    spi_slave_ctrl x_spi_slave_ctrl(
        .I_resetb(rst_b),
        .I_da(4'b0101),          
        .I_csb(csb),                  
        .I_sclk(sclk),                 
        .I_sdi(sdi),                  
        .I_reg_data(reg_spi_data),      
        .O_sdo_en(sdo_en),         
        .O_sdo(sdo),            
        .O_reg_addr(spi_reg_addr), 
        .O_reg_wr_en(spi_reg_wr_en),      
        .O_reg_data(spi_reg_data),  
        .O_reg_rd_en(spi_reg_rd_en)
    ); 
endmodule;    
