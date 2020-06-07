//APB BUS SPI MASTER CLKGEN
//by his honourable Yizhou jiang
//Fudan University, Shanghai, China

module spi_master_clkgen(
  reg_clkgen_dl,
  reg_clkgen_en,
  rst_b,
  sys_clk,
  clkgen_ctrl_clk
);

//Ports
input   [15:0]  reg_clkgen_dl;        
input           reg_clkgen_en;        
input           rst_b;                
input           sys_clk;              
output          clkgen_ctrl_clk;      

//Regs
reg             clkgen_ctrl_clk;      
reg    [15:0]   cnt;                  
//Wires
wire   [15:0]   reg_clkgen_dl;        
wire            reg_clkgen_en;        
wire            rst_b;                
wire            sys_clk;              



always @(posedge sys_clk or negedge rst_b)
    if(!rst_b) begin
        cnt <= 16'b0;
        clkgen_ctrl_clk <= 1'b0;
    end
    else if(reg_clkgen_en) begin
        if(cnt < reg_clkgen_dl) begin
            cnt     <= cnt + 1'b1;
            clkgen_ctrl_clk <= clkgen_ctrl_clk;
        end
        else begin
            cnt     <= 16'b0;
            clkgen_ctrl_clk <= ~clkgen_ctrl_clk;
        end
    end

endmodule
