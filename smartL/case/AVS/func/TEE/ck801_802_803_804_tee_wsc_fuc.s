// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : zhaor
// CSKYCPU    : 801 802 803 804
// HWCFIG     : CSKY_TEE
// SMART_R    : yes  
// FUNCTION   : unsec int nest
// METHOD     : 
// NOTE       : 
// ****************************************************************************

.text
.align 1
.export main
main:

 .macro EXIT
  lrw	r15, __exit
  jmp	r15
.endm

.macro FAIL
  lrw	r15, __fail 
  jmp	r15
.endm  


.macro SETSEXP OFFSET, HANDLER_BEGIN, HANDLER_END
  lrw16  r1, \HANDLER_BEGIN
  mfcr r2, cr<1, 3>
  movi r3, \OFFSET
  lsli r3, r3, 2
  addu r2, r2, r3
  st.w r1, (r2,0)
  br \HANDLER_END
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

.macro SETWSC HANDLER_BEGIN, HANDLER_END
  lrw32  r1, \HANDLER_BEGIN
  //the ebr value is from (vbr + 256<<2)
  mfcr r2, cr<1, 0>
  movi r3, 0x4
  lsli r3, r3, 8
  addu r2, r2, r3
  //set ebr when set wsc handler
  mtcr r2, cr<1, 1>
  //wsc ebr vector is always 0
  st.w r1, (r2,0)
  br \HANDLER_END
.endm

.macro SETSWSC HANDLER_BEGIN, HANDLER_END
  lrw32  r1, \HANDLER_BEGIN
  //the ebr value is from (vbr + 256<<2)
  mfcr r2, cr<1, 3>
  movi r3, 0x4
  lsli r3, r3, 8
  addu r2, r2, r3
  //set ebr when set wsc handler
  mtcr r2, cr<10, 3>
  //wsc ebr vector is always 0
  st.w r1, (r2,0)
  br \HANDLER_END
.endm
      .set PC_SAVE_ADDR, BASE_ADDR
// env init
// SVBR
      lrw r0, PC_SAVE_ADDR + 0x8000
      mtcr r0, cr<1,3>

// initial secure/super sp
      lrw r14, PC_SAVE_ADDR + 0x9000


// initial nosecure/user sp
      lrw r0,  PC_SAVE_ADDR + 0xa000
      mtcr r0,cr<14,1>

// non-secure/supv sp
      lrw r0, PC_SAVE_ADDR + 0xb000
      mtcr r0, cr<6,3>

// SUSP
      lrw r0, PC_SAVE_ADDR + 0xc000
      mtcr r0, cr<7,3>

      SETSEXP 16 TRAP_SERVICE_BEGIN TRAP_SERVICE_END
TRAP_SERVICE_BEGIN:
      mfcr r0,cr<2,0>
      bseti r0,31
      mtcr r0,cr<2,0>
      mfcr r0, cr<4,0>
      addi r0, 4
      mtcr r0,cr<4,0>
      rte
TRAP_SERVICE_END:
      SETEXP 16 STRAP_SERVICE_BEGIN STRAP_SERVICE_END
STRAP_SERVICE_BEGIN:
      mfcr r0, cr<2,3>
      bseti r0,31
      mtcr r0,cr<2,3>
      mfcr r0, cr<4,3>
      addi r0, 4
      mtcr r0,cr<4,3>
      rte
STRAP_SERVICE_END:

      mov r0,r0
      mfcr r5,cr<1,1>

//modify NT_EBR
      lrw r6, 0xfffe0000
      mtcr r6,cr<10,3>

TEST_1:
// modify psr to unsec world
// unsec world
      lrw r0, 0x80000000
      mtcr r0, cr<0,0>
//read NT_EBR
      mfcr r0,cr<1,1>
      cmpne r0,r6
      bt  TEST_FAIL
//read NT_EBR,group3 cr unsec access is 0
      mfcr r0,cr<10,3>
      cmpnei r0,0
      bt  TEST_FAIL
//write NT_EBR
      lrw r0,0xff0000
      mtcr r0,cr<1,1>
      mfcr r1, cr<1,1>
      cmpne r0,r1
      bt  TEST_FAIL
//read NT_EBR,group3 cr unsec access is 0
      lrw r2, 0xfff0000
      mtcr r2, cr<10,3>
      mfcr r3, cr<10,3>
      cmpnei r3, 0
      bt  TEST_FAIL
//recheck NT_EBR not modify by cr<10,3>
      mfcr r3, cr<1,1>
      cmpne r3, r0
      bt  TEST_FAIL
      psrset ee

//wsc to sec world
      lrw r8,sec_world
      lrw r7, 0x0
      st.w r8,(r7,0x0)
      .short 0xc000
      .short 0x3c20
sec_world:
      mfcr r1,cr<0,0>
      lrw  r2,0xc0000000
      and  r1,r2
      cmpne r1,r2
      bt TEST_FAIL
JMP_1_1:
//sec world check SEBR
      mfcr r3,cr<1,1>
      cmpne r3, r5
      bt  TEST_FAIL
//sec world check NSEBR
      mfcr r3, cr<10,3>
      lrw r0, 0xff0000
      cmpne r3, r0
      bt  TEST_FAIL
//sec world modify SEBR,NSEBR
      lrw r0, 0xeffffff
      mtcr r0,cr<1,1>
      lrw r1, 0xdffffff
      mtcr r1,cr<10,3>

//check SEBR,NSEBR, low 2 bits can't write
      mfcr r2,cr<1,1>
      lrw r3, 0xefffffc
      cmpne r2, r3
      bt  TEST_FAIL
      mfcr r2,cr<10,3>
      lrw r3, 0xdfffffc
      cmpne r3, r2
      bt  TEST_FAIL
FINISH:
      EXIT
TEST_FAIL:
      FAIL
//******this region is added by generator******

