// ****************************************************************************
// AUTHOR     : yizhou jiang
// CSKYCPU    : 801 802 803 804
// HWCFIG     : 
// SMART_R    : yes 
// FUNCTION   : spi loop back test with intr
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
SETEXP 0x34 INTER_BEGIN INTER_END
INTER_BEGIN:
  addi r3, 0x1
  mfcr r4, cr<4, 0>
  addi r4, 4
  mtcr r4, cr<4, 0>
  lrw r5, 0x4001B00C
  ld.w r1, (r5)
  andi r1,r1,0xFFF
  cmpnei r1,0x5CC
  bt TEST_FAIL
  //lrw r6, TEST_PASS
  //jmp r6
FINISH:
  rte 
INTER_END:

//==============================
// gpio set output high
//==============================
lrw r0, 0x40019004
lrw r1, 0x0F
st.w r1,(r0)

lrw r0, 0x40019000
lrw r1, 0x0F
st.w r1,(r0)
//==============================
// master config
//==============================
lrw r0, 0x4001C074
lrw r1, 0x00020001
st.w r1,(r0)

lrw r0, 0x4001C078
lrw r1, 0x00000005
st.w r1,(r0)

lrw r0, 0x4001C004
lrw r1, 0x050D5500
st.w r1,(r0)
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

//****************************************************
// master transmit
//****************************************************
//gpio low (csb=0)
lrw r0, 0x40019000
lrw r1, 0x00
st.w r1,(r0)
//tran
lrw r0, 0x4001C078
lrw r1, 0x00000007
st.w r1,(r0)
//wait busy become 0
lrw r0, 0x4001C07C
LOOP_1:
    ld.w r1,(r0)
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    cmpnei r1,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    bt LOOP_1
lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
    lrw r2,0x00
//csb=1
lrw r0, 0x40019000
lrw r1, 0x0F
st.w r1,(r0)



TEST_PASS:
  lrw r13, __exit
  jmp r13

TEST_FAIL:
  lrw r13, __fail
  jmp r13
