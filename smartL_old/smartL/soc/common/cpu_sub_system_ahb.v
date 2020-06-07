// *                                                                           *
// * C-Sky Microsystems Confidential                                           *
// * -------------------------------                                           *
// * This file and all its contents are properties of C-Sky Microsystems. The  *
// * information contained herein is confidential and proprietary and is not   *
// * to be disclosed outside of C-Sky Microsystems except under a              *
// * Non-Disclosure Agreement (NDA).                                           *
// *                                                                           *
// *****************************************************************************
// FILE NAME       : cpu_sub_system_ahb.vp
// AUTHOR          : wangjie
// ORIGINAL TIME   : 2013.05.15
// FUNCTION        : cpu sub system top module
// RESET           : Async reset
// DFT             :
// DFP             :
// VERIFICATION    :
// RELEASE HISTORY :
// $Id: cpu_sub_system_ahb.vp,v 1.37 2018/11/05 05:26:06 zhaok Exp $:
// *****************************************************************************
// &Depend("environment.h"); @21
// &ModuleBeg; @22
module cpu_sub_system_ahb(
  biu_pad_haddr,
  biu_pad_hburst,
  biu_pad_hprot,
  biu_pad_hsize,
  biu_pad_htrans,
  biu_pad_hwdata,
  biu_pad_hwrite,
  biu_pad_lpmd_b,
  biu_pad_psr,
  clk_en,
  corec_pmu_sleep_out,
  cpu_clk,
  ctim_int_vld,
  had_pad_jdb_ack_b,
  had_pad_wakeup_req_b,
  i_pad_jtg_tms,
  pad_biu_bigend_b,
  pad_biu_clkratio,
  pad_biu_hrdata,
  pad_biu_hready,
  pad_biu_hresp,
  pad_cpu_rst_b,
  pad_had_jdb_req_b,
  pad_had_jtg_tap_en,
  pad_had_jtg_tclk,
  pad_had_jtg_tms_i,
  pad_had_jtg_trst_b,
  pad_vic_int_cfg,
  pad_vic_int_vld,
  pad_yy_gate_clk_en_b,
  pad_yy_test_mode,
  pg_reset_b,
  pmu_corec_isolation,
  pmu_corec_sleep_in
);

// &Ports; @23
input           clk_en;              
input           cpu_clk;             
input           pad_biu_bigend_b;    
input   [2 :0]  pad_biu_clkratio;    
input   [31:0]  pad_biu_hrdata;      
input           pad_biu_hready;      
input   [1 :0]  pad_biu_hresp;       
input           pad_cpu_rst_b;       
input           pad_had_jdb_req_b;   
input           pad_had_jtg_tap_en;  
input           pad_had_jtg_tclk;    
input           pad_had_jtg_trst_b;  
input   [31:0]  pad_vic_int_cfg;     
input   [31:0]  pad_vic_int_vld;     
input           pad_yy_gate_clk_en_b; 
input           pad_yy_test_mode;    
input           pg_reset_b;          
input           pmu_corec_isolation; 
input           pmu_corec_sleep_in;  
output  [31:0]  biu_pad_haddr;       
output  [2 :0]  biu_pad_hburst;      
output  [3 :0]  biu_pad_hprot;       
output  [2 :0]  biu_pad_hsize;       
output  [1 :0]  biu_pad_htrans;      
output  [31:0]  biu_pad_hwdata;      
output          biu_pad_hwrite;      
output  [1 :0]  biu_pad_lpmd_b;      
output  [31:0]  biu_pad_psr;         
output          corec_pmu_sleep_out; 
output          ctim_int_vld;        
output          had_pad_jdb_ack_b;   
output          had_pad_wakeup_req_b; 
output          pad_had_jtg_tms_i;   
inout           i_pad_jtg_tms;       

// &Regs; @24

// &Wires; @25
wire            biu_pad_dbg_b;       
wire    [31:0]  biu_pad_haddr;       
wire    [2 :0]  biu_pad_hburst;      
wire    [3 :0]  biu_pad_hprot;       
wire    [2 :0]  biu_pad_hsize;       
wire    [1 :0]  biu_pad_htrans;      
wire    [31:0]  biu_pad_hwdata;      
wire            biu_pad_hwrite;      
wire            biu_pad_ipend_b;     
wire    [1 :0]  biu_pad_lpmd_b;      
wire    [31:0]  biu_pad_psr;         
wire            biu_pad_retire;      
wire    [31:0]  biu_pad_retire_pc;   
wire            biu_pad_vec_redrct;  
wire            biu_pad_wakeup_b;    
wire    [31:0]  biu_pad_wb_gpr_data; 
wire            biu_pad_wb_gpr_en;   
wire    [4 :0]  biu_pad_wb_gpr_index; 
wire            clk_en;              
wire            cpu_clk;             
wire            ctim_int_vld;        
wire            had_pad_jdb_ack_b;   
wire    [1 :0]  had_pad_jdb_pm;      
wire            had_pad_jtg_tap_on;  
wire            had_pad_jtg_tms_o;   
wire            had_pad_jtg_tms_oe;  
wire            had_pad_wakeup_req_b; 
wire            i_pad_jtg_tms;       
wire    [31:0]  iahbl_pad_haddr;     
wire    [2 :0]  iahbl_pad_hburst;    
wire    [3 :0]  iahbl_pad_hprot;     
wire    [2 :0]  iahbl_pad_hsize;     
wire    [1 :0]  iahbl_pad_htrans;    
wire    [31:0]  iahbl_pad_hwdata;    
wire            iahbl_pad_hwrite;    
wire            iahbl_pad_vec_redrct; 
wire            iu_pad_inst_split;   
wire            pad_biu_bigend_b;    
wire    [2 :0]  pad_biu_clkratio;    
wire    [31:0]  pad_biu_hrdata;      
wire            pad_biu_hready;      
wire    [1 :0]  pad_biu_hresp;       
wire            pad_biu_hresp_0;     
wire            pad_cpu_rst_b;       
wire            pad_had_jdb_req_b;   
wire            pad_had_jtg_tap_en;  
wire            pad_had_jtg_tclk;    
wire            pad_had_jtg_tms_i;   
wire            pad_had_jtg_trst_b;  
wire    [31:0]  pad_iahbl_hrdata;    
wire            pad_iahbl_hready;    
wire    [1 :0]  pad_iahbl_hresp;     
wire    [31:0]  pad_vic_int_cfg;     
wire    [31:0]  pad_vic_int_vld;     
wire            pad_yy_gate_clk_en_b; 
wire            pad_yy_test_mode;    
wire            pg_reset_b;          
wire            sysio_pad_srst;      


