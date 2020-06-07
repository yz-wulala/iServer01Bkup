//Test bench for CK802 APB BUS SPI MASTER - SLAVE LOOPBACK
//by his honourable Yizhou jiang
//Fudan University, Shanghai, China
`timescale 1ns/1ps

module apb_spi_loopback_tb();
parameter cyc2=100;//5MHz//
parameter N=32;

reg clk;
reg rst_b;
reg [(N-1):0]apb_xx_paddr;
reg apb_xx_penable;
reg [(N-1):0]apb_xx_pwdata;
reg apb_xx_pwrite;
reg apb_slavex_psel0;//master
reg apb_slavex_psel1;//slave

wire [(N-1):0]slavex0_apb_prdata;//master
wire [(N-1):0]slavex1_apb_prdata;//slave
wire sclk;
wire miso;
wire mosi;

reg  csb;
initial begin
    csb=1;
end
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

//apb bus tasks
//apb bus controller initialization
task apbs_init;
    begin
        apb_xx_penable=0;
        apb_slavex_psel0=0;
        apb_slavex_psel1=0;
        apb_xx_pwdata=0;
        apb_xx_pwrite=0;
    end
endtask
//apb bus controller write control
task apb_w0;
        input [(N-1):0]addr;
        input [(N-1):0]data;
    begin
        @(posedge clk) begin
            apb_xx_paddr=addr;
            apb_xx_pwdata=data;
            apb_slavex_psel0=1;
            apb_xx_pwrite=1;
        end
        @(posedge clk) begin
            apb_xx_penable=1;
        end	
        @(posedge clk) begin
            apb_slavex_psel0=0;
            apb_xx_penable=0;
        end	
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
    end
endtask
task apb_w1;
        input [(N-1):0]addr;
        input [(N-1):0]data;
    begin
        @(posedge clk) begin
            apb_xx_paddr=addr;
            apb_xx_pwdata=data;
            apb_slavex_psel1=1;
            apb_xx_pwrite=1;
        end
        @(posedge clk) begin
            apb_xx_penable=1;
        end	
        @(posedge clk) begin
            apb_slavex_psel1=0;
            apb_xx_penable=0;
        end	
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
    end
endtask
//apb bus controller read control
task apb_r0;
        input [(N-1):0]addr;
    begin
        @(posedge clk) begin
            apb_xx_paddr=addr;
            apb_slavex_psel0=1;
            apb_xx_pwrite=0;
        end
        @(posedge clk) begin
            apb_xx_penable=1;
        end	
        @(posedge clk) begin
            apb_slavex_psel0=0;
            apb_xx_penable=0;
        end	
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
    end
endtask
task apb_r1;
        input [(N-1):0]addr;
    begin
        @(posedge clk) begin
            apb_xx_paddr=addr;
            apb_slavex_psel1=1;
            apb_xx_pwrite=0;
        end
        @(posedge clk) begin
            apb_xx_penable=1;
        end	
        @(posedge clk) begin
            apb_slavex_psel1=0;
            apb_xx_penable=0;
        end	
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
    end
endtask

//user main
//slave:
//0x0C write 0x66
//master vis SPI:
//0x0D write 0x55
//read 0x0E~0x0C

initial begin
    apbs_init;
    #4555
    apb_w1(32'h0000_000C,32'hFFEE_DD66);//slave:0x0C write 0x66
    apb_w0(32'h0000_0074,32'h0002_0001);//master:SPI 3byte 8*clk  
    apb_w0(32'h0000_0078,32'h0000_0005);//master:SPI clock and output enable  
    apb_w0(32'h0000_0004,32'h050D_5500);//master:load TX buffer
    csb=0;
    apb_w0(32'h0000_0078,32'h8877_0007);//master:tran
    #45000
    csb=1; 
    apb_w0(32'h0000_0074,32'h0004_0002);//master:SPI 5byte 12*clk  
    apb_w0(32'h0000_0004,32'hC50E_0000);//master:load TX buffer
    csb=0;
    apb_w0(32'h0000_0078,32'h8877_0007);//master:tran
    #100000
    csb=1;
    apb_r0(32'h0000_000C);//master read RX buffer
    apb_r0(32'h0000_0008);//master read RX buffer
end

spi_master spi_masterx(
    .apb_spi_paddr(apb_xx_paddr),
    .apb_spi_penable(apb_xx_penable),
    .apb_spi_psel(apb_slavex_psel0),
    .apb_spi_pwdata(apb_xx_pwdata),
    .apb_spi_pwrite(apb_xx_pwrite),
    .rst_b(rst_b),
    .sys_clk(clk),
    .spi_apb_prdata(slavex0_apb_prdata),
    .sclk(sclk),
    .sdi(miso),
    .sdo(mosi)
    );

spi_slave spi_slavex(
    .apb_spi_paddr(apb_xx_paddr),
    .apb_spi_penable(apb_xx_penable),
    .apb_spi_psel(apb_slavex_psel1),
    .apb_spi_pwdata(apb_xx_pwdata),
    .apb_spi_pwrite(apb_xx_pwrite),
    .rst_b(rst_b),
    .sys_clk(clk),
    .spi_apb_prdata(slavex1_apb_prdata),
    .sclk(sclk),
    .sdi(mosi),
    .sdo(miso),
    .csb(csb)
    );
endmodule