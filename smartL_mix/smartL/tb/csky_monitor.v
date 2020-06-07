// *****************************************************************************
// *                                                                           *
// * C-Sky Microsystems Confidential                                           *
// * -------------------------------                                           *
// * This file and all its contents are properties of C-Sky Microsystems. The  *
// * information contained herein is confidential and proprietary and is not   *
// * to be disclosed outside of C-Sky Microsystems except under a              *
// * Non-Disclosure Agreement (NDA).                                           *
// *                                                                           *
// *****************************************************************************
// FILE NAME       : csky_monitor.v
// AUTHOR          : ManZhou Wang
// ORIGINAL TIME   : 05-26-2017
// FUNCTION        : CTS Monitor
// RESET           : system rst
// DFT             : 
// DFP             :
// VERIFICATION    :
// RELEASE HISTORY :
// $Id: csky_monitor.v,v 1.6 2017/07/19 03:27:01 wangmz Exp $
// *****************************************************************************

`define SOC_IMEM_INS tb.x_soc.x_cpu_sub_system_ahb.x_iahb_mem_ctrl
`define SOC_DMEM_INS tb.x_soc.x_cpu_sub_system_ahb.x_dahb_mem_ctrl

`define CPU_TOP       tb.x_soc.x_cpu_sub_system_ahb.x_ck803s
`define CPU_CLK      `CPU_TOP.pll_core_cpuclk
`define CPU_RST      `CPU_TOP.pad_cpu_rst_b

`define VIRTUAL_READ `CPU_TOP.x_vg_tcip_top.x_nm_tcipif_dbus.dummy_addr_cmplt
`define VIRTUAL_TIME `CPU_TOP.x_vg_tcip_top.x_nm_tcipif_dbus.tcipif_dbus_rd_data[31:0]

`define MAX_RUN_TIME        700000000

module csky_monitor();


///////////////////////////////////////
// Memory Initialization  
///////////////////////////////////////
integer i;
reg [31:0] mem_inst_temp [integer];
reg [31:0] mem_data_temp [integer];
initial
begin
  $display("\t******START TO LOAD PROGRAM******\n");
  $readmemh("inst.pat", mem_inst_temp);
  $readmemh("data.pat", mem_data_temp);
  for(i=0;i<mem_inst_temp.size;i=i+1)
  begin
    `SOC_IMEM_INS.ram0.U1.mem[i][7:0] = mem_inst_temp[i][31:24];
    `SOC_IMEM_INS.ram1.U1.mem[i][7:0] = mem_inst_temp[i][23:16];
    `SOC_IMEM_INS.ram2.U1.mem[i][7:0] = mem_inst_temp[i][15: 8];
    `SOC_IMEM_INS.ram3.U1.mem[i][7:0] = mem_inst_temp[i][ 7: 0];
  end

  for(i=mem_inst_temp.size;i<32768;i=i+1)
  begin
    `SOC_IMEM_INS.ram0.U1.mem[i][7:0] = 8'b0;
    `SOC_IMEM_INS.ram1.U1.mem[i][7:0] = 8'b0;
    `SOC_IMEM_INS.ram2.U1.mem[i][7:0] = 8'b0;
    `SOC_IMEM_INS.ram3.U1.mem[i][7:0] = 8'b0;
  end


 for(i=0;i<mem_data_temp.size;i=i+1)
  begin
    `SOC_DMEM_INS.ram0.U1.mem[i][7:0]  = mem_data_temp[i][31:24];
    `SOC_DMEM_INS.ram1.U1.mem[i][7:0]  = mem_data_temp[i][23:16];
    `SOC_DMEM_INS.ram2.U1.mem[i][7:0]  = mem_data_temp[i][15: 8];
    `SOC_DMEM_INS.ram3.U1.mem[i][7:0]  = mem_data_temp[i][ 7: 0];
  end

  for(i=mem_data_temp.size;i<16384;i=i+1)
  begin
    `SOC_DMEM_INS.ram0.U1.mem[i][7:0]  = 8'b0;
    `SOC_DMEM_INS.ram1.U1.mem[i][7:0]  = 8'b0;
    `SOC_DMEM_INS.ram2.U1.mem[i][7:0]  = 8'b0;
    `SOC_DMEM_INS.ram3.U1.mem[i][7:0]  = 8'b0;
  end

end

///////////////////////////////////////
// Finish Condition Control 
///////////////////////////////////////

// Reaching the max simulation time.
initial
begin
#`MAX_RUN_TIME;
  $display("**********************************************");
  $display("*   meeting max simulation time, stop!       *");
  $display("**********************************************");
