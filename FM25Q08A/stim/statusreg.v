           

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
        tasks.send_data('h80);
        //tasks.send_data('h00);
        //set SRP1=0, SRP0=1
        tasks.close_comm;
        #(write_SR_delay+100);


         $display("\n ----- Enable the WP bit.");
        tasks.set_WP(0); 
        

         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h80);
        tasks.send_data('h01);
        //set SRP1=1, SRP0=1
        tasks.close_comm;
        #(write_VSR_delay+100);


         $display("\n ----- Disable the WP bit.");
        tasks.set_WP(1); 
        

         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h80);
        tasks.send_data('h01);
        //set SRP1=1, SRP0=1
        tasks.close_comm;
        #(write_VSR_delay+100);



         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h00);//reset the Status Reg.
        tasks.close_comm;
        #(write_VSR_delay+100);


 
         $display("\n ----- Reset in SPI mode.");

        tasks.send_command('h66);//Enable Reset
        tasks.close_comm;
        #100;
        tasks.send_command('h99);//Reset
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


        $display("\n ----- Write Status Register in SPI mode.");
        
        //tasks.write_enable;
        tasks.send_command('h31);
        tasks.send_data('h01);
        //set SRP1=1, SRP0=0
        tasks.close_comm;
        #(write_SR_delay+100);



        $display("\n ----- Write Status Register in SPI mode.");
        
        tasks.write_enable;
        tasks.send_command('h31);
        tasks.send_data('h01);
        //set SRP1=1, SRP0=0
        tasks.close_comm;
        #(write_SR_delay+100);



         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h00);//reset the Status Reg.
        tasks.close_comm;
        #(write_VSR_delay+100);



         $display("\n ----- Reset in SPI mode.");

        tasks.send_command('h66);//Enable Reset
        tasks.close_comm;
        #100;
        tasks.send_command('h99);//Reset
        tasks.close_comm;
        #(RSTlatency+100);


         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h00);//reset the Status Reg.
        tasks.close_comm;
        #(write_VSR_delay+100);


        $display("\n ----- Hardware Reset: power off, then power on again.");
        tasks.power_off;
        #100;
        tasks.power_up;
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
        tasks.send_data('h80);
        tasks.send_data('h01);
        //set SRP1=1, SRP0=1
        tasks.close_comm;
        #(write_SR_delay+100);


        $display("\n ----- Hardware Reset: power off, then power on again.");
        tasks.power_off;
        #100;
        tasks.power_up;
        #100;


         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h00);//reset the Status Reg.
        tasks.close_comm;
        #(write_VSR_delay+100);


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
