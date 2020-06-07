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
// FUNCTION   : ck802 ifu basic function case, branch inst fetch success
// METHOD     : 
// NOTE       : 
// ****************************************************************************


.text
.align 1
.export main
main:

//      .include "core_init.h"
      lrw r1,0xEC0BAD12      
      lrw r2,0x54F97611      
      lrw r3,0x14A90E27      
      lrw r4,0x2EB4194A      
      lrw r5,0xDE4BEBAF      
      lrw r6,0x60BA7C8D      
      lrw r7,0x96BDED42      
      lrw r8,0xFBD6E32A      
      lrw r9,0x534A515C      
      lrw r10,0x6C66CA12      
      lrw r11,0x85F64E0C      
      lrw r12,0xE9BBB9E9      
      lrw r13,0x849B1694      
      lrw r1, 0
      cmplt r1, r1
      br  TEST_1
      .align 2
TEST_1:
      cmphs16 r1, r1
      bt16  TEST_2
      subu16 r3,r7      
      and16 r5,r2      
      cmphsi16 r1,0x9      
      .align 2
TEST_2:
      cmplt16 r1, r1
      bt16  FAIL
      cmphs16 r1, r1
      br  TEST_3
      movi32 r3,0x67B1      
      lslc32 r4,r10,0x7      
      addu16 r2,r13      
      .align 2
TEST_3:
      cmplt16 r1, r1
      bf16  TEST_4
      bclri32 r2,r15,0x13      
      asri32 r3,r15,0xC      
      andi32 r3,r1,0xF3C      
      .align 2
TEST_4:
      cmphs16 r1, r1
      bf16  FAIL
      br  TEST_5
      addc32 r4,r5,r0      
      cmphsi16 r5,0x13      
      andn32 r5,r13,r3      
      .align 2
TEST_5:
      lrw32 r15,TEST_6
      jmp r15
      .align 2
TEST_6:
      ld16.w r7, (r1)
      br16  TEST_7
      asri16 r4,r2,0x3      
      asri16 r5,r5,0x9      
      cmplti16 r7,0x18      
      .align 2
TEST_7:
      lrw r1,TEST_9
      lrw r2, 0x10000
      st.w r1, (r2)
      br  TEST_8
      revh16 r5,r1      
      subi32 r5,r9,0xAC9      
      movi32 r4,0xF873      
      .align 2
TEST_8:
      mov16 r1, r1
      ld32.w r15, (r2)
      jmp r15
      addc32 r3,r3,r3      
      cmpnei16 r6,0x1      
      movi32 r7,0xA11D      
      .align 2
TEST_9:
      lrw r1,TEST_11
      movi r15, 1
      br  TEST_10
      .align 2
TEST_10:
      mult16 r15, r1
      jmp r15
TEST_11:
      br  PASSED
PASSED:
      lrw r15,__exit
      jmp r15
FAIL:
      lrw32 r15,__fail
      jmp r15
//******this region is added by generator******

