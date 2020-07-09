module crc4_tb();

    `define cyc 20
    reg clk_tb;
    reg rstn_tb;
    reg start_tb;
    reg [25:0]data_reg;

    reg [7:0]i;
    crc4 X_0(
        .clk(clk_tb),
        .rstn(rstn_tb),
        .start(start_tb),
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
        $fsdbDumpfile ("crc4_tb.fsdb");
        $fsdbDumpvars (0,"+all",crc4_tb);
    end

    initial begin
        start_tb = 0;
        data_reg = 26'd987654;
        #(`cyc*2)
        start_tb = 1;
        #(`cyc)
        start_tb = 0;
        #(`cyc*40)
        data_reg = 26'd6666666;
        #(`cyc*2)
        start_tb = 1;
        #(`cyc)
        start_tb = 0;
    end
    
    
    initial begin
        #5000
        $finish;
    end
endmodule
