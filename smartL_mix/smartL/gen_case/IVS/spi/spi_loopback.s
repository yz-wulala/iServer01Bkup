// ****************************************************************************
// AUTHOR     : yizhou jiang
// CSKYCPU    : 801 802 803 804
// HWCFIG     : 
// SMART_R    : yes 
// FUNCTION   : spi loop back test
// METHOD     : 
// NOTE       : 
// ****************************************************************************
.text
.align 1
.export main
main:
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
// write slave reg
//==============================
lrw r0, 0x4001B00C
lrw r1, 0xFFEEDD66
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

//==============================
// transmit1
//==============================
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
movi r3,0x00
LOOP_1:
    ld.w r2,(r0)
    cmpne r2,r3
    bt LOOP_1
//csb=1
lrw r0, 0x40019000
lrw r1, 0x0F
st.w r1,(r0)

//==============================
// master config
//==============================
lrw r0, 0x4001C074
lrw r1, 0x00040002
st.w r1,(r0)

lrw r0, 0x4001C004
lrw r1, 0xC50E0000
st.w r1,(r0)

//==============================
// transmit2
//==============================
//gpio low (csb=0)
lrw r0, 0x40019000
lrw r1, 0x00
st.w r1,(r0)
//tran
lrw r0, 0x4001C078
lrw r1, 0x88770007
st.w r1,(r0)
//wait busy become 0
lrw r0, 0x4001C07C
movi r3,0x00
LOOP_2:
    ld.w r2,(r0)
    cmpne r2,r3
    bt LOOP_2
//csb=1
lrw r0, 0x40019000
lrw r1, 0x0F
st.w r1,(r0)

//==============================
// master read Rx buffer
//==============================
lrw r0, 0x4001C00C
ld.w r7,(r0)

lrw r0, 0x4001C008
ld.w r7,(r0)

andi r5,r7,0xFFF
    
WAIT_A_IN:
  movi r6, 0x566
  cmpne r6, r5
  bt WAIT_A_IN


TEST_PASS:
    lrw  r1, __exit
    jmp  r1