// &Instance("CK801_SHYQ", "x_ck801"); @28
// &Connect(.cp0_pad_psr                (biu_pad_psr           ), @29
//          .iu_pad_gpr_index           (biu_pad_wb_gpr_index  ), @30
//          .iu_pad_gpr_we              (biu_pad_wb_gpr_en     ), @31
//          .iu_pad_inst_retire         (biu_pad_retire        ), @32
//          .iu_pad_retire_pc           (biu_pad_retire_pc     ), @33
//          .pad_biu_hrdata_parity      (1'b0                  ), @34
//          .pad_dahbl_hrdata_parity    (1'b0                  ), @35
//          .pad_iahbl_hrdata_parity    (1'b0                  ), @36
//          .pad_sysio_bigend_b         (pad_biu_bigend_b      ), @37
//          .pad_sysio_clkratio         (pad_biu_clkratio      ),   @38
//          .pad_sysio_gsb              (pad_biu_gsb           ),   @39
//          .pad_vic_int_cfg            (pad_vic_int_cfg       ),  @40
//          .pad_ctim_refclk            (1'b0                  ), @41
//          .pad_ctim_calib             (26'b0                 ), @42
//          .pad_bmu_dahbl_base         (12'h200               ), @43
//          .pad_bmu_dahbl_mask         (12'hfff               ), @44
//          .pad_bmu_iahbl_base         (12'h000               ), @45
//          .pad_bmu_iahbl_mask         (12'he00               ), @46
//          .pad_biu_hresp              (pad_biu_hresp        ), @47
//          .pad_dahbl_hresp            (pad_dahbl_hresp_0     ), @48
//          .pad_iahbl_hresp            (pad_iahbl_hresp[0]    ), @49
//          .ctim_pad_int_vld           (ctim_int_vld          ),   @50
//          .sysio_pad_dbg_b            (biu_pad_dbg_b         ),   @51
//          .sysio_pad_ipend_b          (biu_pad_ipend_b       ),   @52
//          .sysio_pad_lpmd_b           (biu_pad_lpmd_b        ),   @53
//          .sysio_pad_wakeup_b         (biu_pad_wakeup_b      ),   @54
//          .iu_pad_gpr_data            (biu_pad_wb_gpr_data   ), @55
//          .pll_core_cpuclk            (cpu_clk               ), @56
//          .cpurst_b                   (pg_reset_b            ), @57
//          .pll_core_cpuclk_nogated    (cpu_clk               ), @58
//          .pad_sysio_endian_v2        (1'b0                  ), @59
//          .pad_had_rst_b              (pad_had_jtg_trst_b    ), @60
//          .pad_had_jtg_trst_b         (pad_had_jtg_trst_b    ), @61
//          .pad_cpu_gpr_rst_b          (pg_reset_b            ), @62
//          .pad_sysio_clk_unlock       (1'b0                  ), @63
//          .pad_cpu_secu_dbg_en        (1'b1                  ) @64
//         ); @65
// &Force("inout","i_pad_jtg_tms"); @69
// &Force("output","pad_had_jtg_tms_i"); @72
// &Force("nonport", "pad_had_jtg_tdi"); @73
// &Force("nonport", "had_pad_jtg_tdo"); @74
// &Force("bus","pad_biu_hresp","1","0"); @78
// &Force("nonport","sysio_pad_srst"); @79
// &Force("nonport","iahbl_pad_vec_redrct"); @80
// &Force("nonport","dahbl_pad_vec_redrct"); @81
// &Force("nonport","biu_pad_vec_redrct"); @82
// &Force("nonport","sysio_pad_gcb"); @84
// &Force("nonport","biu_pad_hwdata_parity"); @85
// &Force("nonport","iahbl_pad_hwdata_parity"); @86
// &Force("nonport","dahbl_pad_hwdata_parity"); @87
// &Force("nonport","iu_pad_inst_split"); @88
// &Force("nonport","nm_top_si_1"); @89
// &Force("nonport","nm_top_si_2"); @90
// &Force("nonport","nm_top_si_3"); @91
// &Force("nonport","nm_top_si_4"); @92
// &Force("nonport","nm_top_so_1"); @93
// &Force("nonport","nm_top_so_2"); @94
// &Force("nonport","nm_top_so_3"); @95
// &Force("nonport","nm_top_so_4"); @96
// &Force("nonport","dahbl_pad_hburst"); @97
// &Force("nonport","dahbl_pad_hprot"); @98
// &Force("nonport","iahbl_pad_hburst"); @99
// &Force("nonport","iahbl_pad_hprot"); @100
// &Force("nonport", "ctim_pad_int_vld"); @101
// &Force("nonport", "pad_adu_data"); @102
// &Force("nonport", "pad_ctim_refclk"); @103
// &Force("nonport","biu_pad_dbg_b"); @104
// &Force("nonport","biu_pad_ipend_b"); @105
// &Force("nonport","biu_pad_wakeup_b"); @106
// &Force("nonport","had_pad_jdb_pm"); @107
// &Force("nonport","had_pad_jtg_tap_on"); @108
// &Force("nonport","had_pad_jtg_tdo_en"); @109


