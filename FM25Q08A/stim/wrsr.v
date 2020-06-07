           

`timescale 1ns / 1ns

`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file 


    defparam Testbench.DUT.memory_file = "mem_Q08A.vmf";


    initial begin
            

        tasks.init;


        //----------------------------
        //  Status Registers Options
        //----------------------------

        
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
        tasks.send_data('h62);
        //tasks.send_data('h00);
        //set SRP1=0, SRP0=1
        tasks.close_comm;
        #(write_SR_delay+100);

        tasks.write_enable;
        tasks.send_command('h01);
        tasks.send_data('h5C);
        tasks.send_data('hEE);
        tasks.close_comm;
        #(write_SR_delay+100);


       tasks.write_enable;
       tasks.send_command('h31);
       tasks.send_data('h12);
       tasks.close_comm;
       #(write_SR_delay+100);


         $display("\n ----- Read Status Registers in SPI mode.");
        
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;
        #100;
        tasks.send_command('h35);
        tasks.read(1);
        tasks.close_comm;
        #100;

        #RSTlatency;


         $display("\n ----- Read Status Registers in SPI mode.");
        
        tasks.send_command('h05);
        tasks.read(1);
        tasks.close_comm;
        #100;
        tasks.send_command('h35);
        tasks.read(1);
        tasks.close_comm;
        #100;


/*         $display("\n ----- Write Status Register in SPI mode.");

         tasks.write_enable;
         tasks.send_command('h01);
         tasks.send_data('h00);
        //tasks.send_data('h00);
       //set SRP1=0, SRP0=1
         tasks.close_comm;
         #(write_SR_delay+100);

*/


         $display("\n ----- Enable QPI.");

        tasks.send_command('h38);
        tasks.close_comm;
        #100;

         $display("\n ----- Read Status Registers in QPI mode.");
        
        tasks.send_command_quad('h05);
        tasks.read_quad(1);
        tasks.close_comm;
        #100;
        tasks.send_command_quad('h35);
        tasks.read_quad(1);
        tasks.close_comm;
        #100;

        $display("\n ----- Write Status Register in QPI mode.");
        
        tasks.write_enable_quad;
        tasks.send_command_quad('h01);
        tasks.send_data_quad('h62);
        //tasks.send_data('h00);
        //set SRP1=0, SRP0=1
        tasks.close_comm;
        #(write_SR_delay+100);

        tasks.write_enable_quad;
        tasks.send_command_quad('h01);
        tasks.send_data_quad('h5C);
        tasks.send_data_quad('hEE);
        tasks.close_comm;
        #(write_SR_delay+100);


       tasks.write_enable_quad;
       tasks.send_command_quad('h31);
       tasks.send_data_quad('h10);
       tasks.close_comm;
       #(write_SR_delay+100);


        $display("\n ----- Read Status Registers in QPI mode.");
        
        tasks.send_command_quad('h05);
        tasks.read_quad(1);
        tasks.close_comm;
        #100;
        tasks.send_command_quad('h35);
        tasks.read_quad(1);
        tasks.close_comm;
        #100;


     #1000;
    end


endmodule    
