// ****************************************************************************
// AUTHOR     : yizhou jiang
// CSKYCPU    : 801 802 803 804
// HWCFIG     : 
// SMART_R    : yes 
// FUNCTION   : wujian 100 usi spi_master test
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
// select mode "spi"
//==============================
lrw r0, 0x4001D004
lrw r1, 0x02
st.w r1,(r0)

//==============================
// set clock div
//==============================
lrw r0, 0x4001D010
lrw r1, 0x12
st.w r1,(r0)

//==============================
// set spi mode
//==============================
// master
lrw r0, 0x4001D040
lrw r1, 0x01
st.w r1,(r0)

//==============================
// set spi ctrl
//==============================
// CPOL=0, CPHA=0, T&R, 8bits
lrw r0, 0x4001D044
lrw r1, 0x0007
st.w r1,(r0)

//==============================
// feed tx buffer
//==============================
lrw r0, 0x4001D008
lrw r1, 0x11
st.w r1,(r0)

lrw r0, 0x4001D008
lrw r1, 0x22
st.w r1,(r0)

lrw r0, 0x4001D008
lrw r1, 0x33
st.w r1,(r0)

//==============================
// wait busy become 0
//==============================
lrw r0, 0x4001D048
movi r3,0x00
LOOP_2:
    ld.w r2,(r0)
    cmpne r2,r3
    bt LOOP_2

//==============================
// read Rx buffer
//==============================
lrw r0, 0x4001D008
lrw r6, 0x06
WAIT_A_IN:
  ld.w r1,(r0)
  subi r6, 0x01
  cmpnei r6, 0x00
  bt WAIT_A_IN


TEST_PASS:
    lrw  r1, __exit
    jmp  r1

