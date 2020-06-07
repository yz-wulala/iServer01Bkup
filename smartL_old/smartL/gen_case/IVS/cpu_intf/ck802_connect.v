// *                                                                          *
// * C-Sky Microsystems Confidential                                          *
// * -------------------------------                                          *
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// FILE NAME    : 802 connect test module
// AUTHOR       : dingyan_wei
// FUNCTION     : test for soc conection
// HWCFG        :
// METHOD       : 
// CSKYCPU      : 802
// NOTE         :
// $Id: 
// ****************************************************************************
//please add configuration file cpu_cfig.h into your environment 
`include "cpu_cfig.h" 
module ck802_connect();

//*******************************************************************************//
//*************** please set the path of the top level signal********************//
//*******************************************************************************//
`define BIU_PATH                         tb.x_soc.x_cpu_sub_system_ahb
`define IAHB_LITE_PATH                   tb.x_soc.x_cpu_sub_system_ahb
`define DAHB_LITE_PATH                   tb.x_soc.x_cpu_sub_system_ahb
`define CTIM_PATH                        tb.x_soc.x_cpu_sub_system_ahb
`define CLOCK_PATH                       tb.x_soc.x_cpu_sub_system_ahb
`define DFT_PATH                         tb.x_soc.x_cpu_sub_system_ahb
`define DSP_PATH                         tb.x_soc.x_cpu_sub_system_ahb
`define FPU_PATH                         tb.x_soc.x_cpu_sub_system_ahb 
`define CPU_OBSERVED_PATH                tb.x_soc.x_cpu_sub_system_ahb
`define LOWPOWER_PATH                    tb.x_soc.x_cpu_sub_system_ahb
`define JTAG_PATH                        tb.x_soc.x_cpu_sub_system_ahb
`define VIC_PATH                         tb.x_soc.x_cpu_sub_system_ahb

`define CPU_TOP_PATH                     tb.x_soc.x_cpu_sub_system_ahb.x_ck802

//ATTENTION!!!:SOC layer signal name must be consistent with the list provided below,
//otherwise unable to identify the signal! If the signal of the inconsistent,you can
//also modify the following list of SOC layer signal name.

//------------------------------SOC layer signal list----------------------------//
//NOTE:You can modify the SOC layer signal's name in the list below to ensure the SOC
//layer signal can be identified                  
//BIU signal list
`define biu_pad_haddr                    `BIU_PATH.biu_pad_haddr[31:0]
`define biu_pad_hburst                   `BIU_PATH.biu_pad_hburst[2:0]
`ifdef SYS_AHB
`define biu_pad_hbusreq                  `BIU_PATH.biu_pad_hbusreq
`endif
`define biu_pad_hprot                    `BIU_PATH.biu_pad_hprot[3:0]
`define biu_pad_hsize                    `BIU_PATH.biu_pad_hsize[2:0]
`define biu_pad_htrans                   `BIU_PATH.biu_pad_htrans[1:0]
`define biu_pad_hwdata                   `BIU_PATH.biu_pad_hwdata[31:0]
`define biu_pad_hwrite                   `BIU_PATH.biu_pad_hwrite 
`define pad_biu_hrdata                   `BIU_PATH.pad_biu_hrdata[31:0]
`define pad_biu_hready                   `BIU_PATH.pad_biu_hready    
`define pad_biu_hresp                    `BIU_PATH.pad_biu_hresp
`ifdef SEU_DATA_PATH_POLARITY
  `define biu_pad_haddr_pol                 `BIU_PATH.biu_pad_haddr_pol[31:0]
  `define biu_pad_hwdata_pol                `BIU_PATH.biu_pad_hwdata_pol[31:0]
  `define pad_biu_hrdata_pol                `BIU_PATH.pad_biu_hrdata_pol[31:0]
`endif
`ifdef CSKY_TEE
  `define pad_biu_hsec                    `BIU_PATH.pad_biu_hsec
`endif
`ifdef SEU_BUS_PARITY
  `define biu_pad_hwdata_par              `BIU_PATH.biu_pad_hwdata_par[31:0]
  `define pad_biu_hrdata_par              `BIU_PATH.pad_biu_hrdata_par[31:0]
`endif
`ifdef HAD_INST_DEBUG_DISABLE
  `define pad_biu_inst_dbg_diable         `BIU_PATH.pad_biu_inst_dbg_diable
`endif
//ilite signal list
`ifdef IAHB_LITE
`define iahbl_pad_haddr                  `IAHB_LITE_PATH.iahbl_pad_haddr[31:0] 
`define iahbl_pad_hburst                 `IAHB_LITE_PATH.iahbl_pad_hburst[2:0]
`define iahbl_pad_hprot                  `IAHB_LITE_PATH.iahbl_pad_hprot[3:0]        
`define iahbl_pad_hsize                  `IAHB_LITE_PATH.iahbl_pad_hsize[2:0]         
`define iahbl_pad_htrans                 `IAHB_LITE_PATH.iahbl_pad_htrans[1:0]         
`define iahbl_pad_hwdata                 `IAHB_LITE_PATH.iahbl_pad_hwdata[31:0]           
`define iahbl_pad_hwrite                 `IAHB_LITE_PATH.iahbl_pad_hwrite          
`define pad_iahbl_hrdata                 `IAHB_LITE_PATH.pad_iahbl_hrdata[31:0]        
`define pad_iahbl_hready                 `IAHB_LITE_PATH.pad_iahbl_hready           
`define pad_iahbl_hresp                  `IAHB_LITE_PATH.pad_iahbl_hresp
`ifdef CSKY_TEE
  `define pad_iahbl_hsec                 `IAHB_LITE_PATH.pad_iahbl_hsec
`endif
`endif
//dlite signal list
`ifdef DAHB_LITE
`define dahbl_pad_haddr                  `DAHB_LITE_PATH.dahbl_pad_haddr[31:0] 
`define dahbl_pad_hburst                 `DAHB_LITE_PATH.dahbl_pad_hburst[2:0]
`define dahbl_pad_hprot                  `DAHB_LITE_PATH.dahbl_pad_hprot[3:0]        
`define dahbl_pad_hsize                  `DAHB_LITE_PATH.dahbl_pad_hsize[2:0]         
`define dahbl_pad_htrans                 `DAHB_LITE_PATH.dahbl_pad_htrans[1:0]         
`define dahbl_pad_hwdata                 `DAHB_LITE_PATH.dahbl_pad_hwdata[31:0]           
`define dahbl_pad_hwrite                 `DAHB_LITE_PATH.dahbl_pad_hwrite          
`define pad_dahbl_hrdata                 `DAHB_LITE_PATH.pad_dahbl_hrdata[31:0]        
`define pad_dahbl_hready                 `DAHB_LITE_PATH.pad_dahbl_hready           
`define pad_dahbl_hresp                  `DAHB_LITE_PATH.pad_dahbl_hresp
`ifdef CSKY_TEE
  `define pad_dahbl_hsec                 `DAHB_LITE_PATH.pad_dahbl_hsec
`endif
`endif
//coretimer signal list
`ifdef CTIM
//`define pad_ctim_calib                   `SOC_PATH.pad_ctim_calib[25:0]
//`define pad_ctim_refclk                  `SOC_PATH.pad_ctim_refclk
`define ctim_pad_int_vld                 `CTIM_PATH.ctim_int_vld
`endif
//clock and control signal list
`define pll_core_cpuclk                  `CLOCK_PATH.cpu_clk
`define clk_en                           `CLOCK_PATH.clk_en
`define pad_sysio_bigend_b               `CLOCK_PATH.pad_biu_bigend_b
`define pad_sysio_clkratio               `CLOCK_PATH.pad_biu_clkratio[2:0]
`define pad_cpu_rst_b                    `CLOCK_PATH.pad_cpu_rst_b
`define sysio_pad_srst                   `CLOCK_PATH.sysio_pad_srst
`define pll_core_cpuclk_nogated          `CLOCK_PATH.pll_core_cpuclk
//DFT signal list
`define pad_yy_test_mode                 `DFT_PATH.pad_yy_test_mode
`ifdef CACHE
`define pad_yy_bist_tst_en               `DFT_PATH.pad_yy_bist_tst_en
`endif
`define pad_yy_gate_clk_en_b             `DFT_PATH.pad_yy_gate_clk_en_b
`ifdef SCAN_CHAIN_4
`define pad_yy_scan_enable               `DFT_PATH.pad_yy_scan_enable
`define nm_top_si_1                      `DFT_PATH.nm_top_si_1
`define nm_top_si_2                      `DFT_PATH.nm_top_si_2
`define nm_top_si_3                      `DFT_PATH.nm_top_si_3
`define nm_top_si_4                      `DFT_PATH.nm_top_si_4
`define nm_top_so_1                      `DFT_PATH.nm_top_so_1
`define nm_top_so_2                      `DFT_PATH.nm_top_so_2
`define nm_top_so_3                      `DFT_PATH.nm_top_so_3
`define nm_top_so_4                      `DFT_PATH.nm_top_so_4
`endif
`ifdef SCAN_CHAIN_8
`define pad_yy_scan_enable               `DFT_PATH.pad_yy_scan_enable  
`define nm_top_si_1                      `DFT_PATH.nm_top_si_1
`define nm_top_si_2                      `DFT_PATH.nm_top_si_2
`define nm_top_si_3                      `DFT_PATH.nm_top_si_3
`define nm_top_si_4                      `DFT_PATH.nm_top_si_4
`define nm_top_si_5                      `DFT_PATH.nm_top_si_5
`define nm_top_si_6                      `DFT_PATH.nm_top_si_6
`define nm_top_si_7                      `DFT_PATH.nm_top_si_7
`define nm_top_si_8                      `DFT_PATH.nm_top_si_8
`define nm_top_so_1                      `DFT_PATH.nm_top_so_1
`define nm_top_so_2                      `DFT_PATH.nm_top_so_2
`define nm_top_so_3                      `DFT_PATH.nm_top_so_3
`define nm_top_so_4                      `DFT_PATH.nm_top_so_4
`define nm_top_so_5                      `DFT_PATH.nm_top_so_5
`define nm_top_so_6                      `DFT_PATH.nm_top_so_6
`define nm_top_so_7                      `DFT_PATH.nm_top_so_7
`define nm_top_so_8                      `DFT_PATH.nm_top_so_8
`endif
`ifdef SCAN_CHAIN_12
`define pad_yy_scan_enable               `DFT_PATH.pad_yy_scan_enable  
`define nm_top_si_1                      `DFT_PATH.nm_top_si_1
`define nm_top_si_2                      `DFT_PATH.nm_top_si_2
`define nm_top_si_3                      `DFT_PATH.nm_top_si_3
`define nm_top_si_4                      `DFT_PATH.nm_top_si_4
`define nm_top_si_5                      `DFT_PATH.nm_top_si_5
`define nm_top_si_6                      `DFT_PATH.nm_top_si_6
`define nm_top_si_7                      `DFT_PATH.nm_top_si_7
`define nm_top_si_8                      `DFT_PATH.nm_top_si_8
`define nm_top_si_9                      `DFT_PATH.nm_top_si_9
`define nm_top_si_10                     `DFT_PATH.nm_top_si_10
`define nm_top_si_11                     `DFT_PATH.nm_top_si_11
`define nm_top_si_12                     `DFT_PATH.nm_top_si_12
`define nm_top_so_1                      `DFT_PATH.nm_top_so_1
`define nm_top_so_2                      `DFT_PATH.nm_top_so_2
`define nm_top_so_3                      `DFT_PATH.nm_top_so_3
`define nm_top_so_4                      `DFT_PATH.nm_top_so_4
`define nm_top_so_5                      `DFT_PATH.nm_top_so_5
`define nm_top_so_6                      `DFT_PATH.nm_top_so_6
`define nm_top_so_7                      `DFT_PATH.nm_top_so_7
`define nm_top_so_8                      `DFT_PATH.nm_top_so_8
`define nm_top_so_9                      `DFT_PATH.nm_top_so_9
`define nm_top_so_10                     `DFT_PATH.nm_top_so_10
`define nm_top_so_11                     `DFT_PATH.nm_top_so_11
`define nm_top_so_12                     `DFT_PATH.nm_top_so_12
`endif

