// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : zhaor
// CSKYCPU    : 801,802 
// HWCFIG     : CSKY_TEE 
// FUNCTION   : unsec int nest
// METHOD     : 
// NOTE       : 
// ****************************************************************************
`define CLK_PERIOD          10
//`define CACHE_8K
//`define CACHE_LINE_16B
//`define CACHE_MBIST
`include "../../../src_rtl/cpu_cfig.h"
module ck802_mem_test_tb();
//data array parameter
`ifdef CACHE_8K
      parameter LOCAL_DATA_ADDR_WIDTH  = 9;
      `ifdef CACHE_LINE_16B
      parameter LOCAL_TAG_ADDR_WIDTH   = 7;
      `endif 
      `ifdef CACHE_LINE_32B
      parameter LOCAL_TAG_ADDR_WIDTH   = 6;
      `endif 
      parameter LOCAL_TAG_DATA_WIDTH   = 48;
`endif
`ifdef CACHE_4K
      parameter LOCAL_DATA_ADDR_WIDTH  = 8;
      `ifdef CACHE_LINE_16B
      parameter LOCAL_TAG_ADDR_WIDTH   = 6;
      `endif 
      `ifdef CACHE_LINE_32B
      parameter LOCAL_TAG_ADDR_WIDTH   = 5;
      `endif 
      parameter LOCAL_TAG_DATA_WIDTH   = 48;
`endif
`ifdef CACHE_2K
      parameter LOCAL_DATA_ADDR_WIDTH  = 7;
      `ifdef CACHE_LINE_16B
      parameter LOCAL_TAG_ADDR_WIDTH   = 5;
      `endif 
      `ifdef CACHE_LINE_32B
      parameter LOCAL_TAG_ADDR_WIDTH   = 4;
      `endif 
      parameter LOCAL_TAG_DATA_WIDTH   = 48;
`endif

//not define cache set random WIDTH of DATA.TAG,DIRTY
`ifndef  CACHE
      parameter LOCAL_DATA_ADDR_WIDTH  = 1;
      parameter LOCAL_TAG_ADDR_WIDTH   = 1;
      parameter LOCAL_TAG_DATA_WIDTH   = 1;

`endif

parameter LOCAL_DATA_DATA_WIDTH = 32;
parameter LOCAL_DATA_WE_WIDTH   = 1;
//tag array parameter
parameter LOCAL_TAG_WE_WIDTH   = 5;

//data array signal
reg [ LOCAL_DATA_ADDR_WIDTH-1 : 0 ] temp_data_addr_internal;
reg [ LOCAL_DATA_DATA_WIDTH-1 : 0 ] temp_data_din_internal ;
reg [ LOCAL_DATA_WE_WIDTH  -1 : 0 ] temp_data_wen_internal ;
reg                                 temp_data_cen_internal ;
reg                                 temp_data_CLK          ;
wire [ LOCAL_DATA_DATA_WIDTH-1 : 0] temp_data_q_internal   ;
reg  [ LOCAL_DATA_DATA_WIDTH-1 : 0] golden_data      ;
reg  [ LOCAL_DATA_DATA_WIDTH-1 : 0] data_mask   ;
reg  [ LOCAL_DATA_DATA_WIDTH-1 : 0] data_mask_ff   ;

//tag array signal
reg [ LOCAL_TAG_ADDR_WIDTH-1 : 0 ] temp_tag_addr_internal;
reg [ LOCAL_TAG_DATA_WIDTH-1 : 0 ] temp_tag_din_internal ;
reg [ LOCAL_TAG_WE_WIDTH  -1 : 0 ] temp_tag_wen_internal ;
reg                                temp_tag_cen_internal ;
reg                                temp_tag_CLK          ;
wire [ LOCAL_TAG_DATA_WIDTH-1 : 0] temp_tag_q_internal   ;
reg  [ LOCAL_TAG_DATA_WIDTH-1 : 0] golden_tag      ;
reg  [ LOCAL_TAG_DATA_WIDTH-1 : 0] tag_mask   ;
reg  [ LOCAL_TAG_DATA_WIDTH-1 : 0] tag_mask_ff   ;

//gated cell clk
reg temp_forever_cpuclk      ;
reg temp_external_en         ;
reg temp_pad_yy_test_mode    ;
wire temp_xor_clk            ;

integer i;

initial 
begin
//gated cell test
           #20
           temp_forever_cpuclk         = 1'b0;
           temp_external_en            = 1'b0;
           temp_pad_yy_test_mode       = 1'b0;
//gated celll type test 
`ifdef GATED_CELL
           //$disapaly("$$$$$$$$$  gated clk type aftre gated,clkout should be 0  test......                                    $");    
           @(posedge temp_forever_cpuclk)
           #0.1
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          Sorry, aftre gated clock out is  %h, gated clk check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          gated clk  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end

            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          gated clk  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
