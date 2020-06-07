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
// CSKYCPU      : 801 802 803 804
// HWCFIG       : 
// SMART_R      : yes 
// FUNCTION     : test wakeup by writing jtag
// CTS          : no
// METHOD       : 
// NOTE         : run this file with ckcpu_lpmd_dbg.v
// ****************************************************************************

.text
.align 1
.export main
main:

//*********************************
//enable debug wakeup
//*********************************
lrw r1, 0x4
lrw r2, 0x40016000
stw r1, (r2, 0)

//*********************************
// wait debug
//*********************************
wait


//*********************************
// wait debug
//*********************************
JMP:
  br JMP


