// *                                                                           *
// * C-Sky Microsystems Confidential                                           *
// * -------------------------------                                           *
// * This file and all its contents are properties of C-Sky Microsystems. The  *
// * information contained herein is confidential and proprietary and is not   *
// * to be disclosed outside of C-Sky Microsystems except under a              *
// * Non-Disclosure Agreement (NDA).                                           *
// *                                                                           *
// *****************************************************************************
// FILE NAME       : soc.vp
// AUTHOR          : wangjie
// ORIGINAL TIME   : 2013.05.15
// FUNCTION        : soc module instance the cpu sub system, ahb bus, memory controller
// RESET           : Async reset
// DFT             :
// DFP             :
// VERIFICATION    :
// RELEASE HISTORY :
// $Id:
// *****************************************************************************
// &Depend("cpu_cfig.h"); @21
// &Depend("soc_top_golden_port.v"); @22

// &ModuleBeg; @24
module soc(
  i_pad_clk,
  i_pad_jtg_nrst_b,
  i_pad_jtg_tclk,
  i_pad_jtg_tms,
  i_pad_jtg_trst_b,
  i_pad_rst_b
);

// &Ports("compare", "../src_rtl/soc_top_golden_port.v"); @25
input           i_pad_clk;             
input           i_pad_jtg_nrst_b;      
input           i_pad_jtg_tclk;        
input           i_pad_jtg_trst_b;      
input           i_pad_rst_b;           
    
inout           i_pad_jtg_tms;         

// &Regs; @26

// &Wires; @27   
wire    [31:0]  biu_pad_haddr;         
wire    [2 :0]  biu_pad_hburst;        
wire    [3 :0]  biu_pad_hprot;         
wire    [2 :0]  biu_pad_hsize;         
wire    [1 :0]  biu_pad_htrans;        
wire    [31:0]  biu_pad_hwdata;        
wire            biu_pad_hwrite;        
wire    [1 :0]  biu_pad_lpmd_b;        
wire    [31:0]  biu_pad_psr;           
wire            clk_en;                
wire            corec_pmu_sleep_out;   
wire            cpu_clk;               
wire            ctim_int_vld;          
wire            fifo_biu_hready;       
wire    [31:0]  fifo_pad_haddr;        
wire    [2 :0]  fifo_pad_hburst;       
wire    [3 :0]  fifo_pad_hprot;        
wire    [2 :0]  fifo_pad_hsize;        
wire    [1 :0]  fifo_pad_htrans;       
wire            fifo_pad_hwrite;       
wire    [31:0]  haddr_s1;              
wire    [31:0]  haddr_s2;              
wire    [31:0]  haddr_s3;              
wire    [31:0]  haddr_s5;              
wire    [2 :0]  hburst_s1;             
wire    [2 :0]  hburst_s3;             
wire    [2 :0]  hburst_s5;             
wire            hmastlock;             
wire    [3 :0]  hprot_s1;              
wire    [3 :0]  hprot_s3;              
wire    [3 :0]  hprot_s5;              
wire    [31:0]  hrdata_s1;             
wire    [31:0]  hrdata_s2;             
wire    [31:0]  hrdata_s3;             
wire    [31:0]  hrdata_s5;             
wire            hready_s1;             
wire            hready_s2;             
wire            hready_s3;             
wire            hready_s5;             
wire    [1 :0]  hresp_s1;              
wire    [1 :0]  hresp_s2;              
wire    [1 :0]  hresp_s3;              
wire    [1 :0]  hresp_s5;              
wire            hsel_s1;               
wire            hsel_s2;               
wire            hsel_s3;               
wire            hsel_s5;               
wire    [2 :0]  hsize_s1;              
wire    [2 :0]  hsize_s3;              
wire    [2 :0]  hsize_s5;              
wire    [1 :0]  htrans_s1;             
wire    [1 :0]  htrans_s3;             
wire    [1 :0]  htrans_s5;             
wire    [31:0]  hwdata_s1;             
wire    [31:0]  hwdata_s2;             
wire    [31:0]  hwdata_s3;             
wire    [31:0]  hwdata_s5;             
wire            hwrite_s1;             
wire            hwrite_s2;             
wire            hwrite_s3;             
wire            hwrite_s5;             
wire            i_pad_clk;             
wire            i_pad_cpu_jtg_rst_b;   
wire            i_pad_jtg_nrst_b;      
wire            i_pad_jtg_tclk;        
wire            i_pad_jtg_tms;         
wire            i_pad_jtg_trst_b;      
wire            i_pad_rst_b;              
wire    [31:0]  pad_biu_hrdata;        
wire            pad_biu_hready;        
wire    [1 :0]  pad_biu_hresp;         
wire            pad_cpu_rst_b;         
wire            pad_had_jtg_tclk;      
wire            pad_had_jtg_tms_i;     
wire            pad_had_jtg_trst_b;    
wire            pad_had_jtg_trst_b_pre; 
wire    [31:0]  pad_vic_int_cfg;       
wire    [31:0]  pad_vic_int_vld;       
wire            per_clk;               
wire            pg_reset_b;            
wire            pmu_corec_isolation;   
wire            pmu_corec_sleep_in;    
wire            smpu_deny;             


