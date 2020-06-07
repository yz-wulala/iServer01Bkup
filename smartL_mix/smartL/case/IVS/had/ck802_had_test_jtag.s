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
// SMART_R    : 
// FUNCTION   : itag test
// METHOD     :
// NOTE       : 
// ****************************************************************************

.text
.align 1
.export main
main:

//****************************************************************************
//  main program
//function: CPU in debug mode changes the values of R0\R2\R3. If the comparent
//          after every "CHECK" label is correct, jump to TEST_PASS.
//****************************************************************************
  mfcr r4, cr<1,0>
  lrw  r6, 0xfff00000
  lrw  r5, 0x0000ff00

  wait                       //set lpmd_b[1:0] = 2'b01 as a handshake signal

JMP:
  br JMP
 
  bkpt
CHECK1:
  cmpne r6,r7
  bt TEST_FAIL
CHECK2:
  cmpne r6,r2
  bt TEST_FAIL
CHECK3:
  cmpne r6,r3
  bt TEST_FAIL
CHECK_DDC:
  lrw  r2,0x0000fff0
  ld.w r0,(r2,0x0)
  ld.w r1,(r2,0x4)
  cmpnei r0,0xf0
  bt TEST_FAIL
  cmpnei r1,0xff
  bt TEST_FAIL
  mtcr r4,cr<1,0>

TEST_PASS:
  movi    r1, 0xFFFF
  mtcr    r1, cr<11,0>
  movi    r1, 0xFFF
  movi    r0, 0x0
  st      r1, (r0)
  lrw     r0, __exit
  jmp     r0

TEST_FAIL:
  movi    r1, 0xEEEE
  mtcr    r1, cr<11,0>
  movi    r1, 0xEEE
  movi    r0, 0x0
  st      r1, (r0)
  lrw     r0, __fail
  jmp     r0

