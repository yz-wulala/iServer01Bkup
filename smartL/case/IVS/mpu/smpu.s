// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : Tao Jiang
// CSKYCPU    : 801 802 803 804
// HWCFIG     : CSKY_TEE
// SMART_R    : yes 
// CTS        : no 
// FUNCTION   : illustrate setting and function of smpu 
// METHOD     : 
// NOTE       : 
// ****************************************************************************
.text
.align 1
.export main
main:

//****************************************************
// set the entry address of the exception
//****************************************************
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
SETEXP 0x2 INT_BEGIN INT_END
INT_BEGIN:
  mfcr r7, cr<4,0>  // epc+4
  addi r7, 0x2
  mtcr r7, cr<4,0>
  addi r4 ,1  // counter+1
  rte    
INT_END:

//*********************************
// initialize smpu
//*********************************
lrw r0, 0x4001a000
lrw r1, 0x60000013
lrw r2, 0x4001a013
lrw r3, 0x40018013
lrw r4, 0

stw r1, (r0, 0)
stw r2, (r0, 4)
stw r3, (r0, 8)


//*********************************
// set psr
//*********************************
mfcr  r5, cr<0,0>
bclri r5, 30
mtcr  r5, cr<0,0>

mfcr  r5, cr<0,0>
bseti r5, 6
bseti r5, 8
mtcr  r5, cr<0,0>

//*********************************
// access to protected area
//*********************************
lrw r0, 0xffffffff
lrw r1, 0x60000000
lrw r2, 0x4001a000
lrw r3, 0x40018000

stw r0, (r1, 0)
stw r0, (r2, 0)
stw r0, (r3, 0)

cmpnei r4, 3 // access error 3 times test pass
bf    TEST_PASS

TEST_FAIL:
  lrw r15, __fail
  jmp r15

TEST_PASS:
  lrw r15, __exit
  jmp r15

