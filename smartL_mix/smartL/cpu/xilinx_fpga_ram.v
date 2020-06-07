module xilinx_fpga_ram (clk, we, en, addr, di, dout);
parameter       width = 8;
parameter       depth = 8;
input           clk;
input           we;
input           en;
input   [depth-1:0]  addr;
input   [width-1:0]   di;
output  [width-1:0]   dout;

reg     [width-1:0]   RAM[2**depth-1:0];
reg     [width-1:0]   dout;

always @(posedge clk)
begin
  if (en) begin
    if (we) begin
      RAM[addr] <= di;
      dout      <= di;
    end
    else
      dout      <= RAM[addr];
  end
end

endmodule


