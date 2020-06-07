#! /usr/bin/perl
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
#// FILE NAME       : regress
#// AUTHOR          : ManZhou Wang
#// ORIGINAL TIME   : 05-26-2017
#// FUNCTION        : regress script , generate regress_list.scr  
#// VERIFICATION    :
#// RELEASE HISTORY :
#// $Id: regress.pl,v 1.9 2017/10/16 02:08:40 wangmz Exp $ 
#// *****************************************************************************


my $path="../gen_case/";
my @file_list;
my $filename;
my $run_case="../tools/run_case -nodump -nomnt";
my @regress_list;


#####################################################
# get input parameter
#####################################################
my $sim_tool=0;
foreach(@ARGV){
	if(/\-nc/) {
		$sim_tool=1;
	}else {
		$sim_tool=0;
	}
}
#print "$sim_tool\n";

if($sim_tool){
   $run_case="$run_case -sim_tool nc";
}

!system("rm -rf ./regress_result/*"); 
@file_list = `find $path -type f`;
foreach $filename (@file_list){
	if($filename=~/\.swp/){
	}elsif($filename=~/\.s/){
		$file_line="$run_case $filename";
		push (@regress_list,$file_line);
	}elsif(($filename=~/main/ ) and ($filename=~/\.c/)){
		$file_line="$run_case $filename";
		push (@regress_list,$file_line);
	}else{
	}

}
$filename ="./regress_list.scr";
open NEW_FILE,">$filename" or die "can't open file";
print NEW_FILE @regress_list;
close NEW_FILE;
