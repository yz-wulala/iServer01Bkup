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
// SMART_R    : yes  
// FUNCTION   : control register set
// METHOD     : 
// NOTE       : 
// ****************************************************************************
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
  lrw r1, 0xfffffffb
  mtcr r1, cr<0, 0>
  mfcr r2, cr<0, 0>
  lrw r4, 0xfffffffb
  and r2, r4
  lrw r3, 0x80ff03c1
  cmpne r2, r3
  bt TEST_FAIL
  psrclr ie
  mfcr r2, cr<0, 0>
  lrw r3, 0x80ff0380
  cmpne r2, r3
  bt TEST_FAIL
  psrset ie
  

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

//cpuid
  lrw r1, 0xffffffff
  mtcr r1, cr<13, 0> 
  mfcr r2, cr<13, 0>
  lrw r4, 0xfffecfff
  and r2, r4
  lrw r3, 0x04880063
  cmpne r2, r3
  bt TEST_FAIL

mfcr r1, cr<2,0>
mfcr r1, cr<11,0>
mfcr r1, cr<12,0>
mfcr r1, cr<20,0>
mfcr r1, cr<21,0>
mfcr r1, cr<14,1>
mtcr r1, cr<14,1>
mfcr r1, cr<12,1>
mtcr r1, cr<12,1>
mfcr r1, cr<6, 0>


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
TEST_PASS:
  lrw     r0, __exit
  jsr     r0
TEST_FAIL:
  lrw     r0, __fail
  jsr     r0
  
  
  
