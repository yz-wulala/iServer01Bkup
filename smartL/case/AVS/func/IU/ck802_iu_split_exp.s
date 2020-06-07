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
// FUNCTION   : ck802 split function case
// METHOD     : 
// NOTE       : update by wangmz
// ****************************************************************************


.text
.align 1
.export main
main:
.macro SETEXP OFFSET, HANDLER_BEGIN, HANDLER_END
  lrw  r1, \HANDLER_BEGIN
  mfcr r2, cr<1, 0>
  movi r3, \OFFSET
  lsli r3, r3, 2
  addu r2, r2, r3
  st.w r1, (r2,0)
  br \HANDLER_END
.endm

//      .include "core_init.h"
      SETEXP 1 MISALIGN_EXP_BEGIN MISALIGN_EXP_END
MISALIGN_EXP_BEGIN:
      lrw r1,ACCESS_UNALIGN
      mfcr r2, cr<4, 0>
      cmpne r1,r2
      bt  fail
      

      lrw r2,AFTER_ACCESS_UNALIGN
      mtcr r2, cr<4, 0>
      rte
MISALIGN_EXP_END:
      psrset ee
      lrw sp, 0x2001
ACCESS_UNALIGN:
      push r4-r11,r15
      br fail
AFTER_ACCESS_UNALIGN:
      lrw r15,__exit
      jsr r15
fail:
      lrw r15,__fail
      jsr r15
//******this region is added by generator******

