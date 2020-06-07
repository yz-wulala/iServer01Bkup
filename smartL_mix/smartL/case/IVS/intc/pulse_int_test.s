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
// HWCFIG       : INT_NUM_32
// SMART_R      : yes 
// FUNCTION     : demonstration of pulse int
// CTS          : no
// METHOD       : 
// NOTE         : run this file with pulse_int_test.v
// ****************************************************************************
.text
.align 1
.export main
main:

//*********************************
//   set the entry address 
//     of the exception
//*********************************
.macro SETEXP OFFSET, HANDLER_BEGIN, HANDLER_END
  lrw  r1, \HANDLER_BEGIN
  mfcr r2, cr<1, 0>
  movi r3, \OFFSET
  lsli r3, r3, 2
  addu r2, r2, r3
  st.w r1, (r2,0)
  br \HANDLER_END
.endm

//*********************************
// set interrupt handler program
//*********************************
SETEXP 51 INTER_BEGIN INTER_END
INTER_BEGIN:
  addi r3, 0x1
  mfcr r4, cr<4, 0>
  addi r4, 4
  mtcr r4, cr<4, 0>
  rte
INTER_END:

//*********************************
// enable int
//*********************************
  lrw r1, 0xffffffff
  lrw r2, 0xE000E100
  stw r1, (r2, 0)  

// int counter
 lrw r3, 0

//*********************************
// set psr
//*********************************	
  mfcr  r0, cr<0, 0>
  bclri r0, 30
  mtcr  r0, cr<0, 0>

//set IE,EE
  mfcr  r0, cr<0, 0>
  bseti r0, 6
  bseti r0, 8
  mtcr  r0, cr<0, 0>

//*********************************
// wait the interrupt
//*********************************
JMP:
  br JMP
  
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  
  cmpnei r3, 0x1
  bt TEST_FAIL

TEST_PASS:
  lrw r13, __exit
  jmp r13

TEST_FAIL:
  lrw r13, __fail
  jmp r13

