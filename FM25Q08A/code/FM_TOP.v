

`timescale 1ns / 100ps

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           TOP LEVEL MODULE                            --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/



module FM25Q08A (CS, CLK, HOLD_DQ3, DI_DQ0, DO_DQ1, VCC, WP_DQ2);

`include "include/FM_DevParam.h"

input CS;
input CLK;
input [`VoltageRange] VCC;

inout DI_DQ0; 
inout DO_DQ1;


inout HOLD_DQ3; //input HOLD, inout DQ3

inout WP_DQ2;//input WP, inout DQ2


parameter [40*8:1] memory_file =" ";


reg PollingAccessOn = 0;
reg ReadAccessOn = 0;
wire WriteAccessOn; 


reg [8:1] latchingMode = "N";

reg [3*8:1] protocol="SPI";

reg [cmdDim-1:0] cmd='h0;
reg [mbitsDim-1:0] mbits='h0;
reg [srdataDim-1:0] srdata='h0;
reg [addrDimLatch-1:0] addrLatch='h0;
reg [addrDim-1:0] addr='h0;
reg [dataDim-1:0] data='h0;
reg [dataDim-1:0] dataOut='h0;

integer dummyDimEff, QuadDummy, WrapLength;

reg [40*8:1] cmdRecName = "";



//----------------------
// HOLD signal
//----------------------


    reg intHOLD=1;

    assign HOLD = (`QE==1) ? 1 : HOLD_DQ3;

	always @(HOLD) if (CS==0 && CLK==0) 
		intHOLD = HOLD;

    always @(negedge CLK) if(CS==0 && intHOLD!=HOLD)
        intHOLD = HOLD;
	
	always @(posedge HOLD) if(CS==1)
		intHOLD = 1;
       
    
    always @intHOLD if (VCC>=Vcc_min) begin
        if(intHOLD==0)
            $display("  [%0t ns] ==INFO== Hold condition enabled: communication with the device has been paused.\n", $time);
        else if(intHOLD==1)
            $display("  [%0t ns] ==INFO== Hold condition disabled: communication with the device has been activated.\n", $time);  
   end



//-------------------------
// Internal signals
//-------------------------

reg busy=0;

reg [2:0] ck_count = 0; //clock counter (modulo 8) 

reg [2:0] ID_count = 0; //ID counter for read

reg reset_by_powerOn = 1 ; //reset_by_powerOn is updated in "Power Up & Voltage check" section


assign logicOn = !reset_by_powerOn && !CS && intHOLD; 


reg deep_power_down = 0; //updated in "Deep power down" processes




//---------------------------------------
//  WP signal : write protect feature
//---------------------------------------

assign W_int = (`QE==1) ? 1 : WP_DQ2;
    
//----------------------------
// CUI decoders istantiation
//----------------------------

`include "include/FM_Decoders.h"




//---------------------------
// Modules istantiations
//---------------------------

Memory          mem ();

UtilFunctions   f ();

Program         prog ();

StatusRegister1  stat1 ();

StatusRegister2  stat2 ();

//StatusRegister3  stat3 ();

Read            read ();        

LockManager     lock ();

`ifdef timingChecks

  TimingCheck     timeCheck (CS, CLK, DI_DQ0, DO_DQ1, W_int, HOLD_DQ3); 

`endif  

 SecuritySectors      SecuSec (); 


//----------------------------------
//  Signals for latching control
//----------------------------------

integer iCmd, iAddr, iData, iDummy, iMbits, iSrdata;

event startCUIdec, cmdLatched;

always @(negedge CS) begin : CP_latchInit

	dataOut = 0;	
          
    ck_count = 0;
    
    ID_count = 0;

    iCmd = cmdDim - 1;
    
    iAddr = addrDimLatch - 1; 

    iData = dataDim - 1;

    iMbits = mbitsDim - 1;

    iSrdata = srdataDim - 1;
    
    cmdRecName = "";

    if (!read.contin_enable)
      latchingMode = "C";  
    else begin
      cmd = read.Mcommand;
      ->cmdLatched;
    end

end


always @(posedge CLK) if(logicOn) begin
    ck_count = ck_count + 1;

end






//  indicate type of data that will be latched by the model:
//  C=command, N=none, Y=dummy;
//  A=address, I=address on two pins, E=address on four pins; 
//  M=continuous Mode bits on two pins;
//  D=data input, Q=Quad data input;
//  S=state register data input, one byte or two.


//-------------------------
// Latching commands
//-------------------------





always @(posedge CLK) if(logicOn && latchingMode=="C" && protocol=="SPI") begin : CP_latchCmd

    cmd[iCmd] = DI_DQ0;

    if (iCmd>0)
        iCmd = iCmd - 1;
    else if(iCmd==0) begin
        latchingMode = "N";
        -> cmdLatched;
    end    
        
end


always @(posedge CLK) if(logicOn && latchingMode=="C" && protocol=="QPI") begin : CP_latchCmdQuad

    cmd[iCmd] = HOLD_DQ3;
    cmd[iCmd-1] = WP_DQ2;
    cmd[iCmd-2] = DO_DQ1;
    cmd[iCmd-3] = DI_DQ0;

    if (iCmd>=7)
        iCmd = iCmd - 4;
    else if(iCmd==3) begin
        latchingMode = "N";
        -> cmdLatched;
    end    
        
end



//-------------------------
// Latching address
//-------------------------


event addrLatched;

always @(posedge CLK) if (logicOn && latchingMode=="A") begin : CP_latchAddr

    addrLatch[iAddr] = DI_DQ0;
    if (iAddr>0)
        iAddr = iAddr - 1;
    else if(iAddr==0) begin
        latchingMode = "N";
        addr = addrLatch[addrDim-1:0];
        -> addrLatched;
    end

end



always @(posedge CLK) if (logicOn && latchingMode=="I") begin : CP_latchAddrDual

    addrLatch[iAddr] = DO_DQ1;
    addrLatch[iAddr-1]= DI_DQ0;
    if (iAddr>=3)
        iAddr = iAddr - 2;
    else if(iAddr==1) begin
        latchingMode = "N";
        addr = addrLatch[addrDim-1:0];
        
        -> addrLatched;

    end

end



always @(posedge CLK) if (logicOn && latchingMode=="E") begin : CP_latchAddrQuad

    addrLatch[iAddr] = HOLD_DQ3;
    addrLatch[iAddr-1]= WP_DQ2;
    addrLatch[iAddr-2]= DO_DQ1;
    addrLatch[iAddr-3]= DI_DQ0;
   
    if (iAddr>=7)
        iAddr = iAddr - 4;

    else if(iAddr==3) begin
        latchingMode = "N";        
        addr = addrLatch[addrDim-1:0];
        -> addrLatched;
    end

end


//-------------------------
// Latching Mbits
//-------------------------


event mbitsLatched;//Continuous Mode bits M7-M0

always @(posedge CLK) if(logicOn && latchingMode=="M" && `QE==0) begin : CP_latchMbitsDual

    mbits[iMbits] = DO_DQ1;
    mbits[iMbits-1] = DI_DQ0;
    
    if (iMbits>=3)
        iMbits = iMbits - 2;
    else if(iMbits==1) begin
        latchingMode = "N";
        -> mbitsLatched;
    end    
        
end


always @(posedge CLK) if(logicOn && latchingMode=="M" && `QE==1) begin : CP_latchMbitsQuad

    mbits[iMbits] = HOLD_DQ3;
    mbits[iMbits-1] = WP_DQ2;
    mbits[iMbits-2] = DO_DQ1;
    mbits[iMbits-3] = DI_DQ0;

    if (iMbits>=7)
        iMbits = iMbits - 4;
    else if(iMbits==3) begin
        latchingMode = "N";
        -> mbitsLatched;
    end    
        
end


//------------------------------
// Latching Status Reg data
//------------------------------


event srdataLatched;

always @(posedge CLK) if(logicOn && latchingMode=="S" && protocol=="SPI") begin : CP_latchSrdata

    srdata[iSrdata] = DI_DQ0;

    if (iSrdata>0)
        iSrdata = iSrdata - 1;
    else if(iSrdata==0) begin
        -> srdataLatched;   
        iSrdata=7;
    end
end


always @(posedge CLK) if(logicOn && latchingMode=="S" && protocol=="QPI") begin : CP_latchSrdataQuad

    srdata[iSrdata] = HOLD_DQ3;
    srdata[iSrdata-1] = WP_DQ2;
    srdata[iSrdata-2] = DO_DQ1;
    srdata[iSrdata-3] = DI_DQ0;

    if (iSrdata>=7)
        iSrdata = iSrdata - 4;
    else if(iSrdata==3) begin
        -> srdataLatched;  
        iSrdata=7;
    end
end


//-----------------
// Latching data
//-----------------


event dataLatched;

always @(posedge CLK) if (logicOn && latchingMode=="D") begin : CP_latchData

    data[iData] = DI_DQ0;

    if (iData>0)
        iData = iData-1;
    else begin 
        -> dataLatched;
        $display("  [%0t ns] Data latched: %h", $time, data);
        iData=dataDim-1;
    end    

end


always @(posedge CLK) if (logicOn && latchingMode=="Q") begin : CP_latchData_quad //data quad input 
       

     data[iData] = HOLD_DQ3;
     data[iData-1] = WP_DQ2;
     data[iData-2] = DO_DQ1;
     data[iData-3] = DI_DQ0;
     if (iData==7)
            iData = iData-4;
     else begin
            -> dataLatched;
            $display("  [%0t ns] Data latched: %h", $time, data);
            iData=dataDim-1;
     end    

end





//-----------------
// Latching dummy
//-----------------


event dummyLatched;

always @(posedge CLK) if (logicOn && latchingMode=="Y") begin : CP_latchDummy

	$display("  [%0t ns] One Dummy clock cycle latched.", $time);
	 
    if (iDummy>0) begin 
        iDummy = iDummy-1;
    end else begin
        -> dummyLatched;
       // ck_count=0;
    end    

end

 





//------------------------------
// Commands recognition control
//------------------------------


event codeRecognized, seqRecognized;



always @(cmdLatched) fork: CP_cmdRecControl

    -> startCUIdec; 

    
	
    
	begin : ok
        @(codeRecognized or seqRecognized) 
          disable error;
    end
    
    
    begin : error
        #0;#0; #0;#0;#0;#0;#0;#0;#0;#0;#0;#0;#0;#0;
        #0; //wait until CUI decoders execute recognition process (2 delta time maximum)
        if (busy)   
            $display("  [%0t ns] **WARNING** Device is busy. Command not accepted.", $time);
        else if (deep_power_down)
            $display("  [%0t ns] **WARNING** Deep power down mode. Command not accepted.", $time);
        else if (!ReadAccessOn || !WriteAccessOn || !PollingAccessOn) 
            $display("  [%0t ns] **WARNING** Power up is ongoing. Command not accepted.", $time);    
        else if (!busy)
            $display("  [%0t ns] **ERROR** Command Not Recognized.", $time);
        disable ok;
    end    

    join



//------------------------------------
// Power Up, Fast POR & Voltage check
//------------------------------------

wire VCC_L1, VCC_L2, VCCOk;
reg WriteAccessCondition = 0;
//--- Reset internal logic (latching disabled when VCC<VCC_wi)

assign VCC_L1 = (VCC>=Vcc_wi) ?  1 : 0 ;

always @VCC_L1 
  if (reset_by_powerOn && VCC_L1) begin
  	reset_by_powerOn = 0;
  	#full_access_power_up_delay;
  	WriteAccessCondition=1;
  end else if (!reset_by_powerOn && !VCC_L1) 
    reset_by_powerOn = 1;
    


assign VCC_L2 = (VCC>=Vcc_min) ?  1 : 0 ;


//--- Write access




//----------------------------
// Power Up  
//----------------------------


always @VCC_L2 if(VCC_L2 && PollingAccessOn==0 && ReadAccessOn==0 && WriteAccessCondition==0) fork : CP_powUp_FullAccess
    
    begin : p1
      $display("  [%0t ns] ==INFO== Power up: polling allowed.",$time );
      PollingAccessOn=1;
      
      #read_access_power_up_delay;
      $display("  [%0t ns] ==INFO== Power up: device fully accessible.",$time );
      ReadAccessOn=1;

      
            disable p2;
    end 

    begin : p2
      @VCC_L2 if(!VCC_L2)
        disable p1;
    end

join    


assign WriteAccessOn =PollingAccessOn && ReadAccessOn && WriteAccessCondition;


//--- Voltage drop (power down)

always @VCC_L1 if (!VCC_L1 && (PollingAccessOn|| ReadAccessOn || WriteAccessCondition)) begin : CP_powerDown
    $display("  [%0t ns] ==INFO== Voltage below the threshold value: device not accessible.", $time);
    ReadAccessOn=0;
    WriteAccessCondition=0;
    PollingAccessOn=0;
    prog.Suspended=0; //the suspended state is reset  
    
end    




//--- Voltage fault (used during program and erase operations)

event voltageFault; //used in Program and erase dynamic check (see also "CP_voltageCheck" process)

assign VCCOk = (VCC>=Vcc_min && VCC<=Vcc_max) ?  1 : 0 ;

always @VCCOk if (!VCCOk) ->voltageFault; //check is active when device is not reset
                                          //(this is a dynamic check used during program and erase operations)
        





                   

//-----------------
// Read execution
//-----------------


reg [addrDim-1:0] readAddr;

reg bitOut='hZ,bitOut_extra='hZ;

reg bitOut0='hZ, bitOut1='hZ, bitOut2='hZ, bitOut3='hZ;

reg oldbitOut, oldbitOut_extra, oldbitOut0, oldbitOut1, oldbitOut2, oldbitOut3;
    
event sendToBus, sendToBus_dual, sendToBus_quad; 


// values assumed by DI_DQ0 and DO_DQ1, when they are not forced
assign DI_DQ0 = 1'bZ;
assign DO_DQ1 = 1'bZ;
assign WP_DQ2 = 1'bZ;
assign HOLD_DQ3 = 1'bZ;


// release of values assigned with "force statement"
    always @(posedge CS) begin
           #tSHQZ release DO_DQ1; 
        end

    always @(negedge(CLK)) if(FM25Q08A.logicOn && (read.enable_dual==1 || read.enable_ManDevID_Dual==1)) 
        @(posedge CS) begin 
           #tSHQZ 
            release DI_DQ0;
            release DO_DQ1;
        end  
        
    
    always @(negedge(CLK)) if(FM25Q08A.logicOn && (read.enable_quad==1 || read.enable_quadwrap==1 || read.enable_ManDevID_Quad==1 || FM25Q08A.protocol=="QPI")) 
    
        @(posedge CS) begin       
           #tSHQZ          
            release DI_DQ0;
            release DO_DQ1;
            release WP_DQ2;
            release HOLD_DQ3;
        end   

     
// effect on DO_DQ1 by HOLD signal
    
    reg temp, temp0;
    
    always @(intHOLD) if(intHOLD===0) fork : CP_HOLD_out_effect 
        
        begin : out_effect
			#(tCLQV - tCLQX);
            temp = DO_DQ1;
            if ((read.enable_dual==1) || (read.enable_ManDevID_Dual==1))
             temp0 = DI_DQ0;
            #(tHLQZ- (tCLQV - tCLQX));
            disable guardian;
            release DO_DQ1;
            if ((read.enable_dual==1) || (read.enable_ManDevID_Dual==1))
             release DI_DQ0;
            @(posedge intHOLD)  force DO_DQ1=temp;
            if ((read.enable_dual==1) || (read.enable_ManDevID_Dual==1))
             force DI_DQ0=temp0;
        end  

        begin : guardian 
            @(posedge intHOLD)
            disable out_effect;
        end
        
    join  
 



// read with SPI protocol

always @(negedge(CLK)) #0 if(logicOn && protocol=="SPI") begin : CP_read_SPI

    if(read.enable==1 || read.enable_fast==1) begin    
        
        if(ck_count==0) begin
            readAddr = mem.memAddr;
            mem.readData(dataOut); //read data and increments address
            f.out_info(readAddr, dataOut);
        end
        
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;

    
    end else if (read.enable_DevID==1) begin
       
        if(ck_count==0) begin
                dataOut = Device_ID; //read data and increments address
                f.out_info(readAddr, dataOut);
        end
          
         #tCLQX
          bitOut = dataOut[dataDim-1-ck_count];
          -> sendToBus;


    end else if (read.enable_ManDevID==1) begin
       
                if(ck_count==0 && ID_count == 0) begin
            
            dataOut = Manufacturer_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 1;
          
                end else if(ck_count==0 && ID_count == 1) begin
         
            dataOut = Device_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 0;
                                   
        end
       
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;


  end else if (read.enable_ManDevID_Dual==1) begin
       
                if((ck_count==0 || ck_count==4) && ID_count == 0) begin
            
            dataOut = Manufacturer_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 1;
          
                end else if((ck_count==0 || ck_count==4) && ID_count == 1) begin
         
            dataOut = Device_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 0;                                   
        end
        
         #tCLQX
         bitOut = dataOut[dataDim-1- (2*(ck_count%4))];
         bitOut_extra = dataOut[ dataDim-2 - (2*(ck_count%4))]; 
        -> sendToBus_dual;


  

  end else if (read.enable_ManDevID_Quad==1) begin
       
                if((ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) && ID_count == 0) begin
            
            dataOut = Manufacturer_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 1;
          
                end else if((ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) && ID_count == 1) begin
         
            dataOut = Device_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 0;
                                   
        end
        
        #tCLQX
        bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
        bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
        bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
        bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 

         -> sendToBus_quad;



         
     end else if (read.enable_JEDEC==1) begin
       
                if(ck_count==0 && ID_count == 0) begin
            
            dataOut = Manufacturer_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 1;
          
                end else if(ck_count==0 && ID_count == 1) begin
         
            dataOut = MemoryType_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 2;
            
                end else if(ck_count==0 && ID_count == 2) begin
         
            dataOut = Capacity_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 0;
                                   
        end
       
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;

 
     end else if (read.enable_UID==1) begin
       
                if(ck_count==0 && ID_count == 0) begin
            
            dataOut = Unique_ID[7:0];
            f.out_info(readAddr, dataOut);
            ID_count = 1;
          
                end else if(ck_count==0 && ID_count == 1) begin
         
            dataOut = Unique_ID[15:8];
            f.out_info(readAddr, dataOut);
            ID_count = 2;
            
                end else if(ck_count==0 && ID_count == 2) begin
         
            dataOut = Unique_ID[23:16];
            f.out_info(readAddr, dataOut);
            ID_count = 3;
            
                end else if(ck_count==0 && ID_count == 3) begin
         
            dataOut = Unique_ID[31:24];
            f.out_info(readAddr, dataOut);
            ID_count = 4;
            
                end else if(ck_count==0 && ID_count == 4) begin
         
            dataOut = Unique_ID[39:32];
            f.out_info(readAddr, dataOut);
            ID_count = 5;
            
                end else if(ck_count==0 && ID_count == 5) begin
         
            dataOut = Unique_ID[47:40];
            f.out_info(readAddr, dataOut);
            ID_count = 6;
            
                end else if(ck_count==0 && ID_count == 6) begin
         
            dataOut = Unique_ID[55:48];
            f.out_info(readAddr, dataOut);
            ID_count = 7;
            
                end else if(ck_count==0 && ID_count == 7) begin
         
            dataOut = Unique_ID[63:56];
            f.out_info(readAddr, dataOut);
            ID_count = 0;
                                   
        end
       
        #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;

        
                
    end else if (stat1.enable_SR1_read==1) begin
        
        if(ck_count==0) begin
            dataOut = stat1.SR1;
            f.out_info(readAddr, dataOut);
        end    
       
       #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;
   

    end else if (stat2.enable_SR2_read==1) begin
        
        if(ck_count==0) begin
            dataOut = stat2.SR2;
            f.out_info(readAddr, dataOut);
        end   
       
       #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;
      


/*     end else if (stat3.enable_SR3_read==1) begin
       if(ck_count==0) begin
            dataOut = stat3.SR3;
            f.out_info(readAddr, dataOut);
        end   
       
       #tCLQX
        bitOut = dataOut[dataDim-1-ck_count];
        -> sendToBus;
*/
     end else if (read.enable_dual==1) begin
        
      if(ck_count==0 || ck_count==4)
         begin
             readAddr = mem.memAddr;
             mem.readData(dataOut); //read data and increments address
             f.out_info(readAddr, dataOut);
         end
         
           #tCLQX
          bitOut = dataOut[ dataDim-1 - (2*(ck_count%4)) ]; //%=modulo operator
          bitOut_extra = dataOut[ dataDim-2 - (2*(ck_count%4)) ]; 
            
          -> sendToBus_dual;


    
     end else if(read.enable_quad==1) begin

            if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)
            begin
                readAddr = mem.memAddr;
                mem.readData(dataOut); //read data and increments address
                f.out_info(readAddr, dataOut);
            end
            
            #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
            -> sendToBus_quad;
    


    
   end else if (read.enable_SecuSec==1) begin 

          if(ck_count==0) begin
              readAddr = 'h0;
              readAddr = SecuSec.addr;
              case (SecuSec.sec) //read data and increments address
              2'b00:   SecuSec.readSecuSec0(dataOut);
              2'b01:   SecuSec.readSecuSec1(dataOut);
              2'b10:   SecuSec.readSecuSec2(dataOut);
              2'b11:   SecuSec.readSecuSec3(dataOut);
              endcase
              f.out_info(readAddr, dataOut);
          end
          
          #tCLQX
          bitOut = dataOut[dataDim-1-ck_count];
          -> sendToBus;



     end else if(read.enable_quadwrap==1) begin

            if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)
            begin
                readAddr = mem.memAddr;
                mem.wrapreadData(dataOut); //read data and increments address
                f.out_info(readAddr, dataOut);
            end
            
            #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
            -> sendToBus_quad;   


       end   

