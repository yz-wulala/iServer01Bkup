           

`timescale 1ns / 1ns

`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file 


    defparam Testbench.DUT.memory_file = "mem_Q08A.vmf";


    reg [addrDim-1:0] A0, A1, A2, A3, A4, A5;
    integer i,j;

    initial begin
            
        A0='h070000;
        A1='h010000;
        A2='h017000;
        A3='h01FFFC;
        A4='h000008;
        A5='h0FFFFA;
        tasks.init;
        
        
        
        //---------------------
        //  SPI read
        //---------------------

        $display("\n ----- Read Data.");

        // read from memory file
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(16);
        tasks.close_comm;
        #100;
        
        
        
        
        //-----------------------
        //  SPI program
        //-----------------------



        $display("\n ----- Page Program in SPI mode.");
        
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A1);
        for (i=1; i<=16; i=i+1)
           tasks.send_data(i);
		tasks.close_comm;
        #(program_delay+100);
        
        
        
        
        //---------------------
        //  SPI read
        //---------------------

        $display("\n ----- Read Data.");

        // read from memory file
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(16);
        tasks.close_comm;
        #100;
        
        
     #1000;
    end


endmodule   
