
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           TIMING CONSTANTS                            --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/




    //--------------------------------------
    // Max clock frequency (minimum period)
    //--------------------------------------
    
    parameter fC = 104; //max frequency in Mhz
    parameter time TC = 10; //10ns~=1/100Mhz
    
    parameter fR = 50; //max frequency in Mhz during standard Read operation
    parameter time TR = 20; //20ns==1/50Mhz

    // for read data, read ID(& related), read status registers
    // max clock frequency is fR
    // for others, including fast read(& related) and others
    // max clock frequency is fC
    // especially for fast read, burst read, fast read quad io in QPI
    // max clock frequency changes and depends on READ PARAMETERS 
    
    //---------------------------
    // Input signals constraints
    //---------------------------

    // Clock signal constraints
    parameter time tCH = 4.5;
    parameter time tCL = 6;
    parameter time tSLCH = 5;
    parameter time tDVCH = 1.5;
    parameter time tSHCH = 5;
    parameter time tHLCH = 5;
    parameter time tHHCH = 5;

    // Chip select constraints
    parameter time tCHSL = 5;
    parameter time tCHSH = 5;
    parameter time tSHSL1 = 7; //after a read command 
    parameter time tSHSL2 = 40; //after a non-read command
    parameter time tWHSL = 20;  
    
    // Data in constraints
    parameter time tCHDX = 4;

    // W signal constraints
    parameter time tSHWL = 100;  


    // HOLD signal constraints
    parameter time tCHHH = 5;
    parameter time tCHHL = 5;


    //-----------------------
    // Output signal timings
    //-----------------------

    parameter time tSHQZ = 7; // max
    parameter time tCLQV = 7; // max
    parameter time tCLQX = 0; // min value
    parameter time tHHQX = 7; // max 
    parameter time tHLQZ = 12; //max



    //--------------------
    // Operation delays
    //--------------------
   
    parameter time tDP  = 3e3;
    parameter time tRES1 = 3e3; 
    parameter time tRES2 = 1.8e3;

    parameter time tSUS = 20e3; //#CS high to next instruction after Suspend

    parameter time tPP  = 5e6;
    
    parameter time tSE = 0.3e9;// sector erase
    parameter time tSBE  = 0.8e9;// subblock erase
    parameter time tBE  = 1e9; // block erase
    parameter time tCE  = 8e9; // chip erase

    parameter time tWSR   = 15e6;
    parameter time tWVSR = 40;
    
    parameter time tRST = 20e3; //#CS high to next instruction after Reset


    // Startup delays
    parameter time tPUW = 10e6;
    parameter time tVSL = 10e3;

    
//---------------------------------
// Alias of timing constants above
//---------------------------------

parameter time program_delay = tPP;

parameter time erase_sector_delay = tSE;
parameter time erase_subblock_delay = tSBE;
parameter time erase_block_delay = tBE;
parameter time erase_chip_delay = tCE;

parameter time write_SR_delay = tWSR;
parameter time write_VSR_delay = tWVSR;

parameter time full_access_power_up_delay = tPUW;
parameter time read_access_power_up_delay = tVSL;

parameter time SUSlatency = tSUS;
parameter time RSTlatency = tRST;


parameter time deep_power_down_delay = tDP; 
parameter time release_power_down_delay_1 = tRES1;
parameter time release_power_down_delay_2 = tRES2;