end





// read with QPI protocol

always @(negedge(CLK)) #0 if(logicOn && protocol=="QPI") begin : CP_read_QPI
	
     if(read.enable_fast==1) begin    
        
        if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)
            begin
                readAddr = mem.memAddr;
                mem.readData(dataOut); 
                f.out_info(readAddr, dataOut);  
            end
            
            #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
            -> sendToBus_quad;

    
    end else if (read.enable_DevID==1) begin
       
        if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)
            begin
                dataOut=Device_ID; 
                f.out_info(readAddr, dataOut);  
            end
            
            #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
            -> sendToBus_quad;


    end else if (stat1.enable_SR1_read==1) begin
        
        if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) begin
            dataOut = stat1.SR1;
            f.out_info(readAddr, dataOut);
        end    
       
       #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
            -> sendToBus_quad;


    end else if (stat2.enable_SR2_read==1) begin
        
        if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) begin
            dataOut = stat2.SR2;
            f.out_info(readAddr, dataOut);
        end   
       
       #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
            -> sendToBus_quad;

/*    end else if (stat3.enable_SR3_read==1) begin
        
        if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) begin
            dataOut = stat3.SR3;
            f.out_info(readAddr, dataOut);
        end   
       
       #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
            -> sendToBus_quad;
*/
     end else if(read.enable_quad==1) begin

            if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)
            begin
                readAddr = mem.memAddr;
                mem.readData(dataOut); //read data and increments address
                f.out_info(readAddr, dataOut);
            end
            
            #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
            -> sendToBus_quad;


            
     end else if(read.enable_quadwrap==1) begin

            if(ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6)
            begin
                readAddr = mem.memAddr;
                mem.wrapreadData(dataOut); //read data and increments address in wrap mode
                f.out_info(readAddr, dataOut);
            end
            
            #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
            -> sendToBus_quad;



    end else if (read.enable_ManDevID==1) begin
       
                if((ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) && ID_count == 0) begin
            
            dataOut = Manufacturer_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 1;
          
                end else if((ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) && ID_count == 1) begin
         
            dataOut = Device_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 0;
                                   
        end
            #tCLQX
            bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
            bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
            bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
            bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 
            -> sendToBus_quad;



    end else if (read.enable_JEDEC==1) begin
       
                if((ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) && ID_count == 0) begin
            
            dataOut = Manufacturer_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 1;
          
                end else if((ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) && ID_count == 1) begin
         
            dataOut = MemoryType_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 2;
            
                end else if((ck_count==0 || ck_count==2 || ck_count==4 || ck_count==6) && ID_count == 2) begin
         
            dataOut = Capacity_ID;
            f.out_info(readAddr, dataOut);
            ID_count = 0;
                                   
        end
       
        #tCLQX
        bitOut3 = dataOut[ dataDim-1 - (4*(ck_count%2)) ]; //%=modulo operator
        bitOut2 = dataOut[ dataDim-2 - (4*(ck_count%2)) ]; 
        bitOut1 = dataOut[ dataDim-3 - (4*(ck_count%2)) ]; 
        bitOut0 = dataOut[ dataDim-4 - (4*(ck_count%2)) ]; 

         -> sendToBus_quad;


     end
 end


