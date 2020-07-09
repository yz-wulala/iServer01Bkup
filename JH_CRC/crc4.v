module crc4(
    clk,
    rstn,
    start,
    data_in,
    data_out
    );
    
    input clk;
    input rstn;
    input start;
    input [25:0]data_in;
    
    
    output [29:0]data_out;
    
    reg [3:0]crc4;
    reg [29:0]data_out;
    reg [25:0]data_reg;
    reg [25:0]data_reg_nt;
    reg clear;
    reg state;
    reg [4:0]cnt;
    
    wire crc4_in;
    
    //FSM
    always@(posedge clk or negedge rstn)begin
        if(~rstn)begin
            state <= 0;//rst 2 IDLE
        end
        else begin
            case(state)
                1'b0:begin//IDLE
                    if(start)begin
                        state <= 1'b1;
                    end
                end
                1'b1:begin//DO
                    if(cnt == 5'd26)begin
                        state <= 1'b0;
                    end
                end
            endcase
        end
    end
    
    //cnt
    always@(posedge clk or negedge rstn)begin
        if(~rstn)begin
            cnt <= 5'b00000;
        end
        else begin
            if(state)begin
                cnt <= cnt + 5'b00001;
            end
            else begin
                cnt <= 0;
            end
        end
    end

    //data_reg
    always@(posedge clk or negedge rstn)begin
        if(~rstn)begin
            data_reg <= 0;
            data_reg_nt <= 0;
        end
        else begin
            if(~state)begin
                data_reg <= data_in;
                data_reg_nt <= data_in;
            end
            else begin
                data_reg <= {data_reg[0],data_reg[25:1]};
            end
        end
    end
    
    assign crc4_in = data_reg[0];
    
    //CRC
    always@(posedge clk or negedge rstn)begin
        if(~rstn)begin
            crc4 <= 0;
        end
        else begin
            if(~state) begin
                crc4 <= 0;
            end
            else begin
                crc4[3] <= crc4[2];
                crc4[2] <= crc4[1];
                crc4[1] <= crc4_in ^ crc4[3] ^ crc4[0];
                crc4[0] <= crc4_in ^ crc4[3];
            end
        end
    end
    
    //Data outputter
    always@(posedge clk or negedge rstn)begin
        if(~rstn)begin
            data_out <= 0;
        end
        else begin
            if(cnt == 5'd26) begin
                data_out <= {data_reg_nt[25:0],crc4[3:0]};
            end
        end
    end
endmodule