//CPU observed signal
`define iu_pad_gpr_data                 `CPU_OBSERVED_PATH.biu_pad_wb_gpr_data[31:0] 
`define iu_pad_gpr_index                `CPU_OBSERVED_PATH.biu_pad_wb_gpr_index[4:0]
`define iu_pad_gpr_we                   `CPU_OBSERVED_PATH.biu_pad_wb_gpr_en
`define iu_pad_inst_retire              `CPU_OBSERVED_PATH.biu_pad_retire
`define iu_pad_inst_split               `CPU_OBSERVED_PATH.iu_pad_inst_split
`define iu_pad_retire_pc                `CPU_OBSERVED_PATH.biu_pad_retire_pc[31:0]
`define cp0_pad_psr                     `CPU_OBSERVED_PATH.biu_pad_psr[31:0]
//lowpower signal
`define sysio_pad_ipend_b                `LOWPOWER_PATH.biu_pad_ipend_b
`define sysio_pad_lpmd_b                 `LOWPOWER_PATH.biu_pad_lpmd_b[1:0] 
`define sysio_pad_wakeup_b               `LOWPOWER_PATH.biu_pad_wakeup_b
//debug and jtag signal list
`define had_pad_jdb_pm                   `JTAG_PATH.had_pad_jdb_pm[1:0]
`define had_pad_jtg_tap_on               `JTAG_PATH.had_pad_jtg_tap_on
`define pad_had_jdb_req_b                `JTAG_PATH.pad_had_jdb_req_b
`define pad_had_jtg_tap_en               `JTAG_PATH.pad_had_jtg_tap_en
`define pad_had_jtg_tclk                 `JTAG_PATH.pad_had_jtg_tclk
`define pad_had_jtg_tms_i                `JTAG_PATH.pad_had_jtg_tms_i
`define had_pad_jtg_tms_o                `JTAG_PATH.had_pad_jtg_tms_o
`define had_pad_jtg_tms_oe               `JTAG_PATH.had_pad_jtg_tms_oe
`define pad_had_jtg_trst_b               `JTAG_PATH.pad_had_jtg_trst_b
`define sysio_pad_dbg_b                  `JTAG_PATH.biu_pad_dbg_b

//VIC signal list
`ifdef VIC
`else
`define pad_cpu_avec_b                   `VIC_PATH.top_cpu_avec_b
`define pad_cpu_fint_b                   `VIC_PATH.pad_cpu_fint_b
`define pad_cpu_fintraw_b                `VIC_PATH.pad_cpu_fintraw_b
`define pad_cpu_int_b                    `VIC_PATH.pad_cpu_int_b
`define pad_cpu_intraw_b                 `VIC_PATH.pad_cpu_intraw_b
`define pad_cpu_vec_b                    `VIC_PATH.pad_cpu_vec_b
`endif
`ifdef VIC
`ifdef INT_NUM_1
// `define pad_vic_int_cfg                VIC_PATHTH.pad_vic_int_cfg
 `define pad_vic_int_vld                 `VIC_PATH.pad_vic_int_vld
`endif
`ifdef INT_NUM_2
// `define pad_vic_int_cfg                VIC_PATHTH.pad_vic_int_cfg[1:0]
 `define pad_vic_int_vld                 `VIC_PATH.pad_vic_int_vld[1:0]
`endif
`ifdef INT_NUM_4
// `define pad_vic_int_cfg                VIC_PATHTH.pad_vic_int_cfg[3:0]
 `define pad_vic_int_vld                 `VIC_PATH.pad_vic_int_vld[3:0]
`endif
 `ifdef VIC_IPR1
// `define pad_vic_int_cfg                VIC_PATHTH.pad_vic_int_cfg[7:0]
 `define pad_vic_int_vld                 `VIC_PATH.pad_vic_int_vld[7:0]
`endif
 `ifdef VIC_IPR3
// `define pad_vic_int_cfg                VIC_PATHTH.pad_vic_int_cfg[15:0]
 `define pad_vic_int_vld                 `VIC_PATH.pad_vic_int_vld[15:0]
`endif
 `ifdef VIC_IPR5
// `define pad_vic_int_cfg                VIC_PATHTH.pad_vic_int_cfg[23:0]
 `define pad_vic_int_vld                 `VIC_PATH.pad_vic_int_vld[23:0]
`endif
 `ifdef VIC_IPR7
// `define pad_vic_int_cfg                VIC_PATHTH.pad_vic_int_cfg[31:0]
 `define pad_vic_int_vld                 `VIC_PATH.pad_vic_int_vld[31:0] 
`endif
`endif
//------------------------------CPU top level signal list----------------------------// 
//BIU signal list
`define CPU_biu_pad_haddr                `CPU_TOP_PATH.biu_pad_haddr[31:0]
`define CPU_biu_pad_hburst               `CPU_TOP_PATH.biu_pad_hburst[2:0]
`ifdef SYS_AHB
`define CPU_biu_pad_hbusreq              `CPU_TOP_PATH.biu_pad_hbusreq
`endif
`define CPU_biu_pad_hprot                `CPU_TOP_PATH.biu_pad_hprot[3:0]
`define CPU_biu_pad_hsize                `CPU_TOP_PATH.biu_pad_hsize[2:0]
`define CPU_biu_pad_htrans               `CPU_TOP_PATH.biu_pad_htrans[1:0]
`define CPU_biu_pad_hwdata               `CPU_TOP_PATH.biu_pad_hwdata[31:0]
`define CPU_biu_pad_hwrite               `CPU_TOP_PATH.biu_pad_hwrite
`define CPU_biu_pad_hwrite               `CPU_TOP_PATH.biu_pad_hwrite
`define CPU_pad_biu_hrdata               `CPU_TOP_PATH.pad_biu_hrdata
`define CPU_pad_biu_hready               `CPU_TOP_PATH.pad_biu_hready    
`define CPU_pad_biu_hresp                `CPU_TOP_PATH.pad_biu_hresp
`ifdef SEU_DATA_PATH_POLARITY
  `define CPU_biu_pad_haddr_pol                 `CPU_TOP_PATH.biu_pad_haddr_pol[31:0]
  `define CPU_biu_pad_hwdata_pol                `CPU_TOP_PATH.biu_pad_hwdata_pol[31:0]
  `define CPU_pad_biu_hrdata_pol                `CPU_TOP_PATH.pad_biu_hrdata_pol[31:0]
`endif
`ifdef CSKY_TEE
  `define CPU_pad_biu_hsec                     `CPU_TOP_PATH.pad_biu_hsec
`endif
`ifdef SEU_BUS_PARITY
  `define CPU_biu_pad_hwdata_par              `CPU_TOP_PATH.biu_pad_hwdata_par[31:0]
  `define CPU_pad_biu_hrdata_par              `CPU_TOP_PATH.pad_biu_hrdata_par[31:0]
`endif
`ifdef HAD_INST_DEBUG_DISABLE
  `define CPU_pad_biu_inst_dbg_diable         `CPU_TOP_PATH.pad_biu_inst_dbg_diable
`endif
//ilite signal list
`ifdef IAHB_LITE
`define CPU_iahbl_pad_haddr              `CPU_TOP_PATH.iahbl_pad_haddr[31:0] 
`define CPU_iahbl_pad_hburst             `CPU_TOP_PATH.iahbl_pad_hburst[2:0]
`define CPU_iahbl_pad_hprot              `CPU_TOP_PATH.iahbl_pad_hprot[3:0]        
`define CPU_iahbl_pad_hsize              `CPU_TOP_PATH.iahbl_pad_hsize[2:0]         
`define CPU_iahbl_pad_htrans             `CPU_TOP_PATH.iahbl_pad_htrans[1:0]         
`define CPU_iahbl_pad_hwdata             `CPU_TOP_PATH.iahbl_pad_hwdata[31:0]           
`define CPU_iahbl_pad_hwrite             `CPU_TOP_PATH.iahbl_pad_hwrite          
`define CPU_pad_iahbl_hrdata             `CPU_TOP_PATH.pad_iahbl_hrdata[31:0]        
`define CPU_pad_iahbl_hready             `CPU_TOP_PATH.pad_iahbl_hready           
`define CPU_pad_iahbl_hresp              `CPU_TOP_PATH.pad_iahbl_hresp
`define CPU_pad_bmu_iahbl_base               `CPU_TOP_PATH.pad_bmu_iahbl_base[11:0]
`define CPU_pad_bmu_iahbl_mask               `CPU_TOP_PATH.pad_bmu_iahbl_mask[11:0]
`ifdef CSKY_TEE
  `define CPU_pad_iahbl_hsec                     `CPU_TOP_PATH.pad_iahbl_hsec
`endif
`endif
//dlite signal list
`ifdef DAHB_LITE
`define CPU_dahbl_pad_haddr              `CPU_TOP_PATH.dahbl_pad_haddr[31:0] 
`define CPU_dahbl_pad_hburst             `CPU_TOP_PATH.dahbl_pad_hburst[2:0]
`define CPU_dahbl_pad_hprot              `CPU_TOP_PATH.dahbl_pad_hprot[3:0]        
`define CPU_dahbl_pad_hsize              `CPU_TOP_PATH.dahbl_pad_hsize[2:0]         
`define CPU_dahbl_pad_htrans             `CPU_TOP_PATH.dahbl_pad_htrans[1:0]         
`define CPU_dahbl_pad_hwdata             `CPU_TOP_PATH.dahbl_pad_hwdata[31:0]           
`define CPU_dahbl_pad_hwrite             `CPU_TOP_PATH.dahbl_pad_hwrite          
`define CPU_pad_dahbl_hrdata             `CPU_TOP_PATH.pad_dahbl_hrdata[31:0]        
`define CPU_pad_dahbl_hready             `CPU_TOP_PATH.pad_dahbl_hready           
`define CPU_pad_dahbl_hresp              `CPU_TOP_PATH.pad_dahbl_hresp
`define CPU_pad_bmu_dahbl_base               `CPU_TOP_PATH.pad_bmu_dahbl_base[11:0]
`define CPU_pad_bmu_dahbl_mask               `CPU_TOP_PATH.pad_bmu_dahbl_mask[11:0]
`ifdef CSKY_TEE
  `define CPU_pad_dahbl_hsec                     `CPU_TOP_PATH.pad_dahbl_hsec
