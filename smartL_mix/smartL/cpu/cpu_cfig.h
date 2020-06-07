























`define PRODUCT_ID 28'hF820CC8




`define RESET_VAL 16'hABCD




`define FPGA_MEM













`define SMIC













`define PROCESS55LL






























`define GPR_16




`define SEPARATE_STACK_POINTER




`define VEC_BASE





`define LOAD_FAST_RETIRE




`define EX_CBIT_FWD_TO_IF
`define WB_LOAD_FWD_TO_EX






`define MAD_FAST











`define UNALIGN_LOAD_STORE






`define IAHB_LITE


`ifdef IAHB_LITE
  //`define FLOP_OUT_IBUS
  //`define IBUS_16
  `define IBUS_32
`endif

`ifdef DAHB_LITE
  //`define FLOP_OUT_DBUS
  //`define DBUS_16
  `define DBUS_32
`endif





`define SYS_AHB_LITE






`define BIU_32




`ifdef FLOP_OUT_BIU
`define FLOP_OUT_BUS
`else
  `ifdef FLOP_OUT_IBUS
  `define FLOP_OUT_BUS
  `else
    `ifdef FLOP_OUT_DBUS
    `define FLOP_OUT_BUS
    `else
    `endif
  `endif
`endif





`define DFS //AHB_LITE  NON-FLOPOUT  



`ifdef IAHB_LITE
  //`define EXTERNAL_BMU
`endif




`define MGU

`ifdef MGU
  //`define MGU_REGION_2
  `define MGU_REGION_4
  //`define MGU_REGION_8
`endif

`ifdef MGU_REGION_2
  `define REGION_ENTRY0
  `define REGION_ENTRY1
  `define RID_BIT_1
`endif

`ifdef MGU_REGION_4
  `define REGION_ENTRY0
  `define REGION_ENTRY1
  `define REGION_ENTRY2
  `define REGION_ENTRY3
  `define RID_BIT_2
`endif

`ifdef MGU_REGION_8
  `define REGION_ENTRY0
  `define REGION_ENTRY1
  `define REGION_ENTRY2
  `define REGION_ENTRY3
  `define REGION_ENTRY4
  `define REGION_ENTRY5
  `define REGION_ENTRY6
  `define REGION_ENTRY7
  `define RID_BIT_3
`endif











`ifdef GCR
  //`define GCR8
  //`define GCR16
  `define GCR32
`endif

`ifdef GCR8
  `define GCR_BITS 8
`endif

`ifdef GCR16
  `define GCR_BITS 16
`endif

`ifdef GCR32
  `define GCR_BITS 32
`endif






`ifdef GSR
  //`define GSR8
  //`define GSR16
  `define GSR32
`endif

`ifdef GSR8
  `define GSR_BITS 8
`endif

`ifdef GSR16
  `define GSR_BITS 16
`endif

`ifdef GSR32
  `define GSR_BITS 32
`endif











`define TCIPIF

`ifdef TCIPIF


  `define CTIM     // Core Timer Hareware Implementation
  `define VIC      // Interrupt controller Configuration
  //`define CACHE
`endif

`ifdef VIC
  //`define INT_NUM_1
  //`define INT_NUM_2
  //`define INT_NUM_4
  //`define INT_NUM_8
  //`define INT_NUM_16
  //`define INT_NUM_24
  `define INT_NUM_32
  //`define INT_NUM_64
  //`define INT_NUM_96
  //`define INT_NUM_128
`endif





`ifdef SEU



  `define SEU_VERIFY_PARITY
  //`define SEU_VERIFY_HAMMING




  `define SEU_FIX_BRANCH
  //`define SEU_FIX_MULT
  //`define SEU_RANDOM_BLANK_INTERVALS
  //`define SEU_RANDOM_GATED_CLOCK_NOISE
  `define SEU_HARDWARE_RANDOM_INSTRUCTION_INSERTION
  `define SEU_GPR_CHECK
  `define SEU_PC_CHECK
  //`define SEU_PIPELINE_CHECK
  //`define SEU_CR_CHECK
  //`define SEU_CR_INDEPENDENT_COMPLEMENTARY_BACKUP
  //`define SEU_DATA_PATH_POLARITY
  //`define SEU_GPR_EXTERNAL_RESET
  `define SEU_BUS_PARITY
  //`define SEU_BUS_ENCRYPTION
  //`define SEU_BUS_SCRAMBLE




  //`define SECURITY_BIST
`endif




`ifdef SEU_VERIFY_PARITY



  //define the verify bits width
  `define SEU_VB_WIDTH 1
  //define the reset value
  `define SEU_VB_RESET_00000000 1'b0
  `define SEU_VB_RESET_80000000 1'b1

`endif

`ifdef SEU_VERIFY_HAMMING



  //define the verify bits width
  `define SEU_VB_WIDTH 6
  //define the reset value
  `define SEU_VB_RESET_00000000 6'b0
  `define SEU_VB_RESET_80000000 6'b100110

`endif




`define PRGSIGN_UNLOCK_VAL 32'hA29CD735





`ifdef INT_NUM_8
  `define VIC_IPR1
`endif
`ifdef INT_NUM_16
  `define VIC_IPR1
  `define VIC_IPR3
`endif
`ifdef INT_NUM_24
  `define VIC_IPR1
  `define VIC_IPR3
  `define VIC_IPR5
`endif
`ifdef INT_NUM_32
  `define VIC_IPR1
  `define VIC_IPR3
  `define VIC_IPR5
  `define VIC_IPR7
`endif
`ifdef INT_NUM_64
  `define VIC_IPR64
`endif
`ifdef INT_NUM_96
  `define VIC_IPR64
  `define VIC_IPR96
`endif
`ifdef INT_NUM_128
  `define VIC_IPR64
  `define VIC_IPR96
  `define VIC_IPR128
`endif




`define NEST_INT_ACCLRT




`ifdef CACHE
  //`define CACHE_2K
  //`define CACHE_4K
  `define CACHE_8K
`endif

`ifdef CACHE
  `define CACHE_2WAY
  //`define CACHE_4WAY
`endif

`ifdef CACHE
  `define CACHE_LINE_16B
  //`define CACHE_LINE_32B
`endif

`ifdef CACHE
  //`define CACHE_REGION_1
  `define CACHE_REGION_2
  //`define CACHE_REGION_3
  //`define CACHE_REGION_4
`endif

`ifdef CACHE_REGION_4
  `define REGION_REG3
  `define REGION_REG2
  `define REGION_REG1
  `define REGION_REG0
`endif

`ifdef CACHE_REGION_3
  `define REGION_REG2
  `define REGION_REG1
  `define REGION_REG0
`endif

`ifdef CACHE_REGION_2
  `define REGION_REG1
  `define REGION_REG0
`endif

`ifdef CACHE_REGION_1
  `define REGION_REG0
`endif

`ifdef CACHE
  //`define CACHE_USER_DEFINED
`endif

`ifdef CACHE
  //`define CACHE_MBIST
`endif

`ifdef CACHE
  //`define CACHE_LFIDLE_REQ
`endif




`define STACK_GUARD





`define INT_SP




`define HAD_IM

`ifdef HAD_IM
  `define HAD_JTAG_2
  `define HAD_MBKPTB //now, MBKPTB indicates five breakpoints: A, B, C, D, E
  `ifdef HAD_MBKPTB

  `endif
 // `define HAD_INST_DEBUG_DISABLE
 // `define HAD_PROF_CNT
 // `define DDMA //debug direct memory access
  `ifdef TCIPIF
 //   `define DBG_EXP // debug exception

  `endif
`endif

