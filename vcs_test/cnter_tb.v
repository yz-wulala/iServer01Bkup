module cnter_tb();

reg clk_tb;
reg rst_n_tb;

cnter I0(
	.clk(clk_tb),
	.rst_n(rst_n_tb)
);

initial begin
	clk_tb=0;
	rst_n_tb=0;
	#13
	rst_n_tb=1;
	#1000
	$finish;
end
always begin
	#5
	clk_tb=~clk_tb;
end
initial begin
	$fsdbDumpfile("cnter_tb.fsdb");
	$fsdbDumpvars(0,cnter_tb);
end

endmodule;
