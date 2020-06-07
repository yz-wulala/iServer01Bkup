module soc_top_golden_port(
  b_pad_gpio_porta,
  i_pad_clk,
  i_pad_jtg_nrst_b,
  i_pad_jtg_tclk,
  i_pad_jtg_tms,
  i_pad_jtg_trst_b,
  i_pad_rst_b,
  i_pad_uart0_sin,
  o_pad_uart0_sout
);

input           i_pad_clk;             
input           i_pad_jtg_nrst_b;      
input           i_pad_jtg_tclk;        
input           i_pad_jtg_trst_b;      
input           i_pad_rst_b;           
input           i_pad_uart0_sin;       
output          o_pad_uart0_sout;      
inout   [7 :0]  b_pad_gpio_porta;      
inout           i_pad_jtg_tms;  
endmodule