`endif
`endif
//coretimer signal list
`ifdef CTIM
`define CPU_pad_ctim_calib               `CPU_TOP_PATH.pad_ctim_calib[25:0]
`define CPU_pad_ctim_refclk              `CPU_TOP_PATH.pad_ctim_refclk
`define CPU_ctim_pad_int_vld             `CPU_TOP_PATH.ctim_pad_int_vld
`endif
//clock and control signal list
`define CPU_pll_core_cpuclk              `CPU_TOP_PATH.pll_core_cpuclk
`define CPU_clk_en                       `CPU_TOP_PATH.clk_en
`define CPU_pad_sysio_bigend_b           `CPU_TOP_PATH.pad_sysio_bigend_b
`define CPU_pad_sysio_clkratio           `CPU_TOP_PATH.pad_sysio_clkratio[2:0]
`define CPU_pad_cpu_rst_b                `CPU_TOP_PATH.pad_cpu_rst_b
`define CPU_sysio_pad_srst               `CPU_TOP_PATH.sysio_pad_srst
`define CPU_pad_sysio_endian_v2          `CPU_TOP_PATH.pad_sysio_endian_v2
`define CPU_pll_core_cpuclk_nogated      `CPU_TOP_PATH.pll_core_cpuclk_nogated 

//DFT signal list
`define CPU_pad_yy_test_mode             `CPU_TOP_PATH.pad_yy_test_mode
`ifdef CACHE
`define CPU_pad_yy_bist_tst_en           `CPU_TOP_PATH.pad_yy_bist_tst_en
`endif
`define CPU_pad_yy_gate_clk_en_b         `CPU_TOP_PATH.pad_yy_gate_clk_en_b
`ifdef SCAN_CHAIN_4
`define CPU_pad_yy_scan_enable           `CPU_TOP_PATH.pad_yy_scan_enable  
`define CPU_nm_top_si_1                  `CPU_TOP_PATH.nm_top_si_1
`define CPU_nm_top_si_2                  `CPU_TOP_PATH.nm_top_si_2
`define CPU_nm_top_si_3                  `CPU_TOP_PATH.nm_top_si_3
`define CPU_nm_top_si_4                  `CPU_TOP_PATH.nm_top_si_4
`define CPU_nm_top_so_1                  `CPU_TOP_PATH.nm_top_so_1
`define CPU_nm_top_so_2                  `CPU_TOP_PATH.nm_top_so_2
`define CPU_nm_top_so_3                  `CPU_TOP_PATH.nm_top_so_3
`define CPU_nm_top_so_4                  `CPU_TOP_PATH.nm_top_so_4
`endif
`ifdef SCAN_CHAIN_8
`define CPU_pad_yy_scan_enable           `CPU_TOP_PATH.pad_yy_scan_enable  
`define CPU_nm_top_si_1                  `CPU_TOP_PATH.nm_top_si_1
`define CPU_nm_top_si_2                  `CPU_TOP_PATH.nm_top_si_2
`define CPU_nm_top_si_3                  `CPU_TOP_PATH.nm_top_si_3
`define CPU_nm_top_si_4                  `CPU_TOP_PATH.nm_top_si_4
`define CPU_nm_top_si_5                  `CPU_TOP_PATH.nm_top_si_5
`define CPU_nm_top_si_6                  `CPU_TOP_PATH.nm_top_si_6
`define CPU_nm_top_si_7                  `CPU_TOP_PATH.nm_top_si_7
`define CPU_nm_top_si_8                  `CPU_TOP_PATH.nm_top_si_8
`define CPU_nm_top_so_1                  `CPU_TOP_PATH.nm_top_so_1
`define CPU_nm_top_so_2                  `CPU_TOP_PATH.nm_top_so_2
`define CPU_nm_top_so_3                  `CPU_TOP_PATH.nm_top_so_3
`define CPU_nm_top_so_4                  `CPU_TOP_PATH.nm_top_so_4
`define CPU_nm_top_so_5                  `CPU_TOP_PATH.nm_top_so_5
`define CPU_nm_top_so_6                  `CPU_TOP_PATH.nm_top_so_6
`define CPU_nm_top_so_7                  `CPU_TOP_PATH.nm_top_so_7
`define CPU_nm_top_so_8                  `CPU_TOP_PATH.nm_top_so_8
`endif
`ifdef SCAN_CHAIN_12
`define CPU_pad_yy_scan_enable           `CPU_TOP_PATH.pad_yy_scan_enable  
`define CPU_nm_top_si_1                  `CPU_TOP_PATH.nm_top_si_1
`define CPU_nm_top_si_2                  `CPU_TOP_PATH.nm_top_si_2
`define CPU_nm_top_si_3                  `CPU_TOP_PATH.nm_top_si_3
`define CPU_nm_top_si_4                  `CPU_TOP_PATH.nm_top_si_4
`define CPU_nm_top_si_5                  `CPU_TOP_PATH.nm_top_si_5
`define CPU_nm_top_si_6                  `CPU_TOP_PATH.nm_top_si_6
`define CPU_nm_top_si_7                  `CPU_TOP_PATH.nm_top_si_7
`define CPU_nm_top_si_8                  `CPU_TOP_PATH.nm_top_si_8
`define CPU_nm_top_si_9                  `CPU_TOP_PATH.nm_top_si_9
`define CPU_nm_top_si_10                 `CPU_TOP_PATH.nm_top_si_10
`define CPU_nm_top_si_11                 `CPU_TOP_PATH.nm_top_si_11
`define CPU_nm_top_si_12                 `CPU_TOP_PATH.nm_top_si_12
`define CPU_nm_top_so_1                  `CPU_TOP_PATH.nm_top_so_1
`define CPU_nm_top_so_2                  `CPU_TOP_PATH.nm_top_so_2
`define CPU_nm_top_so_3                  `CPU_TOP_PATH.nm_top_so_3
`define CPU_nm_top_so_4                  `CPU_TOP_PATH.nm_top_so_4
`define CPU_nm_top_so_5                  `CPU_TOP_PATH.nm_top_so_5
`define CPU_nm_top_so_6                  `CPU_TOP_PATH.nm_top_so_6
`define CPU_nm_top_so_7                  `CPU_TOP_PATH.nm_top_so_7
`define CPU_nm_top_so_8                  `CPU_TOP_PATH.nm_top_so_8
`define CPU_nm_top_so_9                  `CPU_TOP_PATH.nm_top_so_9
`define CPU_nm_top_so_10                 `CPU_TOP_PATH.nm_top_so_10
`define CPU_nm_top_so_11                 `CPU_TOP_PATH.nm_top_so_11
`define CPU_nm_top_so_12                 `CPU_TOP_PATH.nm_top_so_12
`endif
//CPU observed signal
`define CPU_iu_pad_gpr_data             `CPU_TOP_PATH.iu_pad_gpr_data[31:0]
`define CPU_iu_pad_gpr_index            `CPU_TOP_PATH.iu_pad_gpr_index[4:0] 
`define CPU_iu_pad_gpr_we               `CPU_TOP_PATH.iu_pad_gpr_we
`define CPU_iu_pad_inst_retire          `CPU_TOP_PATH.iu_pad_inst_retire
`define CPU_iu_pad_inst_split           `CPU_TOP_PATH.iu_pad_inst_split
`define CPU_iu_pad_retire_pc            `CPU_TOP_PATH.iu_pad_retire_pc[31:0]
`define CPU_cp0_pad_psr                  `CPU_TOP_PATH.cp0_pad_psr[31:0]
//lowpower signal
`define CPU_sysio_pad_ipend_b            `CPU_TOP_PATH.biu_pad_ipend_b
`define CPU_sysio_pad_lpmd_b             `CPU_TOP_PATH.biu_pad_lpmd_b[1:0] 
`define CPU_sysio_pad_wakeup_b           `CPU_TOP_PATH.biu_pad_wakeup_b
//debug and jtag signal list
`ifdef HAD_JTAG_2
`define CPU_had_pad_jdb_pm               `CPU_TOP_PATH.had_pad_jdb_pm      
`define CPU_had_pad_jtg_tap_on           `CPU_TOP_PATH.had_pad_jtg_tap_on        
`define CPU_pad_had_jdb_req_b            `CPU_TOP_PATH.pad_had_jdb_req_b         
`define CPU_pad_had_jtg_tap_en           `CPU_TOP_PATH.pad_had_jtg_tap_en         
`define CPU_pad_had_jtg_tclk             `CPU_TOP_PATH.pad_had_jtg_tclk         
`define CPU_pad_had_jtg_tms_i            `CPU_TOP_PATH.pad_had_jtg_tms_i         
`define CPU_had_pad_jtg_tms_o            `CPU_TOP_PATH.had_pad_jtg_tms_o         
`define CPU_had_pad_jtg_tms_oe           `CPU_TOP_PATH.had_pad_jtg_tms_oe         
`define CPU_pad_had_jtg_trst_b           `CPU_TOP_PATH.pad_had_jtg_trst_b         
`define CPU_sysio_pad_dbg_b              `CPU_TOP_PATH.sysio_pad_dbg_b       
`endif
//VIC signal list
`ifdef VIC
`else
`define CPU_pad_cpu_avec_b               `CPU_TOP_PATH.top_cpu_avec_b
`define CPU_pad_cpu_fint_b               `CPU_TOP_PATH.pad_cpu_fint_b
`define CPU_pad_cpu_fintraw_b            `CPU_TOP_PATH.pad_cpu_fintraw_b
`define CPU_pad_cpu_int_b                `CPU_TOP_PATH.pad_cpu_int_b
`define CPU_pad_cpu_intraw_b             `CPU_TOP_PATH.pad_cpu_intraw_b
`define CPU_pad_cpu_vec_b                `CPU_TOP_PATH.pad_cpu_vec_b
`endif
`ifdef VIC
 `ifdef INT_NUM_1
 `define CPU_pad_vic_int_cfg             `CPU_TOP_PATH.pad_vic_int_cfg
 `define CPU_pad_vic_int_vld             `CPU_TOP_PATH.pad_vic_int_vld
 `endif
 `ifdef INT_NUM_2
 `define CPU_pad_vic_int_cfg             `CPU_TOP_PATH.pad_vic_int_cfg[1:0]
 `define CPU_pad_vic_int_vld             `CPU_TOP_PATH.pad_vic_int_vld[1:0] 
 `endif
 `ifdef INT_NUM_4
 `define CPU_pad_vic_int_cfg             `CPU_TOP_PATH.pad_vic_int_cfg[3:0]
 `define CPU_pad_vic_int_vld             `CPU_TOP_PATH.pad_vic_int_vld[3:0]
 `endif
 `ifdef VIC_IPR1
 `define CPU_pad_vic_int_cfg             `CPU_TOP_PATH.pad_vic_int_cfg[7:0]
 `define CPU_pad_vic_int_vld             `CPU_TOP_PATH.pad_vic_int_vld[7:0]
 `endif
 `ifdef VIC_IPR3
 `define CPU_pad_vic_int_cfg             `CPU_TOP_PATH.pad_vic_int_cfg[15:0]
 `define CPU_pad_vic_int_vld             `CPU_TOP_PATH.pad_vic_int_vld[15:0]
 `endif
 `ifdef VIC_IPR5
 `define CPU_pad_vic_int_cfg             `CPU_TOP_PATH.pad_vic_int_cfg[23:0]
 `define CPU_pad_vic_int_vld             `CPU_TOP_PATH.pad_vic_int_vld[23:0]
 `endif
 `ifdef VIC_IPR7
 `define CPU_pad_vic_int_cfg             `CPU_TOP_PATH.pad_vic_int_cfg[31:0]
 `define CPU_pad_vic_int_vld             `CPU_TOP_PATH.pad_vic_int_vld[31:0]
 `endif
