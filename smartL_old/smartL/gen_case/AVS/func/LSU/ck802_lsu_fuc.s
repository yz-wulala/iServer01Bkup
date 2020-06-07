// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : zhaor
// CSKYCPU    : 802 
// HWCFIG     : 
// FUNCTION   : ck802 lsu function case
// METHOD     : 
// NOTE       : update by wangmz
// ****************************************************************************

.text
.align 1
.export main
main:

//     .include "core_init.h"
//      .set 0x00000000,0x00000000
//      .set 0x20000000,0x20000000
      .set SBUS_ADDR,0x60000100
      mov r0,r0
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
      lrw r15,__exit
      jmp r15
FAIL:
      lrw r15,__fail
      jmp r15
//******this region is added by generator******