//loacal enable enable test,clkout next cycle valid 
           //$disapaly("$$$$$$$$$  gated clk local en  enable  test......                                    $");    
           @(posedge temp_forever_cpuclk)
           #0.1
           temp_external_en            = 1'b1;
           temp_pad_yy_test_mode       = 1'b0;
           #0.1
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          Sorry, aftre gated clock out is  %h, gated clk check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          gated clk  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b1)
               begin
                   //$disapaly("$          gated loacl en  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end

//loacal en disable test,clkout next cycle invalid
           //$disapaly("$$$$$$$$$  gated clk local en disable   test......                                  $");    
           @(posedge temp_forever_cpuclk)
           #0.1
           temp_external_en            = 1'b0;
           temp_pad_yy_test_mode       = 1'b0;
           #0.1
            if(temp_xor_clk !== 1'b1)
               begin
                   //$disapaly("$          Sorry, loacel en gated disable  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          Sorry, loacel en gated disable  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          Sorry, loacel en gated disable  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
//test en enable test,clkout current cycle vaild
           //$disapaly("$$$$$$$$$  gated clk test en enable   test......                                  $");    
           @(posedge temp_forever_cpuclk)
           #0.1
           temp_external_en            = 1'b0;
           temp_pad_yy_test_mode       = 1'b1;
           #0.1
            if(temp_xor_clk !== 1'b1)
               begin
                   //$disapaly("$          Sorry, test en enable  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          Sorry, test en enable  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b1)
               begin
                   //$disapaly("$          Sorry, test en enable  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end

//test en disable test,clkout cycle cycle  invalid
           //$disapaly("$$$$$$$$$  gated clk test en disable   test......                                  $");    
           @(posedge temp_forever_cpuclk)
           #0.1
           temp_external_en            = 1'b0;
           temp_pad_yy_test_mode       = 1'b0;
           #0.1
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          Sorry, test en disable  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          Sorry, test en disable  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          Sorry, test en disable  check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end

//test en and loacal en both enabke  test,clkout valid current cycle
           //$disapaly("$$$$$$$$$  gated clk test en local en both enable   test......                                  $");    
           @(posedge temp_forever_cpuclk)
           #0.1
           temp_external_en            = 1'b1;
           temp_pad_yy_test_mode       = 1'b1;
           #0.1
            if(temp_xor_clk !== 1'b1)
               begin
                   //$disapaly("$          Sorry, gated enable check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          Sorry, gated enable check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b1)
               begin
                   //$disapaly("$          Sorry, gated enable check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end

//test en and loacal en both disable  test,clkout disable next cycle
           //$disapaly("$$$$$$$$$  gated clk test en local en both disable   test......                                  $");    
           @(posedge temp_forever_cpuclk)
           #0.1
           temp_external_en            = 1'b0;
           temp_pad_yy_test_mode       = 1'b0;
           #0.1
            if(temp_xor_clk !== 1'b1)
               begin
                   //$disapaly("$          Sorry, gated disable check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          Sorry, gated disable check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
            #(`CLK_PERIOD/2)
            if(temp_xor_clk !== 1'b0)
               begin
                   //$disapaly("$          Sorry, gated disable check fail ! @_@     $",temp_xor_clk);    
                   $finish;
               end
           //$disapaly("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
           //$disapaly("$           gated clk test PASS!!!!!!!!!!!!!!!!!!!!                     $");    
           //$disapaly("$           gated clk test PASS!!!!!!!!!!!!!!!!!!!!                     $");    
           //$disapaly("$           gated clk test PASS!!!!!!!!!!!!!!!!!!!!                     $");    
           //$disapaly("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
`endif

`ifdef CACHE
//memory test
           temp_data_CLK               = 1'b0; 
           temp_data_cen_internal      = 1'b0; 
           temp_data_wen_internal      = {LOCAL_DATA_WE_WIDTH{1'b1}};
           temp_data_addr_internal     = {LOCAL_DATA_ADDR_WIDTH{1'b0}};
           temp_data_din_internal      = {LOCAL_DATA_DATA_WIDTH{1'b0}};
           golden_data                 = {LOCAL_DATA_DATA_WIDTH{1'b0}};
           data_mask              = {LOCAL_DATA_DATA_WIDTH{1'b0}};

           #20
           @(posedge temp_data_CLK)

           //cen==1 test
           //$disapaly("$$$$$$$$  data array  memory cen test cen ==1 test...                          $");   
           #0.1 temp_data_wen_internal   = {LOCAL_DATA_WE_WIDTH{1'b0}};
           #0.1 temp_data_cen_internal  = 1'b0; 
           for(i=1;i<10;i=i+1)     //set address 1~9
           begin
           #0.1 temp_data_wen_internal   = {LOCAL_DATA_WE_WIDTH{1'b0}};
           #0.1 temp_data_cen_internal  = 1'b0; 
               @(posedge temp_data_CLK)
                temp_data_addr_internal <= {LOCAL_DATA_ADDR_WIDTH{1'b0}} + i;
                temp_data_din_internal  <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + i;
                golden_data             <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + i;
               @(posedge temp_data_CLK)
               #0.1 temp_data_wen_internal  <= {LOCAL_DATA_WE_WIDTH{1'b1}};
                    golden_data             <= temp_data_din_internal ;
               @(posedge temp_data_CLK)
               #0.1   
                   //$disapaly("$address = %h temp_data_q_internal = %h , golden_data =%h \n",temp_data_addr_internal,temp_data_q_internal,golden_data);    
               if(temp_data_q_internal !== golden_data)
               begin
                   //$disapaly("$          Sorry, address %h memory write check fail ! @_@     $",temp_data_addr_internal);    
                   $finish;
               end
           end


           //cen==0 test
           //$disapaly("$$$$$$$$$$  data array  memory cen test cen ==1  test passed                     $\n");   
           //$disapaly("$$$$$$$$$$  data array  memory cen test  cen ==0 test...                         $");    
           #0.1 temp_data_wen_internal   = {LOCAL_DATA_WE_WIDTH{1'b0}};
           #0.1 temp_data_cen_internal  = 1'b1; 

           for(i=10;i<15;i=i+1)     //set address 10 ~15
           begin
               @(posedge temp_data_CLK)
                temp_data_addr_internal <= {LOCAL_DATA_ADDR_WIDTH{1'b0}} + i;
                temp_data_din_internal  <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + i;
                golden_data             <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + i;
               @(posedge temp_data_CLK)
               #0.1   
                   //$disapaly("$          address = %h temp_data_q_internal = %h , golden_data =%h \n",temp_data_addr_internal,temp_data_q_internal,golden_data);    
               if(temp_data_q_internal === golden_data)
               begin
                   //$disapaly("$          Sorry, address %h memory write check fail ! @_@     $",temp_data_addr_internal);    
                   $finish;
               end
           end



           //wen test
           //$disapaly("$$$$$$$$$  data array  memory cen test  cen ==0 test passed                      $");    
           //$disapaly("$$$$$$$$$  data array  memory wen test.......                                    $");    
           #0.1 temp_data_wen_internal   = {LOCAL_DATA_WE_WIDTH{1'b0}};
           #0.1 temp_data_cen_internal   = 1'b0; 
          for(i=0;i<LOCAL_DATA_WE_WIDTH + 1;i=i+1)
          begin
                 @(posedge temp_data_CLK)
                  temp_data_addr_internal <= {LOCAL_DATA_ADDR_WIDTH{1'b0}} ;
                  temp_data_wen_internal  <= {LOCAL_DATA_WE_WIDTH{1'b1}} >>i ; 
                  temp_data_din_internal  <= {LOCAL_DATA_DATA_WIDTH{1'b1}} ;
                  golden_data             <= temp_data_din_internal ;
                 @(posedge temp_data_CLK)
                 @(posedge temp_data_CLK)
                 #0.1 temp_data_wen_internal  <= {LOCAL_DATA_WE_WIDTH{1'b1}};
                      golden_data             <= temp_data_din_internal ;
                      data_mask_ff            <= data_mask;
                 @(posedge temp_data_CLK)
                  #0.1 
                      //$disapaly("$  address = %h temp_data_q_internal = %h , golden_data =%h,wen=%h \n",temp_data_addr_internal,temp_data_q_internal,(golden_data &(~data_mask)),temp_data_wen_internal);    
                 if(temp_data_q_internal !== (golden_data &(~data_mask_ff)) )
                 begin
                      //$disapaly("$  temp_data_q_internal = %h , golden_data =%h, wen=%h \n",temp_data_q_internal,golden_data,temp_data_wen_internal);    
                      $finish;
                 end
           end
            
                      

          //write test
           //$disapaly("$$$$$$$$$  data array  memory wen test passed                                    $");    
           //$disapaly("$$$$$$$$$  data array  memory write test......                                    $");    
           @(posedge temp_data_CLK) //write address 0
           #0.1 temp_data_wen_internal   = {LOCAL_DATA_WE_WIDTH{1'b0}};
           #0.1 temp_data_cen_internal   = 1'b0; 
           for(i=10;i<15;i = i+1)     //set address 10 ~15
           begin
           #0.1 temp_data_wen_internal   = {LOCAL_DATA_WE_WIDTH{1'b0}};
           #0.1 temp_data_cen_internal   = 1'b0; 
               @(posedge temp_data_CLK)
                temp_data_addr_internal <= {LOCAL_DATA_ADDR_WIDTH{1'b0}} + i;
                temp_data_din_internal  <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + i;
                golden_data             <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + i;
               @(posedge temp_data_CLK)
               #0.1 temp_data_wen_internal  <= {LOCAL_DATA_WE_WIDTH{1'b1}};
                    golden_data             <= temp_data_din_internal ;
               @(posedge temp_data_CLK)
               #0.1   
                   //$disapaly("$          address = %h temp_data_q_internal = %h , golden_data =%h \n",temp_data_addr_internal,temp_data_q_internal,golden_data);    
               if(temp_data_q_internal !== golden_data)
               begin
                   //$disapaly("$          Sorry, address %h memory write check fail ! @_@     $",temp_data_addr_internal);    
                   $finish;
               end
           end


          //address width check
           //$disapaly("$$$$$$$$  data array  memory read test passed                                    $");    
           //$disapaly("$$$$$$$$  data array  memory address width test......                            $");    
          @(posedge temp_data_CLK) //write address 
           #0.1 temp_data_cen_internal   = 1'b0; 
           @(posedge temp_data_CLK)
           temp_data_wen_internal  <= {LOCAL_DATA_WE_WIDTH{1'b0}};
           temp_data_addr_internal <= {LOCAL_DATA_ADDR_WIDTH{1'b0}} ;                // 0 address write bb
           temp_data_din_internal  <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + 8'hbb;
           golden_data             <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + 8'hbb;
           @(posedge temp_data_CLK)
           temp_data_wen_internal  <= {LOCAL_DATA_WE_WIDTH{1'b0}};
           temp_data_addr_internal <= { {1{1'b1}},{LOCAL_DATA_ADDR_WIDTH-1{1'b0}} } ; // 1/2 max address 
           temp_data_din_internal  <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + 8'haa;
           golden_data             <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + 8'haa;

           //read data in 1/2max address
           @(posedge temp_data_CLK)
           temp_data_wen_internal  <= {LOCAL_DATA_WE_WIDTH{1'b1}};
           temp_data_addr_internal <= { {1{1'b1}},{LOCAL_DATA_ADDR_WIDTH-1{1'b0}} } ; // 1/2 max address
           temp_data_din_internal  <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + 8'hff;
           golden_data             <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + 8'haa;
           @(posedge temp_data_CLK)
           #0.1   
           if(temp_data_q_internal !== golden_data)
           begin
               //$disapaly("$          Sorry, address %h memory read check fail ! @_@     $",temp_data_addr_internal);    
               $finish;
           end

           //read data in  address 0
           @(posedge temp_data_CLK)
           temp_data_wen_internal  <= {LOCAL_DATA_WE_WIDTH{1'b1}};
           temp_data_addr_internal <= {LOCAL_DATA_ADDR_WIDTH{1'b0}} ;                // 0 address write bb
           temp_data_din_internal  <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + 8'hff;
           golden_data             <= {LOCAL_DATA_DATA_WIDTH{1'b0}} + 8'hbb;
           @(posedge temp_data_CLK)
           #0.1   
           if(temp_data_q_internal !== golden_data)
           begin
               //$disapaly("$          Sorry, address %h memory read check fail ! @_@     $",temp_data_addr_internal);    
               $finish;
           end


           //$disapaly("$$$$$$$$  data array  memory address width test passed                                    $");    
           //$disapaly("$$$$$$$$  data array  memory data width test......                                    $");    
          //read data check
     
           @(posedge temp_data_CLK) //write address 
           #0.1 temp_data_cen_internal   = 1'b0; 
           @(posedge temp_data_CLK)
           temp_data_wen_internal  <= {LOCAL_DATA_WE_WIDTH{1'b0}};
           temp_data_addr_internal <= {LOCAL_DATA_ADDR_WIDTH{1'b1}} ;
           temp_data_din_internal  <= {LOCAL_DATA_DATA_WIDTH{1'b1}} ;
           golden_data             <= {LOCAL_DATA_DATA_WIDTH{1'b1}} ;
           @(posedge temp_data_CLK)
           #0.1 temp_data_wen_internal  <= {LOCAL_DATA_WE_WIDTH{1'b1}};
                golden_data             <= temp_data_din_internal ;
           @(posedge temp_data_CLK)
           #0.1   
               //$disapaly("$          address = %h temp_data_q_internal = %h , golden_data =%h \n",temp_data_addr_internal,temp_data_q_internal,golden_data);    
           if(temp_data_q_internal !== golden_data)
           begin
               //$disapaly("$          Sorry, address %h memory read check fail ! @_@     $",temp_data_addr_internal);    
               $finish;
           end
           //$disapaly("$$$$$$$$  data array  memory data width test passed                          $");    
          //read data check
           //$disapaly("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
           //$disapaly("$           data array test PASS!!!!!!!!!!!!!!!!!!!!                     $");    
           //$disapaly("$           data array test PASS!!!!!!!!!!!!!!!!!!!!                     $");    
           //$disapaly("$           data array test PASS!!!!!!!!!!!!!!!!!!!!                     $");    
           //$disapaly("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");


           temp_tag_CLK               = 1'b0; 
           temp_tag_cen_internal      = 1'b0; 
           temp_tag_wen_internal      = {LOCAL_TAG_WE_WIDTH{1'b1}};
           temp_tag_addr_internal     = {LOCAL_TAG_ADDR_WIDTH{1'b0}};
           temp_tag_din_internal      = {LOCAL_TAG_DATA_WIDTH{1'b0}};
           golden_tag                 = {LOCAL_TAG_DATA_WIDTH{1'b0}};
           tag_mask                   = {LOCAL_TAG_DATA_WIDTH{1'b0}};

           #20
           @(posedge temp_tag_CLK)

           //cen==1 test
           //$disapaly("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
           //$disapaly("$$$$$$$  tag array   memory cen test cen ==1 test...                          $");   
           //$disapaly("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
           #0.1 temp_tag_wen_internal   = {LOCAL_TAG_WE_WIDTH{1'b0}};
           #0.1 temp_tag_cen_internal  = 1'b0; 
           for(i=1;i<10;i=i+1)     //set address 1~9
           begin
               @(posedge temp_tag_CLK)
                temp_tag_wen_internal  <= {LOCAL_TAG_WE_WIDTH{1'b0}};
                temp_tag_addr_internal <= {LOCAL_TAG_ADDR_WIDTH{1'b0}} + i;
                temp_tag_din_internal  <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + i;
                golden_tag             <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + i;
               @(posedge temp_tag_CLK)
               #0.1 temp_tag_wen_internal  <= {LOCAL_TAG_WE_WIDTH{1'b1}};
                    golden_tag             <= temp_tag_din_internal ;
               @(posedge temp_tag_CLK)
               #0.1   
                   //$disapaly("$address = %h temp_tag_q_internal = %h , golden_tag =%h \n",temp_tag_addr_internal,temp_tag_q_internal,golden_tag);    
               if(temp_tag_q_internal !== golden_tag)
               begin
                   //$disapaly("$          Sorry, address %h memory write check fail ! @_@     $",temp_tag_addr_internal);    
                   $finish;
               end
           end


           //cen==0 test
           //$disapaly("$$$$$$$$  tag array   memory cen test cen ==1  test passed                     $");   
           //$disapaly("$$$$$$$$  tag array   memory cen test  cen ==0 test...                         $");    
           #0.1 temp_tag_wen_internal   = {LOCAL_TAG_WE_WIDTH{1'b0}};
           #0.1 temp_tag_cen_internal  = 1'b1; 

           for(i=10;i<15;i=i+1)     //set address 10 ~15
           begin
               @(posedge temp_tag_CLK)
                temp_tag_addr_internal <= {LOCAL_TAG_ADDR_WIDTH{1'b0}} + i;
                temp_tag_din_internal  <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + i;
                golden_tag             <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + i;
               @(posedge temp_tag_CLK)
               #0.1   
                   //$disapaly("$          address = %h temp_tag_q_internal = %h , golden_tag =%h \n",temp_tag_addr_internal,temp_tag_q_internal,golden_tag);    
               if(temp_tag_q_internal === golden_tag)
               begin
                   //$disapaly("$          Sorry, address %h memory write check fail ! @_@     $",temp_tag_addr_internal);    
                   $finish;
               end
           end



           //wen test
           //$disapaly("$$$$$$$  tag array   memory cen test  cen ==0 test passed                      $");    
           //$disapaly("$$$$$$$  tag array   memory wen test.......                                    $");    
           #0.1 temp_tag_addr_internal <= {LOCAL_TAG_ADDR_WIDTH{1'b0}} ;
           #0.1 temp_tag_din_internal  <= {LOCAL_TAG_DATA_WIDTH{1'b0}} ;
           #0.1 temp_tag_wen_internal   = {LOCAL_TAG_WE_WIDTH{1'b0}};
           #0.1 temp_tag_cen_internal   = 1'b0; 
          for(i=0;i<LOCAL_TAG_WE_WIDTH + 1;i=i+1)
          begin
                 @(posedge temp_tag_CLK)
                  temp_tag_addr_internal <= {LOCAL_TAG_ADDR_WIDTH{1'b0}} ;
                  temp_tag_wen_internal  <= {LOCAL_TAG_WE_WIDTH{1'b1}} >>i ; 
                  temp_tag_din_internal  <= {LOCAL_TAG_DATA_WIDTH{1'b1}} ;
                 // golden_tag             <= temp_tag_din_internal ;
                 @(posedge temp_tag_CLK)
                 @(posedge temp_tag_CLK)
                 #0.1 temp_tag_wen_internal  <= {LOCAL_TAG_WE_WIDTH{1'b1}};
                      golden_tag             <= temp_tag_din_internal;
                      tag_mask_ff            <= tag_mask;
                @(posedge temp_tag_CLK)
                  #0.1 
                      //$disapaly("$  address = %h temp_tag_q_internal = %h , golden_tag =%h,wen=%h \n",temp_tag_addr_internal,temp_tag_q_internal,(golden_tag &(~tag_mask)),temp_tag_wen_internal);    
                 if(temp_tag_q_internal !== (golden_tag &(~tag_mask_ff)) )
                 begin
                     // $display("$  temp_tag_q_internal = %h , golden_tag =%h, wen=%h \n",temp_tag_q_internal,golden_tag,temp_tag_wen_internal);    
                      $finish;
                 end
           end
            
                      

          //write test
           //$disapaly("$$$$$$$$$  tag array   memory wen test passed                                    $");    
           //$disapaly("$$$$$$$$$  tag array   memory write test......                                    $");    
           @(posedge temp_tag_CLK) //write address 0
           #0.1 temp_tag_wen_internal   = {LOCAL_TAG_WE_WIDTH{1'b0}};
           #0.1 temp_tag_cen_internal   = 1'b0; 
           for(i=10;i<15;i = i+1)     //set address 10 ~15
           begin
           #0.1 temp_tag_wen_internal   = {LOCAL_TAG_WE_WIDTH{1'b0}};
           #0.1 temp_tag_cen_internal   = 1'b0; 
               @(posedge temp_tag_CLK)
                temp_tag_addr_internal <= {LOCAL_TAG_ADDR_WIDTH{1'b0}} + i;
                temp_tag_din_internal  <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + i;
                golden_tag             <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + i;
               @(posedge temp_tag_CLK)
               #0.1 temp_tag_wen_internal  <= {LOCAL_TAG_WE_WIDTH{1'b1}};
                    golden_tag             <= temp_tag_din_internal;
               @(posedge temp_tag_CLK)
               #0.1   
                   //$disapaly("$          address = %h temp_tag_q_internal = %h , golden_tag =%h \n",temp_tag_addr_internal,temp_tag_q_internal,golden_tag);    
               if(temp_tag_q_internal !== golden_tag)
               begin
                   //$disapaly("$          Sorry, address %h memory write check fail ! @_@     $",temp_tag_addr_internal);    
                   $finish;
               end
           end


          //address width check
           //$disapaly("$$$$$$$$  tag array   memory read test passed                                    $");   
 
           //$disapaly("$$$$$$$$  tag array   memory address width test......                            $");    
            @(posedge temp_tag_CLK) //write address 
           #0.1 temp_tag_cen_internal   = 1'b0; 
           //write address 0 
           @(posedge temp_tag_CLK)
           temp_tag_wen_internal  <= {LOCAL_TAG_WE_WIDTH{1'b0}};
           temp_tag_addr_internal <= {LOCAL_TAG_ADDR_WIDTH{1'b0}} ;
           temp_tag_din_internal  <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + 8'hbb;
           golden_tag             <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + 8'hbb;
           //write address 1/2 max address
           @(posedge temp_tag_CLK)
           temp_tag_wen_internal  <= {LOCAL_TAG_WE_WIDTH{1'b0}};
           temp_tag_addr_internal <= {{1'b1}, {LOCAL_TAG_ADDR_WIDTH-1{1'b0}} } ;
           temp_tag_din_internal  <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + 8'haa;
           golden_tag             <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + 8'haa;

           //read address 1/2 max address
           @(posedge temp_tag_CLK)
           temp_tag_wen_internal  <= {LOCAL_TAG_WE_WIDTH{1'b1}};
           temp_tag_addr_internal <= {{1'b1}, {LOCAL_TAG_ADDR_WIDTH-1{1'b0}} } ;
           temp_tag_din_internal  <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + 8'hff;
           golden_tag             <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + 8'haa;
           @(posedge temp_tag_CLK)
           #0.1   
           if(temp_tag_q_internal !== golden_tag)
           begin
               //$disapaly("$          Sorry, address %h memory read check fail ! @_@     $",temp_tag_addr_internal);    
               $finish;
           end

           //read address 0
           @(posedge temp_tag_CLK)
           temp_tag_wen_internal  <= {LOCAL_TAG_WE_WIDTH{1'b1}};
           temp_tag_addr_internal <= {LOCAL_TAG_ADDR_WIDTH{1'b0}}  ;
           temp_tag_din_internal  <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + 8'hff;
           golden_tag             <= {LOCAL_TAG_DATA_WIDTH{1'b0}} + 8'hbb;
           @(posedge temp_tag_CLK)
           #0.1   
           if(temp_tag_q_internal !== golden_tag)
           begin
               //$disapaly("$          Sorry, address %h memory read check fail ! @_@     $",temp_tag_addr_internal);    
               $finish;
           end



           //$disapaly("$$$$$$$  tag array   memory address width test passed                                $");    
           //$disapaly("$$$$$$$  tag array   memory data width test......                                    $");    
          //read data check
     
           @(posedge temp_tag_CLK) //write address 
           #0.1 temp_tag_cen_internal   = 1'b0; 
           @(posedge temp_tag_CLK)
           temp_tag_wen_internal  <= {LOCAL_TAG_WE_WIDTH{1'b0}};
           temp_tag_addr_internal <= {LOCAL_TAG_ADDR_WIDTH{1'b1}} ;
           temp_tag_din_internal  <= {LOCAL_TAG_DATA_WIDTH{1'b1}} ;
           golden_tag             <= {LOCAL_TAG_DATA_WIDTH{1'b1}} ;
           @(posedge temp_tag_CLK)
           #0.1 temp_tag_wen_internal  <= {LOCAL_TAG_WE_WIDTH{1'b1}};
                golden_tag             <= temp_tag_din_internal;
           @(posedge temp_tag_CLK)
           #0.1   
               //$disapaly("$          address = %h temp_tag_q_internal = %h , golden_tag =%h \n",temp_tag_addr_internal,temp_tag_q_internal,golden_tag);    
           if(temp_tag_q_internal !== golden_tag)
           begin
               //$disapaly("$          Sorry, address %h memory read check fail ! @_@     $",temp_tag_addr_internal);    
               $finish;
           end
           //$disapaly("$$$$$$$  tag array   memory data width test passed                          $");    
          //read data check
           //$disapaly("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
           //$disapaly("$           tag array test passed!!!!!!!!!!!!!!!!!!!!                    $");    
           //$disapaly("$           tag array test passed!!!!!!!!!!!!!!!!!!!!                    $");    
           //$disapaly("$           tag array test passed!!!!!!!!!!!!!!!!!!!!                    $");    
           //$disapaly("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");



           `ifdef CACHE_8K
           //$disapaly("$$$$$$$$  icache 8k  Congratuations PASS!!!!!!!!!                $");   
            `endif 
           `ifdef CACHE_4K
           //$disapaly("$$$$$$$$  icache 4k  Congratuations PASS!!!!!!!!!                $");   
            `endif 
           `ifdef CACHE_2K
           //$disapaly("$$$$$$$$  icache 2k  Congratuations PASS!!!!!!!!!                $");   
            `endif 
           `ifdef CACHE_1K
           //$disapaly("$$$$$$$$  icache 1k  Congratuations PASS!!!!!!!!!                $");   
            `endif 
`endif



`ifndef GATED_CELL
           $display("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
           $display("$$$$$$$$  RTL not define GATED_CELL               $");   
           $display("$$$$$$$$  jump over gate cell test                $");   
           $display("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
`endif

`ifndef CACHE
           $display("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
           $display("$$$$$$$$  RTL not define CACHE                   $");   
           $display("$$$$$$$$  jump over cache test                   $");   
           $display("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
`endif
`ifdef GATED_CELL
           $display("$$$$$$$$  gate cell test pass              $$$$$$");   
`endif

`ifdef CACHE
           $display("$$$$$$$$  cache test pass                  $$$$$$");   
`endif

           $finish;
           $finish;



end

//Dumping Control
initial
begin
  //$display("######time:%d, Dump start######",$time);
  //$fsdbDumpfile("vg_dump.fsdb");
  //$fsdbDumpon;
  //$fsdbDumpvars();
  $dumpfile("test.vcd");
  $dumpvars;
end


always 
#(`CLK_PERIOD/2)  temp_data_CLK = ~temp_data_CLK;
always 
#(`CLK_PERIOD/2)  temp_tag_CLK = ~temp_tag_CLK;
always 
#(`CLK_PERIOD/2)  temp_forever_cpuclk = ~temp_forever_cpuclk;

always @(posedge temp_data_CLK)
begin
//data array mask
 data_mask <= {32{temp_data_wen_internal[0]}};
end 


//tag array mask
always @(posedge temp_tag_CLK)
begin

`ifdef CACHE_8K
tag_mask <={{temp_tag_wen_internal[4:3], {2{temp_tag_wen_internal[2]}}, {23{temp_tag_wen_internal[1]}}, {23{temp_tag_wen_internal[0]}}}};
`endif
`ifdef CACHE_4K
tag_mask <={{temp_tag_wen_internal[4:3], {2{temp_tag_wen_internal[2]}}, {23{temp_tag_wen_internal[1]}}, {23{temp_tag_wen_internal[0]}}}};
`endif
`ifdef CACHE_2K
tag_mask <={{temp_tag_wen_internal[4:3], {2{temp_tag_wen_internal[2]}}, {23{temp_tag_wen_internal[1]}}, {23{temp_tag_wen_internal[0]}}}};
`endif
end 

`ifdef CACHE
nm_cache_data_smbist_wrap  x_nm_cache_data_array1 (
`ifdef CACHE_MBIST
  .b_done                        ( ),
  .b_fail                        ( ),
  .b_rst_n                       (1'b0 ),
  .b_te                          (1'b0 ),
  .bist_clk                      (1'b0 ),
`endif
  .s_mode                        (1'b0 ),
  .A                             (temp_data_addr_internal      ),
  .CEN                           (temp_data_cen_internal       ),
  .CLK                           (temp_data_CLK                ),
  .D                             (temp_data_din_internal       ),
  .Q                             (temp_data_q_internal         ),
  .WEN                           (temp_data_wen_internal       )
);                                                                


nm_cache_tag_smbist_wrap  x_nm_cache_tag_array0 (
`ifdef CACHE_MBIST
  .b_done                       (),
  .b_fail                       (),
  .b_rst_n                      (1'b1),
  .b_te                         (1'b0),
  .bist_clk                     (1'b0),
  .cpurst_b                     (1'b1),
  .tst_clk                      (1'b0),
`endif
  .s_mode                       (1'b0),
  .A                            (temp_tag_addr_internal      ),
  .CEN                          (temp_tag_cen_internal       ),
  .CLK                          (temp_tag_CLK                ),
  .D                            (temp_tag_din_internal       ),
  .Q                            (temp_tag_q_internal         ),
  .WEN                          (temp_tag_wen_internal       )
);
`endif   //not define CACHE

`ifdef GATED_CELL
gated_clk_cell  x_gated_clk_cell_xor (
  .clk_in                   (temp_forever_cpuclk      ),
  .clk_out                  (temp_xor_clk             ),
  .external_en              (temp_external_en         ),
  .global_en                (1'b0                     ),
  .local_en                 (1'b0                     ),
  .module_en                (1'b0                     ),
  //.pad_yy_bist_tst_en       (1'b0                   ),
  .pad_yy_gate_clk_en_b     (1'b0                     ),
  .pad_yy_test_mode         (temp_pad_yy_test_mode    )
);
`endif

endmodule
