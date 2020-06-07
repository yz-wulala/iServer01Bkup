.text
.align 1
.export main
main:

//==============================
// read DAC default vcalue
//==============================
lrw r0, 0x4001C000
ld.w r7,(r0)

//==============================
// write DAC
//==============================
lrw r0, 0x4001C000
lrw r1, 0x123
st.w r1,(r0)

//==============================
// read DAC
//==============================
lrw r0, 0x4001C000
ld.w r7,(r0)


TEST_PASS:
  lrw r13, __exit
  jmp r13

