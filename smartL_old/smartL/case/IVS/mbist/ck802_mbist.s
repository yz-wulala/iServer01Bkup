// ****************************************************************************
// *                                                                          *
// * C-Sky Microsystems Confidential                                          *
// * -------------------------------                                          *
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR       : Tao Jiang
// CSKYCPU      : 802
// HWCFIG       : CACHE MBIST
// FUNCTION     : 
// CTS          : 
// METHOD       : 
// NOTE         : run this file with ck802_mbist.v
// ****************************************************************************

.text
.align 1
.export main
main:

//*********************************
// wait bist finish
//*********************************
JMP:
  br JMP

lrw r1, 0x1
lrw r1, 0x1
lrw r1, 0x1
lrw r1, 0x1
