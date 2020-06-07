


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           CUI DECODERS ISTANTIATIONS                  --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


//
// Here are istantiated CUIdecoders
// for commands recognition
//


CUIdecoder   

    #(.cmdName("Write Enable"), .cmdCode('h06), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_WriteEnable (!busy && !deep_power_down && WriteAccessOn);


CUIdecoder   

    #(.cmdName("Write Disable"), .cmdCode('h04), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_WriteDisable (!busy && !deep_power_down  && WriteAccessOn);


CUIdecoder   

    #(.cmdName("Volatile SR Write Enable"), .cmdCode('h50), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_VolatileSR_WriteEnable (!busy && !deep_power_down  && ReadAccessOn);


CUIdecoder   

    #(.cmdName("Read Status Register 1"), .cmdCode('h05), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_ReadStatusRegister1 (!deep_power_down && ReadAccessOn);




CUIdecoder   

      #(.cmdName("Read Status Register 2"), .cmdCode('h35), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_ReadStatusRegister2 (!deep_power_down && ReadAccessOn);


CUIdecoder

      #(.cmdName("Read Status Register 3"), .cmdCode('h15), .withAddr(0), .with2Addr(0), .with4Addr(0))

      CUIDEC_ReadStatusRegister3 (!deep_power_down && ReadAccessOn);


CUIdecoder   

    #(.cmdName("Write Status Register1"), .cmdCode('h01), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_WriteStatusRegister1 (!busy && PollingAccessOn && !deep_power_down);


CUIdecoder

    #(.cmdName("Write Status Register2"), .cmdCode('h31), .withAddr(0), .with2Addr(0), .with4Addr(0))

    CUIDEC_WriteStatusRegister2 (!busy && PollingAccessOn && !deep_power_down);


CUIdecoder

    #(.cmdName("Write Status Register3"), .cmdCode('h11), .withAddr(0), .with2Addr(0), .with4Addr(0))

    CUIDEC_WriteStatusRegister3 (!busy && PollingAccessOn && !deep_power_down);


//SPI
CUIdecoder   

      #(.cmdName("Read Manufacturer Device ID"), .cmdCode('h90), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_ReadManufacturerDeviceID_SPI (!busy && ReadAccessOn && protocol=="SPI" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Page Program"), .cmdCode('h02), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_PageProgramSPI (!busy && WriteAccessOn && protocol=="SPI" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Sector Erase"), .cmdCode('h20), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_SectorEraseSPI (!busy && WriteAccessOn && protocol=="SPI" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Subblock Erase"), .cmdCode('h52), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_SubblockEraseSPI (!busy && WriteAccessOn && protocol=="SPI" && !deep_power_down);


CUIdecoder      

    #(.cmdName("Block Erase"), .cmdCode('hD8), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_BlockEraseSPI (!busy && WriteAccessOn && protocol=="SPI" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Fast Read"), .cmdCode('h0B), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_FastReadSPI (!busy && ReadAccessOn && protocol=="SPI" && !deep_power_down);


