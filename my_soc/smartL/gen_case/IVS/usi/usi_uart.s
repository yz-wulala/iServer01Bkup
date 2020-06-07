// ****************************************************************************
// AUTHOR     : yizhou jiang
// CSKYCPU    : 801 802 803 804
// HWCFIG     : 
// SMART_R    : yes 
// FUNCTION   : wujian 100 usi uart test
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
SETEXP 0x2F INTER_BEGIN INTER_END
INTER_BEGIN:
  addi r3, 0x1
  mfcr r4, cr<4, 0>
  addi r4, 4
  mtcr r4, cr<4, 0>
  lrw r6, 0x40013054
  ld.w r1, (r6)
  lrw r6, 0x40013060
  lrw r1, 0x0800
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
// enable all modules
//==============================
lrw r0, 0x40013000
lrw r1, 0x0F
st.w r1,(r0)

//==============================
// select mode "uart"
//==============================
lrw r0, 0x40013004
lrw r1, 0x00
st.w r1,(r0)

//==============================
// set clock div
//==============================
lrw r0, 0x40013010
lrw r1, 0x12
st.w r1,(r0)

//==============================
// set uart ctrl
//==============================
// no parity, 1bit stop, 8bit data
lrw r0, 0x40013018
lrw r1, 0x03
st.w r1,(r0)

//==============================
// set uart intr
//==============================
// uart_rx_stop_en
lrw r0, 0x40013050
lrw r1, 0x0800
st.w r1,(r0)

lrw r0, 0x4001305C
lrw r1, 0x0800
st.w r1,(r0)

//==============================
// feed tx buffer
//==============================
lrw r0, 0x40013008
lrw r1, 0xAAAA
st.w r1,(r0)

lrw r0, 0x40013008
lrw r1, 0x1234
st.w r1,(r0)

lrw r0, 0x40013008
lrw r1, 0x5678
st.w r1,(r0)

//==============================
// wait uart status become 0
//==============================
lrw r0, 0x4001301C
LOOP_2:
    ld.w r2,(r0)
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    cmpnei r2,0x0
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    lrw r1,0x00
    bt LOOP_2

lrw r1,0x00
lrw r1,0x00
lrw r1,0x00
lrw r1,0x00
lrw r1,0x00
lrw r1,0x00
lrw r1,0x00
lrw r1,0x00


//==============================
// read Rx buffer
//==============================
lrw r0, 0x40013008
lrw r6, 0x04
WAIT_A_IN:
  ld.w r1,(r0)
  subi r6, 0x01
  cmpnei r6, 0x00
  bt WAIT_A_IN


TEST_PASS:
    lrw  r1, __exit
    jmp  r1

