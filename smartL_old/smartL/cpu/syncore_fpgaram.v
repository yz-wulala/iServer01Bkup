 

 // Output ports are always registered to ensure Rams get packed into BlockRAM
 
// &Depend("syncore_ram.v"); @5

//`timescale 1ns/100ps
     module syncore_fpgaram 
(
	 PortAClk
	,PortAAddr
	,PortADataIn
	,PortAWriteEnable




	,PortADataOut


	);


  parameter	 DATAWIDTH = 1;
  parameter	 ADDRWIDTH = 2; 
  parameter	 MEMDEPTH = 2**(ADDRWIDTH);


  parameter 	 SPRAM				= 1;
  parameter 	 READ_MODE_A			= 2;
  parameter	 READ_WRITE_A			= 1;
  parameter	 ENABLE_WR_PORTA	 	= 1; 


  parameter	 REGISTER_RD_ADDR_PORTA 	= 0; 


  parameter	 REGISTER_OUTPUT_PORTA 		= 1; 
  parameter	 ENABLE_OUTPUT_REG_PORTA 	= 0; 
  parameter	 RESET_OUTPUT_REG_PORTA 	= 0; 


  parameter 	 READ_MODE_B			= 1;
  parameter	 READ_WRITE_B			= 1;
  parameter	 ENABLE_WR_PORTB	 	= 0; 


  parameter	 REGISTER_RD_ADDR_PORTB 	= 0; 


  parameter	 REGISTER_OUTPUT_PORTB 		= 0; 
  parameter	 ENABLE_OUTPUT_REG_PORTB 	= 0; 
  parameter	 RESET_OUTPUT_REG_PORTB 	= 0; 



  input 				PortAClk; 
  input  [ADDRWIDTH-1:0] 		PortAAddr;
  input  [DATAWIDTH-1:0] 		PortADataIn; 
  input 				PortAWriteEnable;




  output [DATAWIDTH-1:0] 		PortADataOut;



  wire 				PortAClk;
  wire  [ADDRWIDTH-1:0] 		PortAAddr;
  wire  [DATAWIDTH-1:0] 		PortADataIn;


  wire [DATAWIDTH-1:0] 		PortADataOut;


  wire 				PortAWriteEnable;
  wire 				PortAReadEnable;
  wire 				PortAReset;


  wire 				PortBClk;
  wire  [DATAWIDTH-1:0] 		PortBDataIn;
  wire 				PortBWriteEnable;
  wire  [ADDRWIDTH-1:0] 		PortBAddr;


  wire [DATAWIDTH-1:0] 		PortBDataOut;


  wire 				PortBReadEnable;
  wire 				PortBReset;



 Syncore_ram
 #(	
				.SPRAM(SPRAM)
				,.READ_MODE_A(READ_MODE_A)
				,.READ_MODE_B(READ_MODE_B)
				,.READ_WRITE_A(READ_WRITE_A)
				,.READ_WRITE_B(READ_WRITE_B)
				,.DATAWIDTH(DATAWIDTH)
				,.ADDRWIDTH(ADDRWIDTH)
				,.ENABLE_WR_PORTA(ENABLE_WR_PORTA)
				,.REGISTER_RD_ADDR_PORTA(REGISTER_RD_ADDR_PORTA)
				,.REGISTER_OUTPUT_PORTA(REGISTER_OUTPUT_PORTA)
				,.ENABLE_OUTPUT_REG_PORTA(ENABLE_OUTPUT_REG_PORTA)
				,.RESET_OUTPUT_REG_PORTA(RESET_OUTPUT_REG_PORTA)
				,.ENABLE_WR_PORTB(ENABLE_WR_PORTB)
				,.REGISTER_RD_ADDR_PORTB(REGISTER_RD_ADDR_PORTB)
				,.REGISTER_OUTPUT_PORTB(REGISTER_OUTPUT_PORTB)
				,.ENABLE_OUTPUT_REG_PORTB(ENABLE_OUTPUT_REG_PORTB)
				,.RESET_OUTPUT_REG_PORTB(RESET_OUTPUT_REG_PORTB)	
				) 
			U1(
				.PortClk({PortAClk})
				,.PortReset({PortAReset})
				,.PortWriteEnable({PortAWriteEnable})
				,.PortReadEnable({PortAReadEnable})
				,.PortDataIn({PortADataIn})
				,.PortAddr({PortAAddr})
				,.PortDataOut({PortADataOut})
				); 
endmodule
