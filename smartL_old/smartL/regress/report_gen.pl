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
#// FILE NAME       : report_gen
#// AUTHOR          : ManZhou Wang
#// ORIGINAL TIME   : 05-26-2017
#// FUNCTION        : report_gen script , get the result of every case and list 
#// VERIFICATION    :
#// RELEASE HISTORY :
#// $Id: report_gen.pl,v 1.3 2017/06/21 05:01:41 wangmz Exp $ 
#// *****************************************************************************


my $path="./regress_result";
my @file_list;
my @result_list;
my $filename;
my $file;
my $i=0;
my $pass=0;
my $fail=0;
my $not_run=0;
my $total=0;

#$header1="  BLOCK           PATTERN              RESULT  \n";
#$header2="------------------------------------------------\n";

# read result of every case
@file_list = `find $path -type f`;
foreach $filename (@file_list){
	my $result=" ";
	my $empty;
	open FILE,"$filename" or die "can't open file";
 	@text=<FILE>;
	if($filename=~/.*\/(.*)\.report/) {
		$empty=$1;
		if($empty=~/\w/){
			$file=$empty;
		}else{
			next;
		}
	}		
 	foreach my $file_line (@text){
    		if ($file_line =~/NOT RUN/){  
     			$result="=>NOT RUN";
			$not_run=$not_run+1;
		}
    		elsif ($file_line =~/TEST PASS/){
     			$result="PASS";
			$pass=$pass+1;
    		}
		elsif ($file_line =~/TEST FAIL/){
     			$result="=>FAIL";
			$fail=$fail+1;
    		}else{
			$result=" ";
		}
  	}


	$line="$i,$file,$result\n";
	push (@result_list,$line);
	$i=$i+1;

}

$total=$not_run+$pass+$fail;

#$filename ="./result";
#open NEW_FILE,">$filename" or die "can't open file";
#print NEW_FILE $header1;
#print NEW_FILE $header2;
#print NEW_FILE @result_list;
#close NEW_FILE;

# write result to regress_report file
$filename ="./regress_report";
open NEW_FILE,">$filename" or die "can't open file";
my $file=NEW_FILE;

my ($Block,$Pattern,$Result);
foreach $data (@result_list){
	($Block,$Pattern,$Result)=split(",",$data);
	select(NEW_FILE);
	$^='STDOUT_TOP';
	$~='STDOUT';
#	$=='STDOUT_TO';
	write;
}
# write format
format STDOUT_TOP=
@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 Block      Pattern                   Result
---------------------------------------------
.
format STDOUT=
@<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<@>>>>>>>>>>>>
$Block    $Pattern      $Result
.

#($not_run1,$pass1,$fail1,$total1)=($not_run,$pass,$fail,$total);
#select(NEW_FILE);
#$^='STDOUT_B';
#$~='STDOUT2';
#write;
#format STDOUT_B=
#@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#
#	   Regress Result
# NOT RUN      FAIL      PASS      TOTAL
#------------------------------------------
#.
#format STDOUT2=
#@<<<<<<<<<@<<<<<<<<<<<<<<<@>>>>>>>>>>>>
#$not_run1    $pass1     $fail1      $total1 
#.
$header="---------------------------------------------\n";
$header1=" Not run   Pass   Fail   Total\n";
$header2="   $not_run       $pass      $fail      $total\n";

print NEW_FILE $header;
print NEW_FILE $header1;
print NEW_FILE $header2;
#print NEW_FILE @result_list;
#close NEW_FILE;

close NEW_FILE;
