// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : Tao Jiang
// CSKYCPU    : 802
// HWCFIG     : FLOP_OUT_BIU
// CTS        : no
// SMART_R    : yes 
// FUNCTION   : set different clk ratio
// METHOD     : 
// NOTE       : set clk ratio from 0-7 and read back the corresponding value to R3
// ****************************************************************************


//*************Following is the generated instructions*****************

.text
.align 1
.export main
main:
      lrw r1, 0x40017000  //read default clk ratio
      ldw r3, (r1, 0)
     
      lrw r1, 0x40017000 //set clk ratio 1
      lrw r2, 0x1
      stw r2, (r1, 0)
      ldw r3, (r1, 0)

      lrw r1, 0x40017000 //set clk ratio 2
      lrw r2, 0x2
      stw r2, (r1, 0)
      ldw r3, (r1, 0)
       
      lrw r1, 0x40017000 //set clk ratio 3
      lrw r2, 0x3
      stw r2, (r1, 0)
      ldw r3, (r1, 0)

      lrw r1, 0x40017000 //set clk ratio 4
      lrw r2, 0x4
      stw r2, (r1, 0)
      ldw r3, (r1, 0)

      lrw r1, 0x40017000 //set clk ratio 5
      lrw r2, 0x5
      stw r2, (r1, 0)
      ldw r3, (r1, 0)

      lrw r1, 0x40017000 //set clk ratio 6
      lrw r2, 0x6
      stw r2, (r1, 0)
      ldw r3, (r1, 0)

      lrw r1, 0x40017000 //set clk ratio 7
      lrw r2, 0x7
      stw r2, (r1, 0)
      ldw r3, (r1, 0)

      lrw r1, 0x40017000 //set clk ratio 0
      lrw r2, 0x0
      stw r2, (r1, 0)
      ldw r3, (r1, 0)


  TEST_EXIT:
      lrw r15,__exit
      jmp r15
//******this region is added by generator******

