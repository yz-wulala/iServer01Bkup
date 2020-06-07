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
// FILE NAME       : connect_test.s 
// AUTHOR          : weidy
// NOTE            : this case is test for connection  
// ID              : 
// HWCFG           : 
// CSKYCPU         :  802 

.text
.align 1
.export main
main:
loop_begin:
  mov r0 , r0
  mov r1 , r1
  br loop_begin

PASS:
  lrw r15,__exit
  jmp r15 
  
FAIL:
   lrw r15,__fail
  jmp r15
