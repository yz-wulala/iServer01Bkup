`include "environment.h" 
// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : Tao Jiang
// CSKYCPU    : 802
// HWCFIG     : CACHE_MBIST
// FUNCTION   : check mbist function
// METHOD     : 
// NOTE       : please modify the run_case file or add this file into tb file 
// ****************************************************************************
module ck802_mbist();

//*******************************************************************************//
//*************** please set the path of each module top signal******************//
//*******************************************************************************//
`define CPU_TOP_PATH                     tb.x_soc.x_cpu_sub_system_ahb.x_ck802

//------------------------------SOC layer signal list----------------------------//
//NOTE:modify the SOC layer signals listed below to ensure the SOC
//layer signal can be identified                  
`define pad_yy_bist_tst_en               `CPU_TOP_PATH.pad_yy_bist_tst_en
`define cache_data_array0_smbist_done    `CPU_TOP_PATH.cache_data_array0_smbist_done 
`define cache_data_array0_smbist_fail    `CPU_TOP_PATH.cache_data_array0_smbist_fail 
`define cache_data_array1_smbist_done    `CPU_TOP_PATH.cache_data_array1_smbist_done 
`define cache_data_array1_smbist_fail    `CPU_TOP_PATH.cache_data_array1_smbist_fail 
`define cache_tag_array0_smbist_done     `CPU_TOP_PATH.cache_tag_array0_smbist_done  
`define cache_tag_array0_smbist_fail     `CPU_TOP_PATH.cache_tag_array0_smbist_fail  

`ifdef  CACHE_2K
`else
`ifdef CACHE_4WAY
`define cache_data_array2_smbist_done    `CPU_TOP_PATH.cache_data_array2_smbist_done 
`define cache_data_array2_smbist_fail    `CPU_TOP_PATH.cache_data_array2_smbist_fail 
`define cache_data_array3_smbist_done    `CPU_TOP_PATH.cache_data_array3_smbist_done 
`define cache_data_array3_smbist_fail    `CPU_TOP_PATH.cache_data_array3_smbist_fail 
`define cache_tag_array1_smbist_done     `CPU_TOP_PATH.cache_tag_array1_smbist_done  
`define cache_tag_array1_smbist_fail     `CPU_TOP_PATH.cache_tag_array1_smbist_fail  
`endif
`endif

`define pad_cpu_rst_b                    `CPU_TOP_PATH.pad_cpu_rst_b
//********************************************************************************//
//                              MAIN TEST PROGRAM                                 //
//********************************************************************************//
//test signal define 
`define CLK                              `CPU_TOP_PATH.forever_cpuclk
//****************************BIU signal test begin  *****************************//
static integer FILE;

initial
begin
  #4000;
  //enable bist test
  force `pad_yy_bist_tst_en = 1'b1;

  #55000;
  force `pad_cpu_rst_b = 1'b0;

  #1700;
  force `pad_cpu_rst_b = 1'b1;


  wait (`cache_data_array0_smbist_done & `cache_data_array1_smbist_done &
        `cache_tag_array0_smbist_done 
 `ifdef CACHE_2K
 `else
 `ifdef CACHE_4WAY
       &`cache_data_array2_smbist_done & `cache_data_array3_smbist_done &
        `cache_tag_array1_smbist_done
 `endif
 `endif
   );
  #100;
  if ( `cache_data_array0_smbist_fail | `cache_data_array1_smbist_fail |
       `cache_tag_array0_smbist_fail
 `ifdef CACHE_2K
 `else
 `ifdef CACHE_4WAY
      &`cache_data_array2_smbist_fail & `cache_data_array3_smbist_fail &
       `cache_tag_array1_smbist_fail
 `endif
 `endif
 )
  begin
    $display("TEST Fail");
    $finish;
  end

  #100;
  $display("#######################################################################");
  $display("#                Congratulations, Simulation PASS!                    #");
  $display("#######################################################################");
  FILE = $fopen("run_case.report","w");
  $fdisplay(FILE,"TEST PASS");
  $finish;

end

initial
begin
  wait (`cache_data_array0_smbist_done);
  if(!`cache_data_array0_smbist_fail)
    $display("data array0 memory bist test pass!");
  else
  begin
    $display("data array0 memory bist test fail!");
    $finish;
  end
end

initial
begin
  wait (`cache_data_array1_smbist_done);
  if(!`cache_data_array1_smbist_fail)
    $display("data array1 memory bist test pass!");
  else
  begin
    $display("data array1 memory bist test fail!");
    $finish;
  end
end

initial
begin
  wait (`cache_tag_array0_smbist_done);
  if(!`cache_tag_array0_smbist_fail)
    $display("tag array0 memory bist test pass!");
  else
  begin
    $display("tag array0 memory bist test fail!");
    $finish;
  end
end

`ifdef CACHE_2K
`else
`ifdef CACHE_4WAY
initial
begin
  wait (`cache_data_array2_smbist_done);
  if(!`cache_data_array2_smbist_fail)
    $display("data array2 memory bist test pass!");
  else
  begin
    $display("data array2 memory bist test fail!");
    $finish;
  end
end

initial
begin
  wait (`cache_data_array3_smbist_done);
  if(!`cache_data_array3_smbist_fail)
    $display("data array3 memory bist test pass!");
  else
  begin
    $display("data array3 memory bist test fail!");
    $finish;
  end
end

initial
begin
  wait (`cache_tag_array1_smbist_done);
  if(!`cache_tag_array1_smbist_fail)
    $display("tag array1 memory bist test pass!");
  else
  begin
    $display("tag array1 memory bist test fail!");
    $finish;
  end
end
`endif
`endif

endmodule
