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
  gpio_porta_oe,
  gpio_porta_out,
  gpio_porta_in,
  
  usi0_nss_ie,
  usi0_nss_oe,
  usi0_nss_in,
  usi0_nss_out,
  usi0_sclk_ie,
  usi0_sclk_oe,
  usi0_sclk_in,
  usi0_sclk_out,
  usi0_sd0_ie,
  usi0_sd0_oe,
  usi0_sd0_in,
  usi0_sd0_out,
  usi0_sd1_ie,
  usi0_sd1_oe,
  usi0_sd1_in,
  usi0_sd1_out,
  usi1_nss_ie,
  usi1_nss_oe,
  usi1_nss_in,
  usi1_nss_out,
  usi1_sclk_ie,
  usi1_sclk_oe,
  usi1_sclk_in,
  usi1_sclk_out,
  usi1_sd0_ie,
  usi1_sd0_oe,
  usi1_sd0_in,
  usi1_sd0_out,
  usi1_sd1_ie,
  usi1_sd1_oe,
  usi1_sd1_in,
  usi1_sd1_out,
  
  dac_out,
  
  biu_pad_lpmd_b,
  biu_pad_psr,
  clk_en,
  corec_pmu_sleep_out,
  cpu_clk,
  ctim_int_vld,
  fifo_pad_haddr,
  fifo_pad_hprot,
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
  smpu_deny
);

// &Ports; @21
input   [1 :0]  biu_pad_lpmd_b;        
input   [31:0]  biu_pad_psr;           
input           corec_pmu_sleep_out;   
input           ctim_int_vld;          
input   [31:0]  fifo_pad_haddr;        
input   [3 :0]  fifo_pad_hprot;        
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
input   [7 :0]  gpio_porta_in;    
input           usi0_nss_in;
input           usi0_sclk_in;
input           usi0_sd0_in;
input           usi0_sd1_in;
input           usi1_nss_in;
input           usi1_sclk_in;
input           usi1_sd0_in;
input           usi1_sd1_in;



output  [11:0]  dac_out;
output          clk_en;                
output          cpu_clk;               
output  [31:0]  hrdata_s2;             
output          hready_s2;             
output  [1 :0]  hresp_s2;              
output          pad_had_jtg_trst_b;    
output  [31:0]  pad_vic_int_cfg;       
output  [31:0]  pad_vic_int_vld;       
output          per_clk;               
output          pg_reset_b;            
output          pmu_corec_isolation;   
output          pmu_corec_sleep_in;    
output          smpu_deny;                        
output  [7 :0]  gpio_porta_oe;  
output  [7 :0]  gpio_porta_out;  
output          usi0_nss_ie;
output          usi0_nss_oe;
output          usi0_nss_out;
output          usi0_sclk_ie;
output          usi0_sclk_oe;
output          usi0_sclk_out;
output          usi0_sd0_ie;
output          usi0_sd0_oe;
output          usi0_sd0_out;
output          usi0_sd1_ie;
output          usi0_sd1_oe;
output          usi0_sd1_out;
output          usi1_nss_ie;
output          usi1_nss_oe;
output          usi1_nss_out;
output          usi1_sclk_ie;
output          usi1_sclk_oe;
output          usi1_sclk_out;
output          usi1_sd0_ie;
output          usi1_sd0_oe;
output          usi1_sd0_out;
output          usi1_sd1_ie;
output          usi1_sd1_oe;
output          usi1_sd1_out;

// &Regs; @22

// &Wires; @23
wire            apb_clkgen_psel;       
wire            apb_gpio_psel;         
wire            apb_pmu_psel;                 
wire            apb_tim_psel;          
wire            apb_wdt_psel;
wire            apb_usi0_psel;   
wire            apb_usi1_psel;  
wire            apb_sfr_psel;
wire            apb_adc_psel;
wire            apb_dac_psel;
wire            apb_pwm_psel;
wire            apb_otp_psel;

wire    [31:0]  apb_xx_paddr;          
wire            apb_xx_penable;        
wire    [31:0]  apb_xx_pwdata;         
wire            apb_xx_pwrite;   
      
wire    [7 :0]  gpio_porta_oe;  
wire    [7 :0]  gpio_porta_out;  
wire    [7 :0]  gpio_porta_in;  

