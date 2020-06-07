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
#// FILE NAME       : allpat_gen
#// AUTHOR          : ManZhou Wang
#// ORIGINAL TIME   : 05-26-2017
#// FUNCTION        : allpat_gen script , use pat_gen.pl in CSKY_Test_Suit to
#//                   translate all case you select to .pat file  
#// VERIFICATION    :
#// RELEASE HISTORY :
#// $Id: allpat_gen.pl,v 1.3 2018/06/29 01:55:16 wangmz Exp $ 
#// *****************************************************************************

use strict;
#####################################################
# Get Dirlist
#####################################################
my $workpath="../../CSKY_Test_Suit/";


chdir($workpath);

my $path="./case/";

my @dir_list;
my $dirname;

@dir_list = `find $path -type d`;
foreach $dirname (@dir_list){
  $dirname =~ s/case/case_pat/ ;
#  print $filename;
  `mkdir $dirname`;
}

@dir_list = undef;
$dirname= undef;

#####################################################
# Get filelist
#####################################################
my $path_case="./case/";
my @file_list;
my $filename;

@file_list = `find $path_case -type f`;
#foreach $filename (@file_list){
#  print $filename;
#}


my @text;
my @new_text;
my $casefile;
#####################################################
# translate case to .pat
#####################################################
foreach my $filename (@file_list){
	my $new_path;
	if($filename=~/(.*\/)(.*)/){
		$new_path = $1;
		$casefile = $2;
	}
	$new_path=~s/case/case_pat/;

	if($filename=~/.*\.s/) {
		system("./pat_gen.pl $filename");
		print "\n";
		print $filename;
		print $new_path;
		!system("cp  ./workdir/*\_*\.pat $new_path");
#		!system("cp  ./workdir/*\_inst\.pat $new_path") or die "can't copy";
#		!system("cp  ./workdir/*\_data\.pat $new_path") or die "can't copy";

	} elsif ($filename=~/.*coremark.*/) {
		if ($filename=~/.*main.*\.c/) {
			system("./pat_gen.pl $filename");
			print "\n";
			print $filename;
			print $new_path; 
			!system("cp  ./workdir/*\_*\.pat $new_path");
#			!system("cp  ./workdir/*\_inst\.pat $new_path") or die "can't copy";
#			!system("cp  ./workdir/*\_data\.pat $new_path") or die "can't copy";

		}
	} elsif ($filename=~/.*PVS.*memcpy.*/) {
		if ($filename=~/.*mem_copy\.c/) {
			system("./pat_gen.pl $filename"); 
			print "\n";
			print $filename;
			print $new_path;
			!system("cp  ./workdir/*\_*\.pat $new_path");
#			!system("cp  ./workdir/*\_inst\.pat $new_path") or die "can't copy";
#			!system("cp  ./workdir/*\_data\.pat $new_path") or die "can't copy";

		}
	} elsif ($filename=~/.*\.c/){
		system("./pat_gen.pl $filename");
		print "\n";
		print $filename;
		print $new_path;
		!system("cp  ./workdir/*\_*\.pat $new_path");
#		!system("cp  ./workdir/*\_inst\.pat $new_path") or die "can't copy";
#		!system("cp  ./workdir/*\_data\.pat $new_path") or die "can't copy";

	}
}
  

