// * This file and all its contents are properties of C-Sky Microsystems. The  *
// * information contained herein is confidential and proprietary and is not   *
// * to be disclosed outside of C-Sky Microsystems except under a              *
// * Non-Disclosure Agreement (NDA).                                           *
// *                                                                           *
// *****************************************************************************
// FILE NAME       : apb.vp
// AUTHOR          : 
// ORIGINAL TIME   : 
// FUNCTION        : instaniate IP on APB bus
//                 :   
//                 :   
// RESET           : Async reset
// DFT             :
// DFP             :
// VERIFICATION    :
// RELEASE HISTORY :
// *****************************************************************************
// &Depend("environment.h"); @19
// &ModuleBeg; @20
module apb(
  b_pad_gpio_porta,
  biu_pad_lpmd_b,
  biu_pad_psr,
  clk_en,
  corec_pmu_sleep_out,
  cpu_clk,
  ctim_int_vld,
  fifo_pad_haddr,
  fifo_pad_hprot,
  had_pad_wakeup_req_b,
  haddr_s2,
  hrdata_s2,
  hready_s2,
  hresp_s2,
  hsel_s2,
  hwdata_s2,
  hwrite_s2,
  i_pad_cpu_jtg_rst_b,
  i_pad_jtg_tclk,
  pad_clk,
  pad_cpu_rst_b,
  pad_had_jdb_req_b,
  pad_had_jtg_tap_en,
  pad_had_jtg_tms_i,
  pad_had_jtg_trst_b,
  pad_had_jtg_trst_b_pre,
  pad_vic_int_cfg,
  pad_vic_int_vld,
  per_clk,
  pg_reset_b,
  pmu_corec_isolation,
  pmu_corec_sleep_in,
  smpu_deny,
  uart0_sin,
  uart0_sout
);

// &Ports; @21
input   [1 :0]  biu_pad_lpmd_b;        
input   [31:0]  biu_pad_psr;           
input           corec_pmu_sleep_out;   
input           ctim_int_vld;          
input   [31:0]  fifo_pad_haddr;        
input   [3 :0]  fifo_pad_hprot;        
input           had_pad_wakeup_req_b;  
input   [31:0]  haddr_s2;              
input           hsel_s2;               
input   [31:0]  hwdata_s2;             
input           hwrite_s2;             
input           i_pad_cpu_jtg_rst_b;   
input           i_pad_jtg_tclk;        
input           pad_clk;               
input           pad_cpu_rst_b;         
input           pad_had_jtg_tap_en;    
input           pad_had_jtg_tms_i;     
input           pad_had_jtg_trst_b_pre; 
input           uart0_sin;             
output          clk_en;                
output          cpu_clk;               
output  [31:0]  hrdata_s2;             
output          hready_s2;             
output  [1 :0]  hresp_s2;              
output          pad_had_jdb_req_b;     
output          pad_had_jtg_trst_b;    
output  [31:0]  pad_vic_int_cfg;       
output  [31:0]  pad_vic_int_vld;       
output          per_clk;               
output          pg_reset_b;            
output          pmu_corec_isolation;   
output          pmu_corec_sleep_in;    
output          smpu_deny;             
output          uart0_sout;            
inout   [7 :0]  b_pad_gpio_porta;      

// &Regs; @22

