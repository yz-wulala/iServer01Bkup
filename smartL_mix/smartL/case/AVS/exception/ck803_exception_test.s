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
// FILE NAME       : exception_test.s 
// AUTHOR          : lin lin
// NOTE            : this case tells user to know how to configure control 
//                   register to set exception(not include interrupt)

.text
.align 1
.export main
main:

mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
GENINTRAW1:
      //wait
      idly
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
GENINTRAW2:
      //doze
      idly
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
GENINTRAW3:
      //stop
      idly
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0


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
// set trace exception handler program:
//****************************************************
SETEXP 6 TRACE_BEGIN TRACE_END	
TRACE_BEGIN:
//  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
//  addi r1, r1, 4         
//  mtcr r1, cr<4,0>
  rte                    //return the next pc of generating the TRAP0 exception
TRACE_END:

//****************************************************
// set trap0 exception handler program:
//****************************************************
SETEXP 2 TRAPA_BEGIN TRAPA_END	
TRAPA_BEGIN:
  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
  addi r1, r1, 4         
  mtcr r1, cr<4,0>
  rte                    //return the next pc of generating the TRAP0 exception
TRAPA_END:

//****************************************************
// set trap0 exception handler program:
//****************************************************
SETEXP 16 TRAP0_BEGIN TRAP0_END	
TRAP0_BEGIN:
  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
  addi r1, r1, 4         
  mtcr r1, cr<4,0>
  rte                    //return the next pc of generating the TRAP0 exception
TRAP0_END:
//****************************************************
// set trap1 exception handler program:
//****************************************************
SETEXP 17 TRAP1_BEGIN TRAP1_END	
TRAP1_BEGIN:
  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
  addi r1, r1, 4         
  mtcr r1, cr<4,0>
  rte                    //return the next pc of generating the TRAP0 exception
TRAP1_END:
//****************************************************
// set trap2 exception handler program:
//****************************************************
SETEXP 18 TRAP2_BEGIN TRAP2_END	
TRAP2_BEGIN:
  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
  addi r1, r1, 4         
  mtcr r1, cr<4,0>
  rte                    //return the next pc of generating the TRAP0 exception
TRAP2_END:
//****************************************************
// set trap3 exception handler program:
//****************************************************
SETEXP 19 TRAP3_BEGIN TRAP3_END	
TRAP3_BEGIN:
  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
  addi r1, r1, 4         
  mtcr r1, cr<4,0>
  rte                    //return the next pc of generating the TRAP0 exception
TRAP3_END:


//****************************************************
// set misalign exception handler program:
//****************************************************
SETEXP 1 MISALIGN_BEGIN MISALIGN_END
MISALIGN_BEGIN:
  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
  addi r1, r1, 4
  mtcr r1, cr<4,0>
  rte                    //return the next pc of generating the MISALIGN exception
MISALIGN_END:


SETEXP 44 EXPT44_BEGIN EXPT44_END
EXPT44_BEGIN:
  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
  addi r1, r1, 2
  mtcr r1, cr<4,0>
  rte                    //return the next pc of generating the MISALIGN exception
EXPT44_END:

//****************************************************
// set unrecoverable exception handler program:
//****************************************************
SETEXP 8 UNRECOV_BEGIN UNRECOV_END
UNRECOV_BEGIN:
 br TEST_PASS 
UNRECOV_END:

SETEXP 10 INTER_BEGIN INTER_END
INTER_BEGIN:
  lrw r4, 0x10011000
  ld.w r1, (r4, 0xc)
  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
  addi r1, r1, 2
  mtcr r1, cr<4,0>
//  mfcr r1, cr<2, 0>
//  bclri r1, 15
//  bclri r1, 14
//  mtcr r1, cr<2,0>
  rte                   //return the next pc of generating the MISALIGN exception
INTER_END:


  mfcr r1, cr<0,0>
  bseti r1, 14
  mtcr r1, cr<0,0>

  mfcr r1, cr<0, 0>
  bseti r1, 8
  mtcr r1, cr<0, 0>      //configure the EE=1 of PSR
  
  trap 0                 //generate the trap 0 exception
    
//****************************
//   misalign exception
//****************************
  mfcr r1, cr<0, 0>
  bclri r1, 9
  mtcr r1, cr<0, 0>      //configure the MM=0 of PSR
  lrw r2, 0x1002         //unalign address
  st32.w r0, (r2, 0)     //generate the misalign exception

 trap 1
 

  mfcr r1, cr<0, 0>
  bseti r1, 8
  mtcr r1, cr<0, 0>      //configure the EE=1 of PSR
  
  trap 0          
  lrw r2, 0x1002     //unalign address
  st32.w r0, (r2, 0)

trap 2

//****************************
//   misalign exception
//****************************
  mfcr r1, cr<0, 0>
  bclri r1, 9
  mtcr r1, cr<0, 0>      //configure the MM=0 of PSR
  lrw r2, 0x1002     //unalign address
  st32.w r0, (r2, 0)       //generate the misalign exception

 trap 3

//trace_pending 
  psrset ee
  lrw r0,0xe000e004
  ld.w r2,(r0,0)
  st.w r2,(r0,0)
  mfcr r5, cr<0, 0>
  bseti r5, 6
  mtcr r5, cr<0, 0>
  lrw r3, 0x10010100
  lrw r4, 0xe000e100
  lrw r2, 0x7
  st.w r2, (r3, 0x0)
  st.w r2, (r4, 0x0)


  lrw  r2,0x10010000 
  lrw  r3, 0x00010203
  st.w r3,(r2, 0x40)
  lrw  r3, 0x04050607
  st.w r3,(r2, 0x44)
  lrw  r3, 0x08090a0b
  st.w r3,(r2, 0x48)
  lrw  r3, 0x0c0d0e0f
  st.w r3,(r2, 0x4c)
  lrw  r3, 0x10111213
  st.w r3,(r2, 0x50)
  lrw  r3, 0x14151617
  st.w r3,(r2, 0x54)
  lrw  r3, 0x18191a1b
  st.w r3,(r2, 0x58)
  lrw  r3, 0x1c1d1e1f
  st.w r3,(r2, 0x5c)

  movi r3,0
  st.w r3,(r2,0x10)
  lrw r4,0xffffffff
  st.w r4,(r2,0x10)
  movi r3,0
  st.w r3,(r2,0x18)
//  lrw r3, 0x10010100
//  lrw r4, 0xe000e100
//  lrw r5, 0xe000e300
//  lrw r2, 0x7
//  st.w r2, (r3, 0x0)
//  st.w r2, (r4, 0x0)
//  st.w r2, (r5, 0x0)
  lrw r4, 0x10011000
  lrw r1, 0x00003000
  st.w r1, (r4, 0x0)
  lrw r1, 0x3
  st.w r1, (r4, 0x8)
  lrw r7, 0xffffffff
  lrw r6, 0xffffffff
  addc r7, r6
  addc r7, r6
  addc r7, r6
  addc r7, r6
  addc r7, r6
  addc r7, r6
  addc r7, r6
  addc r7, r6
//****************************************************
// wait the interrupt
//****************************************************a
  mfcr r7,cr<0,0> 
  bclri r7,8
  mtcr r7,cr<0,0>
JMP:
   br JMP
//****************************
//   unrecoverable exception
//****************************
  mfcr r1, cr<0, 0>
  bclri r1, 8
  mtcr r1, cr<0, 0>      //configure the MM=0 and EE=0 of PSR
  st.w r0, (r2, 0)       //generate the unrecoverable exception

TEST_PASS:
  jmpi  __exit

TEST_FAIL:
  jmpi  __fail
