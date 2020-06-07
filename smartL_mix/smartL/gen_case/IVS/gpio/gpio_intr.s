// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : zhaor
// CSKYCPU    : 801 802 803 804
// HWCFIG     : 
// SMART_R    : yes 
// FUNCTION   : gpio test
// METHOD     : 
// NOTE       : 
// ****************************************************************************
.text
.align 1
.set _VIC_ICR, 0xe000e004
.export main
main:

//****************************************************
// use auto interrupt vector	--by shenjc 2014.11.04
//****************************************************
lrw	r1, _VIC_ICR
lrw	r2, 0
st	r2, (r1)

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
SETEXP 0x27 INTER_BEGIN27 INTER_END27
INTER_BEGIN27:
  lrw r0, 0x40019030
  ld.w r1, (r0)
  addi r7,r7,0x1  
  lsli r1, 0x1
  st.w r1, (r0)
  cmpnei r7,0x8
  bt FINISH27
  lrw r6, TEST_PASS
  jmp r6
FINISH27:
  rte 
INTER_END27:

SETEXP 0x28 INTER_BEGIN28 INTER_END28
INTER_BEGIN28:
  lrw r0, 0x40019030
  ld.w r1, (r0)
  addi r7,r7,0x1  
  lsli r1, 0x1
  st.w r1, (r0)
  cmpnei r7,0x8
  bt FINISH28
  lrw r6, TEST_PASS
  jmp r6  
FINISH28:
  rte 
INTER_END28:

SETEXP 0x29 INTER_BEGIN29 INTER_END29
INTER_BEGIN29:
  lrw r0, 0x40019030
  ld.w r1, (r0)
  addi r7,r7,0x1  
  lsli r1, 0x1
  st.w r1, (r0)
  cmpnei r7,0x8
  bt FINISH29
  lrw r6, TEST_PASS
  jmp r6
FINISH29:
  rte 
INTER_END29:

SETEXP 0x2a INTER_BEGIN2a INTER_END2a
INTER_BEGIN2a:
  lrw r0, 0x40019030
  ld.w r1, (r0)
  addi r7,r7,0x1  
  lsli r1, 0x1
  st.w r1, (r0)
  cmpnei r7,0x8
  bt FINISH2a
  lrw r6, TEST_PASS
  jmp r6  
FINISH2a:
  rte 
INTER_END2a:

SETEXP 0x2b INTER_BEGIN2b INTER_END2b
INTER_BEGIN2b:
  lrw r0, 0x40019030
  ld.w r1, (r0)
  addi r7,r7,0x1  
  lsli r1, 0x1
  st.w r1, (r0)
  cmpnei r7,0x8
  bt FINISH2b
  lrw r6, TEST_PASS
  jmp r6  
FINISH2b:
  rte 
INTER_END2b:

SETEXP 0x2c INTER_BEGIN2c INTER_END2c
INTER_BEGIN2c:
  lrw r0, 0x40019030
  ld.w r1, (r0)
  addi r7,r7,0x1  
  lsli r1, 0x1
  st.w r1, (r0)
  cmpnei r7,0x8
  bt FINISH2c
  lrw r6, TEST_PASS
  jmp r6
FINISH2c:
  rte 
INTER_END2c:

SETEXP 0x2d INTER_BEGIN2d INTER_END2d
INTER_BEGIN2d:
  lrw r0, 0x40019030
  ld.w r1, (r0)
  addi r7,r7,0x1  
  lsli r1, 0x1
  st.w r1, (r0)
  cmpnei r7,0x8
  bt FINISH2d
  lrw r6, TEST_PASS
  jmp r6  
FINISH2d:
  rte 
INTER_END2d:

SETEXP 0x2e INTER_BEGIN2e INTER_END2e
INTER_BEGIN2e:
  lrw r0, 0x40019030
  ld.w r1, (r0)
  addi r7,r7,0x1  
  lsli r1, 0x1
  st.w r1, (r0)
  cmpnei r7,0x8
  bt FINISH2e
  lrw r6, TEST_PASS
  jmp r6
FINISH2e:
  rte 
INTER_END2e:

SETEXP 0x2f INTER_BEGIN2f INTER_END2f
INTER_BEGIN2f:
  lrw r0, 0x40019030
  ld.w r1, (r0)
  addi r7,r7,0x1  
  lsli r1, 0x1
  st.w r1, (r0)
  cmpnei r7,0x8
  bt FINISH2f
  lrw r6, TEST_PASS
  jmp r6
FINISH2f:
  rte 
INTER_END2f:


//****************************************************
// set the interrupt counter
//****************************************************
mfcr r5, cr<0, 0>
bseti r5, 6
bseti r5, 8
mtcr r5, cr<0, 0>

//****************************************************
// set the interrupt enable
//****************************************************
lrw r0, 0xe000e100
lrw r1, 0xffffffff
st.w r1, (r0)

//****************************************************
// test gpio port a interrupt
//****************************************************
lrw r0, 0x40019004
lrw r1, 0x0
st.w r1, (r0) // set porta as input

lrw r0, 0x40019008
lrw r1, 0x0
st.w r1, (r0) // set porta as S/W

lrw r0, 0x4001903c
lrw r1, 0xff
st.w r1, (r0) //set porta interrupt active high
  
lrw r0, 0x40019030
lrw r1, 0xff
st.w r1, (r0) // set porta bit as interrupt

WAIT_INT_FINISH:
  cmpnei r7, 0x8
  bt WAIT_INT_FINISH

TEST_PASS:
    lrw  r6, __exit
    jmp  r6
