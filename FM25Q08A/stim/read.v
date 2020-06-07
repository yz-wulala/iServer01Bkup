           

`timescale 1ns / 1ns

`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file 


    defparam Testbench.DUT.memory_file = "mem_Q08A.vmf";


//    reg [addrDim-1:0] A0='h0, A1, A2='h08, A3, A4;
    reg [23:0] A0='h0, A1, A2='h08, A3, A4;


    initial begin
            
        A1='hFFFFFA;
        A3='h017000;
        A4='h01FFFC;
        tasks.init;

        //---------------------
        //  SPI read
        //---------------------

        $display("\n ----- Read Data.");

        // read from memory file
        tasks.send_command('h03);
        tasks.send_address(A1);
        tasks.read(10);
        tasks.close_comm;
        #100;



        $display("\n ----- Fast Read in SPI mode.");

        // read from memory file
        tasks.send_command('h0B);
        tasks.send_address(A0);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;
        

        $display("\n ----- Read Manufacturer Device ID in SPI mode.");

        // read from memory file
        tasks.send_command('h90);
        tasks.send_address('h00);
        tasks.read(3);
        tasks.close_comm;
        #100;
        tasks.send_command('h90);
        tasks.send_address('h01);
        tasks.read(3);
        tasks.close_comm;
        #100;


        $display("\n ----- Read JEDEC ID in SPI mode.");

        // read from memory file
        tasks.send_command('h9F);
        tasks.read(3);
        tasks.close_comm;
        #100;


        $display("\n ----- Read Unique ID.");

        // read from memory file
        tasks.send_command('h4B);
        tasks.send_dummy_dual(32);
        tasks.read(8);
        tasks.close_comm;
        #100;

        
        $display("\n ----- Fast Read Dual Output.");

        // read from memory file
        tasks.send_command('h3B);
        tasks.send_address(A0);
        tasks.send_dummy_dual(8);
        tasks.read_dual(8);
        tasks.close_comm;
        #100;


         $display("\n ----- Fast Read Dual I/O.");

        // read from memory file
        tasks.send_command('hBB);
        tasks.send_address_dual(A2);
        tasks.send_mbits_dual('h20);//open continuous mode
        tasks.read_dual(8);
        tasks.close_comm;
        #100;


        $display("\n ----- Fast Read Dual I/O, in continuous mode.");

        // read from memory file
        tasks.XIP_send_address_dual(A3);
        tasks.send_mbits_dual('hFF);
        tasks.read_dual(20);
        tasks.close_comm;
        #100;


         $display("\n ----- Read Manufacturer Device ID Dual IO.");

        // read from memory file
        tasks.send_command('h92);
        tasks.send_address_dual('h00);
        tasks.send_mbits_dual('h20);//open continuous mode
        tasks.read_dual(3);
        tasks.close_comm;
        #100;
		
				
	    $display("\n ----- Read Manufacturer Device ID Dual IO, in continuous mode.");

        tasks.XIP_send_address_dual('h01);
        tasks.send_mbits_dual('hFF);
        tasks.read_dual(3);
        tasks.close_comm;
        #100;

        
         $display("\n ----- Read Status Registers in SPI mode.");
        
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;
        #100;
        tasks.send_command('h35);
        tasks.read(1);
        tasks.close_comm;
        #100;

        
         $display("\n ----- Write Status Register in SPI mode.");
        
        tasks.write_enable;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h02);//set the QE bit
        tasks.close_comm;
        #100;
 
        #write_SR_delay;

         $display("\n ----- Fast Read Quad Output.");

        // read from memory file
        tasks.send_command('h6B);
        tasks.send_address(A2);
        tasks.send_dummy_quad(8);
        tasks.read_quad(8);
        tasks.close_comm;
        #100;


         $display("\n ----- Read Manufacturer Device ID Quad IO.");

        // read from memory file
        tasks.send_command('h94);
        tasks.send_address_quad('h00);
        tasks.send_mbits_quad('h20);//open continuous mode
        tasks.send_dummy_quad(4);
        tasks.read_quad(3);
        tasks.close_comm;
        #100;

		
        $display("\n ----- Read Manufacturer Device ID Quad IO, in continuous mode.");

        tasks.XIP_send_address_quad('h01);
        tasks.send_mbits_quad('hFF);
        tasks.send_dummy_quad(4);
        tasks.read_quad(5);
        tasks.close_comm;
        #100;       

         $display("\n ----- Fast Read Quad I/O in SPI mode.");

        // read from memory file
        tasks.send_command('hEB);
        tasks.send_address_quad(A0);
        tasks.send_mbits_quad('hFF);
        tasks.send_dummy_quad(4);
        tasks.read_quad(8);
        tasks.close_comm;
        #100;


         $display("\n ----- Word Read Quad I/O");

        // read from memory file
        tasks.send_command('hE7);
        tasks.send_address_quad('h01);
        tasks.send_mbits_quad('hFF);
        tasks.send_dummy_quad(2);
        tasks.read_quad(8);
        tasks.close_comm;
        #100;


         $display("\n ----- Word Read Quad I/O.");

        // read from memory file
        tasks.send_command('hE7);
        tasks.send_address_quad(A3);
        tasks.send_mbits_quad('hFF);
        tasks.send_dummy_quad(2);
        tasks.read_quad(8);
        tasks.close_comm;
        #100;



        $display("\n ----- Set Burst with Wrap with 16-bytes wrap length.");

        // open wrap mode and set wrap length
        tasks.send_command('h77);
        tasks.send_dummy_quad(6);
        tasks.send_data_quad('h20);
        tasks.close_comm;
        #100;


        $display("\n ----- Word Read Quad I/O in wrap mode.");

        // word wrap quad read from memory file
        tasks.send_command('hE7);
        tasks.send_address_quad(A3);
        tasks.send_mbits_quad('h20);//open continuous mode
        tasks.send_dummy_quad(2);
        tasks.read_quad(32);
        tasks.close_comm;
        #100;


        $display("\n ----- Word Read Quad I/O in wrap mode, in continuous mode.");

        // word wrap quad read from memory file
        tasks.XIP_send_address_quad(A3);
        tasks.send_mbits_quad('hFF);
        tasks.send_dummy_quad(2);
        tasks.read_quad(32);
        tasks.close_comm;
        #100;



        $display("\n ----- Set Burst with Wrap with wrap mode closed.");

        // close the wrap mode
        tasks.send_command('h77);
        tasks.send_dummy_quad(6);
        tasks.send_data_quad('h50);//set 32byte wrap length for the following Burst Read with Wrap command.
        tasks.close_comm;
        #100;

         $display("\n ----- Fast Read Quad I/O in SPI mode.");

        // test whether the wrap mode is closed.
        tasks.send_command('hEB);
        tasks.send_address_quad(A3);
        tasks.send_mbits_quad('hFF);
        tasks.send_dummy_quad(4);
        tasks.read_quad(20);
        tasks.close_comm;
        #100;


         $display("\n ----- Octal Word Read Quad I/O,");

        // read from memory file
        tasks.send_command('hE3);
        tasks.send_address_quad('h03);// error occurs
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(8);
        tasks.close_comm;
        #100; 
		
		
		$display("\n ----- Octal Word Read Quad I/O.");

        //retry in another legal addr 
        tasks.send_command('hE3);
        tasks.send_address_quad(A4);
        tasks.send_mbits_quad('h20);
        tasks.read_quad(8);
        tasks.close_comm;
        #100;


         $display("\n ----- Octal Word Read Quad I/O in continuous mode.");

        // read from memory file
        tasks.XIP_send_address_quad(A4);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(8);
        tasks.close_comm;
        #100;


        //---------------------
        //  QPI read
        //---------------------


         $display("\n ----- Enable QPI.");

        tasks.send_command('h38);
        tasks.close_comm;
        #100;



        $display("\n ----- Read JEDEC ID in QPI mode.");

        // read from memory file
        tasks.send_command_quad('h9F);
        tasks.read_quad(3);
        tasks.close_comm;
        #100;


        $display("\n ----- Read Manufacturer Device ID in QPI mode.");

        // read from memory file
        tasks.send_command_quad('h90);
        tasks.send_address_quad('h00);
        tasks.read_quad(3);
        tasks.close_comm;
        #100;
        tasks.send_command_quad('h90);
        tasks.send_address_quad('h01);
        tasks.read_quad(3);
        tasks.close_comm;
        #100;


        $display("\n ----- Fast Read in QPI mode.");

        // read from memory file
        tasks.send_command_quad('h0B);
        tasks.send_address_quad(A3);
        tasks.send_dummy_quad(2); //before parameters are set, the default dummy number is 2 
        tasks.read_quad(8);
        tasks.close_comm;
        #100;


        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A3);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(8);
        tasks.close_comm;
        #100;


        $display("\n ----- Burst Read with Wrap.");

        // read from memory file
        tasks.send_command_quad('h0C);
        tasks.send_address_quad(A3);
        tasks.send_dummy_quad(8);
        tasks.read_quad(40);
        tasks.close_comm;
        #100;


        $display("\n ----- Set Read Parameters.");

        // set 8 dummy clocks and 16-bytes wrap length
        tasks.send_command_quad('hC0);
        tasks.send_data_quad('h31);
        tasks.close_comm;
        #100;


        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A3);
        tasks.send_mbits_quad('h20);// open the continuous mode
        tasks.send_dummy_quad(6);
        tasks.read_quad(32);
        tasks.close_comm;
        #100;



        $display("\n ----- Fast Read Quad I/O in QPI mode, in continuous mode.");

        // read from memory file
        tasks.XIP_send_address_quad(A3);
        tasks.send_mbits_quad('hFF);
        tasks.send_dummy_quad(6);
        tasks.read_quad(32);
        tasks.close_comm;
        #100;


        $display("\n ----- Burst Read with Wrap.");

        // read from memory file
        tasks.send_command_quad('h0C);
        tasks.send_address_quad(A3);
        tasks.send_dummy_quad(8);
        tasks.read_quad(32);
        tasks.close_comm;
        #100;



        $display("\n ----- Set Read Parameters.");

        // set 4 dummy clocks and 32-bytes wrap length
        tasks.send_command_quad('hC0);
        tasks.send_data_quad('h12);
        tasks.close_comm;
        #100;


        $display("\n ----- Burst Read with Wrap.");

        // read from memory file
        tasks.send_command_quad('h0C);
        tasks.send_address_quad(A3);
        tasks.send_dummy_quad(4);
        tasks.read_quad(40);
        tasks.close_comm;
        #100;



        $display("\n ----- Set Read Parameters.");

        // set 6 dummy clocks and 64-bytes wrap length
        tasks.send_command_quad('hC0);
        tasks.send_data_quad('h23);
        tasks.close_comm;
        #100;


        $display("\n ----- Burst Read with Wrap.");

        // read from memory file
        tasks.send_command_quad('h0C);
        tasks.send_address_quad(A3);
        tasks.send_dummy_quad(6);
        tasks.read_quad(70);
        tasks.close_comm;
        #100;



  /*      $display("\n ----- Set Read Parameters.");

        // set 2 dummy clocks and 8-bytes wrap length
        tasks.send_command_quad('hC0);
        tasks.send_data_quad('h00);
        tasks.close_comm;
        #100;


        $display("\n ----- Burst Read with Wrap.");

        // read from memory file
        tasks.send_command_quad('h0C);
        tasks.send_address_quad(A1);
        tasks.send_dummy_quad(2);
        tasks.read_quad(16);
        tasks.close_comm;
        #100;


        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A3);
        tasks.send_mbits_quad('hFF);
		tasks.read_quad(8);
        tasks.close_comm;
        #100;
*/
 
         $display("\n ----- Reset in QPI mode.");

        //test the default dummy clk numbers and wrap length 
        tasks.send_command_quad('h66);//Enable Reset
        tasks.close_comm;
        #100;
        tasks.send_command_quad('h99);//Reset
        tasks.close_comm;
        #100;


        #RSTlatency;


        $display("\n ----- Burst Read with Wrap.");

        // read from memory file
        tasks.send_command_quad('h0C);
        tasks.send_address_quad(A1);
        tasks.send_dummy_quad(2);
        tasks.read_quad(16);
        tasks.close_comm;
        #100;


        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A3);
        tasks.send_mbits_quad('hFF);
		tasks.read_quad(8);
        tasks.close_comm;
        #100;


         $display("\n ----- Disable QPI.");

        tasks.send_command_quad('hFF);
        tasks.close_comm;
        #100;


        //---------------------
        //  Change to SPI mode
        //---------------------
    

         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h00);//reset the QE bit
        tasks.close_comm;
        #100;

        #write_VSR_delay;
   

         $display("\n ----- Read Status Registers in SPI mode.");
        
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;
        #100;
        tasks.send_command('h35);
        tasks.read(1);
        tasks.close_comm;
        #100;


 


     #1000;
    end


endmodule    
