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
#// FILE NAME       : pat_gen
#// AUTHOR          : Manzhou Wang
#// ORIGINAL TIME   : 05-23-2017
#// FUNCTION        : pat_gen script, generate .pat
#// RESET           : no
#// DFT             : no
#// DFP             :
#// VERIFICATION    :
#// RELEASE HISTORY :
#// $Id: pat_gen.pl,v 1.5 2018/11/05 05:53:49 zhaok Exp $ 
#// *****************************************************************************

use Getopt::Long;
    $Getopt::Long::ignorecase = 0;
use File::Copy;
use Cwd;
use FileHandle;
use File::Basename;
use Term::ANSIColor;
use strict;
no strict 'refs';
my $SMART_PATH = `pwd`;
chomp($SMART_PATH);
$SMART_PATH =~ s/CSKY_Test_Suit.*/CSKY_Test_Suit\//;

my $com_dir = `pwd`;
chomp($com_dir);
my $work;
#=================================================
# Step1: Remove all things in 'workdir'
#=================================================
$work = "$SMART_PATH\/workdir";
chdir($work);
my @file2del;
my $dir = `pwd`;
if($dir =~ /workdir$/) {
	@file2del = qx(ls);
	foreach(@file2del){
		chomp($_);
		if("$_" ne "CVS"){
			!system("rm -rf $_") or die "can't rm";
		}
	}
}
else {
	print "Error when change directory to workdir!";
	exit(1);
}
print "\nStep1 (Remove all things in current 'workdir') is finished!\n";



# Select the specified case and copy some other files you need to workdir 
chdir($com_dir);
my $path;
my $case;
my $case_file;
my $case_make;
my $had_v = "";
my @file;
my $size="no";
foreach(@ARGV){
	if(/\-size/) {
		$size="yes";
	}else {
		$size="no";
	}
	
	if(/(.*\/)(.*)/){
		$case_file = $_;
		$path = $1;
		$case = $2;
	}else{
		$case_file = $_;
		$case = $_;
		chomp($path = `pwd`);
	}

#for .s case
	if($case =~ /(.*)\.s/){
		$case_make = $1;
		!system("cp $case_file $SMART_PATH/workdir") or die "can't copy $case_file";
		if(($case =~ /.*had.*\.s/) or ($case =~ /.*gpio.*\.s/)){
			$case_file =~ s/\.s/\.v/;
			$had_v = $case;
			$had_v =~ s/\.s/\.v/;
			!system("cp $case_file $SMART_PATH/workdir") or die "can't copy $case_file";
		}
	}

#for .c case
	if($case =~ /(.*)\.c/){
		$case_make = $1;
		chomp(@file = `ls $path`);
		foreach(@file){
			if(/CVS/){
				undef $_;
			}else{
				my $file = "$path"."\/"."$_";
				print "$file\n";
				!system("cp $file $SMART_PATH/workdir") or die "can't copy $file";
			}
		}
		!system("cp $SMART_PATH/lib/clib/*.h $SMART_PATH/workdir") or die "can't copy clib program";
		!system("cp $SMART_PATH/lib/clib/*.c $SMART_PATH/workdir") or die "can't copy clib program";
	}
}
print "\nStep2 (Copy file what you need) is finished!\n";

#=======================================================
# Step2: Make 
#========================================================
chdir($work);
my $cpu_model="CPU_MODEL";
$_ = $cpu_model;

if(/ck80[1234]/){
	!system("cp ../lib/Makefile ./Makefile") or die "cant't copy";
        !system("cp ../lib/crt0.s ./crt0.s") or die "cant't copy";
	!system("cp ../lib/linker.lcf ./linker.lcf") or die "cant't copy";
}
else{
	print "Invalid CPU model!";
	exit(1);
}



my $cpu_model_make="CPU_MODEL_MAKE";

!system("make clean; make all CPU=$cpu_model_make ENDIAN_MODE=little-endian FILE=$case_make SIZE=$size") or die "$case can't make";

print "$case_file\n";
print "$path\n";
print "$case\n";
#my $new_path;
#$new_path=$path;
#$new_path=~s/\.\/gen_diag/gen_diag_pat/;
#print "$new_path\n";

!system("cp inst.pat $case_make\_inst.pat") or die "can't copy";
#!system("cp  $case_make\_inst.pat ../$new_path") or die "can't copy";
!system("cp data.pat $case_make\_data.pat ") or die "can't copy";
#!system("cp  $case_make\_data.pat ../$new_path") or die "can't copy";

#!system("rm -r *") or die "can't delete";

print "\nStep3 (Make) is finished!\n";


