/*-------------------------------------------------------------------------
-- The procedures here following may be used to send
-- commands to the serial flash.
-- These procedures must be combined using one of the following sequences:
--  
-- 1) send_command / close_comm 
-- 2) send_command / send_address / close_comm
-- 3) send_command / send_address / send_data /close_comm
-- 4) send_command / send_address / read / close_comm
-- 5) send_command / read / close_comm
-------------------------------------------------------------------------*/

`timescale 1ns / 1ns

module StimTasks (CS, HOLD_DQ3, DI_DQ0, DO_DQ1, VCC, WP_DQ2, clock_active);


`include "include/FM_DevParam.h"

    output CS;
    reg CS;
    
    output [`VoltageRange] VCC;
    reg [`VoltageRange] VCC;

    output clock_active;
    reg clock_active;

 
    inout DI_DQ0, DO_DQ1; 
    
    
    inout WP_DQ2;
    
    
    inout HOLD_DQ3; 
    

    reg[7:0] read_temp;


    assign DI_DQ0 = 1'bZ;
    assign DO_DQ1 = 1'bZ;
    assign WP_DQ2 = 1'bZ;
    assign HOLD_DQ3 = 1'bZ;
        



    //-----------------
    // Initialization
    //-----------------


    task init;
    begin
        
          CS = 1;
          force HOLD_DQ3= 1; 
          power_up;

    end
    endtask



    task power_up;
    begin
        setVCC('d3000); 
        force WP_DQ2=1;
        #(full_access_power_up_delay+100);

    end
    endtask



    task power_off;
    begin
        setVCC('d1500);   

    end
    endtask

    //----------------------------------------------------------
    // Tasks for send commands, send adressses, and read memory
    //----------------------------------------------------------


    task send_command;

    input [cmdDim-1:0] cmd;
    
    integer i;
    
    begin


        clock_active = 1;  
        #(T/4);
        CS=0; 
        #(T/4); 

        
        for (i=cmdDim-1; i>=1; i=i-1) begin
            force DI_DQ0=cmd[i]; 
            #T;
        end

        force DI_DQ0=cmd[0]; 
        #(T/2+T/4); 


    end
    endtask





   task send_command_dual;

    input [cmdDim-1:0] cmd;
    
    integer i;
    
    begin
        
        clock_active = 1;  
        #(T/4);
        CS=0; 
        #(T/4); 
     

        for (i=cmdDim-1; i>=3; i=i-2) begin
             force DO_DQ1=cmd[i]; 
             force DI_DQ0=cmd[i-1];
             #T;
        end
        force DO_DQ1=cmd[1];
        force DI_DQ0=cmd[0]; 
        #(T/2+T/4); 
 



    end
    endtask


    task send_command_quad;

    input [cmdDim-1:0] cmd;
    
    integer i;
    
    begin


        clock_active = 1;  
        #(T/4);
        CS=0; 
        #(T/4); 


        for (i=cmdDim-1; i>=7; i=i-4) begin
        
             force HOLD_DQ3=cmd[i];
             force WP_DQ2=cmd[i-1];
             force DO_DQ1=cmd[i-2]; 
             force DI_DQ0=cmd[i-3];
             #T;
        end   
        
            force HOLD_DQ3=cmd[3];
            force WP_DQ2=cmd[2];
            force DO_DQ1=cmd[1]; 
            force DI_DQ0=cmd[0]; 
            #(T/2+T/4);
           
 




   end
 endtask





    task send_address;

    input [23:0] addr;

    integer i;
    
    begin

        #(T/4);


//          force DI_DQ0=0; #T; force DI_DQ0=0;#T;

        for (i=23; i>=1; i=i-1) begin
            force DI_DQ0= addr[i]; #T;
        end    

        force DI_DQ0= addr[0];  #(T/2+T/4);


    end
    endtask 





 task XIP_send_address;

    input [23:0] addr;

    integer i;
    
    begin
        
        clock_active = 1;  #(T/4);
        CS=0;  
        #(T/4);


//          force DI_DQ0=0; #T; force DI_DQ0=0;#T;


        for (i=23; i>=1; i=i-1) begin
            force DI_DQ0= addr[i]; #T;
        end    

        force DI_DQ0= addr[0];  #(T/2+T/4);


    end
    endtask 






  task send_address_dual;

    input [23:0] addr;

    integer i;
    
    begin

        #(T/4);
        

//          force DO_DQ1=0;force DI_DQ0=0;#T;  


        for (i=23; i>=3; i=i-2) begin
            force DO_DQ1= addr[i];
            force DI_DQ0= addr[i-1];
            #T;
        end    
        force DO_DQ1= addr[1];
        force DI_DQ0= addr[0];  
		#(T/2+T/4);

        

    end
    endtask 




    task XIP_send_address_dual;

    input [23:0] addr;

    integer i;
    
    begin
        clock_active = 1;  #(T/4);
        CS=0;
        #(T/4);
        

//          force DO_DQ1=0;force DI_DQ0=0;#T;


        for (i=23; i>=3; i=i-2) begin
            force DO_DQ1= addr[i];
            force DI_DQ0= addr[i-1];
            #T;
        end    
        force DO_DQ1= addr[1];
        force DI_DQ0= addr[0];  
		#(T/2+T/4);

        

    end
    endtask 




    task send_address_quad;

    input [23 : 0] addr;

    integer i;
    
    begin

        #(T/4);     

//          force HOLD_DQ3=0;
//          force WP_DQ2=0;
//          force DO_DQ1=addr[addrDim-1]; 
//          force DI_DQ0=addr[addrDim-2];
//          #T;


        for (i=23; i>=7; i=i-4) begin

            force HOLD_DQ3=addr[i];       
            force WP_DQ2=addr[i-1];
            force DO_DQ1= addr[i-2];
            force DI_DQ0= addr[i-3];
            #T;
        end  

            force HOLD_DQ3=addr[i];
            force WP_DQ2=addr[i-1];
            force DO_DQ1= addr[i-2];
            force DI_DQ0= addr[i-3]; 
            #(T/2+T/4);
        
        

    end
    endtask 





    task XIP_send_address_quad;

    input [23:0] addr;

    integer i;
    
    begin
        
        clock_active = 1;  #(T/4);
        CS=0;
        #(T/4);
         
          

//         force HOLD_DQ3=0;
//         force WP_DQ2=0;
//
//          force DO_DQ1=addr[addrDim-1]; 
//          force DI_DQ0=addr[addrDim-2];
//          #T;


        for (i=23; i>=7; i=i-4) begin

            force HOLD_DQ3=addr[i];
            force WP_DQ2=addr[i-1];
            force DO_DQ1= addr[i-2];
            force DI_DQ0= addr[i-3];
            #T;
        end 
        
            force HOLD_DQ3=addr[i];
            force WP_DQ2=addr[i-1];
            force DO_DQ1= addr[i-2];
            force DI_DQ0= addr[i-3]; 
			
			#(T/2+T/4);
        

    end
    endtask 





    task send_data;

    input [dataDim-1:0] data;    
    integer i;
    
    begin

        #(T/4);

        
        for (i=dataDim-1; i>=1; i=i-1) begin
            force DI_DQ0=data[i]; 
            #T;
        end

        force DI_DQ0=data[0]; 
        #(T/2+T/4); 
        release DI_DQ0;

    end
    endtask






    
        task send_data_dual;

        input [dataDim-1:0] data;
        
        integer i;
        
        begin

            #(T/4);

            
            for (i=dataDim-1; i>=3; i=i-2) begin
                force DO_DQ1=data[i]; 
                force DI_DQ0=data[i-1];
                #T;
            end

            force DO_DQ1=data[1];
            force DI_DQ0=data[0]; 
            #(T/2+T/4);
			release DI_DQ0;
            release DO_DQ1;


        end
        endtask





        task send_data_quad;

        input [dataDim-1:0] data;
        
        integer i;
        
        begin

            #(T/4);

            
            for (i=dataDim-1; i>=7; i=i-4) begin

                force HOLD_DQ3=data[i];
                force WP_DQ2=data[i-1];
                force DO_DQ1=data[i-2]; 
                force DI_DQ0=data[i-3];
                #T;
            end

            force HOLD_DQ3=data[3];
            force WP_DQ2=data[2];
            force DO_DQ1=data[1];
            force DI_DQ0=data[0]; 
            #(T/2+T/4);

			release HOLD_DQ3;
            release WP_DQ2;
            release DO_DQ1;
			release DI_DQ0;

        end
        endtask





        task send_mbits_dual;

        input [dataDim-1:0] mbits;
        
        integer i;
        
        begin

            #(T/4);

            
            for (i=dataDim-1; i>=5; i=i-2) begin
                force DO_DQ1=mbits[i]; 
                force DI_DQ0=mbits[i-1];
                #T;
            end

            force DO_DQ1=1'bX;
            force DI_DQ0=1'bX; 
            #(T+T/2+T/4);

			release DI_DQ0;
			release DO_DQ1;
         


        end
        endtask





        task send_mbits_quad;

        input [dataDim-1:0] mbits;
        
        integer i;
        
        begin

            #(T/4);

            
            for (i=dataDim-1; i>=7; i=i-4) begin

                force HOLD_DQ3=mbits[i];
                force WP_DQ2=mbits[i-1];
                force DO_DQ1=mbits[i-2]; 
                force DI_DQ0=mbits[i-3];
                #T;
            end

            force HOLD_DQ3=1'bX;
            force WP_DQ2=1'bX;
            force DO_DQ1=1'bX;
            force DI_DQ0=1'bX; 
            #(T/2+T/4);  

			release DI_DQ0;
			release DO_DQ1;
			release WP_DQ2;
			release HOLD_DQ3;
   


        end
        endtask





task send_dummy_dual;

    input integer n;
    
    integer i;
    
    begin

        #(T/4);
			release DI_DQ0;
			release DO_DQ1;
        
        for (i=n-1; i>=1; i=i-1) begin       
            #T;
        end           
            #(T/2+T/4); 

    end
    endtask






   task send_dummy_quad;

    input integer n;
 
    integer i;
    
    begin

        #(T/4);

			release DI_DQ0;
			release DO_DQ1;
			release WP_DQ2;
			release HOLD_DQ3;

       
        for (i=n-1; i>=1; i=i-1) begin                     
             #T;
        end      
         
        #(T/2+T/4); 

    end
    endtask


 
    task read;

    input n;
    integer n, i, j;

    
    for (i=1; i<=n; i=i+1) begin
			#(T/4);
			release DO_DQ1;
			#(T/2);
			for (j=7; j>=1; j=j-1)
			begin
			read_temp[j] = DO_DQ1;
			#T;
            end
			read_temp[j] = DO_DQ1;
			$display("  [%0t ns] Read Data From Flash: %h", $time, read_temp);
			#(T/4);
    end  

    endtask




 

    
    task read_dual;

    input n;
    integer n, i, j;
    for (i=1; i<=n; i=i+1) begin
			#(T/4);
			release DI_DQ0;
			release DO_DQ1;
			#(T/2);
			for (j=7; j>=3; j=j-2)
			begin
			read_temp[j] = DO_DQ1;
			read_temp[j-1] = DI_DQ0;
			#T;
            end
			read_temp[j] = DO_DQ1;
			read_temp[j-1] = DI_DQ0;
			$display("  [%0t ns] Dual Read Data From Flash: %h", $time, read_temp);
			#(T/4);
    end 
    endtask





  
   task read_quad;

    input n;
    integer n, i, j;
    for (i=1; i<=n; i=i+1) begin
			#(T/4);
    	    release DI_DQ0;
			release DO_DQ1;
            release WP_DQ2;
            release HOLD_DQ3;
			#(T/2);
			for (j=7; j>=4; j=j-4)
			begin
			read_temp[j] = HOLD_DQ3;
			read_temp[j-1] = WP_DQ2;
			read_temp[j-2] = DO_DQ1;
			read_temp[j-3] = DI_DQ0;
			#T;
            end
			read_temp[j] = HOLD_DQ3;
			read_temp[j-1] = WP_DQ2;
			read_temp[j-2] = DO_DQ1;
			read_temp[j-3] = DI_DQ0;
			$display("  [%0t ns] Quad Read Data From Flash: %h", $time, read_temp);
            #(T/4);
    end
    endtask







    task close_comm;

    begin

        #(T/4);
        CS = 1;
        clock_active = 0;
		#tSHQZ;
		release DI_DQ0;
        # 100;

    end
    endtask





    //------------------
    // others tasks
    //------------------
 

    task set_WP;
    input value;
        force WP_DQ2= value;
    endtask


    task set_HOLD;
    input value;
        force HOLD_DQ3= value;
    endtask


    task set_clock;
    input value;
        clock_active = value;
    endtask 


    task set_CS;
    input value;
        CS = value;
    endtask
    

    task setVCC;
    input [`VoltageRange] value;
        VCC = value;
    endtask


    task VCC_waveform;
    input [`VoltageRange] V1; input time t1;
    input [`VoltageRange] V2; input time t2;
    input [`VoltageRange] V3; input time t3;
    begin
      VCC=V1; #t1;
      VCC=V2; #t2;
      VCC=V3; #t3;
    end
    endtask



    




    //------------------------------------------
    // Tasks to send complete command sequences
    //------------------------------------------


    task write_enable;
    begin
        send_command('h06); //write enable
        close_comm;
        #100;
    end  
    endtask

    task write_enable_quad;
    begin
        send_command_quad('h06); //write enable
        close_comm;
        #100;
    end  
    endtask



endmodule    