// &Wires; @23
wire            apb_clkgen_psel;       
wire            apb_gpio_psel;         
wire            apb_pmu_psel;          
wire            apb_smpu_psel;         
wire            apb_stim_psel;         
wire            apb_tim_psel;          
wire            apb_uart_psel;         
wire            apb_spi_slave_psel;    
wire            apb_spi_master_psel;  
wire            apb_usi_psel; 
wire    [31:0]  apb_xx_paddr;          
wire            apb_xx_penable;        
wire    [31:0]  apb_xx_pwdata;         
wire            apb_xx_pwrite;         
wire    [7 :0]  b_pad_gpio_porta;      
wire    [1 :0]  biu_pad_lpmd_b;        
wire    [31:0]  biu_pad_psr;           
wire            clk_en;                
wire    [31:0]  clkgen_apb_prdata;     
wire            corec_pmu_sleep_out;   
wire            cpu_clk;               
wire            ctim_int_vld;          
wire    [31:0]  fifo_pad_haddr;        
wire    [3 :0]  fifo_pad_hprot;        
wire            gate_en0;              
wire            gate_en1;              
wire    [31:0]  gpio_apb_prdata;       
wire    [7 :0]  gpio_vic_int;          
wire            had_pad_wakeup_req_b;  
wire    [31:0]  haddr_s2;              
wire    [31:0]  hrdata_s2;             
wire            hready_s2;             
wire    [1 :0]  hresp_s2;              
wire            hsel_s2;               
wire    [31:0]  hwdata_s2;             
wire            hwrite_s2;             
wire            i_pad_cpu_jtg_rst_b;   
wire            i_pad_jtg_tclk;        
wire            intraw_vld;            
wire            pad_clk;               
wire            pad_cpu_rst_b;         
wire            pad_had_jdb_req_b;     
wire            pad_had_jtg_tap_en;    
wire            pad_had_jtg_tms_i;     
wire            pad_had_jtg_trst_b;    
wire            pad_had_jtg_trst_b_pre;
wire    [31:0]  pad_vic_int_cfg;       
wire    [31:0]  pad_vic_int_vld;       
wire            per_clk;               
wire            pg_reset_b;            
wire    [31:0]  pmu_apb_prdata;        
wire            pmu_clk;               
wire            pmu_corec_isolation;   
wire            pmu_corec_sleep_in;    
wire    [31:0]  smpu_apb_prdata;       
wire            smpu_deny;             
wire    [31:0]  stim_apb_prdata;       
wire    [3 :0]  stim_vic_int;          
wire    [31:0]  tim_apb_prdata;        
wire    [3 :0]  tim_vic_int;           
wire            uart0_sin;             
wire            uart0_sout;            
wire            uart0_vic_int;         
wire    [31:0]  uart_apb_prdata;       
wire            wic_clk;               
wire    [31:0]  spi_slave_apb_prdata;  
wire    [31:0]  spi_master_apb_prdata; 
wire            spi_slave_vic_int;
wire            usi_vic_int;
wire    [31:0]  usi_apb_prdata;  

// &Instance("apb_bridge", "x_apb_bridge"); @26
apb_bridge  x_apb_bridge (
  .apb_harb_hrdata   (hrdata_s2        ),
  .apb_harb_hready   (hready_s2        ),
  .apb_harb_hresp    (hresp_s2         ),
  .apb_xx_paddr      (apb_xx_paddr     ),
  .apb_xx_penable    (apb_xx_penable   ),
  .apb_xx_pwdata     (apb_xx_pwdata    ),
  .apb_xx_pwrite     (apb_xx_pwrite    ),
  .harb_apb_hsel     (hsel_s2          ),
  .harb_xx_haddr     (haddr_s2         ),
  .harb_xx_hwdata    (hwdata_s2        ),
  .harb_xx_hwrite    (hwrite_s2        ),
  .hclk              (per_clk          ),
  .hrst_b            (pg_reset_b       ),
  .prdata_s1         (uart_apb_prdata  ),
  .prdata_s2         (tim_apb_prdata   ),
  .prdata_s3         (pmu_apb_prdata   ),
  .prdata_s4         (gpio_apb_prdata  ),
  .prdata_s5         (stim_apb_prdata  ),
  .prdata_s6         (clkgen_apb_prdata),
  .prdata_s7         (smpu_apb_prdata  ),
  .prdata_s8         (spi_slave_apb_prdata  ),
  .prdata_s9         (spi_master_apb_prdata  ),
  .prdata_sA         (usi_apb_prdata  ),
  
  .psel_s1           (apb_uart_psel    ),
  .psel_s2           (apb_tim_psel     ),
  .psel_s3           (apb_pmu_psel     ),
  .psel_s4           (apb_gpio_psel    ),
  .psel_s5           (apb_stim_psel    ),
  .psel_s6           (apb_clkgen_psel  ),
  .psel_s7           (apb_smpu_psel    ),
  .psel_s8           (apb_spi_slave_psel    ),
  .psel_s9           (apb_spi_master_psel    ),
  .psel_sA           (apb_usi_psel    )
);

