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
// FUNCTION   : cover the 802 803 bmu basic function
// METHOD     : 
// NOTE       : 
// ****************************************************************************

.text
.align 1
.export main
main:

//      .include "core_init.h"
//      .set 0x00000000,0x00000000
//      .set 0x20000000,0x20000000
      .set SBUS_ADDR,0x60000100
      mov r0,r0
      br  ST_INST_TO_IBUS
INST_ADDR:
      mov r0,r0
      movi r0,0x0
      mov r0,r0
      addi r0,0x1
      mov r0,r0
      addi r0,0x2
      mov r0,r0
      addi r0,0x3
      mov r0,r0
      addi r0,0x4
      mov r0,r0
      addi r0,0x5
      mov r0,r0
      addi r0,0x6
      mov r0,r0
      jmp r3

//mov inst to IBUS 
ST_INST_TO_IBUS:
      lrw r2,0x00000000
      lrw r4,INST_ADDR
      ld.w r5,(r4,0x0)
      st.w r5,(r2,0x0)
      ld.w r5,(r4,0x4)
      st.w r5,(r2,0x4)
      ld.w r5,(r4,0x8)
      st.w r5,(r2,0x8)
      ld.w r5,(r4,0xc)
      st.w r5,(r2,0xc)
      ld.w r5,(r4,0x10)
      st.w r5,(r2,0x10)
      ld.w r5,(r4,0x14)
      st.w r5,(r2,0x14)
      ld.w r5,(r4,0x18)
      st.w r5,(r2,0x18)
      ld.w r5,(r4,0x1c)
      st.w r5,(r2,0x1c)

//jump to 0x00000000, exe inst in IBUS
      lrw r3,IBUS_RESULT_CHECK
      jmp r2

//result check 
IBUS_RESULT_CHECK:
      cmpnei r0, 0x15
      bt  FAIL
      br  DBUS_TEST

//****mov inst to DBUS
DBUS_TEST:
      lrw r2,0x20000000
      lrw r4,INST_ADDR
      ld.w r5,(r4,0x0)
      st.w r5,(r2,0x0)
      ld.w r5,(r4,0x4)
      st.w r5,(r2,0x4)
      ld.w r5,(r4,0x8)
      st.w r5,(r2,0x8)
      ld.w r5,(r4,0xc)
      st.w r5,(r2,0xc)
      ld.w r5,(r4,0x10)
      st.w r5,(r2,0x10)
      ld.w r5,(r4,0x14)
      st.w r5,(r2,0x14)
      ld.w r5,(r4,0x18)
      st.w r5,(r2,0x18)
      ld.w r5,(r4,0x1c)
      st.w r5,(r2,0x1c)

//jump to 0x20000000, exe inst in DBUS
      lrw r3,DBUS_RESULT_CHECK
      jmp r2

//result check
DBUS_RESULT_CHECK:
      cmpnei r0, 0x15
      bt  FAIL
      br  SBUS_TEST


//****mov inst to SBUS
SBUS_TEST:
      lrw r2,SBUS_ADDR
      lrw r4,INST_ADDR
      ld.w r5,(r4,0x0)
      st.w r5,(r2,0x0)
      ld.w r5,(r4,0x4)
      st.w r5,(r2,0x4)
      ld.w r5,(r4,0x8)
      st.w r5,(r2,0x8)
      ld.w r5,(r4,0xc)
      st.w r5,(r2,0xc)
      ld.w r5,(r4,0x10)
      st.w r5,(r2,0x10)
      ld.w r5,(r4,0x14)
      st.w r5,(r2,0x14)
      ld.w r5,(r4,0x18)
      st.w r5,(r2,0x18)
      ld.w r5,(r4,0x1c)
      st.w r5,(r2,0x1c)

//jump to SBUS_ADDR, exe inst in SBUS
      lrw r3,SBUS_RESULT_CHECK
      jmp r2

//result check
SBUS_RESULT_CHECK:
      cmpnei r0, 0x15
      bt  FAIL

//LSU access IBUS
IBUS_LD_ST_TEST:
      movi r1,0x1
      movi r2,0x2
      movi r3,0x3
      movi r5,0x0
      movi r6,0x0
      movi r7,0x0
      lrw r4,0x00000000
      st.w r1,(r4,0x0)
      st.w r2,(r4,0x4)
      st.w r3,(r4,0x8)
      ld.w r5,(r4,0x0)
      ld.w r6,(r4,0x4)
      ld.w r7,(r4,0x8)
      addu r7,r5
      addu r7,r6
      cmpnei r7, 0x6
      bt  FAIL

//LSU access DBUS
DBUS_LD_ST_TEST:
      movi r1,0x1
      movi r2,0x2
      movi r3,0x3
      movi r5,0x0
      movi r6,0x0
      movi r7,0x0
      lrw r4,0x20000000
      st.w r1,(r4,0x0)
      st.w r2,(r4,0x4)
      st.w r3,(r4,0x8)
      ld.w r5,(r4,0x0)
      ld.w r6,(r4,0x4)
      ld.w r7,(r4,0x8)
      addu r7,r5
      addu r7,r6
      cmpnei r7, 0x6
      bt  FAIL

//LSU access SBUS
SBUS_LD_ST_TEST:
      movi r1,0x1
      movi r2,0x2
      movi r3,0x3
      movi r5,0x0
      movi r6,0x0
      movi r7,0x0
      lrw r4,SBUS_ADDR
      st.w r1,(r4,0x0)
      st.w r2,(r4,0x4)
      st.w r3,(r4,0x8)
      ld.w r5,(r4,0x0)
      ld.w r6,(r4,0x4)
      ld.w r7,(r4,0x8)
      addu r7,r5
      addu r7,r6
      cmpnei r7, 0x6
      bt  FAIL
EXIT:
      lrw32 r15,__exit
      jmp r15
FAIL:
      lrw32 r15,__fail
      jmp r15

