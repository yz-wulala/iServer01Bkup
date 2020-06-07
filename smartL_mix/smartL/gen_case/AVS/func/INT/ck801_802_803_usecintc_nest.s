// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : zhaor
// CSKYCPU    : 801,802.803
// HWCFIG     : 
// SMART_R    : yes  
// FUNCTION   : unsec int nest
// METHOD     : 
// NOTE       : 
// ****************************************************************************
.text
.align 1
.export main
main:

      .set INT_VECTOR_ADDR,0x60000100
      .set INT_COUNT_ADDR,0x60000100 + 4
      .set PC_SAVE_ADDR,0x60000100 + 8

.macro EXIT
  lrw	r15, __exit
  jmp	r15
.endm

.macro FAIL
  lrw	r15, __fail 
  jmp	r15
.endm  

.macro SETEXP OFFSET, HANDLER_BEGIN, HANDLER_END
  lrw16  r1, \HANDLER_BEGIN
  mfcr r2, cr<1, 0>
  movi r3, \OFFSET
  lsli r3, r3, 2
  addu r2, r2, r3
  st.w r1, (r2,0)
  br \HANDLER_END
.endm 


      SETEXP 37 INT_SERVICE37_BEGIN, INT_SERVICE37_END
INT_SERVICE37_BEGIN:
      mfcr r1,cr<4,0>
      lrw r2,PC_SAVE_ADDR
      st.w r1,(r2,0)
      lrw r1,INT_VECTOR_ADDR
      ld.w r1,(r1,0)
      lrw r2, 32
      cmpne r1,r2
      bt  FAIL
      lrw r1,INT_COUNT_ADDR
      ld.w r1,(r1,0)
      lrw r2, 1
      cmpne r1,r2
      bt  FAIL
      psrset ee,ie
int33_preempt_int37:
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      lrw r1,0x00000002  
      st.w r1,(r3,0x0)   //ISPR pending int33
int33_preempt_int37_end:
      mov r0,r0
      mov r0,r0
      mov r0,r0
      lrw r1,INT_VECTOR_ADDR
      ld.w r1,(r1,0)
      lrw r2, 32
      cmpne r1,r2        //check int33 nest int37 fail
      bt  FAIL
      lrw r1,INT_COUNT_ADDR
      ld.w r1,(r1,0)
      lrw r2, 1
      cmpne r1,r2
      bt  FAIL
int34_preempt_int37:
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      lrw r1,0x00000004 
      st.w r1,(r3,0x0)  //set ISPR,pending int34 
      mov r0,r0
      mov r0,r0
      mov r0,r0
int34_preempt_int37_end:
      lrw r1,INT_VECTOR_ADDR
      ld.w r1,(r1,0)
      lrw r2, 34
      cmpne r1,r2      //check int33 nest int37 success
      bt  FAIL
      lrw r1,INT_COUNT_ADDR
      ld.w r1,(r1,0)
      lrw r2, 2
      cmpne r1,r2
      bt  FAIL
int35_preempt_int37:
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      lrw r1,0x00000008 //set ISPR,pending int35
      st.w r1,(r3,0x0)
      mov r0,r0
      mov r0,r0
      mov r0,r0
int35_preempt_int37_end:
      lrw r1,INT_VECTOR_ADDR
      ld.w r1,(r1,0)
      lrw r2, 35
      cmpne r1,r2      //check int35 nest int37 success
      bt  FAIL
      lrw r1,INT_COUNT_ADDR
      ld.w r1,(r1,0)
      lrw r2, 3
      cmpne r1,r2
      bt  FAIL
int36_preempt_int37:
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      lrw r1,0x00000010
      st.w r1,(r3,0x0) //set ISPR
      mov r0,r0
      mov r0,r0
      mov r0,r0
int36_preempt_int37_end:
      lrw r1,INT_VECTOR_ADDR
      ld.w r1,(r1,0)
      lrw r2, 36
      cmpne r1,r2     //check int36 nest int37 success
      bt  FAIL
      lrw r1,INT_COUNT_ADDR
      ld.w r1,(r1,0)
      lrw r2, 4
      cmpne r1,r2    //check int into int expt counter
      bt  FAIL
      lrw r1,INT_VECTOR_ADDR
      lrw r2, 37
      st.w r2,(r1,0)
      lrw r1,INT_COUNT_ADDR
      ld.w r2,(r1,0)
      addi r2,0x1
      st.w r2,(r1,0)
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      lrw r1,0xffffffff
      st.w r1,(r2,0x0)
      lrw r2,PC_SAVE_ADDR 
      ld.w r1,(r2,0)   //load return pc
      mtcr r1,cr<4,0>  //return pc write to epsr
      rte
INT_SERVICE37_END:
      SETEXP 32 INT_SERVICE32_BEGIN INT_SERVICE32_END
INT_SERVICE32_BEGIN:
      psrset ee,ie
int37_preempt_int32:
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      lrw r1,0x00000020
      st.w r1,(r3,0x0)
      mov r0,r0
      mov r0,r0
      mov r0,r0