// &Connect( @27
//   .hclk                   (per_clk), @28
//   .hrst_b                 (pg_reset_b), @29
//   .harb_apb_hsel          (hsel_s2), @30
//   .harb_xx_haddr          (haddr_s2), @31
//   .harb_xx_hwdata         (hwdata_s2), @32
//   .harb_xx_hwrite         (hwrite_s2), @33
//   .apb_harb_hrdata        (hrdata_s2), @34
//   .apb_harb_hready        (hready_s2), @35
//   .apb_harb_hresp         (hresp_s2), @36
//   .apb_xx_paddr           (apb_xx_paddr), @37
//   .apb_xx_penable         (apb_xx_penable), @38
//   .apb_xx_pwdata          (apb_xx_pwdata), @39
//   .apb_xx_pwrite          (apb_xx_pwrite), @40
//   .prdata_s1              (uart_apb_prdata), @41
//   .prdata_s2              (tim_apb_prdata), @42
//   .prdata_s3              (pmu_apb_prdata), @43
//   .prdata_s4              (gpio_apb_prdata), @44
//   .prdata_s5              (stim_apb_prdata), @45
//   .prdata_s6              (clkgen_apb_prdata), @46
//   .prdata_s7              (smpu_apb_prdata), @47
//   .psel_s1                (apb_uart_psel), @48
//   .psel_s2                (apb_tim_psel), @49
//   .psel_s3                (apb_pmu_psel), @50
//   .psel_s4                (apb_gpio_psel), @51
//   .psel_s5                (apb_stim_psel), @52
//   .psel_s6                (apb_clkgen_psel) @53
//   .psel_s7                (apb_smpu_psel) @54
// ); @55

// &Instance("pmu", "x_pmu"); @57
pmu  x_pmu (
  .apb_pmu_paddr          (apb_xx_paddr[11:0]    ),
  .apb_pmu_penable        (apb_xx_penable        ),
  .apb_pmu_psel           (apb_pmu_psel          ),
  .apb_pmu_pwdata         (apb_xx_pwdata         ),
  .apb_pmu_pwrite         (apb_xx_pwrite         ),
  .biu_pad_lpmd_b         (biu_pad_lpmd_b        ),
  .corec_pmu_sleep_out    (corec_pmu_sleep_out   ),
  .cpu_clk                (cpu_clk               ),
  .gate_en0               (gate_en0              ),
  .gate_en1               (gate_en1              ),
  .had_pad_wakeup_req_b   (had_pad_wakeup_req_b  ),
  .i_pad_cpu_jtg_rst_b    (i_pad_cpu_jtg_rst_b   ),
  .i_pad_jtg_tclk         (i_pad_jtg_tclk        ),
  .intraw_vld             (intraw_vld            ),
  .pad_cpu_rst_b          (pad_cpu_rst_b         ),
  .pad_had_jdb_req_b      (pad_had_jdb_req_b     ),
  .pad_had_jtg_tap_en     (pad_had_jtg_tap_en    ),
  .pad_had_jtg_tms_i      (pad_had_jtg_tms_i     ),
  .pad_had_jtg_trst_b     (pad_had_jtg_trst_b    ),
  .pad_had_jtg_trst_b_pre (pad_had_jtg_trst_b_pre),
  .pg_reset_b             (pg_reset_b            ),
  .pmu_apb_prdata         (pmu_apb_prdata        ),
  .pmu_clk                (pmu_clk               ),
  .pmu_corec_isolation    (pmu_corec_isolation   ),
  .pmu_corec_sleep_in     (pmu_corec_sleep_in    )
);

// &Connect( @58
//   .apb_pmu_psel          (apb_pmu_psel), @59
//   .apb_pmu_paddr         (apb_xx_paddr[11:0]), @60
//   .apb_pmu_penable       (apb_xx_penable), @61
//   .apb_pmu_pwdata        (apb_xx_pwdata), @62
//   .apb_pmu_pwrite        (apb_xx_pwrite), @63
//   .pad_cpu_rst_b         (pad_cpu_rst_b), @64
//   .pmu_apb_prdata        (pmu_apb_prdata), @65
//   .intraw_b              (wic_vic_intraw_b), @66
//   .had_pad_wakeup_req_b  (had_pad_wakeup_req_b) @67
// //  .ctl_xx_awake_enable   (32'hffffffff), @68
// //  .pulse_int             (1'b0) @69
//  // .pad_vic_event_vld     (1'b0) @70
// ); @71