//QPI
CUIdecoder   

      #(.cmdName("Read Manufacturer Device ID"), .cmdCode('h90), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
      CUIDEC_ReadManufacturerDeviceID_QPI (!busy && ReadAccessOn && protocol=="QPI" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Quad Page Program"), .cmdCode('h02), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_PageProgramQPI (!busy && WriteAccessOn && protocol=="QPI" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Sector Erase"), .cmdCode('h20), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_SectorEraseQPI (!busy && WriteAccessOn && protocol=="QPI" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Subblock Erase"), .cmdCode('h52), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_SubblockEraseQPI (!busy && WriteAccessOn && protocol=="QPI" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Block Erase"), .cmdCode('hD8), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_BlockEraseQPI (!busy && WriteAccessOn && protocol=="QPI" && !deep_power_down);


CUIdecoder   

    #(.cmdName("Fast Read"), .cmdCode('h0B), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_FastReadQPI (!busy && ReadAccessOn && protocol=="QPI" && !deep_power_down);

//

CUIdecoder   

    #(.cmdName("Chip Erase"), .cmdCode('hC7), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_ChipErase1 (!busy && WriteAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Chip Erase"), .cmdCode('h60), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_ChipErase2 (!busy && WriteAccessOn && !deep_power_down);


CUIdecoder   

    #(.cmdName("Erase Program Suspend"), .cmdCode('h75), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_EraseProgramSuspend (WriteAccessOn && !deep_power_down);



CUIdecoder   

      #(.cmdName("Erase Program Resume"), .cmdCode('h7A), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_EraseProgramResume (!busy && WriteAccessOn && !deep_power_down);

  

 CUIdecoder   

      #(.cmdName("Power Down"), .cmdCode('hB9), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_PowerDown (!busy && ReadAccessOn && !deep_power_down);

 CUIdecoder   

      #(.cmdName("Release Power Down Device ID"), .cmdCode('hAB), .withAddr(1), .with2Addr(0), .with4Addr(0))
         
      CUIDEC_ReleasePowerdown_DeviceID (!busy && ReadAccessOn && protocol=="SPI");

 CUIdecoder
                      
      #(.cmdName("Release Power Down Device ID"), .cmdCode('hAB), .withAddr(0), .with2Addr(0), .with4Addr(1))
                                
      CUIDEC_ReleasePowerdown_DeviceID_QPI (!busy && ReadAccessOn && protocol=="QPI");

 CUIdecoder   

      #(.cmdName("Release Power Down"), .cmdCode('hAB), .withAddr(0), .with2Addr(0), .with4Addr(0))

      CUIDEC_ReleasePowerdown (!busy && ReadAccessOn && deep_power_down);

 CUIdecoder   

      #(.cmdName("Read Data"), .cmdCode('h03), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_ReadData (!busy && ReadAccessOn && !deep_power_down);




  CUIdecoder   

      #(.cmdName("Read Manufacturer Device ID Dual IO"), .cmdCode('h92), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
      CUIDEC_ReadManufacturerDeviceID_DualIO (!busy && ReadAccessOn && !deep_power_down);


  CUIdecoder   

      #(.cmdName("Read Manufacturer Device ID Quad IO"), .cmdCode('h94), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
      CUIDEC_ReadManufacturerDeviceID_QuadIO (!busy && ReadAccessOn && !deep_power_down); 


CUIdecoder   

      #(.cmdName("Read JEDEC ID"), .cmdCode('h9F), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_ReadJEDECID (!busy && ReadAccessOn && !deep_power_down);


  CUIdecoder   

      #(.cmdName("Read Unique ID"), .cmdCode('h4B), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_ReadUniqueID (!busy && ReadAccessOn && !deep_power_down);


 CUIdecoder

       #(.cmdName("Read SFDP Register"), .cmdCode('h5A), .withAddr(1), .with2Addr(0), .with4Addr(0))

       CUIDEC_ReadSFDPRegister (!busy && ReadAccessOn && !deep_power_down);


  CUIdecoder   

      #(.cmdName("Erase Security Sectors"), .cmdCode('h44), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_EraseSecuritySectors (!busy && WriteAccessOn && !deep_power_down);


CUIdecoder   

      #(.cmdName("Program Security Sectors"), .cmdCode('h42), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_ProgramSecuritySectors (!busy && WriteAccessOn && !deep_power_down);
      

CUIdecoder   

    #(.cmdName("Read Security Sectors"), .cmdCode('h48), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_ReadSecuritySectors (!busy && ReadAccessOn && !deep_power_down);


CUIdecoder   

    #(.cmdName("Enable QPI"), .cmdCode('h38), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_EnableQPI (!busy && WriteAccessOn && !deep_power_down);


CUIdecoder   

    #(.cmdName("Enable Reset"), .cmdCode('h66), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_EnableReset (WriteAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Reset"), .cmdCode('h99), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_Reset (WriteAccessOn && !deep_power_down);


CUIdecoder   

    #(.cmdName("Fast Read Dual Output"), .cmdCode('h3B), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_FastReadDualOutput (!busy && ReadAccessOn && !deep_power_down);


CUIdecoder   

    #(.cmdName("Fast Read Dual IO"), .cmdCode('hBB), .withAddr(0), .with2Addr(1), .with4Addr(0))
    
    CUIDEC_FastReadDualIO (!busy && ReadAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Quad Page Program"), .cmdCode('h32), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_QuadPageProgram (!busy && WriteAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Fast Read Quad Output"), .cmdCode('h6B), .withAddr(1), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_FastReadQuadOutput (!busy && ReadAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Fast Read Quad IO"), .cmdCode('hEB), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_FastReadQuadIO (!busy && ReadAccessOn && !deep_power_down);

CUIdecoder   

    #(.cmdName("Word Read Quad IO"), .cmdCode('hE7), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_WordReadQuadIO (!busy && ReadAccessOn && !deep_power_down);

CUIdecoder   

      #(.cmdName("Octal Word Read Quad IO"), .cmdCode('hE3), .withAddr(0), .with2Addr(0), .with4Addr(1))

      CUIDEC_OctalWordReadQuadIO (!busy && ReadAccessOn  && !deep_power_down);    

  CUIdecoder   

      #(.cmdName("Set Burst With Wrap"), .cmdCode('h77), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_SetBurstWithWrap (!busy && WriteAccessOn  && !deep_power_down);    

  CUIdecoder   

      #(.cmdName("Set Read Parameters"), .cmdCode('hC0), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
      CUIDEC_SetReadParameters (!busy && WriteAccessOn  && !deep_power_down);    

CUIdecoder   

    #(.cmdName("Burst Read With Wrap"), .cmdCode('h0C), .withAddr(0), .with2Addr(0), .with4Addr(1))
    
    CUIDEC_BurstReadWithWrap (!busy && ReadAccessOn  && !deep_power_down);

CUIdecoder   

    #(.cmdName("Disable QPI"), .cmdCode('hFF), .withAddr(0), .with2Addr(0), .with4Addr(0))
    
    CUIDEC_DisableQPI (!busy && WriteAccessOn  && !deep_power_down);

