module AD7091R_Socket(
    clk,//m clock fmax=13.56MHz
    rst_n,
    en,
    //ADC signal
    convst_n_o,
    cs_n_o,
    sclk_o,
    sdo_i,
    //master interface
    rd_en,
    adc_data_o,
    adc_rdy
    );
    
    input clk;
    input rst_n;
    input en;
    input sdo_i;
    input rd_en;
    
    output convst_n_o;
    output cs_n_o;
    output sclk_o;
    output [11:0]adc_data_o;
    output adc_rdy;
    
    reg convst_n_o;
    reg cs_n_o;
    reg sclk_o;
    reg [11:0]adc_data_o;
    reg adc_rdy;
    
    reg [5:0]cnt;
    reg [2:0]state;
    reg [2:0]next_state;
    reg [11:0]adc_data;
    
    wire cnt_full;
    
    parameter IDLE = 3'b001;
    parameter READ = 3'b010;
    parameter DONE = 3'b100;
    
    //fsm
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            state <= IDLE;
        end
        else begin
            if(en) begin
                state <= next_state;
            end
        end    
    end
    
    always@(rd_en or cnt_full or state[2:0]) begin
        case(state[2:0]) 
            IDLE: next_state = rd_en ? READ : IDLE;
            READ: next_state = cnt_full ? DONE : READ;
            DONE: next_state = IDLE;
            default: next_state = state;
        endcase
    end
    
    
    //ctrl counter
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            cnt <= 0;
        end
        else if(en & (state[2:0] == READ)) begin
            cnt <= cnt + 1'b1;
        end
        else begin
            cnt <= 0;
        end
    end
    
    assign cnt_full = cnt[5:0] == 6'd35;
    
    //counter outputter
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            convst_n_o <= 1'b1;
            cs_n_o <= 1'b1;
            sclk_o <= 0;
        end
        else if(en) begin
            case(cnt[5:0])
                6'd1: convst_n_o <= 0;
                6'd2: convst_n_o <= 1'b1;
                6'd11: cs_n_o <= 0;
                6'd12: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd13: sclk_o <= 0;
                6'd14: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd15: sclk_o <= 0;
                6'd16: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd17: sclk_o <= 0;
                6'd18: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd19: sclk_o <= 0;
                6'd20: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd21: sclk_o <= 0;
                6'd22: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd23: sclk_o <= 0;
                6'd24: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd25: sclk_o <= 0;
                6'd26: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd27: sclk_o <= 0;
                6'd28: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd29: sclk_o <= 0;
                6'd30: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd31: sclk_o <= 0;
                6'd32: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd33: sclk_o <= 0;
                6'd34: begin
                        sclk_o <= 1'b1;
                        adc_data <= {adc_data[10:0],sdo_i};
                    end
                6'd35: sclk_o <= 0;
                6'd36: cs_n_o <= 1'b1;
            endcase
        end

    end

    //adc data ready intr signal
    always@(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            adc_rdy <= 0;
            adc_data_o <= 0;
        end
        else if(en && (state[2:0] == DONE)) begin
            adc_rdy <= 1'b1;
            adc_data_o <= adc_data;
        end
        else begin
            adc_rdy <= 1'b0;
        end    
    end
endmodule
