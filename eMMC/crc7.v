module crc7(
    clk,
    rstn,
    enable,
    data_in,
    crc7);
    
    input clk;
    input rstn;
    input enable;
    input data_in;
    output [6:0]crc7;
    
    reg [6:0]crc7;
    
    always@(posedge clk)begin
        if(~rstn)begin
            crc7 <= 0;
        end
        else begin
            if(enable) begin
                crc7[6] <= crc7[5];
                crc7[5] <= crc7[4];
                crc7[4] <= crc7[3];
                crc7[3] <= data_in ^ crc7[2] ^ crc7[6];
                crc7[2] <= crc7[1];
                crc7[1] <= crc7[0];
                crc7[0] <= data_in ^ crc7[6];
            end
        end
    end
endmodule