//***********************Instance cpu_sub_system_ahb****************************
// &Instance("cpu_sub_system_ahb", "x_cpu_sub_system_ahb"); @31
// &Connect( @32
//          .clk_en                 (clk_en              )    @33
//          ); @34
// Support AHB_LITE
// &Instance("cpu_sub_system_ahb", "x_cpu_sub_system_ahb"); @38
cpu_sub_system_ahb  x_cpu_sub_system_ahb (
  .biu_pad_haddr        (biu_pad_haddr       ),
  .biu_pad_hburst       (biu_pad_hburst      ),
  .biu_pad_hprot        (biu_pad_hprot       ),
  .biu_pad_hsize        (biu_pad_hsize       ),
  .biu_pad_htrans       (biu_pad_htrans      ),
  .biu_pad_hwdata       (biu_pad_hwdata      ),
  .biu_pad_hwrite       (biu_pad_hwrite      ),
  .biu_pad_lpmd_b       (biu_pad_lpmd_b      ),
  .biu_pad_psr          (biu_pad_psr         ),
  .clk_en               (clk_en              ),
  .corec_pmu_sleep_out  (corec_pmu_sleep_out ),
  .cpu_clk              (cpu_clk             ),
  .ctim_int_vld         (ctim_int_vld        ),
  .i_pad_jtg_tms        (i_pad_jtg_tms       ),
  .pad_biu_bigend_b     (1'b1                ),
  .pad_biu_hrdata       (pad_biu_hrdata      ),
  .pad_biu_hready       (fifo_biu_hready     ),
  .pad_biu_hresp        (pad_biu_hresp       ),
  .pad_cpu_rst_b        (pad_cpu_rst_b       ),
  .pad_had_jtg_tclk     (pad_had_jtg_tclk    ),
  .pad_had_jtg_tms_i    (pad_had_jtg_tms_i   ),
  .pad_had_jtg_trst_b   (pad_had_jtg_trst_b  ),
  .pad_vic_int_cfg      (pad_vic_int_cfg     ),
  .pad_vic_int_vld      (pad_vic_int_vld     ),
  .pad_yy_gate_clk_en_b (1'b0                ),
  .pad_yy_test_mode     (1'b0                ),
  .pg_reset_b           (pg_reset_b          ),
  .pmu_corec_isolation  (pmu_corec_isolation ),
  .pmu_corec_sleep_in   (pmu_corec_sleep_in  )
);

// &Connect(.clk_en                  (clk_en             ), @40
//          .pad_yy_gate_clk_en_b    (1'b0               ), @41
//          .pad_yy_bist_tst_en      (1'b0               ), @42
//          .pad_yy_scan_enable      (1'b0               ), @43
//          .pad_yy_test_mode        (1'b0               ), @44
//          .pad_biu_bigend_b        (1'b1               ), @45
//          .pad_biu_int_b           (1'b1               ), @46
//          .pad_biu_fint_b          (1'b1               ), @47
//          .pad_biu_fintraw_b       (1'b1               ), @48
//          .pad_biu_avec_b          (1'b0               ), @49
//          .pad_biu_vec_b           (8'b0               ), @50
//          .pad_biu_gsb             (32'b0              ), @51
//          //add for debug @52
//          .pad_biu_dbgrq_b         (1'b1               ),  @53
//          .pad_had_jtg_tap_en      (1'b1               ), @54
//          .pad_biu_clkratio        (3'b0               ), @55
//          .pad_biu_hready          (fifo_biu_hready    ) @56
//         ); @57

//assign i_pad_cpu_jtg_rst_b = i_pad_rst_b & i_pad_jtg_trst_b;
assign i_pad_cpu_jtg_rst_b = i_pad_rst_b & i_pad_jtg_nrst_b;

//assign pad_cpu_rst_b = i_pad_rst_b;
assign pad_cpu_rst_b = i_pad_cpu_jtg_rst_b;
//assign pll_core_cpuclk = cpu_clk;
assign pad_had_jtg_tclk = i_pad_jtg_tclk;
assign pad_had_jtg_trst_b_pre = i_pad_jtg_trst_b;
//assign pad_had_jtg_trst_b_pre = i_pad_cpu_jtg_rst_b;
// //&Force("inout","i_pad_jtg_tms"); @77
//assign pad_had_jtg_tms = i_pad_jtg_tms;
//assign i_pad_jtg_tms = had_pad_jtg_tms_oe ? pad_had_jtg_tms : 1'bz;
// //&Force("nonport","pad_had_jtg_tms"); @80
// &Force("nonport","had_pad_jdb_ack_b"); @82
//***********************Instance ahb delay simulator ***********************
// &Instance("ahb_fifo", "x_ahb_fifo"); @84
ahb_fifo  x_ahb_fifo (
  .biu_pad_haddr   (biu_pad_haddr  ),
  .biu_pad_hburst  (biu_pad_hburst ),
  .biu_pad_hprot   (biu_pad_hprot  ),
  .biu_pad_hsize   (biu_pad_hsize  ),
  .biu_pad_htrans  (biu_pad_htrans ),
  .biu_pad_hwrite  (biu_pad_hwrite ),
  .counter_num0    (32'h1          ),
  .cpu_clk         (per_clk        ),
  .cpu_rst_b       (pg_reset_b     ),
  .fifo_biu_hready (fifo_biu_hready),
  .fifo_pad_haddr  (fifo_pad_haddr ),
  .fifo_pad_hburst (fifo_pad_hburst),
  .fifo_pad_hprot  (fifo_pad_hprot ),
  .fifo_pad_hsize  (fifo_pad_hsize ),
  .fifo_pad_htrans (fifo_pad_htrans),
  .fifo_pad_hwrite (fifo_pad_hwrite),
  .pad_biu_hready  (pad_biu_hready )
);

// &Connect( @85
//          .cpu_clk                 (per_clk            ), @86
//          .cpu_rst_b               (pg_reset_b         ), @87
//          .counter_num0            (32'h1              ) @88
//          ); @89

//***********************Instance ahb bus arbiter****************************
// &Instance("ahb", "x_ahb"); @92
ahb  x_ahb (
  .biu_pad_haddr   (fifo_pad_haddr ),
  .biu_pad_hburst  (fifo_pad_hburst),
  .biu_pad_hprot   (fifo_pad_hprot ),
  .biu_pad_hsize   (fifo_pad_hsize ),
  .biu_pad_htrans  (fifo_pad_htrans),
  .biu_pad_hwdata  (biu_pad_hwdata ),
  .biu_pad_hwrite  (fifo_pad_hwrite),
  .haddr_s1        (haddr_s1       ),
  .haddr_s2        (haddr_s2       ),
  .haddr_s3        (haddr_s3       ),
  .haddr_s5        (haddr_s5       ),
  .hburst_s1       (hburst_s1      ),
  .hburst_s3       (hburst_s3      ),
  .hburst_s5       (hburst_s5      ),
  .hmastlock       (hmastlock      ),
  .hprot_s1        (hprot_s1       ),
  .hprot_s3        (hprot_s3       ),
  .hprot_s5        (hprot_s5       ),
  .hrdata_s1       (hrdata_s1      ),
  .hrdata_s2       (hrdata_s2      ),
  .hrdata_s3       (hrdata_s3      ),
  .hrdata_s5       (hrdata_s5      ),
  .hready_s1       (hready_s1      ),
  .hready_s2       (hready_s2      ),
  .hready_s3       (hready_s3      ),
  .hready_s5       (hready_s5      ),
  .hresp_s1        (hresp_s1       ),
  .hresp_s2        (hresp_s2       ),
  .hresp_s3        (hresp_s3       ),
  .hresp_s5        (hresp_s5       ),
  .hsel_s1         (hsel_s1        ),
  .hsel_s2         (hsel_s2        ),
  .hsel_s3         (hsel_s3        ),
  .hsel_s5         (hsel_s5        ),
  .hsize_s1        (hsize_s1       ),
  .hsize_s3        (hsize_s3       ),
  .hsize_s5        (hsize_s5       ),
  .htrans_s1       (htrans_s1      ),
  .htrans_s3       (htrans_s3      ),
  .htrans_s5       (htrans_s5      ),
  .hwdata_s1       (hwdata_s1      ),
  .hwdata_s2       (hwdata_s2      ),
  .hwdata_s3       (hwdata_s3      ),
  .hwdata_s5       (hwdata_s5      ),
  .hwrite_s1       (hwrite_s1      ),
  .hwrite_s2       (hwrite_s2      ),
  .hwrite_s3       (hwrite_s3      ),
  .hwrite_s5       (hwrite_s5      ),
  .pad_biu_hrdata  (pad_biu_hrdata ),
  .pad_biu_hready  (pad_biu_hready ),
  .pad_biu_hresp   (pad_biu_hresp  ),
  .pad_cpu_rst_b   (pg_reset_b     ),
  .pll_core_cpuclk (per_clk        ),
  .smpu_deny       (smpu_deny      )
);

// &Connect( @93
//          .pll_core_cpuclk         (per_clk            ), @94
//          .pad_cpu_rst_b           (pg_reset_b         ), @95
//          .biu_pad_hbusreq         (fifo_pad_hreq      ), @96
//          .biu_pad_haddr           (fifo_pad_haddr     ), @97
//          .biu_pad_hburst          (fifo_pad_hburst    ), @98
//          .biu_pad_hlock           (fifo_pad_hlock     ), @99
//          .biu_pad_hprot           (fifo_pad_hprot     ), @100
//          .biu_pad_hsize           (fifo_pad_hsize     ), @101
//          .biu_pad_htrans          (fifo_pad_htrans    ),     @102
//          .biu_pad_hwrite          (fifo_pad_hwrite    )   @103
//          ); @104

//***********************Instance ahb slave 1    ****************************

// &Instance("mem_ctrl", "x_smem_ctrl"); @108
mem_ctrl  x_smem_ctrl (
  .haddr_s1        (haddr_s1       ),
  .hburst_s1       (hburst_s1      ),
  .hprot_s1        (hprot_s1       ),
  .hrdata_s1       (hrdata_s1      ),
  .hready_s1       (hready_s1      ),
  .hresp_s1        (hresp_s1       ),
  .hsel_s1         (hsel_s1        ),
  .hsize_s1        (hsize_s1       ),
  .htrans_s1       (htrans_s1      ),
  .hwdata_s1       (hwdata_s1      ),
  .hwrite_s1       (hwrite_s1      ),
  .pad_cpu_rst_b   (pad_cpu_rst_b  ),
  .pll_core_cpuclk (per_clk        )
);

// &Connect( @109
//          .pll_core_cpuclk         (per_clk            ) @110
//          ); @111

//***********************Instance ahb slave 2    ****************************

// &Instance("apb", "x_apb"); @115
apb  x_apb (

  .biu_pad_lpmd_b         (biu_pad_lpmd_b        ),
  .biu_pad_psr            (biu_pad_psr           ),
  .clk_en                 (clk_en                ),
  .corec_pmu_sleep_out    (corec_pmu_sleep_out   ),
  .cpu_clk                (cpu_clk               ),
  .ctim_int_vld           (ctim_int_vld          ),
  .fifo_pad_haddr         (fifo_pad_haddr        ),
  .fifo_pad_hprot         (fifo_pad_hprot        ),
  .haddr_s2               (haddr_s2              ),
  .hrdata_s2              (hrdata_s2             ),
  .hready_s2              (hready_s2             ),
  .hresp_s2               (hresp_s2              ),
  .hsel_s2                (hsel_s2               ),
  .hwdata_s2              (hwdata_s2             ),
  .hwrite_s2              (hwrite_s2             ),
  .i_pad_cpu_jtg_rst_b    (i_pad_cpu_jtg_rst_b   ),
  .i_pad_jtg_tclk         (i_pad_jtg_tclk        ),
  .pad_clk                (i_pad_clk             ),
  .pad_cpu_rst_b          (pad_cpu_rst_b         ),
  .pad_had_jtg_tap_en     (1'b1                  ),
  .pad_had_jtg_tms_i      (pad_had_jtg_tms_i     ),
  .pad_had_jtg_trst_b     (pad_had_jtg_trst_b    ),
  .pad_had_jtg_trst_b_pre (pad_had_jtg_trst_b_pre),
  .pad_vic_int_cfg        (pad_vic_int_cfg       ),
  .pad_vic_int_vld        (pad_vic_int_vld       ),
  .per_clk                (per_clk               ),
  .pg_reset_b             (pg_reset_b            ),
  .pmu_corec_isolation    (pmu_corec_isolation   ),
  .pmu_corec_sleep_in     (pmu_corec_sleep_in    ),
  .smpu_deny              (smpu_deny             )
);

// &Connect(.pad_clk                 (i_pad_clk          ), @116
//          .uart0_sin               (i_pad_uart0_sin    ), @117
//          .uart0_sout              (o_pad_uart0_sout   ), @118
// 	 .gpio_ext_porta          (i_pad_gpio_porta   ), @119
// 	 .gpio_ext_portb          (i_pad_gpio_portb   ), @120
//          .gpio_porta_dr           (o_pad_gpio_porta   ), @121
// 	 .gpio_portb_dr           (o_pad_gpio_portb   ), @122
// 	 .gpio_portb_dr           (o_pad_gpio_portb   ), @123
//          .pad_had_jtg_tap_en      (1'b1               ) @124
//           @125
//  @126
//          ); @127
//***********************Instance ahb slave 3    ****************************

// &Instance("err_gen", "x_err_gen"); @130
err_gen  x_err_gen (
  .haddr_s3        (haddr_s3       ),
  .hburst_s3       (hburst_s3      ),
  .hmastlock       (hmastlock      ),
  .hprot_s3        (hprot_s3       ),
  .hrdata_s3       (hrdata_s3      ),
  .hready_s3       (hready_s3      ),
  .hresp_s3        (hresp_s3       ),
  .hsel_s3         (hsel_s3        ),
  .hsize_s3        (hsize_s3       ),
  .htrans_s3       (htrans_s3      ),
  .hwdata_s3       (hwdata_s3      ),
  .hwrite_s3       (hwrite_s3      ),
  .pad_cpu_rst_b   (pg_reset_b     ),
  .pll_core_cpuclk (per_clk        )
);

// &Connect ( @131
//          .pll_core_cpuclk        (per_clk             ), @132
//          .pad_cpu_rst_b          (pg_reset_b          ) @133
//          );  @134

//***********************Instance ahb slave 4    ****************************
// &Instance("mem_ctrl", "x_imem_ctrl"); @139
// &Connect( @140
//            .haddr_s1               (haddr_s4          ), @141
//            .hburst_s1              (hburst_s4         ), @142
//            .hprot_s1               (hprot_s4          ),  @143
//            .hrdata_s1              (hrdata_s4         ),      @144
//            .hready_s1              (hready_s4         ), @145
//            .hresp_s1               (hresp_s4          ), @146
//            .hsel_s1                (hsel_s4           ), @147
//            .hsize_s1               (hsize_s4          ), @148
//            .htrans_s1              (htrans_s4         ), @149
//            .hwdata_s1              (hwdata_s4         ), @150
//            .hwrite_s1              (hwrite_s4         ), @151
//            .pll_core_cpuclk        (per_clk           ) @152
//          ); @153

//***********************Instance ahb slave 5    ****************************
// &Instance("mem_ctrl", "x_dmem_ctrl"); @159
mem_ctrl  x_dmem_ctrl (
  .haddr_s1        (haddr_s5       ),
  .hburst_s1       (hburst_s5      ),
  .hprot_s1        (hprot_s5       ),
  .hrdata_s1       (hrdata_s5      ),
  .hready_s1       (hready_s5      ),
  .hresp_s1        (hresp_s5       ),
  .hsel_s1         (hsel_s5        ),
  .hsize_s1        (hsize_s5       ),
  .htrans_s1       (htrans_s5      ),
  .hwdata_s1       (hwdata_s5      ),
  .hwrite_s1       (hwrite_s5      ),
  .pad_cpu_rst_b   (pad_cpu_rst_b  ),
  .pll_core_cpuclk (per_clk        )
);

// &Connect( @160
//            .haddr_s1               (haddr_s5         ), @161
//            .hburst_s1              (hburst_s5        ), @162
//            .hprot_s1               (hprot_s5         ),  @163
//            .hrdata_s1              (hrdata_s5        ),      @164
//            .hready_s1              (hready_s5        ), @165
//            .hresp_s1               (hresp_s5         ), @166
//            .hsel_s1                (hsel_s5          ), @167
//            .hsize_s1               (hsize_s5         ), @168
//            .htrans_s1              (htrans_s5        ), @169
//            .hwdata_s1              (hwdata_s5        ), @170
//            .hwrite_s1              (hwrite_s5        ), @171
//            .pll_core_cpuclk        (per_clk          ) @172
//          ); @173

// &Force("nonport","pad_dahbl_hsec"); @176
// &Force("nonport","pad_iahbl_hsec"); @177
// &ModuleEnd; @178
endmodule


