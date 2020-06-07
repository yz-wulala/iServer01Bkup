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
#// FILE NAME       : cpu_type
#// AUTHOR          : ManZhou Wang
#// ORIGINAL TIME   : 05-26-2017
#// FUNCTION        : cpu_type script , change the parameters in pat_gen.pl 
#// VERIFICATION    :
#// RELEASE HISTORY :
#// $Id: cpu_type.pl,v 1.4 2018/11/05 05:53:35 zhaok Exp $ 
#// *****************************************************************************

#=================================================
# Get cpu config for make and change arguments in
# pat_gen.pl 
#=================================================
my $cpu_config_path="../../cpu/cpu_cfig.h";
#parse environment.h to determine the model of CPU sub-system

#####################################################
# get CPU
#####################################################
my $top_file = `find ../../cpu/ -type f | grep CK8`;
my $cpu_model;
if($top_file =~ /804/){
  $cpu_model = "ck804"; 
}
elsif($top_file =~ /803S/){
  $cpu_model = "ck803s"; 
}
elsif($top_file =~ /802/){
  $cpu_model = "ck802"; 
}
elsif($top_file =~ /801/){
  $cpu_model = "ck801"; 
}
else{
  print"CPU RTL is not found!\n";
  exit; 
}

#####################################################
# get CPU type to Makefile
#####################################################

my $cpu_model_make;

#micro configuration for CK801
if("$cpu_model" eq "ck801"){
	open ENV_FILE, $cpu_config_path or die "cannot open cpu_cfig.h:$!";
	my $temp_line;
	my $bctm_801 = 0;
	while (<ENV_FILE>){
		$temp_line = $_;	
		if($temp_line =~ m/^\s*`define\s+BCTM\s*$/) {
			$bctm_801 = 1;
		}	
	}
	close ENV_FILE;
	if($bctm_801) {
		$cpu_model_make = "ck801j";
	} else {
		$cpu_model_make = "ck801";
	}
}


#micro configuration for CK802
if("$cpu_model" eq "ck802"){
	open ENV_FILE, $cpu_config_path or die "cannot open cpu_cfig.h:$!";
	my $temp_line;
	my $bctm_802 = 0;
	while (<ENV_FILE>){
		$temp_line = $_;
		if($temp_line =~ m/^\s*`define\s+BCTM\s*$/) {
			$bctm_802 = 1;
		}
		
	}
	close ENV_FILE;
	if($bctm_802) {
		$cpu_model_make = "ck802j";
	} else {
		$cpu_model_make = "ck802";
	}
       
}

#micro configuration for CK803
if("$cpu_model" eq "ck803"){
	open ENV_FILE, $cpu_config_path or die "cannot open cpu_cfig.h:$!";
	my $temp_line;
	my $dsp_media_803 = 0;
	while (<ENV_FILE>){
		$temp_line = $_;
		if($temp_line =~ m/^\s*`define\s+DSP\s*$/) {
			$dsp_media_803 = 1;
		}
		}
	close ENV_FILE;
	if($dsp_media_803) {
		$cpu_model_make = "ck803e";
	} else {
		$cpu_model_make = "ck803";
	}
}

#micro configuration for CK803s
if("$cpu_model" eq "ck803s"){
	open ENV_FILE, $cpu_config_path or die "cannot open cpu_cfig.h:$!";
	my $temp_line;
	my $dsp_media_803s = 0;
        my $fpu_803s = 0;
	while (<ENV_FILE>){
		$temp_line = $_;
		if($temp_line =~ m/^\s*`define\s+DSP_MEDIA\s*$/) {
			$dsp_media_803s = 1;
		}
		elsif($temp_line =~ m/^\s*`define\s+FPU\s*$/) {
			$fpu_803s = 1;
		}
	}
	close ENV_FILE;
	if($dsp_media_803s && $fpu_803s) {
		$cpu_model_make = "ck803sef";
	} elsif ($dsp_media_803s && !$fpu_803s) {
		$cpu_model_make = "ck803se";
	} elsif (!$dsp_media_803s && $fpu_803s) {
		$cpu_model_make = "ck803sf";
	} else {
		$cpu_model_make = "ck803s";
	}
}

#micro configuration for CK803s
if("$cpu_model" eq "ck804"){
	open ENV_FILE, $cpu_config_path or die "cannot open cpu_cfig.h:$!";
	my $temp_line;
	my $dsp_media_804 = 0;
    my $fpu_804 = 0;
	while (<ENV_FILE>){
		$temp_line = $_;
		if($temp_line =~ m/^\s*`define\s+DSP\s*$/) {
			$dsp_media_804 = 1;
		}
		elsif($temp_line =~ m/^\s*`define\s+FPU\s*$/) {
			$fpu_804 = 1;
		}
	}
	close ENV_FILE;
	if($dsp_media_804 && $fpu_804) {
		$cpu_model_make = "ck804ef";
	} elsif ($dsp_media_804 && !$fpu_804) {
		$cpu_model_make = "ck804e";
	} elsif (!$dsp_media_804 && $fpu_804) {
		$cpu_model_make = "ck804f";
	} else {
		$cpu_model_make = "ck804";
	}
}


my $SMART_PATH = `pwd`;
chomp($SMART_PATH);
$SMART_PATH =~ s/smartL.*/smartL\//;

#######################################################
# replace the cpu_type int pat_gen.pl at CSKY_Test_Suit 
#######################################################


!system("sed -i 's/CPU_MODEL_MAKE/$cpu_model_make/g' $SMART_PATH/CSKY_Test_Suit/pat_gen.pl") or die "cant't replace";
!system("sed -i 's/CPU_MODEL/$cpu_model/g' $SMART_PATH/CSKY_Test_Suit/pat_gen.pl") or die "cant't replace";

