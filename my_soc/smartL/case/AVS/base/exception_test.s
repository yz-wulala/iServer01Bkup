// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : weidy
// CSKYCPU    : 801 802 803
// HWCFIG     :
// SMART_R    : yes 
// FUNCTION   : give a example to user to set exception
// METHOD     : 
// NOTE       :this case tells user to know how to configure control 
//             register to set exception(not include interrupt)
// ****************************************************************************
.text
.align 1
.export main
main:
//****************************************************
// set the entry address of the exception
//****************************************************
.macro SETEXP OFFSET, HANDLER_BEGIN, HANDLER_END
  lrw  r1, \HANDLER_BEGIN     //set handler program begin addr
  mfcr r2, cr<1, 0>           //get VBR register value to get the exception handler base addr
  movi r3, \OFFSET            //OFFSET is the exception vector 
  lsli r3, r3, 2              //shift
  addu r2, r2, r3             //calculate the exception vector entry addr
  st.w r1, (r2,0)             //store the exception handler program addr to the exception vector entry addr
  br \HANDLER_END              
.endm

//****************************************************
// set Illegal_INSTU exception handler program:
//****************************************************
SETEXP 4 ILLEGAL_INSTR_BEGIN ILLEGAL_INSTR_END	
ILLEGAL_INSTR_BEGIN:
 mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
 addi r1, r1, 2         
 mtcr r1, cr<4,0>
  rte                    //return the next pc of generating the SPECIAL_INSTR_BEGIN exception
ILLEGAL_INSTR_END:

//****************************************************
// set SPECIAL_INSTR_BEGIN exception handler program:
//****************************************************
SETEXP 5 SPECIAL_INSTR_BEGIN SPECIAL_INSTR_END	
SPECIAL_INSTR_BEGIN:
 mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
 addi r1, r1, 4         
 mtcr r1, cr<4,0>
 rte                    //return the next pc of exit
SPECIAL_INSTR_END:


//*****************************
//   generate Illegal_INSTU exception
//***************************** 
.short 0xffff           //generate a 16 bit illegal instruction 
//*****************************
//   generat Special_INSTU exception
//*****************************
//modify to user mode  
  mfcr r1, cr<0,0>
  bclri r1, r1, 31
  mtcr r1, cr<0,0>

  bseti r1, r1,31
  mtcr r1, cr<0,0>       //generate Special_INSTU

//*****************************
//    EXIT 
//*****************************
  lrw r15,__exit
  jmp r15
