           

`timescale 1ns / 1ns

`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file 


    defparam Testbench.DUT.memory_file = "mem_Q08A.vmf";


    reg [addrDim-1:0] A0, A1, A2, A3, A4, A5;
    integer i,j;

    initial begin
            
        A0='h000000;

        tasks.init;
        
        
        
        //---------------------
        //  SPI read
        //---------------------

        $display("\n ----- Read Data.");

        // read from memory file
        tasks.send_command('h03);
        tasks.send_address(A0);
        tasks.read(1);
        tasks.close_comm;
        #100;
        
        
        
        
        //-----------------------
        //  SPI program
        //-----------------------



        $display("\n ----- Page Program in SPI mode.");
        
        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A0);
        tasks.send_data('hAA);
		tasks.close_comm;
        #(program_delay+100);
        
        
        
        
        //---------------------
        //  SPI read
        //---------------------

        $display("\n ----- Read Data.");

        // read from memory file
        tasks.send_command('h03);
        tasks.send_address(A0);
        tasks.read(1);
        tasks.close_comm;
        #100;
        
        
     #1000;
    end


endmodule   
