module crc7_tb();

    `define cyc 20
    reg clk_tb;
    reg rstn_tb;
    reg data_reg;
    reg [7:0]data;
    reg [7:0]i;
    crc7 X_0(
        .clk(clk_tb),
        .rstn(rstn_tb),
        .data_in(data_reg)
        );
    initial begin
        clk_tb = 0;
        rstn_tb = 0;
        #16
        rstn_tb = 1;
    end
    
    always begin
        #(`cyc/2)
        clk_tb = ~clk_tb;
    end
    
    initial begin
        $fsdbDumpfile ("crc7_tb.fsdb");
        $fsdbDumpvars (0,"+all",crc7_tb);
    end

    initial begin
        data = 8'b10100001;
        i = 0;
    end
    
    always@(negedge clk_tb)begin
        if(rstn_tb) begin
            i <= i + 1;
            data_reg <= data[7-i];
        end
    end
    
    initial begin
        #1000
        $finish;
    end
endmodule
