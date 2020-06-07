// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : Tao Jiang
// CSKYCPU    : 801 802 803 804
// HWCFIG     :
// SMART_R    : yes  
// CTS        : no
// FUNCTION   : wake cpu up from stop mode using int
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
  br TEST_PASS
INT_END:

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
//set timer 
//*********************************
lrw   r1, 0xa
lrw   r2, 0x3
lrw   r3, 0x40011000
stw   r1, (r3, 0)
stw   r2, (r3, 8)

//*********************************
//enter lpmd
//*********************************
wait
mov   r1, r1
mov   r1, r1

TEST_FAIL:
  lrw r13, __fail
  jmp r13

TEST_PASS:
  lrw r13, __exit
  jmp r13

