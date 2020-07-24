module WLL_FIFO_tb();

    `define cyc 10
    `define TB_DATA_WIDTH 8
    reg clk_tb;
    reg rstn_tb;
    reg [7:0]data_tb;
    reg en_tb;
    reg wr_en_tb;
    reg rd_en_tb;    
    
    WLL_FIFO x1(
    .clk(clk_tb),
    .rst_n(rstn_tb),
    .en(en_tb),
    .data_in(data_tb),
    .wr_en(wr_en_tb),
    .rd_en(rd_en_tb)
    );
    
    task fifo_push;
        input[`TB_DATA_WIDTH-1:0]data;
        begin
        @(negedge clk_tb) begin
            data_tb <= data;
            wr_en_tb <= 1;
            #(`cyc)
            wr_en_tb <= 0;
        end
        end
    endtask
    
    task fifo_pop;
        begin
        @(negedge clk_tb) begin
            rd_en_tb <= 1;
            #(`cyc)
            rd_en_tb <= 0;
        end
        end
    endtask
    
    initial begin
        clk_tb = 0;
        rstn_tb = 0;
        en_tb = 1;
        wr_en_tb = 0;
        rd_en_tb = 0;
        #16
        rstn_tb = 1;
        #47
        fifo_push(8'hAA);
        #16
        fifo_push(8'hBB);
        #13
        fifo_pop;
        #1
        fifo_push(8'h01);
        #1
        fifo_push(8'h02);
        #1
        fifo_push(8'h03);
        #1
        fifo_push(8'h04);
        #1
        fifo_pop;
        #1
        fifo_pop;
        #1
        fifo_pop;
        #1
        fifo_pop;
        #1
        fifo_pop;

    end
    
    always begin
        #(`cyc/2)
        clk_tb = ~clk_tb;
    end
    
    initial begin
        $fsdbDumpfile ("WLL_FIFO_tb.fsdb");
        $fsdbDumpvars (0,"+all",WLL_FIFO_tb);
    end
    
    initial begin
        #1000
        $finish;
    end
endmodule
