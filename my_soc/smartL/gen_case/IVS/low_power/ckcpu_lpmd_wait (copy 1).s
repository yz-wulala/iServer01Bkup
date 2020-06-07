// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : Lei Ye
// CSKYCPU    : 801 802 803 804
// HWCFIG     :
// SMART_R    : yes  
// CTS        : no
// FUNCTION   : wake cpu up from wait mode using int
// METHOD     : 
// NOTE       : 
// ****************************************************************************


.text
.align 1
.export main
main:
//*********************************
//   set the entry address
//      of the exception
//*********************************
.macro SETEXP OFFSET, HANDLER_BEGIN, HANDLER_END
  lrw	r1, \HANDLER_BEGIN
  mfcr	r2, cr<1, 0>
  movi	r3, \OFFSET
  lsli	r3, r3, 2
  addu	r2, r2, r3
  st.w	r1, (r2,0)
  br	\HANDLER_END
.endm
 
//*********************************
//exception handler
//*********************************
SETEXP 0x22 INT_BEGIN INT_END
INT_BEGIN:
  addi r4, 0x1
  mfcr r1, cr<4, 0>
  addi r1, 4
  mtcr r1, cr<4, 0>
  
  lrw r1, 0x1
  lrw r2, 0x4001904C
  stw r1, (r2, 0)
  rte
INT_END:


//*********************************
//set intr counter
//*********************************
lrw  r4, 0

//*********************************
//set psr
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
// enable int
//*********************************
lrw r1, 0x4
lrw r2, 0xE000E100
stw r1, (r2, 0)


//*********************************
//enable wic
//*********************************
lrw r1, 0x4
lrw r2, 0xE000E140
stw r1, (r2, 0)


//*********************************
//enable int wakeup
//*********************************
lrw r1, 0x1
lrw r2, 0x40016000
stw r1, (r2, 0)

//*********************************
//set ext intr
//*********************************
lrw r1, 0x1

lrw r2, 0x40019038
stw r1, (r2, 0)

lrw r2, 0x4001903C
stw r1, (r2, 0)

lrw r2, 0x40019030
stw r1, (r2, 0)
//*********************************
//enter lpmd
//*********************************
wait
mov r1, r1
mov r1, r1

loop:
    cmpnei r4,0x5
    bt loop
    
TEST_PASS:
  lrw r13, __exit
  jmp r13
  
TEST_FAIL:
  lrw r13, __fail
  jmp r13
