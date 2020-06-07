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
  i_pad_jtg_tms,
  pad_biu_bigend_b,
  pad_biu_hrdata,
  pad_biu_hready,
  pad_biu_hresp,
  pad_cpu_rst_b,
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
input   [31:0]  pad_biu_hrdata;      
input           pad_biu_hready;      
input   [1 :0]  pad_biu_hresp;       
input           pad_cpu_rst_b;       
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
output          pad_had_jtg_tms_i;   
inout           i_pad_jtg_tms;       

// &Regs; @24

// &Wires; @25
wire    [31:0]  biu_pad_haddr;       
wire    [2 :0]  biu_pad_hburst;      
wire    [3 :0]  biu_pad_hprot;       
wire    [2 :0]  biu_pad_hsize;       
wire    [1 :0]  biu_pad_htrans;      
wire    [31:0]  biu_pad_hwdata;      
wire            biu_pad_hwrite;      
wire    [1 :0]  biu_pad_lpmd_b;      
wire    [31:0]  biu_pad_psr;         
wire            biu_pad_retire;      
wire    [31:0]  biu_pad_retire_pc;   
wire    [31:0]  biu_pad_wb_gpr_data; 
wire            biu_pad_wb_gpr_en;   
wire    [4 :0]  biu_pad_wb_gpr_index; 
wire            cpu_clk;             
wire            cpu_pad_dfs_ack;     
wire            ctim_int_vld;        
wire    [1 :0]  had_pad_jdb_pm;      
wire            had_pad_jtg_tms_o;   
wire            had_pad_jtg_tms_oe;  
wire            i_pad_jtg_tms;       
wire    [31:0]  iahbl_pad_haddr;     
wire    [2 :0]  iahbl_pad_hburst;    
wire    [3 :0]  iahbl_pad_hprot;     
wire    [2 :0]  iahbl_pad_hsize;     
wire    [1 :0]  iahbl_pad_htrans;    
wire    [31:0]  iahbl_pad_hwdata;    
wire            iahbl_pad_hwrite;    
wire            iu_pad_inst_split;   
wire            pad_biu_bigend_b;    
wire    [31:0]  pad_biu_hrdata;      
wire            pad_biu_hready;      
wire    [1 :0]  pad_biu_hresp;       
wire            pad_biu_hresp_0;     
wire            pad_cpu_rst_b;       
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
wire            sysio_pad_idlyn_b;   
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


