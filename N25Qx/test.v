module test();
parameter delay = 200;
reg sclk;
reg din;
reg csn;
wire dout;
wire din_w;
wire holdn_w;
wire wpn_w;
wire [`VoltageRange] Vcc; 
assign Vcc=32'h0708;

assign din_w = din;
assign holdn_w = 1'b1;
assign wpn_w = 1'b1;
N25Qxxx X_0
    (
        .DQ0(din_w),
        .DQ1(dout),
        .C_(sclk),
        .S(csn),
        .Vcc(Vcc),
        .Vpp_W_DQ2(wpn_w),
        .HOLD_DQ3(holdn_w)
);

initial begin
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0,"+all",test);
    
end

initial begin
    sclk=1;
    din=1;
    csn=1;
    #300000
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
    #1000000
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
