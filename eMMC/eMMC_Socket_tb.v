module eMMC_Socket_tb();

    `define cyc 20
    
    
    
    reg mclk_tb;
    reg rstn_tb;
    reg send_cmd_tb;
    reg [5:0]cmd_index_tb;
    reg [31:0]cmd_argument_tb;
    
    reg cmd_o_tb;//refer to the eMMC side
    reg cmd_oe_tb;//refer to the eMMC side
    wire cmd_i_tb;//refer to the eMMC side

    wire cmd;
    
    
    tri_state TRI(
        .trio(cmd),
        .in(cmd_i_tb),
        .out(cmd_o_tb),
        .oe(cmd_oe_tb),
        .oe_master(eMMC_Socket_tb.X0.cmd_oe)
    );
    
    eMMC_Socket X0(
    .mclk(mclk_tb),
    .rstn(rstn_tb),
    .send_cmd(send_cmd_tb),
    .cmd_index(cmd_index_tb),
    .cmd_argument(cmd_argument_tb),
    .io_cmd(cmd)
    );
    
    
    initial begin
        mclk_tb = 0;
        rstn_tb = 0;
        send_cmd_tb = 0;
        cmd_oe_tb = 0;
        cmd_o_tb = 0;
        #35
        rstn_tb = 1;
    end
    
    always begin
        #(`cyc/2)
        mclk_tb = ~mclk_tb;
    end
    
    initial begin
        $fsdbDumpfile ("eMMC_Socket_tb.fsdb");
        $fsdbDumpvars (0,"+all",eMMC_Socket_tb);
    end

    initial begin
        #500
        @(negedge mclk_tb)begin
            send_cmd_tb = 1;
            cmd_index_tb = 6'b000000;
            cmd_argument_tb = 32'hF0F0F0F0;
        end
        #(`cyc)
        send_cmd_tb = 0;
        #1200
        @(negedge mclk_tb)begin
            cmd_oe_tb = 1;
            cmd_o_tb = 0;
        end
        #(`cyc)
        cmd_oe_tb = 0;
    end

    
    initial begin
        #10000
        $finish;
    end
    
endmodule

module tri_state(
    inout trio,
    output in,
    input out,
    input oe,
    input oe_master);
    assign trio = oe_master ? 1'bz : (oe ? out : 1'b1);
    assign in = trio;
endmodule
