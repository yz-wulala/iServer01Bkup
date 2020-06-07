module test();
parameter delay = 200000;
reg sclk;
reg din;
reg csn;
wire dout;
wire din_w;
wire holdn_w;
wire wpn_w;

wire [7:0]Mem_mnt_0;
wire [7:0]Mem_mnt_1;
wire [7:0]Mem_mnt_2;
assign Mem_mnt_0 = X_0.Mem[0];
assign Mem_mnt_1 = X_0.Mem[1];
assign Mem_mnt_2 = X_0.Mem[2];
assign din_w = din;
assign holdn_w = 1'b1;
assign wpn_w = 1'b1;
s25fl256s X_0
    (
        // Data Inputs/Outputs
        .SI(din_w),
        .SO(dout),
        // Controls
        .SCK(sclk),
        .CSNeg(csn),
        .RSTNeg(1'b1),
        .WPNeg(wpn_w),
        .HOLDNeg(holdn_w)
);

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0,"+all",test);
    
end

initial begin
    sclk=1;
    din=1;
    csn=1;
    #300000000
    //Send 06
    #delay
    csn=0;
    spi_do(8'h06);
    #delay
    csn=1;
    //Read SR1
    #delay
    csn=0;
    spi_do(8'h05);
    spi_do(8'hFF);
    #delay
    csn=1;
    //Program 0x000000 with data 0xA5
    #delay
    csn=0;
    spi_do(8'h02);
    spi_do(8'h00);
    spi_do(8'h00);
    spi_do(8'h01);
    spi_do(8'hA5);
    #delay
    csn=1;
    //Read SR1
    #delay
    csn=0;
    spi_do(8'h05);
    spi_do(8'hFF);
    #delay
    csn=1;
    #750000000
    //Read SR1
    #delay
    csn=0;
    spi_do(8'h05);
    spi_do(8'hFF);
    #delay
    csn=1;
    //Read data from 0x000000
    #delay
    csn=0;
    spi_do(8'h03);
    spi_do(8'h00);
    spi_do(8'h00);
    spi_do(8'h00);
    spi_do(8'hFF);
    spi_do(8'hFF);
    spi_do(8'hFF);
    #delay
    csn=1;
end


task spi_do;
    input [7:0]data;
    begin
    #delay
    sclk=0;
    din=data[7];
    #delay
    sclk=1;
    #delay
    sclk=0;
    din=data[6];
    #delay
    sclk=1;
    #delay
    sclk=0;
    din=data[5];
    #delay
    sclk=1;
    #delay
    sclk=0;
    din=data[4];
    #delay
    sclk=1;
    #delay
    sclk=0;
    din=data[3];
    #delay
    sclk=1;
    #delay
    sclk=0;
    din=data[2];
    #delay
    sclk=1;
    #delay
    sclk=0;
    din=data[1];
    #delay
    sclk=1;
    #delay
    sclk=0;
    din=data[0];
    #delay
    sclk=1;
    end
endtask
endmodule
