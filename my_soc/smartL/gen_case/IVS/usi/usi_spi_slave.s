// ****************************************************************************
// AUTHOR     : yizhou jiang
// CSKYCPU    : 801 802 803 804
// HWCFIG     : 
// SMART_R    : yes 
// FUNCTION   : wujian 100 usi spi_slave test
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

  lrw r6, 0x40013008
  ld.w r1, (r6)
  ld.w r1, (r6)
  ld.w r1, (r6)
  
  lrw r6, 0x40013060
  lrw r1, 0x20
  st.w r1,(r6)
  br TEST_PASS
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
// select mode "spi"
//==============================
lrw r0, 0x40013004
lrw r1, 0x02
st.w r1,(r0)

//==============================
// set spi mode
//==============================
// slave
lrw r0, 0x40013040
lrw r1, 0x00
st.w r1,(r0)

//==============================
// set spi ctrl
//==============================
// CPOL=0, CPHA=0, T&R, 8bits
lrw r0, 0x40013044
lrw r1, 0x0007
st.w r1,(r0)

//==============================
// feed tx buffer
//==============================
lrw r0, 0x40013008
lrw r1, 0x11
st.w r1,(r0)

lrw r0, 0x40013008
lrw r1, 0x22
st.w r1,(r0)

lrw r0, 0x40013008
lrw r1, 0x33
st.w r1,(r0)

lrw r0, 0x40013008
lrw r1, 0x44
st.w r1,(r0)

lrw r0, 0x40013008
lrw r1, 0x55
st.w r1,(r0)

//==============================
// set thold intr
//==============================
lrw r0, 0x4001304C
lrw r1, 0x00010300
st.w r1,(r0)

lrw r0, 0x40013050
lrw r1, 0x0020
st.w r1,(r0)

lrw r0, 0x4001305C
lrw r1, 0x0020
st.w r1,(r0)

//==============================
// wait intr
//==============================
LOOP:
    br LOOP



TEST_PASS:
    lrw  r1, __exit
    jmp  r1

