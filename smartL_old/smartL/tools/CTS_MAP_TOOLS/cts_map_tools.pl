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
#// FILE NAME       : cts_map_tools
#// AUTHOR          : ManZhou Wang
#// ORIGINAL TIME   : 05-26-2017
#// FUNCTION        : cts_map_tools script , generate CSKY_Test_Suit  
#// VERIFICATION    :
#// RELEASE HISTORY :
#// $Id: cts_map_tools.pl,v 1.4 2017/06/21 04:08:33 wangmz Exp $ 
#// *****************************************************************************

# get path of current workdir
my $SMART_PATH = `pwd`;
chomp($SMART_PATH);
$SMART_PATH =~ s/smartL.*/smartL\//;

my $crr_path=`pwd`;
chomp($crr_path);

#establish the filesystem
system("rm -r ../../CSKY_Test_Suit");

system("mkdir ../../CSKY_Test_Suit");
system("mkdir ../../CSKY_Test_Suit/tools/");
system("mkdir ../../CSKY_Test_Suit/case/");
system("mkdir ../../CSKY_Test_Suit/lib/");
system("mkdir ../../CSKY_Test_Suit/workdir/");
system("mkdir ../../CSKY_Test_Suit/verilog_task/");
system("mkdir ../../CSKY_Test_Suit/connect_test/");
system("mkdir ../../CSKY_Test_Suit/mem_replace_test/");
system("mkdir ../../CSKY_Test_Suit/dft_sim/");
system("cp ./pat_gen.pl ../../CSKY_Test_Suit/");
system("cp ../../cpu/cpu_cfig.h ../../CSKY_Test_Suit/lib/");
#replace parameters in pat_gen.pl
system("./cpu_type.pl");

# copy lib, Srec2vmem to sim dir
system("cp -r ../../lib/* ../../CSKY_Test_Suit/lib/");
system("cp -r ../../tools/Srec2v* ../../CSKY_Test_Suit/tools/");
#chdir($SMART_PATH);

# choose case and change base addr
system("./remap_case.pl");
#chdir($crr_path);

#generate environment
system("./replace.pl");


# generate all pat
system("./allpat_gen.pl");


# regress
system("./regress.pl");




