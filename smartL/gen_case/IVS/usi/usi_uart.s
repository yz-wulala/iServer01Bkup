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
//==============================
// enable all modules
//==============================
lrw r0, 0x4001D000
lrw r1, 0x0F
st.w r1,(r0)

//==============================
// select mode "uart"
//==============================
lrw r0, 0x4001D004
lrw r1, 0x00
st.w r1,(r0)

//==============================
// set clock div
//==============================
lrw r0, 0x4001D010
lrw r1, 0x12
st.w r1,(r0)

//==============================
// set uart ctrl
//==============================
// no parity, 1bit stop, 8bit data
lrw r0, 0x4001D018
lrw r1, 0x03
st.w r1,(r0)

//==============================
// set uart intr
//==============================
// uart_tx_stop_en
lrw r0, 0x4001D050
lrw r1, 0x0400
st.w r1,(r0)

lrw r0, 0x4001D05C
lrw r1, 0x0400
st.w r1,(r0)

//==============================
// feed tx buffer
//==============================
lrw r0, 0x4001D008
lrw r1, 0xAAAA
st.w r1,(r0)

lrw r0, 0x4001D008
lrw r1, 0x1234
st.w r1,(r0)

lrw r0, 0x4001D008
lrw r1, 0x5678
st.w r1,(r0)

//==============================
// wait busy become 0
//==============================
lrw r0, 0x4001D01C
movi r3,0x00
LOOP_2:
    ld.w r2,(r0)
    cmpne r2,r3
    bt LOOP_2

//==============================
// read intr status
//==============================
lrw r0, 0x4001D054
ld.w r1,(r0)
lrw r0, 0x4001D058
ld.w r1,(r0)

//==============================
// clean intr
//==============================
lrw r0, 0x4001D060
lrw r1, 0xFFFF
st.w r1,(r0)

//==============================
// read Rx buffer
//==============================
lrw r0, 0x4001D008
lrw r6, 0x04
WAIT_A_IN:
  ld.w r1,(r0)
  subi r6, 0x01
  cmpnei r6, 0x00
  bt WAIT_A_IN


TEST_PASS:
    lrw  r1, __exit
    jmp  r1

