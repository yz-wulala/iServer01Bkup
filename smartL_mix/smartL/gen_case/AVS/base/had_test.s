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
// FILE NAME       : had_test.s 
// AUTHOR          : weidy
// NOTE            : this case tells user to know how to set jtag signal into debug mode 
// ID              : 
// HWCFG : 
// CSKYCPU : 801 802 803
// SMART_R    : yes 

.text
.align 1
.export main
main:

LOOP:
mov r0,r0
br LOOP


PASS:
  lrw r15,__exit
  jmp r15 
  
FAIL:
   lrw r15,__fail
  jmp r15  
