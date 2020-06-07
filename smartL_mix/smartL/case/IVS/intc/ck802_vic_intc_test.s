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
// FILE NAME       : intc_test.s
// CSKYCPU         : 802
// HWCFIG          : VIC
// SMART_R         : yes
// AUTHOR          : lin lin
// NOTE            : (1) This case tells user to know how to enter into interrupt
//                       and deal with interrupt
//                   (2) The configure is intc
//****************************************************

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
// set interrupt handler program:
//****************************************************
SETEXP 34 INTER_BEGIN INTER_END
INTER_BEGIN:
  addi r3, 0x1
  mfcr r4, cr<4, 0>
  addi r4, 4
  mtcr r4, cr<4, 0>
  lrw  r4, 0x40011000
  ldw  r5, (r4, 0x0c)
  mov  r0, r0
  mov  r0, r0
  mov  r0, r0
  rte

INTER_END:


//****************************************************
// set the interrupt counter
//****************************************************
// int counter
  lrw r3, 0

//wsc
  mfcr r5, cr<0, 0>
  bclri r5, 30
  mtcr r5, cr<0, 0>

//initial psr
  mfcr r5, cr<0, 0>
  bseti r5, 6
  bseti r5, 8
  mtcr r5, cr<0, 0>

//set intc
  lrw r4, 0xe000e100
  lrw r2, 0x3f
  st.w r2, (r4, 0x0)

//set timer
  lrw r4, 0x40011000
  lrw r1, 0x000000ff
  st.w r1, (r4, 0x0)
  lrw r1, 0x3
  st.w r1, (r4, 0x8)
  
	
//****************************************************
// wait the interrupt
//****************************************************
JMP:
  br JMP

TEST:
  lrw32 r1 ,0	
  lrw32 r1 ,0	
  lrw32 r1 ,0	
  lrw32 r1 ,0
  lrw32 r1 ,0	
  lrw32 r1 ,0	
  lrw32 r1 ,0	
  lrw32 r1 ,0

//check counter
  cmpnei r3, 0x1
  bt TEST_FAIL


TEST_PASS:
  lrw r1,__exit
  jsr r1

TEST_FAIL:
  lrw r13, __fail
  jmp r13
