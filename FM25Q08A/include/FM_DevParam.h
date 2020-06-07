
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           PARAMETERS OF DEVICES                       --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


//-----------------------------
//  Customization Parameters
//-----------------------------

//`define timingChecks

// data & address dimensions

parameter cmdDim = 8;
parameter addrDimLatch =24;
parameter dataDim = 8;
parameter dummyDim = 32;
parameter mbitsDim = 8;
parameter srdataDim = 8;


//----------------------------
// Model configuration
//----------------------------

parameter [12*8:1] devName = "FM25Q08XXXCH";
parameter [dataDim-1:0] MemoryType_ID = 'h40; 
parameter [dataDim-1:0] Capacity_ID = 'h14;
parameter [dataDim-1:0] Manufacturer_ID = 'hA1;
parameter [dataDim-1:0] Device_ID = 'h13;
parameter [63:0] Unique_ID = 'd0; // a factory-set 64bit ID unique for each FM25Q08A.Supposed zero here.


//----------------------------------------
// Supply Voltage Parameters 
//----------------------------------------

`define VoltageRange 31:0
parameter [`VoltageRange] Vcc_wi = 'd2000; //write inhibit 
parameter [`VoltageRange] Vcc_min = 'd2700;
parameter [`VoltageRange] Vcc_max = 'd3600;


//----------------------------
// Include TimingData file 
//----------------------------

`include "include/FM_TimingData.h"



//---------------------------
// stimuli clock period
//---------------------------
// for a correct behavior of the stimuli, clock period should
// be multiple of 4, meanwhile some timing violation will happen. 


//parameter time T = 16;//62.5MHz
parameter time T = 20; //50MHz
//parameter time T = 12; //83.3MHz
//parameter time T = 40; //25MHz


//-----------------------------------
// Devices Parameters 
//-----------------------------------



// memory organization

parameter addrDim = 'd20;
parameter memDim = 2 ** addrDim;

parameter colAddrDim = 'd8;
parameter colAddr_sup = colAddrDim-1;

parameter pageAddrDim = addrDim-colAddrDim;
parameter pageAddr_inf = colAddr_sup+1;
parameter pageAddr_sup = addrDim-1;
parameter pageDim = 2 ** colAddrDim;

parameter sectorAddrDim = pageAddrDim-4;
parameter sectorAddr_inf = 'd12; 
parameter sectorAddr_sup = addrDim-1;
parameter sectorDim = 2 ** (addrDim-sectorAddrDim);

parameter subblockAddrDim = sectorAddrDim-3;
parameter subblockAddr_inf = 'd15;
parameter subblockAddr_sup = addrDim-1;
parameter subblockDim = 2 ** (addrDim-subblockAddrDim);

parameter blockAddrDim = subblockAddrDim-1;
parameter blockAddr_inf = 'd16;
parameter blockAddr_sup = addrDim-1;
parameter blockDim = 2 ** (addrDim-blockAddrDim);

//parameter nBlock = 2 ** (blockAddrDim);
parameter nBlock = 2<<(blockAddrDim-1);



// Security Sectors

 parameter SecuSec_dim = 256;
 parameter SecuSec_addrDim = 8;


// others constants

parameter [dataDim-1:0] data_NP = 'hFF;


//-------------------------
// Alias used in the code
//-------------------------


`define WIP FM25Q08A.stat1.SR1[0]

`define WEL FM25Q08A.stat1.SR1[1]

`define BP0 FM25Q08A.stat1.SR1[2]

`define BP1 FM25Q08A.stat1.SR1[3]

`define BP2 FM25Q08A.stat1.SR1[4]

`define TB FM25Q08A.stat1.SR1[5]

`define SEC FM25Q08A.stat1.SR1[6]

`define SRP0 FM25Q08A.stat1.SR1[7]


`define SRP1 FM25Q08A.stat2.SR2[0]

`define QE FM25Q08A.stat2.SR2[1]

`define LB0 FM25Q08A.stat2.SR2[2]

`define LB1 FM25Q08A.stat2.SR2[3]

`define CMP FM25Q08A.stat2.SR2[4]

//`define WPS FM25Q08A.stat2.SR2[5]

`define ERR FM25Q08A.stat2.SR2[5]

//`define SUS FM25Q08A.stat2.SR2[7]

`define DRV0 FM25Q08A.stat2.SR2[6]

`define DRV1 FM25Q08A.stat2.SR2[7]
