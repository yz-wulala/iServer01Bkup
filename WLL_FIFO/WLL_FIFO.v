module WLL_FIFO(
    clk,
    rst_n,
    en,
    data_in,
    data_out,
    wr_en,
    rd_en,
    empty,
    full);
    
    `define DATA_WIDTH 8
    `define ADDR_WIDTH 2
    
    input clk;
    input rst_n;
    input en;
    input [`DATA_WIDTH-1:0]data_in;
    input wr_en;
    input rd_en;
    
    output [`DATA_WIDTH-1:0]data_out;
    output empty;
    output full;
    
    reg [`DATA_WIDTH-1:0]fifo_reg[0:2**`ADDR_WIDTH-1];
    reg [`ADDR_WIDTH-1:0]wr_ptr;
    reg [`ADDR_WIDTH-1:0]rd_ptr;
    reg [`ADDR_WIDTH:0]fifo_counter;
    reg empty;
    reg full;
    
    wire [`DATA_WIDTH-1:0]data_out;
    //write fifo
    always @(posedge clk) begin
        if (wr_en && en) begin
             fifo_reg[wr_ptr[`ADDR_WIDTH-1:0]] <= data_in[`DATA_WIDTH-1:0];
        end
    end

    //write ptr
    //data will be overflowed if write to a full fifo
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr[`ADDR_WIDTH-1:0] <= 0;
        else if(~en)
            wr_ptr[`ADDR_WIDTH-1:0] <= 0;
        else if(wr_en) 
            wr_ptr[`ADDR_WIDTH-1:0] <= wr_ptr[`ADDR_WIDTH-1:0] + 1;
    end
    
    //read ptr
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rd_ptr[`ADDR_WIDTH-1:0] <= 0;
        else if(~en)
            rd_ptr[`ADDR_WIDTH-1:0] <= 0;
        else if((~empty && rd_en) || (full && wr_en)) 
            rd_ptr[`ADDR_WIDTH-1:0] <= rd_ptr[`ADDR_WIDTH-1:0] + 1;
    end
    
    //read data
    assign data_out[`DATA_WIDTH-1:0] = fifo_reg[rd_ptr[`ADDR_WIDTH-1:0]];
    
    //fifo counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            fifo_counter[`ADDR_WIDTH:0] <= 0;
        else if(~en)
            fifo_counter[`ADDR_WIDTH:0] <= 0;
        else if (rd_en && ~wr_en && ~empty)
            fifo_counter[`ADDR_WIDTH:0] <= fifo_counter[`ADDR_WIDTH:0] - 1;
        else if (~rd_en && wr_en && ~full)
            fifo_counter[`ADDR_WIDTH:0] <= fifo_counter[`ADDR_WIDTH:0] + 1;
    end
    
    //empty flag
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            empty <= 1'b1;
        else if(~en)
            empty <= 1'b1;
        else if ((fifo_counter[`ADDR_WIDTH:0] == 1) && rd_en && ~wr_en)
            empty <= 1'b1;
        else if(fifo_counter[`ADDR_WIDTH:0] > 0)
            empty <= 1'b0;
    end
    
    //full flag
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            full <= 1'b0;
        else if(~en)
            full <= 1'b0;
        else if (fifo_counter[`ADDR_WIDTH] == 1'b1) 
            full <= 1'b1;
        else
            full <= 1'b0;
    end
endmodule
