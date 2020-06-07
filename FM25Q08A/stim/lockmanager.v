           

`timescale 1ns / 1ns

`include "top/StimGen_interface.h"
// the port list of current module is contained in "StimGen_interface.h" file 


    defparam Testbench.DUT.memory_file = "mem_Q08A.vmf";


    reg [addrDim-1:0] A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15;
    integer i,j;

    initial begin
            
        A0='h0F0000;
        A1='h0AC000;
        A2='h0F3000;
        A3='h078000;
        A4='h0F7000;
        A5='h0F8000;
        A6='h0FB000;
        A7='h0FDFFA;
        A8='h0FFFFE;
        A9='h000000;
        A10='h001000;
        A11='h003000;
        A12='h007000;
        A13='h004000;
        A14='h008000;
        A15='h0FCFFA;

        tasks.init;


        //-------------------------------------
        //  Status Register Memory Protection
        //-------------------------------------


         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h50);
        tasks.send_data('h10);
        //set CMP=1,SEC=0, TB=0, BP2=1, BP1=0, BP0=0
        tasks.close_comm;
        #100;

        #write_VSR_delay;



        $display("\n ----- Fast Read in SPI mode.");

        // read from memory file
        tasks.send_command('h0B);
        tasks.send_address(A15);
        tasks.send_dummy_dual(8);
        tasks.read(4);
        tasks.close_comm;
        #100;

        #write_VSR_delay;


        $display("\n ----- Page Program in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h02);
        tasks.send_address(A15);
        for (i=1; i<=16; i=i+1)
           tasks.send_data(i);
        tasks.close_comm;
        #100;

        #program_delay;

        $display("\n ----- Block Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(A15);
        tasks.close_comm;
        #(erase_block_delay+100);


        $display("\n ----- Subblock Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h52);
        tasks.send_address(A15);
        tasks.close_comm;
        #(erase_subblock_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A15);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A14);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A13);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A12);
        tasks.close_comm;
        #(erase_sector_delay+100);


        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A11);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A10);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A9);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A8);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A7);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A6);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A5);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A4);
        tasks.close_comm;
        #(erase_sector_delay+100);


        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A3);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A2);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A1);
        tasks.close_comm;
        #(erase_sector_delay+100);

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A0);
        tasks.close_comm;
        #(erase_sector_delay+100);


        $display("\n ----- Chip Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h60);
        tasks.close_comm;
        #(erase_chip_delay+100);


/*

        $display("\n ----- Block Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(A0);
        tasks.close_comm;
        #100;


        $display("\n ----- Fast Read in SPI mode.");

        // read from memory file
        tasks.send_command('h0B);
        tasks.send_address(A4);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;


        $display("\n ----- Block Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(A4);
        tasks.close_comm;
        #(erase_block_delay+100);


        $display("\n ----- Fast Read in SPI mode.");

        // read from memory file
        tasks.send_command('h0B);
        tasks.send_address(A4);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;





        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A0);
        tasks.close_comm;
        #100;




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


        $display("\n ----- Quad Page Program in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h32);
        tasks.send_address(A0);
        for (i=1; i<=30; i=i+1)
           for (j=1; j<=10; j=j+1)
              tasks.send_data_quad(i);
        tasks.close_comm;
        #(program_delay+100);


         $display("\n ----- Fast Read Quad I/O in SPI mode.");

        // read from memory file
        tasks.send_command('hEB);
        tasks.send_address_quad(A0);
        tasks.send_mbits_quad('hFF);
        tasks.send_dummy_quad(4);
        tasks.read_quad(100);
        tasks.close_comm;
        #100;


        //-----------------------
        //  QPI program & erase
        //-----------------------


         $display("\n ----- Enable QPI.");

        tasks.send_command('h38);
        tasks.close_comm;
        #100;


        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A1);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(8);
        tasks.close_comm;
        #100;

 

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A0);
        tasks.close_comm;
        #(erase_sector_delay+100);


  
        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A1);
        tasks.close_comm;
        #(erase_sector_delay+100);




        $display("\n ----- Fast Read in SPI mode.");

        // read from memory file
        tasks.send_command('h0B);
        tasks.send_address(A0);
        tasks.send_dummy_dual(8);
        tasks.read(4);
        tasks.close_comm;
        #100;





/*         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h64);
        tasks.send_data('h10);
        //set CMP=1, TB=1, BP2=0, BP1=0, BP0=1
        tasks.close_comm;
        #100;

        #write_VSR_delay;



        $display("\n ----- Fast Read in SPI mode.");

        // read from memory file
        tasks.send_command('h0B);
        tasks.send_address(A4);
        tasks.send_dummy_dual(8);
        tasks.read(4);
        tasks.close_comm;
        #100;
        

        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A4);
        tasks.close_comm;
        #(erase_sector_delay+100);


  
        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A3);
        tasks.close_comm;
        #(erase_sector_delay+100);




        $display("\n ----- Fast Read in SPI mode.");

        // read from memory file
        tasks.send_command('h0B);
        tasks.send_address(A4);
        tasks.send_dummy_dual(8);
        tasks.read(4);
        tasks.close_comm;
        #100;






         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h10);
        tasks.send_data('h12);//set QE=1
        //set CMP=1, TB=0, BP2=1, BP1=0, BP0=0
        tasks.close_comm;
        #100;

        #write_VSR_delay;



        $display("\n ----- Quad Page Program in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h32);
        tasks.send_address(A2);
        for (i=1; i<=8; i=i+1)
              tasks.send_data_quad(i);
        tasks.close_comm;
        #(program_delay+100);


       $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A4);
        tasks.close_comm;
        #(erase_sector_delay+100);




         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h14);
        tasks.send_data('h02);//set QE=1
        //set CMP=0, TB=0, BP2=1, BP1=0, BP0=1
        tasks.close_comm;
        #100;

        #write_VSR_delay;



        $display("\n ----- Quad Page Program in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h32);
        tasks.send_address(A2);
        for (i=1; i<=8; i=i+1)
              tasks.send_data_quad(i);
        tasks.close_comm;
        #(program_delay+100);

      
        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A4);
        tasks.close_comm;
        #(erase_sector_delay+100);




         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h1C);
        tasks.send_data('h02);//set QE=1
        //set CMP=0, SEC=0, TB=0, BP2=1, BP1=1, BP0=1
        tasks.close_comm;
        #100;

        #write_VSR_delay;




        $display("\n ----- Quad Page Program in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h32);
        tasks.send_address(A3);
        for (i=1; i<=8; i=i+1)
              tasks.send_data_quad(i);
        tasks.close_comm;
        #(program_delay+100);



         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h60);
        tasks.send_data('h02);//set QE=1
        //set CMP=0, SEC=1, TB=1, BP2=0, BP1=0, BP0=0
        tasks.close_comm;
        #100;

        #write_VSR_delay;



        $display("\n ----- Quad Page Program in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h32);
        tasks.send_address(A3);
        for (i=1; i<=8; i=i+1)
              tasks.send_data_quad(i);
        tasks.close_comm;
        #(program_delay+100);







         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h00);
        tasks.send_data('h40);
        //set CMP=1, SEC=0, TB=0, BP2=0, BP1=0, BP0=0
        tasks.close_comm;
        #100;

        #write_VSR_delay;




        $display("\n ----- Block Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(A3);
        tasks.close_comm;
        #(erase_block_delay+100);


         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h1C);
        tasks.send_data('h40);
        //set CMP=1, SEC=0, TB=0, BP2=1, BP1=1, BP0=1
        tasks.close_comm;
        #100;

        #write_VSR_delay;



        $display("\n ----- Block Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(A3);
        tasks.close_comm;
        #(erase_block_delay+100);




         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h74);
        tasks.send_data('h40);
        //set CMP=1, SEC=1, TB=1, BP2=1, BP1=0, BP0=1
        tasks.close_comm;
        #100;

        #write_VSR_delay;



        $display("\n ----- Subblock Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h52);
        tasks.send_address(A0);
        tasks.close_comm;
        #(erase_subblock_delay+100);



         $display("\n ----- Volatile Write Status Register in SPI mode.");
        
        tasks.send_command('h50);//Volatile SR Write Enable
        tasks.close_comm;
        #100;
        tasks.send_command('h01);
        tasks.send_data('h6C);
        tasks.send_data('h40);
        //set CMP=1, SEC=1, TB=1, BP2=0, BP1=1, BP0=1
        tasks.close_comm;
        #100;

        #write_VSR_delay;



        $display("\n ----- Subblock Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h52);
        tasks.send_address(A0);
        tasks.close_comm;
        #(erase_subblock_delay+100);




        $display("\n ----- Chip Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h60);
        tasks.close_comm;
        #(erase_chip_delay+100);


/*

        $display("\n ----- Block Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(A0);
        tasks.close_comm;
        #100;


        $display("\n ----- Fast Read in SPI mode.");

        // read from memory file
        tasks.send_command('h0B);
        tasks.send_address(A4);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;


        $display("\n ----- Block Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('hD8);
        tasks.send_address(A4);
        tasks.close_comm;
        #(erase_block_delay+100);


        $display("\n ----- Fast Read in SPI mode.");

        // read from memory file
        tasks.send_command('h0B);
        tasks.send_address(A4);
        tasks.send_dummy_dual(8);
        tasks.read(8);
        tasks.close_comm;
        #100;





        $display("\n ----- Sector Erase in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h20);
        tasks.send_address(A0);
        tasks.close_comm;
        #100;




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


        $display("\n ----- Quad Page Program in SPI mode.");

        tasks.write_enable;
        tasks.send_command('h32);
        tasks.send_address(A0);
        for (i=1; i<=30; i=i+1)
           for (j=1; j<=10; j=j+1)
              tasks.send_data_quad(i);
        tasks.close_comm;
        #(program_delay+100);


         $display("\n ----- Fast Read Quad I/O in SPI mode.");

        // read from memory file
        tasks.send_command('hEB);
        tasks.send_address_quad(A0);
        tasks.send_mbits_quad('hFF);
        tasks.send_dummy_quad(4);
        tasks.read_quad(100);
        tasks.close_comm;
        #100;


        //-----------------------
        //  QPI program & erase
        //-----------------------


         $display("\n ----- Enable QPI.");

        tasks.send_command('h38);
        tasks.close_comm;
        #100;


        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A1);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(8);
        tasks.close_comm;
        #100;


        $display("\n ----- Page Program in QPI mode.");

        tasks.write_enable_quad;
        tasks.send_command_quad('h02);
        tasks.send_address_quad(A1);
        for (i=1; i<=8; i=i+1)
           tasks.send_data_quad(i);
        tasks.close_comm;
        #(program_delay+100);


        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A1);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(8);
        tasks.close_comm;
        #100;


        $display("\n ----- Sector Erase in QPI mode.");

        tasks.write_enable_quad;
        tasks.send_command_quad('h20);
        tasks.send_address_quad(A1);
        tasks.close_comm;
        #100;

        #erase_sector_delay;


        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A1);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(8);
        tasks.close_comm;
        #100;



        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A2);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(2);
        tasks.close_comm;
        #100;


        $display("\n ----- Subblock Erase in QPI mode.");

        tasks.write_enable_quad;
        tasks.send_command_quad('h52);
        tasks.send_address_quad(A1);
        tasks.close_comm;
        #100;

        #erase_sector_delay;



        $display("\n ----- Erase Program Suspend in QPI mode.");
        
        //suspend the subblock erase operation at A1 ad.
        tasks.send_command_quad('h75);
        tasks.close_comm;
        #(SUSlatency+100);


        $display("\n ----- Chip Erase in QPI mode.");

        tasks.write_enable_quad;
        tasks.send_command_quad('hC7);
        tasks.close_comm;
        #100;


        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A3);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(3);
        tasks.close_comm;
        #100;


        $display("\n ----- Page Program in QPI mode.");

        tasks.write_enable_quad;
        tasks.send_command_quad('h02);
        tasks.send_address_quad(A3);
        for (i=1; i<=3; i=i+1)
           tasks.send_data_quad(i);
        tasks.close_comm;
        #(program_delay+100);


        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A3);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(3);
        tasks.close_comm;
        #100;



        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A2);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(3);
        tasks.close_comm;
        #100;


        $display("\n ----- Erase Program Resume in QPI mode.");

        tasks.send_command_quad('h7A);
        tasks.close_comm;
        #100;

        #(erase_subblock_delay - erase_sector_delay);


        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A2);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(2);
        tasks.close_comm;
        #100;



        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A5);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(5);
        tasks.close_comm;
        #100;



        $display("\n ----- Chip Erase in QPI mode.");

        tasks.write_enable_quad;
        tasks.send_command_quad('h60);
        tasks.close_comm;
        #(erase_chip_delay+100);



        $display("\n ----- Fast Read Quad I/O in QPI mode.");

        // read from memory file
        tasks.send_command_quad('hEB);
        tasks.send_address_quad(A5);
        tasks.send_mbits_quad('hFF);
        tasks.read_quad(5);
        tasks.close_comm;
        #100;
*/
     #1000;
    end


endmodule    