wire            usi0_nss_ie;
wire            usi0_nss_oe;
wire            usi0_nss_in;
wire            usi0_nss_out;
wire            usi0_sclk_ie;
wire            usi0_sclk_oe;
wire            usi0_sclk_in;
wire            usi0_sclk_out;
wire            usi0_sd0_ie;
wire            usi0_sd0_oe;
wire            usi0_sd0_in;
wire            usi0_sd0_out;
wire            usi0_sd1_ie;
wire            usi0_sd1_oe;
wire            usi0_sd1_in;
wire            usi0_sd1_out;
wire            usi1_nss_ie;
wire            usi1_nss_oe;
wire            usi1_nss_in;
wire            usi1_nss_out;
wire            usi1_sclk_ie;
wire            usi1_sclk_oe;
wire            usi1_sclk_in;
wire            usi1_sclk_out;
wire            usi1_sd0_ie;
wire            usi1_sd0_oe;
wire            usi1_sd0_in;
wire            usi1_sd0_out;
wire            usi1_sd1_ie;
wire            usi1_sd1_oe;
wire            usi1_sd1_in;
wire            usi1_sd1_out;

wire    [11:0]  dac_out;

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
wire            scan_mode;   
wire            smpu_deny;             
wire            wic_clk;  

wire    [ 3:0]  tim_vic_int;  
wire    [31:0]  tim_apb_prdata;
wire            wdt_vic_int;
wire    [31:0]  wdt_apb_prdata;
wire            usi0_vic_int;
wire    [31:0]  usi0_apb_prdata; 
wire            usi1_vic_int;
wire    [31:0]  usi1_apb_prdata; 
wire    [31:0]  sfr_apb_prdata;
wire            adc_vic_int;
wire    [31:0]  adc_apb_prdata;
wire    [31:0]  dac_apb_prdata;
wire    [31:0]  pwm_apb_prdata;
wire    [31:0]  otp_apb_prdata;

assign smpu_deny = 1'b0;
assign scan_mode = 1'b0;


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
  .prdata_s1         (tim_apb_prdata   ),
  .prdata_s2         (wdt_apb_prdata   ),
  .prdata_s3         (usi0_apb_prdata  ),
  .prdata_s4         (usi1_apb_prdata  ),
  .prdata_s5         (sfr_apb_prdata   ),
  .prdata_s6         (pmu_apb_prdata   ),
  .prdata_s7         (clkgen_apb_prdata),
  .prdata_s8         (pwm_apb_prdata   ),
  .prdata_s9         (gpio_apb_prdata  ),
  .prdata_sA         (otp_apb_prdata   ),
  .prdata_sB         (adc_apb_prdata   ),
  .prdata_sC         (dac_apb_prdata   ),
  .psel_s1           (apb_tim_psel     ),
  .psel_s2           (apb_wdt_psel     ),
  .psel_s3           (apb_usi0_psel    ),
  .psel_s4           (apb_usi1_psel    ),
  .psel_s5           (apb_sfr_psel     ),
  .psel_s6           (apb_pmu_psel     ),
  .psel_s7           (apb_clkgen_psel  ),
  .psel_s8           (apb_pwm_psel     ),
  .psel_s9           (apb_gpio_psel    ),
  .psel_sA           (otp_pwm_psel     ),
  .psel_sB           (apb_adc_psel     ),
  .psel_sC           (apb_dac_psel     )
);


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
  .i_pad_cpu_jtg_rst_b    (i_pad_cpu_jtg_rst_b   ),
  .i_pad_jtg_tclk         (i_pad_jtg_tclk        ),
  .intraw_vld             (intraw_vld            ),
  .pad_cpu_rst_b          (pad_cpu_rst_b         ),
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