int_vec37_preempt_int32_end:
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      movi r1,0x1
      st.w r1,(r2,0x0)   //set ISPR,pending int32
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
      lrw r1,INT_VECTOR_ADDR
      ld.w r1,(r1,0)
      lrw r2, 32
      cmpne r1,r2       //check int vector
      bt  FAIL
      lrw r1,INT_COUNT_ADDR
      ld.w r2,(r1,0)
      addi r2,0x1
      st.w r2,(r1,0)   //int count++ and savecd
      rte
INT_SERVICE32_END:
      SETEXP 33 INT_SERVICE33_BEGIN INT_SERVICE33_END
INT_SERVICE33_BEGIN:
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      movi r1,0x2
      st.w r1,(r2,0x0)
      lrw r2, 33
      lrw r1,INT_VECTOR_ADDR   //save int vector
      st.w r2,(r1,0)
      lrw r1,INT_COUNT_ADDR
      ld.w r2,(r1,0)
      addi r2,0x1              //int count++
      st.w r2,(r1,0)           //save int counter
      rte
INT_SERVICE33_END:
      SETEXP 34 INT_SERVICE34_BEGIN INT_SERVICE34_END
INT_SERVICE34_BEGIN:
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      movi r1,0x4
      st.w r1,(r2,0x0)
      lrw r2, 34
      lrw r1,INT_VECTOR_ADDR  //save int vector
      st.w r2,(r1,0)                            
      lrw r1,INT_COUNT_ADDR                     
      ld.w r2,(r1,0)                            
      addi r2,0x1             //int count++
      st.w r2,(r1,0)          //save int counter
      rte
INT_SERVICE34_END:
      SETEXP 35 INT_SERVICE35_BEGIN INT_SERVICE35_END
INT_SERVICE35_BEGIN:
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      movi r1,0x8
      st.w r1,(r2,0x0)
      lrw r2, 35
      lrw r1,INT_VECTOR_ADDR //save int vector
      st.w r2,(r1,0)                           
      lrw r1,INT_COUNT_ADDR                    
      ld.w r2,(r1,0)                           
      addi r2,0x1            //int count++
      st.w r2,(r1,0)         //save int counter
      rte
INT_SERVICE35_END:
      SETEXP 36 INT_SERVICE36_BEGIN INT_SERVICE36_END
INT_SERVICE36_BEGIN:
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      movi r1,0x10
      st.w r1,(r2,0x0)
      lrw r2, 36
      lrw r1,INT_VECTOR_ADDR  //save int vector
      st.w r2,(r1,0)                            
      lrw r1,INT_COUNT_ADDR                     
      ld.w r2,(r1,0)                            
      addi r2,0x1             //int count++
      st.w r2,(r1,0)          //save int counter
      rte
INT_SERVICE36_END:
      movi r0,0x0

//int nest test begin 
INST_BEGIN:
//clear enable bit for all int
      lrw r1,0xffffffff
      lrw r2,0xE000E180 //ICER
      lrw r3,0xE000E100 //ISER
      st.w r1,(r2,0x0)  //clear all int enable

//compare ISER and ICER should be the sam
      ld.w r4,(r2,0x0)
      ld.w r5,(r3,0x0)
      cmpne r4,r5
      bt  FAIL

 //set enable  int 32 ~int 37
      lrw r2,0xE000E180
      lrw r3,0xE000E100
      lrw r1,0x3f
      st.w r1,(r3,0x0) //enable 6 int 37 ~int 32

//compare ISER and ICER should be the same
      ld.w r4,(r2,0x0)
      ld.w r5,(r3,0x0)
      cmpne r4,r5
      bt  FAIL

// int vector  37 36 35 34 33 32
//set priority 11 00 01 10 11 11 
      lrw r7,0x4080c0c0
      lrw r6,0xE000E400
      st.w r7,(r6,0x0)
      lrw r7,0xc0c0c000
      st.w r7,(r6,0x4)
      st.w r7,(r6,0x8)
      st.w r7,(r6,0xc)
      st.w r7,(r6,0x10)
      st.w r7,(r6,0x14)
      st.w r7,(r6,0x18)
      st.w r7,(r6,0x1c)
//set psr ee,ie
      psrset ee,ie
//initial vector number and counter
      lrw r1,INT_VECTOR_ADDR
      lrw r2, 32
      st.w r2,(r1,0)
      lrw r1,INT_COUNT_ADDR
      lrw r2, 0
      st.w r2,(r1,0)
//int32 pending
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      lrw r1,0x00000001
      st.w r1,(r3,0x0)
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
//check int37 preempt in int32
//check int nest in int37 expt processing program
      lrw r1,INT_VECTOR_ADDR
      ld.w r1,(r1,0)
      lrw r2, 37
      cmpne r1,r2
      bt  FAIL
      lrw r1,INT_COUNT_ADDR
      ld.w r1,(r1,0)
      lrw r2, 5
      cmpne r1,r2
      bt  FAIL
      EXIT
FAIL:
      FAIL
//******this region is added by generator******

