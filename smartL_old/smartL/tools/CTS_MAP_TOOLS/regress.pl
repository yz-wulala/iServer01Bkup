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
#// FUNCTION        : regress script , get the caselist you select for cts 
#// VERIFICATION    :
#// RELEASE HISTORY :
#// $Id: regress.pl,v 1.3 2017/06/21 04:11:30 wangmz Exp $ 
#// *****************************************************************************

my $SMART_PATH = `pwd`;
chomp($SMART_PATH);
$SMART_PATH =~ s/smartL.*/smartL\//;
$csky_test_suit="$SMART_PATH\/CSKY_Test_Suit";

#####################################################
# Get all case path
#####################################################

my $path_case="$csky_test_suit/case/";
my @file_list;
my $filename;
@file_list = `find $path_case -type f`;
@new_list;

foreach $filename (@file_list){
	if($filename=~/swp/){
	}elsif($filename=~/\.s/){
		push (@new_list,$filename);
	}elsif($filename=~/main/){
		push (@new_list,$filename);
	}else{
	}
}

#####################################################
# write case list to regress file
#####################################################

open REGRESS,">$csky_test_suit/case/regress" or die "can't open file";

print REGRESS @new_list;
close REGRESS;

print "  Generate regress successfully! \n";