// &Instance("CK802_20200318_FPGA", "x_ck802"); @116
CK802_20200318_FPGA  x_ck802 (
  .biu_pad_haddr        (biu_pad_haddr       ),
  .biu_pad_hburst       (biu_pad_hburst      ),
  .biu_pad_hprot        (biu_pad_hprot       ),
  .biu_pad_hsize        (biu_pad_hsize       ),
  .biu_pad_htrans       (biu_pad_htrans      ),
  .biu_pad_hwdata       (biu_pad_hwdata      ),
  .biu_pad_hwrite       (biu_pad_hwrite      ),
  .cp0_pad_psr          (biu_pad_psr         ),
  .cpu_pad_dfs_ack      (cpu_pad_dfs_ack     ),
  .ctim_pad_int_vld     (ctim_int_vld        ),
  .had_pad_jdb_pm       (had_pad_jdb_pm      ),
  .had_pad_jtg_tms_o    (had_pad_jtg_tms_o   ),
  .had_pad_jtg_tms_oe   (had_pad_jtg_tms_oe  ),
  .iahbl_pad_haddr      (iahbl_pad_haddr     ),
  .iahbl_pad_hburst     (iahbl_pad_hburst    ),
  .iahbl_pad_hprot      (iahbl_pad_hprot     ),
  .iahbl_pad_hsize      (iahbl_pad_hsize     ),
  .iahbl_pad_htrans     (iahbl_pad_htrans    ),
  .iahbl_pad_hwdata     (iahbl_pad_hwdata    ),
  .iahbl_pad_hwrite     (iahbl_pad_hwrite    ),
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
  .pad_cpu_dfs_req      (1'b0                ),
  .pad_cpu_rst_b        (pg_reset_b          ),
  .pad_ctim_calib       (26'b0               ),
  .pad_ctim_refclk      (1'b0                ),
  .pad_had_jtg_tclk     (pad_had_jtg_tclk    ),
  .pad_had_jtg_tms_i    (pad_had_jtg_tms_i   ),
  .pad_had_jtg_trst_b   (pad_had_jtg_trst_b  ),
  .pad_had_rst_b        (pad_had_jtg_trst_b  ),
  .pad_iahbl_hrdata     (pad_iahbl_hrdata    ),
  .pad_iahbl_hready     (pad_iahbl_hready    ),
  .pad_iahbl_hresp      (pad_iahbl_hresp[0]  ),
  .pad_sysio_bigend_b   (pad_biu_bigend_b    ),
  .pad_sysio_dbgrq_b    (1'b1                ),
  .pad_sysio_endian_v2  (1'b0                ),
  .pad_vic_int_cfg      (pad_vic_int_cfg     ),
  .pad_vic_int_vld      (pad_vic_int_vld     ),
  .pad_yy_gate_clk_en_b (pad_yy_gate_clk_en_b),
  .pad_yy_test_mode     (pad_yy_test_mode    ),
  .pll_core_cpuclk      (cpu_clk             ),
  .sysio_pad_idlyn_b    (sysio_pad_idlyn_b   ),
  .sysio_pad_lpmd_b     (biu_pad_lpmd_b      ),
  .sysio_pad_srst       (sysio_pad_srst      )
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
//          .pad_cpu_dfs_req            (1'b0                  ), @141
//          .cpu_pad_dfs_ack            (cpu_pad_dfs_ack       ), @142
//          .pad_sysio_dbgrq_b          (1'b1                  ), @143
//          .sysio_pad_dbg_b            (biu_pad_dbg_b         ),   @144
//          .sysio_pad_ipend_b          (biu_pad_ipend_b       ),   @145
//          .sysio_pad_lpmd_b           (biu_pad_lpmd_b        ),   @146
//          .sysio_pad_wakeup_b         (biu_pad_wakeup_b      ),   @147
//          .iu_pad_gpr_data            (biu_pad_wb_gpr_data   ), @148
//          .pll_core_cpuclk            (cpu_clk               ), @149
//          .pad_cpu_rst_b              (pg_reset_b            ), @150
//          .pll_core_cpuclk_nogated    (cpu_clk               ), @151
//          .pad_sysio_endian_v2        (1'b0                  ), @152
//          .pad_had_rst_b              (pad_had_jtg_trst_b    ), @153
//          .pad_had_jtg_trst_b         (pad_had_jtg_trst_b    ), @154
//          .pad_cpu_gpr_rst_b          (pg_reset_b            ), @155
//          .pad_sysio_clk_unlock       (1'b0                  ),   @156
//          .pad_cpu_secu_dbg_en        (1'b1                  ) @157
// 	  @158
//         ); @159


// &Force("inout","i_pad_jtg_tms"); @164
assign i_pad_jtg_tms = had_pad_jtg_tms_oe ? had_pad_jtg_tms_o : 1'bz;
assign pad_had_jtg_tms_i = i_pad_jtg_tms;
// &Force("output","pad_had_jtg_tms_i"); @167
// &Force("nonport", "pad_had_jtg_tdi"); @168
// &Force("nonport", "had_pad_jtg_tdo"); @169

// &Force("nonport","pad_cpu_secu_dbg_en"); @174

// &Force("nonport","pad_cpu_secu_dbg_en"); @179

// //&Force("nonport", "biu_pad_psr") @184


assign pad_biu_hresp_0 = pad_biu_hresp[0];

// &Instance("dahb_mem_ctrl", "x_dahb_mem_ctrl"); @196
// &Connect(.lite_yy_haddr   (dahbl_pad_haddr     ), @197
//          .lite_yy_hsize   (dahbl_pad_hsize     ), @198
//          .lite_yy_htrans  (dahbl_pad_htrans    ), @199
//          .lite_yy_hwdata  (dahbl_pad_hwdata    ), @200
//          .lite_yy_hwrite  (dahbl_pad_hwrite    ), @201
//          .mmc_lite_hrdata (pad_dahbl_hrdata    ), @202
//          .mmc_lite_hready (pad_dahbl_hready    ), @203
//          .mmc_lite_hresp  (pad_dahbl_hresp     ), @204
//          .lite_mmc_hsel   (dahbl_pad_htrans[1] ), @205
//          .pll_core_cpuclk (cpu_clk             ) @206
//  @207
//         ); @208
// &Force("nonport","dahbl_pad_hburst"); @211
// &Force("nonport","dahbl_pad_hprot"); @212
// &Force("bus","pad_biu_hresp","1","0"); @215
// &Force("nonport","sysio_pad_srst"); @216
// &Force("nonport","iahbl_pad_vec_redrct"); @217
// &Force("nonport","dahbl_pad_vec_redrct"); @218
// &Force("nonport","biu_pad_vec_redrct"); @219
// &Force("nonport","biu_pad_ipend_b"); @220
// &Force("nonport","sysio_pad_gcb"); @221
// &Force("nonport","biu_pad_hwdata_parity"); @222
// &Force("nonport","iahbl_pad_hwdata_parity"); @223
// &Force("nonport","dahbl_pad_hwdata_parity"); @224
// &Force("nonport","iu_pad_inst_split"); @225
// &Force("nonport","nm_top_si_1"); @226
// &Force("nonport","nm_top_si_2"); @227
// &Force("nonport","nm_top_si_3"); @228
// &Force("nonport","nm_top_si_4"); @229
// &Force("nonport","nm_top_so_1"); @230
// &Force("nonport","nm_top_so_2"); @231
// &Force("nonport","nm_top_so_3"); @232
// &Force("nonport","nm_top_so_4"); @233
// &Force("nonport","dahbl_pad_hburst"); @234
// &Force("nonport","dahbl_pad_hprot"); @235
// &Force("nonport","iahbl_pad_hburst"); @236
// &Force("nonport","iahbl_pad_hprot"); @237
// &Force("nonport", "ctim_pad_int_vld"); @238
// &Force("nonport", "pad_adu_data"); @239
// &Force("nonport", "pad_ctim_refclk"); @240
// &Force("nonport","biu_pad_dbg_b"); @241
// &Force("nonport","biu_pad_wakeup_b"); @242
// &Force("nonport","had_pad_jdb_pm"); @243
// &Force("nonport","had_pad_jtg_tap_on"); @244
// &Force("nonport","had_pad_jtg_tdo_en"); @245
// &Force("nonport","cpu_pad_dfs_ack"); @246
// &Force("nonport","sysio_pad_idlyn_b"); @247
// &Force("input","clk_en"); @248

// IAHB Lite Memory
// &Instance("iahb_mem_ctrl", "x_iahb_mem_ctrl"); @252
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

// &Connect(.lite_yy_haddr   (iahbl_pad_haddr     ), @253
//          .lite_yy_hsize   (iahbl_pad_hsize     ), @254
//          .lite_yy_htrans  (iahbl_pad_htrans    ), @255
//          .lite_yy_hwdata  (iahbl_pad_hwdata    ),  @256
//          .lite_yy_hwrite  (iahbl_pad_hwrite    ), @257
//          .mmc_lite_hrdata (pad_iahbl_hrdata    ),  @258
//          .mmc_lite_hready (pad_iahbl_hready    ), @259
//          .mmc_lite_hresp  (pad_iahbl_hresp     ),  @260
//          .lite_mmc_hsel   (iahbl_pad_htrans[1] ), @261
//          .pll_core_cpuclk (cpu_clk             ) @262
//         ); @263

// &Force("nonport","cache_data_array0_smbist_done"); @265
// &Force("nonport","cache_data_array0_smbist_fail"); @266
// &Force("nonport","cache_data_array1_smbist_done"); @267
// &Force("nonport","cache_data_array1_smbist_fail"); @268
// &Force("nonport","cache_tag_array0_smbist_done"); @269
// &Force("nonport","cache_tag_array0_smbist_fail"); @270



// &Instance("CK803_IDLITE_AHBLITE_J2_NEW","x_ck803"); @277
// &Connect(.cp0_pad_psr           (biu_pad_psr           ), @278
//          .iu_pad_inst_retire    (biu_pad_retire        ), @279
//          .iu_pad_retire_pc      (biu_pad_retire_pc     ), @280
//          .iu_pad_gpr_index      (biu_pad_wb_gpr_index  ), @281
//          .iu_pad_gpr_we         (biu_pad_wb_gpr_en     ), @282
//          .iu_pad_gpr_data       (biu_pad_wb_gpr_data   ), @283
//          .ctim_pad_int_vld      (ctim_int_vld          ), @284
//          .pad_biu_hresp         (pad_biu_hresp_0       ), @285
//          .pad_dahbl_hresp       (pad_dahbl_hresp_0     ), @286
//          .pad_iahbl_hresp       (pad_iahbl_hresp[0]    ),  @287
//          .pad_ctim_calib        (26'b0                 ), @288
//          .pad_ctim_refclk       (1'b0                  ), @289
//          .pad_vic_int_cfg       (pad_vic_int_cfg       ),   @290
//          .pad_biu_brkrq_b       (2'b11                 ) @291
//         ); @292
// &Force("inout","i_pad_jtg_tms"); @298
// &Force("output","pad_had_jtg_tms_i"); @301
// &Force("nonport", "pad_had_jtg_tdi"); @302
// &Force("nonport", "had_pad_jtg_tdo"); @303
// &Instance("dahb_mem_ctrl", "x_dahb_mem_ctrl"); @313
// &Connect(.lite_yy_haddr   (dahbl_pad_haddr     ), @314
//          .lite_yy_hsize   (dahbl_pad_hsize     ), @315
//          .lite_yy_htrans  (dahbl_pad_htrans    ), @316
//          .lite_yy_hwdata  (dahbl_pad_hwdata    ), @317
//          .lite_yy_hwrite  (dahbl_pad_hwrite    ), @318
//          .mmc_lite_hrdata (pad_dahbl_hrdata    ), @319
//          .mmc_lite_hready (pad_dahbl_hready    ), @320
//          .mmc_lite_hresp  (pad_dahbl_hresp     ), @321
//          .lite_mmc_hsel   (dahbl_pad_htrans[1] ) @322
//         ); @323
// &Force("nonport","dahbl_pad_hburst"); @325
// &Force("nonport","dahbl_pad_hprot"); @326
// &Force("bus","pad_biu_hresp","1","0"); @332
// &Force("nonport","biu_pad_gcb"); @333
// &Force("output","had_pad_jtg_tdo_en"); @334
// &Force("nonport","cpu_pad_int_ack"); @335
// &Force("nonport","iu_pad_inst_split"); @336
// &Force("nonport","ct_top_si_1"); @337
// &Force("nonport","ct_top_si_2"); @338
// &Force("nonport","ct_top_si_3"); @339
// &Force("nonport","ct_top_si_4"); @340
// &Force("nonport","ct_top_si_5"); @341
// &Force("nonport","ct_top_si_6"); @342
// &Force("nonport","ct_top_si_7"); @343
// &Force("nonport","ct_top_si_8"); @344
// &Force("nonport","ct_top_si_9"); @345
// &Force("nonport","ct_top_si_10"); @346
// &Force("nonport","ct_top_si_11"); @347
// &Force("nonport","ct_top_si_12"); @348
// &Force("nonport","ct_top_so_1"); @349
// &Force("nonport","ct_top_so_2"); @350
// &Force("nonport","ct_top_so_3"); @351
// &Force("nonport","ct_top_so_4"); @352
// &Force("nonport","ct_top_so_5"); @353
// &Force("nonport","ct_top_so_6"); @354
// &Force("nonport","ct_top_so_7"); @355
// &Force("nonport","ct_top_so_8"); @356
// &Force("nonport","ct_top_so_9"); @357
// &Force("nonport","ct_top_so_10"); @358
// &Force("nonport","ct_top_so_11"); @359
// &Force("nonport","ct_top_so_12"); @360
// &Force("nonport","biu_pad_wakeup_b"); @361
// &Force("nonport","biu_pad_idly4_b"); @362
// &Force("nonport","biu_pad_ipend_b"); @363
// &Force("nonport","had_pad_jtg_tap_on"); @364
// &Force("nonport","had_pad_jtg_tdo_en"); @365
// &Force("nonport","biu_pad_dbg_b"); @366
// &Force("nonport","had_pad_jdb_pm"); @367
// &Instance("iahb_mem_ctrl", "x_iahb_mem_ctrl"); @371
// &Connect(.lite_yy_haddr   (iahbl_pad_haddr     ), @372
//          .lite_yy_hsize   (iahbl_pad_hsize     ), @373
//          .lite_yy_htrans  (iahbl_pad_htrans    ), @374
//          .lite_yy_hwdata  (iahbl_pad_hwdata    ),  @375
//          .lite_yy_hwrite  (iahbl_pad_hwrite    ), @376
//          .mmc_lite_hrdata (pad_iahbl_hrdata    ),  @377
//          .mmc_lite_hready (pad_iahbl_hready    ), @378
//          .mmc_lite_hresp  (pad_iahbl_hresp     ),  @379
//          .lite_mmc_hsel   (iahbl_pad_htrans[1] ) @380
//         ); @381
// &Force("nonport","iahbl_pad_hburst"); @382
// &Force("nonport","iahbl_pad_hprot"); @383

// &Instance("CK803S2E_20170502","x_ck803s"); @389
// &Connect(.cp0_pad_psr                (biu_pad_psr           ), @390
//          .rtu_pad_inst_retire        (biu_pad_retire        ), @391
//          .rtu_pad_retire_pc          (biu_pad_retire_pc     ), @392
//          .rtu_pad_gpr_index          (biu_pad_wb_gpr_index  ), @393
//          .rtu_pad_gpr_we             (biu_pad_wb_gpr_en     ), @394
//          .rtu_pad_gpr_data           (biu_pad_wb_gpr_data   ), @395
//          .ctim_pad_int_vld           (ctim_int_vld          ), @396
//          .pad_ctim_calib             (26'b0                 ), @397
//          .pad_ctim_refclk            (1'b0                  ), @398
//          .pad_vic_int_cfg            (pad_vic_int_cfg       ),   @399
//          .pad_sysio_bigend_b         (pad_biu_bigend_b      ), @400
//          .pad_sysio_clkratio         (pad_biu_clkratio      ),   @401
//          .pad_sysio_gsb              (pad_biu_gsb           ), @402
//          .sysio_pad_dbg_b            (biu_pad_dbg_b         ),   @403
//          .sysio_pad_ipend_b          (biu_pad_ipend_b       ),   @404
//          .sysio_pad_lpmd_b           (biu_pad_lpmd_b        ),   @405
//          .sysio_pad_wakeup_b         (biu_pad_wakeup_b      ), @406
//          .pad_bmu_dahbl_base         (20'h20000             ), @407
//          .pad_bmu_dahbl_mask         (20'he0000             ), @408
//          .pad_bmu_iahbl_base         (20'h00000             ), @409
//          .pad_bmu_iahbl_mask         (20'he0000             ), @410
// 	 .ilite_clk_en               (1'b1                  ), @411
// 	 .pad_dahbl_hsec             (1'b0                  ), @412
// 	 .pad_iahbl_hsec             (1'b0                  ), @413
// 	 .dlite_clk_en               (1'b1                  ), @414
//          .pad_cpu_secu_dbg_en        (1'b1                  ), @415
//          .pll_core_cpuclk            (cpu_clk               ), @416
//          .pad_cpu_rst_b              (pg_reset_b            )  @417
//           ); @418
// &Force("nonport","pad_cpu_secu_dbg_en"); @422
// &Force("nonport","sysio_pad_gcb"); @425
// &Instance("dahb_mem_ctrl", "x_dahb_mem_ctrl"); @428
// &Connect(.lite_yy_haddr   (dahbl_pad_haddr     ), @429
//          .lite_yy_hsize   (dahbl_pad_hsize     ), @430
//          .lite_yy_htrans  (dahbl_pad_htrans    ), @431
//          .lite_yy_hwdata  (dahbl_pad_hwdata    ),  @432
//          .lite_yy_hwrite  (dahbl_pad_hwrite    ), @433
//          .mmc_lite_hrdata (pad_dahbl_hrdata    ),  @434
//          .mmc_lite_hready (pad_dahbl_hready    ), @435
//          .mmc_lite_hresp  (pad_dahbl_hresp     ),  @436
//          .lite_mmc_hsel   (dahbl_pad_htrans[1] ), @437
//          .pll_core_cpuclk (cpu_clk             ) @438
//         ); @439
// &Force("nonport","dahbl_pad_hburst"); @441
// &Force("nonport","dahbl_pad_hprot"); @442
// &Instance("iahb_mem_ctrl", "x_iahb_mem_ctrl"); @448
// &Connect(.lite_yy_haddr   (iahbl_pad_haddr     ), @449
//          .lite_yy_hsize   (iahbl_pad_hsize     ), @450
//          .lite_yy_htrans  (iahbl_pad_htrans    ), @451
//          .lite_yy_hwdata  (iahbl_pad_hwdata    ),  @452
//          .lite_yy_hwrite  (iahbl_pad_hwrite    ), @453
//          .mmc_lite_hrdata (pad_iahbl_hrdata    ),  @454
//          .mmc_lite_hready (pad_iahbl_hready    ), @455
//          .mmc_lite_hresp  (pad_iahbl_hresp     ),  @456
//          .lite_mmc_hsel   (iahbl_pad_htrans[1] ), @457
//          .pll_core_cpuclk (cpu_clk             ) @458
//         ); @459
// &Force("output","pad_had_jtg_tms_i"); @465
// &Force("nonport", "had_pad_jtg_tms_o"); @466
// &Force("nonport", "had_pad_jtg_tms_oe"); @467
// &Force("inout","i_pad_jtg_tms"); @470
// &Force("output","pad_had_jtg_tms_i"); @474
// &Force("nonport", "pad_had_jtg_tdi"); @475
// &Force("nonport", "had_pad_jtg_tdo"); @476
// &Force("nonport", "rtu_pad_fpr_data"); @481
// &Force("nonport", "rtu_pad_fpr_index"); @482
// &Force("nonport", "rtu_pad_fpr_we"); @483
// &Force("nonport", "rtu_pad_fesr"); @484
// &Force("nonport","rtu_pad_gpr_data_1"); @489
// &Force("nonport","rtu_pad_gpr_index_1"); @490
// &Force("nonport","rtu_pad_gpr_we_1"); @491
// &Force("nonport","pad_cpu_secu_dbg_en"); @492
// &Force("nonport","sysio_pad_srst"); @493
// &Force("nonport","iahbl_pad_hburst"); @494
// &Force("nonport","iahbl_pad_hprot"); @495
// &Force("nonport","biu_pad_ipend_b"); @496
// &Force("nonport","biu_pad_dbg_b"); @497
// &Force("nonport","biu_pad_wakeup_b"); @498
// &Force("nonport","had_pad_jdb_pm"); @499
// &Force("nonport","had_pad_jtg_tap_on"); @500
// &Force("nonport","had_pad_jtg_tdo_en"); @501
// &Force("nonport","iu_pad_mult_hi"); @502
// &Force("nonport","iu_pad_mult_lo"); @503
// &Force("nonport","iu_pad_mult_updt_hi"); @504
// &Force("nonport","iu_pad_mult_updt_lo"); @505
// &Force("nonport","rtu_pad_inst_split"); @506
// &Force("nonport","pad_sysio_dbgrq_b"); @507
// &Force("nonport","sysio_pad_idly4_b"); @508
// &Force("nonport","vg_top_si_1"); @509
// &Force("nonport","vg_top_si_2"); @510
// &Force("nonport","vg_top_si_3"); @511
// &Force("nonport","vg_top_si_4"); @512
// &Force("nonport","vg_top_so_1"); @513
// &Force("nonport","vg_top_so_2"); @514
// &Force("nonport","vg_top_so_3"); @515
// &Force("nonport","vg_top_so_4"); @516
// &Force("nonport","icache_data_array0_smbist_done"); @518
// &Force("nonport","icache_data_array0_smbist_fail"); @519
// &Force("nonport","icache_data_array1_smbist_done"); @520
// &Force("nonport","icache_data_array1_smbist_fail"); @521
// &Force("nonport","icache_tag_array_smbist_done"); @522
// &Force("nonport","icache_tag_array_smbist_fail"); @523
// &Force("nonport","icache_data_array2_smbist_done"); @524
// &Force("nonport","icache_data_array2_smbist_fail"); @525
// &Force("nonport","icache_data_array3_smbist_done"); @526
// &Force("nonport","icache_data_array3_smbist_fail"); @527

// &Instance("CK804EF_181029","x_ck804"); @532
// &Connect(.cp0_pad_psr                (biu_pad_psr           ), @533
//          .rtu_pad_inst_retire        (biu_pad_retire        ), @534
//          .rtu_pad_retire_pc          (biu_pad_retire_pc     ), @535
//          .rtu_pad_gpr_index          (biu_pad_wb_gpr_index  ), @536
//          .rtu_pad_gpr_we             (biu_pad_wb_gpr_en     ), @537
//          .rtu_pad_gpr_data           (biu_pad_wb_gpr_data   ), @538
//          .ctim_pad_int_vld           (ctim_int_vld          ), @539
//          .pad_ctim_calib             (26'b0                 ), @540
//          .pad_ctim_refclk            (1'b0                  ), @541
//          .pad_vic_int_cfg            (pad_vic_int_cfg       ),   @542
//          .pad_sysio_bigend_b         (pad_biu_bigend_b      ), @543
//          .pad_sysio_clkratio         (pad_biu_clkratio      ),   @544
//          .pad_sysio_gsb              (pad_biu_gsb           ), @545
//          .sysio_pad_dbg_b            (biu_pad_dbg_b         ),   @546
//          .sysio_pad_ipend_b          (biu_pad_ipend_b       ),   @547
//          .sysio_pad_lpmd_b           (biu_pad_lpmd_b        ),   @548
//          .sysio_pad_wakeup_b         (biu_pad_wakeup_b      ), @549
//          .pad_bmu_dahbl_base         (20'h20000             ), @550
//          .pad_bmu_dahbl_mask         (20'he0000             ), @551
//          .pad_bmu_iahbl_base         (20'h00000             ), @552
//          .pad_bmu_iahbl_mask         (20'he0000             ), @553
// 	 .ilite_clk_en               (1'b1                  ), @554
// 	 .pad_dahbl_hsec             (1'b0                  ), @555
// 	 .pad_iahbl_hsec             (1'b0                  ), @556
// 	 .dlite_clk_en               (1'b1                  ), @557
//          .pad_cpu_secu_dbg_en        (1'b1                  ), @558
//          .pll_core_cpuclk            (cpu_clk               ), @559
//          .pad_cpu_rst_b              (pg_reset_b            )  @560
//           ); @561
// &Force("nonport","pad_cpu_secu_dbg_en"); @565
// &Force("nonport","sysio_pad_gcb"); @568
// &Instance("dahb_mem_ctrl", "x_dahb_mem_ctrl"); @571
// &Connect(.lite_yy_haddr   (dahbl_pad_haddr     ), @572
//          .lite_yy_hsize   (dahbl_pad_hsize     ), @573
//          .lite_yy_htrans  (dahbl_pad_htrans    ), @574
//          .lite_yy_hwdata  (dahbl_pad_hwdata    ),  @575
//          .lite_yy_hwrite  (dahbl_pad_hwrite    ), @576
//          .mmc_lite_hrdata (pad_dahbl_hrdata    ),  @577
//          .mmc_lite_hready (pad_dahbl_hready    ), @578
//          .mmc_lite_hresp  (pad_dahbl_hresp     ),  @579
//          .lite_mmc_hsel   (dahbl_pad_htrans[1] ), @580
//          .pll_core_cpuclk (cpu_clk             ) @581
//         ); @582
// &Force("nonport","dahbl_pad_hburst"); @584
// &Force("nonport","dahbl_pad_hprot"); @585
// &Instance("iahb_mem_ctrl", "x_iahb_mem_ctrl"); @591
// &Connect(.lite_yy_haddr   (iahbl_pad_haddr     ), @592
//          .lite_yy_hsize   (iahbl_pad_hsize     ), @593
//          .lite_yy_htrans  (iahbl_pad_htrans    ), @594
//          .lite_yy_hwdata  (iahbl_pad_hwdata    ),  @595
//          .lite_yy_hwrite  (iahbl_pad_hwrite    ), @596
//          .mmc_lite_hrdata (pad_iahbl_hrdata    ),  @597
//          .mmc_lite_hready (pad_iahbl_hready    ), @598
//          .mmc_lite_hresp  (pad_iahbl_hresp     ),  @599
//          .lite_mmc_hsel   (iahbl_pad_htrans[1] ), @600
//          .pll_core_cpuclk (cpu_clk             ) @601
//         ); @602
// &Force("output","pad_had_jtg_tms_i"); @608
// &Force("nonport", "had_pad_jtg_tms_o"); @609
// &Force("nonport", "had_pad_jtg_tms_oe"); @610
// &Force("inout","i_pad_jtg_tms"); @613
// &Force("output","pad_had_jtg_tms_i"); @617
// &Force("nonport", "pad_had_jtg_tdi"); @618
// &Force("nonport", "had_pad_jtg_tdo"); @619
// &Force("nonport", "rtu_pad_fpr_data"); @624
// &Force("nonport", "rtu_pad_fpr_index"); @625
// &Force("nonport", "rtu_pad_fpr_we"); @626
// &Force("nonport", "rtu_pad_fesr"); @627
// &Force("nonport","rtu_pad_gpr_data_1"); @632
// &Force("nonport","rtu_pad_gpr_index_1"); @633
// &Force("nonport","rtu_pad_gpr_we_1"); @634
// &Force("nonport","pad_cpu_secu_dbg_en"); @635
// &Force("nonport","sysio_pad_srst"); @636
// &Force("nonport","iahbl_pad_hburst"); @637
// &Force("nonport","iahbl_pad_hprot"); @638
// &Force("nonport","biu_pad_ipend_b"); @639
// &Force("nonport","biu_pad_dbg_b"); @640
// &Force("nonport","biu_pad_wakeup_b"); @641
// &Force("nonport","had_pad_jdb_pm"); @642
// &Force("nonport","had_pad_jtg_tap_on"); @643
// &Force("nonport","had_pad_jtg_tdo_en"); @644
// &Force("nonport","iu_pad_mult_hi"); @645
// &Force("nonport","iu_pad_mult_lo"); @646
// &Force("nonport","iu_pad_mult_updt_hi"); @647
// &Force("nonport","iu_pad_mult_updt_lo"); @648
// &Force("nonport","rtu_pad_inst_split"); @649
// &Force("nonport","pad_sysio_dbgrq_b"); @650
// &Force("nonport","sysio_pad_idly4_b"); @651
// &Force("nonport","vg_top_si_1"); @652
// &Force("nonport","vg_top_si_2"); @653
// &Force("nonport","vg_top_si_3"); @654
// &Force("nonport","vg_top_si_4"); @655
// &Force("nonport","vg_top_so_1"); @656
// &Force("nonport","vg_top_so_2"); @657
// &Force("nonport","vg_top_so_3"); @658
// &Force("nonport","vg_top_so_4"); @659
// &Force("nonport","icache_data_array0_smbist_done"); @661
// &Force("nonport","icache_data_array0_smbist_fail"); @662
// &Force("nonport","icache_data_array1_smbist_done"); @663
// &Force("nonport","icache_data_array1_smbist_fail"); @664
// &Force("nonport","icache_tag_array_smbist_done"); @665
// &Force("nonport","icache_tag_array_smbist_fail"); @666
// &Force("nonport","icache_data_array2_smbist_done"); @667
// &Force("nonport","icache_data_array2_smbist_fail"); @668
// &Force("nonport","icache_data_array3_smbist_done"); @669
// &Force("nonport","icache_data_array3_smbist_fail"); @670


// &Force("input", "pmu_corec_isolation"); @675
// &Force("input", "pmu_corec_sleep_in"); @676
// &Force("output", "corec_pmu_sleep_out"); @677


// &Force("nonport","pad_had_jtag2_sel"); @680
// &Force("nonport","sysio_pad_srst"); @681
// &Force("nonport","biu_pad_retire"); @682
// &Force("nonport","biu_pad_retire_pc"); @683
// &Force("nonport","biu_pad_wb_gpr_data"); @684
// &Force("nonport","biu_pad_wb_gpr_en"); @685
// &Force("nonport","biu_pad_wb_gpr_index"); @686
// &ModuleEnd; @687
endmodule


