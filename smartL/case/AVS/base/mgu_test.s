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
// FILE NAME       : mgu_test.s 
// AUTHOR          : weidy
// NOTE            : this case tells user to know how to configure and use the mgu
// ID              : 
// HWCFIG : MGU
// CSKYCPU : 801 802 803
// SMART_R    : yes 

.text
.align 1
.export main
main:
//****************************************************
// set the entry address of the exception
//****************************************************
.macro SETEXP OFFSET, HANDLER_BEGIN, HANDLER_END
  lrw  r1, \HANDLER_BEGIN
  mfcr r2, cr<1, 0>
  movi r3, \OFFSET
  lsli r3, r3, 2
  addu r2, r2, r3
  st.w r1, (r2,0)
  br \HANDLER_END
.endm

//****************************************************
// set access error exception handler program:
//****************************************************
SETEXP 2 ACC_ERR_BEGIN ACC_ERR_END
ACC_ERR_BEGIN:
  mfcr r5, cr<2,0>
  bseti r5, r5, 31
  mtcr r5, cr<2,0>
  movi r6, 0x1           //set flag
  mtcr r4, cr<4, 0>      //r4 is the next pc  
  rte                    //return the next pc of generating the access error exception
ACC_ERR_END:

//*****************************
//   main program
//*****************************
  mfcr r0, cr<0, 0>
  bseti r0, 8            //set psr register ee bit
  mtcr r0, cr<0, 0>
//*********************************************************************
//configure the first MGU region: in user and super mode can read/write
//   AP0 = 2'b11
//   BASE_ADDRESS = 0
//   SIZE = 4G
//   the first area : 0x0~0xffffffff
//*********************************************************************
  lrw r2, 0
  mtcr r2, cr<21, 0>    //configure mgu RID of PRSR,select REGION0
  lrw r1, 0x0000003f    //set the mgu base address=0x0 and size=4G 
  mtcr r1, cr<20, 0>
  mfcr r3, cr<19, 0> 
  bseti r3, 8
  bseti r3, 9
  mtcr r3, cr<19, 0>    //configure the AP0=2'b11 and in user mode and super mode can read/write
  
//****************************************************************************************************
//configure the second MGU region: 1,in super mode can read/write
//                                 2,in user mode only can read, if you writes, can occur access error
//   AP1 = 2'b10
//   BASE_ADDRESS = 0x6000 0000
//   SIZE = 4K
//   the second area : 0x60000000~0x60000fff
//****************************************************************************************************
  lrw  r2, 1
  mtcr r2, cr<21, 0>    //configure mgu RID of PRSR,select REGION1
  lrw  r1, BASE_ADDR       
  lrw  r2, 0xffff0000   
  and  r1, r2           //set mgu base is 60000000
  movi r3,0x17          //size =4K
  or   r1,r3
  mtcr r1,cr<20,0>

  mfcr r1,cr<19,0>
  bseti r1,1            //set REGION1
  bclri r1,10 
  bseti  r1,11          //AP1 = 2'b10
  mtcr  r1,cr<19,0>
  
//*********************************
// enable the mgu
//*********************************
  mfcr r0, cr<18, 0>
  bseti r0, 0
  mtcr r0, cr<18, 0>

TEST1:
  lrw r1,BASE_ADDR     //hit region1 protect region
  lrw r2,0x12345678
  st.w r2,(r1,0)
  ld.w r3,(r1,0)
  cmpne r2,r3
  bt FAIL

TEST2:
  lrw  r4,CONTINUE
  //modify to user mode  
  mfcr r1, cr<0,0>
  bclri r1, r1, 31
  mtcr r1, cr<0,0>

  lrw r1,BASE_ADDR     //hit region1 protect region
  lrw r2,0x12345678
  st.w r2,(r1,0x0)     //user mode only can read, if you writes, can occur access error
CONTINUE:
  ld.w r3,(r1,0x0)
  cmpnei r6,0x1
  bt FAIL
PASS:
  lrw r15,__exit
  jmp r15 
  
FAIL:
   lrw r15,__fail
  jmp r15  
