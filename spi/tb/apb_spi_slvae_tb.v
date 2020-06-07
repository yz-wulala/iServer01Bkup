//Test bench for CK802 APB BUS SPI SLAVE
//by his honourable Yizhou jiang
//Fudan University, Shanghai, China
`timescale 1ns/1ps

module apb_spi_slave_tb();
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

reg t_sclk;
reg t_sdi;
reg t_csb;

wire sdo;
wire sdo_en;

wire [(N-1):0]slavex_apb_prdata;

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
//spi tasks
//spi initial
task spi_init;
    begin
        t_sdi=0;
        t_csb=1;
        t_sclk=0;
    end
endtask
//spi csb enable
task spi_start;
    begin
        #(cycl)
        t_csb=0;
    end
endtask
//spi csb disable
task spi_stop;
    begin
        #(cycl)
        t_csb=1;
    end
endtask
//spi 1 byte transerver
task spi_byte;
        input [7:0]spi_in;
    begin
                    t_sdi   =   spi_in[7];
        #(cycl)     t_sclk  =   1; 
        #(cycl)     t_sdi   =   spi_in[6];
                    t_sclk  =   0; 
        #(cycl)     t_sclk  =   1; 
        #(cycl)     t_sdi   =   spi_in[5];
                    t_sclk  =   0; 
        #(cycl)     t_sclk  =   1; 
        #(cycl)     t_sdi   =   spi_in[4];
                    t_sclk  =   0; 
        #(cycl)     t_sclk  =   1; 
        #(cycl)     t_sdi   =   spi_in[3];
                    t_sclk  =   0; 
        #(cycl)     t_sclk  =   1; 
        #(cycl)     t_sdi   =   spi_in[2];
                    t_sclk  =   0; 
        #(cycl)     t_sclk  =   1; 
        #(cycl)     t_sdi   =   spi_in[1];
                    t_sclk  =   0; 
        #(cycl)     t_sclk  =   1; 
        #(cycl)     t_sdi   =   spi_in[0];
                    t_sclk  =   0; 
        #(cycl)     t_sclk  =   1; 
        #(cycl)     t_sclk  =   0; 
    end
endtask
//user main
initial begin
    apb_init;
    spi_init;
    #4555
    apb_r(32'h0000_0000);
    apb_r(32'h0000_0004);
    apb_r(32'h0000_0008);
    apb_r(32'h0000_000c);
    apb_w(32'h0000_000c,32'haaaa_aa00);
    apb_r(32'h0000_000c);
    apb_xx_pwrite=0;
    #9999
    spi_start;
    spi_byte({8'b01100101});
    spi_byte({8'h07});
    spi_byte({8'h01});
    spi_byte({8'h02});
    spi_byte({8'h04});
    spi_byte({8'h08});
    spi_stop;
    #(cycl)
    spi_start;
    spi_byte({8'b11100101});
    spi_byte({8'h0F});
    spi_byte({8'hFF});
    spi_byte({8'hFF});
    spi_byte({8'hFF});
    spi_byte({8'hFF});
    spi_stop;
    #3333
    apb_r(32'h0000_0004);
    end

spi_slave spi_slavex(
    .apb_spi_paddr(apb_xx_paddr),
    .apb_spi_penable(apb_xx_penable),
    .apb_spi_psel(apb_slavex_psel),
    .apb_spi_pwdata(apb_xx_pwdata),
    .apb_spi_pwrite(apb_xx_pwrite),
    .rst_b(rst_b),
    .sys_clk(clk),
    .spi_apb_prdata(slavex_apb_prdata),
    .csb(t_csb),
    .sclk(t_sclk),
    .sdi(t_sdi),
    .sdo_en(sdo_en),
    .sdo(sdo));

endmodule