// &Instance("CK802_20190530", "x_ck802"); @116
CK802_20190530  x_ck802 (
  .biu_pad_haddr        (biu_pad_haddr       ),
  .biu_pad_hburst       (biu_pad_hburst      ),
  .biu_pad_hprot        (biu_pad_hprot       ),
  .biu_pad_hsize        (biu_pad_hsize       ),
  .biu_pad_htrans       (biu_pad_htrans      ),
  .biu_pad_hwdata       (biu_pad_hwdata      ),
  .biu_pad_hwrite       (biu_pad_hwrite      ),
  .biu_pad_vec_redrct   (biu_pad_vec_redrct  ),
  .clk_en               (clk_en              ),
  .cp0_pad_psr          (biu_pad_psr         ),
  .ctim_pad_int_vld     (ctim_int_vld        ),
  .had_pad_jdb_ack_b    (had_pad_jdb_ack_b   ),
  .had_pad_jdb_pm       (had_pad_jdb_pm      ),
  .had_pad_jtg_tap_on   (had_pad_jtg_tap_on  ),
  .had_pad_jtg_tms_o    (had_pad_jtg_tms_o   ),
  .had_pad_jtg_tms_oe   (had_pad_jtg_tms_oe  ),
  .had_pad_wakeup_req_b (had_pad_wakeup_req_b),
  .iahbl_pad_haddr      (iahbl_pad_haddr     ),
  .iahbl_pad_hburst     (iahbl_pad_hburst    ),
  .iahbl_pad_hprot      (iahbl_pad_hprot     ),
  .iahbl_pad_hsize      (iahbl_pad_hsize     ),
  .iahbl_pad_htrans     (iahbl_pad_htrans    ),
  .iahbl_pad_hwdata     (iahbl_pad_hwdata    ),
  .iahbl_pad_hwrite     (iahbl_pad_hwrite    ),
  .iahbl_pad_vec_redrct (iahbl_pad_vec_redrct),
  .iu_pad_gpr_data      (biu_pad_wb_gpr_data ),
  .iu_pad_gpr_index     (biu_pad_wb_gpr_index),
  .iu_pad_gpr_we        (biu_pad_wb_gpr_en   ),
  .iu_pad_inst_retire   (biu_pad_retire      ),
  .iu_pad_inst_split    (iu_pad_inst_split   ),
  .iu_pad_retire_pc     (biu_pad_retire_pc   ),
  .pad_biu_hrdata       (pad_biu_hrdata      ),
  .pad_biu_hready       (pad_biu_hready      ),
  .pad_biu_hresp        (pad_biu_hresp_0     ),
  .pad_bmu_iahbl_base   (12'h000             ),
  .pad_bmu_iahbl_mask   (12'he00             ),
  .pad_cpu_rst_b        (pg_reset_b          ),
  .pad_ctim_calib       (26'b0               ),
  .pad_ctim_refclk      (1'b0                ),
  .pad_had_jdb_req_b    (pad_had_jdb_req_b   ),
  .pad_had_jtg_tap_en   (pad_had_jtg_tap_en  ),
  .pad_had_jtg_tclk     (pad_had_jtg_tclk    ),
  .pad_had_jtg_tms_i    (pad_had_jtg_tms_i   ),
  .pad_had_jtg_trst_b   (pad_had_jtg_trst_b  ),
  .pad_had_rst_b        (pad_had_jtg_trst_b  ),
  .pad_iahbl_hrdata     (pad_iahbl_hrdata    ),
  .pad_iahbl_hready     (pad_iahbl_hready    ),
  .pad_iahbl_hresp      (pad_iahbl_hresp[0]  ),
  .pad_sysio_bigend_b   (pad_biu_bigend_b    ),
  .pad_sysio_clk_unlock (1'b0                ),
  .pad_sysio_clkratio   (pad_biu_clkratio    ),
  .pad_sysio_endian_v2  (1'b0                ),
  .pad_vic_int_cfg      (pad_vic_int_cfg     ),
  .pad_vic_int_vld      (pad_vic_int_vld     ),
  .pad_yy_gate_clk_en_b (pad_yy_gate_clk_en_b),
  .pad_yy_test_mode     (pad_yy_test_mode    ),
  .pll_core_cpuclk      (cpu_clk             ),
  .sysio_pad_dbg_b      (biu_pad_dbg_b       ),
  .sysio_pad_ipend_b    (biu_pad_ipend_b     ),
  .sysio_pad_lpmd_b     (biu_pad_lpmd_b      ),
  .sysio_pad_srst       (sysio_pad_srst      ),
  .sysio_pad_wakeup_b   (biu_pad_wakeup_b    )
);

// &Connect(.cp0_pad_psr                (biu_pad_psr           ), @117
//          .iu_pad_gpr_index           (biu_pad_wb_gpr_index  ), @118
//          .iu_pad_gpr_we              (biu_pad_wb_gpr_en     ), @119
//          .iu_pad_inst_retire         (biu_pad_retire        ), @120
//          .iu_pad_retire_pc           (biu_pad_retire_pc     ), @121
//          .pad_biu_hrdata_parity      (1'b0                  ), @122
//          .pad_dahbl_hrdata_parity    (1'b0                  ), @123
//          .pad_iahbl_hrdata_parity    (1'b0                  ), @124
//          .pad_sysio_bigend_b         (pad_biu_bigend_b      ), @125
//          .pad_sysio_clkratio         (pad_biu_clkratio      ),   @126
//          .pad_sysio_gsb              (pad_biu_gsb           ),   @127
//          .pad_vic_int_cfg            (pad_vic_int_cfg       ),  @128
//          .pad_ctim_refclk            (1'b0                  ), @129
//          .pad_ctim_calib             (26'b0                 ), @130
//          .pad_bmu_dahbl_base         (12'h200               ), @131
//          .pad_bmu_dahbl_mask         (12'hfff               ), @132
//          .pad_bmu_iahbl_base         (12'h000               ), @133
//          .pad_bmu_iahbl_mask         (12'he00               ), @134
//          .pad_biu_hresp              (pad_biu_hresp_0       ), @135
//          .pad_dahbl_hresp            (pad_dahbl_hresp_0     ), @136
//          .pad_dahbl_hsec             (1'b0                  ), @137
//          .pad_iahbl_hresp            (pad_iahbl_hresp[0]    ), @138
//          .pad_iahbl_hsec             (1'b0                  ), @139
//          .ctim_pad_int_vld           (ctim_int_vld          ),   @140
//          .sysio_pad_dbg_b            (biu_pad_dbg_b         ),   @141
//          .sysio_pad_ipend_b          (biu_pad_ipend_b       ),   @142
//          .sysio_pad_lpmd_b           (biu_pad_lpmd_b        ),   @143
//          .sysio_pad_wakeup_b         (biu_pad_wakeup_b      ),   @144
//          .iu_pad_gpr_data            (biu_pad_wb_gpr_data   ), @145
//          .pll_core_cpuclk            (cpu_clk               ), @146
//          .pad_cpu_rst_b              (pg_reset_b            ), @147
//          .pll_core_cpuclk_nogated    (cpu_clk               ), @148
//          .pad_sysio_endian_v2        (1'b0                  ), @149
//          .pad_had_rst_b              (pad_had_jtg_trst_b    ), @150
//          .pad_had_jtg_trst_b         (pad_had_jtg_trst_b    ), @151
//          .pad_cpu_gpr_rst_b          (pg_reset_b            ), @152
//          .pad_sysio_clk_unlock       (1'b0                  ),   @153
//          .pad_cpu_secu_dbg_en        (1'b1                  ) @154
// 	  @155
//         ); @156


// &Force("inout","i_pad_jtg_tms"); @161
assign i_pad_jtg_tms = had_pad_jtg_tms_oe ? had_pad_jtg_tms_o : 1'bz;
assign pad_had_jtg_tms_i = i_pad_jtg_tms;
// &Force("output","pad_had_jtg_tms_i"); @164
// &Force("nonport", "pad_had_jtg_tdi"); @165
// &Force("nonport", "had_pad_jtg_tdo"); @166

// &Force("nonport","pad_cpu_secu_dbg_en"); @171

// &Force("nonport","pad_cpu_secu_dbg_en"); @176

// //&Force("nonport", "biu_pad_psr") @181


assign pad_biu_hresp_0 = pad_biu_hresp[0];

// &Instance("dahb_mem_ctrl", "x_dahb_mem_ctrl"); @193
// &Connect(.lite_yy_haddr   (dahbl_pad_haddr     ), @194
//          .lite_yy_hsize   (dahbl_pad_hsize     ), @195
//          .lite_yy_htrans  (dahbl_pad_htrans    ), @196
//          .lite_yy_hwdata  (dahbl_pad_hwdata    ), @197
//          .lite_yy_hwrite  (dahbl_pad_hwrite    ), @198
//          .mmc_lite_hrdata (pad_dahbl_hrdata    ), @199
//          .mmc_lite_hready (pad_dahbl_hready    ), @200
//          .mmc_lite_hresp  (pad_dahbl_hresp     ), @201
//          .lite_mmc_hsel   (dahbl_pad_htrans[1] ), @202
//          .pll_core_cpuclk (cpu_clk             ) @203
//  @204
//         ); @205
// &Force("nonport","dahbl_pad_hburst"); @208
// &Force("nonport","dahbl_pad_hprot"); @209
// &Force("bus","pad_biu_hresp","1","0"); @212
// &Force("nonport","sysio_pad_srst"); @213
// &Force("nonport","iahbl_pad_vec_redrct"); @214
// &Force("nonport","dahbl_pad_vec_redrct"); @215
// &Force("nonport","biu_pad_vec_redrct"); @216
// &Force("nonport","biu_pad_ipend_b"); @217
// &Force("nonport","sysio_pad_gcb"); @218
// &Force("nonport","biu_pad_hwdata_parity"); @219
// &Force("nonport","iahbl_pad_hwdata_parity"); @220
// &Force("nonport","dahbl_pad_hwdata_parity"); @221
// &Force("nonport","iu_pad_inst_split"); @222
// &Force("nonport","nm_top_si_1"); @223
// &Force("nonport","nm_top_si_2"); @224
// &Force("nonport","nm_top_si_3"); @225
// &Force("nonport","nm_top_si_4"); @226
// &Force("nonport","nm_top_so_1"); @227
// &Force("nonport","nm_top_so_2"); @228
// &Force("nonport","nm_top_so_3"); @229
// &Force("nonport","nm_top_so_4"); @230
// &Force("nonport","dahbl_pad_hburst"); @231
// &Force("nonport","dahbl_pad_hprot"); @232
// &Force("nonport","iahbl_pad_hburst"); @233
// &Force("nonport","iahbl_pad_hprot"); @234
// &Force("nonport", "ctim_pad_int_vld"); @235
// &Force("nonport", "pad_adu_data"); @236
// &Force("nonport", "pad_ctim_refclk"); @237
// &Force("nonport","biu_pad_dbg_b"); @238
// &Force("nonport","biu_pad_wakeup_b"); @239
// &Force("nonport","had_pad_jdb_pm"); @240
// &Force("nonport","had_pad_jtg_tap_on"); @241
// &Force("nonport","had_pad_jtg_tdo_en"); @242

// IAHB Lite Memory
// &Instance("iahb_mem_ctrl", "x_iahb_mem_ctrl"); @246
iahb_mem_ctrl  x_iahb_mem_ctrl (
  .lite_mmc_hsel       (iahbl_pad_htrans[1]),
  .lite_yy_haddr       (iahbl_pad_haddr    ),
  .lite_yy_hsize       (iahbl_pad_hsize    ),
  .lite_yy_htrans      (iahbl_pad_htrans   ),
  .lite_yy_hwdata      (iahbl_pad_hwdata   ),
  .lite_yy_hwrite      (iahbl_pad_hwrite   ),
  .mmc_lite_hrdata     (pad_iahbl_hrdata   ),
  .mmc_lite_hready     (pad_iahbl_hready   ),
  .mmc_lite_hresp      (pad_iahbl_hresp    ),
  .pad_biu_bigend_b    (pad_biu_bigend_b   ),
  .pad_cpu_rst_b       (pad_cpu_rst_b      ),
  .pll_core_cpuclk     (cpu_clk            )
);

// &Connect(.lite_yy_haddr   (iahbl_pad_haddr     ), @247
//          .lite_yy_hsize   (iahbl_pad_hsize     ), @248
//          .lite_yy_htrans  (iahbl_pad_htrans    ), @249
//          .lite_yy_hwdata  (iahbl_pad_hwdata    ),  @250
//          .lite_yy_hwrite  (iahbl_pad_hwrite    ), @251
//          .mmc_lite_hrdata (pad_iahbl_hrdata    ),  @252
//          .mmc_lite_hready (pad_iahbl_hready    ), @253
//          .mmc_lite_hresp  (pad_iahbl_hresp     ),  @254
//          .lite_mmc_hsel   (iahbl_pad_htrans[1] ), @255
//          .pll_core_cpuclk (cpu_clk             ) @256
//         ); @257

// &Force("nonport","cache_data_array0_smbist_done"); @259
// &Force("nonport","cache_data_array0_smbist_fail"); @260
// &Force("nonport","cache_data_array1_smbist_done"); @261
// &Force("nonport","cache_data_array1_smbist_fail"); @262
// &Force("nonport","cache_tag_array0_smbist_done"); @263
// &Force("nonport","cache_tag_array0_smbist_fail"); @264



// &Instance("CK803_IDLITE_AHBLITE_J2_NEW","x_ck803"); @271
// &Connect(.cp0_pad_psr           (biu_pad_psr           ), @272
//          .iu_pad_inst_retire    (biu_pad_retire        ), @273
//          .iu_pad_retire_pc      (biu_pad_retire_pc     ), @274
//          .iu_pad_gpr_index      (biu_pad_wb_gpr_index  ), @275
//          .iu_pad_gpr_we         (biu_pad_wb_gpr_en     ), @276
//          .iu_pad_gpr_data       (biu_pad_wb_gpr_data   ), @277
//          .ctim_pad_int_vld      (ctim_int_vld          ), @278
//          .pad_biu_hresp         (pad_biu_hresp_0       ), @279
//          .pad_dahbl_hresp       (pad_dahbl_hresp_0     ), @280
//          .pad_iahbl_hresp       (pad_iahbl_hresp[0]    ),  @281
//          .pad_ctim_calib        (26'b0                 ), @282
//          .pad_ctim_refclk       (1'b0                  ), @283
//          .pad_vic_int_cfg       (pad_vic_int_cfg       ),   @284
//          .pad_biu_brkrq_b       (2'b11                 ) @285
//         ); @286
// &Force("inout","i_pad_jtg_tms"); @292
// &Force("output","pad_had_jtg_tms_i"); @295
// &Force("nonport", "pad_had_jtg_tdi"); @296
// &Force("nonport", "had_pad_jtg_tdo"); @297
// &Instance("dahb_mem_ctrl", "x_dahb_mem_ctrl"); @307
// &Connect(.lite_yy_haddr   (dahbl_pad_haddr     ), @308
//          .lite_yy_hsize   (dahbl_pad_hsize     ), @309
//          .lite_yy_htrans  (dahbl_pad_htrans    ), @310
//          .lite_yy_hwdata  (dahbl_pad_hwdata    ), @311
//          .lite_yy_hwrite  (dahbl_pad_hwrite    ), @312
//          .mmc_lite_hrdata (pad_dahbl_hrdata    ), @313
//          .mmc_lite_hready (pad_dahbl_hready    ), @314
//          .mmc_lite_hresp  (pad_dahbl_hresp     ), @315
//          .lite_mmc_hsel   (dahbl_pad_htrans[1] ) @316
//         ); @317
// &Force("nonport","dahbl_pad_hburst"); @319
// &Force("nonport","dahbl_pad_hprot"); @320
// &Force("bus","pad_biu_hresp","1","0"); @326
// &Force("nonport","biu_pad_gcb"); @327
// &Force("output","had_pad_jtg_tdo_en"); @328
// &Force("nonport","cpu_pad_int_ack"); @329
// &Force("nonport","iu_pad_inst_split"); @330
// &Force("nonport","ct_top_si_1"); @331
// &Force("nonport","ct_top_si_2"); @332
// &Force("nonport","ct_top_si_3"); @333
// &Force("nonport","ct_top_si_4"); @334
// &Force("nonport","ct_top_si_5"); @335
// &Force("nonport","ct_top_si_6"); @336
// &Force("nonport","ct_top_si_7"); @337
// &Force("nonport","ct_top_si_8"); @338
// &Force("nonport","ct_top_si_9"); @339
// &Force("nonport","ct_top_si_10"); @340
// &Force("nonport","ct_top_si_11"); @341
// &Force("nonport","ct_top_si_12"); @342
// &Force("nonport","ct_top_so_1"); @343
// &Force("nonport","ct_top_so_2"); @344
// &Force("nonport","ct_top_so_3"); @345
// &Force("nonport","ct_top_so_4"); @346
// &Force("nonport","ct_top_so_5"); @347
// &Force("nonport","ct_top_so_6"); @348
// &Force("nonport","ct_top_so_7"); @349
// &Force("nonport","ct_top_so_8"); @350
// &Force("nonport","ct_top_so_9"); @351
// &Force("nonport","ct_top_so_10"); @352
// &Force("nonport","ct_top_so_11"); @353
// &Force("nonport","ct_top_so_12"); @354
// &Force("nonport","biu_pad_wakeup_b"); @355
// &Force("nonport","biu_pad_idly4_b"); @356
// &Force("nonport","biu_pad_ipend_b"); @357
// &Force("nonport","had_pad_jtg_tap_on"); @358
// &Force("nonport","had_pad_jtg_tdo_en"); @359
// &Force("nonport","biu_pad_dbg_b"); @360
// &Force("nonport","had_pad_jdb_pm"); @361
// &Instance("iahb_mem_ctrl", "x_iahb_mem_ctrl"); @365
// &Connect(.lite_yy_haddr   (iahbl_pad_haddr     ), @366
//          .lite_yy_hsize   (iahbl_pad_hsize     ), @367
//          .lite_yy_htrans  (iahbl_pad_htrans    ), @368
//          .lite_yy_hwdata  (iahbl_pad_hwdata    ),  @369
//          .lite_yy_hwrite  (iahbl_pad_hwrite    ), @370
//          .mmc_lite_hrdata (pad_iahbl_hrdata    ),  @371
//          .mmc_lite_hready (pad_iahbl_hready    ), @372
//          .mmc_lite_hresp  (pad_iahbl_hresp     ),  @373
//          .lite_mmc_hsel   (iahbl_pad_htrans[1] ) @374
//         ); @375
// &Force("nonport","iahbl_pad_hburst"); @376
// &Force("nonport","iahbl_pad_hprot"); @377

// &Instance("CK803S2E_20170502","x_ck803s"); @383
// &Connect(.cp0_pad_psr                (biu_pad_psr           ), @384
//          .rtu_pad_inst_retire        (biu_pad_retire        ), @385
//          .rtu_pad_retire_pc          (biu_pad_retire_pc     ), @386
//          .rtu_pad_gpr_index          (biu_pad_wb_gpr_index  ), @387
//          .rtu_pad_gpr_we             (biu_pad_wb_gpr_en     ), @388
//          .rtu_pad_gpr_data           (biu_pad_wb_gpr_data   ), @389
//          .ctim_pad_int_vld           (ctim_int_vld          ), @390
//          .pad_ctim_calib             (26'b0                 ), @391
//          .pad_ctim_refclk            (1'b0                  ), @392
//          .pad_vic_int_cfg            (pad_vic_int_cfg       ),   @393
//          .pad_sysio_bigend_b         (pad_biu_bigend_b      ), @394
//          .pad_sysio_clkratio         (pad_biu_clkratio      ),   @395
//          .pad_sysio_gsb              (pad_biu_gsb           ), @396
//          .sysio_pad_dbg_b            (biu_pad_dbg_b         ),   @397
//          .sysio_pad_ipend_b          (biu_pad_ipend_b       ),   @398
//          .sysio_pad_lpmd_b           (biu_pad_lpmd_b        ),   @399
//          .sysio_pad_wakeup_b         (biu_pad_wakeup_b      ), @400
//          .pad_bmu_dahbl_base         (20'h20000             ), @401
//          .pad_bmu_dahbl_mask         (20'he0000             ), @402
//          .pad_bmu_iahbl_base         (20'h00000             ), @403
//          .pad_bmu_iahbl_mask         (20'he0000             ), @404
// 	 .ilite_clk_en               (1'b1                  ), @405
// 	 .pad_dahbl_hsec             (1'b0                  ), @406
// 	 .pad_iahbl_hsec             (1'b0                  ), @407
// 	 .dlite_clk_en               (1'b1                  ), @408
//          .pad_cpu_secu_dbg_en        (1'b1                  ), @409
//          .pll_core_cpuclk            (cpu_clk               ), @410
//          .pad_cpu_rst_b              (pg_reset_b            )  @411
//           ); @412
// &Force("nonport","pad_cpu_secu_dbg_en"); @416
// &Force("nonport","sysio_pad_gcb"); @419
// &Instance("dahb_mem_ctrl", "x_dahb_mem_ctrl"); @422
// &Connect(.lite_yy_haddr   (dahbl_pad_haddr     ), @423
//          .lite_yy_hsize   (dahbl_pad_hsize     ), @424
//          .lite_yy_htrans  (dahbl_pad_htrans    ), @425
//          .lite_yy_hwdata  (dahbl_pad_hwdata    ),  @426
//          .lite_yy_hwrite  (dahbl_pad_hwrite    ), @427
//          .mmc_lite_hrdata (pad_dahbl_hrdata    ),  @428
//          .mmc_lite_hready (pad_dahbl_hready    ), @429
//          .mmc_lite_hresp  (pad_dahbl_hresp     ),  @430
//          .lite_mmc_hsel   (dahbl_pad_htrans[1] ), @431
//          .pll_core_cpuclk (cpu_clk             ) @432
//         ); @433
// &Force("nonport","dahbl_pad_hburst"); @435
// &Force("nonport","dahbl_pad_hprot"); @436
// &Instance("iahb_mem_ctrl", "x_iahb_mem_ctrl"); @442
// &Connect(.lite_yy_haddr   (iahbl_pad_haddr     ), @443
//          .lite_yy_hsize   (iahbl_pad_hsize     ), @444
//          .lite_yy_htrans  (iahbl_pad_htrans    ), @445
//          .lite_yy_hwdata  (iahbl_pad_hwdata    ),  @446
//          .lite_yy_hwrite  (iahbl_pad_hwrite    ), @447
//          .mmc_lite_hrdata (pad_iahbl_hrdata    ),  @448
//          .mmc_lite_hready (pad_iahbl_hready    ), @449
//          .mmc_lite_hresp  (pad_iahbl_hresp     ),  @450
//          .lite_mmc_hsel   (iahbl_pad_htrans[1] ), @451
//          .pll_core_cpuclk (cpu_clk             ) @452
//         ); @453
// &Force("output","pad_had_jtg_tms_i"); @459
// &Force("nonport", "had_pad_jtg_tms_o"); @460
// &Force("nonport", "had_pad_jtg_tms_oe"); @461
// &Force("inout","i_pad_jtg_tms"); @464
// &Force("output","pad_had_jtg_tms_i"); @468
// &Force("nonport", "pad_had_jtg_tdi"); @469
// &Force("nonport", "had_pad_jtg_tdo"); @470
// &Force("nonport", "rtu_pad_fpr_data"); @475
// &Force("nonport", "rtu_pad_fpr_index"); @476
// &Force("nonport", "rtu_pad_fpr_we"); @477
// &Force("nonport", "rtu_pad_fesr"); @478
// &Force("nonport","rtu_pad_gpr_data_1"); @483
// &Force("nonport","rtu_pad_gpr_index_1"); @484
// &Force("nonport","rtu_pad_gpr_we_1"); @485
// &Force("nonport","pad_cpu_secu_dbg_en"); @486
// &Force("nonport","sysio_pad_srst"); @487
// &Force("nonport","iahbl_pad_hburst"); @488
// &Force("nonport","iahbl_pad_hprot"); @489
// &Force("nonport","biu_pad_ipend_b"); @490
// &Force("nonport","biu_pad_dbg_b"); @491
// &Force("nonport","biu_pad_wakeup_b"); @492
// &Force("nonport","had_pad_jdb_pm"); @493
// &Force("nonport","had_pad_jtg_tap_on"); @494
// &Force("nonport","had_pad_jtg_tdo_en"); @495
// &Force("nonport","iu_pad_mult_hi"); @496
// &Force("nonport","iu_pad_mult_lo"); @497
// &Force("nonport","iu_pad_mult_updt_hi"); @498
// &Force("nonport","iu_pad_mult_updt_lo"); @499
// &Force("nonport","rtu_pad_inst_split"); @500
// &Force("nonport","pad_sysio_dbgrq_b"); @501
// &Force("nonport","sysio_pad_idly4_b"); @502
// &Force("nonport","vg_top_si_1"); @503
// &Force("nonport","vg_top_si_2"); @504
// &Force("nonport","vg_top_si_3"); @505
// &Force("nonport","vg_top_si_4"); @506
// &Force("nonport","vg_top_so_1"); @507
// &Force("nonport","vg_top_so_2"); @508
// &Force("nonport","vg_top_so_3"); @509
// &Force("nonport","vg_top_so_4"); @510
// &Force("nonport","icache_data_array0_smbist_done"); @512
// &Force("nonport","icache_data_array0_smbist_fail"); @513
// &Force("nonport","icache_data_array1_smbist_done"); @514
// &Force("nonport","icache_data_array1_smbist_fail"); @515
// &Force("nonport","icache_tag_array_smbist_done"); @516
// &Force("nonport","icache_tag_array_smbist_fail"); @517
// &Force("nonport","icache_data_array2_smbist_done"); @518
// &Force("nonport","icache_data_array2_smbist_fail"); @519
// &Force("nonport","icache_data_array3_smbist_done"); @520
// &Force("nonport","icache_data_array3_smbist_fail"); @521

// &Instance("CK804EF_181029","x_ck804"); @526
// &Connect(.cp0_pad_psr                (biu_pad_psr           ), @527
//          .rtu_pad_inst_retire        (biu_pad_retire        ), @528
//          .rtu_pad_retire_pc          (biu_pad_retire_pc     ), @529
//          .rtu_pad_gpr_index          (biu_pad_wb_gpr_index  ), @530
//          .rtu_pad_gpr_we             (biu_pad_wb_gpr_en     ), @531
//          .rtu_pad_gpr_data           (biu_pad_wb_gpr_data   ), @532
//          .ctim_pad_int_vld           (ctim_int_vld          ), @533
//          .pad_ctim_calib             (26'b0                 ), @534
//          .pad_ctim_refclk            (1'b0                  ), @535
//          .pad_vic_int_cfg            (pad_vic_int_cfg       ),   @536
//          .pad_sysio_bigend_b         (pad_biu_bigend_b      ), @537
//          .pad_sysio_clkratio         (pad_biu_clkratio      ),   @538
//          .pad_sysio_gsb              (pad_biu_gsb           ), @539
//          .sysio_pad_dbg_b            (biu_pad_dbg_b         ),   @540
//          .sysio_pad_ipend_b          (biu_pad_ipend_b       ),   @541
//          .sysio_pad_lpmd_b           (biu_pad_lpmd_b        ),   @542
//          .sysio_pad_wakeup_b         (biu_pad_wakeup_b      ), @543
//          .pad_bmu_dahbl_base         (20'h20000             ), @544
//          .pad_bmu_dahbl_mask         (20'he0000             ), @545
//          .pad_bmu_iahbl_base         (20'h00000             ), @546
//          .pad_bmu_iahbl_mask         (20'he0000             ), @547
// 	 .ilite_clk_en               (1'b1                  ), @548
// 	 .pad_dahbl_hsec             (1'b0                  ), @549
// 	 .pad_iahbl_hsec             (1'b0                  ), @550
// 	 .dlite_clk_en               (1'b1                  ), @551
//          .pad_cpu_secu_dbg_en        (1'b1                  ), @552
//          .pll_core_cpuclk            (cpu_clk               ), @553
//          .pad_cpu_rst_b              (pg_reset_b            )  @554
//           ); @555
// &Force("nonport","pad_cpu_secu_dbg_en"); @559
// &Force("nonport","sysio_pad_gcb"); @562
// &Instance("dahb_mem_ctrl", "x_dahb_mem_ctrl"); @565
// &Connect(.lite_yy_haddr   (dahbl_pad_haddr     ), @566
//          .lite_yy_hsize   (dahbl_pad_hsize     ), @567
//          .lite_yy_htrans  (dahbl_pad_htrans    ), @568
//          .lite_yy_hwdata  (dahbl_pad_hwdata    ),  @569
//          .lite_yy_hwrite  (dahbl_pad_hwrite    ), @570
//          .mmc_lite_hrdata (pad_dahbl_hrdata    ),  @571
//          .mmc_lite_hready (pad_dahbl_hready    ), @572
//          .mmc_lite_hresp  (pad_dahbl_hresp     ),  @573
//          .lite_mmc_hsel   (dahbl_pad_htrans[1] ), @574
//          .pll_core_cpuclk (cpu_clk             ) @575
//         ); @576
// &Force("nonport","dahbl_pad_hburst"); @578
// &Force("nonport","dahbl_pad_hprot"); @579
// &Instance("iahb_mem_ctrl", "x_iahb_mem_ctrl"); @585
// &Connect(.lite_yy_haddr   (iahbl_pad_haddr     ), @586
//          .lite_yy_hsize   (iahbl_pad_hsize     ), @587
//          .lite_yy_htrans  (iahbl_pad_htrans    ), @588
//          .lite_yy_hwdata  (iahbl_pad_hwdata    ),  @589
//          .lite_yy_hwrite  (iahbl_pad_hwrite    ), @590
//          .mmc_lite_hrdata (pad_iahbl_hrdata    ),  @591
//          .mmc_lite_hready (pad_iahbl_hready    ), @592
//          .mmc_lite_hresp  (pad_iahbl_hresp     ),  @593
//          .lite_mmc_hsel   (iahbl_pad_htrans[1] ), @594
//          .pll_core_cpuclk (cpu_clk             ) @595
//         ); @596
// &Force("output","pad_had_jtg_tms_i"); @602
// &Force("nonport", "had_pad_jtg_tms_o"); @603
// &Force("nonport", "had_pad_jtg_tms_oe"); @604
// &Force("inout","i_pad_jtg_tms"); @607
// &Force("output","pad_had_jtg_tms_i"); @611
// &Force("nonport", "pad_had_jtg_tdi"); @612
// &Force("nonport", "had_pad_jtg_tdo"); @613
// &Force("nonport", "rtu_pad_fpr_data"); @618
// &Force("nonport", "rtu_pad_fpr_index"); @619
// &Force("nonport", "rtu_pad_fpr_we"); @620
// &Force("nonport", "rtu_pad_fesr"); @621
// &Force("nonport","rtu_pad_gpr_data_1"); @626
// &Force("nonport","rtu_pad_gpr_index_1"); @627
// &Force("nonport","rtu_pad_gpr_we_1"); @628
// &Force("nonport","pad_cpu_secu_dbg_en"); @629
// &Force("nonport","sysio_pad_srst"); @630
// &Force("nonport","iahbl_pad_hburst"); @631
// &Force("nonport","iahbl_pad_hprot"); @632
// &Force("nonport","biu_pad_ipend_b"); @633
// &Force("nonport","biu_pad_dbg_b"); @634
// &Force("nonport","biu_pad_wakeup_b"); @635
// &Force("nonport","had_pad_jdb_pm"); @636
// &Force("nonport","had_pad_jtg_tap_on"); @637
// &Force("nonport","had_pad_jtg_tdo_en"); @638
// &Force("nonport","iu_pad_mult_hi"); @639
// &Force("nonport","iu_pad_mult_lo"); @640
// &Force("nonport","iu_pad_mult_updt_hi"); @641
// &Force("nonport","iu_pad_mult_updt_lo"); @642
// &Force("nonport","rtu_pad_inst_split"); @643
// &Force("nonport","pad_sysio_dbgrq_b"); @644
// &Force("nonport","sysio_pad_idly4_b"); @645
// &Force("nonport","vg_top_si_1"); @646
// &Force("nonport","vg_top_si_2"); @647
// &Force("nonport","vg_top_si_3"); @648
// &Force("nonport","vg_top_si_4"); @649
// &Force("nonport","vg_top_so_1"); @650
// &Force("nonport","vg_top_so_2"); @651
// &Force("nonport","vg_top_so_3"); @652
// &Force("nonport","vg_top_so_4"); @653
// &Force("nonport","icache_data_array0_smbist_done"); @655
// &Force("nonport","icache_data_array0_smbist_fail"); @656
// &Force("nonport","icache_data_array1_smbist_done"); @657
// &Force("nonport","icache_data_array1_smbist_fail"); @658
// &Force("nonport","icache_tag_array_smbist_done"); @659
// &Force("nonport","icache_tag_array_smbist_fail"); @660
// &Force("nonport","icache_data_array2_smbist_done"); @661
// &Force("nonport","icache_data_array2_smbist_fail"); @662
// &Force("nonport","icache_data_array3_smbist_done"); @663
// &Force("nonport","icache_data_array3_smbist_fail"); @664


// &Force("input", "pmu_corec_isolation"); @669
// &Force("input", "pmu_corec_sleep_in"); @670
// &Force("output", "corec_pmu_sleep_out"); @671


// &Force("nonport","pad_had_jtag2_sel"); @674
// &Force("nonport","sysio_pad_srst"); @675
// &Force("nonport","biu_pad_retire"); @676
// &Force("nonport","biu_pad_retire_pc"); @677
// &Force("nonport","biu_pad_wb_gpr_data"); @678
// &Force("nonport","biu_pad_wb_gpr_en"); @679
// &Force("nonport","biu_pad_wb_gpr_index"); @680
// &ModuleEnd; @681
endmodule