// &Instance("uart", "x_uart"); @74
uart  x_uart (
  .apb_uart_paddr   (apb_xx_paddr    ),
  .apb_uart_penable (apb_xx_penable  ),
  .apb_uart_psel    (apb_uart_psel   ),
  .apb_uart_pwdata  (apb_xx_pwdata   ),
  .apb_uart_pwrite  (apb_xx_pwrite   ),
  .rst_b            (pad_cpu_rst_b   ),
  .s_in             (uart0_sin       ),
  .s_out            (uart0_sout      ),
  .sys_clk          (pmu_clk         ),
  .uart_apb_prdata  (uart_apb_prdata ),
  .uart_vic_int     (uart0_vic_int   )
);

// &Connect( @75
//   .sys_clk                (pmu_clk), @76
//   .apb_uart_psel          (apb_uart_psel), @77
//   .apb_uart_paddr         (apb_xx_paddr), @78
//   .apb_uart_penable       (apb_xx_penable), @79
//   .apb_uart_pwdata        (apb_xx_pwdata), @80
//   .apb_uart_pwrite        (apb_xx_pwrite), @81
//   .rst_b                  (pad_cpu_rst_b), @82
//   .uart_apb_prdata        (uart_apb_prdata), @83
//   .uart_vic_int           (uart0_vic_int), @84
//   .s_in                   (uart0_sin), @85
//   .s_out                  (uart0_sout) @86
// ); @87

// &Instance("timer", "x_timer"); @89
timer  x_timer (
  .paddr              (apb_xx_paddr[15:0]),
  .pclk               (pmu_clk           ),
  .penable            (apb_xx_penable    ),
  .prdata             (tim_apb_prdata    ),
  .presetn            (pad_cpu_rst_b     ),
  .psel               (apb_tim_psel      ),
  .pwdata             (apb_xx_pwdata     ),
  .pwrite             (apb_xx_pwrite     ),
  .timer_int          (tim_vic_int       )
);

// &Connect( @90
//   .presetn                (pad_cpu_rst_b), @91
//   .prdata                 (tim_apb_prdata), @92
//   .timer_int              (tim_vic_int), @93
//   .pclk                   (pmu_clk), @94
//   .penable                (apb_xx_penable), @95
//   .paddr                  (apb_xx_paddr[15:0]), @96
//   .psel                   (apb_tim_psel), @97
//   .pwdata                 (apb_xx_pwdata), @98
//   .pwrite                 (apb_xx_pwrite) @99
// ); @100

// &Instance("timer", "x_stimer"); @102
timer  x_stimer (
  .paddr              (apb_xx_paddr[15:0]),
  .pclk               (pmu_clk           ),
  .penable            (apb_xx_penable    ),
  .prdata             (stim_apb_prdata   ),
  .presetn            (pad_cpu_rst_b     ),
  .psel               (apb_stim_psel     ),
  .pwdata             (apb_xx_pwdata     ),
  .pwrite             (apb_xx_pwrite     ),
  .timer_int          (stim_vic_int      )
);

// &Connect( @103
//   .presetn                (pad_cpu_rst_b), @104
//   .prdata                 (stim_apb_prdata), @105
//   .timer_int              (stim_vic_int), @106
//   .pclk                   (pmu_clk), @107
//   .penable                (apb_xx_penable), @108
//   .paddr                  (apb_xx_paddr[15:0]), @109
//   .psel                   (apb_stim_psel), @110
//   .pwdata                 (apb_xx_pwdata), @111
//   .pwrite                 (apb_xx_pwrite) @112
// ); @113


// &Instance("fpga_clk_gen", "x_fpga_clk_gen"); @117
fpga_clk_gen  x_fpga_clk_gen (
  .clk_en             (clk_en            ),
  .clkrst_b           (pad_cpu_rst_b     ),
  .cpu_clk            (cpu_clk           ),
  .gate_en0           (gate_en0          ),
  .gate_en1           (gate_en1          ),
  .pad_clk            (pad_clk           ),
  .penable            (apb_xx_penable    ),
  .per_clk            (per_clk           ),
  .pmu_clk            (pmu_clk           ),
  .prdata             (clkgen_apb_prdata ),
  .psel               (apb_clkgen_psel   ),
  .pwdata             (apb_xx_pwdata[2:0]),
  .pwrite             (apb_xx_pwrite     ),
  .wic_clk            (wic_clk           )
);