`endif



//********************************************************************************//
//                              MAIN TEST PROGRAM                                 //
//********************************************************************************//
//test signal define 
`define CLK                              `CPU_TOP_PATH.forever_cpuclk
//****************************BIU signal test begin  *****************************//
//biu_pad_haddr
initial
begin 
     @(posedge `CLK); 
     force `CPU_biu_pad_haddr = 32'b0;
     if(!(`biu_pad_haddr == 0))
    begin
     $display("Error:sorry, biu_pad_haddr conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_biu_pad_haddr = 32'hffffffff;
     if(!(`biu_pad_haddr == 32'hffffffff))
    begin
     $display("Error:sorry, biu_pad_haddr conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!biu_pad_haddr conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_biu_pad_haddr;
    end
end

//biu_pad_hburst
initial
begin      
     @(posedge `CLK); 
     force `CPU_biu_pad_hburst = 3'b0;
     if(!(`biu_pad_hburst == 0))
    begin
     $display("Error:sorry, biu_pad_hburst conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_biu_pad_hburst = 3'b111;
     if(!(`biu_pad_hburst == 3'b111))
    begin
     $display("Error:sorry, biu_pad_hburst conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!biu_pad_hburst conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_biu_pad_hburst;
    end
end
`ifdef SYS_AHB
//biu_pad_hbusreq
initial
begin      
     @(posedge `CLK); 
     force `CPU_biu_pad_hbusreq = 1'b0;
     if(!(`biu_pad_hbusreq == 0))
    begin
     $display("Error:sorry, biu_pad_hbusreq conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_biu_pad_hbusreq = 1'b1;
     if(!(`biu_pad_hbusreq == 1'b1))
    begin
     $display("Error:sorry, biu_pad_hbusreq conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!biu_pad_hbusreq conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_biu_pad_hbusreq;
    end
end
`endif

//biu_pad_hprot
initial
begin      
     @(posedge `CLK); 
     force `CPU_biu_pad_hprot = 4'b0;
     if(!(`biu_pad_hprot == 0))
    begin
     $display("Error:sorry,biu_pad_hprot conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_biu_pad_hprot = 4'b1111;
     if(!(`biu_pad_hprot == 4'b1111))
    begin
     $display("Error:sorry,biu_pad_hprot  conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!biu_pad_hprot conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_biu_pad_hprot;
    end    
end

//biu_pad_hsize
initial
begin      
     @(posedge `CLK); 
     force `CPU_biu_pad_hsize = 3'b0;
     if(!(`biu_pad_hsize == 0))
    begin
     $display("Error:sorry,biu_pad_hsize conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_biu_pad_hsize = 3'b111;
     if(!(`biu_pad_hsize == 3'b111))
    begin
     $display("Error:sorry,biu_pad_hsize  conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!biu_pad_hsize conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_biu_pad_hsize;
    end    
end

//biu_pad_htrans
initial
begin      
     @(posedge `CLK); 
     force `CPU_biu_pad_htrans = 2'b0;
     if(!(`biu_pad_htrans == 0))
    begin
     $display("Error:sorry,biu_pad_htrans conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_biu_pad_htrans = 2'b11;
     if(!(`biu_pad_htrans == 2'b11))
    begin
     $display("Error:sorry, biu_pad_htrans conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!biu_pad_htrans conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_biu_pad_htrans;
    end    
end

//biu_pad_hwdata
initial
begin 
     @(posedge `CLK); 
     force `CPU_biu_pad_hwdata = 32'b0;
     if(!(`biu_pad_hwdata == 0))
    begin
     $display("Error:sorry,biu_pad_hwdata  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_biu_pad_hwdata = 32'hffffffff;
     if(!(`biu_pad_hwdata == 32'hffffffff))
    begin
     $display("Error:sorry,biu_pad_hwdata  conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!biu_pad_hwdata conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_biu_pad_hwdata;
    end
end

//biu_pad_hwrite
initial
begin      
     @(posedge `CLK); 
     force `CPU_biu_pad_hwrite = 1'b0;
     if(!(`biu_pad_hwrite == 0))
    begin
     $display("Error:sorry,biu_pad_hwrite  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_biu_pad_hwrite = 1'b1;
     if(!(`biu_pad_hwrite == 1'b1))
    begin
     $display("Error:sorry,biu_pad_hwrite conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!biu_pad_hwrite conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_biu_pad_hwrite;
    end
end


//pad_biu_hready
initial
begin      
     @(posedge `CLK); 
     force `pad_biu_hready = 1'b0;
     if(!(`CPU_pad_biu_hready == 0))
    begin
     $display("Error:sorry,pad_biu_hready  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_biu_hready = 1'b1;
     if(!(`CPU_pad_biu_hready == 1'b1))
    begin
     $display("Error:sorry,pad_biu_hready conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_biu_hready conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_biu_hready;
    end
end

//pad_biu_hrdata
initial
begin      
     @(posedge `CLK); 
     force `pad_biu_hrdata = 32'h0;
     if(!(`CPU_pad_biu_hrdata == 0))
    begin
     $display("Error:sorry,pad_biu_hrdata  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_biu_hrdata = 32'hffffffff;
     if(!(`CPU_pad_biu_hrdata == 32'hffffffff))
    begin
     $display("Error:sorry,pad_biu_hrdata conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_biu_hrdata conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_biu_hrdata;
    end
end

//pad_biu_hresp
initial
begin      
     @(posedge `CLK); 
     force `pad_biu_hresp = 1'b0;
     if(!(`CPU_pad_biu_hresp == 0))
    begin
     $display("Error:sorry, pad_biu_hresp conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_biu_hresp = 1'b1;
     if(!(`CPU_pad_biu_hresp == 1'b1))
    begin
     $display("Error:sorry,pad_biu_hresp conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_biu_hresp conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_biu_hresp;
    end
end
////pad_biu_hsec
//`ifdef CSKY_TEE
//  initial
//begin
//  $display("the value of pad_biu_hsec is:%h",`CPU_pad_biu_hsec);
//end
//`endif
`ifdef SEU_DATA_PATH_POLARITY
  //pad_biu_hrdata_pol
initial
begin      
     @(posedge `CLK); 
     force `pad_biu_hrdata_pol = 32'b0;
     if(!(`CPU_pad_biu_hrdata_pol == 0))
    begin
     $display("Error:sorry,pad_biu_hrdata_pol  conect fail!,please check");
     $finish;
    end 
     force `pad_biu_hrdata_pol = 32'hffffffff;
     if(!(`CPU_pad_biu_hrdata_pol == 32'hffffffff))
    begin
     $display("Error:sorry,pad_biu_hrdata_pol conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_biu_hrdata_pol conect correctly!");
     release `pad_biu_hrdata_pol;
    end
end
//biu_pad_haddr_pol
initial
begin      
     @(posedge `CLK); 
     force `CPU_biu_pad_haddr_pol = 32'b0;
     if(!(`biu_pad_haddr_pol == 0))
    begin
     $display("Error:sorry,biu_pad_haddr_pol  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_biu_pad_haddr_pol = 32'hffffffff;
     if(!(`biu_pad_haddr_pol == 32'hffffffff))
    begin
     $display("Error:sorry,biu_pad_haddr_pol conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!biu_pad_haddr_pol conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_biu_pad_haddr_pol;
    end
end
//biu_pad_hwdata_pol
initial
begin      
     @(posedge `CLK); 
     force `CPU_biu_pad_hwdata_pol = 32'b0;
     if(!(`biu_pad_hwdata_pol == 0))
    begin
     $display("Error:sorry,biu_pad_hwdata_pol  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_biu_pad_hwdata_pol = 32'hffffffff;
     if(!(`biu_pad_hwdata_pol == 32'hffffffff))
    begin
     $display("Error:sorry,biu_pad_hwdata_pol conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!biu_pad_hwdata_pol conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_biu_pad_hwdata_pol;
    end
end
`endif
`ifdef SEU_BUS_PARITY
  //biu_pad_hwdata_par
initial
begin      
     @(posedge `CLK); 
     force `CPU_biu_pad_hwdata_par = 32'b0;
     if(!(`biu_pad_hwdata_par == 0))
    begin
     $display("Error:sorry,biu_pad_hwdata_par  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_biu_pad_hwdata_par = 32'hffffffff;
     if(!(`biu_pad_hwdata_par == 32'hffffffff))
    begin
     $display("Error:sorry,biu_pad_hwdata_par conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!biu_pad_hwdata_par conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_biu_pad_hwdata_par;
    end
end
//pad_biu_hrdata_par
initial
begin      
     @(posedge `CLK); 
     force `pad_biu_hrdata_par = 32'b0;
     if(!(`CPU_pad_biu_hrdata_par == 0))
    begin
     $display("Error:sorry,pad_biu_hrdata_par  conect fail!,please check");
     $finish;
    end 
     force `pad_biu_hrdata_par = 32'hffffffff;
     if(!(`CPU_pad_biu_hrdata_par == 32'hffffffff))
    begin
     $display("Error:sorry,pad_biu_hrdata_par conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_biu_hrdata_par conect correctly!");
     release `pad_biu_hrdata_par;
    end
end
`endif
//****************************BIU signal test end  *******************************//

//****************************ilite signal test begin  *******************************//
`ifdef IAHB_LITE
//iahbl_pad_haddr
initial
begin 
     @(posedge `CLK); 
     force `CPU_iahbl_pad_haddr = 32'b0;
     if(!(`iahbl_pad_haddr == 0))
    begin
     $display("Error:sorry, iahbl_pad_haddr conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iahbl_pad_haddr = 32'hffffffff;
     if(!(`iahbl_pad_haddr == 32'hffffffff))
    begin
     $display("Error:sorry, iahbl_pad_haddr conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iahbl_pad_haddr conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iahbl_pad_haddr;
    end
end

//iahbl_pad_hburst
initial
begin      
     @(posedge `CLK); 
     force `CPU_iahbl_pad_hburst = 3'b0;
     if(!(`iahbl_pad_hburst == 0))
    begin
     $display("Error:sorry, iahbl_pad_hburst conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iahbl_pad_hburst = 3'b111;
     if(!(`iahbl_pad_hburst == 3'b111))
    begin
     $display("Error:sorry, iahbl_pad_hburst conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iahbl_pad_hburst conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iahbl_pad_hburst;
    end
end

//iahbl_pad_hprot
initial
begin      
     @(posedge `CLK); 
     force `CPU_iahbl_pad_hprot = 4'b0;
     if(!(`iahbl_pad_hprot == 0))
    begin
     $display("Error:sorry,iahbl_pad_hprot conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iahbl_pad_hprot = 4'b1111;
     if(!(`iahbl_pad_hprot == 4'b1111))
    begin
     $display("Error:sorry,iahbl_pad_hprot  conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iahbl_pad_hprot conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iahbl_pad_hprot;
    end    
end

//iahbl_pad_hsize
initial
begin      
     @(posedge `CLK); 
     force `CPU_iahbl_pad_hsize = 3'b0;
     if(!(`iahbl_pad_hsize == 0))
    begin
     $display("Error:sorry,iahbl_pad_hsize conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iahbl_pad_hsize = 3'b111;
     if(!(`iahbl_pad_hsize == 3'b111))
    begin
     $display("Error:sorry,iahbl_pad_hsize  conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iahbl_pad_hsize conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iahbl_pad_hsize;
    end    
end

//iahbl_pad_htrans
initial
begin      
     @(posedge `CLK); 
     force `CPU_iahbl_pad_htrans = 2'b0;
     if(!(`iahbl_pad_htrans == 0))
    begin
     $display("Error:sorry,iahbl_pad_htrans conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iahbl_pad_htrans = 2'b11;
     if(!(`iahbl_pad_htrans == 2'b11))
    begin
     $display("Error:sorry, iahbl_pad_htrans conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iahbl_pad_htrans conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iahbl_pad_htrans;
    end    
end

//iahbl_pad_hwdata
initial
begin 
     @(posedge `CLK); 
     force `CPU_iahbl_pad_hwdata = 32'b0;
     if(!(`iahbl_pad_hwdata == 0))
    begin
     $display("Error:sorry,iahbl_pad_hwdata  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iahbl_pad_hwdata = 32'hffffffff;
     if(!(`iahbl_pad_hwdata == 32'hffffffff))
    begin
     $display("Error:sorry,iahbl_pad_hwdata  conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iahbl_pad_hwdata conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iahbl_pad_hwdata;
    end
end

//iahbl_pad_hwrite
initial
begin      
     @(posedge `CLK); 
     force `CPU_iahbl_pad_hwrite = 1'b0;
     if(!(`iahbl_pad_hwrite == 0))
    begin
     $display("Error:sorry,iahbl_pad_hwrite  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iahbl_pad_hwrite = 1'b1;
     if(!(`iahbl_pad_hwrite == 1'b1))
    begin
     $display("Error:sorry,iahbl_pad_hwrite conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iahbl_pad_hwrite conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iahbl_pad_hwrite;
    end
end

//pad_iahbl_hready
initial
begin      
     @(posedge `CLK); 
     force `pad_iahbl_hready = 1'b0;
     if(!(`CPU_pad_iahbl_hready == 0))
    begin
     $display("Error:sorry,pad_iahbl_hready  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_iahbl_hready = 1'b1;
     if(!(`CPU_pad_iahbl_hready == 1'b1))
    begin
     $display("Error:sorry,pad_iahbl_hready conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_iahbl_hready conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_iahbl_hready;
    end
end

//pad_iahbl_hrdata
initial
begin      
     @(posedge `CLK); 
     force `pad_iahbl_hrdata = 32'h0;
     if(!(`CPU_pad_iahbl_hrdata == 0))
    begin
     $display("Error:sorry,pad_iahbl_hrdata  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_iahbl_hrdata = 32'hffffffff;
     if(!(`CPU_pad_iahbl_hrdata == 32'hffffffff))
    begin
     $display("Error:sorry,pad_iahbl_hrdata conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_iahbl_hrdata conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_iahbl_hrdata;
    end
end

//pad_iahbl_hresp
initial
begin      
     @(posedge `CLK); 
     force `pad_iahbl_hresp = 1'b0;
     if(!(`CPU_pad_iahbl_hresp == 0))
    begin
     $display("Error:sorry, pad_iahbl_hresp conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_iahbl_hresp = 1'b1;
     if(!(`CPU_pad_iahbl_hresp == 1'b1))
    begin
     $display("Error:sorry,pad_iahbl_hresp conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_iahbl_hresp conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_iahbl_hresp;
    end
end
//pad_bmu_iahbl_base
initial
begin
  $display("the value of pad_bmu_iahbl_base is:%h",`CPU_pad_bmu_iahbl_base);
end
//pad_bmu_iahbl_mask
initial
begin
  $display("the value of pad_bmu_iahbl_mask is:%h",`CPU_pad_bmu_iahbl_mask);
end
//pad_iahbl_hsec
`ifdef CSKY_TEE
initial
begin
$display("the value of pad_iahbl_hsec is:%h",`CPU_pad_iahbl_hsec);
end
`endif
`endif
//****************************ilite signal test end    *******************************//

//****************************dlite signal test end    *******************************//
`ifdef DAHB_LITE
//dahbl_pad_haddr
initial
begin 
     @(posedge `CLK); 
     force `CPU_dahbl_pad_haddr = 32'b0;
     if(!(`dahbl_pad_haddr == 0))
    begin
     $display("Error:sorry, dahbl_pad_haddr conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_dahbl_pad_haddr = 32'hffffffff;
     if(!(`dahbl_pad_haddr == 32'hffffffff))
    begin
     $display("Error:sorry, dahbl_pad_haddr conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!dahbl_pad_haddr conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_dahbl_pad_haddr;
    end
end

//dahbl_pad_hburst
initial
begin      
     @(posedge `CLK); 
     force `CPU_dahbl_pad_hburst = 3'b0;
     if(!(`dahbl_pad_hburst == 0))
    begin
     $display("Error:sorry, dahbl_pad_hburst conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_dahbl_pad_hburst = 3'b111;
     if(!(`dahbl_pad_hburst == 3'b111))
    begin
     $display("Error:sorry, dahbl_pad_hburst conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!dahbl_pad_hburst conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_dahbl_pad_hburst;
    end
end

//dahbl_pad_hprot
initial
begin      
     @(posedge `CLK); 
     force `CPU_dahbl_pad_hprot = 4'b0;
     if(!(`dahbl_pad_hprot == 0))
    begin
     $display("Error:sorry,dahbl_pad_hprot conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_dahbl_pad_hprot = 4'b1111;
     if(!(`dahbl_pad_hprot == 4'b1111))
    begin
     $display("Error:sorry,dahbl_pad_hprot  conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!dahbl_pad_hprot conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_dahbl_pad_hprot;
    end    
end

//dahbl_pad_hsize
initial
begin      
     @(posedge `CLK); 
     force `CPU_dahbl_pad_hsize = 3'b0;
     if(!(`dahbl_pad_hsize == 0))
    begin
     $display("Error:sorry,dahbl_pad_hsize conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_dahbl_pad_hsize = 3'b111;
     if(!(`dahbl_pad_hsize == 3'b111))
    begin
     $display("Error:sorry,dahbl_pad_hsize  conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!dahbl_pad_hsize conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_dahbl_pad_hsize;
    end    
end

//dahbl_pad_htrans
initial
begin      
     @(posedge `CLK); 
     force `CPU_dahbl_pad_htrans = 2'b0;
     if(!(`dahbl_pad_htrans == 0))
    begin
     $display("Error:sorry,dahbl_pad_htrans conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_dahbl_pad_htrans = 2'b11;
     if(!(`dahbl_pad_htrans == 2'b11))
    begin
     $display("Error:sorry, dahbl_pad_htrans conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!dahbl_pad_htrans conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_dahbl_pad_htrans;
    end    
end

//dahbl_pad_hwdata
initial
begin 
     @(posedge `CLK); 
     force `CPU_dahbl_pad_hwdata = 32'b0;
     if(!(`dahbl_pad_hwdata == 0))
    begin
     $display("Error:sorry,dahbl_pad_hwdata  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_dahbl_pad_hwdata = 32'hffffffff;
     if(!(`dahbl_pad_hwdata == 32'hffffffff))
    begin
     $display("Error:sorry,dahbl_pad_hwdata  conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!dahbl_pad_hwdata conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_dahbl_pad_hwdata;
    end
end

//dahbl_pad_hwrite
initial
begin      
     @(posedge `CLK); 
     force `CPU_dahbl_pad_hwrite = 1'b0;
     if(!(`dahbl_pad_hwrite == 0))
    begin
     $display("Error:sorry,dahbl_pad_hwrite  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_dahbl_pad_hwrite = 1'b1;
     if(!(`dahbl_pad_hwrite == 1'b1))
    begin
     $display("Error:sorry,dahbl_pad_hwrite conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!dahbl_pad_hwrite conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_dahbl_pad_hwrite;
    end
end

//pad_dahbl_hready
initial
begin      
     @(posedge `CLK); 
     force `pad_dahbl_hready = 1'b0;
     if(!(`CPU_pad_dahbl_hready == 0))
    begin
     $display("Error:sorry,pad_dahbl_hready  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_dahbl_hready = 1'b1;
     if(!(`CPU_pad_dahbl_hready == 1'b1))
    begin
     $display("Error:sorry,pad_dahbl_hready conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_dahbl_hready conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_dahbl_hready;
    end
end

//pad_dahbl_hrdata
initial
begin      
     @(posedge `CLK); 
     force `pad_dahbl_hrdata = 32'h0;
     if(!(`CPU_pad_dahbl_hrdata == 0))
    begin
     $display("Error:sorry,pad_dahbl_hrdata  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_dahbl_hrdata = 32'hffffffff;
     if(!(`CPU_pad_dahbl_hrdata == 32'hffffffff))
    begin
     $display("Error:sorry,pad_dahbl_hrdata conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_dahbl_hrdata conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_dahbl_hrdata;
    end
end

//pad_dahbl_hresp
initial
begin      
     @(posedge `CLK); 
     force `pad_dahbl_hresp = 1'b0;
     if(!(`CPU_pad_dahbl_hresp == 0))
    begin
     $display("Error:sorry, pad_dahbl_hresp conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_dahbl_hresp = 1'b1;
     if(!(`CPU_pad_dahbl_hresp == 1'b1))
    begin
     $display("Error:sorry,pad_dahbl_hresp conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_dahbl_hresp conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_dahbl_hresp;
    end
end
//pad_bmu_dahbl_base
initial
begin
  $display("the value of pad_bmu_dahbl_base is:%h",`CPU_pad_bmu_dahbl_base);
end
//pad_bmu_dahbl_mask
initial
begin
  $display("the value of pad_bmu_dahbl_mask is:%h",`CPU_pad_bmu_dahbl_mask);
end
//pad_dahbl_hsec
`ifdef CSKY_TEE
initial
begin
  $display("the value of pad_dahbl_hsec is:%h",`CPU_pad_dahbl_hsec);
end

`endif
`endif
//****************************dlite signal test end    ***************************//

//****************************coretimer signal test begin***************************//
`ifdef CTIM
initial
begin
//pad_ctim_calib
$display("the value of pad_ctim_calib is:%h",`CPU_pad_ctim_calib);
//pad_ctim_refclk
$display("the value of pad_ctim_refclk is:%h",`CPU_pad_ctim_refclk);
end
//ctim_pad_int_vld
initial
begin      
     @(posedge `CLK); 
     force `CPU_ctim_pad_int_vld = 1'b0;
     if(!(`ctim_pad_int_vld == 0))
    begin
     $display("Error:sorry,ctim_pad_int_vld  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_ctim_pad_int_vld = 1'b1;
     if(!(`ctim_pad_int_vld == 1'b1))
    begin
     $display("Error:sorry,ctim_pad_int_vld conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!ctim_pad_int_vld conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_ctim_pad_int_vld;
    end
end
`endif
//****************************coretimer signal test end*************************//

//****************************clock and control signal test begin*****************//
//pad_sysio_endian_v2
initial
begin
  $display("the value of pad_sysio_endian_v2 is:%h",`CPU_pad_sysio_endian_v2);
end
`ifdef TWO_CLK
//pll_core_cpuclk_nogated
initial
begin      
     @(posedge `CLK); 
     force `pll_core_cpuclk_nogated = 1'b0;
     if(!(`CPU_pll_core_cpuclk_nogated == 0))
    begin
     $display("Error:sorry,pll_core_cpuclk_nogated  conect fail!,please check");
     $finish;
    end 
     force `pll_core_cpuclk_nogated = 1'b1;
     if(!(`CPU_pll_core_cpuclk_nogated == 1'b1))
    begin
     $display("Error:sorry,pll_core_cpuclk_nogated conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pll_core_cpuclk_nogated conect correctly!");
     release `pll_core_cpuclk_nogated;
    end
end
`endif
//pll_core_cpuclk
initial
begin      
     @(posedge `CLK); 
     force `pll_core_cpuclk = 1'b0;
     if(!(`CPU_pll_core_cpuclk == 0))
    begin
     $display("Error:sorry,pll_core_cpuclk  conect fail!,please check");
     $finish;
    end 
     force `pll_core_cpuclk = 1'b1;
     if(!(`CPU_pll_core_cpuclk == 1'b1))
    begin
     $display("Error:sorry,pll_core_cpuclk conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pll_core_cpuclk conect correctly!");
     release `pll_core_cpuclk;
    end
end
//clk_en
initial
begin      
     @(posedge `CLK); 
     force `clk_en = 1'b0;
     if(!(`CPU_clk_en == 0))
    begin
     $display("Error:sorry,clk_en  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `clk_en = 1'b1;
     if(!(`CPU_clk_en == 1'b1))
    begin
     $display("Error:sorry,clk_en conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!clk_en conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `clk_en;
    end
end
//pad_sysio_bigend_b
initial
begin      
     @(posedge `CLK); 
     force `pad_sysio_bigend_b = 1'b0;
     if(!(`CPU_pad_sysio_bigend_b == 0))
    begin
     $display("Error:sorry,pad_sysio_bigend_b  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_sysio_bigend_b = 1'b1;
     if(!(`CPU_pad_sysio_bigend_b == 1'b1))
    begin
     $display("Error:sorry,pad_sysio_bigend_b conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_sysio_bigend_b conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_sysio_bigend_b;
    end
end
//pad_cpu_rst_b
initial
begin      
     @(posedge `CLK); 
     force `pad_cpu_rst_b = 1'b0;
     if(!(`CPU_pad_cpu_rst_b == 0))
    begin
     $display("Error:sorry,pad_cpu_rst_b  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_cpu_rst_b = 1'b1;
     if(!(`CPU_pad_cpu_rst_b == 1'b1))
    begin
     $display("Error:sorry,pad_cpu_rst_b conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_cpu_rst_b conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_cpu_rst_b;
    end
end
//pad_sysio_clkratio
initial
begin      
     @(posedge `CLK); 
     force `pad_sysio_clkratio = 2'b0;
     if(!(`CPU_pad_sysio_clkratio == 0))
    begin
     $display("Error:sorry,pad_sysio_clkratio  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_sysio_clkratio = 2'b11;
     if(!(`CPU_pad_sysio_clkratio == 2'b11))
    begin
     $display("Error:sorry,pad_sysio_clkratio conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_sysio_clkratio conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_sysio_clkratio;
    end
end
//sysio_pad_srst
initial
begin      
     @(posedge `CLK); 
     force `CPU_sysio_pad_srst = 1'b0;
     if(!(`sysio_pad_srst == 0))
    begin
     $display("Error:sorry,sysio_pad_srst  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_sysio_pad_srst = 1'b1;
     if(!(`sysio_pad_srst == 1'b1))
    begin
     $display("Error:sorry,sysio_pad_srst conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!sysio_pad_srst conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_sysio_pad_srst;
    end
end
//****************************clock and control signal test end  *****************//

//****************************DFT signal test begin  *****************//
//pad_yy_test_mode
initial
begin      
     @(posedge `CLK); 
     force `pad_yy_test_mode = 1'b0;
     if(!(`CPU_pad_yy_test_mode == 0))
    begin
     $display("Error:sorry,pad_yy_test_mode  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_yy_test_mode = 1'b1;
     if(!(`CPU_pad_yy_test_mode == 1'b1))
    begin
     $display("Error:sorry,pad_yy_test_mode conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_yy_test_mode conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_yy_test_mode;
    end
end


//pad_yy_bist_tst_en
`ifdef ICACHE
initial
begin      
     @(posedge `CLK); 
     force `pad_yy_bist_tst_en = 1'b0;
     if(!(`CPU_pad_yy_bist_tst_en == 0))
    begin
     $display("Error:sorry,pad_yy_bist_tst_en  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_yy_bist_tst_en = 1'b1;
     if(!(`CPU_pad_yy_bist_tst_en == 1'b1))
    begin
     $display("Error:sorry,pad_yy_bist_tst_en conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_yy_bist_tst_en conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_yy_bist_tst_en;
    end
end
`endif
//pad_yy_gate_clk_en_b
initial
begin      
     @(posedge `CLK); 
     force `pad_yy_gate_clk_en_b = 1'b0;
     if(!(`CPU_pad_yy_gate_clk_en_b == 0))
    begin
     $display("Error:sorry,pad_yy_gate_clk_en_b  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_yy_gate_clk_en_b = 1'b1;
     if(!(`CPU_pad_yy_gate_clk_en_b == 1'b1))
    begin
     $display("Error:sorry,pad_yy_gate_clk_en_b conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_yy_gate_clk_en_b conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_yy_gate_clk_en_b;
    end
end
`ifdef SCAN_CHAIN_4
  //pad_yy_scan_enable
initial
begin      
     @(posedge `CLK); 
     force `pad_yy_scan_enable = 1'b0;
     if(!(`CPU_pad_yy_scan_enable == 0))
    begin
     $display("Error:sorry,pad_yy_scan_enable  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_yy_scan_enable = 1'b1;
     if(!(`CPU_pad_yy_scan_enable == 1'b1))
    begin
     $display("Error:sorry,pad_yy_scan_enable conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_yy_scan_enable conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_yy_scan_enable;
    end
end
//nm_top_si_1
initial
begin      
     @(posedge `CLK); 
     force `nm_top_si_1 = 1'b0;
     if(!(`CPU_nm_top_si_1 == 0))
    begin
     $display("Error:sorry,nm_top_si_1  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `nm_top_si_1 = 1'b1;
     if(!(`CPU_nm_top_si_1 == 1'b1))
    begin
     $display("Error:sorry,nm_top_si_1 conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!nm_top_si_1 conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `nm_top_si_1;
    end
end
//nm_top_si_2
initial
begin      
     @(posedge `CLK); 
     force `nm_top_si_2 = 1'b0;
     if(!(`CPU_nm_top_si_2 == 0))
    begin
     $display("Error:sorry,nm_top_si_2  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `nm_top_si_2 = 1'b1;
     if(!(`CPU_nm_top_si_2 == 1'b1))
    begin
     $display("Error:sorry,nm_top_si_2 conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!nm_top_si_2 conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `nm_top_si_2;
    end
end
//nm_top_si_3
initial
begin      
     @(posedge `CLK); 
     force `nm_top_si_3 = 1'b0;
     if(!(`CPU_nm_top_si_3 == 0))
    begin
     $display("Error:sorry,nm_top_si_3  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `nm_top_si_3 = 1'b1;
     if(!(`CPU_nm_top_si_3 == 1'b1))
    begin
     $display("Error:sorry,nm_top_si_3 conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!nm_top_si_3 conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `nm_top_si_3;
    end
end
//nm_top_si_4
initial
begin      
     @(posedge `CLK); 
     force `nm_top_si_4 = 1'b0;
     if(!(`CPU_nm_top_si_4 == 0))
    begin
     $display("Error:sorry,nm_top_si_4  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `nm_top_si_4 = 1'b1;
     if(!(`CPU_nm_top_si_4 == 1'b1))
    begin
     $display("Error:sorry,nm_top_si_4 conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!nm_top_si_4 conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `nm_top_si_4;
    end
end
//nm_top_so_1
initial
begin      
     @(posedge `CLK); 
     force `CPU_nm_top_so_1 = 1'b0;
     if(!(`nm_top_so_1 == 0))
    begin
     $display("Error:sorry,nm_top_so_1  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_nm_top_so_1 = 1'b1;
     if(!(`nm_top_so_1 == 1'b1))
    begin
     $display("Error:sorry,nm_top_so_1 conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!nm_top_so_1 conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_nm_top_so_1;
    end
end
//nm_top_so_2
initial
begin      
     @(posedge `CLK); 
     force `CPU_nm_top_so_2 = 1'b0;
     if(!(`nm_top_so_2 == 0))
    begin
     $display("Error:sorry,nm_top_so_2  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_nm_top_so_2 = 1'b1;
     if(!(`nm_top_so_2 == 1'b1))
    begin
     $display("Error:sorry,nm_top_so_2 conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!nm_top_so_2 conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_nm_top_so_2;
    end
end
//nm_top_so_3
initial
begin      
     @(posedge `CLK); 
     force `CPU_nm_top_so_3 = 1'b0;
     if(!(`nm_top_so_3 == 0))
    begin
     $display("Error:sorry,nm_top_so_3  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_nm_top_so_3 = 1'b1;
     if(!(`nm_top_so_3 == 1'b1))
    begin
     $display("Error:sorry,nm_top_so_3 conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!nm_top_so_3 conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_nm_top_so_3;
    end
end
//nm_top_so_4
initial
begin      
     @(posedge `CLK); 
     force `CPU_nm_top_so_4 = 1'b0;
     if(!(`nm_top_so_4 == 0))
    begin
     $display("Error:sorry,nm_top_so_4  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_nm_top_so_4 = 1'b1;
     if(!(`nm_top_so_4 == 1'b1))
    begin
     $display("Error:sorry,nm_top_so_4 conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!nm_top_so_4 conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_nm_top_so_4;
    end
end
`endif
//****************************DFT signal test end  *****************//

//****************************DSP signal test end  *****************//
`ifdef DSP
//iu_pad_gpr_data_1
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_data_1 = 32'h0;
     if(!(`iu_pad_gpr_data_1 == 0))
    begin
     $display("Error:sorry,iu_pad_gpr_data_1  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_data_1 = 32'hffffffff;
     if(!(`iu_pad_gpr_data_1 == 32'hffffffff))
    begin
     $display("Error:sorry,iu_pad_gpr_data_1 conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_gpr_data_1 conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_gpr_data_1;
    end
end
//iu_pad_gpr_index_1
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_index_1 = 5'b0;
     if(!(`iu_pad_gpr_index_1 == 0))
    begin
     $display("Error:sorry,iu_pad_gpr_index_1  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_index_1 = 5'b11111;
     if(!(`iu_pad_gpr_index_1 == 5'b11111))
    begin
     $display("Error:sorry,iu_pad_gpr_index_1 conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_gpr_index_1 conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_gpr_index_1;
    end
end
//iu_pad_gpr_we_1
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_we_1 = 1'b0;
     if(!(`iu_pad_gpr_we_1 == 0))
    begin
     $display("Error:sorry,iu_pad_gpr_we_1  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_we_1 = 1'b1;
     if(!(`iu_pad_gpr_we_1 == 1'b1))
    begin
     $display("Error:sorry,iu_pad_gpr_we_1 conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_gpr_we_1 conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_gpr_we_1;
    end
end
`endif
//****************************DSP signal test end  *****************//

//****************************FPU signal test end  *****************//
`ifdef FPU
//iu_pad_fesr
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_fesr = 32'b0;
     if(!(`iu_pad_fesr == 0))
    begin
     $display("Error:sorry,iu_pad_fesr  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_fesr = 32'hffffffff;
     if(!(`iu_pad_fesr == 32'hffffffff))
    begin
     $display("Error:sorry,iu_pad_fesr conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_fesr conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_fesr;
    end
end
//iu_pad_fpr_data
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_fpr_data = 32'b0;
     if(!(`iu_pad_fpr_data == 0))
    begin
     $display("Error:sorry,iu_pad_fpr_data  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_fpr_data = 32'hffffffff;
     if(!(`iu_pad_fpr_data == 32'hffffffff))
    begin
     $display("Error:sorry,iu_pad_fpr_data conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_fpr_data conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_fpr_data;
    end
end
//iu_pad_fpr_index
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_fpr_index = 4'b0;
     if(!(`iu_pad_fpr_index == 0))
    begin
     $display("Error:sorry,iu_pad_fpr_index  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_fpr_index = 4'b1111;
     if(!(`iu_pad_fpr_index == 4'b1111))
    begin
     $display("Error:sorry,iu_pad_fpr_index conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_fpr_index conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_fpr_index;
    end
end
//iu_pad_fpr_we
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_fpr_we = 1'b0;
     if(!(`iu_pad_fpr_we == 0))
    begin
     $display("Error:sorry,iu_pad_fpr_we  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_fpr_we = 1'b1;
     if(!(`iu_pad_fpr_we == 1'b1))
    begin
     $display("Error:sorry,iu_pad_fpr_we conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_fpr_we conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_fpr_we;
    end
end
`endif
//****************************FPU signal test end  *****************//

//****************************CPU observed signal test begin  *****************//
//iu_pad_gpr_data
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_data = 32'b0;
     if(!(`iu_pad_gpr_data == 0))
    begin
     $display("Error:sorry,iu_pad_gpr_data  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_data = 32'hffffffff;
     if(!(`iu_pad_gpr_data == 32'hffffffff))
    begin
     $display("Error:sorry,iu_pad_gpr_data conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_gpr_data conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_gpr_data;
    end
end
//iu_pad_gpr_index
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_index = 5'b0;
     if(!(`iu_pad_gpr_index == 0))
    begin
     $display("Error:sorry,iu_pad_gpr_index  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_index = 5'b11111;
     if(!(`iu_pad_gpr_index == 5'b11111))
    begin
     $display("Error:sorry,iu_pad_gpr_index conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_gpr_index conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_gpr_index;
    end
end
//iu_pad_gpr_we
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_we = 1'b0;
     if(!(`iu_pad_gpr_we == 0))
    begin
     $display("Error:sorry,iu_pad_gpr_we  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_gpr_we = 1'b1;
     if(!(`iu_pad_gpr_we == 1'b1))
    begin
     $display("Error:sorry,iu_pad_gpr_we conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_gpr_we conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_gpr_we;
    end
end
//iu_pad_inst_retire
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_inst_retire = 1'b0;
     if(!(`iu_pad_inst_retire == 0))
    begin
     $display("Error:sorry,iu_pad_inst_retire  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_inst_retire = 1'b1;
     if(!(`iu_pad_inst_retire == 1'b1))
    begin
     $display("Error:sorry,iu_pad_inst_retire conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_inst_retire conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_inst_retire;
    end
end
//iu_pad_inst_split
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_inst_split = 1'b0;
     if(!(`iu_pad_inst_split == 0))
    begin
     $display("Error:sorry,iu_pad_inst_split  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_inst_split = 1'b1;
     if(!(`iu_pad_inst_split == 1'b1))
    begin
     $display("Error:sorry,iu_pad_inst_split conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_inst_split conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_inst_split;
    end
end
//iu_pad_retire_pc
initial
begin      
     @(posedge `CLK); 
     force `CPU_iu_pad_retire_pc = 32'b0;
     if(!(`iu_pad_retire_pc == 0))
    begin
     $display("Error:sorry,iu_pad_retire_pc  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_iu_pad_retire_pc = 32'hffffffff;
     if(!(`iu_pad_retire_pc == 32'hffffffff))
    begin
     $display("Error:sorry,iu_pad_retire_pc conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!iu_pad_retire_pc conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_iu_pad_retire_pc;
    end
end
//cp0_pad_psr
initial
begin      
     @(posedge `CLK); 
     force `CPU_cp0_pad_psr = 32'b0;
     if(!(`cp0_pad_psr == 0))
    begin
     $display("Error:sorry,cp0_pad_psr  conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `CPU_cp0_pad_psr = 32'hffffffff;
     if(!(`cp0_pad_psr == 32'hffffffff))
    begin
     $display("Error:sorry,cp0_pad_psr conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!cp0_pad_psr conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `CPU_cp0_pad_psr;
    end
end
//****************************CPU observed signal test end  *****************//

//**************************** VIC signal test begin  *****************//
`ifdef VIC
`else
 //pad_cpu_avec_b
initial
begin      
     @(posedge `CLK); 
     force `pad_cpu_avec_b = 1'b0;
     if(!(`CPU_pad_cpu_avec_b == 0))
    begin
     $display("Error:sorry, pad_cpu_avec_b conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_cpu_avec_b = 1'b1;
     if(!(`CPU_pad_cpu_avec_b == 1'b1))
    begin
     $display("Error:sorry,pad_cpu_avec_b conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_cpu_avec_b conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_cpu_avec_b;
    end
end
 //pad_cpu_fint_b
initial
begin      
     @(posedge `CLK); 
     force `pad_cpu_fint_b = 1'b0;
     if(!(`CPU_pad_cpu_fint_b == 0))
    begin
     $display("Error:sorry, pad_cpu_fint_b conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_cpu_fint_b = 1'b1;
     if(!(`CPU_pad_cpu_fint_b == 1'b1))
    begin
     $display("Error:sorry,pad_cpu_fint_b conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_cpu_fint_b conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_cpu_fint_b;
    end
end
//pad_cpu_fintraw_b
initial
begin      
     @(posedge `CLK); 
     force `pad_cpu_fintraw_b = 1'b0;
     if(!(`CPU_pad_cpu_fintraw_b == 0))
    begin
     $display("Error:sorry, pad_cpu_fintraw_b conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_cpu_fintraw_b = 1'b1;
     if(!(`CPU_pad_cpu_fintraw_b == 1'b1))
    begin
     $display("Error:sorry,pad_cpu_fintraw_b conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_cpu_fintraw_b conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_cpu_fintraw_b;
    end
end
 //pad_cpu_int_b
initial
begin      
     @(posedge `CLK); 
     force `pad_cpu_int_b = 1'b0;
     if(!(`CPU_pad_cpu_int_b == 0))
    begin
     $display("Error:sorry, pad_cpu_int_b conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_cpu_int_b = 1'b1;
     if(!(`CPU_pad_cpu_int_b == 1'b1))
    begin
     $display("Error:sorry,pad_cpu_int_b conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_cpu_int_b conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_cpu_int_b;
    end
end
 //pad_cpu_intraw_b
initial
begin      
     @(posedge `CLK); 
     force `pad_cpu_intraw_b = 1'b0;
     if(!(`CPU_pad_cpu_intraw_b == 0))
    begin
     $display("Error:sorry, pad_cpu_intraw_b conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_cpu_intraw_b = 1'b1;
     if(!(`CPU_pad_cpu_intraw_b == 1'b1))
    begin
     $display("Error:sorry,pad_cpu_intraw_b conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_cpu_intraw_b conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_cpu_intraw_b;
    end
end
//pad_cpu_vec_b
initial
begin      
     @(posedge `CLK); 
     force `pad_cpu_vec_b = 1'b0;
     if(!(`CPU_pad_cpu_vec_b == 0))
    begin
     $display("Error:sorry, pad_cpu_vec_b conect fail!,please check");
     $finish;
    end
     @(posedge `CLK); 
     force `pad_cpu_vec_b = 1'b1;
     if(!(`CPU_pad_cpu_vec_b == 1'b1))
    begin
     $display("Error:sorry,pad_cpu_vec_b conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_cpu_vec_b conect correctly!");
     @(posedge `CLK);
     @(posedge `CLK);
     release `pad_cpu_vec_b;
    end
end
`endif
//`ifdef VIC
//  `ifdef INT_NUM_1
//    //pad_vic_int_cfg
//initial
//begin      
//     $display("the value of pad_vic_int_cfg is:%h",`CPU_pad_vic_int_cfg);
//end
//
// //pad_vic_int_vld
//initial
//begin      
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 1'b0;
//     if(!(`CPU_pad_vic_int_vld == 0))
//    begin
//     $display("Error:sorry, pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 1'b1;
//     if(!(`CPU_pad_vic_int_vld == 1'b1))
//    begin
//     $display("Error:sorry,pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     else 
//    begin
//     $display("Success!pad_vic_int_vld conect correctly!");
//     @(posedge `CLK);
//     @(posedge `CLK);
//     release `pad_vic_int_vld;
//    end
//end
//  `endif
//  `ifdef INT_NUM_2
//    //pad_vic_int_cfg
//initial
//begin      
//$display("the value of pad_vic_int_cfg is:%h",`CPU_pad_vic_int_cfg);
//end
//     //pad_vic_int_vld
//initial
//begin      
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 2'b0;
//     if(!(`CPU_pad_vic_int_vld == 0))
//    begin
//     $display("Error:sorry, pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 2'b11;
//     if(!(`CPU_pad_vic_int_vld == 2'b11))
//    begin
//     $display("Error:sorry,pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     else 
//    begin
//     $display("Success!pad_vic_int_vld conect correctly!");
//     @(posedge `CLK);
//     @(posedge `CLK);
//     release `pad_vic_int_vld;
//    end
//end
//  `endif
//  `ifdef INT_NUM_4
//    //pad_vic_int_cfg
//initial
//begin      
//   $display("the value of pad_vic_int_cfg is:%h",`CPU_pad_vic_int_cfg); 
//end
//    //pad_vic_int_vld
//initial
//begin      
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 4'b0;
//     if(!(`CPU_pad_vic_int_vld == 0))
//    begin
//     $display("Error:sorry, pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 4'b1111;
//     if(!(`CPU_pad_vic_int_vld == 4'b1111))
//    begin
//     $display("Error:sorry,pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     else 
//    begin
//     $display("Success!pad_vic_int_vld conect correctly!");
//     @(posedge `CLK);
//     @(posedge `CLK);
//     release `pad_vic_int_vld;
//    end
//end
//  `endif
 //  `ifdef VIC_IPR1
     //pad_vic_int_cfg
//initial
//begin      
//    $display("the value of pad_vic_int_cfg is:%h",`CPU_pad_vic_int_cfg);  
//end
     //pad_vic_int_vld
//initial
//begin      
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 8'b0;
//     if(!(`CPU_pad_vic_int_vld == 0))
//    begin
//     $display("Error:sorry, pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 8'hff;
//     if(!(`CPU_pad_vic_int_vld == 8'hff))
//    begin
//     $display("Error:sorry,pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     else 
//    begin
//     $display("Success!pad_vic_int_vld conect correctly!");
//     @(posedge `CLK);
//     @(posedge `CLK);
//     release `pad_vic_int_vld;
//    end
//end
//   `endif
//   `ifdef VIC_IPR3
//     //pad_vic_int_cfg
//initial
//begin      
//    $display("the value of pad_vic_int_cfg is:%h",`CPU_pad_vic_int_cfg); 
//end
//     //pad_vic_int_vld
//initial
//begin      
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 16'b0;
//     if(!(`CPU_pad_vic_int_vld == 0))
//    begin
//     $display("Error:sorry, pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 16'hffff;
//     if(!(`CPU_pad_vic_int_vld == 16'hffff))
//    begin
//     $display("Error:sorry,pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     else 
//    begin
//     $display("Success!pad_vic_int_vld conect correctly!");
//     @(posedge `CLK);
//     @(posedge `CLK);
//     release `pad_vic_int_vld;
//    end
//end
//   `endif
//    `ifdef VIC_IPR5
//      //pad_vic_int_cfg
//initial
//begin      
//    $display("the value of pad_vic_int_cfg is:%h",`CPU_pad_vic_int_cfg); 
//end
//      //pad_vic_int_vld
//initial
//begin      
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 24'b0;
//     if(!(`CPU_pad_vic_int_vld == 0))
//    begin
//     $display("Error:sorry, pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 24'hffffff;
//     if(!(`CPU_pad_vic_int_vld == 24'hffffff))
//    begin
//     $display("Error:sorry,pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     else 
//    begin
//     $display("Success!pad_vic_int_vld conect correctly!");
//     @(posedge `CLK);
//     @(posedge `CLK);
//     release `pad_vic_int_vld;
//    end
//end
//    `endif
//    `ifdef VIC_IPR7
// //pad_vic_int_cfg
//initial
//begin      
//      $display("the value of pad_vic_int_cfg is:%h",`CPU_pad_vic_int_cfg);
//end
// //pad_vic_int_vld
//initial
//begin      
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 32'b0;
//     if(!(`CPU_pad_vic_int_vld == 0))
//    begin
//     $display("Error:sorry, pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     @(posedge `CLK); 
//     force `pad_vic_int_vld = 32'hffffffff;
//     if(!(`CPU_pad_vic_int_vld == 32'hffffffff))
//    begin
//     $display("Error:sorry,pad_vic_int_vld conect fail!,please check");
//     $finish;
//    end
//     else 
//    begin
//     $display("Success!pad_vic_int_vld conect correctly!");
//     @(posedge `CLK);
//     @(posedge `CLK);
//     release `pad_vic_int_vld;
//    end
//end
//    `endif
//`endif
//**************************** VIC signal test end    *****************//

//**************************debug and jtag test begin*****************************//
`ifdef HAD_JTAG_2
reg [143:0] jtag_data_in  = 32'h8000;
reg [8:0]   jtag_data_len = 32;
reg [7:0]   ir_value      = 7'b0001101;//hcr
reg [31:0]  rst_cycle     = 100;
reg [143:0] jtag_data_out;
integer i;
reg  parity;
static integer FILE;
initial
begin
//reset jtag
force `pad_had_jtg_trst_b = 1'b1;
force `pad_had_jtg_tms_i = 1'b1;
  //wait until posedge tclk
  @(negedge `pad_had_jtg_tclk); 
  force `pad_had_jtg_trst_b = 1'b0;

  //wait for user specified cycles
  for(i=0; i<rst_cycle; i=i+1)
    @(negedge `pad_had_jtg_tclk);
  force `pad_had_jtg_trst_b = 1'b1;
  
  //drive TAP state machine into IDLE state
  @(negedge `pad_had_jtg_tclk);
  @(negedge `pad_had_jtg_tclk);
  if (1'b1)
    force `pad_had_jtg_tms_i = 1'b1;
  else
    force `pad_had_jtg_tms_i = 1'b0;

//set dr
//step1:write_ir hcr
    parity = 1'b1;
    @(negedge `pad_had_jtg_tclk); // start
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // read/write
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[0]
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[1]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk);
    for(i=0; i<8; i=i+1)begin
      force `pad_had_jtg_tms_i = ir_value[i];
      parity = parity ^ ir_value[i];
      @(negedge `pad_had_jtg_tclk); // Shift IR 
    end
    force `pad_had_jtg_tms_i = parity;
    @(negedge `pad_had_jtg_tclk); // Parity
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // IDLE

    //step2:write_Dr(32'h8000,32)
    parity = 1'b1;
    @(negedge `pad_had_jtg_tclk); // start
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // read/write
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[0]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // RS[1]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk);
    for(i=0; i<32; i=i+1)begin
      force `pad_had_jtg_tms_i = jtag_data_in[i];
      parity = parity ^ jtag_data_in[i];
      @(negedge `pad_had_jtg_tclk); // Shift DR 
    end
    force `pad_had_jtg_tms_i = parity; // Parity
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Drive to IDLE
    force `pad_had_jtg_tms_i = 1'b1;
    
//read hcr
//step 1     write_ir(hcr)
    parity = 1'b1;
    ir_value[7:0] =8'b10001101;
    @(negedge `pad_had_jtg_tclk); // start
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // read/write
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[0]
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[1]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk);
    for(i=0; i<8; i=i+1)begin
      force `pad_had_jtg_tms_i = ir_value[i];
      parity = parity ^ ir_value[i];
      @(negedge `pad_had_jtg_tclk); // Shift IR 
    end
    force `pad_had_jtg_tms_i = parity;
    @(negedge `pad_had_jtg_tclk); // Parity
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // IDLE
//step2 :read_dr
    jtag_data_out = 144'b0;
    parity = 1'b1;
    @(negedge `pad_had_jtg_tclk); // start
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // read/write
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // RS[0]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // RS[1]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;    
    @(posedge `pad_had_jtg_tclk);
    @(posedge `pad_had_jtg_tclk); // Sync cycle
//check had_pad_jtg_tms_oe    
    //had_pad_jtg_tms_oe
    if(!`had_pad_jtg_tms_oe)
    begin
     $display("Error:sorry, had_pad_jtg_tms_oe conect fail!,please check");
     $finish;
   end
    else 
    begin
     $display("Success!had_pad_jtg_tms_oe conect correctly!");
    end
//continue    
    for(i=0; i<32; i=i+1)begin
      @(posedge `pad_had_jtg_tclk); // Shift DR 
      jtag_data_out[i] = `had_pad_jtg_tms_o;
    end
    @(posedge `pad_had_jtg_tclk); // Parity
    parity = `had_pad_jtg_tms_o;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // to IDLE
    force `pad_had_jtg_tms_i = 1'b1;
//check
     if(!(jtag_data_out == 32'h8000))
    begin
     $display("Warning:sorry, pad_had_jtg_tclk   may not be conected correctly!,please check!");
     $display("Warning:sorry, pad_had_jtg_tms_i  may not be conected correctly!,please check!");
     $display("Warning:sorry, pad_had_jtg_trst_b may not be conected correctly!,please check!");
     $display("Warning:sorry, had_pad_jtg_tms_o  may not be conected correctly!,please check!");
     $finish;
    end
    else 
    begin
     $display("Success!pad_had_jtg_tclk   conect correctly");
     $display("Success!pad_had_jtg_tms_i  conect correctly");
     $display("Success!pad_had_jtg_trst_b conect correctly");
     $display("Success!had_pad_jtg_tms_o  conect correctly");
    end
     
//read pm
//step 1     write_ir(hsr)
    parity = 1'b1;
    ir_value[7:0] =8'b10001110;
    @(negedge `pad_had_jtg_tclk); // start
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // read/write
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[0]
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // RS[1]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk);
    for(i=0; i<8; i=i+1)begin
      force `pad_had_jtg_tms_i = ir_value[i];
      parity = parity ^ ir_value[i];
      @(negedge `pad_had_jtg_tclk); // Shift IR 
    end
    force `pad_had_jtg_tms_i = parity;
    @(negedge `pad_had_jtg_tclk); // Parity
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // IDLE
//step2 :read_dr
    jtag_data_out = 144'b0;
    parity = 1'b1;
    @(negedge `pad_had_jtg_tclk); // start
    force `pad_had_jtg_tms_i = 1'b0;
    @(negedge `pad_had_jtg_tclk); // read/write
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // RS[0]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // RS[1]
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(posedge `pad_had_jtg_tclk);
    @(posedge `pad_had_jtg_tclk); // Sync cycle
    for(i=0; i<32; i=i+1)begin
      @(posedge `pad_had_jtg_tclk); // Shift DR 
      jtag_data_out[i] = `had_pad_jtg_tms_o;
    end
    @(posedge `pad_had_jtg_tclk); // Parity
    parity = `had_pad_jtg_tms_o;
    @(negedge `pad_had_jtg_tclk); // Trn
    force `pad_had_jtg_tms_i = 1'b1;
    @(negedge `pad_had_jtg_tclk); // to IDLE
    force `pad_had_jtg_tms_i = 1'b1;    
    
    //had_pad_jdb_pm
    if(!(`had_pad_jdb_pm == 2'b10))
    begin
     $display("Error:sorry, had_pad_jdb_pm conect fail!,please check");
     $finish;     
   end
    else 
    begin
     $display("Success!had_pad_jdb_pm conect correctly!");
    end
    //had_pad_jtg_tap_on
    if(!`had_pad_jtg_tap_on)
    begin
     $display("Error:sorry, had_pad_jtg_tap_on conect fail!,please check");
     $finish;
    end
    else 
    begin
     $display("Success!had_pad_jtg_tap_on conect correctly!");
    end    
    //sysio_pad_dbg_b
    if(`sysio_pad_dbg_b)
    begin
     $display("Error:sorry,sysio_pad_dbg_b conect fail!,please check");
     $finish;
    end
    else 
    begin
     $display("Success!sysio_pad_dbg_b conect correctly!");
    end
//force toggle signal to check conection
//judgement    
     //pad_had_jtg_tap_en 
     @(posedge `pad_had_jtg_tclk); 
     force `pad_had_jtg_tap_en= 1'b1;
     if(!`CPU_pad_had_jtg_tap_en)
    begin
     $display("Error:sorry,  pad_had_jtg_tap_en conect fail!,please check");
     $finish;
    end
     @(posedge `pad_had_jtg_tclk); 
     force `pad_had_jtg_tap_en= 1'b0;
     if(`CPU_pad_had_jtg_tap_en)
    begin
     $display("Error:sorry, pad_had_jtg_tap_en  conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_had_jtg_tap_en conect correctly!");
     @(posedge `pad_had_jtg_tclk);
     @(posedge `pad_had_jtg_tclk);
     release `pad_had_jtg_tap_en;
    end
     //pad_had_jdb_req_b
    @(posedge `pad_had_jtg_tclk); 
     force `pad_had_jdb_req_b= 1'b1;
     if(!`CPU_pad_had_jdb_req_b)
    begin
     $display("Error:sorry, pad_had_jdb_req_b conect fail!,please check");
     $finish;
    end
     @(posedge `pad_had_jtg_tclk); 
     force `pad_had_jdb_req_b = 1'b0;
     if(`CPU_pad_had_jdb_req_b)
    begin
     $display("Error:sorry,   pad_had_jdb_req_b conect fail!,please check");
     $finish;
    end
     else 
    begin
     $display("Success!pad_had_jdb_req_b conect correctly!");
     $display("TEST PASS!");
     FILE = $fopen("run_case.report","w");
     $fdisplay(FILE,"TEST PASS");
     @(posedge `pad_had_jtg_tclk);
     @(posedge `pad_had_jtg_tclk);
     release `pad_had_jdb_req_b;
    $finish; 
    end
end
`endif
//*****************************debug and jtag signal test end****************************************
endmodule
