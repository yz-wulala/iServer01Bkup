//define the type of core that will be tested
//`define CK801
`define CK802
//`define CK803
//`define CK803S
//`define CK804

`ifdef CK801
  `define MGU
`endif

`ifdef CK802
  `define IAHB_LITE
  //`define DAHB_LITE
  `define MGU
  //`define BCTM
`endif

`ifdef CK803
  `define IAHB_LITE
  //`define DAHB_LITE
  `define MGU
  `define DSP_MEDIA
`endif

`ifdef CK803S
  `define IAHB_LITE
  `define DAHB_LITE
  `define MGU
  //`define DSP_MEDIA
  //`define FPU
`endif


`ifdef CK804
  `define IAHB_LITE
  `define DAHB_LITE
  `define MGU
  `define DSP
  `define FPU
`endif

//define the bus type 
//`define AHB
`define AHB_LITE

//define HAD interface type 
//`define JTAG_5

//define test on FPGA
`define FPGAEN

//define rst active high
//`define RST_ACTIVE_HIGH
