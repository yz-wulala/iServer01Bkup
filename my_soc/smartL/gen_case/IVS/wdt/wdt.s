.text
.align 1
.export main
main:


//==============================
// set wdt
//==============================

lrw r0, 0x40012004
lrw r1, 0x11
st.w r1,(r0)

lrw r0, 0x40012000
lrw r1, 0x03
st.w r1,(r0)

//==============================
// write restart
//==============================


lrw r1, 0x01
lrw r1, 0x01
lrw r1, 0x01
lrw r1, 0x01


lrw r0, 0x40011010
WAIT_A_IN:
  ld.w r1,(r0)
  cmpnei r1, 0x01
  bt WAIT_A_IN

lrw r0, 0x4001100C
lrw r7, 0x76
st.w r7,(r0)

TEST_PASS:
  lrw r13, __exit
  jmp r13

TEST_FAIL:
  lrw r13, __fail
  jmp r13
  
