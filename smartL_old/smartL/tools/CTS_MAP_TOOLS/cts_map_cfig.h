//INST address and size
`define IMEM_ADDR 0x10000000
`define IMEM_SIZE  0x20000
//DATA address and size
`define DMEM_ADDR 0x20000000
`define DMEM_SIZE 0x10000

//TSSP TUSP SSP USP address
`define TSSP 0x6000f8f8
`define TUSP 0x6000f4f8
`define SSP  0x6000fff8
`define USP  0x6000fcf8
//CPU IMEM DMEM instance path
`define CPU_TOP		tb.soc.ahb.ck***_top
`define SOC_IMEM_INS    tb.soc.ahb.mema
`define SOC_DMEM_INS    tb.soc.ahb.memb

//base address
`define BASE_ADDR    0x60000100
//print address
`define PRINT_ADDR   32'h6000fff8

//toolchain
`define TOOL_EXTENSION  /home/zhaok/toolchain/3.8.12
