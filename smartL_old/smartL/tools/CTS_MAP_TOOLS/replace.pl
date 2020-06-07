#! /usr/bin/perl -w
# ****************************************************************************
# *                                                                          *
# * C-Sky Microsystems Confidential                                          *
# * -------------------------------                                          *
# * This file and all its contents are properties of C-Sky Microsystems. The *
# * information contained herein is confidential and proprietary and is not  *
# * to be disclosed outside of C-Sky Microsystems except under a             *
# * Non-Disclosure Agreement (NDA).                                          *
# *                                                                          *
# ****************************************************************************
#// *****************************************************************************
#// FILE NAME       : replace
#// AUTHOR          : ManZhou Wang
#// ORIGINAL TIME   : 05-26-2017
#// FUNCTION        : replace script , repace environment parameters  
#// VERIFICATION    :
#// RELEASE HISTORY :
#// $Id: replace.pl,v 1.8 2017/07/19 03:33:32 wangmz Exp $ 
#// *****************************************************************************



use strict;

#####################################################
# Get CTS Configure
####################################################
open FILE,"./cts_map_cfig.h" or die "can't open cts_map_cfig";
my @text=<FILE>;
my $IMEM_ADDR;
my $IMEM_SIZE;
my $DMEM_ADDR;
my $DMEM_SIZE;
my $MEM_LIB_PATH;

my $TSSP;
my $TUSP;
my $SSP;
my $USP;
my $SOC_IMEM_INS;
my $SOC_DMEM_INS;
my $TOOL_EXTENSION;
my $PRINT_ADDR;
my $CPU_TOP;

foreach my $line (@text) {
  if ($line =~/^\s*`define\s+IMEM_ADDR\s+(.*)\s*/){ 
    $IMEM_ADDR = $1;
  }elsif ($line =~/^\s*`define\s+IMEM_SIZE\s+(.*)\s*/){ 
    $IMEM_SIZE = $1;
  }elsif ($line =~/^\s*`define\s+DMEM_ADDR\s+(.*)\s*/){
    $DMEM_ADDR=$1;
  }elsif ($line =~/^\s*`define\s+DMEM_SIZE\s+(.*)\s*/){
    $DMEM_SIZE=$1;	
  }elsif ($line =~/^\s*`define\s+MEM_LIB_PATH\s+(.*)\s*/){
    $MEM_LIB_PATH=$1;
  }elsif ($line =~/^\s*`define\s+PRINT_ADDR\s+(.*)\s*/){
    $PRINT_ADDR=$1;	
  }elsif ($line =~/^\s*`define\s+CPU_TOP\s+(.*)\s*/){ 
    $CPU_TOP = $1;
  }elsif ($line =~/^\s*`define\s+SOC_IMEM_INS\s+(.*)\s*/){
    $SOC_IMEM_INS=$1;	
  }elsif ($line =~/^\s*`define\s+SOC_DMEM_INS\s+(.*)\s*/){
    $SOC_DMEM_INS=$1;
  }elsif ($line =~/^\s*`define\s+TSSP\s+(.*)\s*/){
    $TSSP=$1;
  }elsif ($line =~/^\s*`define\s+TUSP\s+(.*)\s*/){
    $TUSP=$1;
  }elsif ($line =~/^\s*`define\s+SSP\s+(.*)\s*/){
    $SSP=$1;
  }elsif ($line =~/^\s*`define\s+USP\s+(.*)\s*/){
    $USP=$1;
  }elsif ($line =~/^\s*`define\s+TOOL_EXTENSION\s+(.*)/){
    $TOOL_EXTENSION=$1;
  }

}

close FILE;
print"  Read config successfully! \n";

#print "$IMEM_ADDR\n";
#print "$IMEM_SIZE\n";
#print "$DMEM_ADDR\n";
#print "$DMEM_SIZE\n";
#print "$TSSP\n";
#print "$TUSP\n";
#print "$SSP\n";
#print "$USP\n";
#print "$CPU_INS\n";
#print "$SOC_IMEM_INS\n";
#print "$SOC_DMEM_INS\n";
#print "$TOOL_EXTENSION\n";
#print "$PRINT_ADDR\n";



