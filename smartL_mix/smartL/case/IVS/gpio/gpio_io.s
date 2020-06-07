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
.export main
main:

//==============================
// test gpio port a output
//==============================
lrw r0, 0x40019004
lrw r1, 0xff
st.w r1,(r0)

lrw r0, 0x40019008
lrw r1, 0x0
st.w r1,(r0)

lrw r0, 0x40019000
lrw r1, 0xff
st.w r1,(r0)

//==============================
// test gpio port a input
//==============================
lrw r0, 0x40019004
lrw r1, 0x0
st.w r1,(r0)

lrw r0, 0x40019008
lrw r1, 0x0
st.w r1,(r0)

lrw r0, 0x40019050
ld.w r7,(r0)

WAIT_A_IN:
  movi r6, 0xff
  cmpne r7, r6
  bt WAIT_A_IN
lrw r7, 0x0

TEST_PASS:
    lrw  r1, __exit
    jmp  r1

