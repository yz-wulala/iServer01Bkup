module AD7091R_Socket_tb();

    `define cyc 10
    reg clk_tb;
    reg rst_n_tb;
    reg rd_en_tb;
    reg [11:0]test_data;
    
    wire sclk_o_tb;
    
    AD7091R_Socket X0(
    .clk(clk_tb),//m clock fmax=13.56MHz
    .rst_n(rst_n_tb),
    .en(1'b1),
    //ADC signal
    .sclk_o(sclk_o_tb),
    .sdo_i(test_data[11]),
    //master interface
    .rd_en(rd_en_tb)
    );
    
    initial begin
        clk_tb = 0;
        rst_n_tb = 0;
        rd_en_tb = 0;
        #18
        rst_n_tb = 1;
        #121
        test_data = 12'd3333;
        @(negedge clk_tb)begin
            rd_en_tb = 1;
        end
        @(negedge clk_tb)begin
            rd_en_tb = 0;
        end
    end
    
    always @(negedge sclk_o_tb) begin
        test_data <= {test_data[10:0],test_data[11]};
    end
    
    always begin
        #(`cyc/2)
        clk_tb = ~clk_tb;
    end
    
    initial begin
        $fsdbDumpfile ("AD7091R_Socket_tb.fsdb");
        $fsdbDumpvars (0,"+all",AD7091R_Socket_tb);
    end
    
    initial begin
        #1000
        $finish;
    end
endmodule
