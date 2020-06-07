module gated_clk_cell(
  clk_in,
  global_en,
  module_en,
  local_en,
  external_en,
  pad_yy_gate_clk_en_b,
  clk_out
);

input  clk_in;
input  global_en;
input  module_en;
input  local_en;
input  external_en;
input  pad_yy_gate_clk_en_b;
output clk_out;

wire   clk_en_bf_latch;
wire   SE;

assign clk_en_bf_latch = (global_en && (module_en || local_en)) || external_en ;

// SE driven from primary input, held constant
assign SE	       =  pad_yy_gate_clk_en_b;
 
//   &Instance("gated_cell","x_gated_clk_cell");
// //   &Connect(    .clk_in           (clk_in), @50
// //                .SE               (SE), @51
// //                .external_en      (clk_en_bf_latch), @52
// //                .clk_out          (clk_out) @53
// //                ) ; @54
HVT_CLKLANQHDV8 x_gated_clk_cell(
.CK(clk_in),
.TE(SE),
.E(clk_en_bf_latch),
.Q(clk_out));


endmodule   
