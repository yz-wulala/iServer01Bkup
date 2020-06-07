// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : zhaor
// CSKYCPU    : 802 
// HWCFIG     : 
// FUNCTION   : cover the 802 alu basic function
// METHOD     : 
// NOTE       : 
// ****************************************************************************


.text
.align 1
.export main
main:

//      .include "core_init.h"
      movi r1, 1
      lsri r2, r1, 1
      subi r3, r2, 1
      lsli r0, r1, 31
      mov r4, r1
      mov r5, r1
      mov r6, r0
      mov r7, r0
      mov r2, r3
      mov r3, r3
      addc16 r4, r5
      addc16 r6, r7
      addc16 r2, r3
      lrw r1,0x2
      cmpne r4,r1
      bt  FAIL
      cmpnei r6,0x0
      bt  FAIL
      lrw r1,0xffffffff
      cmpne r2,r1
      bt  FAIL
EXIT:
      lrw32 r15,__exit
      jmp r15
FAIL:
      lrw32 r15,__fail
      jmp r15
//******this region is added by generator******

