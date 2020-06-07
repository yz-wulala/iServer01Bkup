`timescale 1ns / 1ns

`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file 


    defparam Testbench.DUT.memory_file = "mem_Q08A.vmf";

    reg [addrDim-1:0] A0, A1, A2, A3;
    integer i;

    initial begin

        A0='h001080;
        A1='h00110F;
        A2='h00007A;
        A3='h000130;
        tasks.init;



        //-------------
        //  SPI mode
        //-------------



         $display("\n ----- Read Security Sectors.");

        tasks.send_command('h48);
        tasks.send_address(A0);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;



         $display("\n ----- Program Security Sectors.");
        
        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A0);
        for (i=1; i<=8; i=i+1)
           tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);

        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A1);
        for (i=1; i<=8; i=i+1)
           tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);

         $display("\n ----- Read Security Sectors.");

        tasks.send_command('h48);
        tasks.send_address(A0);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;

        tasks.send_command('h48);
        tasks.send_address(A1);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;

         $display("\n ----- Erase Security Sectors.");
        
        tasks.write_enable;
        tasks.send_command('h44);
        tasks.send_address(A1);
        tasks.close_comm;
        #(erase_sector_delay+100);




         $display("\n ----- Read Security Sectors.");

        tasks.send_command('h48);
        tasks.send_address(A0);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;

        tasks.send_command('h48);
        tasks.send_address(A1);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;

         $display("\n ----- Volatile Write Status Register in SPI mode.");
         
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h08);//set the LB1 bit
        tasks.close_comm;
        #100;
    
        #write_VSR_delay;



         $display("\n ----- Program Security Sectors.");
        
        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A0);
        for (i=1; i<=8; i=i+1)
           tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);

        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A1);
        for (i=1; i<=8; i=i+1)
           tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);

		 $display("\n ----- Read Security Sectors.");

        tasks.send_command('h48);
        tasks.send_address(A0);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;

        tasks.send_command('h48);
        tasks.send_address(A1);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;

         $display("\n ----- Reset in SPI mode.");

        tasks.send_command('h66);//Enable Reset
        tasks.close_comm;
        #100;
        tasks.send_command('h99);//Reset
        tasks.close_comm;
        #100;

        #RSTlatency;


         $display("\n ----- Program Security Sectors.");
        
        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A0);
        for (i=1; i<=8; i=i+1)
           tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);


        
		$display("\n ----- Read Security Sectors.");

        tasks.send_command('h48);
        tasks.send_address(A0);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;



         $display("\n ----- Write Status Register in SPI mode.");
        
        // non-volatile SR write      
        tasks.write_enable;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h08);//set the LB1 bit
        tasks.close_comm;
        #100;
 
        #write_SR_delay;



        
        $display("\n ----- Hardware Reset: power off, then power on again.");
        
        //test non-volatile SR write
        tasks.power_off;
        #100;
        tasks.power_up;
        #100;


         $display("\n ----- Erase Security Sectors.");
        
        tasks.write_enable;
        tasks.send_command('h44);
        tasks.send_address(A1);
        tasks.close_comm;
        #(erase_sector_delay+100);



         $display("\n ----- Write Status Register in SPI mode.");
        
        // check the OTP protection of the LB1 bit             
        tasks.write_enable;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h00);//reset the LB1 bit
        tasks.close_comm;
        #100;
 
        #write_SR_delay;

         $display("\n ----- Read Security Sectors.");

        tasks.send_command('h48);
        tasks.send_address(A2);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;



         $display("\n ----- Program Security Sectors.");
        
        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A2);
        for (i=1; i<=8; i=i+1)
           tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);

        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A3);
        for (i=1; i<=8; i=i+1)
           tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);

         $display("\n ----- Read Security Sectors.");

        tasks.send_command('h48);
        tasks.send_address(A2);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;

        tasks.send_command('h48);
        tasks.send_address(A3);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;

         $display("\n ----- Erase Security Sectors.");
        
        tasks.write_enable;
        tasks.send_command('h44);
        tasks.send_address(A2);
        tasks.close_comm;
        #(erase_sector_delay+100);




         $display("\n ----- Read Security Sectors.");

        tasks.send_command('h48);
        tasks.send_address(A2);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;

        tasks.send_command('h48);
        tasks.send_address(A3);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;

         $display("\n ----- Volatile Write Status Register in SPI mode.");
         
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h04);//set the LB0 bit
        tasks.close_comm;
        #100;
    
        #write_VSR_delay;



         $display("\n ----- Program Security Sectors.");
        
        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A3);
        for (i=1; i<=8; i=i+1)
           tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);


        
		 $display("\n ----- Read Security Sectors.");

        tasks.send_command('h48);
        tasks.send_address(A3);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;



         $display("\n ----- Reset in SPI mode.");

        tasks.send_command('h66);//Enable Reset
        tasks.close_comm;
        #100;
        tasks.send_command('h99);//Reset
        tasks.close_comm;
        #100;

        #RSTlatency;


         $display("\n ----- Program Security Sectors.");
        
        tasks.write_enable;
        tasks.send_command('h42);
        tasks.send_address(A3);
        for (i=1; i<=8; i=i+1)
           tasks.send_data(i);
        tasks.close_comm;
        #(program_delay+100);


        
		$display("\n ----- Read Security Sectors.");

        tasks.send_command('h48);
        tasks.send_address(A3);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;



     #1000;
    end


endmodule    
