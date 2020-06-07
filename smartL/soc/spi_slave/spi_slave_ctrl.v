module spi_slave_ctrl (
  input I_resetb,               // I_resetb Tree Bufferred
  input [3:0]   I_da ,          // device address for regfile
  input I_csb,                  // Serial Chip Select
  input I_sclk,                 // Serial Data Clock
  input I_sdi,                  // Serial Data Input
  input [7:0] I_reg_data,       // From selected read reg
  output wire O_sdo_en,         // Output enable for SDO pin
  output wire O_sdo,            // Bit Wide Data Out to Host (Sdio/O_sdo pins)
  output wire [7:0] O_reg_addr, // Address to register map
  output wire O_reg_wr_en,      // Write enable pulse to register map 
  output reg [7:0] O_reg_data,  // Write data to register map 
  output wire O_reg_rd_en       // Read enable pulse to register map
  
) ;



//------------------------------------------------------------------------
wire I_wrap_stream = 1'b0;       // Enable streaming mode to wrap/stop on high address
wire I_en_eng_map = 1'b1;        // Engineering mode for finding wrapping high address         
//------------------------------------------------------------------------


//------------------------------------------------------------------------
// Internal signals
//------------------------------------------------------------------------
wire OpType;                    // SPI Read/Write type
wire [1:0] OpPack;              // SPI length of transfer in Bytes
reg DontFlush;                  // Dont flush on byte boundaries.
wire [2:0] expected_bytes;      // Decode number of bytes in transfer
wire Instruction_end;           // Reached end of instruction
reg reg_done1;                  // Instruction done
reg reg_done2;                  // Delay signal for 0.5 cycle pulse ( async reset)
wire reg1_and_reg2;             // Flush state machine on instruction done.
wire MachFlushb;                // Flush state machine
reg [5:0] BITcnt;               // State machine bit counter
reg [15:0] IRRreg;              // Register storing the control portion of the SPI command
reg [7:0] SerBits;              // The data shifter for SPI writes
reg [12:0] IRRnxt;              // The next address for multi data transaction
wire [3:0] BITuse;              // The pointer to the data shifter for SPI read
reg RdStb;                      // A SPI read happening - controls sdo_oe
wire stream_mode_stop;          // End stream mode instruction on reaching end of register space.
wire [3:0]device_address;

reg O_sdo_tmp;

parameter
  PMBL0       = 3'b000 ,        // Preamble Byte0 -- Can        Stall IF INSlong
  PMBL1       = 3'b001 ,        // Preamble Byte1 -- Can ALWAYS Stall
  BYTE0       = 3'b010 ,        // Data     Byte0 -- Can        Stall IF Bytes > 1
  BYTE1       = 3'b011 ,        // Data     Byte1 -- Can        Stall IF Bytes > 2
  BYTE2       = 3'b100 ,        // Data     Byte2 -- Can        Stall IF Bytes > 3
  BYTE3       = 3'b101 ,        // Data     Byte3 -- Can NEVER  Stall
  BYTE4       = 3'b110 ,        // Data     Byte4 -- Can NEVER  Stall
  BYTE5       = 3'b111 ,        // Data     Byte5 -- Can NEVER  Stall
  Write       = 1'b0 ,          // Preamble Write specification
  Read        = 1'b1 ,          // Preamble Read  specification
  Bytes1      = 2'h0 ,          // Preamble 1 Byte transfer specification
  Bytes2      = 2'h1 ,          // Preamble 2 Byte transfer specification
  Bytes3      = 2'h2 ,          // Preamble 3 Byte transfer specification
  Bytes4      = 2'h3 ,          // Preamble 4 Byte transfer specification
  VisHead     = 13'h0000,       // Viewable starting register address
  VisTail     = 13'h0ffe;       // Viewable user ending register address
//------------------------------------------------------------------------


//------------------------------------------------------------------------
// Decode instruction register to decide transaction parameters 
//                                       == 0   /  == 1   /  == 2   /  == 3
//------------------------------------------------------------------------
assign OpType     = IRRreg[   15] ; // Write    / Read
assign OpPack     = IRRreg[14:13] ; // Bytes1   / Bytes2  / Bytes3  / Bytes4
assign O_reg_addr = IRRreg[7: 0] ; //
assign device_address = IRRreg[11: 8] ;
//------------------------------------------------------------------------



