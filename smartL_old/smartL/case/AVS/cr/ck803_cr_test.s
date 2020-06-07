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
// FILE NAME       : cr_test.s
// AUTHOR          : lin lin
// NOTE            : this case tells user to know how to configure control
//                   register

.text
.align 1
.export main

main:

//*************************************
//  configure the control register
//*************************************
// psr(processor status register):used to save the current status and control information of processor
// 31|30---24|23---------16|15---10| 9|8 |7 |6 |5---3|2 |1|0|
// ----------------------------------------------------------
// |S|   0   |  VEC[7:0]   |   0   |MM|EE|IC|IE|  0  |BM|0|C|   
// ----------------------------------------------------------
  lrw r1, 0xffff8ffd
  mtcr r1, cr<0, 0>
  mfcr r2, cr<0, 0>
  lrw r4, 0xfffffffb
  and r2, r4
//  lrw r3, 0x80ff83c1
  lrw r3, 0x80ff83d1
  cmpne r2, r3
  bt TEST_FAIL

//vbr: vector base register
// 31------------------------------------10|9--------------0|
// ----------------------------------------------------------
// |               VECTOR BASE             |     RESERVED   |
// ----------------------------------------------------------
  lrw r1, 0xffffffff
  mtcr r1, cr<1, 0>
  mfcr r2, cr<1, 0>
  lrw r3, 0xfffffc00
  cmpne r2, r3
  bt TEST_FAIL

//gcr: global control register
  lrw r1, 0xff
  mtcr r1, cr<11, 0>
  mfcr r2, cr<11, 0>
  cmpne r2, r1
  bt TEST_FAIL

//gsr: global status register
  lrw r1, 0xff
  mtcr r1, cr<12, 0>
  mfcr r2, cr<12, 0>
  lrw r3, 0x0
  cmpne r2, r3
  bt TEST_FAIL

//ccr
// 31--------------------11|10-------8|7 |6------------2|1-0|
// ----------------------------------------------------------
// |          0            |    SCK   |BE|       0      | MP|
// ----------------------------------------------------------
  lrw r1, 0xfffffffc
  mtcr r1, cr<18, 0>
  mfcr r2, cr<18, 0>
  lrw r3, 0x0
  cmpne r2, r3
  bt TEST_FAIL

//other crs
  psrset ee,ie
  psrset af
  psrclr af
  psrclr fe
  psrclr ee,ie
  lrw r1, 0xfffffffc
  mtcr r1,cr<2,0>
  mfcr r1, cr<2,0>
  lrw r1, 0xfffffffc
  mtcr r1, cr<3,0>
  mfcr r1, cr<3,0>
  lrw r1, 0xfffffffc
  mtcr r1, cr<4,0>
  mfcr r1, cr<4,0>
  lrw r1, 0xfffffffc
  mtcr r1, cr<5,0>
  mfcr r1, cr<5,0>
  mfcr r1, cr<18,0>
  //bseti r1, 0
 // mtcr r1, cr<18,0>
  mfcr r1, cr<20,0>
  mfcr r1, cr<19,0>
  //mtcr r1, cr<20,0>
  mfcr r1, cr<21,0>
  //mtcr r1, cr<21,0>
  lrw r1, 0xfffffffc
  mtcr r1, cr<13,0>
  mfcr r1, cr<13,0>
  mfcr r1, cr<13,0>
  mfcr r1, cr<13,0>
  mfcr r1, cr<13,0>
  mtcr r1, cr<13,0>
  lrw r1, 0xfffffffc
  mtcr r1, cr<14,0>
  mfcr r1, cr<14,0>
  lrw r1, 0xfffffffc
  mtcr r1, cr<14,1>
  mfcr r1, cr<14,1>
 
//about ifu  
  lrw r28, 0xff
  lrw r17, 0xf
  lrw r16, 0xff
  lrw r4, 0xfff
  push r28,r16-r17 
  mov r0, r0
  lrw r15, AFTER_POP1
  pop r28,r16-r17
AFTER_POP1:
  lrw r28, 0xff
  lrw r15, AFTER_POP2
  push r28,r15
  pop r28, r15
AFTER_POP2:
  lrw r28, 0xf
  push r28, r4
  lrw r15, AFTER_POP3
  pop r28, r4
AFTER_POP3:
  lrw r28, 0xff
  push r28
  lrw r15, AFTER_POP4
  pop r28
AFTER_POP4:
  lrw r15, AFTER_POP5
  push r16-r17, r15
  pop r16-r17, r15
AFTER_POP5:
  push r16-r17, r4
  lrw r15, AFTER_POP6
  pop r16-r17, r4
AFTER_POP6:
  push r16-r17
  lrw r15, AFTER_POP7
  pop r16-r17
AFTER_POP7:
  push r4
  lrw r15, AFTER_POP8
  pop r4
AFTER_POP8:
  lrw r15, AFTER_POP9
  push r16, r15
  pop r16, r15
AFTER_POP9:
  push r16, r4
  lrw r15, AFTER_POP10
  pop r16, r4
AFTER_POP10:
  push r16
  lrw r15, AFTER_POP11
  pop r16
AFTER_POP11:
  lrw r15, AFTER_POP12
  push r15, r4
  pop r15, r4
AFTER_POP12:
  lrw r15, AFTER_POP13
  push r15
  pop r15
AFTER_POP13:
  lrw r15, AFTER_POP14
  lrw r28, 0xff
  push r28, r15, r4
  divu r28, r4, r16
  pop r4, r15, r28  
AFTER_POP14:
  lrw r15, AFTER_POP15
  push r16, r15, r4, r28
  pop r16, r15, r4, r28
AFTER_POP15:
  
   
  

//........ 
  movih r1, 0xffff
  ori r1, r1, 0xffff
  movi r2, 0x7f
  divu r3, r1, r2
  lrw r1, 0xfffffffc
  jsri TEST_PASS
 
TEST_PASS:
  jmpi  __exit

TEST_FAIL:
  jmpi  __fail 
