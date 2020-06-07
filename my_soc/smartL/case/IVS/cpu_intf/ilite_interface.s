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
// FILE NAME       : ck803_ilite_connect.s 
// AUTHOR          : weidy
// NOTE            : this case is test for ilite connection  
// ID              : 
// HWCFIG           : IAHB_LITE
// CSKYCPU         :  802 803 804
.text
.align 1
.export main
main:

//load store data at ibus addr to test connection
  lrw r1,IBUS_ADDR
  lrw r2,0xc5c5c5c5
  lrw r3,0x5c5c5c5c

  st.w r2,(r1,0)
  ld.w r4,(r1,0)
  cmpne r4,r2
  bt FAIL
  
//test for size  
  movi r4,0x0
  st.h r3,(r1,0x4)
  ld.b r4,(r1,0x4)
  lrw  r5,0x5c
  cmpne r5,r4
  bt FAIL

//toggle
  movi r4,0x0
  st.w r3,(r1,0)
  ld.w r4,(r1,0)
  cmpne r4,r3
  bt FAIL
PASS:
  lrw r15,__exit
  jmp r15 
  
FAIL:
   lrw r15,__fail
  jmp r15
