`timescale 1ns / 1ns

`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file 


    defparam Testbench.DUT.memory_file = "mem_Q08A.vmf";



    initial begin

        tasks.init;



        //-------------
        //  SPI mode
        //-------------

         $display("\n ----- Release Power Down Device ID in SPI mode.");

        // read Device ID while not in Power Down state
        tasks.send_command('hAB);
        tasks.send_dummy_dual(24);
        tasks.read(2);
        tasks.close_comm;
        #100;



         $display("\n ----- Power Down in SPI mode.");

        tasks.send_command('hB9);
        tasks.close_comm;
        #(100+deep_power_down_delay);



         $display("\n ----- Read Status Register 1 in SPI mode.");
        
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;
        #100;


         $display("\n ----- Release Power Down Device ID in SPI mode.");

        // read Device ID and release from Power Down state
        tasks.send_command('hAB);
        tasks.send_dummy_dual(24);
        tasks.read(1);
        tasks.close_comm;
        #100;


         $display("\n ----- Enable QPI.");

        tasks.send_command('h38);
        tasks.close_comm;
        #100;

        #(release_power_down_delay_2);



         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h02);//set the QE bit
        tasks.close_comm;
        #100;
    
        #write_VSR_delay;

        //-------------
        //  QPI mode
        //-------------


         $display("\n ----- Enable QPI.");

        tasks.send_command('h38);
        tasks.close_comm;
        #100;


         $display("\n ----- Release Power Down Device ID in QPI mode.");

        // read Device ID while not in Power Down state
        tasks.send_command_quad('hAB);
        tasks.send_dummy_quad(6);
        tasks.read_quad(2);
        tasks.close_comm;
        #100;


         $display("\n ----- Power Down in QPI mode.");

        tasks.send_command_quad('hB9);
        tasks.close_comm;
        #(100+deep_power_down_delay);



         $display("\n ----- Read Status Register 1 in QPI mode.");

        // test whether Read SR command is ignored or not in power down state        
        tasks.send_command_quad('h05);
        tasks.read_quad(1);
        tasks.close_comm;
        #100;



         $display("\n ----- Release Power Down Device ID in QPI mode.");

        // only release from Power Down state
        tasks.send_command_quad('hAB);
        tasks.close_comm;
        #100;


         $display("\n ----- Disable QPI.");

        tasks.send_command_quad('hFF);
        tasks.close_comm;
        #100;

        #(release_power_down_delay_1);



         $display("\n ----- Power Down in QPI mode.");

        tasks.send_command_quad('hB9);
        tasks.close_comm;
        #(100+deep_power_down_delay);



         $display("\n ----- Release Power Down Device ID in QPI mode.");

        // read Device ID and release from Power Down state
        tasks.send_command_quad('hAB);
        tasks.send_dummy_quad(6);
        tasks.read_quad(1);
        tasks.close_comm;
        #100;


        #(release_power_down_delay_2);



         $display("\n ----- Disable QPI.");

        tasks.send_command_quad('hFF);
        tasks.close_comm;
        #100;



     #1000;
    end


endmodule    
