.text
.align 1
.export main
main:

//==============================
// read sfr
//==============================
lrw r0, 0x4001500C
ld.w r7,(r0)

//==============================
// write sfr
//==============================
lrw r0, 0x4001500C
lrw r1, 0xAAAAAAAA
st.w r1,(r0)

//==============================
// read sfr
//==============================
lrw r0, 0x4001500C
ld.w r7,(r0)


andi r5,r7,0xFFF
movi r6, 0xAAA
cmpne r6, r5
bt TEST_FAIL

TEST_PASS:
  lrw r13, __exit
  jmp r13

TEST_FAIL:
  lrw r13, __fail
  jmp r13
  
