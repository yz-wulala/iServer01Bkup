module cnter(
	clk,
	rst_n,
	ctr);
input clk;
input rst_n;

output [3:0]ctr;

reg [3:0]ctr;

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ctr<=4'b0000;
	end
	else begin
		ctr<=ctr+4'b0001;
	end
end

endmodule;
