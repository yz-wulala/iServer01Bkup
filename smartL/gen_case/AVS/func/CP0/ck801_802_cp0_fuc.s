// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : weidy
// CSKYCPU    : 801  802 
// HWCFIG     :
// SMART_R    : yes  
// FUNCTION   : test mfcr mtcr and trap inst
// METHOD     : 
// NOTE       : 
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
      psrset ee,ie
      SETEXP 16, TRAP_HANDLE_BEGIN, TRAP_HANDLE_END
TRAP_HANDLE_BEGIN:
      mfcr r2, epc
      cmpne r1, r2
      bt  FAIL
      addi r2, 4
      mtcr r2, epc
      rte
TRAP_HANDLE_END:
      movi r1, 0
      mtcr r1, epc   //cp0 inst mtcr
      mfcr r2, epc   //cp0 inst mfcr
      cmpne r1, r2   //cp0 inst result check,cp0 exe success
      bt  FAIL
      lrw r1, 0xffffffff
      mtcr r1, epc
      mfcr r1, epc
      lrw r2, 0xfffffffe
      cmpne r1, r2
      bt  FAIL
      lrw r1,TRAP
TRAP:
      trap 0         //cp0 inst trap
      br  PASS

    
PASS:
     lrw32 r15,__exit
     jmp r15
FAIL:
     lrw32 r15,__fail
     jmp r15