always @sendToBus fork : CP_sendToBus


      force DO_DQ1 = ((bitOut==oldbitOut)? oldbitOut: 1'bX);
    
    #(tCLQV - tCLQX) begin 
        force DO_DQ1 = bitOut;
        oldbitOut = bitOut;
        end

join






always @sendToBus_dual fork

        begin
            force DO_DQ1 = ((bitOut==oldbitOut)? oldbitOut: 1'bX);
            force DI_DQ0 = ((bitOut_extra==oldbitOut_extra)? oldbitOut_extra: 1'bX); 
        end
        
        #(tCLQV -tCLQX) begin
            force DO_DQ1 = bitOut;
            force DI_DQ0 = bitOut_extra;
             
            oldbitOut = bitOut;
            oldbitOut_extra = bitOut_extra;       
        end        

    join





always @sendToBus_quad fork

      begin
           
          force HOLD_DQ3 = ((bitOut3==oldbitOut3)? oldbitOut3: 1'bX); 
          force WP_DQ2 = ((bitOut2==oldbitOut2)? oldbitOut2: 1'bX);
          force DO_DQ1 = ((bitOut1==oldbitOut1)? oldbitOut1: 1'bX);
          force DI_DQ0 = ((bitOut0==oldbitOut0)? oldbitOut0: 1'bX); 
      end
        
      #(tCLQV-tCLQX) begin
           
          force HOLD_DQ3 = bitOut3;
          force WP_DQ2 = bitOut2;
          force DO_DQ1 = bitOut1;
          force DI_DQ0 = bitOut0;

          oldbitOut3 = bitOut3;
          oldbitOut2 = bitOut2;
          oldbitOut1 = bitOut1;
          oldbitOut0 = bitOut0;
        end        

    join


always @(negedge CS) begin
     oldbitOut=1'bZ;
     oldbitOut_extra=1'bZ;
     oldbitOut3=1'bZ;
     oldbitOut2=1'bZ;
     oldbitOut1=1'bZ;
     oldbitOut0=1'bZ;
    end

//-----------------------
//  Reset By PowerOn
//-----------------------

event resetEvent; 


    always @reset_by_powerOn if (!reset_by_powerOn) begin : CP_reset

        ->resetEvent;
        
        cmdRecName = "";
        ck_count = 0;
        latchingMode = "N";
        cmd='h0;
        addrLatch='h0;
        addr='h0;
        data='h0;
        dataOut='h0;

        iCmd = cmdDim - 1;
        iAddr = addrDimLatch - 1;
        iData = dataDim - 1;
        
        WrapLength=8;
        QuadDummy=2;

        -> stat1.getNVSR1;
        -> stat2.getNVSR2;
//        -> stat3.getNVSR3;
         
        #0 if (`SRP1==1 && `SRP0==0) 
            `SRP1=0;

//        stat2.SR2[6] = 0; 
        // commands waiting to be executed are disabled internally
        
        // read enabler are resetted internally, in the read processes
        
        // CUIdecoders are internally disabled by reset signal
        
        #0 $display("  [%0t ns] ==INFO== VCC has been driven high : internal logic will be reset by power on.", $time);

    end



//-----------------------
// Software Reset 
//-----------------------

   reg  Reset_enable= 0;
    always @(seqRecognized) if (cmdRecName=="Enable Reset") fork : REN 
        
        begin : exe
          @(posedge FM25Q08A.CS); 
          disable reset;
          Reset_enable= 1;
          $display("  [%0t ns] Command execution: Reset Enable.", $time);
        end

        begin : reset
          @FM25Q08A.resetEvent;
          disable exe;
        end
    
    join


 always @(seqRecognized) if (cmdRecName=="Reset") begin : SW_reset
        
    if(Reset_enable==1) begin
    	
        
        Reset_enable=0;        
        release DO_DQ1;
        
        busy=1;
        $display("  [%0t ns] Device is reseting...",$time);
        
        #RSTlatency;
        
        ->resetEvent;       
        ck_count = 0;
        latchingMode = "N";
        cmd='h0;
        addrLatch='h0;
        addr='h0;
        data='h0;
        dataOut='h0;

        iCmd = cmdDim - 1;
        iAddr = addrDimLatch - 1;
        iData = dataDim - 1;
        
        WrapLength=8;
        QuadDummy=2;
        
        -> stat1.getNVSR1;
        -> stat2.getNVSR2;

        // commands waiting to be executed are disabled internally
        
        // read enabler are resetted internally, in the read processes
        
        // CUIdecoders are internally disabled by reset signal
        
        $display("  [%0t ns] ==INFO== Software reset : internal logic has been reset.",$time);
        
        busy=0;
        
     end else $display("  [%0t ns] **WARNING** A reset-enable command is required before the Reset command: operation aborted!", $time);

 end


always @(seqRecognized) if (cmdRecName!="Reset" && Reset_enable==1) begin 
        Reset_enable=0;
end




//-----------------------
//     QPI protocol
//-----------------------


    always @seqRecognized if (cmdRecName=="Enable QPI")  begin
         
          if(`QE!==1)
            $display("  [%0t ns] **WARNING** QE bit not set: operation aborted!", $time);
          else begin
            @(posedge CS);
            protocol="QPI";
            $display("  [%0t ns] Device is entering in QPI mode...",$time);
          end
          end



    always @seqRecognized if (cmdRecName=="Disable QPI")  begin
         
          if(protocol=="SPI")
            $display("  [%0t ns] **WARNING** Wrong Protocol: operation aborted!", $time);
          else begin
            @(posedge CS);
            protocol="SPI";
            $display("  [%0t ns] Device is entering in SPI mode...",$time);
          end
          end




//-----------------------
//     Power Down 
//-----------------------


    always @seqRecognized if (cmdRecName=="Power Down") fork : CP_PowerDown

        begin : exe
          @(posedge CS);
          disable reset;
          busy=1;
          $display("  [%0t ns] Device is entering in deep power down mode...",$time);
          #deep_power_down_delay;
          $display("  [%0t ns] ...power down mode activated.",$time);
          busy=0;
          deep_power_down=1;
        end

        begin : reset
          @resetEvent;
          disable exe;
        end

    join


    always @seqRecognized if (cmdRecName=="Release Power Down" && deep_power_down) fork : CP_releaseDeepPowerDown

        begin
          @(posedge CS);
          disable reset;
//          disable release_and_readID;
          busy=1;
          $display("  [%0t ns] Release from power down is ongoing...",$time);
          #release_power_down_delay_1;
          $display("  [%0t ns] ...release from power down mode completed.",$time);
          busy=0;
          deep_power_down=0;
        end 
/*
        begin :  release_and_readID       
            if(protocol=="SPI")
		        dummyDimEff = 24;//3 dummy bytes, as 24 dummy clocks
            else if(protocol=="QPI")
                dummyDimEff = 6;//3 dummy bytes, as 6 dummy clocks
            $display("  [%0t ns] %0d Dummy Cycles expected ...", $time, FM25Q08A.dummyDimEff);
            iDummy = dummyDimEff - 1;
            latchingMode="Y"; //Y=dummy
            @dummyLatched;
            
			read.enable_DevID = 1;
            latchingMode="N";
            disable release_only;
            
			@(posedge CS);
            read.enable_DevID = 0;
            disable reset;
            busy=1;
            $display("  [%0t ns] Release from power down is ongoing...",$time);
            #release_power_down_delay_2;
            $display("  [%0t ns] ...release from power down mode completed.",$time);
            busy=0;
            deep_power_down=0;
        end
*/
        begin : reset
          @resetEvent;
          disable CP_releaseDeepPowerDown;
        end

    join






endmodule




/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           PROGRAM MODULE                              --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ns

module Program;

    

    `include "include/FM_DevParam.h"

    

    
    event errorCheck, error, noError;
    
    reg [40*8:1] operation; //get the value of the command currently decoded by CUI decoders
    reg [40*8:1] oldOperation; 
    reg [40*8:1] holdOperation;

    time delay,delay_resume,startTime,latencyTime;                 
                                 

    reg [pageAddrDim-1:0] page_susp; 
 

    reg [sectorAddrDim-1:0] sec_susp, page_susp_sec;
    reg [subblockAddrDim-1:0] sub_susp, page_susp_sub;
    reg [blockAddrDim-1:0] blk_susp, page_susp_blk;

    reg Suspended = 0;
    reg prog_susp = 0;//page program suspend
    reg sec_erase_susp =0;//sector erase suspend
    reg sub_erase_susp =0;//subblock(32KB) erase suspend
    reg blk_erase_susp =0;//block(64KB) erase suspend


    //----------------------------------
    //  Page Program & Quad Program
    //----------------------------------


    reg writePage_en=0;
    reg [addrDim-1:0] destAddr, olddestAddr;



    always @FM25Q08A.seqRecognized 
    if(FM25Q08A.cmdRecName=="Page Program" || FM25Q08A.cmdRecName=="Quad Page Program")

       if(prog_susp) begin
                $display("  [%0t ns] **WARNING** It's not allowed to perform a program instruction after a program suspend",$time); 
                disable program_ops;

       end else if(sec_erase_susp && sec_susp==f.sec(FM25Q08A.addr)) begin
           
                $display("  [%0t ns] **WARNING** It's not allowed to perform a program instruction in the sector whose erase cycle is suspended",$time); 
                disable program_ops;

       end else if(sub_erase_susp && sub_susp==f.sub(FM25Q08A.addr)) begin
           
                $display("  [%0t ns] **WARNING** It's not allowed to perform a program instruction in the subblock whose erase cycle is suspended",$time); 
                disable program_ops;

       end else if(blk_erase_susp && blk_susp==f.blk(FM25Q08A.addr)) begin
           
                $display("  [%0t ns] **WARNING** It's not allowed to perform a program instruction in the block whose erase cycle is suspended",$time); 
                disable program_ops;

       end else if(FM25Q08A.cmdRecName=="Quad Page Program" && FM25Q08A.protocol=="SPI" && `QE!==1) begin
           
                $display("  [%0t ns] **WARNING** QE bit not set: operation aborted!", $time); 
                disable program_ops;

       end else

       
    fork : program_ops

           begin

            operation = FM25Q08A.cmdRecName;
            mem.resetPage;
            destAddr = FM25Q08A.addr;
            mem.setAddr(destAddr);
            
            if(operation=="Page Program")
                FM25Q08A.latchingMode="D";
            else if(operation=="Quad Page Program") begin
                FM25Q08A.latchingMode="Q";
                release FM25Q08A.DO_DQ1;
                release FM25Q08A.WP_DQ2;
                release FM25Q08A.HOLD_DQ3;
               
            end
  
            
            writePage_en = 1;

          end   
                                                                                                                                                                                    

        begin : exe
            
           @(posedge FM25Q08A.CS);
            disable reset;
            writePage_en=0;
            FM25Q08A.latchingMode="N";
            FM25Q08A.busy=1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: %0s.", $time, operation);
            
                delay=program_delay;

                -> errorCheck;

                @(noError) begin
                   mem.programPageToMemory;
                    $display("  [%0t ns] Command execution completed: %0s.", $time, operation);
                end
           
        end 


        begin : reset
        
          @FM25Q08A.resetEvent;
            writePage_en=0;
            operation = "None";
            disable exe;    
        
        end

    join



    always @FM25Q08A.dataLatched if(writePage_en) begin

        mem.writeDataToPage(FM25Q08A.data);

    end
 
 



    //------------------------------
    //  Volatile SR Write Enable
    //------------------------------

    reg VSR_enable=0;

    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Volatile SR Write Enable") begin
      
          @(posedge FM25Q08A.CS); 
          VSR_enable= 1;
          $display("  [%0t ns] Command execution: Volatile SR Write Enable.", $time);

          end





    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName!="Write Status Register1" && FM25Q08A.cmdRecName!="Write Status Register2" && FM25Q08A.cmdRecName!="Write Status Register3" && VSR_enable==1) begin 
        VSR_enable=0;
        end



    //------------------------
    //  Write Status register
    //------------------------

    reg [srdataDim-1:0] SR_data1, SR_data2;

    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Write Status Register1") begin : write_SR1_ops

            FM25Q08A.latchingMode="S";
            @(FM25Q08A.srdataLatched);
            SR_data1 = FM25Q08A.srdata;

            fork

              begin : onebyte 
               @(posedge FM25Q08A.CS);
               disable twobyte;
//               SR_data2 = 'h00;
                SR_data2[7]=`DRV1;
                SR_data2[6]=`DRV0;
                SR_data2[5]=0;
                SR_data2[4]=`CMP;
                SR_data2[3]=`LB1;
                SR_data2[2]=`LB0;
                SR_data2[1]=`QE;
                SR_data2[0]=`SRP1;
              end

              begin : twobyte 
               @(FM25Q08A.srdataLatched); 
               disable onebyte;
               SR_data2 = FM25Q08A.srdata;
               @(posedge FM25Q08A.CS);
             end

            join

            operation=FM25Q08A.cmdRecName;
            FM25Q08A.latchingMode="N";          
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Write Status Register1",$time);
            if(VSR_enable==1) begin
                 delay=write_VSR_delay;
                 FM25Q08A.busy=0;
            end else begin
                 delay=write_SR_delay;
                 FM25Q08A.busy=1;
            end
            -> errorCheck;

            @(noError) begin
                 
                `DRV1 = SR_data2[7];
                `DRV0 = SR_data2[6];
                `CMP  = SR_data2[4];
                `LB1  = SR_data2[3] || `LB1;
                `LB0  = SR_data2[2] || `LB0;
                `QE   = SR_data2[1] || (`QE && FM25Q08A.protocol=="QPI");
                `SRP1 = SR_data2[0] || `SRP1;
           
                `SRP0 = SR_data1[7];
                `SEC  = SR_data1[6];
                `TB   = SR_data1[5];
                `BP2  = SR_data1[4];
                `BP1  = SR_data1[3];
                `BP0  = SR_data1[2];

                 if(VSR_enable !== 1) begin
                    -> FM25Q08A.stat1.writeNVSR1;
                    -> FM25Q08A.stat2.writeNVSR2;
                 end
 
             #0 $display("  [%0t ns] Command execution completed: Write Status Register1.\n \tStatus Register 1:\tSRP0=%b\tSEC=%b\tTB=%b\tBP2=%b\tBP1=%b\tBP0=%b\n \tStatus Register 2:\tDRV1=%b\tDRV0=%b\tCMP=%b\tLB1=%b\tLB0=%b\tQE=%b\tSRP1=%b", $time, `SRP0, `SEC, `TB, `BP2, `BP1, `BP0, `DRV1, `DRV0, `CMP, `LB1, `LB0, `QE, `SRP1);
            end
   
    end

    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Write Status Register2") begin : write_SR2_ops

            FM25Q08A.latchingMode="S";
            @(FM25Q08A.srdataLatched);
            SR_data2 = FM25Q08A.srdata;

            operation=FM25Q08A.cmdRecName;
            FM25Q08A.latchingMode="N";          
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Write Status Register2",$time);
            if(VSR_enable==1) begin
                 delay=write_VSR_delay;
                 FM25Q08A.busy=0;
            end else begin
                 delay=write_SR_delay;
                 FM25Q08A.busy=1;
            end
            -> errorCheck;

            @(noError) begin
                 
                `DRV1 = SR_data2[7];
                `DRV0 = SR_data2[6];
                `CMP  = SR_data2[4];
                `LB1  = SR_data2[3] || `LB1;
                `LB0  = SR_data2[2] || `LB0;
                `QE   = SR_data2[1] || (`QE && FM25Q08A.protocol=="QPI");
                `SRP1 = SR_data2[0] || `SRP1;
           
                 if(VSR_enable !== 1) begin
                    -> FM25Q08A.stat2.writeNVSR2;
                 end
 
             #0 $display("  [%0t ns] Command execution completed: Write Status Register2.\n \tStatus Register 2:\tDRV1=%b\tDRV0=%b\tCMP=%b\tLB1=%b\tLB0=%b\tQE=%b\tSRP1=%b", $time, `DRV1, `DRV0, `CMP, `LB1, `LB0, `QE, `SRP1);
            end
   
    end
    
/*    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Write Status Register3") begin : write_SR3_ops

            FM25Q08A.latchingMode="S";
            @(FM25Q08A.srdataLatched);
            SR_data3 = FM25Q08A.srdata;

            operation=FM25Q08A.cmdRecName;
            FM25Q08A.latchingMode="N";          
            startTime = $time;
            $display("  [%0t ns] Command execution begins: Write Status Register3",$time);
            if(VSR_enable==1) begin
                 delay=write_VSR_delay;
                 FM25Q08A.busy=0;
            end else begin
                 delay=write_SR_delay;
                 FM25Q08A.busy=1;
            end
            -> errorCheck;

            @(noError) begin
                 
                `DRV1   = SR_data3[1];
                `DRV0   = SR_data3[0];
           
                 if(VSR_enable !== 1) begin
                    -> FM25Q08A.stat3.writeNVSR3;
                 end
 
             #0 $display("  [%0t ns] Command execution completed: Write Status Register3.\n \tStatus Register 3:\tDRV1=%b\tDRV0=%b", $time, `DRV1, `DRV0);
            end
   
    end
*/

    //--------------
    // Erase
    //--------------

    always @FM25Q08A.seqRecognized 
    
    if (FM25Q08A.cmdRecName==="Sector Erase" || FM25Q08A.cmdRecName==="Subblock Erase" ||
        FM25Q08A.cmdRecName==="Block Erase" || FM25Q08A.cmdRecName==="Chip Erase")   begin : erase_ops
          
        if(prog_susp) begin

                 if(FM25Q08A.cmdRecName==="Sector Erase" && page_susp_sec==f.sec(FM25Q08A.addr)) begin
           
                 $display("  [%0t ns] **WARNING** It's not allowed to perform an erase instruction in the sector whose page program cycle is suspended",$time);
                 disable erase_ops;

                 end else if(FM25Q08A.cmdRecName==="Subblock Erase" && page_susp_sub==f.sub(FM25Q08A.addr)) begin

                 $display("  [%0t ns] **WARNING** It's not allowed to perform an erase instruction in the subblock whose page program cycle is suspended",$time);
                 disable erase_ops;

                 end else if(FM25Q08A.cmdRecName==="Block Erase" && page_susp_blk==f.blk(FM25Q08A.addr)) begin

                 $display("  [%0t ns] **WARNING** It's not allowed to perform an erase instruction in the block whose page program cycle is suspended",$time);
                 disable erase_ops;

                 end else if(FM25Q08A.cmdRecName==="Chip Erase") begin

                 $display("  [%0t ns] **WARNING** It's not allowed to perform an erase instruction in the chip whose page program cycle is suspended",$time);
                 disable erase_ops;

                 end

        end else  if(sec_erase_susp || sub_erase_susp || blk_erase_susp) begin
        
                 $display("  [%0t ns] **WARNING** It's not allowed to perform an erase instruction after a erase suspend",$time); 
                 disable erase_ops;

     
        end   
   
        fork 

        begin : exe
        
           @(posedge FM25Q08A.CS);

            disable reset;
             

            operation = FM25Q08A.cmdRecName;
            destAddr = FM25Q08A.addr;
            FM25Q08A.latchingMode="N";
            FM25Q08A.busy = 1;
            startTime = $time;
            $display("  [%0t ns] Command execution begins: %0s.", $time, operation);
            if (operation=="Sector Erase") delay=erase_sector_delay;
            else if (operation=="Subblock Erase")  delay=erase_subblock_delay; 
            else if (operation=="Block Erase")  delay=erase_block_delay;
            else if (operation=="Chip Erase") delay=erase_chip_delay;
            
            -> errorCheck;

            @(noError) begin
                if (operation=="Sector Erase")          mem.eraseSector(destAddr);
                else if (operation=="Subblock Erase")   mem.eraseSubblock(destAddr); 
                else if (operation=="Block Erase")      mem.eraseBlock(destAddr);
                else if (operation=="Chip Erase")       mem.eraseChip;
                $display("  [%0t ns] Command execution completed: %0s.", $time, operation);
             end
			 
			//disable reset;
        end


        begin : reset
        
          @FM25Q08A.resetEvent;
            operation = "None";
            disable exe;    
        
        end

            
    join

end


//------------------------
// Erase Program Suspend
//-------------------------

/*
 always @FM25Q08A.seqRecognized 
    
    if (FM25Q08A.cmdRecName==="Erase Program Suspend" && `SUS==0 && `WIP==1) begin
    
        if (operation!=="Quad Page Program" && operation!=="Page Program" && operation!=="Sector Erase" && operation!=="Subblock Erase" && operation!=="Block Erase") 
             $display("  [%0t ns] %0s can't be suspended", $time, operation);

        else fork : progerasesusp_ops

        
        begin : exe
        
           @(posedge FM25Q08A.CS);

            disable reset;    
            oldOperation = operation;
            olddestAddr = destAddr;
            operation = FM25Q08A.cmdRecName;
            FM25Q08A.latchingMode="N";
            #SUSlatency; 
            FM25Q08A.busy = 0; //WIP = 0
            Suspended = 1;//SUS = 1
            
            if (oldOperation=="Sector Erase") begin
                    delay_resume=erase_sector_delay-($time - startTime);
                    sec_erase_susp = 1;
                    sec_susp= f.sec(destAddr);
                    disable erase_ops;
                    disable errorCheck_ops;

        end else if (oldOperation=="Subblock Erase") begin
                    delay_resume=erase_subblock_delay-($time - startTime);
                    sub_erase_susp = 1;
                    sub_susp= f.sub(destAddr);
                    disable erase_ops;
                    disable errorCheck_ops;

        end else if (oldOperation=="Block Erase") begin
                    delay_resume=erase_block_delay-($time - startTime);
                    blk_erase_susp = 1;
                    blk_susp= f.blk(destAddr);
                    disable erase_ops;
                    disable errorCheck_ops;

        end else if (oldOperation=="Page Program" || oldOperation=="Quad Page Program") begin
  
                       delay_resume = program_delay-($time - startTime);
                       prog_susp = 1;
                       page_susp = f.pag(destAddr);
                       page_susp_sec = f.sec(destAddr);
                       page_susp_sub = f.sub(destAddr);
                       page_susp_blk = f.blk(destAddr);
                       disable program_ops;
                       disable errorCheck_ops;
              end


        end


        begin : reset
        
          @FM25Q08A.resetEvent;
            operation = "None";
            disable exe;    
        
        end

            
    join

  end
i*/

 //------------------------
 // Erase Program Resume
 //-------------------------

/*
always @FM25Q08A.seqRecognized 
    
    if (FM25Q08A.cmdRecName==="Erase Program Resume") fork :resume_ops

                                                                                                                                                                             

        begin : exe
            
           @(posedge FM25Q08A.CS);
            
            disable reset;
            operation = FM25Q08A.cmdRecName;
            FM25Q08A.latchingMode="N";
            delay=delay_resume;
            #SUSlatency; 
            Suspended=0;// SUS = 0
            FM25Q08A.busy=1;// WIP = 1
            
            -> errorCheck;

            @(noError) begin
                
                if (oldOperation=="Sector Erase")  begin
                    mem.eraseSector(olddestAddr);
                    sec_erase_susp = 0;
                end    
                else if (oldOperation=="Subblock Erase") begin
                    mem.eraseSubblock(olddestAddr); 
                    sub_erase_susp = 0;
                end    
                else if (oldOperation=="Block Erase") begin
                    mem.eraseBlock(olddestAddr); 
                    blk_erase_susp = 0;
                end                     
                else begin
                    mem.setAddr(olddestAddr);
                    mem.programPageToMemory;
                    prog_susp = 0;
                end 
                
                $display("  [%0t ns] Command execution completed: %0s.", $time, oldOperation);
  
            end
                
        end 


        begin : reset
        
          @FM25Q08A.resetEvent;
            operation = "None";
            disable exe;    
        
        end

    join


*/

    //---------------------------
    //  Program Security Sectors 
    //---------------------------

    
        reg write_SecuSec_buffer_en=0;

        always @FM25Q08A.seqRecognized if(FM25Q08A.cmdRecName=="Program Security Sectors")

        fork : SecuSec_prog_ops

            begin
                SecuSec.resetBuffer;
                SecuSec.setAddr(FM25Q08A.addr);
                FM25Q08A.latchingMode="D";
                write_SecuSec_buffer_en = 1;
            end

            begin : exe
               @(posedge FM25Q08A.CS);
                operation=FM25Q08A.cmdRecName;
                write_SecuSec_buffer_en=0;
                FM25Q08A.latchingMode="N";
                FM25Q08A.busy=1;
                startTime = $time;
                $display("  [%0t ns] Command execution begins: Security Sectors Program.",$time);
                delay=program_delay;
                -> errorCheck;

                @(noError) begin
                    case (SecuSec.sec)
                    2'b00: SecuSec.writeBufferToSecuSec0;
                    2'b01: SecuSec.writeBufferToSecuSec1;
                    2'b10: SecuSec.writeBufferToSecuSec2;
                    2'b11: SecuSec.writeBufferToSecuSec3;
                    endcase
                    $display("  [%0t ns] Command execution completed: Security Sectors Program.",$time);
                end
            end  


        join



        always @FM25Q08A.dataLatched if(write_SecuSec_buffer_en) begin

            SecuSec.writeDataToBuffer(FM25Q08A.data);
        
        end





    //---------------------------
    //  Erase Security Sectors 
    //---------------------------



        always @FM25Q08A.seqRecognized if(FM25Q08A.cmdRecName=="Erase Security Sectors")

        fork : SecuSec_erase_ops

            begin : exe
                SecuSec.setAddr(FM25Q08A.addr); 
               @(posedge FM25Q08A.CS);
                operation=FM25Q08A.cmdRecName;
                FM25Q08A.latchingMode="N";
                FM25Q08A.busy=1;
                startTime = $time;
                $display("  [%0t ns] Command execution begins: Security Sectors Erase.",$time);
                delay=erase_sector_delay;
                -> errorCheck;

                @(noError) begin
                    SecuSec.eraseSecuSec;
                    $display("  [%0t ns] Command execution completed: Security Sectors Erase.",$time);
                end
            end  


        join








    //------------------------
    //  Error check
    //------------------------
    // This process also models  
    // the operation delays
    

    always @(errorCheck) fork : errorCheck_ops
    
    
        begin : static_check

            if (operation=="Quad Page Program" && FM25Q08A.ck_count!=0 && FM25Q08A.ck_count!=2 && 
                         FM25Q08A.ck_count!=4 && FM25Q08A.ck_count!=6) begin 
                        FM25Q08A.f.clock_error;
                        -> error;
            end else if(operation == "Page Program" && FM25Q08A.ck_count!=0) begin 
                FM25Q08A.f.clock_error;
                -> error;
                            
            end else if(operation!="Write Status Register1" && operation!="Write Status Register2" && operation!="Write Status Register3" && `WEL==0) begin
               
                FM25Q08A.f.WEL_error;
                -> error;
            
            end 
            else if ( (operation=="Page Program" || operation=="Quad Page Program" || operation=="Sector Erase") && (lock.isSectorProtected_by_SR(destAddr)!==0) ) begin
           
                 $display("  [%0t ns] **WARNING** Sector locked by Status Register: operation aborted.", $time);
                 -> error;
            
            end else if ( (operation=="Subblock Erase") && (lock.isSubblockProtected_by_SR(destAddr)!==0) ) begin
           
                 $display("  [%0t ns] **WARNING** Subblock locked by Status Register: operation aborted.", $time);
                 -> error;
                 
            end else if ( (operation=="Block Erase") && (lock.isBlockProtected_by_SR(destAddr)!==0) ) begin
           
                 $display("  [%0t ns] **WARNING** Block locked by Status Register: operation aborted.", $time);
                 -> error;
            
            end else if (operation=="Chip Erase" && lock.isAnyBlockProtected(0)) begin
                
                 $display("  [%0t ns] **WARNING** Some sectors are locked: chip erase aborted.", $time);
                 -> error;
            

            end 
            else if(operation=="Write Status Register1" || operation=="Write Status Register2" || operation=="Write Status Register3") begin

                 if(`SRP1==0 && `SRP0==1 && FM25Q08A.W_int==0) begin
                  $display("  [%0t ns] **WARNING** Status Register is Hardware Protected: write status register isn't allowed!", $time);
                  -> error;

                 end else if (`SRP1==1 && `SRP0==0) begin
                  $display("  [%0t ns] **WARNING** Status Register is Power Supply Lock-Down: write status register isn't allowed!", $time);
                  -> error;

                 end else if (`SRP1==1 && `SRP0==1) begin
                  $display("  [%0t ns] **WARNING** Status Register is permanently protected: write status register isn't allowed!", $time);
                  -> error;
     
                 end else if (`WEL==0 && VSR_enable==0) begin
                  $display("  [%0t ns] **WARNING** WEL bit not set, and Volatile Status Register disable: write status register isn't allowed!", $time);
                  -> error;
                 end
               
 

            end 
            else if (operation=="Program Security Sectors" || operation=="Erase Security Sectors") 
                    if ((SecuSec.sec[1]==0&&`LB0==1)||(SecuSec.sec[1]==1&&`LB1==1)) begin
                    $display("  [%0t ns] **WARNING** Security Sector is read only, because the corresponding lock bit has been programmed to 1: operation aborted.", $time);
                    -> error;
                    end
            
        end


        fork : dynamicCheck

            @(FM25Q08A.voltageFault) begin
                $display("  [%0t ns] **WARNING** Operation Fault because of VCC Out of Range!", $time);
                -> error;
            end
            
            #delay begin 
            FM25Q08A.busy=0;
                if(!Suspended) -> stat1.WEL_reset;
                -> noError;
                disable dynamicCheck;
                disable errorCheck_ops;
            end
        join

        
    join




    always @(error) begin

        FM25Q08A.busy = 0;
        -> stat1.WEL_reset;
//        stat2.SR2[6] = 1;
        disable errorCheck_ops;
        if (operation=="Page Program" || operation=="Quad Page Program") disable program_ops;
        else if (operation=="Sector Erase" || operation=="Subblock Erase" || operation=="Block Erase" || operation=="Chip Erase") disable erase_ops;
        else if (operation=="Write Status Register1") disable write_SR1_ops;
        else if (operation=="Write Status Register2") disable write_SR2_ops;
//        else if (operation=="Write Status Register3") disable write_SR3_ops;
        else if (operation=="Program Security Sectors") disable SecuSec_prog_ops;
        else if (operation=="Erase Security Sectors") disable SecuSec_erase_ops;
    end






endmodule

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           READ MODULE                                 --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module Read;


    `include "include/FM_DevParam.h"
    
   
   

    reg wrap_enable=0;
    reg contin_enable=0;
    reg enable_quadwrap=0;
    reg [cmdDim-1:0] Mcommand;//store current command for continuous read mode 

    reg enable;
    //--------------
    //  Read
    //--------------
    // NB : "Read" operation is also modelled in FM25Q08A.module
    
    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Read Data") fork 
        
        begin
           
            if(prog.prog_susp && prog.page_susp==f.pag(FM25Q08A.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
            else begin    
                enable = 1;
                mem.setAddr(FM25Q08A.addr);
            end    
        end
        
        @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault) 
            enable=0;
        
    join





    //--------------
    //  Read Fast
    //--------------
    reg enable_fast;// for the fast read command 

    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Fast Read") fork :READFAST_d

        begin
            if(prog.prog_susp && prog.page_susp==f.pag(FM25Q08A.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
            else begin 
            mem.setAddr(FM25Q08A.addr);
			
			if(FM25Q08A.protocol=="SPI")
		        FM25Q08A.dummyDimEff=8;
            else if(FM25Q08A.protocol=="QPI") 
                FM25Q08A.dummyDimEff=FM25Q08A.QuadDummy;//QuadDummy used for QPI mode and configed by command Set Read Parameters.            
            $display("  [%0t ns] %0d Dummy Cycles expected ...", $time, FM25Q08A.dummyDimEff);
		    FM25Q08A.iDummy = FM25Q08A.dummyDimEff - 1;
            FM25Q08A.latchingMode="Y"; //Y=dummy
            @FM25Q08A.dummyLatched;
            
			enable_fast = 1;
            FM25Q08A.latchingMode="N";

            end
        end

        @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
            enable_fast=0;

            disable READFAST_d;
        end   
    
    join


   //-------------------------------
   //  Release Power Down Device ID
   //-------------------------------

    reg enable_DevID;

    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Release Power Down Device ID") fork

        begin
/*            
            if(FM25Q08A.protocol=="SPI")
	    	    FM25Q08A.dummyDimEff = 24;//3 dummy bytes, as 24 dummy clocks
            else if(FM25Q08A.protocol=="QPI")
                FM25Q08A.dummyDimEff = 6;//3 dummy bytes, as 6 dummy clocks
            $display("  [%0t ns] %0d Dummy Cycles expected ...", $time, FM25Q08A.dummyDimEff);
            FM25Q08A.iDummy = FM25Q08A.dummyDimEff - 1;
            FM25Q08A.latchingMode="Y"; //Y=dummy
            @FM25Q08A.dummyLatched;
*/            
			enable_DevID = 1;
//            FM25Q08A.latchingMode="N";

        end

        @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault)
            enable_DevID = 0;
    
    join





    //-----------------------------
    //  Read Manufacturer Device ID
    //-----------------------------

    reg enable_ManDevID;

    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Read Manufacturer Device ID") fork 
        
        begin
            enable_ManDevID = 1;
        end
        
        @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault)
            enable_ManDevID=0;
        
    join


    //---------------------------------------
    // Read Manufacturer Device ID Dual IO
    //---------------------------------------

    reg enable_ManDevID_Dual;

    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Read Manufacturer Device ID Dual IO") fork 
        
        begin
            FM25Q08A.latchingMode="M"; //M=Continuous Mode bits M7-M0
            @FM25Q08A.mbitsLatched;
            $display("  [%0t ns] Continuous Read Mode bits latched: (M5,M4) = (%b,%b).", $time, FM25Q08A.mbits[5], FM25Q08A.mbits[4]);
            if(FM25Q08A.mbits[5:4]==2'b10) begin
              contin_enable=1;
              Mcommand='h92;
            end else begin
            	contin_enable=0;
            	Mcommand='h0;
            end
            enable_ManDevID_Dual = 1;
            FM25Q08A.latchingMode="N";
        end
        
        @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault)
            enable_ManDevID_Dual =0;
        
    join


    //---------------------------------------
    // Read Manufacturer Device ID Quad IO
    //---------------------------------------

    reg enable_ManDevID_Quad;

    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Read Manufacturer Device ID Quad IO") fork 
        
            if (`QE!==1)
                 $display("  [%0t ns] **WARNING** QE bit not set: operation aborted!", $time);
            else begin
                 FM25Q08A.latchingMode="M"; //M=Continuous Mode bits M7-M0
            @FM25Q08A.mbitsLatched;
			$display("  [%0t ns] Continuous Read Mode bits latched: (M5,M4) = (%b,%b).", $time, FM25Q08A.mbits[5], FM25Q08A.mbits[4]);
            if(FM25Q08A.mbits[5:4]==2'b10) begin
              contin_enable=1;
              Mcommand='h94;
            end else begin
              contin_enable=0;
              Mcommand='h0;
            end
            
			FM25Q08A.dummyDimEff = 4;//4 dummy clocks
            $display("  [%0t ns] %0d Dummy Cycles expected ...", $time, FM25Q08A.dummyDimEff);
            FM25Q08A.iDummy = FM25Q08A.dummyDimEff - 1;
            FM25Q08A.latchingMode="Y"; //Y=dummy
            @FM25Q08A.dummyLatched;
            
			enable_ManDevID_Quad = 1;
            FM25Q08A.latchingMode="N";
            end
        
        @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault)
            enable_ManDevID_Quad =0;
        
    join


    //------------------
    //  Read JEDEC ID
    //------------------

    reg enable_JEDEC;

    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Read JEDEC ID") fork 
        
        begin
            enable_JEDEC = 1;
        end
        
        @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault)
            enable_JEDEC = 0;
        
    join


    //----------------
    // Read Unique ID 
    //----------------

    reg enable_UID;

    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Read Unique ID") fork 
        
        begin
            FM25Q08A.dummyDimEff = 32;//4 dummy bytes,32 dummy clocks
            $display("  [%0t ns] %0d Dummy Cycles expected ...", $time, FM25Q08A.dummyDimEff);
            FM25Q08A.iDummy = FM25Q08A.dummyDimEff - 1;
            FM25Q08A.latchingMode="Y"; //Y=dummy
            @FM25Q08A.dummyLatched;
            enable_UID = 1;
            FM25Q08A.latchingMode="N";
        end
        
        @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault)
            enable_UID =0;
        
    join


    //--------------------------
    //  Read Security Sectors 
    //--------------------------
    // NB : "Read Security Sectors" operation is also modelled in FM25Q08A.module

    reg enable_SecuSec=0;
       
      always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Read Security Sectors") fork 
        
          begin
		      
		      SecuSec.setAddr(FM25Q08A.addr); //SecuSec:Security Sectors

              FM25Q08A.dummyDimEff = 8;//8 dummy clocks
              $display("  [%0t ns] %0d Dummy Cycles expected ...", $time, FM25Q08A.dummyDimEff);
              FM25Q08A.iDummy = FM25Q08A.dummyDimEff - 1;
              FM25Q08A.latchingMode="Y"; //Y=dummy
              @FM25Q08A.dummyLatched;
              
			  enable_SecuSec = 1;
              FM25Q08A.latchingMode="N";             
          end
        
          @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault)
              enable_SecuSec=0;
        
      join
    




    reg enable_dual=0;
    
    //--------------------------
    //  Fast Read Dual Output  
    //--------------------------
    
      always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Fast Read Dual Output") fork :DUAL_0

          begin 

              if(prog.prog_susp && prog.page_susp==f.pag(FM25Q08A.addr)) 
                  $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
              else begin
            
              mem.setAddr(FM25Q08A.addr);

              FM25Q08A.dummyDimEff = 8;//8 dummy clocks
              $display("  [%0t ns] %0d Dummy Cycles expected ...", $time, FM25Q08A.dummyDimEff);
              FM25Q08A.iDummy = FM25Q08A.dummyDimEff - 1;
              FM25Q08A.latchingMode="Y"; //Y=dummy
              @(FM25Q08A.dummyLatched);
              
			  enable_dual = 1;
              FM25Q08A.latchingMode="N";
             end 
          end 

          @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
              enable_dual=0;
              disable DUAL_0;
          end
    
      join


    //--------------------------
    //  Fast Read Dual IO  
    //--------------------------

    
    
      always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Fast Read Dual IO") fork :DUAL_1

          begin 

           if(prog.prog_susp && prog.page_susp==f.pag(FM25Q08A.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
            else begin
              FM25Q08A.latchingMode="M"; //M=Continuous Mode bits M7-M0
              @FM25Q08A.mbitsLatched;
			   $display("  [%0t ns] Continuous Read Mode bits latched: (M5,M4) = (%b,%b).", $time, FM25Q08A.mbits[5], FM25Q08A.mbits[4]);
              if(FM25Q08A.mbits[5:4]==2'b10) begin
                contin_enable=1;
                Mcommand='hBB;
              end else begin
            	  contin_enable=0;
            	  Mcommand='h0;
              end
              mem.setAddr(FM25Q08A.addr);
              enable_dual = 1;
              FM25Q08A.latchingMode="N";
             end 
          end 

          @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
              enable_dual=0;
              disable DUAL_1;
          end
    
      join


    reg enable_quad=0;

  //-------------------------
  //  Fast Read Quad Output 
  //-------------------------
       
      always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Fast Read Quad Output") fork :QUAD_0

          begin
           if(prog.prog_susp && prog.page_susp==f.pag(FM25Q08A.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
                
            else if(prog.sec_erase_susp && prog.sec_susp==f.sec(FM25Q08A.addr)) 
                 $display("  [%0t ns] **WARNING** It's not allowed to read the sector whose erase cycle is suspended",$time);

            else if(prog.sub_erase_susp && prog.sub_susp==f.sub(FM25Q08A.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the subblock whose erase cycle is suspended",$time);

            else if(prog.blk_erase_susp && prog.blk_susp==f.blk(FM25Q08A.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the block whose erase cycle is suspended",$time);
                 
            else if (`QE!==1)
                 $display("  [%0t ns] **WARNING** QE bit not set: operation aborted!", $time);

            else begin
              mem.setAddr(FM25Q08A.addr);

              FM25Q08A.dummyDimEff = 8;//8 dummy clocks
              $display("  [%0t ns] %0d Dummy Cycles expected ...", $time, FM25Q08A.dummyDimEff);
              FM25Q08A.iDummy = FM25Q08A.dummyDimEff - 1;
              FM25Q08A.latchingMode="Y"; //Y=dummy
              @FM25Q08A.dummyLatched;
              
			  enable_quad = 1;
              FM25Q08A.latchingMode="N";

            end
            
          end 

          @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
              enable_quad=0;
              disable QUAD_0;
          end    
    
      join

  //-------------------------
  //  Fast Read Quad IO  
  //-------------------------
       
      always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Fast Read Quad IO") fork :QUAD_1

          begin
            if(prog.prog_susp && prog.page_susp==f.pag(FM25Q08A.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
                
            else if(prog.sec_erase_susp && prog.sec_susp==f.sec(FM25Q08A.addr)) 
                 $display("  [%0t ns] **WARNING** It's not allowed to read the sector whose erase cycle is suspended",$time);

            else if(prog.sub_erase_susp && prog.sub_susp==f.sub(FM25Q08A.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the subblock whose erase cycle is suspended",$time);

            else if(prog.blk_erase_susp && prog.blk_susp==f.blk(FM25Q08A.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the block whose erase cycle is suspended",$time);
            
            else if (`QE!==1)
                 $display("  [%0t ns] **WARNING** QE bit not set: operation aborted!", $time);

            else begin
              mem.setAddr(FM25Q08A.addr);
              
			  FM25Q08A.latchingMode="M"; //M=Continuous Mode bits M7-M0
              @FM25Q08A.mbitsLatched;
			   $display("  [%0t ns] Continuous Read Mode bits latched: (M5,M4) = (%b,%b).", $time, FM25Q08A.mbits[5], FM25Q08A.mbits[4]);
              if(FM25Q08A.mbits[5:4]==2'b10) begin
                contin_enable=1;
                Mcommand='hEB;
              end else begin
            	contin_enable=0;
                Mcommand='h0;
              end

              if(FM25Q08A.protocol=="SPI")
		        FM25Q08A.dummyDimEff = 4;//4 dummy clocks
              else if(FM25Q08A.protocol=="QPI")
                FM25Q08A.dummyDimEff = FM25Q08A.QuadDummy-2;//QuadDummy used for QPI mode and configed by command Set Read Parameters.
              if(FM25Q08A.dummyDimEff!==0) begin
                $display("  [%0t ns] %0d Dummy Cycles expected ...", $time, FM25Q08A.dummyDimEff);
                FM25Q08A.iDummy = FM25Q08A.dummyDimEff - 1;
                FM25Q08A.latchingMode="Y"; //Y=dummy
                @FM25Q08A.dummyLatched;
              end

			  if(wrap_enable==1 && FM25Q08A.protocol=="SPI") begin 
                enable_quadwrap = 1;
		        $display("  [%0t ns] Entering Wrap Around Read Mode with %0d bytes Wrap Length...",$time,FM25Q08A.WrapLength);
		      end else
                enable_quad = 1;
                FM25Q08A.latchingMode="N";
              end
            
           end 

          @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
              enable_quadwrap=0;
              enable_quad=0;
              disable QUAD_1;
          end    
    
      join



  //-------------------------
  //  Word Read Quad IO 
  //-------------------------
       
      always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Word Read Quad IO") fork :QUAD_2

          begin
           if(prog.prog_susp && prog.page_susp==f.pag(FM25Q08A.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
                
            else if(prog.sec_erase_susp && prog.sec_susp==f.sec(FM25Q08A.addr)) 
                 $display("  [%0t ns] **WARNING** It's not allowed to read the sector whose erase cycle is suspended",$time);

            else if(prog.sub_erase_susp && prog.sub_susp==f.sub(FM25Q08A.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the subblock whose erase cycle is suspended",$time);

            else if(prog.blk_erase_susp && prog.blk_susp==f.blk(FM25Q08A.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the block whose erase cycle is suspended",$time);
            
            else if (`QE!==1)
                 $display("  [%0t ns] **WARNING** QE bit not set: operation aborted!", $time);

            else begin
              FM25Q08A.addr[0] = 0;
              mem.setAddr(FM25Q08A.addr);

//              if(FM25Q08A.addr[0]) begin
//                 $display("  [%0t ns] **ERROR** Wrong address for WORD READ QUAD I/O", $time);
//                 disable QUAD_2;
//              end

              FM25Q08A.latchingMode="M"; //M=Continuous Mode bits M7-M0
              @FM25Q08A.mbitsLatched;
			  $display("  [%0t ns] Continuous Read Mode bits latched: (M5,M4) = (%b,%b).", $time, FM25Q08A.mbits[5], FM25Q08A.mbits[4]);
              if(FM25Q08A.mbits[5:4]==2'b10) begin
                contin_enable=1;
                Mcommand='hE7;
              end else begin
              	contin_enable=0;
              	Mcommand='h0;
              end

              FM25Q08A.dummyDimEff = 2;//2 dummy clocks
              $display("  [%0t ns] %0d Dummy Cycles expected ...", $time, FM25Q08A.dummyDimEff);
              FM25Q08A.iDummy = FM25Q08A.dummyDimEff - 1;
              FM25Q08A.latchingMode="Y"; //Y=dummy
              @FM25Q08A.dummyLatched;
			  
			  if(wrap_enable==1) begin
                enable_quadwrap = 1;
		        $display("  [%0t ns] Entering Wrap Around Read Mode with %0d bytes Wrap Length...",$time,FM25Q08A.WrapLength);
              end else
                enable_quad = 1;
              FM25Q08A.latchingMode="N";

            end
            
          end 

          @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
              enable_quad=0;
              enable_quadwrap=0;
              disable QUAD_2;
          end    
    
      join    


  //-------------------------
  // Octal Word Read Quad IO 
  //-------------------------
       
      always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Octal Word Read Quad IO") fork :QUAD_3

          begin
           if(prog.prog_susp && prog.page_susp==f.pag(FM25Q08A.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
                
            else if(prog.sec_erase_susp && prog.sec_susp==f.sec(FM25Q08A.addr)) 
                 $display("  [%0t ns] **WARNING** It's not allowed to read the sector whose erase cycle is suspended",$time);

            else if(prog.sub_erase_susp && prog.sub_susp==f.sub(FM25Q08A.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the subblock whose erase cycle is suspended",$time);

            else if(prog.blk_erase_susp && prog.blk_susp==f.blk(FM25Q08A.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the block whose erase cycle is suspended",$time);
            
            else if (`QE!==1)
                 $display("  [%0t ns] **WARNING** QE bit not set: operation aborted!", $time);

            else begin
              FM25Q08A.addr[1] = 0;
              FM25Q08A.addr[0] = 0;
              mem.setAddr(FM25Q08A.addr);
//              if(FM25Q08A.addr[0]||FM25Q08A.addr[1]||FM25Q08A.addr[2]||FM25Q08A.addr[3]) begin
//                 $display("  [%0t ns] **ERROR** Wrong address for OCTAL WORD READ QUAD I/O", $time);
//                 disable QUAD_3;
//              end
              FM25Q08A.latchingMode="M"; //M=Continuous Mode bits M7-M0
              @FM25Q08A.mbitsLatched;
			   $display("  [%0t ns] Continuous Read Mode bits latched: (M5,M4) = (%b,%b).", $time, FM25Q08A.mbits[5], FM25Q08A.mbits[4]);
              if(FM25Q08A.mbits[5:4]==2'b10) begin
                contin_enable=1;
                Mcommand='hE3;
              end else begin
              	contin_enable=0;
              	Mcommand='h0;
              end
              enable_quad = 1;
              FM25Q08A.latchingMode="N";

            end
            
          end 

          @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
              enable_quad=0;
              disable QUAD_3;
          end    
    
      join    


     

  //-------------------------
  //  Burst Read With Wrap  
  //-------------------------
       
      always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Burst Read With Wrap") fork :QUAD_4

          begin
           if(prog.prog_susp && prog.page_susp==f.pag(FM25Q08A.addr)) 
                $display("  [%0t ns] **WARNING** It's not allowed to read the page whose program cycle is suspended",$time); 
                
            else if(prog.sec_erase_susp && prog.sec_susp==f.sec(FM25Q08A.addr)) 
                 $display("  [%0t ns] **WARNING** It's not allowed to read the sector whose erase cycle is suspended",$time);

            else if(prog.sub_erase_susp && prog.sub_susp==f.sub(FM25Q08A.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the subblock whose erase cycle is suspended",$time);

            else if(prog.blk_erase_susp && prog.blk_susp==f.blk(FM25Q08A.addr))
                 $display("  [%0t ns] **WARNING** It's not allowed to read the block whose erase cycle is suspended",$time);
            
            else if (FM25Q08A.protocol!=="QPI")
                 $display("  [%0t ns] **WARNING** Wrong Protocol: burst read with wrap operation aborted!", $time);

            else begin
              mem.setAddr(FM25Q08A.addr);
              
			  FM25Q08A.dummyDimEff = FM25Q08A.QuadDummy;
              $display("  [%0t ns] %0d Dummy Cycles expected ...", $time, FM25Q08A.dummyDimEff);
              FM25Q08A.iDummy = FM25Q08A.dummyDimEff - 1;
              FM25Q08A.latchingMode="Y"; //Y=dummy
              @FM25Q08A.dummyLatched;
              
			  enable_quadwrap = 1;
			  $display("  [%0t ns] Entering Wrap Around Read Mode with %0d bytes Wrap Length...",$time,FM25Q08A.WrapLength);
              FM25Q08A.latchingMode="N";

            end
            
          end 

          @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
              enable_quadwrap=0;
              disable QUAD_4;
          end    
    
      join 





  //-------------------------
  //  Set Burst With Wrap 
  //-------------------------
       
      always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Set Burst With Wrap") fork :set_wrap
      	 
      	 begin
      	  if (FM25Q08A.protocol=="QPI")
                 $display("  [%0t ns] **WARNING** Wrong Protocol: Set Burst With Wrap operation aborted!", $time);
          else if (`QE!==1)
                 $display("  [%0t ns] **WARNING** QE bit not set: operation aborted!", $time);
          else begin
           /* FM25Q08A.dummyDimEff = 6;
              $display("  [%0t ns] Dummy clock cycles expected ...",$time);
              FM25Q08A.iDummy = FM25Q08A.dummyDimEff - 1;
              FM25Q08A.latchingMode="Y"; //Y=dummy
              @FM25Q08A.dummyLatched;  */
              FM25Q08A.latchingMode="Q"; 
              @FM25Q08A.dataLatched;
			  @FM25Q08A.dataLatched;
			  @FM25Q08A.dataLatched;
			  @FM25Q08A.dataLatched;
              wrap_enable=!FM25Q08A.data[4];
              case(FM25Q08A.data[6:5]) 
              	2'b00:   FM25Q08A.WrapLength=8;
              	2'b01:   FM25Q08A.WrapLength=16;
              	2'b10:   FM25Q08A.WrapLength=32;
              	2'b11:   FM25Q08A.WrapLength=64;
              endcase
			 $display("  [%0t ns] Set Burst With Wrap: Wrap Enable=%0d, Wrap Length Bytes=%0d.",$time,wrap_enable,FM25Q08A.WrapLength);
              FM25Q08A.latchingMode="N";
             end
        end

        @(FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
         	FM25Q08A.WrapLength=8;
                wrap_enable=0;
                disable set_wrap;
         end
        
        @(posedge(FM25Q08A.CS))
                disable set_wrap;
         

join

  //-------------------------
  //  Set Read Parameters 
  //-------------------------

      always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Set Read Parameters") fork :set_readparam

        begin
        	if (FM25Q08A.protocol!=="QPI")
                 $display("  [%0t ns] **WARNING** Wrong Protocol: Set Read Parameters operation aborted!", $time);
          else begin
          	  FM25Q08A.latchingMode="Q"; 
              @FM25Q08A.dataLatched;
              case(FM25Q08A.data[1:0]) 
              	2'b00:   FM25Q08A.WrapLength=8;
              	2'b01:   FM25Q08A.WrapLength=16;
              	2'b10:   FM25Q08A.WrapLength=32;
              	2'b11:   FM25Q08A.WrapLength=64;
              endcase
              case(FM25Q08A.data[5:4]) 
              	2'b00:   FM25Q08A.QuadDummy=2;
              	2'b01:   FM25Q08A.QuadDummy=4;
              	2'b10:   FM25Q08A.QuadDummy=6;
              	2'b11:   FM25Q08A.QuadDummy=8;
              endcase
            $display("  [%0t ns] Set Read Parameters: Wrap Length Bytes=%0d, Dummy Clocks=%0d.", $time, FM25Q08A.WrapLength, FM25Q08A.QuadDummy);
         end
       end
         @(FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
         	      FM25Q08A.WrapLength=8;
                FM25Q08A.QuadDummy=2;
                disable set_readparam;
         end
         @(posedge(FM25Q08A.CS))
                disable set_readparam;
      join 
endmodule

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           MEMORY MODULE                               --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ns

module Memory;

    

    `include "include/FM_DevParam.h"



    //-----------------------------
    // data structures definition
    //-----------------------------

    reg [dataDim-1:0] memory [0:memDim-1];
    reg [dataDim-1:0] page [0:pageDim];




    //------------------------------
    // Memory management variables
    //------------------------------

    reg [addrDim-1:0] memAddr, wrapAddr_inf, wrapAddr_sup;
    reg [addrDim-1:0] pageStartAddr;
    reg [colAddrDim-1:0] pageIndex = 'h0;
    reg [colAddrDim-1:0] zeroIndex = 'h0;

    integer i;



    //-----------
    //  Init
    //-----------

    initial begin 

        for (i=0; i<=memDim-1; i=i+1) 
            memory[i] = data_NP;
          
    
    end



    always @(FM25Q08A.VCC_L2) if((FM25Q08A.VCC_L2) && ( FM25Q08A.memory_file!="" && FM25Q08A.memory_file!=" ")) begin
         
         $readmemh(FM25Q08A.memory_file, memory);
         $display("  [%0t ns] ==INFO== Load memory content from file: \"%0s\".", $time, FM25Q08A.memory_file);
                     

   end      


    //-----------------------------------------
    //  Task used in program & read operations  
    //-----------------------------------------
    

    
    // set start address & page index
    // (for program and read operations)
    
    task setAddr;

    input [addrDim-1:0] addr;

    begin

        memAddr = addr;
        wrapAddr_inf = addr;
        wrapAddr_sup = addr+FM25Q08A.WrapLength-1;
        pageStartAddr = {addr[addrDim-1:pageAddr_inf], zeroIndex};
        pageIndex = addr[colAddrDim-1:0];
    
    end
    
    endtask



    
    // reset page with FF data

    task resetPage;

    for (i=0; i<=pageDim-1; i=i+1) 
        page[i] = data_NP;

    endtask    


    

    // in program operations data latched 
    // are written in page buffer

    task writeDataToPage;

    input [dataDim-1:0] data;

    begin

        page[pageIndex] = data;
        pageIndex = pageIndex + 1; 

    end

    endtask



    // page buffer is written to the memory

    task programPageToMemory; //logic and between old_data and new_data

    for (i=0; i<=pageDim-1; i=i+1)
        memory[pageStartAddr+i] = memory[pageStartAddr+i] & page[i];
        // before page program the page should be reset

    endtask





    // in read operations data are readed directly from the memory

    task readData;

    output [dataDim-1:0] data;
    begin
        data = memory[memAddr];
        if (memAddr < memDim-1)
            memAddr = memAddr + 1;
        else begin
            memAddr=0;
            $display("  [%0t ns] **WARNING** Highest address reached. Next read will be at the beginning of the memory!", $time);
        end    
            

    end

    endtask


// mem address increments in limited range
    task wrapreadData;

    output [dataDim-1:0] data;

    begin
        data = memory[memAddr];        
        if ((memAddr < memDim-1) && (memAddr !== wrapAddr_sup))
            memAddr = memAddr + 1;
        else if(memAddr==memDim-1) begin
            memAddr=0;
            $display("  [%0t ns] **WARNING** Highest address reached. Next read will be at the beginning of the memory!", $time);
        end else if(memAddr == wrapAddr_sup) 
            memAddr = wrapAddr_inf;
  

    end

    endtask



    //-----------------------------
    //  Tasks for erase operations
    //-----------------------------

    task eraseSector;
    input [addrDim-1:0] A;
    reg [sectorAddrDim-1:0] sect;
    reg [sectorAddr_inf-1:0] zeros;
    reg [addrDim-1:0] mAddr;
    begin
    
        sect = f.sec(A);
        zeros = 'h0;
        mAddr = {sect, zeros};
        for(i=mAddr; i<=(mAddr+sectorDim-1); i=i+1)
            memory[i] = data_NP;
    
    end
    endtask



   
    
     task eraseSubblock;
     input [addrDim-1:0] A;
     reg [subblockAddrDim-1:0] subt;
     reg [subblockAddr_inf-1:0] zeros;
     reg [addrDim-1:0] mAddr;
     begin
    
         subt = f.sub(A);
         zeros = 'h0;
         mAddr = {subt, zeros};
         for(i=mAddr; i<=(mAddr+subblockDim-1); i=i+1)
             memory[i] = data_NP;
    
     end
     endtask

  



     task eraseBlock;
     input [addrDim-1:0] A;
     reg [blockAddrDim-1:0] blkt;
     reg [blockAddr_inf-1:0] zeros;
     reg [addrDim-1:0] mAddr;
     begin
    
         blkt = f.blk(A);
         zeros = 'h0;
         mAddr = {blkt, zeros};
         for(i=mAddr; i<=(mAddr+blockDim-1); i=i+1)
             memory[i] = data_NP;
    
     end
     endtask





    task eraseChip;

        for (i=0; i<=memDim-1; i=i+1) 
            memory[i] = data_NP;
    
    endtask





endmodule

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           STATUS REGISTER 1 MODULE                    --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module StatusRegister1;

    `include "include/FM_DevParam.h"

    // status register 1
    reg [7:0] SR1;

    //--------------
    // Init
    //--------------

    reg nv_SRP0,nv_SEC,nv_TB,nv_BP2,nv_BP1,nv_BP0;
    
    initial begin
        
        //see alias in DevParam.h
        
        nv_BP0 = 0; // BP0 - block protect bit 0 
        nv_BP1 = 0; // BP1 - block protect bit 1
        nv_BP2 = 0; // BP2 - block protect bit 2
        nv_TB = 0; // TB (block protect top/bottom) 
        nv_SEC = 0; // SEC - sector protect bit
        nv_SRP0 = 0; // SRP0

    end


    always @(FM25Q08A.PollingAccessOn) if(FM25Q08A.PollingAccessOn) begin
        
        SR1[0] = 1; // WIP - write in progress
//        SR1[1] = 0; // WEL - write enable latch
        SR1[1] = 1; // WEL - write enable latch

    end


    always @(FM25Q08A.ReadAccessOn) if(FM25Q08A.ReadAccessOn) begin
        
        SR1[0] = 0; // WIP - write in progress
       // SR1[1] = 0; // WEL - write enable latch
        SR1[1] = 0; // WEL - write enable latch

    end


    //----------
    // WIP bit
    //----------

    always @(FM25Q08A.busy)
        `WIP = FM25Q08A.busy;


   
    //----------
    // WEL bit 
    //----------
    
    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Write Enable")   
        
        begin : WREN
          @(posedge FM25Q08A.CS); 
          `WEL = 1;
//          stat2.SR2[6] = 0;
          $display("  [%0t ns] Command execution: WEL bit set.", $time);
        end

    

    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Write Disable") 
        
        begin : WRDI
          @(posedge FM25Q08A.CS);
          `WEL = 0;
          $display("  [%0t ns] Command execution: WEL bit reset.", $time);
        end
        



    event WEL_reset;
    always @(WEL_reset)
        `WEL = 0;




    event writeNVSR1; //refresh status register 1 nonvolatile bits values
    always @(writeNVSR1) begin
        
         nv_SRP0=`SRP0;
         nv_SEC=`SEC;
         nv_TB=`TB;
         nv_BP2=`BP2;
         nv_BP1=`BP1;
         nv_BP0=`BP0;

    end

    event getNVSR1;//update the values of SP1 by nonvolatile values
    always @(getNVSR1) begin
        
         SR1[7] = nv_SRP0;
         SR1[6] = nv_SEC;
         SR1[5] = nv_TB;
         SR1[4] = nv_BP2;
         SR1[3] = nv_BP1;
         SR1[2] = nv_BP0;

    end
    

    //------------------------
    // write status register 1
    //------------------------

    // see "Program" module


    //----------------------
    // read status register 1
    //----------------------
    // NB : "Read SR1" operation is also modelled in FM25Q08A.module

    reg enable_SR1_read;
    
    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Read Status Register 1") fork 
        
        enable_SR1_read=1;

        @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault)
            enable_SR1_read=0;
        
    join    


endmodule   


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           STATUS REGISTER 2 MODULE                    --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module StatusRegister2;

    `include "include/FM_DevParam.h"

    // status register 2
    reg [7:0] SR2;

//    reg nv_SRP1,nv_QE,nv_LB0,nv_LB1,nv_LB2,nv_LB3,nv_CMP;
    
    reg nv_SRP1,nv_QE,nv_LB0,nv_LB1,nv_CMP,nv_DRV0,nv_DRV1;
    //--------------
    // Init
    //--------------


    initial begin
        nv_SRP1 = 0; // SPR1
        nv_QE = 0; // QE
        nv_LB0 = 0; // LB0
        nv_LB1 = 0; // LB1
        nv_CMP = 0; // CMP
        nv_DRV1 = 0; // DRV1
        nv_DRV0 = 0; // DRV0
        SR2[5] = 0; // ERR


    end




    event writeNVSR2; //refresh status register 2 nonvolatile bits value
    always @(writeNVSR2) begin
        
         nv_SRP1=`SRP1;
         nv_QE=`QE;
         nv_LB0=`LB0;
         nv_LB1=`LB1;
         nv_CMP=`CMP;
         nv_DRV1=`DRV1;
         nv_DRV0=`DRV0;

    end

    event getNVSR2; //refresh status register 2 nonvolatile bits value
    always @(getNVSR2) begin
        SR2[0] = nv_SRP1; // SPR1
        SR2[1] = nv_QE; // QE
        SR2[2] = nv_LB0; // LB0
        SR2[3] = nv_LB1; // LB1
        SR2[4] = nv_CMP; // CMP
        SR2[5] = 0; // ERR
        SR2[6] = nv_DRV1; // DRV1
        SR2[7] = nv_DRV0; // DRV0

end

    //----------
    // SUS bit
    //----------
    
//    always @(prog.Suspended)
//        `SUS = prog.Suspended;




    //------------------------------
    // read status register 2
    //------------------------------
    
    reg enable_SR2_read;
    
    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Read Status Register 2") fork 
        
        enable_SR2_read=1;

        @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault)
            enable_SR2_read=0;
        
    join
      

endmodule

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           STATUS REGISTER 3 MODULE                    --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*
`timescale 1ns / 1ns

module StatusRegister3;

    `include "include/FM_DevParam.h"

    // status register 3
    reg [7:0] SR3;

    
    reg nv_DRV1,nv_DRV0;
    //--------------
    // Init
    //--------------


    initial begin
        nv_DRV1 = 0; // DRV1
        nv_DRV0 = 0; // DRV0

    end




    event writeNVSR3; //refresh status register 3 nonvolatile bits value
    always @(writeNVSR3) begin
        
         nv_DRV1=`DRV1;
         nv_DRV0=`DRV0;

    end

    event getNVSR3; //refresh status register 3 nonvolatile bits value
    always @(getNVSR3) begin
        SR3[0] = nv_DRV0; // DRV0
        SR3[1] = nv_DRV1; // DRV1
        SR3[2] = 0; //RFU
        SR3[3] = 0; //RFU
        SR3[4] = 0; //RFU
        SR3[5] = 0; //RFU
        SR3[6] = 0; //RFU
        SR3[7] = 0; //RFU

end

    //------------------------------
    // read status register 3
    //------------------------------
    
    reg enable_SR3_read;
    
    always @(FM25Q08A.seqRecognized) if (FM25Q08A.cmdRecName=="Read Status Register 3") fork 
        
        enable_SR3_read=1;

        @(posedge(FM25Q08A.CS) or FM25Q08A.resetEvent or FM25Q08A.voltageFault)
            enable_SR3_read=0;
        
    join
      

endmodule

*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           SECURITY SECTORS MODULE                     --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

module SecuritySectors;

    
    `include "include/FM_DevParam.h"


    reg [dataDim-1:0] mem0 [0:SecuSec_dim-1];
    reg [dataDim-1:0] mem1 [0:SecuSec_dim-1];
    reg [dataDim-1:0] mem2 [0:SecuSec_dim-1];
    reg [dataDim-1:0] mem3 [0:SecuSec_dim-1];

    reg [dataDim-1:0] buffer [0:SecuSec_dim-1];
    reg [SecuSec_addrDim-1:0] addr;
    reg [1:0] sec;

    integer i;



    //-----------
    //  Init
    //-----------

    initial begin
        for (i=0; i<=SecuSec_dim-1; i=i+1)  begin
            mem0[i] = data_NP;
            mem1[i] = data_NP;
            mem2[i] = data_NP;
            mem3[i] = data_NP;
            end
    end



    //---------------------------
    // Program & Read SecuSec tasks
    //---------------------------


    // set start address
    // (for program and read operations)
    
    task setAddr;
    input [addrDim-1:0] A;
        begin
         addr = A[SecuSec_addrDim-1:0];
         sec[1] = A[12];
         sec[0] = A[8];
        end
    endtask


    task resetBuffer;
    for (i=0; i<=SecuSec_dim-1; i=i+1)
        buffer[i] = data_NP;
    endtask


    task writeDataToBuffer;
    input [dataDim-1:0] data;
    begin
        
        buffer[addr] = data;
        addr = addr + 1;
        
    end
    endtask



    task writeBufferToSecuSec0;

            for (i=0; i<=SecuSec_dim-1; i=i+1)
                           mem0[i] = mem0[i] & buffer[i];

    endtask


 
    task writeBufferToSecuSec1;

            for (i=0; i<=SecuSec_dim-1; i=i+1)
                           mem1[i] = mem1[i] & buffer[i];

    endtask



    task writeBufferToSecuSec2;

            for (i=0; i<=SecuSec_dim-1; i=i+1)
                           mem2[i] = mem2[i] & buffer[i];

    endtask



    task writeBufferToSecuSec3;

            for (i=0; i<=SecuSec_dim-1; i=i+1)
                           mem3[i] = mem3[i] & buffer[i];

    endtask



    task readSecuSec0;
    output [dataDim-1:0] data;
    begin

        data = mem0[addr];
        addr = addr + 1;

    end
    endtask



    task readSecuSec1;
    output [dataDim-1:0] data;
    begin

        data = mem1[addr];
        addr = addr + 1;

    end
    endtask



    task readSecuSec2;
    output [dataDim-1:0] data;
    begin

        data = mem2[addr];
        addr = addr + 1;

    end
    endtask



    task readSecuSec3;
    output [dataDim-1:0] data;
    begin

        data = mem3[addr];
        addr = addr + 1;

    end
    endtask



    task eraseSecuSec;
    begin
/*        case (sec[1])
        1'b0:   for(i=0; i<=SecuSec_dim-1; i=i+1) begin
                   mem0[i] = data_NP;
                   mem1[i] = data_NP;
                 end
        2'b1:   for(i=0; i<=SecuSec_dim-1; i=i+1)
                   mem2[i] = data_NP;
        2'b11:   for(i=0; i<=SecuSec_dim-1; i=i+1)
                   mem3[i] = data_NP;
        endcase */
        if (sec[1] == 0) begin
            for(i=0; i<=SecuSec_dim-1; i=i+1) begin
              mem0[i] = data_NP;
              mem1[i] = data_NP;
            end
        end else begin
            for(i=0; i<=SecuSec_dim-1; i=i+1) begin
              mem2[i] = data_NP;
              mem3[i] = data_NP;
            end
        end
    end
    endtask




endmodule 
  



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           CUI DECODER                                 --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ns 

module CUIdecoder (cmdAllowed);


    `include "include/FM_DevParam.h" 

    input cmdAllowed;

    parameter [40*8:1] cmdName = "Write Enable";
    parameter [cmdDim-1:0] cmdCode = 'h06;
    parameter withAddr = 1'b0; // 1 -> command with address  /  0 -> without address 
    parameter with2Addr = 1'b0; // 1 -> command with address  /  0 -> without address 
    parameter with4Addr = 1'b0; // 1 -> command with address  /  0 -> without address 
     


    always @FM25Q08A.startCUIdec if (cmdAllowed && cmdCode==FM25Q08A.cmd) begin

        if(!withAddr && !with2Addr && !with4Addr) begin
            
            FM25Q08A.cmdRecName = cmdName;
            $display("  [%0t ns] COMMAND RECOGNIZED: %0s.", $time, cmdName);
            -> FM25Q08A.seqRecognized; 
        
        end else if (withAddr) begin
            
            FM25Q08A.latchingMode = "A";
            $display("  [%0t ns] COMMAND RECOGNIZED: %0s. Address expected ...", $time, cmdName);
            -> FM25Q08A.codeRecognized;
            
            fork : proc1 

                @(FM25Q08A.addrLatched) begin
                    if(cmdName=="Read Security Sectors" || cmdName=="Program Security Sectors" || cmdName=="Erase Security Sectors")
                        $display("  [%0t ns] Security Sector #%0d Address latched: column %0d", $time, f.security_sec(FM25Q08A.addr), f.col(FM25Q08A.addr));
                    else if(cmdName=="Read Manufacturer Device ID" && FM25Q08A.addr==0)begin
                        $display("  [%0t ns] %0s Command INFO: Manufacturer ID output first", $time, cmdName);
                        FM25Q08A.ID_count = 0;
                    end else if(cmdName=="Read Manufacturer Device ID" && FM25Q08A.addr==1)begin
                        $display("  [%0t ns] %0s Command INFO: Device ID output first", $time, cmdName);
                        FM25Q08A.ID_count = 1;  
                    end else
                        $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d, subblock %0d, block %0d)", $time, FM25Q08A.addr, f.col(FM25Q08A.addr), f.pag(FM25Q08A.addr), f.sec(FM25Q08A.addr), f.sub(FM25Q08A.addr), f.blk(FM25Q08A.addr));
                    
				    FM25Q08A.cmdRecName = cmdName;
                    
					-> FM25Q08A.seqRecognized;
                    disable proc1;
                end

                @(posedge FM25Q08A.CS) begin
                    $display("  - [%0t ns] CS high: command aborted", $time);
                    disable proc1;
                end

                @(FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
                    disable proc1;
                end
            
            join


         end else if (with2Addr) begin
            
            FM25Q08A.latchingMode = "I";
			if(FM25Q08A.read.contin_enable)
					$display("  [%0t ns] %0s with Continuous Read Mode Starts. Address expected directly ...", $time, cmdName);
			else
                    $display("  [%0t ns] COMMAND RECOGNIZED: %0s. Address expected ...", $time, cmdName);
            -> FM25Q08A.codeRecognized;
            
            fork : proc2 

                   @(FM25Q08A.addrLatched) begin
                   if(cmdName!=="Read Manufacturer Device ID Dual IO")
                   $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d, subblock %0d, block %0d)", $time, FM25Q08A.addr, f.col(FM25Q08A.addr), f.pag(FM25Q08A.addr), f.sec(FM25Q08A.addr), f.sub(FM25Q08A.addr), f.blk(FM25Q08A.addr));
                   else if(FM25Q08A.addr==0)begin
                   $display("  [%0t ns] %0s Command INFO: Manufacturer ID output first", $time, cmdName);
                   FM25Q08A.ID_count = 0;
                   end else if(FM25Q08A.addr==1)begin
                   $display("  [%0t ns] %0s Command INFO: Device ID output first", $time, cmdName);
                   FM25Q08A.ID_count = 1;
                   end
                  
				   FM25Q08A.cmdRecName = cmdName;
                   
				   -> FM25Q08A.seqRecognized;
                   disable proc2;
                end

                @(posedge FM25Q08A.CS) begin
                    $display("  - [%0t ns] CS high: command aborted", $time);
                    disable proc2;
                end

                @(FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
                    disable proc2;
                end
            
            join


        end  else if (with4Addr) begin
                    
                FM25Q08A.latchingMode = "E";
				if(FM25Q08A.read.contin_enable)
				     $display("  [%0t ns] %0s with Continuous Read Mode Starts. Address expected directly ...", $time, cmdName);
			    else
                     $display("  [%0t ns] COMMAND RECOGNIZED: %0s. Address expected ...", $time, cmdName);
                
			    -> FM25Q08A.codeRecognized;
                                            
                fork : proc3 
                                   
                @(FM25Q08A.addrLatched) begin
                if(cmdName!=="Read Manufacturer Device ID Quad IO" && cmdName!=="Read Manufacturer Device ID") begin
                $display("  [%0t ns] Address latched: %h (byte %0d of page %0d, sector %0d, subblock %0d, block %0d)", $time, FM25Q08A.addr, f.col(FM25Q08A.addr), f.pag(FM25Q08A.addr), f.sec(FM25Q08A.addr), f.sub(FM25Q08A.addr), f.blk(FM25Q08A.addr));
                end else if(FM25Q08A.addr==0)begin
                $display("  [%0t ns] %0s Command INFO: Manufacturer ID output first", $time, cmdName);
                FM25Q08A.ID_count = 0;
                end else if(FM25Q08A.addr==1)begin
                $display("  [%0t ns] %0s Command INFO: Device ID output first", $time, cmdName);
                FM25Q08A.ID_count = 1;
                end
                
				FM25Q08A.cmdRecName = cmdName;
                
				-> FM25Q08A.seqRecognized;
                disable proc3;
                end

                @(posedge FM25Q08A.CS) begin
                $display("  - [%0t ns] CS high: command aborted", $time);
                disable proc3;
                end

				@(FM25Q08A.resetEvent or FM25Q08A.voltageFault) begin
                disable proc3;
                end
       
		    join
    
       end    

    end

endmodule    
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           UTILITY FUNCTIONS                           --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ns 

module UtilFunctions;

    `include "include/FM_DevParam.h"

    integer i;

    
    //----------------------------------
    // Utility functions for addresses 
    //----------------------------------

    function  security_sec;
    input [addrDim-1:0] A;
        security_sec = A[12];
    endfunction
    
    function [blockAddrDim-1:0] blk;//BLOCK 64KB
    input [addrDim-1:0] A;
        blk = A[blockAddr_sup:blockAddr_inf];
    endfunction  

    function [subblockAddrDim-1:0] sub;//SUBBLOCK 32KB
    input [addrDim-1:0] A;
        sub = A[subblockAddr_sup:subblockAddr_inf];
    endfunction   

    function [sectorAddrDim-1:0] sec;
    input [addrDim-1:0] A;
        sec = A[sectorAddr_sup:sectorAddr_inf];
    endfunction

    function [pageAddrDim-1:0] pag;
    input [addrDim-1:0] A;
        pag = A[pageAddr_sup:pageAddr_inf];
    endfunction

    function [colAddrDim-1:0] col;
    input [addrDim-1:0] A;
        col = A[colAddr_sup:0];
    endfunction
    
    
    
    
    
    //----------------------------------
    // Console messages 
    //----------------------------------

    task clock_error;

        $display("  [%0t ns] **WARNING** Number of clock pulse isn't multiple of eight: operation aborted!", $time);

    endtask



    task WEL_error;

        $display("  [%0t ns] **WARNING** WEL bit not set: operation aborted!", $time);

    endtask



    task out_info;
    
        input [addrDim-1:0] A;
        input [dataDim-1:0] D;


         if (stat1.enable_SR1_read)          
         $display("  [%0t ns] Status Register 1 are going to be output: %h.\n \tStatus Register 1:\tSRP0=%b\tSEC=%b\tTB=%b\tBP2=%b\tBP1=%b\tBP0=%b\tWEL=%b\tWIP=%b", $time, D, D[7], D[6], D[5], D[4], D[3], D[2], D[1], D[0]);

         else if (stat2.enable_SR2_read)          
         $display("  [%0t ns] Status Register 2 are going to be output: %h.\n \tStatus Register 2:\tDRV1=%b\tDRV0=%b\tERR=%b\tCMP=%b\tLB1=%b\tLB0=%b\tQE=%b\tSRP1=%b", $time, D, D[7],D[6], D[5], D[4], D[3], D[2], D[1], D[0]);

//         else if (stat3.enable_SR3_read)          
//         $display("  [%0t ns] Status Register 3 are going to be output: %h.\n \tStatus Register 3:\tDRV1=%b\tDRV0=%b", $time, D, D[1], D[0]);
 
        
         else if (read.enable_ManDevID)
         $display("  [%0t ns] Data are going to be output: %h. [Read Manufacturer Device ID]",
                  $time, D);
                  
         else if (read.enable_ManDevID_Dual)
         $display("  [%0t ns] Data are going to be output: %h. [Read Manufacturer Device ID Dual IO]",
                  $time, D);
                  
         else if (read.enable_ManDevID_Quad)
         $display("  [%0t ns] Data are going to be output: %h. [Read Manufacturer Device ID Quad IO]",
                  $time, D);
                  
         else if (read.enable_JEDEC)
         $display("  [%0t ns] Data are going to be output: %h. [Read JEDEC ID]",
                  $time, D);
                  
         else if (read.enable_UID)
         $display("  [%0t ns] Data are going to be output: %h. [Read Unique ID]",
                  $time, D);

          else if (read.enable_DevID)
            $display("  [%0t ns] Data are going to be output: %h. [Read Device ID]", $time, D);
        
          else if (read.enable_SecuSec)  
            $display("  [%0t ns] Data are going to be output: %h. [Read Security Sector %0d, Page %d, column %0d ]", $time, D, SecuSec.sec[1], SecuSec.sec[0], SecuSec.addr-1);

        else        
          
          if (read.enable || read.enable_fast)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, sector %0d, subsector %0d of block %0d)] ",
                    $time, D, A, col(A), pag(A), sec(A), sub(A), blk(A)); 
        
          else if (read.enable_dual)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, sector %0d, subsector %0d of block %0d)] ",
                    $time, D, A, col(A), pag(A), sec(A), sub(A), blk(A));

          else if (read.enable_quad)
          $display("  [%0t ns] Data are going to be output: %h. [Read Memory. Address %h (byte %0d of page %0d, sector %0d, subsector %0d of block %0d)] ",
                    $time, D, A, col(A), pag(A), sec(A), sub(A), blk(A));
                    
          else if (read.enable_quadwrap)
          $display("  [%0t ns] Data are going to be output in Wrap mode: %h. [Read Memory. Address %h (byte %0d of page %0d, sector %0d, subsector %0d of block %0d)] ",
                    $time, D, A, col(A), pag(A), sec(A), sub(A), blk(A));
        

    endtask





    //----------------------------------------------------
    // Special tasks used for testing and debug the model
    //----------------------------------------------------
    

    //
    // erase the whole memory, and resets pageBuffer and cacheBuffer
    //
    
    task fullErase;
    begin
    
        for (i=0; i<=memDim-1; i=i+1) 
            mem.memory[i] = data_NP; 
        
        $display("  [%0t ns] ==INFO== The whole memory has been erased.", $time);

    end
    endtask









    //
    // load memory file
    //

    task load_memory_file;

    input [40*8:1] memory_file;

    begin
    
        for (i=0; i<=memDim-1; i=i+1) 
            mem.memory[i] = data_NP;
        
        $readmemh(memory_file, mem.memory);
        $display("  [%0t ns] ==INFO== Load memory content from file: \"%0s\".", $time, FM25Q08A.memory_file);
    
    end
    endtask





endmodule


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           LOCK MANAGER MODULE                         --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

`timescale 1ns / 1ns 

module LockManager;


`include "include/FM_DevParam.h"




//---------------------------------------------------
// Data structures for protection status modelling
//---------------------------------------------------


// array of blocks lock status (status determinated by Block Protect Status Register bits)
reg [nBlock-1:0] block_lock_by_SR; //(1=locked)
reg[15:0] topBlock_lock; // for the sectors in the uppest Block
reg[15:0] bottomBlock_lock; // for the sectors in the lowest Block
integer i;






//----------------------------
// Initial protection status
//----------------------------

initial begin
    for (i=0; i<=nBlock-1; i=i+1)
        block_lock_by_SR[i] = 0;
   
    topBlock_lock=0;
    bottomBlock_lock=0;
end    





//------------------------------------------------
// Protection managed by BP status register bits
//------------------------------------------------


integer nLockedBlock;
integer temp;


  
  always @(`SEC or `CMP or `TB  or `BP2 or `BP1 or `BP0)  begin
  
  if (({`CMP, `BP2, `BP1, `BP0}==4'b0000) || ({`CMP, `BP2, `BP1}==3'b111) || ({`CMP, `SEC, `BP2, `BP1, `BP0}==5'b10101)) begin
      for (i=0; i<=nBlock-1; i=i+1)  
          block_lock_by_SR[i] = 0;
      topBlock_lock=0;
      bottomBlock_lock=0;
      $display("  [%0t ns] ==INFO== None Blocks are locked", $time);

  end else if (({`CMP, `SEC, `BP2, `BP1, `BP0}==5'b00101) || ({`CMP, `BP2, `BP1}==3'b011) || ({`CMP, `BP2, `BP1, `BP0}==4'b1000)) begin
      for (i=0; i<=nBlock-1; i=i+1)  
          block_lock_by_SR[i] = 1;
      topBlock_lock='hFFFF;
      bottomBlock_lock='hFFFF;
      $display("  [%0t ns] ==INFO== All Blocks are locked", $time);
  
  end else if(`SEC==0) begin
    	
      topBlock_lock=0;//reset all lock status
      bottomBlock_lock=0;  
      for (i=0; i<=nBlock-1; i=i+1)  
          block_lock_by_SR[i] = 0;
    
      temp = {`BP2, `BP1, `BP0};
      nLockedBlock = 2**(temp-1); 

      if (nLockedBlock>0 && `TB==0) // upper blocks protected
          for ( i=nBlock-1 ; i>=nBlock-nLockedBlock ; i=i-1 )
              block_lock_by_SR[i] = 1;
 
      else if (nLockedBlock>0 && `TB==1) // lower blocks protected 
          for ( i = 0 ; i <= nLockedBlock-1 ; i = i+1 ) 
              block_lock_by_SR[i] = 1;

      if (`CMP==1)
          for ( i = 0; i<=nBlock-1;i=i+1)
              block_lock_by_SR[i] = !block_lock_by_SR[i];
              
      if (block_lock_by_SR[0]==1)
          bottomBlock_lock='hFFFF;
          
      if (block_lock_by_SR[nBlock-1]==1)
          topBlock_lock='hFFFF;
           
      for (i=0; i<=nBlock-1;i=i+1)
          if (block_lock_by_SR[i]==1)  
              $display("  [%0t ns] ==INFO== Block %0d locked", $time, i);   

  end 
  else begin
    	
      topBlock_lock=0;//reset all lock status
      bottomBlock_lock=0;  
      for (i=0; i<=nBlock-1; i=i+1)  
          block_lock_by_SR[i] = 0;
      
      if (`TB==0) begin
      	 block_lock_by_SR[nBlock-1]=1;
         case ({`BP2, `BP1, `BP0})
         	3'b001:  topBlock_lock='h8000;// 0 means unlocked, 1 means locked
         	3'b010:  topBlock_lock='hC000;
         	3'b011:  topBlock_lock='hF000;
         	3'b100,3'b101:   topBlock_lock='hFF00;
         endcase
      end else begin
      	 block_lock_by_SR[0]=1;
         case ({`BP2, `BP1, `BP0})
         	3'b001:  bottomBlock_lock='h0001;// 0 means unlocked, 1 means locked
         	3'b010:  bottomBlock_lock='h0003;
         	3'b011:  bottomBlock_lock='h000F;
         	3'b100,3'b101:   bottomBlock_lock='h00FF;
         endcase
      end
      
      if (`CMP==1) begin
      	 topBlock_lock = ~topBlock_lock;
      	 bottomBlock_lock = ~bottomBlock_lock;
         for (i=0; i<=nBlock-1; i=i+1)  
          block_lock_by_SR[i] = 1; 	// every block locked by SR except some sectors in uppest block or lowest block
      end
      
  end  

end

//-------------------------------------------
// Function to test sector protection status
//-------------------------------------------

function isBlockProtected_by_SR;
input [addrDim-1:0] byteAddr;
reg [blockAddrDim-1:0] blkAddr;
begin

    blkAddr = f.blk(byteAddr);
    isBlockProtected_by_SR = block_lock_by_SR[blkAddr]; 

end
endfunction


function isSubblockProtected_by_SR;
input [addrDim-1:0] byteAddr;
reg [subblockAddrDim-1:0] subAddr;
reg [blockAddrDim-1:0] blkAddr;
begin

    subAddr = f.sub(byteAddr);
    blkAddr = f.blk(byteAddr);
    if(blkAddr!==0 && blkAddr!==nBlock-1)
       isSubblockProtected_by_SR = block_lock_by_SR[blkAddr]; 
    else if(blkAddr == 0)
       isSubblockProtected_by_SR = (subAddr%2)? (|bottomBlock_lock[15:8]):(|bottomBlock_lock[7:0]);
    else if(blkAddr == nBlock-1)
       isSubblockProtected_by_SR = (subAddr%2)? (|topBlock_lock[15:8]):(|topBlock_lock[7:0]);  
    
end
endfunction


function isSectorProtected_by_SR;
input [addrDim-1:0] byteAddr;
reg [sectorAddrDim-1:0] secAddr;
reg [blockAddrDim-1:0] blkAddr;
begin

    secAddr = f.sec(byteAddr);
    blkAddr = f.blk(byteAddr);
    if(blkAddr!==0 && blkAddr!==nBlock-1)
       isSectorProtected_by_SR = block_lock_by_SR[blkAddr]; 
    else if(blkAddr == 0)
       isSectorProtected_by_SR = bottomBlock_lock[(secAddr%16)];
    else if(blkAddr == nBlock-1)
       isSectorProtected_by_SR = topBlock_lock[(secAddr%16)];  
    
end
endfunction



function isAnyBlockProtected;
input required;
begin

    i=0;   
    isAnyBlockProtected=0;
    while(isAnyBlockProtected==0 && i<=nBlock-1) begin 
          isAnyBlockProtected = block_lock_by_SR[i];
        i=i+1;
    end    

end
endfunction



endmodule



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------
-----------------------------------------------------------
--                                                       --
--           TIMING CHECK                                --
--                                                       --
-----------------------------------------------------------
-----------------------------------------------------------
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
`timescale 1ns / 1ns

`ifdef timingChecks

module TimingCheck (CS, CLK, D, Q, W, H); 
    `include "include/FM_DevParam.h"

    input CS, CLK, D, Q;
    
    input H; 

    input W;

    
    time delta; //used for interval measuring
    
   

    //--------------------------
    //  Task for timing check
    //--------------------------

    task check;
        
        input [8*8:1] name;  //constraint check
        input time interval;
        input time constr;
        
        begin
        
            if (interval<constr)
                $display("  [%0t ns] --TIMING ERROR-- %0s constraint violation. Measured time: %0t ns - Constraint: %0t ns",
                          $time, name, interval, constr);
            
        
        end
    
    endtask



    //----------------------------
    // Istants to be measured
    //----------------------------

    parameter initialTime = -1000;

    time C_high=initialTime, C_low=initialTime;
    time S_low=initialTime, S_high=initialTime;
    time D_valid=initialTime;
    time H_low=initialTime, H_high=initialTime; 
    time W_low=initialTime, W_high=initialTime; 
    


    //------------------------
    //  CLK signal checks
    //------------------------


    always 
    @CLK if(CLK===0) //posedge(CLK)
    @CLK if(CLK===1)
    begin
        
        delta = $time - C_low; 
        check("tCL", delta, tCL);

        delta = $time - S_low; 
        check("tSLCH", delta, tSLCH);

        delta = $time - D_valid; 
        if (`QE==0)
        check("tDVCH", delta, tDVCH);

        delta = $time - S_high; 
        check("tSHCH", delta, tSHCH);

        // clock frequency checks
        delta = $time - C_high;

        if ((read.enable || read.enable_ManDevID || read.enable_JEDEC || read.enable_UID || stat1.enable_SR1_read || stat2.enable_SR2_read)
                    && 
                    delta<TR)
           $display("  [%0t ns] --TIMING ERROR-- Violation of Max clock frequency (%0d MHz) during READ operation. T_ck_measured=%0d ns, T_clock_min=%0d ns.",
                      $time, fR, delta, TR);
                      
        else if ( (read.enable_quad || read.enable_quadwrap || read.enable_fast) && FM25Q08A.protocol=="QPI")  begin
        	  case(FM25Q08A.QuadDummy) 
        	  	2: begin
        	  		if (delta<20)     //50mhz  	  	
        	 $display("  [%0t ns] --TIMING ERROR-- Violation of Max clock frequency (%0d MHz) during READ operation. T_ck_measured=%0d ns, T_clock_min=%0d ns.",
                      $time, 50, delta, 20);
                 end
              4:  begin  
              if (delta<13)     //80mhz  	  	
        	 $display("  [%0t ns] --TIMING ERROR-- Violation of Max clock frequency (%0d MHz) during READ operation. T_ck_measured=%0d ns, T_clock_min=%0d ns.",
                      $time, 80, delta, 13);
                    end
              6, 8: begin
              	if (delta<10)    //100mhz   	  	
        	 $display("  [%0t ns] --TIMING ERROR-- Violation of Max clock frequency (%0d MHz) during READ operation. T_ck_measured=%0d ns, T_clock_min=%0d ns.",
                      $time, fC, delta, 10);
                    end
              default : begin end
             endcase
        end
        
        
        else if ( (read.enable_fast || read.enable_dual || read.enable_quad || read.enable_quadwrap || read.enable_SecuSec)   
                          && 
                        delta<TC  )
           $display("  [%0t ns] --TIMING ERROR-- Violation of Max clock frequency (%0d MHz). T_ck_measured=%0d ns, T_clock_min=%0d ns.",
                      $time, fC, delta, TC);
        

        
            delta = $time - H_low; 
                    if (`QE==0)
                check("tHLCH", delta, tHLCH);

            delta = $time - H_high; 
                    if (`QE==0)
                check("tHHCH", delta, tHHCH);
        

        
        C_high = $time;
        
    end



    always 
    @CLK if(CLK===1) //negedge(CLK)
    @CLK if(CLK===0)
    begin
        
        delta = $time - C_high; 
        check("tCH", delta, tCH);
        
        C_low = $time;
        
    end




    //------------------------
    //  CS signal checks
    //------------------------


    always 
    @CS if(CS===1) //negedge(CS)
    @CS if(CS===0)
    begin
        
        delta = $time - C_high; 
        check("tCHSL", delta, tCHSL);
                   
        delta = $time - W_high; 
                if (`QE==0)
check("tWHSL", delta, tWHSL);
        
        delta = $time - S_high;
        if(FM25Q08A.cmdRecName !== "Read Data" &&
           FM25Q08A.cmdRecName !== "Fast Read" && 
           FM25Q08A.cmdRecName !== "Read Manufacturer Device ID" && 
           FM25Q08A.cmdRecName !== "Read Manufacturer Device ID Dual IO" && 
           FM25Q08A.cmdRecName !== "Read Manufacturer Device ID Quad IO" && 
           FM25Q08A.cmdRecName !== "Read JEDEC ID" && 
           FM25Q08A.cmdRecName !== "Read Unique ID" && 
           FM25Q08A.cmdRecName !== "Read Security Sectors" && 
           FM25Q08A.cmdRecName !== "Fast Read Dual Output" && 
           FM25Q08A.cmdRecName !== "Fast Read Dual IO" && 
           FM25Q08A.cmdRecName !== "Fast Read Quad Output" && 
           FM25Q08A.cmdRecName !== "Fast Read Quad IO" && 
           FM25Q08A.cmdRecName !== "Word Read Quad IO" && 
           FM25Q08A.cmdRecName !== "Octal Word Read Quad IO" && 
           FM25Q08A.cmdRecName !== "Burst Read With Wrap" && 
           FM25Q08A.cmdRecName !== "Release Power Down Device ID")
           check("tSHSL2", delta, tSHSL2);
        else
           check("tSHSL1", delta, tSHSL1); // after a read command



        S_low = $time;


    end




    always 
    @CS if(CS===0) //posedge(CS)
    @CS if(CS===1)
    begin
        
        delta = $time - C_high; 
        check("tCHSH", delta, tCHSH);
        
        S_high = $time;
        
    end





    //----------------------------
    //  D signal (data in) checks
    //----------------------------

    always @D 
    begin

        delta = $time - C_high;
        if(FM25Q08A.cmdRecName !== "Read Data" &&
           FM25Q08A.cmdRecName !== "Fast Read" && 
           FM25Q08A.cmdRecName !== "Read Manufacturer Device ID" && 
           FM25Q08A.cmdRecName !== "Read Manufacturer Device ID Dual IO" && 
           FM25Q08A.cmdRecName !== "Read Manufacturer Device ID Quad IO" && 
           FM25Q08A.cmdRecName !== "Read JEDEC ID" && 
           FM25Q08A.cmdRecName !== "Read Unique ID" && 
           FM25Q08A.cmdRecName !== "Read Security Sectors" && 
           FM25Q08A.cmdRecName !== "Fast Read Dual Output" && 
           FM25Q08A.cmdRecName !== "Fast Read Dual IO" && 
           FM25Q08A.cmdRecName !== "Fast Read Quad Output" && 
           FM25Q08A.cmdRecName !== "Fast Read Quad IO" && 
           FM25Q08A.cmdRecName !== "Word Read Quad IO" && 
           FM25Q08A.cmdRecName !== "Octal Word Read Quad IO" && 
           FM25Q08A.cmdRecName !== "Burst Read With Wrap" && 
           FM25Q08A.cmdRecName !== "Release Power Down Device ID" && `QE==0)
         check("tCHDX", delta, tCHDX);

        if (isValid(D)) D_valid = $time;

    end



    //------------------------
    //  Hold signal checks
    //------------------------



        always 
        @H if(H===1) //negedge(H)
        @H if(H===0)
        begin
            
            delta = $time - C_high; 
                    if (`QE==0)
check("tCHHL", delta, tCHHL);

            H_low = $time;
            
        end



        always 
        @H if(H===0) //posedge(H)
        @H if(H===1)
        begin
            
            delta = $time - C_high; 
                    if (`QE==0)
check("tCHHH", delta, tCHHH);
            
            H_high = $time;
            
        end







    //------------------------
    //  W signal checks
    //------------------------


        always 
        @W if(W===1) //negedge(W)
        @W if(W===0)
        begin
            
            delta = $time - S_high; 
                    if (`QE==0)
check("tSHWL", delta, tSHWL);

            W_low = $time;
            
        end

        always 
        @W if(W===0) //posedge(W)
        @W if(W===1)
            W_high = $time;






    //----------------
    // Others tasks
    //----------------

    function isValid;
    input bit;
      if (bit!==0 && bit!==1) isValid=0;
      else isValid=1;
    endfunction




    

endmodule //TimingChecks module  
`endif


