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
// FILE NAME       : ck803_vic_connect.s 
// AUTHOR          : weidy
// NOTE            : this case is test for vic connection  
// ID              : 
// HWCFIG           : VIC
// CSKYCPU         : 801 802 803 804

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
.macro EXIT
      lrw16 r0, __exit
      mov r15,r0
      jmp r15
.endm

.macro FAIL
      lrw16 r0, __fail
      mov r15,r0
      jmp r15
.endm

//****************************************************
// set int handler program:
//****************************************************
SETEXP 33 SEVICER_BEGIN SEVICER_END
SEVICER_BEGIN:
 br NEXT_INT
SEVICER_END:
.ifdef CSKY_TEE
      mfcr r1,cr<0,0>
      bclri r1,30
      mtcr r1,cr<0,0>
.endif
//set sec world ee and ie
      psrset ee,ie


//****************************************************
// please set the trigger external interrupt on your soc
//****************************************************
//lmpd awake
      lrw r1,0xffffffff
      lrw r8,0xE000E1C0 //IWDR
      lrw r7,0xE000E140 //IWER
      st.w r1,(r8,0x0)
      st.w r1,(r7,0x0)
//disable all int
      lrw r1,0xffffffff
      lrw r2,0xE000E180
      st.w r1,(r2,0x0)  //ICER
//enable int 32 ~ int 36
      lrw r3,0xE000E100
      lrw r1,0xf
      st.w r1,(r3,0x0)  //ISER
      movi r5,0x0
set_coretimer:
//set coretimer
      lrw r1,0xE000E010 //CSR
      movi r2,0x50
      st.w r2,(r1,4)    //RVR,50cycle  
      st.w r2,(r1,8)    //CVR, clear  
      ld.w r2,(r1,4)    //RVR,50cycle  
      lrw r3,0x50
      cmpne r2,r3
      bt  TEST_FAIL_2
//enable coretimer
      movi r2,0x7
      st.w r2,(r1,0)   //enable core timer
      ld.w r2,(r1,0)   //enable core timer
      cmpnei r2,0x7
      bt  TEST_FAIL_2

//loop wait coretimer int happend
loop: 
      mov r0,r0
      br loop
//****************************************************
// please set the next trigger external interrupt on your soc
//****************************************************
NEXT_INT:
      mov r0,r0
EXIT_2:
      EXIT
TEST_FAIL_2:
      FAIL 