#!system("sed -i 's/^(`define \+SOC_IMEM_INS \+)(.*)/$1$SOC_IMEM_INS/g' mem_inst.v") or die "cant't replace";

#####################################################
# Copy Lib
#####################################################
#!system("rm -r ./lib/*") or die "can't delete";
#!system("rm -r ./tools/*") or die "can't delete";
#!system("cp -r ../lib ./") or die "can't copy";
#!system("cp -r ../tools ./") or die "can't copy";


my $SMART_PATH = `pwd`;
chomp($SMART_PATH);
$SMART_PATH =~ s/smartL.*/smartL\//;
my $csky_suit_path="$SMART_PATH/CSKY_Test_Suit";

#####################################################
# Replace instance path and initial memory file
####################################################


open FILE2,"$SMART_PATH/tb/csky_monitor.v" or die "can't open file";
my @text2=<FILE2>;

open NEW_FILE2,">$csky_suit_path/verilog_task/csky_monitor.v" or die "can't open file";

foreach my $line2 (@text2) {
	$line2=~s/^(\`define\s+CPU_TOP\s+).*/$1$CPU_TOP/g;
	$line2=~s/^(\`define\s+SOC_IMEM_INS\s+).*/$1$SOC_IMEM_INS/g;
	$line2=~s/^(\`define\s+SOC_DMEM_INS\s+).*/$1$SOC_DMEM_INS/g;
	$line2=~s/PRINT_ADDR/$PRINT_ADDR/g;
}
print NEW_FILE2 @text2;
close NEW_FILE2;
close FILE2;

print"  Replace memory and finish file instance path successfully! \n";



#####################################################
# Replace Address of TSSP TUSP SSP USP in linkfile
# Repalce Address of IMEM and DMEM 
####################################################

open FILE3,"$SMART_PATH/lib/linker.lcf" or die "can't open file";
my @text3=<FILE3>;

open NEW_FILE3,">$csky_suit_path/lib/linker.lcf" or die "can't open file";

foreach my $line3 (@text3) {
	$line3=~s/(\s*MEM1\(RWX\)\s+:\s+ORIGIN\s+=\s+)(0x[a-f0-9]+)(\,\s+LENGTH\s+=\s+)(.*)/$1$IMEM_ADDR$3$IMEM_SIZE/;
	$line3=~s/(\s*MEM2\(RWX\)\s+:\s+ORIGIN\s+=\s+)(DATA_BADDR)(\,\s+LENGTH\s+=\s+)(.*)/$1$DMEM_ADDR$3$DMEM_SIZE/;

	$line3=~s/(\_\_kernel_stack\s+\=\s+)(0x[a-f0-9]+)(.*)/$1$SSP$3/;
	$line3=~s/(\_\_user_stack\s+\=\s+)(0x[a-f0-9]+)(.*)/$1$USP$3/;
	$line3=~s/(\_\_tkernel_stack\s+\=\s+)(0x[a-f0-9]+)(.*)/$1$TSSP$3/;
	$line3=~s/(\_\_tuser_stack\s+\=\s+)(0x[a-f0-9]+)(.*)/$1$TUSP$3/;

}
  
print NEW_FILE3 @text3;

close NEW_FILE3;
close FILE3;

print"  Replace linker.lcf successfully! \n";

#####################################################
# Replace path of toolchain 
####################################################

open FILE4,"$SMART_PATH/lib/Makefile" or die "can't open file";
my @text4=<FILE4>;

open NEW_FILE4,">$csky_suit_path/lib/Makefile" or die "can't open file";

foreach my $line4 (@text4) {
	$line4=~s/(\s*TOOL_PATH\s+=\s+)(.*)/$1$TOOL_EXTENSION/;
}
 
print NEW_FILE4 @text4;

close NEW_FILE4;
close FILE4;

print"  Replace Makefile toolset successfully! \n";


#####################################################
# Connect test
####################################################
#
#open FILE5,"../connect.v" or die "can't open file";
#my @text5=<FILE5>;
#open NEW_FILE5,">./connect.v" or die "can't open file";
#
#foreach my $line5 (@text5) {
#	$line5=~s/^(\`define\s+CPU_INS\s+).*/$1$CPU_INS/g;
#	$line5=~s/^(\`define\s+SOC_IMEM_INS\s+).*/$1$SOC_IMEM_INS/g;
#	$line5=~s/^(\`define\s+SOC_DMEM_INS\s+).*/$1$SOC_DMEM_INS/g;
#
#	$line5=~s/^(\`define\s+BIU_PATH\s+).*/$1$BIU_PATH/g;
#	$line5=~s/^(\`define\s+IAHB_LITE_PATH\s+).*/$1$IAHB_LITE_PATH/g;
#	$line5=~s/^(\`define\s+DAHB_LITE_PATH\s+).*/$1$DAHB_LITE_PATH/g;
#	$line5=~s/^(\`define\s+CTIM_PATH\s+).*/$1$CTIM_PATH/g;
#	$line5=~s/^(\`define\s+CLOCK_PATH\s+).*/$1$CLOCK_PATH/g;
#	$line5=~s/^(\`define\s+DFT_PATH\s+).*/$1$DFT_PATH/g;
#	$line5=~s/^(\`define\s+DSP_PATH\s+).*/$1$DSP_PATH/g;
#	$line5=~s/^(\`define\s+FPU_PATH\s+).*/$1$FPU_PATH/g;
#	$line5=~s/^(\`define\s+LOWPOWER_PATH\s+).*/$1$LOWPOWER_PATH/g;
#	$line5=~s/^(\`define\s+JTAG_PATH\s+).*/$1$JTAG_PATH/g;
#	$line5=~s/^(\`define\s+VIC_PATH\s+).*/$1$VIC_PATH/g;
#	$line5=~s/^(\`define\s+CPU_OBSERVED_PATH\s+).*/$1$CPU_OBSERVED_PATH/g;
#
#
#}
# 
#print NEW_FILE5 @text5;
#
#close NEW_FILE5;
#close FILE5;
#
#print " Replace instance path of connect test successfully! \n";
#



#####################################################
# Replace memory test
####################################################

#open FILE6,"$SMART_PATH/mem_replace.v" or die "can't open file";
#my @text6=<FILE6>;
#open NEW_FILE6,">$csky_suit_path/mem_replace_test/mem_replace.v" or die "can't open file";
#
#foreach my $line6 (@text6) {
#	$line6=~s/^(\`define\s+CPU_INS\s+).*/$1$CPU_INS/g;
#	$line6=~s/^(\`define\s+SOC_IMEM_INS\s+).*/$1$SOC_IMEM_INS/g;
#	$line6=~s/^(\`define\s+SOC_DMEM_INS\s+).*/$1$SOC_DMEM_INS/g;
#}
# 
#print NEW_FILE6 @text6;
#
#close NEW_FILE6;
#close FILE6;
#
#print "Memory replace test successfully! \n";

#####################################################
# Replace printf address
####################################################

#my $print_addr="$csky_suit_path/lib/clib/printf.c";
#
#!system("sed -i 's/(.*)PRINT_ADDR(.*)/$PRINT_ADDR/g' $print_addr") or die "cant't replace";
#
#print "Printf.c address replace successfully! \n";

open FILE7,"$SMART_PATH/lib/clib/printf.c" or die "can't open file";
my @text7=<FILE7>;
open NEW_FILE7,">$csky_suit_path/lib/clib/printf.c" or die "can't open file";

foreach my $line7 (@text7) {
	$line7=~s/(.*)0x6000fff8(.*)/$1$SSP$2/g;
}
 
print NEW_FILE7 @text7;

close NEW_FILE7;
close FILE7;
print "Printf.c address replace successfully! \n";


#####################################################
# Replace vtimer address
####################################################

open FILE8,"$SMART_PATH/lib/clib/vtimer.h" or die "can't open file";
my @text8=<FILE8>;
open NEW_FILE8,">$csky_suit_path/lib/clib/vtimer.h" or die "can't open file";

foreach my $line8 (@text8) {
	$line8=~s/(\s*END_ADDR\s+\=\s+)(0x[A-F0-9]+)(.*)/$1$SSP$3/;
}
 
print NEW_FILE8 @text8;

close NEW_FILE8;
close FILE8;
print "vtimer.h address replace successfully! \n";


