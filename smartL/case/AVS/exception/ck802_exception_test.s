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
// FUNCTION   : exception test
// METHOD     : 
// NOTE       : this case tells user to know how to configure control 
//                   register to set exception(not include interrupt)
// ****************************************************************************

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
// set bkpt exception handler program:
//****************************************************
SETEXP 7 BKPT_BEGIN BKPT_END	
BKPT_BEGIN:
  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
  addi r1, r1, 2         
  mtcr r1, cr<4,0>
  rte                    //return the next pc of generating the TRAP0 exception
BKPT_END:

//****************************************************
// set unprivi instruction exception handler program:
//****************************************************
SETEXP 5 UNPRI_BEGIN UNPRI_END
UNPRI_BEGIN:
  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
  addi r1, r1, 4
  mtcr r1, cr<4,0>
  mfcr r1, cr<2, 0>
  bseti r1, 31
  mtcr r1, cr<2, 0>
  rte                    //return the next pc of generating the UNPRI exception
UNPRI_END:

//****************************************************
// set illegal instruction exception handler program:
//****************************************************
SETEXP 4 ILIN_BEGIN ILIN_END
ILIN_BEGIN:
  mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
  addi r1, r1, 2
  mtcr r1, cr<4,0>
  rte                    //return the next pc of generating the MISALIGN exception
ILIN_END:

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

//****************************************************
// set unrecoverable exception handler program:
//****************************************************
SETEXP 8 UNRECOV_BEGIN UNRECOV_END
UNRECOV_BEGIN:
  TEST_PASS:
  movi    r1, 0xFFFF
  mtcr    r1, cr<11,0>
  movi    r1, 0xFFF
  //movi    r0, 0x0
  //st      r1, (r0)
  lrw    r1,  __exit
  jmp    r1
UNRECOV_END:


//*****************************
//   main program
//*****************************
  mfcr r1, cr<0, 0>
  bseti r1, 8
  mtcr r1, cr<0, 0>      //configure the EE=1 of PSR
  .long 0xd7ea0a01

  bkpt                   //generate the bkpt exception
  
  trap 0                 //generate the trap 0 exception
  trap 1                 //generate the trap 1 exception
  trap 2                 //generate the trap 2 exception
  trap 3                 //generate the trap 3 exception
//****************************
//   misalign exception
//****************************
  mfcr r1, cr<0, 0>
  bclri r1, 9
  mtcr r1, cr<0, 0>      //configure the MM=0 of PSR
  lrw r2, 0x1002     //unalign address
  st32.w r0, (r2, 0)       //generate the misalign exception

  mfcr r1, cr<0, 0>
  bclri r1, 31
  mtcr r1, cr<0, 0>
  mfcr r2, cr<1, 0>

//****************************
//   unrecoverable exception
//****************************
  mfcr r1, cr<0, 0>
  bclri r1, 8
  mtcr r1, cr<0, 0>      //configure the MM=0 and EE=0 of PSR
  st.w r0, (r2, 0)       //generate the unrecoverable exception

TEST_FAIL:
  movi    r1, 0xEEEE
  mtcr    r1, cr<11,0>
  movi    r1, 0xEEE
  movi    r0, 0x0
  st      r1, (r0)
  
    


