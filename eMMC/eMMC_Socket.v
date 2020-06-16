module eMMC_Socket(
    mclk,
    rstn,
    send_cmd,
    cmd_index,
    cmd_argument,
    o_clk,
    io_cmd
    );
    
    input mclk;
    input rstn;
    input send_cmd;
    input [5:0]cmd_index;
    input [31:0]cmd_argument;
    
    output o_clk;
    
    inout io_cmd;

    wire cmd_i;
    reg cmd_oe;
    reg cmd_o;
    
    parameter IDLE = 4'b0001;
    parameter SEND = 4'b0010;
    parameter WAIT = 4'b0100;
    parameter RECV = 4'b1000;
    
    reg [3:0]cur_state;
    reg [3:0]next_state;
    
    reg [5:0]send_cnt;
    reg [7:0]recv_cnt;
    
    wire send_end;
    wire resp_start;
    wire recv_end;
    wire long_resp;
    
    wire [47:0]cmd;
    
    reg [39:0]cmd_reg;
    wire [6:0]crc7;
    reg [6:0]crc7_reg;
    wire rstn_crc;
    wire data_crc;
    assign cmd = {cmd_reg[39:0],crc7_reg[6:0],1'b1};
    
    assign cmd_i = io_cmd;
    assign io_cmd = cmd_oe ? cmd_o : 1'bz;
    
    assign rstn_crc = ~( send_cnt == 0 );
    assign data_crc = cmd_o;
    //command sending FSM
    assign send_end   = (cur_state == SEND) && (send_cnt == 6'd49);
    assign resp_start = (cmd_i == 1'b0);//(cur_state == WAIT) && (cmd_i == 1'b0);
    assign recv_end   = (cur_state == RECV) && (long_resp ? (recv_cnt == 8'd135) : (recv_cnt == 8'd47));
    assign long_resp  = (cur_state == RECV) && ((cmd_index == 6'd2) || (cmd_index == 6'd9) || (cmd_index == 6'd10));
    
    always@(negedge mclk)begin
        if(cur_state == SEND)begin
            send_cnt <= send_cnt + 6'b000001;
            cmd_o <= cmd [6'd47 - send_cnt];
        end
        else begin
            send_cnt <= 0;
        end
    end
    
    always@(negedge mclk)begin
        if((cur_state == SEND) && (send_cnt < 6'd48))begin
            cmd_oe <= 1'b1;
        end
        else begin
            cmd_oe <= 0;
        end
    end
    
    always@(posedge mclk)begin
        if(send_cmd)begin
            cmd_reg <= {2'b01,cmd_index[5:0],cmd_argument[31:0]};
        end
    end
    
    crc7 X_TX_CRC(
        .clk(mclk),
        .rstn(rstn_crc),
        .data_in(data_crc),
        .crc7(crc7));
        
    
    //next state comb
    always@(cur_state or send_cmd or send_end or resp_start or recv_end)begin
        case(cur_state)
            IDLE: next_state = send_cmd   ? SEND : cur_state;
            SEND: next_state = send_end   ? WAIT : cur_state;
            WAIT: next_state = resp_start ? RECV : cur_state;
            RECV: next_state = recv_end   ? IDLE : cur_state;
            default:next_state = cur_state;
        endcase
    end
    
    //load state
    always@(posedge mclk or negedge rstn)begin
        if(~rstn)begin
            cur_state <= 4'b0001;
        end
        else begin
            cur_state <= next_state;
        end
    end

endmodule  
    
