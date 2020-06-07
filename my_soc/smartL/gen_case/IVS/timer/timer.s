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
SETEXP 0x2A INTER_BEGIN INTER_END
INTER_BEGIN:
  addi r3, 0x1
  mfcr r4, cr<4, 0>
  addi r4, 4
  mtcr r4, cr<4, 0>
  lrw r6, 0x40011010
  ld.w r1, (r6)
  lrw r6, 0x4001100C
  ld.w r1, (r6)
  st.w r1,(r6)
FINISH:
  rte 
INTER_END:

//****************************************************
// set the interrupt counter
//****************************************************
lrw  r3, 0

mfcr  r0, cr<0, 0>
bclri r0, 30
mtcr  r0, cr<0, 0>
  
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



//==============================
// set timer
//==============================
lrw r0, 0x40011000
lrw r1, 0xFFFF
st.w r1,(r0)

lrw r0, 0x40011008
lrw r1, 0x03
st.w r1,(r0)


  
//*********************************
// wait the interrupt
//*********************************
JMP:
  br JMP
  
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  cmpnei r3, 0x1
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  lrw32 r1, 0x0
  bt TEST_FAIL

TEST_PASS:
  lrw r13, __exit
  jmp r13

TEST_FAIL:
  lrw r13, __fail
  jmp r13


