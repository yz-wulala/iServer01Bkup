//Test bench for CK802 APB BUS SPI MASTER
//by his honourable Yizhou jiang
//Fudan University, Shanghai, China
`timescale 1ns/1ps

module apb_spi_master_tb();
parameter cycl=50000;//10kHz//
parameter cyc2=100;//5MHz//
parameter N=32;

reg clk;
reg rst_b;
reg [(N-1):0]apb_xx_paddr;
reg apb_xx_penable;
reg [(N-1):0]apb_xx_pwdata;
reg apb_xx_pwrite;
reg apb_slavex_psel;
reg [63:0]rx_data;


wire [(N-1):0]slavex_apb_prdata;
wire sclk;
wire sdi;
wire sdo;

//clock tree
initial begin
    clk=0;
end
always begin
    #cyc2 clk=~clk;
end
//reset tree
initial begin
    rst_b=1;
    #(20*cyc2) rst_b=0;
    #(20*cyc2) rst_b=1;
end
//sdi data
initial begin
    rx_data=64'h0123_4567_89AB_CDEF;
end
always @(posedge sclk) begin
    rx_data[63:0] <= {rx_data[62:0],1'b0};
end
assign sdi = rx_data[63];
//apb bus tasks
//apb bus controller initialization
task apb_init;
    begin
        apb_xx_penable=0;
        apb_slavex_psel=0;
        apb_xx_pwdata=0;
        apb_xx_pwrite=0;
    end
endtask
//apb bus controller write control
task apb_w;
        input [(N-1):0]addr;
        input [(N-1):0]data;
    begin
        @(posedge clk) begin
            apb_xx_paddr=addr;
            apb_xx_pwdata=data;
            apb_slavex_psel=1;
            apb_xx_pwrite=1;
        end
        @(posedge clk) begin
            apb_xx_penable=1;
        end	
        @(posedge clk) begin
            apb_slavex_psel=0;
            apb_xx_penable=0;
        end	
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
    end
endtask
//apb bus controller read control
task apb_r;
        input [(N-1):0]addr;
    begin
        @(posedge clk) begin
            apb_xx_paddr=addr;
            apb_slavex_psel=1;
            apb_xx_pwrite=0;
        end
        @(posedge clk) begin
            apb_xx_penable=1;
        end	
        @(posedge clk) begin
            apb_slavex_psel=0;
            apb_xx_penable=0;
        end	
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
    end
endtask

//user main
initial begin
    apb_init;
    #4555

    apb_w(32'h0000_0000,32'h4433_2211);
    apb_w(32'h0000_0004,32'h8877_6655);    
    apb_r(32'h0000_0000);
    apb_r(32'h0000_0004);
    apb_w(32'h0000_0074,32'h0007_0005);
    apb_w(32'h0000_0078,32'h0000_0001);
    #10000
    apb_w(32'h0000_0074,32'h0007_0000);
    apb_w(32'h0000_0078,32'h0000_0007);
    #100000
    apb_r(32'h0000_0008);
    apb_r(32'h0000_000C);
    end

spi_master spi_masterx(
    .apb_spi_paddr(apb_xx_paddr),
    .apb_spi_penable(apb_xx_penable),
    .apb_spi_psel(apb_slavex_psel),
    .apb_spi_pwdata(apb_xx_pwdata),
    .apb_spi_pwrite(apb_xx_pwrite),
    .rst_b(rst_b),
    .sys_clk(clk),
    .spi_apb_prdata(slavex_apb_prdata),
    .sclk(sclk),
    .sdi(sdi),
    .sdo(sdo)
    );

endmodule