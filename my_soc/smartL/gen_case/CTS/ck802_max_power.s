// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : Tao Jiang
// CSKYCPU    : 802 
// HWCFIG     : 
// FUNCTION   : 
//              1. test max power with FAST multiply
//              2. test max power without any cfg above
// METHOD     : keep corresponding module busy during loop and keep fetching instructions
// NOTE       : 
// ****************************************************************************

//*************Following is the generated instructions*****************

.text
.align 1
.export main
main:
//loop counter//
      lrw r13, 0x8
      lrw r12, 0x1
//start max power test//
//cofigure with fast multiplier ///
      lrw r1, 0x55555555
      lrw r2, 0xaaaaaaaa
      lrw r4, 0x66666666
      lrw r5, 0x77777777
      lrw r6, 0x88888888
FM_MAX:
      subc r13, r12
      mult r3, r2, r1
      mult r3, r4, r2
      mult r3, r5, r4
      mult r3, r6, r5
      mult r3, r2, r1
      mult r3, r4, r2
      mult r3, r5, r4
      mult r3, r6, r5
      mult r3, r2, r1
      mult r3, r4, r2
      mult r3, r5, r4
      mult r3, r6, r5
      mult r3, r2, r1
      mult r3, r4, r2
      mult r3, r5, r4
      mult r3, r6, r5
      mult r3, r2, r1
      mult r3, r4, r2
      mult r3, r5, r4
      mult r3, r6, r5
      mult r3, r2, r1
      mult r3, r4, r2
      mult r3, r5, r4
      mult r3, r6, r5
      mult r3, r2, r1
      mult r3, r4, r2
      mult r3, r5, r4
      mult r3, r6, r5
      mult r3, r2, r1
      mult r3, r4, r2
      mult r3, r5, r4
      mult r3, r6, r5
      mult r3, r2, r1
      mult r3, r4, r2
      mult r3, r5, r4
      mult r3, r6, r5
      mult r3, r2, r1
      mult r3, r4, r2
      mult r3, r5, r4
      mult r3, r6, r5
      mult r6,r1
      bt  FM_MAX
      br  FINISH

//if none of above module is configured
      lrw r1, 0x55555555
      lrw r2, 0x66666666
      lrw r4, 0x77777777
      lrw r5, 0x88888888
      lrw r6, 0x99999999
//loop counter
      lrw r7, 0x8
      lrw r8, 0x1
ADDER:
      subc r7, r8
      addu r3,r2,r1
      addu r3,r1,r4
      addu r3,r5,r4
      addu r3,r6,r5
      addu r3,r2,r1
      addu r3,r4,r1
      addu r3,r5,r4
      addu r3,r6,r5
      addu r3,r2,r1
      addu r3,r4,r1
      addu r3,r5,r4
      addu r3,r6,r5
      addu r3,r2,r1
      addu r3,r4,r1
      addu r3,r5,r4
      addu r3,r6,r5
      addu r3,r2,r1
      addu r3,r4,r1
      addu r3,r5,r4
      addu r3,r6,r5
      addu r3,r2,r1
      addu r3,r4,r1
      addu r3,r5,r4
      addu r3,r6,r5
      addu r3,r2,r1
      addu r3,r4,r1
      addu r3,r5,r4
      addu r3,r6,r5
      addu r3,r2,r1
      addu r3,r4,r1
      addu r3,r5,r4
      addu r3,r6,r5
      addu r3,r2,r1
      addu r3,r4,r1
      addu r3,r5,r4
      addu r3,r6,r5
      addu r3,r2,r1
      addu r3,r4,r1
      addu r3,r5,r4
      addu r3,r6,r5
      bt  ADDER
//exit
FINISH:
      lrw r12, __exit
      jmp r12

      