// &Connect( @118
//   .penable               (apb_xx_penable    ), @119
//   .psel                  (apb_clkgen_psel   ), @120
//   .prdata                (clkgen_apb_prdata ), @121
//   .pwdata                (apb_xx_pwdata[2:0]), @122
//   .pwrite                (apb_xx_pwrite     ), @123
//   .clkrst_b              (pad_cpu_rst_b     ) @124
// ); @125
// &Instance("clk_aligner", "x_clk_aligner"); @127
// &Connect( @128
//   .forever_cpuclk          (pad_clk           ), @129
//   .penable                 (apb_xx_penable    ), @130
//   .paddr                   (apb_xx_paddr[11:0]), @131
//   .psel                    (apb_clkgen_psel   ), @132
//   .prdata                  (clkgen_apb_prdata ), @133
//   .pwdata                  (apb_xx_pwdata[2:0]), @134
//   .pwrite                  (apb_xx_pwrite     ), @135
//   .clkrst_b                (pad_cpu_rst_b     ) @136
// ); @137
// &Instance("clk_divider", "x_clk_divider"); @139
// &Connect( @140
//   .osc_clk                 (pad_clk) @141
// ); @142



// &Instance("gpio", "x_gpio"); @147
gpio  x_gpio (
  .b_pad_gpio_porta  (b_pad_gpio_porta ),
  .gpio_intr         (gpio_vic_int     ),
  .paddr             (apb_xx_paddr[6:2]),
  .pclk              (pmu_clk          ),
  .pclk_intr         (pmu_clk          ),
  .penable           (apb_xx_penable   ),
  .prdata            (gpio_apb_prdata  ),
  .presetn           (pad_cpu_rst_b    ),
  .psel              (apb_gpio_psel    ),
  .pwdata            (apb_xx_pwdata    ),
  .pwrite            (apb_xx_pwrite    )
);

// &Connect( @148
//   .paddr                  (apb_xx_paddr[6:2]), @149
//   .pclk                   (pmu_clk), @150
//   .pclk_intr              (pmu_clk), @151
//   .penable                (apb_xx_penable), @152
//   .presetn                (pad_cpu_rst_b), @153
//   .psel                   (apb_gpio_psel), @154
//   .pwdata                 (apb_xx_pwdata), @155
//   .pwrite                 (apb_xx_pwrite), @156
//   .gpio_intr              (gpio_vic_int), @157
//   .prdata                 (gpio_apb_prdata) @158
// ); @159

// &Instance("smpu_top", "x_smpu_top"); @161
smpu_top  x_smpu_top (
  .biu_pad_haddr     (fifo_pad_haddr   ),
  .biu_pad_hprot     (fifo_pad_hprot   ),
  .paddr             (apb_xx_paddr[3:2]),
  .pclk              (per_clk          ),
  .penable           (apb_xx_penable   ),
  .prdata            (smpu_apb_prdata  ),
  .presetn           (pg_reset_b       ),
  .psel              (apb_smpu_psel    ),
  .pwdata            (apb_xx_pwdata    ),
  .pwrite            (apb_xx_pwrite    ),
  .smpu_deny         (smpu_deny        )
);

// &Connect( @162
//   .paddr                  (apb_xx_paddr[3:2]), @163
//   .pclk                   (per_clk), @164
//   .penable                (apb_xx_penable), @165
//   .presetn                (pg_reset_b), @166
//   .psel                   (apb_smpu_psel), @167
//   .pwdata                 (apb_xx_pwdata), @168
//   .pwrite                 (apb_xx_pwrite), @169
//   .prdata                 (smpu_apb_prdata), @170
//   .biu_pad_haddr          (fifo_pad_haddr ), @171
//   .biu_pad_hprot          (fifo_pad_hprot ) @172
// ); @173

