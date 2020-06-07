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
#FILE NAME       : setup
#FUNCTION        : the file defines the source path and alias
#****************************************************************************** 
#set VCS path
setenv VCS_HOME /tools/synopsys/vcs_vD-2010.06
set path=($VCS_HOME/linux/bin $path)

#set VCS license
setenv SNPSLMD_LICENSE_FILE 27000@gaea:10001@matrix:10001@earth

#set cskytools path
setenv TOOL_PATH /home/zhaok/toolchain/3.8.12


setenv SMART_PATH `pwd | perl -pe "s/smartL.*/smartL\//"`