//------------------------------------------------------------------------
// This section of logic is responsible for deriving a synchronous control signal 
//  that forms the basis for when the internal Spi logic should not be asynchonously
//   cleared whenever the input I_csb signal is driven high by the user. 
//
// By reseting the internal state machines whenever the input I_csb signal is inactive,
//  a high confidence of deterministic state machine behaviour is afforded.
// Thus, to maintain this as well as supporting 'clock stalls' requires some trade-offs. 
//
// The Spi commitee has decided that 'clock stalls' are only effective for small 
//  sequential data packet transfers of less than 4 bytes and thus, the previously 
//    mentioned asynchonouls reset of the internal control logic only needs to be 
//     blocked for these underlying conditions.
// 
// Note: Simply commenting out the DontFlush assignment below returns the control
//        logic to its prior flush behavior whenever I_csb-->1.
//
// Note: Performing any access cycle where the number of bits Written/Read is not
//        on an 8N boundary causes DontFlush-->0 which will clear on I_csb==1.
// 
// Krishnan Feb 20, 2009
// Streaming mode transfer can be allowed to stall on byte boundaries if the
// transfer can be stopped based on the address ( I_wrap_stream = 0, and
// conditions related to it). In this case, the DontFlush should be enabled at
// byte boundaries.
// If streaming address wraps instead of stopping, only CSB can be used to end
// streaming mode. In this case, csb stalling at byte boundaries should cause a
// flush
//------------------------------------------------------------------------
always @( posedge I_sclk or negedge I_resetb ) // MUST use I_resetb so not reset recursive!
  begin
    if( ~I_resetb )
        DontFlush <= 0 ;
    else
      begin
        if( ~I_csb ) // Need to hold through  I_csb 0-->1-->0  cycle
          begin
            // This variable specifies when flushing should NOT be done to allow striding.
            // Note: Base 0 coding is utilized for BitCnt thus counts reflect this.
            //
            DontFlush <= ( (OpPack == Bytes1) & (BITcnt[5:3] == PMBL0) & (BITcnt[2:0] == 3'h7) ) // IRR0  bound
                       | ( (OpPack == Bytes2) & (BITcnt[5:3] == PMBL0) & (BITcnt[2:0] == 3'h7) ) // IRR0  bound
                       | ( (OpPack == Bytes3) & (BITcnt[5:3] == PMBL0) & (BITcnt[2:0] == 3'h7) ) // IRR0  bound
                       | ( (OpPack == Bytes4) & (BITcnt[5:3] == PMBL0) & (BITcnt[2:0] == 3'h7) ) // IRR0  bound

                       | ( (OpPack == Bytes1) & (BITcnt[5:3] == PMBL1) & (BITcnt[2:0] == 3'h7) ) // IRR1  bound
                       | ( (OpPack == Bytes2) & (BITcnt[5:3] == PMBL1) & (BITcnt[2:0] == 3'h7) ) // IRR1  bound
                       | ( (OpPack == Bytes3) & (BITcnt[5:3] == PMBL1) & (BITcnt[2:0] == 3'h7) ) // IRR1  bound
                       | ( (OpPack == Bytes4) & (BITcnt[5:3] == PMBL1) & (BITcnt[2:0] == 3'h7) ) // IRR1  bound

                       | ( (OpPack == Bytes2) & (BITcnt[5:3] == BYTE0) & (BITcnt[2:0] == 3'h7) ) // BYTE0 bound
                       | ( (OpPack == Bytes3) & (BITcnt[5:3] == BYTE0) & (BITcnt[2:0] == 3'h7) ) // BYTE0 bound
                       //| ( (OpPack == Bytes4) & (BITcnt[5:3] == BYTE0) & (BITcnt[2:0] == 3'h7) ) // BYTE0 bound !!

                       | ( (OpPack == Bytes3) & (BITcnt[5:3] == BYTE1) & (BITcnt[2:0] == 3'h7) ) // BYTE1 bound
                       //| ( (OpPack == Bytes4) & (BITcnt[5:3] == BYTE1) & (BITcnt[2:0] == 3'h7) ) // BYTE1 bound !!

                       //| ( (OpPack == Bytes4) & (BITcnt[5:3] == BYTE2) & (BITcnt[2:0] == 3'h7) ) // BYTE2 bound !!
                 // Important, following 3 lines were commented out
                 // in streaming mode, CSB deassertion will end streaming mode no matter where csb deassertion
                 // occurs. following 3 lines would not allow deassertion at byte boundary to reset the FSM.
                 // this goes back to be same as 9239, 9520 and 9548
                 //      | ( (OpPack == Bytes4) & (BITcnt[5:3] == BYTE3) & (BITcnt[2:0] == 3'h7) & ~I_wrap_stream ) // BYTE3 bound !!
                 //      | ( (OpPack == Bytes4) & (BITcnt[5:3] == BYTE4) & (BITcnt[2:0] == 3'h7) & ~I_wrap_stream ) // BYTE4 bound !!
                 //      | ( (OpPack == Bytes4) & (BITcnt[5:3] == BYTE5) & (BITcnt[2:0] == 3'h7) & ~I_wrap_stream ) // BYTE5 bound !!
                       ;
          end
      end
  end  
//------------------------------------------------------------------------


//------------------------------------------------------------------------
// Flush state machine when instruction completes
// Note: The state machines needs to be cleared with I_resetb REGARDLESS of I_csb level!
//calculate the total # of bytes in an instruction, add 2 bits for long addr, 1 if in short addr mode
//------------------------------------------------------------------------
assign expected_bytes = {1'b0,OpPack} + 2'b10  ;

//reached the end of the current instruction
assign Instruction_end = ((I_csb == 1'b0) && (BITcnt[2:0] == 3'b111) && (BITcnt [5:3] == expected_bytes) && (OpPack !=2'b11)) | stream_mode_stop;

//delay signal 1 sclk cycle
always @(posedge I_sclk or negedge I_resetb )
  if (~I_resetb)
    reg_done1 <=1'b0;
  else 
        reg_done1 <= Instruction_end;
      
//delay signal additional .5 cycle        
always @(negedge I_sclk or negedge I_resetb )
  if (~I_resetb)
    reg_done2 <=1'b0;
  else 
    reg_done2 <= reg_done1;    

assign reg1_and_reg2 = reg_done1 && ~reg_done2;
//------------------------------------------------------------------------


//------------------------------------------------------------------------
//when to flush:       hard reset / csb high on a nonstall / instruction completed
//------------------------------------------------------------------------
assign MachFlushb = ~( ~I_resetb | (I_csb & ~DontFlush) | reg1_and_reg2) ;        
//------------------------------------------------------------------------


//------------------------------------------------------------------------
// This is the internal bit counter used to track and steer (bit addressing) the 
//  placement of each serial data stream bit into/from the internal registers.
//
// Since Msb/Lsb data loading must be supported, along with data holding whenever I_csb is 
//  inactive, an input data multiplexor prior to the serializer flops is mandatory. 
//   Thus, a direct bit addressing structure is a very efficient implementation to utilize. 
//   
// Note: Since the orderring of the address bits within the Preamble has been logically
//        stated based on mode, a simple 'skip' over the unused portion (previously 
//         asynchronously cleared) simplifies the data loading and decoding.
//
// Note: Since the I_16b_mode is located in RegAdd00 ( 12'h000 ), the ONLY way to program
//        this register IF THE Current I_16b_mode=??? is to assume that it is ACTIVE and to
//         perform a Write to specifically set it to I_16b_mode=0 before proceeding!
//------------------------------------------------------------------------
always @( posedge I_sclk or negedge MachFlushb ) // Flush whenever I_resetb or Invalid Stalls!
  begin
    if ( ~MachFlushb )
      BITcnt[5:0] <= 0 ;
    else
      begin
        if( ~I_csb ) // NEEDED since BITcnt must be "held" during stalls!
          begin
            // Bit counter is always incrementing!
            BITcnt[2:0] <= BITcnt[2:0] + 1 ;
            // Count words and prevent wrapping back into IRR fields!
            case( BITcnt[5:3] )
              // Inorder to keep the logic simple, skip over unused IRR bits!
              PMBL0 : // IRR0--->IRR1 transition control -- INSshort == Skip a byte
                  if( BITcnt[2:0] == 3'h7 ) BITcnt[5:3] <= PMBL1 ;
              // All remaining Bit counter increments occurs on logical Byte boundaries
              //  and is limited to the last logical byte boundary occuring after BYTE4!
              PMBL1 : if( (BITcnt[2:0] == 3'h7) ) BITcnt[5:3] <= BYTE0 ; // IRR1 --->BYTE0
              BYTE0 : if( (BITcnt[2:0] == 3'h7) ) BITcnt[5:3] <= BYTE1 ; // BYTE0--->BYTE1
              BYTE1 : if( (BITcnt[2:0] == 3'h7) ) BITcnt[5:3] <= BYTE2 ; // BYTE1--->BYTE2
              BYTE2 : if( (BITcnt[2:0] == 3'h7) ) BITcnt[5:3] <= BYTE3 ; // BYTE2--->BYTE3
              BYTE3 : if( (BITcnt[2:0] == 3'h7) ) BITcnt[5:3] <= BYTE4 ; // BYTE3--->BYTE4
              BYTE4 : if( (BITcnt[2:0] == 3'h7) ) BITcnt[5:3] <= BYTE5 ; // BYTE4--->BYTE5
              BYTE5 : if( (BITcnt[2:0] == 3'h7) ) BITcnt[5:3] <= BYTE5 ; // BYTE5--->BYTE5
            endcase
          end
      end
  end
//------------------------------------------------------------------------


//------------------------------------------------------------------------
// Control the write strobe, Instruction regiter, serial data in
//------------------------------------------------------------------------
//
reg reg_wr_en;
reg reg_rd_en;
always @( posedge I_sclk or negedge MachFlushb )
  begin
    if( ~MachFlushb )
      begin
        IRRreg[15:0] <= 0 ;
        SerBits      <= 0 ;
        reg_wr_en  <= 0 ;
        reg_rd_en  <= 0 ;
      end
    else
      begin
        if( ~I_csb ) // Note: I_sdi=Z when Stalling... NEEDED for Quiet operation!
          begin
            // This control section handles the IRRreg specific data loading 
            //  during the Preamble portion of the data stream.
            // Note: also addresses the IRR address updating on byte boundaries!
            case( BITcnt[5:3] )
              PMBL0  : IRRreg[ BITuse[3:0] ] <= I_sdi ; // Load IRR0           // IRR0
              PMBL1  : IRRreg[ BITuse[3:0] ] <= I_sdi ; // Load IRR1           // IRR1
              BYTE0  : if( BITcnt[2:0] == 7) IRRreg[12:0] <= IRRnxt[12:0] ;  // BYTE0
              BYTE1  : if( BITcnt[2:0] == 7) IRRreg[12:0] <= IRRnxt[12:0] ;  // BYTE1
              BYTE2  : if( BITcnt[2:0] == 7) IRRreg[12:0] <= IRRnxt[12:0] ;  // BYTE2
              BYTE3  : if( BITcnt[2:0] == 7) IRRreg[12:0] <= IRRnxt[12:0] ;  // BYTE3
              BYTE4  : if( BITcnt[2:0] == 7) IRRreg[12:0] <= IRRnxt[12:0] ;  // BYTE4
              BYTE5  : if( BITcnt[2:0] == 7) IRRreg[12:0] <= IRRnxt[12:0] ;  // BYTE5
            endcase
            
            // This control section handles the Serializing of the input data stream  
            //  during the post Preamble portion as applicable to write cycles.
            // Note: flushes serializer during Preamble loading!
            case( BITcnt[5:3] )
              PMBL0  : SerBits <= 0 ; // Flush SerBits/O_reg_data when IRR0      // IRR0
              PMBL1  : SerBits <= 0 ; // Flush SerBits/O_reg_data when IRR1      // IRR1
              BYTE0  : if( OpType == Write ) SerBits[ BITuse[2:0] ] <= I_sdi ; // BYTE0
              BYTE1  : if( OpType == Write ) SerBits[ BITuse[2:0] ] <= I_sdi ; // BYTE1
              BYTE2  : if( OpType == Write ) SerBits[ BITuse[2:0] ] <= I_sdi ; // BYTE2
              BYTE3  : if( OpType == Write ) SerBits[ BITuse[2:0] ] <= I_sdi ; // BYTE3
              BYTE4  : if( OpType == Write ) SerBits[ BITuse[2:0] ] <= I_sdi ; // BYTE4
              BYTE5  : if( OpType == Write ) SerBits[ BITuse[2:0] ] <= I_sdi ; // BYTE5
            endcase

            // This control section handles the generation of a register write strobe
            //  during the post Preamble portion as applicable to write cycles.
            // Note: all internal register writes are inhibited during Preamble loading!
            case( BITcnt[5:3] )
              PMBL0  : reg_wr_en <= 0 ; // No O_reg_wr_en during IRR0                  // IRR0
              PMBL1  : reg_wr_en <= 0 ; // No O_reg_wr_en during IRR1                  // IRR1
              BYTE0  : reg_wr_en <= ((OpType == Write) & (BITcnt[2:0] == 6)) ;   // BYTE0
              BYTE1  : reg_wr_en <= ((OpType == Write) & (BITcnt[2:0] == 6)) ;   // BYTE1
              BYTE2  : reg_wr_en <= ((OpType == Write) & (BITcnt[2:0] == 6)) ;   // BYTE2
              BYTE3  : reg_wr_en <= ((OpType == Write) & (BITcnt[2:0] == 6)) ;   // BYTE3
              BYTE4  : reg_wr_en <= ((OpType == Write) & (BITcnt[2:0] == 6)) ;   // BYTE4
              BYTE5  : reg_wr_en <= ((OpType == Write) & (BITcnt[2:0] == 6)) ;   // BYTE5
            endcase
            
            
            //modified yizhou jiang
            case( BITcnt[5:3] )
              PMBL0  : reg_rd_en <= 0 ; // No O_reg_rd_en during IRR0           // IRR0
              PMBL1  : reg_rd_en <= ((OpType == Read) & (BITcnt[2:0] == 7)) ;   // IRR1
              BYTE0  : reg_rd_en <= ((OpType == Read) & (BITcnt[2:0] == 7)) ;   // BYTE0
              BYTE1  : reg_rd_en <= ((OpType == Read) & (BITcnt[2:0] == 7)) ;   // BYTE1
              BYTE2  : reg_rd_en <= ((OpType == Read) & (BITcnt[2:0] == 7)) ;   // BYTE2
              BYTE3  : reg_rd_en <= ((OpType == Read) & (BITcnt[2:0] == 7)) ;   // BYTE3
              BYTE4  : reg_rd_en <= ((OpType == Read) & (BITcnt[2:0] == 7)) ;   // BYTE4
              BYTE5  : reg_rd_en <= ((OpType == Read) & (BITcnt[2:0] == 7)) ;   // BYTE5
            endcase
          end
      end
  end
//------------------------------------------------------------------------


//------------------------------------------------------------------------
//FOLLOWING CODE CHANGED FROM LOURIER'S ORIGINAL, TO INCLUDE CORRECTED WRAP
//AROUND, BASED ON ENGINEER KEY ACTIVATED OR NOT
// This logic is responsible for specifying the next internal register address as
//  programmed by the initialized IRR register value and the requested Msb/Lsb mode.
// As specified by the Spi standard, when using Msb first mode, the internal register 
//  address is decremented after each byte transfer and likewise incremented whenever
//   the Lsb first mode is selected.
//
// Additional logic has being included to facilitate the "wrapping" of the 
//  visible register addresses so that internal test registers can be hidden
//   from the interface unless specifically initialed by the access itself.
//------------------------------------------------------------------------
always @( * )
  begin
    if (~I_en_eng_map & ( IRRreg[12:0] == VisHead ))
      IRRnxt[12:0] = VisTail    ; // if @ Visible Head, wrap to Visible Tail
    else
      IRRnxt[12:0] = IRRreg[12:0] - 1 ; // MSB addressing requires incrementing
  end
//------------------------------------------------------------------------


//------------------------------------------------------------------------
// Krishnan : Feb 19, 2009
// Logic to stop stream mode accesses from wrapping.
// Wrap if address is VisHead/VisTail, and instruction is a stream access, and
// bit counter indicates that one or more data has been transferred.
//------------------------------------------------------------------------
assign stream_mode_stop = ~I_wrap_stream & ( I_csb == 1'b0 ) & ( BITcnt[2:0] == 3'b111 ) &
                          (BITcnt [5:3] > 1 ) & ( OpPack == 2'b11 ) &
                          (  IRRreg[12:0] == VisHead  );
//------------------------------------------------------------------------



//------------------------------------------------------------------------
// This logic is responsible for forming the data word to be written into the internal
//  registers based on the content of the serializer byte, the mode selected and the
//   last data bit currently provided on the I_sdi input data line.
// Note: Used for direct (non-latent) loading of the input data into registers.
//------------------------------------------------------------------------
always @( * )
  begin
          // This is an EARLY MSB serial data version to registers (uses O_reg_wr_en pulse)
          O_reg_data[7:0] = { SerBits[7:1], I_sdi } ;  
  end
//------------------------------------------------------------------------


//------------------------------------------------------------------------
// Perform the output data readout steering using the BITcnt register
//  and DataDir to control the data bit output ordering.
//        LSB uses 0-->7, MSB uses 7-->0 bit orderring
//
// This latch is required to allow sufficient HOLD time relative to the 
//  rising edge of I_sclk on data reads.
//------------------------------------------------------------------------
assign BITuse[3:0] = BITcnt[3:0] ^ {4'b1111} ; 

// Steer output data bit based on bit counter.
// A zero cleans up transitions going to the pad to be READ limited.
(* dont_touch = "true" *)

always @ ( negedge I_sclk )
  begin
    O_sdo_tmp <= ( OpType == Read && device_address == I_da ) ? I_reg_data[ BITuse[2:0] ] : (1'b0);
  end


assign O_sdo = O_sdo_en ? O_sdo_tmp:0;//block_output

//------------------------------------------------------------------------
// Decoding of the Readback output enables 
//               (3 wire BiDirectional enable / 4 wire TriState enable)
// Concerns:
//  a)  Readback data is only possible in Data regions (Data BYTE0..BYTE5)
//  b)  Stalls must immediately disable outputs whenever I_csb-->1 
//       and re-enable when I_csb-->0/
//------------------------------------------------------------------------

always @( negedge I_sclk or negedge MachFlushb )
  begin
    if ( MachFlushb == 0 )
      begin
        RdStb <= 0 ; // Disable all output enable controls
      end
    else
      begin
        case( BITcnt[5:3] )
          PMBL0  :                      RdStb <= 0 ; // IRR0   no data
          PMBL1  :                      RdStb <= 0 ; // IRR1   no data
          BYTE0  : if( OpType == Read ) RdStb <= 1 ; // BYTE0 data read
          BYTE1  : if( OpType == Read ) RdStb <= 1 ; // BYTE1 data read
          BYTE2  : if( OpType == Read ) RdStb <= 1 ; // BYTE2 data read
          BYTE3  : if( OpType == Read ) RdStb <= 1 ; // BYTE3 data read
          BYTE4  : if( OpType == Read ) RdStb <= 1 ; // BYTE4 data read
          BYTE5  : if( OpType == Read ) RdStb <= 1 ; // BYTE5 data read
        endcase
      end
  end
//------------------------------------------------------------------------


//------------------------------------------------------------------------
// 3 wire Sdio pin BiDirect enable
// 1. When Csb = 0
// 2. In read mode (RdStb is high)
// 3. In Bi directional mode
// SDO should be 1'bz when in 3 wire mode or wrong device address .
//------------------------------------------------------------------------
wire sdo_flag_rst = (~I_resetb)|I_csb;
reg sdo_fix_op_flag;//edited by hzs
always@(posedge OpType or posedge sdo_flag_rst)begin
    if(sdo_flag_rst)begin
        sdo_fix_op_flag <= Write;//
    end
    else begin
        sdo_fix_op_flag <= Read;
    end
end

assign O_sdo_en =  (RdStb | (sdo_fix_op_flag==Read?reg1_and_reg2:0) ) & ~I_csb;
//------------------------------------------------------------------------


// when DEVICE ID = my ID , SPI want to read regc0 data, slave send data by SDO
//
assign O_reg_wr_en = reg_wr_en && (device_address==I_da);
//
assign O_reg_rd_en = reg_rd_en && (device_address==I_da);
//

 
  
endmodule