// &Instance("wic_top", "x_wic_top"); @175
wic_top  x_wic_top (
  .biu_pad_psr         (biu_pad_psr        ),
  .ctim_int_vld        (ctim_int_vld       ),
  .ctl_xx_awake_enable (32'hffffffff       ),
  .gpio_vic_int        (gpio_vic_int       ),
  .intraw_vld          (intraw_vld         ),
  .pad_cpu_rst_b       (pad_cpu_rst_b      ),
  .pad_vic_int_cfg     (pad_vic_int_cfg    ),
  .pad_vic_int_vld     (pad_vic_int_vld    ),
  .pulse_int           (1'b0               ),
  .stim_vic_int        (stim_vic_int       ),
  .tim_vic_int         (tim_vic_int        ),
  .uart0_vic_int       (uart0_vic_int      ),
  .spi_slave_vic_int   (spi_slave_vic_int  ),
  .wic_clk             (wic_clk            ),
  .usi_vic_int         (usi_vic_int        )
);

// &Connect( @176
//    .pulse_int              (1'b0         ), @177
//    .ctl_xx_awake_enable   (32'hffffffff  ) @178
//  @179
// ); @180
// &Force("nonport","pulse_int"); @182
// &Force("nonport","stim_vic_int"); @183
// &Force("nonport","gpio_vic_int"); @184

// &Force("nonport", "pulse_int"); @188
// &Force("nonport", "stim_vic_int"); @189

//assign pll_core_cpuclk = per_clk;
// &Force("output","per_clk"); @193
// &Force("output","cpu_clk"); @194
// &Force("output","pg_reset_b"); @195

// //&Force("output","cpu_clk"); @197
// //&Force("output",""); @198

wire spi_csb;
wire spi_sclk;
wire spi_miso;
wire spi_mosi;
wire sdo;
wire sdo_en;
assign spi_csb=b_pad_gpio_porta[0];
assign spi_miso=sdo_en?sdo:1'bZ;

spi_slave xspi_slave(
    .apb_spi_paddr(apb_xx_paddr),
    .apb_spi_penable(apb_xx_penable),
    .apb_spi_psel(apb_spi_slave_psel),
    .apb_spi_pwdata(apb_xx_pwdata),
    .apb_spi_pwrite(apb_xx_pwrite),
    .rst_b(pad_cpu_rst_b),
    .sys_clk(pmu_clk),
    .spi_apb_prdata(spi_slave_apb_prdata),
    .csb(spi_csb),
    .sclk(spi_sclk),
    .sdi(spi_mosi),
    .sdo_en(sdo_en),
    .sdo(sdo),
    .spi_vic_int(spi_slave_vic_int)
);

spi_master xspi_master(
    .apb_spi_paddr(apb_xx_paddr),
    .apb_spi_penable(apb_xx_penable),
    .apb_spi_psel(apb_spi_master_psel),
    .apb_spi_pwdata(apb_xx_pwdata),
    .apb_spi_pwrite(apb_xx_pwrite),
    .rst_b(pad_cpu_rst_b),
    .sys_clk(pmu_clk),
    .spi_apb_prdata(spi_master_apb_prdata),
    .sclk(spi_sclk),
    .sdi(spi_miso),
    .sdo(spi_mosi)
);

wire nss_in;
wire nss_out;
wire sclk_in;
wire sclk_out;
wire sd0_in;
wire sd0_out;
wire sd1_in;
wire sd1_out;

// uart
//wire uart;
//assign uart = sd0_out;
//assign sclk_in = uart;

// spi master
wire miso;
wire mosi;
wire sclk;
reg [15:0] test_data;
assign sclk = sclk_out;
assign mosi = sd0_out;
assign sd1_in = miso;
always @(negedge sclk or negedge pad_cpu_rst_b) begin
    if(~pad_cpu_rst_b) begin
        test_data <= 16'h203D;
    end
    else begin
        test_data <= {test_data[14:0],test_data[15]};
    end
end
assign miso=test_data[15];

usi_wll x_usi(
    .clk(pmu_clk),
    //.nss_ie_n,
    .nss_in(nss_in),
    //.nss_oe_n,
    .nss_out(nss_out),
    .paddr(apb_xx_paddr),
    .penable(apb_xx_penable),
    .prdata(usi_apb_prdata),
    .psel(apb_usi_psel),
    .pwdata(apb_xx_pwdata),
    .pwrite(apb_xx_pwrite),
    .rst_n(pad_cpu_rst_b),
    //.sclk_ie_n,
    .sclk_in(sclk_in),
    //.sclk_oe_n,
    .sclk_out(sclk_out),
    //.sd0_ie_n,
    .sd0_in(sd0_in),
    //.sd0_oe_n,
    .sd0_out(sd0_out),
    //.sd1_ie_n,
    .sd1_in(sd1_in),
    //.sd1_oe_n,
    .sd1_out(sd1_out),
    .usi_intr(usi_vic_int)
);

// &ModuleEnd; @200
endmodule