gpio  x_gpio (
  .gpio_porta_oe     (gpio_porta_oe    ),
  .gpio_porta_in     (gpio_porta_in    ),
  .gpio_porta_out    (gpio_porta_out   ),
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


wic_top  x_wic_top (
  .biu_pad_psr         (biu_pad_psr        ),
  .ctl_xx_awake_enable (32'hffffffff       ),
  .intraw_vld          (intraw_vld         ),
  .pad_cpu_rst_b       (pad_cpu_rst_b      ),
  .pad_vic_int_cfg     (pad_vic_int_cfg    ),
  .pad_vic_int_vld     (pad_vic_int_vld    ),
  .pad_wic_int_vld     ({   14'b0,
                            1'b0,        //0x31 ADC_Socket
                            usi1_vic_int,       //0x30 usi1
                            usi0_vic_int,       //0x2F usi0
                            wdt_vic_int,        //0x2E WDT
                            tim_vic_int[3:0],   //0x2D-0x2A TIM
                            gpio_vic_int[7:0],  //0x29-0x22 GPIO
                            ctim_int_vld,       //0x21 CoreTim
                            1'b0}),             //0x20 REV
  .wic_clk             (wic_clk            )
);

wdt x_wdt(
    .pclk               (per_clk            ),
    .presetn            (pad_cpu_rst_b      ),
    .penable            (apb_xx_penable     ),
    .pwrite             (apb_xx_pwrite      ),
    .pwdata             (apb_xx_pwdata      ),
    .paddr              (apb_xx_paddr       ),
    .psel               (apb_wdt_psel       ),
    .scan_mode          (scan_mode          ),
    .wdt_int            (wdt_vic_int        ),
    //.wdt_sys_rst_n      ( ),//to rst tree
    .prdata             (wdt_apb_prdata     )
);

usi x_usi0(
    .clk                (per_clk            ),
    .nss_ie             (usi0_nss_ie        ),
    .nss_in             (usi0_nss_in        ),
    .nss_oe             (usi0_nss_oe        ),
    .nss_out            (usi0_nss_out       ),
    .paddr              (apb_xx_paddr       ),
    .penable            (apb_xx_penable     ),
    .prdata             (usi0_apb_prdata    ),
    .psel               (apb_usi0_psel      ),
    .pwdata             (apb_xx_pwdata      ),
    .pwrite             (apb_xx_pwrite      ),
    .rst_n              (pad_cpu_rst_b      ),
    .sclk_ie            (usi0_sclk_ie       ),
    .sclk_in            (usi0_sclk_in       ),
    .sclk_oe            (usi0_sclk_oe       ),
    .sclk_out           (usi0_sclk_out      ),
    .sd0_ie             (usi0_sd0_ie        ),
    .sd0_in             (usi0_sd0_in        ),
    .sd0_oe             (usi0_sd0_oe        ),
    .sd0_out            (usi0_sd0_out       ),
    .sd1_ie             (usi0_sd1_ie        ),
    .sd1_in             (usi0_sd1_in        ),
    .sd1_oe             (usi0_sd1_oe        ),
    .sd1_out            (usi0_sd1_out       ),
    .usi_intr           (usi0_vic_int       )
);

usi x_usi1(
    .clk                (per_clk            ),
    .nss_ie             (usi1_nss_ie        ),
    .nss_in             (usi1_nss_in        ),
    .nss_oe             (usi1_nss_oe        ),
    .nss_out            (usi1_nss_out       ),
    .paddr              (apb_xx_paddr       ),
    .penable            (apb_xx_penable     ),
    .prdata             (usi1_apb_prdata    ),
    .psel               (apb_usi1_psel      ),
    .pwdata             (apb_xx_pwdata      ),
    .pwrite             (apb_xx_pwrite      ),
    .rst_n              (pad_cpu_rst_b      ),
    .sclk_ie            (usi1_sclk_ie       ),
    .sclk_in            (usi1_sclk_in       ),
    .sclk_oe            (usi1_sclk_oe       ),
    .sclk_out           (usi1_sclk_out      ),
    .sd0_ie             (usi1_sd0_ie        ),
    .sd0_in             (usi1_sd0_in        ),
    .sd0_oe             (usi1_sd0_oe        ),
    .sd0_out            (usi1_sd0_out       ),
    .sd1_ie             (usi1_sd1_ie        ),
    .sd1_in             (usi1_sd1_in        ),
    .sd1_oe             (usi1_sd1_oe        ),
    .sd1_out            (usi1_sd1_out       ),
    .usi_intr           (usi1_vic_int       )
);

sfr x_sfr(
    .apb_sfr_paddr      (apb_xx_paddr       ),
    .apb_sfr_penable    (apb_xx_penable     ),
    .apb_sfr_psel       (apb_sfr_psel       ),
    .apb_sfr_pwdata     (apb_xx_pwdata      ),
    .apb_sfr_pwrite     (apb_xx_pwrite      ),
    .rst_b              (pad_cpu_rst_b      ),
    .sys_clk            (per_clk            ),
    .sfr_apb_prdata     (sfr_apb_prdata     )
    //.sfr_reg_00,
    //.sfr_reg_01,
    //.sfr_reg_02,
    //.sfr_reg_03,
    //.sfr_reg_04,
    //.sfr_reg_05,
    //.sfr_reg_06,
    //.sfr_reg_07
);

DAC_Socket x_DAC_Socket(
    .apb_dac_paddr      (apb_xx_paddr       ),
    .apb_dac_penable    (apb_xx_penable     ),
    .apb_dac_psel       (apb_dac_psel       ),
    .apb_dac_pwdata     (apb_xx_pwdata      ),
    .apb_dac_pwrite     (apb_xx_pwrite      ),
    .rst_b              (pad_cpu_rst_b      ),
    .sys_clk            (per_clk            ),
    .dac_apb_prdata     (dac_apb_prdata     ),
    .dac_value          (dac_out            )
);

endmodule