$finish;
end
// No instrunction retired in the last `LAST_CYCLE cycles
reg [31:0] retire_inst_in_period;
reg [31:0] cycle_count;
`define LAST_CYCLE 5000
always @(posedge `clk or negedge `rst_b)
begin
  if(!`rst_b)
    cycle_count[31:0] <= 32'b1;
  else 
    cycle_count[31:0] <= cycle_count[31:0] + 1'b1;
end


always @(posedge `clk or negedge `rst_b)
begin
  if(!`rst_b) //reset to zero
    retire_inst_in_period[31:0] <= 32'b0;
  else if( (cycle_count[31:0] % `LAST_CYCLE) == 0)//check and reset retire_inst_in_period every 50000 cycles
  begin
    if(retire_inst_in_period[31:0] == 0)begin
      $display("*************************************************************");
      $display("* Error: There is no instructions retired in the last %d cycles! *", `LAST_CYCLE);
      $display("*              Simulation Fail and Finished!                *");
      $display("*************************************************************");
      #10;
      $finish;
    end
    retire_inst_in_period[31:0] <= 32'b0;
  end
  else if(`CPU_TOP.rtu_pad_inst_retire)
    retire_inst_in_period[31:0] <= retire_inst_in_period[31:0] + 1'b1;
end


//Finish control with address 32'h0 
reg [31:0] cpu_addr;
reg [1:0]  cpu_trans;
reg        cpu_write;
wire [31:0] cpu_wdata;
always @(posedge `clk)
begin
  cpu_trans[1:0] <= `CPU_TOP.biu_pad_htrans[1:0];
  cpu_addr[31:0] <= `CPU_TOP.biu_pad_haddr[31:0];
  cpu_write      <= `CPU_TOP.biu_pad_hwrite;
end
assign cpu_wdata[31:0] = `CPU_TOP.biu_pad_hwdata[31:0];
always @(posedge `clk)
begin
  if((cpu_trans[1:0] == 2'b10) &&
     (cpu_addr[31:0] == PRINT_ADDR) &&
      cpu_write                &&
     (cpu_wdata[31:0] == 12'hfff || cpu_wdata[31:0] == 32'hffff0000))
  begin
   $display("**********************************************");
   $display("*    simulation finished successfully        *");
   $display("**********************************************");
  #10;
   $finish;
  end
  else if((cpu_trans[1:0] == 2'b10) &&
     (cpu_addr[31:0] == PRINT_ADDR) &&
      cpu_write                &&
     (cpu_wdata[31:0] == 12'heee || cpu_wdata[31:0] == 32'heeee0000))
  begin
   $display("**********************************************");
   $display("*    simulation finished with error          *");
   $display("**********************************************");
  #10;
   $finish;
  end
  else if((cpu_trans[1:0] == 2'b10) &&
     (cpu_addr[31:0] == PRINT_ADDR) &&
      cpu_write)
  begin
//   $write("begin to display:");
   $write("%c", cpu_wdata[7:0]);
  end

end


//virtual couter set for cpu performance

reg [31:0] virtual_counter;

always @(posedge `CPU_CLK or negedge `CPU_RST)
begin
  if(!`CPU_RST)
    virtual_counter[31:0] <= 32'b0;
  else if(virtual_counter[31:0]==32'hffffffff)
    virtual_counter[31:0] <= virtual_counter[31:0];
  else
    virtual_counter[31:0] <= virtual_counter[31:0] +1'b1;
end 

initial 
begin 
  #1;
  wait (`VIRTUAL_READ==1'b1);
  force `VIRTUAL_TIME = virtual_counter[31:0];
  @(posedge `CPU_CLK);
  release `VIRTUAL_TIME;
  #1;
  
  wait (`VIRTUAL_READ==1'b1);
  force `VIRTUAL_TIME = virtual_counter[31:0];
  @(posedge `CPU_CLK);
  release `VIRTUAL_TIME;
  #1;

  wait (`VIRTUAL_READ==1'b1);
  force `VIRTUAL_TIME = virtual_counter[31:0];
  @(posedge `CPU_CLK);
  release `VIRTUAL_TIME;
  #1;

  wait (`VIRTUAL_READ==1'b1);
  force `VIRTUAL_TIME = virtual_counter[31:0];
  @(posedge `CPU_CLK);
  release `VIRTUAL_TIME;

  #1;
  wait (`VIRTUAL_READ==1'b1);
  force `VIRTUAL_TIME = virtual_counter[31:0];
  @(posedge `CPU_CLK);
  release `VIRTUAL_TIME;

  #1;
  wait (`VIRTUAL_READ==1'b1);
  force `VIRTUAL_TIME = virtual_counter[31:0];
  @(posedge `CPU_CLK);
  release `VIRTUAL_TIME;
  #1;
end



endmodule
