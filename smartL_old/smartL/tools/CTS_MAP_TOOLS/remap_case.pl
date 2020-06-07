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
#// FILE NAME       : remap_case
#// AUTHOR          : ManZhou Wang
#// ORIGINAL TIME   : 05-26-2017
#// FUNCTION        : remap_case script , select all case that meet your config 
#// VERIFICATION    :
#// RELEASE HISTORY :
#// $Id: remap_case.pl,v 1.10 2018/11/05 05:54:11 zhaok Exp $ 
#// *****************************************************************************


use strict;

my $SMART_PATH = `pwd`;
chomp($SMART_PATH);
$SMART_PATH =~ s/smartL.*/smartL\//;

chdir($SMART_PATH);


#####################################################
# get CPU
#####################################################
my $top_file = `find ./cpu/ -type f | grep CK8`;
my $cpu;
if($top_file =~ /804/){
  $cpu = 804; 
}
elsif($top_file =~ /803/){
  $cpu = 803; 
}
elsif($top_file =~ /802/){
  $cpu = 802; 
}
elsif($top_file =~ /801/){
  $cpu = 801; 
}
else{
  print"CPU RTL is not found!\n";
  exit; 
}

print"  Step1: CPU TOP file is $top_file";

#####################################################
# Get CPU Configure
####################################################
open FILE,"./cpu/cpu_cfig.h" or die "can't open cpu cfig in ./cpu \n";
my @text2=<FILE>;
my %hash_cfig;
foreach my $line (@text2) {
  if ($line =~/^\s*`define\s+(\w+)/){ 
    $hash_cfig{$1} = 1;
  }
}

print"  Step2: read cpu_cfig.h\n";
#my @tmp = keys %hash_cfig;
#foreach my $tmp1 (@tmp){
#print $tmp1;
#print "\n";  
#}
!system("rm -r ./CSKY_Test_Suit/case") or die "cannot delete dir";
#####################################################
# Get filelist
#####################################################
my $path="./case/";
my @file_list;
my $filename;

@file_list = `find $path -type d`;
foreach $filename (@file_list){
  $filename =~ s/case/CSKY_Test_Suit\/case/ ;
#  print $filename;
   `mkdir $filename`;
}

print"  Step3: Gen gen_dir successfully! \n";

#####################################################
# Get remap base address
####################################################
open FILE_REMAP_CFG,"./tools/CTS_MAP_TOOLS/cts_map_cfig.h" or die "can't open cts_map_cfig";
my @text_remap=<FILE_REMAP_CFG>;
my $REMAP_ADDR;
my $IBUS_ADDR;
my $DBUS_ADDR;

foreach my $line_remap (@text_remap) {
  if ($line_remap =~/^\s*`define\s+BASE_ADDR\s+(.*)\s*/){ 
    $REMAP_ADDR = $1;
  }elsif($line_remap =~/^\s*`define\s+IMEM_ADDR\s+(.*)\s*/){
    $IBUS_ADDR=$1;
  }elsif($line_remap =~/^\s*`define\s+DMEM_ADDR\s+(.*)\s*/){
    $DBUS_ADDR=$1;
  }

}

close FILE_REMAP_CFG;
print"  Read remap address successfully! \n";


@file_list = undef;
$filename= undef;

@file_list = `find $path -type f`;
#foreach $filename (@file_list){
#  print $filename;
#}

my @text;
my @new_text;
my $src_file;
my $des_file;

#####################################################
# read case
#####################################################
foreach my $filename (@file_list){
  @text=undef;
  @new_text=undef;

  open FILE,"$filename" or die "can't open file";
  @text=<FILE>;

#  $filename =~ s/cpu/gen_rtl/ ;
#  open NEW_FILE,">$filename" or die "can't open file";

#####################################################
# read case
####################################################

#open FILE1,"/home/jiangp/projects/virgo/src_diag/cpu/diag/vg_int_acc_fail_nie.rs" or die "can't open file";
#my @text1=<FILE1>;
#open NEW_FILE,">./test.rs" or die "can't open file";
my @CFIG;
my $case_cpu=0;
my $case_cannot_run = 0;
my @new_text;

my  $nesting_num;
my  $config_noexist;
my  $first_lvl ;
my  $not_for_cts=" ";

#judge the core and config
  foreach my $file_line (@text){
    if ($file_line =~ /HWCFIG\s+:\s*(.+)/){  
      @CFIG = split /\s+/,$1;
    }
    elsif ($file_line =~/CSKYCPU\s+:\s*(.+)/){
      $case_cpu = $1;
    }elsif ($file_line=~/CTS\s+:\s*(.+)/){
      $not_for_cts=$1; 
    }
  }
#  filter case, not for cts
  if($not_for_cts=~/no/){
     $case_cannot_run=1;
  }
 
  if($case_cpu =~ /$cpu/){
#    print "$case_cpu \n";
  }
  else{
    $case_cannot_run = 1;    
  }
    
  foreach my $cpu_cfig(@CFIG){
    if($hash_cfig{$cpu_cfig}){
#      print "$cpu_cfig \n";
    }
    else{
      $case_cannot_run = 1;
    }
  }
  
  if ($case_cannot_run) {
    next;  
    $case_cannot_run=0;
  }
  else {
#    print "there is one\n";
  }
  $src_file=$filename;
  $filename =~ s/case/CSKY_Test_Suit\/case/ ;
  $des_file=$filename;
  open NEW_FILE,">$filename" or die "can't open file";
  
  print "     Gen $filename";
####################################################################
  $nesting_num = 0;
  $config_noexist=0;
  $first_lvl = 0;
  foreach my $file_line1 (@text){
    if ($file_line1 =~ /ifdef\s+(\w+)/){
      $nesting_num = $nesting_num +1;
      if(!$hash_cfig{$1} && $config_noexist==0) {
        $config_noexist = 1; 
        $first_lvl = $nesting_num;
      } 
    }
    elsif ($file_line1 =~ /endif/){
      if($nesting_num==$first_lvl){$config_noexist = 0;}
      $nesting_num = $nesting_num -1;
    }       
    else{
      if($config_noexist == 1){}
      else {
	$file_line1 =~ s/IBUS_ADDR/$IBUS_ADDR/ ;
	$file_line1 =~ s/DBUS_ADDR/$DBUS_ADDR/ ;
        $file_line1 =~ s/BASE_ADDR/$REMAP_ADDR/ ;
        push (@new_text,$file_line1);
      }
    }
  }
  print NEW_FILE @new_text;
  
   #recorrect .v file, .v should not be delete as config
  if($filename =~ /\.v/)
  {
     chomp $src_file;
     chomp $des_file;
     print("     cp -rf $src_file  $des_file\n");
     !system("cp -rf $src_file  $des_file") or die "can't copy verilog";
  }

}

!system("cp -r ./case/IVS/power_gating ./CSKY_Test_Suit/case/IVS") or die "can't copy";

!system("cp -r ./case/PVS/c_example ./CSKY_Test_Suit/case/PVS") or die "can't copy";
!system("cp -r ./case/PVS/coremark ./CSKY_Test_Suit/case/PVS") or die "can't copy";
!system("cp -r ./case/PVS/dhry ./CSKY_Test_Suit/case/PVS") or die "can't copy";
!system("cp -r ./case/PVS/int_real_time ./CSKY_Test_Suit/case/PVS") or die "can't copy";
!system("cp -r ./case/PVS/memcpy ./CSKY_Test_Suit/case/PVS") or die "can't copy";
!system("cp -r ./case/PVS/memset ./CSKY_Test_Suit/case/PVS") or die "can't copy";
if(($cpu=~/803/) and ($hash_cfig{FPU})){
!system("cp -r ./case/PVS/linpack ./CSKY_Test_Suit/case/PVS") or die "can't copy";
}elsif(($cpu=~/804/) and ($hash_cfig{FPU})){
!system("cp -r ./case/PVS/linpack ./CSKY_Test_Suit/case/PVS") or die "can't copy";
}else{
}



exit;

