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
// FUNCTION   :
// METHOD     :
// NOTE       : coverage  case
// ****************************************************************************

.text
.align 1
.export main
#define CSKY_TEE
//#define TSPEND
#define SS_M
#define MGU


main:

      //.include "core_init.h"

 .macro EXIT
  lrw	r15, __exit
  jmp	r15
.endm

.macro FAIL
  lrw	r15, __fail 
  jmp	r15
.endm  

.macro SETEXP OFFSET, HANDLER_BEGIN, HANDLER_END
  lrw	r1, \HANDLER_BEGIN
  mfcr	r2, cr<1, 0>
  movi	r3, \OFFSET
  lsli	r3, r3, 2
  addu	r2, r2, r3
  st.w	r1, (r2,0)
  br	\HANDLER_END
.endm 

      .set SPEC_ADDR, 0x3000
      .set RANDOM_ADDR_0, 0x55555555
      .set RANDOM_ADDR_1, 0xaaaaaaaa
      .set IBUS_ACCERR_ADDR, 0x10000000
//      .set BASE_ADDR, 0x60000000
      #ifdef MGU_REGION_4
      .set MGU_CAPR_MASK, 0x0f00ff0f  //CAPR set according mgu number
      #endif
      #ifdef MGU_REGION_8
      .set MGU_CAPR_MASK, 0xffffffff  //CAPR set according mgu number
      #endif

      #ifdef INT_NUM_8
      .set INT_NUMBER_MASK, 0xff        
      .set INT_NUMBER,8
      #endif
      #ifdef INT_NUM_16
      .set INT_NUMBER_MASK, 0xffff      
      .set INT_NUMBER,16
      #endif
      #ifdef INT_NUM_24
      .set INT_NUMBER_MASK, 0xffffff   
      .set INT_NUMBER,24
      #endif
      #ifdef INT_NUM_32
      .set INT_NUMBER_MASK, 0xffffffff   
      .set INT_NUMBER,32
      #endif
      #ifdef INT_NUM_64
      .set INT_NUMBER_MASK, 0xffffffffffffffff   
      .set INT_NUMBER,64
      #endif
      


//wsc_to_sec_world_init:
//      lrw r12,sec_world_init
//      lrw r13, 0x0
//      st.w r12,(r13,0x0)
//      .short 0xc000
//      .short 0x3c20
//      br __fail
//sec_world_init:

      psrclr fe,ee,ie
      psrset fe,ee,ie
      #ifdef CSKY_TEE
      movi r1,0xf0
      lrw r8,0xE000E240
      st.w r1,(r8,0x0)
      #endif
      mfcr r3,cr<31,0>
      mov r2,r3
      bseti r2,0x4
      mtcr r2,cr<31,0>
      mfcr r3,cr<0,0>
      bseti r3,26
      mtcr r3,cr<0,0>
      lrw r0, 0x0
      mtcr r0, cr<1,3>
      lrw r0, 0x0
      mtcr r0, cr<1,1>
      mfcr r0, cr<1,1>
      cmpnei r0,0x0
      bt  __fail
      mtcr r0, cr<10,3>
      mfcr r0, cr<10,3>
      cmpnei r0,0x0
      bt  __fail
      lrw r14, 0x20001000
      lrw r0, 0x20002000
      mtcr r0,cr<14,1>
      mfcr r1,cr<14,1>
      cmpne r0,r1
      bt  __fail
      #ifdef CSKY_TEE
      lrw r0, 0x20003000
      mtcr r0, cr<6,3>
      mfcr r1, cr<6,3>
      cmpne r0,r1
      bt  __fail
      lrw r0, 0x20004000
      mtcr r0, cr<7,3>
      mfcr r1, cr<7,3>
      cmpne r0,r1
      bt  __fail
      #endif
      #ifdef CSKY_TEE
wsc_to_unsec_set_int_expt:
      lrw r12,unsec_world_1
      lrw r13, 0x0
      st.w r12,(r13,0x0)
      .short 0xc000
      .short 0x3c20
      br  go_back_1
unsec_world_1:
      lrw r14,0x20003000
      psrset ee
      psrset ie
      mfcr r1,cr<0,0>
      lrw r3,0xa0000140
      cmpne r1,r3
      bt  __fail
      #endif
      psrset ee
      psrset ie

      SETEXP 32 INT_SERVICE32_BEGIN INT_SERVICE32_END
INT_SERVICE32_BEGIN:
      sync
      nie
      lrw r2,0xE000E280
      movi r1,0x1
      st.w r1,(r2,0x0)
      lrw r1,BASE_ADDR
      ld.w r0,(r1,4)
      addi r0,32
      st.w r0,(r1,0)
      mfcr r1, cr<0,0>
      nir
INT_SERVICE32_END:
      SETEXP 33 INT_SERVICE33_BEGIN INT_SERVICE33_END
INT_SERVICE33_BEGIN:
      sync
      lrw r2,0xE000E280
      movi r1,0x2
      st.w r1,(r2,0x0)
      lrw r1,BASE_ADDR
      movi r0,33
      st.w r0,(r1,4)
      rte
INT_SERVICE33_END:
      SETEXP 34 INT_SERVICE34_BEGIN INT_SERVICE34_END
INT_SERVICE34_BEGIN:
      sync
      lrw r2,0xE000E280
      movi r1,0x4
      st.w r1,(r2,0x0)
      lrw r1,BASE_ADDR
      movi r0,34
      st.w r0,(r1,8)
      rte
INT_SERVICE34_END:
      SETEXP 35 INT_SERVICE35_BEGIN INT_SERVICE35_END
INT_SERVICE35_BEGIN:
      sync
      lrw r2,0xE000E280
      movi r1,0x8
      st.w r1,(r2,0x0)
      lrw r1,BASE_ADDR
      lrw r0,74        //without secint int39 priority lower than int35
      #ifdef CSKY_TEE
      ld.w r0,(r1,0x1c) //int 39
      addi r0,35
      #endif
      st.w r0,(r1,0xc)
      rte
INT_SERVICE35_END:
      lrw r1,INT_SERVICE40_to_63_BEGIN
      mfcr r2, cr<1, 0>
      movi r3, 40
      lsli r3, r3, 2
      addu r2, r2, r3
      movi r3,0x0
set_vectable_int_address:
      st.w r1, (r2, 0x0)
      addi r2,0x4
      addi r3,0x1
      cmpnei r3,24
      bt  set_vectable_int_address
      br  INT_SERVICE40_to_63_END
INT_SERVICE40_to_63_BEGIN:
      sync
      lrw r2,0xE000E280
      lrw r1,0xffffffff
      st.w r1,(r2,0x0)
      lrw r1,BASE_ADDR
      ld.w r0,(r1,0x20)
      addi r0,1
      st.w r0,(r1,0x20)
      rte
INT_SERVICE40_to_63_END:
unsec_world_unsec_int:
      lrw r1,0x4
      lrw r3,0xE000E100
      st.w r1,(r3,0x0)
      lrw r1,0x4
      lrw r3,0xE000E200
      st.w r1,(r3,0x0)
      mov r0,r0
      mov r0,r0
      mov r0,r0
      mov r0,r0
      lrw r0,BASE_ADDR
      ld.w r1,(r0,0x8)
      cmpnei r1,34
      bt  __fail

      //no unsec int, rte wsc useless 
      #ifdef CSKY_TEE
      rte
go_back_1:
      #endif

      #ifdef CSKY_TEE
      lrw r1,0xffffffff
      lrw r8,0xE000E240
      st.w r1,(r8,0x0)
      ld.w r2,(r8,0x0)
      lrw r3,INT_NUMBER_MASK
      and r1,r3
      cmpne r1,r2
      bt  __fail
      lrw r8,0xE000E2C0
      st.w r1,(r8,0x0)
      ld.w r2,(r8,0x0)
      cmpnei r2,0
      bt  __fail
      #endif
      SETEXP 36 INT_SERVICE36_BEGIN INT_SERVICE36_END
INT_SERVICE36_BEGIN:
      sync
      lrw r2,0xE000E280
      movi r1,0x10
      st.w r1,(r2,0x0)
      lrw r1,BASE_ADDR
      movi r0,36
      st.w r0,(r1,0x10)
      rte
INT_SERVICE36_END:
      SETEXP 37 INT_SERVICE37_BEGIN INT_SERVICE37_END
INT_SERVICE37_BEGIN:
      sync
      lrw r2,0xE000E280
      movi r1,0x20
      st.w r1,(r2,0x0)
      lrw r1,BASE_ADDR
      movi r0,37
      st.w r0,(r1,0x14)
      rte
INT_SERVICE37_END:
      SETEXP 38 INT_SERVICE38_BEGIN INT_SERVICE38_END
INT_SERVICE38_BEGIN:
      sync
      lrw r2,0xE000E280
      movi r1,0x40
      st.w r1,(r2,0x0)
      lrw r1,BASE_ADDR
      movi r0,38
      st.w r0,(r1,0x18)
      rte
INT_SERVICE38_END:
      SETEXP 39 INT_SERVICE39_BEGIN INT_SERVICE39_END
INT_SERVICE39_BEGIN:
      nie
      ipush
      ipop
      ipush
      ipop
      lrw r2,0xE000E280
      movi r1,0x80
      st.w r1,(r2,0x0)
      lrw r1,BASE_ADDR
      movi r0,39
      st.w r0,(r1,0x1c)
      nir
INT_SERVICE39_END:
      SETEXP 1 MISALIGN_HANDLE_BEGIN MISALIGN_HANDLE_END
MISALIGN_HANDLE_BEGIN:
      mov r1,r1
      mov r1,r1
      mov r1,r1
      movi r1,0xa000
      rte
MISALIGN_HANDLE_END:
      SETEXP 2 ACCESS_ERROR_BEGIN ACCESS_ERROR_END
ACCESS_ERROR_BEGIN:
      mfcr r1, epc
      addi r1, r1, 2
      mtcr r1, epc
      movi r3,0xacc
      rte
ACCESS_ERROR_END:
      SETEXP 3 DIV0_EXP_BEGIN DIV0_EXP_END
DIV0_EXP_BEGIN:
      mfcr r0,cr<4,0>
      addi r0,4
      mtcr r0,cr<4,0>
      rte
DIV0_EXP_END:
      SETEXP 4 ILLEGAL_INST_EXP_BEGIN ILLEGAL_INST_EXP_END
ILLEGAL_INST_EXP_BEGIN:
      lrw r1,0x8000
      ld.w r1,(r1,0)
      lrw r2,0x3f800000
      cmpne r1,r2
      bt  __fail
      mfcr r0,cr<4,0>
      addi r0,4
      mtcr r0,cr<4,0>
      rte
ILLEGAL_INST_EXP_END:
      SETEXP 6 TRACE_EXP_BEGIN TRACE_EXP_END
TRACE_EXP_BEGIN:
      addi16 r1, 4
      mfcr r2, cr<4, 0>
      lrw r1, 0x80064150
      mfcr r2, cr<2, 0>
      addi r11, 1
      rte
TRACE_EXP_END:
      SETEXP 7 BKPT_EXP_BEGIN BKPT_EXP_END
BKPT_EXP_BEGIN:
      cmpnei r12, 0x1111
      bt  __fail
      lrw r12, 0x7777
      mov r1, r15
      mfcr r2, cr<4, 0>
      cmpne r1,r2
      bt  __fail
      lrw r0,0xe0011054
      lrw r1,0x0
      st.w r1,(r0,0)
      rte
BKPT_EXP_END:
      SETEXP 10 AUTO_INT_BEGIN AUTO_INT_END
AUTO_INT_BEGIN:
      movi r10, 0x9876
      rte
AUTO_INT_END:
      SETEXP 16 TRAP0_BEGIN TRAP0_END
TRAP0_BEGIN:
      mfcr r1, cr<4, 0>
      addi r1, r1, 4
      mtcr r1, cr<4,0>
      rte
TRAP0_END:
      SETEXP 17 TRAP1_BEGIN TRAP1_END
TRAP1_BEGIN:
      mfcr r1, cr<4, 0>
      addi r1, r1, 4
      mtcr r1, cr<4,0>
      rte
TRAP1_END:
      SETEXP 18 TRAP2_BEGIN TRAP2_END
TRAP2_BEGIN:
      mfcr r1, cr<4, 0>
      addi r1, r1, 4
      mtcr r1, cr<4,0>
      rte
TRAP2_END:
      SETEXP 19 TRAP3_BEGIN TRAP3_END
TRAP3_BEGIN:
      mfcr r1, cr<4, 0>
      addi r1, r1, 4
      mtcr r1, cr<4,0>
      rte
TRAP3_END:

#ifdef TSPEND
      SETEXP 22 TSPEND_BEGIN TSPEND_END
TSPEND_BEGIN:
      lrw r1,0x8000
      lrw r2,22
      st.w r2,(r1,0)
      rte
TSPEND_END:
#endif

main_start:
      lrw r0, 0x00000000
      lrw r1, 0x55555555
      lrw r2, 0xaaaaaaaa
      bmaski r3, 0x0
      mov r4, r0
      mov r5, r0
      lrw r6, 0x0
      lrw r7, 0x55555555
      mov r9, r0
      mov r10, r0
      mov r11, r0
      mov r12, r11
      mov r13, r12
      mov r13, r13
      lrw sp, 0x5555aaaa
      mov r15, r14
      addc16 r6, r7
      addc32 r7, r6, r2
      addi16 r7, 0x01
      addi16 r4, r7, 0x01
      addi16 r7, sp, 0xa8
      addi32 sp, sp, 0xffc
      cmpnei r4, 0x1
      bt  __fail
      addu16 r6, r7
      addu32 r7, r6, r2
      and16 r6, r7
      and32 r4, r2, r3
      andi r7, r6, 0xaaa
      andn16 r6, r7
      andn32 r4, r4, r1
      andni32 r7, r6, 0xaaa
      asr16 r6, r7
      asr32 r3, r2, r4
      asrc32 r4, r3, 0xa
      asri16 r7, r6, 1
      asri32 r3, r4, 15
      bclri16 r3, 7
      not r3
      cmpnei r3, 0x80
      bt  __fail
      bclri32 r4, r7, 0x0
      cmpnei r4, 0x4000
      bt  __fail
      bf16  __bf_label
__bf_label:
      bmaski r4, 17
      lrw r3, 0x1ffff
      cmpne r3, r4
      bt32  __bt_label
__bt_label:
      bf32  __br16_label
      br16  __br16_label
__br16_label:
      br32  __br32_label
__br32_label:
      bseti16 r0, 0x15
      bseti16 r0, 0x0a
      bseti32 r4, r0, 0x00
      bseti32 r4, r0, 0x15
      bseti32 r4, r0, 0x1f
      bsr32  __bsr32_label
__bsr32_label:
      movi r1,0x1
      .short 0x39c0
      bt  jump_over
      bt  __fail
jump_over:
      btsti r1, 0x1
      btsti r4, 0x5
      cmphs16 r4, r3
      cmplt16 r4, r3
      cmphsi16 r4, 0x1f
      cmphsi32 r4, 0xffff
      cmplti16 r4, 0x1f
      cmplti32 r4, 0xffff
      cmpne16 r4, r3
      cmpnei32 r6, 0x8000
      decf r4, r6, 0x1
      dect r4, r4, 0x1
      cmpnei r4, 0x7fff
      bt  __fail
      movi r4, 0x1
__ff_label:
      ff1 r0, r4
      ff0 r0, r4
      lsli r4, 0x1
      cmpnei r4, 0
      bt  __ff_label
      ff0 r6, r7
      ff1 r7, r6
      incf32 r6, r7, 0x12
      inct32 r7, r6, 0x03
      movi r2,0x1
      movi r3,0x1
      ixh32 r6, r7, r2
      ixw32 r7, r6, r3
      lrw r8,0x26
      cmpne r8, r7
      bt  __fail
      lrw r4,__jmp_label
      jmp r4
__jmp_label:
      lrw r15,__jmp15_label
      jmp r15
__jmp15_label:
      lrw r4,__jsr_label
      jsr r4
__jsr_label:
      movi r5, 0x20
      movi r4, 0x0
__lsl16_label:
      lsl16 r0, r4
      addi r4, 0x1
      cmpne r4, r5
      bt  __lsl16_label
      lsl32 r7, r3, r1
      lslc32 r6, r7, 0xc
      lsli16 r7, r6, 0xa
      lsli32 r4, r3, 0x1
      lsr16 r6, r7
      lsr32 r3, r4, r1
      lsrc32 r7, r6, 0x1f
      lsri16 r6, r7, 0x15
      lsri32 r4, r3, 0xa
      movi32 r5, 0xffff
      movih32 r3, 0xffff
      mult16 r6, r5
      mult32 r1, r3, r4
      mvc r3
      mvcv16 r4
      mvcv16 r4
      nor16 r1, r6
      nor32 r2, r4, r3
      or16 r6, r1
      or32 r4, r2, r6
      ori32 r7, r6, 0xaa
      cmpne r7, r1
      bt  __fail
push_pop:
      lrw sp,SPEC_ADDR
      push r4-r11,r15
      lrw r15,__pop_r15_label
      push r15
      pop r15
__pop_r15_label:
      lrw r15,__pop_r4_r7_label
      pop r4-r5
__pop_r4_r7_label:
      lrw r15,__pop_r4_label
      pop r4
__pop_r4_label:
      revb16 r1, r8
      revb16 r6, r1
      revh16 r7, r6
      revh16 r6, r7
      rotl16 r7, r6
      rotl32 r4, r7, r0
      rotli32 r7, r4, 0xa
      sextb16 r4, r7
      sexth16 r6, r7
      subc16 r6, r4
      subc32 r4, r6, r0
      subi16 r5, 0x24
      subi16 r4, r5, 0x01
      subi32 r4, r4, 0xfff
      subi16 sp, sp, 0x58
      subu16 r1, r4, r0
      subu16 r7, r1
      subu32 r4, r7, r5
      lrw r6, 0xfffe104a
      cmpne r4, r6
      bt  __fail
      sync
      trap 0
      trap 1
      trap 2
      trap 3
      movi r1, 0xa
      tst16 r4, r0
      tstnbz16 r2
      tstnbz16 r3
      xor16 r6, r4
      xor32 r4, r6, r2
      xori32 r7, r4, 0xaaa
      xsr32 r6, r7, 0x8
      xtrb0 r7, r6
      xtrb1 r7, r6
      xtrb2 r6, r7
      xtrb3 r7, r6
      zextb16 r5, r6
      zexth16 r4, r7
      cmpnei16 r4, 0
      bt  __fail
      cmpnei32 r5, 0
      bt  __fail
set_psr_mm_sd:
      mfcr r1,cr<0,0>
      bseti r1,0x9
      bseti r1,26
      mtcr r1,cr<0,0>
ld_st_instruction:
      lrw r1, 0x40000
      movi r2, 0x8
      movi r4, 0x0
stb_ldb_instruction:
      st.b r2,(r1,0)
      st.b r2,(r1,1)
      st.b r2,(r1,2)
      st.b r2,(r1,3)
      ld.b r2,(r1,0)
      ld.b r2,(r1,1)
      ld.b r2,(r1,2)
      ld.b r2,(r1,3)
      ld.w r2,(r1,0)
      lrw r3,0x08080808
      cmpne r2,r3
      bt  __fail
sth_ldh_instruction:
      st.h r2,(r1,0)
      st.h r2,(r1,2)
      ld.h r3,(r1,0)
      ld.h r4,(r1,2)
      cmpnei r3,0x0808
      bt  __fail
      cmpnei r4,0x0808
      bt  __fail
unalign_store:
      lrw r1, 0x40000
      lrw r2,0x12345678
      st.w r2,(r1,0)
      st.w r2,(r1,4)
      lrw r3,0x87654321
      lrw r8,0x40001
      st.w r3,(r8,0)
      ld.w r4,(r8,0)
      cmpne r3,r4
      bt  __fail
      lrw r8,0x40002
      st.w r3,(r8,0)
      ld.w r4,(r8,0)
      cmpne r3,r4
      bt  __fail
      lrw r8,0x40003
      st.w r3,(r8,0)
      ld.w r4,(r8,0)
      cmpne r3,r4
      bt  __fail
ldh_sth_unalign:
      lrw r1, 0x40000
      lrw r2,0x12345678
      st.w r2,(r1,0)
      st.w r2,(r1,4)
      lrw r3,0x8765
      lrw r8,0x40001
      st.h r3,(r8,0)
      ld.h r4,(r8,0)
      cmpne r3,r4
      bt  __fail
      lrw r8,0x40002
      st.h r3,(r8,0)
      ld.h r4,(r8,0)
      cmpne r3,r4
      bt  __fail
      lrw r8,0x40003
      st.h r3,(r8,0)
      ld.h r4,(r8,0)
      cmpne r3,r4
      bt  __fail
ldb_stb_aualign:
      lrw r1, 0x40000
      lrw r2,0x12345678
      st.w r2,(r1,0)
      st.w r2,(r1,4)
      lrw r3,0xab
      lrw r8,0x40001
      st.b r3,(r8,0)
      ld.b r4,(r8,0)
      cmpne r3,r4
      bt  __fail
      lrw r8,0x40002
      st.b r3,(r8,0)
      ld.b r4,(r8,0)
      cmpne r3,r4
      bt  __fail
      lrw r8,0x40003
      st.b r3,(r8,0)
      ld.b r4,(r8,0)
      cmpne r3,r4
      bt  __fail
set_clr_mm:
      mfcr r1,cr<0,0>
      bclri r1,0x9
      mtcr r1,cr<0,0>
system_bus_addres_access:
      lrw r1,BASE_ADDR
      lrw r2,0x1234aaaa
      st.w r2,(r1,0)
      ld.w r3,(r1,0)
      cmpne r2,r3
      bt  __fail
illegial_isnt:
      lrw r1,0x3f800000
      lrw r2,0x8000
      st.w r1,(r2,0)
      .short 0x3f80
      .short 0x3f80
      lrw r2,0x8000
      lrw r1,0x40000000
      st.w r1,(r2,0)
st_ld_instruction:
      lrw r1, 0x40000
      lrw r2, 0x12349988
      st16.w r2, (sp,0)
      ld16.w r3, (sp,0)
      st32.w r3, (r1,0)
      ld32.w r2, (r1,0)
      st16.h r2, (r1,0)
      ld16.h r3, (r1,0)
      st32.h r3, (r1,0)
      ld32.h r2, (r1,0)
      ld.hs r4, (r1,0)
      lrw r6, 0xffff9988
      cmpne r4, r6
      bt  __fail
      st16.b r2, (r1,0)
      ld16.b r3, (r1,0)
      st32.b r3, (r1,0)
      ld32.b r2, (r1,0)
      cmpnei r2, 0x88
      bt  __fail
      ld.bs r5, (r1,0)
      lrw r6, 0xffffff88
      cmpne r5, r6
      bt  __fail
stm_ldm_instruction:
      lrw r2,0x88
      lrw r3,0x88
      stm r2-r3, (r1)
      ldm r4-r5, (r1)
      cmpnei r4, 0x88
      bt  __fail
      cmpnei r5, 0x88
      bt  __fail
div_inst:
      lrw r1, 0x20000000
      lrw r4, 0x12345678
branch_pass:
      mov r0,r0
#ifdef MGU
close_mgu1:
      movi r1,0x0
      mtcr r1,cr<18,0>
      lrw r10,0xffffff00
      mtcr r10,cr<19,0>
      mfcr r1,cr<19,0>  
      lrw  r2,MGU_CAPR_MASK
      and  r10,r2           //mgu capr set according with mgu number
      cmpne r1,r10
      bt  __fail
      movi r1,0x3
      mtcr r1,cr<21,0>
      mfcr r1,cr<21,0>
      cmpnei r1,0x3
      bt  __fail
      movi r2,0x3f
      mtcr r2,cr<20,0>
      mfcr r1,cr<20,0>
      cmpnei r1,0x3f
      bt  __fail
      movi r1,0x0
set_mgu0_mgu7:
      movi r2,0xd
set_mgu_size:
      mtcr r1,cr<21,0>
      mtcr r2,cr<20,0>
      mfcr r3,cr<20,0>
      cmpne r2,r3
      bt  __fail
      addi r2,0x2
      cmpnei r2,0x41
      bt  set_mgu_size
      addi r1,0x1
      cmpnei r1,0x8
      bt  set_mgu0_mgu7
set_mgu_primision:
      lrw r10,0xfe5555fe
      lrw r9, 0x0
      mtcr r10,cr<19,0>
      mfcr r11,cr<19,0>
      lrw  r2,MGU_CAPR_MASK
      and  r10,r2           //mgu capr set according with mgu number
      cmpne r11,r10
      bt  __fail
      lrw r10,0xfeaaaafe
      lrw r9, 0x0
      mtcr r10,cr<19,0>
      mfcr r11,cr<19,0>
      lrw  r2,MGU_CAPR_MASK
      and  r10,r2           //mgu capr set according with mgu number
      cmpne r11,r10
      bt  __fail
      lrw r10,0xfeff3ffe
      lrw r9, 0x0
      mtcr r10,cr<19,0>
      mfcr r11,cr<19,0>
      lrw  r2,MGU_CAPR_MASK
      and  r10,r2           //mgu capr set according with mgu number
      cmpne r11,r10
      bt  __fail
      movi r1,0x0
      lrw r3,0x0
      lrw r4,0x20000000
      lrw r5,0x17
set_mgu_region:
      mtcr r1,cr<21,0>
      lrw r2,0x39
      add r2,r3
      mtcr r2,cr<20,0>
      add r3,r4
      addi r1,0x1
      cmpnei r1,0x8
      bt  set_mgu_region

set_mgu_region0_accsuccess:
      movi r1,0x0
      mtcr r1,cr<21,0>
      lrw r2,0x00000021  //mgu region 0 128K access ok
      mtcr r2,cr<20,0>
      mfcr r2,cr<19,0>   //read mgu premision
      lrw  r1,0x01000300 //set mgu 0 premision exe,rW,cacheable
      or   r2,r1
      lrw  r1,0x00ffffff 
      and  r2,r1         //remove cache premision
      mtcr r2,cr<19,0>   //read mgu premision

set_mgu_region3_accerr:
      movi r1,0x3
      mtcr r1,cr<21,0>
      lrw r2,0x20001013
      mtcr r2,cr<20,0>
      mfcr r1,cr<18,0>
      bseti r1,0
      bclri r1,1
      mtcr r1,cr<18,0>
      movi r1, 0x8000
      movi r2, 0x777
      st.w r2, (r1,0)
      ld.w r3, (r1,0)
      cmpnei r3, 0x777
      bt  __fail


check_access_err:
      lrw r1, 0x20001000
      movi r2, 0x777
      st16.w r2, (r1,0)
      cmpnei r3, 0xacc
      bt  __fail
#ifdef CSKY_TEE
wsc_to_unsec_accerr:
      lrw r12,unsec_world_3
      lrw r13, 0x0
      st.w r12,(r13,0x0)
      .short 0xc000
      .short 0x3c20
      br  go_back_3
unsec_world_3:
      movi r3,0x0
      lrw r1, 0x20001000
      movi r2, 0x777
      st16.w r2, (r1,0)
      cmpnei r3, 0xacc
      bt  __fail
      rte
go_back_3:
#endif

close_mgu:
      movi r1,0
      mtcr r1,cr<18,0>
      movi r1,0x0
      movi r2,0x0
close_mgu_entry:
      mtcr r1,cr<21,0>
      mtcr r2,cr<20,0>
      addi r1,0x1
      cmpnei r1,0x8
      bt  close_mgu_entry
set_mgu_entry_one_by_one:
      lrw r10,0xffffff00
      mtcr r10,cr<19,0>
      movi r1,0x0
      mtcr r1,cr<21,0>
      movi r1,0x3f
      mtcr r1,cr<20,0>
      mfcr r1,cr<18,0>
      bseti r1,0
      bclri r1,1
      mtcr r1,cr<18,0>
      lrw r1,0x08000000
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt  __fail
      movi r1,0x1
      mtcr r1,cr<21,0>
      movi r2,0x3f
      mtcr r2,cr<20,0>
      movi r1,0x0
      mtcr r1,cr<21,0>
      movi r2,0x0
      mtcr r2,cr<20,0>
      lrw r1,0x08000000
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt  __fail
      movi r1,0x2
      mtcr r1,cr<21,0>
      movi r2,0x3f
      mtcr r2,cr<20,0>
      movi r1,0x1
      mtcr r1,cr<21,0>
      movi r2,0x0
      mtcr r2,cr<20,0>
      lrw r1,0x08000000
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt  __fail
      movi r1,0x3
      mtcr r1,cr<21,0>
      movi r2,0x3f
      mtcr r2,cr<20,0>
      movi r1,0x2
      mtcr r1,cr<21,0>
      movi r2,0x0
      mtcr r2,cr<20,0>
      lrw r1,0x08000000
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt  __fail
      movi r1,0x4
      mtcr r1,cr<21,0>
      movi r2,0x3f
      mtcr r2,cr<20,0>
      movi r1,0x3
      mtcr r1,cr<21,0>
      movi r2,0x0
      mtcr r2,cr<20,0>
      lrw r1,0x08000000
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt  __fail
      movi r1,0x5
      mtcr r1,cr<21,0>
      movi r2,0x3f
      mtcr r2,cr<20,0>
      movi r1,0x4
      mtcr r1,cr<21,0>
      movi r2,0x0
      mtcr r2,cr<20,0>
      lrw r1,0x08000000
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt  __fail
      movi r1,0x6
      mtcr r1,cr<21,0>
      movi r2,0x3f
      mtcr r2,cr<20,0>
      movi r1,0x5
      mtcr r1,cr<21,0>
      movi r2,0x0
      mtcr r2,cr<20,0>
      lrw r1,0x08000000
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt  __fail
      movi r1,0x7
      mtcr r1,cr<21,0>
      movi r2,0x3f
      mtcr r2,cr<20,0>
      movi r1,0x6
      mtcr r1,cr<21,0>
      movi r2,0x0
      mtcr r2,cr<20,0>
      lrw r1,0x08000000
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt  __fail
      movi r1,0
      mtcr r1,cr<18,0>
#endif
#ifdef CACHE
modify_memory:
      movi r1, 0x8000
      movi r3, 0x888
      st16.w r3, (r1,0x0)
      st16.w r3, (r1,0x4)
      st16.w r3, (r1,0x8)
      st16.w r3, (r1,0xc)
      st16.w r3, (r1,0x10)
      st16.w r3, (r1,0x14)
      st16.w r3, (r1,0x18)
      st16.w r3, (r1,0x1c)
      st16.w r3, (r1,0x20)
      st16.w r3, (r1,0x24)
      st16.w r3, (r1,0x28)
      st16.w r3, (r1,0x2c)
      lrw r1, 0x20008000
      movi r3, 0x888
      st16.w r3, (r1,0x0)
      st16.w r3, (r1,0x4)
      st16.w r3, (r1,0x8)
      st16.w r3, (r1,0xc)
set_crcr0_crcr3_for_cov:
      lrw r3,0xe000f008
      movi r1,0x0
      movi r2,0x17
      #ifdef CSKY_TEE
      movi r2,0x57
      #endif
set_crcr_size:
      st.w r2,(r3,0x0)
      st.w r2,(r3,0x4)
      st.w r2,(r3,0x8)
      st.w r2,(r3,0xc)
      ld.w r4,(r3,0x0)
      cmpne r2,r4
      bt  __fail
      addi r2,0x2
      #ifdef CSKY_TEE
      cmpnei r2,0x81
      #endif
      bt  set_crcr_size
cache_test:
      movi r1,0x1
      lrw r2,0xe000f000
      st.w r1,(r2,0x0)
      st.w r1,(r2,4)
      movi r3,0x3f
      #ifdef CSKY_TEE
      movi r3,0x7f
      #endif
      st.w r3,(r2,0x8)
      st.w r3,(r2,0xc)
      st.w r3,(r2,0x10)
      st.w r3,(r2,0x14)
cache_cannot_write:
      movi r1, 0x8000
      movi r3, 0x777
      ld.w r4, (r1,0x10)
      st.w r3, (r1,0x10)
      ld.w r4, (r1,0x20)
      st.w r3, (r1,0x20)
      ld.w r4, (r1,0)
      st.w r3, (r1,0)
      ld.w r4, (r1,0)
      cmpnei r4,0x888
      bt  __fail
dlite_memory_uncacheable:
      lrw r1, 0x20008000
      movi r3, 0x777
      ld.w r4, (r1,0)
      st.w r3, (r1,0)
      ld.w r4, (r1,0)
      cmpnei r4,0x777
      bt  __fail
      lrw r2,0xe000f000
      movi r1,0x0
      st.w r1,(r2,0x0)
      movi r1, 0x8000
      ld.w r4, (r1,0)
      cmpnei r4,0x777
      bt  __fail
cache_inv_one:
      movi r1,0x1
      lrw r2,0xe000f000
      st.w r1,(r2,0x0)
      lrw r1,0x8002
      st.w r1,(r2,0x4)
      lrw r1, 0x8000
      ld16.w r3, (r1,0)
      cmpnei r3,0x777
      bt  __fail
cache_inv_all:
      lrw r1,1
      lrw r2,0xe000f000
      st.w r1,(r2,0x4)
      lrw r1, 0x8000
      ld16.w r3, (r1,0x10)
      cmpnei r3,0x777
      bt  __fail
      ld16.w r3, (r1,0x20)
      cmpnei r3,0x777
      bt  __fail
      lrw r1,0
      st.w r1,(r2,0x0)
#endif
int_test:
      lrw r1,0xffffffff
      lrw r2,0xE000E180
      lrw r3,0xE000E100
      st.w r1,(r3,0x0)
      st.w r1,(r2,0x0)
      lrw r4,0xffffffff
      st.w r4,(r3,0x0)
      movi r2,0x0
      lrw r8,0x00000000
      lrw r9,0xE000E400
int_priority_cov:
      st.w r8,(r9,0x0)
      st.w r8,(r9,0x4)
      st.w r8,(r9,0x8)
      st.w r8,(r9,0xc)
      st.w r8,(r9,0x10)
      st.w r8,(r9,0x14)
      st.w r8,(r9,0x18)
      st.w r8,(r9,0x1c)
      lrw r3,0x40404040
      add r8,r3
      addi r2,0x1
      cmpnei r2,0x4
      bt  int_priority_cov
      lrw r8,0x004080c0
      st.w r8,(r9,0x0)
      st.w r8,(r9,0x4)
      movi r1,0xf0
      lrw r8,0xE000E240
      st.w r1,(r8,0x0)
      lrw r1,0xffffffff
      lrw r8,0xE000E1C0
      lrw r9,0xE000E140
      st.w r1,(r8,0x0)
      st.w r1,(r9,0x0)
int0_int7:
      lrw r1,0xff
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      st.w r1,(r2,0x0)
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
      lrw r1,BASE_ADDR
      ld.w r2,(r1,0)
      cmpnei r2,65
      bt  __fail
      ld.w r2,(r1,0xc)
      cmpnei r2,74
      bt  __fail
      lrw r1,BASE_ADDR
      movi r4,0x0
      st.w r4,(r1,0x20)
      lrw r1,0x100
      movi r4,0x0
int8_int31_test:
      lrw r2,0xE000E280
      lrw r3,0xE000E200
      st.w r1,(r2,0x0)
      st.w r1,(r3,0x0)
      mov r0,r0
      lsli r1,0x1
      addi r4,0x1
      cmpnei r4,INT_NUMBER - 8
      bt  int8_int31_test
      lrw r1,BASE_ADDR
      ld.w r2,(r1,0x20)
      cmpnei r2,INT_NUMBER - 8
      bt  __fail
#ifdef TSPEND
tspending_test:
      lrw r0,0xe000ec10
      lrw r1,0x3
      st.w r1,(r0,0)
      lrw r0,0xe000ec08
      lrw r1,0x1
      st.w r1,(r0,0)
      mov r0,r0
      mov r0,r0
      lrw r1,0x8000
      ld.w r2,(r1,0)
      cmpnei r2,22
      bt  __fail
#endif 
      #ifdef CSKY_TEE
sec_int_in_unsec_world:
      lrw r12,unsec_world_4
      lrw r13, 0x0
      st.w r12,(r13,0x0)
      .short 0xc000
      .short 0x3c20
      br  go_back_4
unsec_world_4:
      lrw r1,0x20
      lrw r3,0xE000E200
      st.w r1,(r3,0x0)
      mov r0,r0
      mov r0,r0
      mov r0,r0
      lrw r1,0x20000000
      ld.w r0,(r1,0x14)
      cmpnei r0,37
      bt  __fail
      rte
go_back_4:
      #endif
      lrw r1,0xffffffff
      lrw r2,0xE000E180
      st.w r1,(r2,0x0)
      movi r5,0x0
//set_coretimer:
//      lrw r1,0xE000E010
//      movi r2,0x50
//      st.w r2,(r1,4)
//      st.w r2,(r1,8)
//      ld.w r2,(r1,4)
//      cmpnei r2,0x50
//      bt  __fail
//      movi r2,0x7
//      st.w r2,(r1,0)
//      ld.w r2,(r1,0)
//      cmpnei r2,0x7
//      bt  __fail
//      addi r5,0x1
//inst_wait:
//      cmpnei r5,0x1
//      bt  inst_doze
//      wait
//      lrw r2,0xE000E280
//      movi r1,0x1
//      st.w r1,(r2,0x0)
//      br  set_coretimer
//inst_doze:
//      cmpnei r5,0x2
//      bt  inst_stop
//      doze
//      lrw r2,0xE000E280
//      movi r1,0x1
//      st.w r1,(r2,0x0)
//      br  set_coretimer
//inst_stop:
//      cmpnei r5,0x3
//      bt  lpmd_end
//      stop
//      lrw r2,0xE000E280
//      movi r1,0x1
//      st.w r1,(r2,0x0)
//      br  set_coretimer
//lpmd_end:
//      movi r2,0x0
//      st.w r2,(r1,0)
group0_cr_test:
      lrw r1,0x00000000
      mtcr r1,cr<1,0>
      mfcr r2,cr<1,0>
      cmpne r1,r2
      bt  __fail

      mtcr r1,cr<13,0>//cpu id read and write
      mfcr r2,cr<13,0>

      mfcr r3,cr<2,0>
      mov r2,r3
      bclri r2,0x6
      bclri r2,0x8
      mtcr r2,cr<2,0>
      mfcr r2,cr<2,0>
      subu r3,r2
      cmpnei r3,0x140
      bt  __fail
      lrw r1,0x80000000
      mtcr r1,cr<4,0>
      mfcr r2,cr<4,0>
      cmpne r1,r2
      bt  __fail
      mfcr r3,cr<31,0>
      mov r2,r3
      bclri r2,0x4
      mtcr r2,cr<31,0>
      mfcr r2,cr<31,0>
      subu r3,r2
      cmpnei r3,0x10
      bt  __fail
#ifdef CSKY_TEE
      //group 3 register only vaild in tee
      br  group3_cr_check
      .align 4
group3_cr_check:
      movi r2,0x240
      mtcr r2,cr<0,3>
      mfcr r3,cr<0,3>
      cmpnei r3,0x240
      bt  __fail
      mfcr r3,cr<1,3>
      cmpnei r3,0x0
      bt  __fail
      mfcr r3,cr<10,3>
      cmpnei r3,0x0
      bt  __fail
      movi r2,0x240
      mtcr r2,cr<2,3>
      mfcr r3,cr<2,3>
      cmpnei r3,0x240
      bt  __fail
      movi r2,0x240
      mtcr r2,cr<4,3>
      mfcr r3,cr<4,3>
      cmpnei r3,0x240
      bt  __fail
      movi r2,0x22
      mtcr r2,cr<8,3>
      mfcr r3,cr<8,3>
      cmpnei r3,0x2
      bt  __fail
      movi r2,0x1
      mtcr r2,cr<8,3>
      mfcr r3,cr<8,3>
      cmpnei r3,0x1
      bt  __fail
#endif
#ifdef CSKY_TEE
//tcipif access had reg need tee
had_reg_test:
      lrw r2,0xee
      lrw r1,0xe0011010
all_had_reg_test:
      st.w r2,(r1,0)
      ld.w r3,(r1,0)
      cmpne r2,r3
      bt  __fail
      st.w r2,(r1,4)
      ld.w r3,(r1,4)
      cmpne r2,r3
      bt  __fail
      st.w r2,(r1,0xc)
      ld.w r3,(r1,0xc)
      cmpne r2,r3
      bt  __fail
      st.w r2,(r1,0x10)
      ld.w r3,(r1,0x10)
      cmpne r2,r3
      bt  __fail
      st.w r2,(r1,0x14)
      ld.w r3,(r1,0x14)
      cmpne r2,r3
      bt  __fail
      st.w r2,(r1,0x18)
      ld.w r3,(r1,0x18)
      cmpne r2,r3
      bt  __fail
bank0_ctl_reg:
      lrw r2,0x80000140
      st.w r2,(r1,0x38)
      ld.w r3,(r1,0x38)
      cmpne r2,r3
      bt  __fail
#endif

#ifdef DBG_EXP
inst_bkpt_debug_exception_a_to_i:
      psrset ee
      lrw r1,0x1
      mtcr r1,cr<8,3>
      #ifdef CSKY_TEE
      lrw r1,0x3
      mtcr r1,cr<8,3>
      #endif

mem_bkptb_test:
      lrw r0,0xe0011034
      lrw r1,0xc0
      st.w r1,(r0,0)
      lrw r0,0xe0011020
      lrw r1, 0x8000
      st.w r1,(r0,0)
      lrw r0,0xe0011028
      lrw r1,0xff
      st.w r1,(r0,0)
      lrw r0,0xe0011014
      lrw r1,0x0
      st.w r1,(r0,0)
      lrw r0,0xe0011054
      lrw r1,0xc0
      st.w r1,(r0,0)
      mov r0,r0
      lrw r12,0x1111
      lrw r1,0x8000
      lrw r15,mem_bkpt_a
      addi r15,0x4
mem_bkpt_a:
      st32.w r1,(r1,0)
      mov    r0,r0
      mov    r0,r0
      mov    r0,r0
      cmpnei r12,0x7777
      bt  __fail
      lrw r0,0xe0011034
      lrw r1,0x1fc00082
      st.w r1,(r0,0)
      lrw r0,0xe001101c
      lrw r1,instbkpt_a
      st.w r1,(r0,0)
      lrw r0,0xe0011024
      lrw r1,0xff
      st.w r1,(r0,0)
      lrw r0,0xe0011010
      lrw r1,0x0
      st.w r1,(r0,0)
      lrw r0,0xe0011020
      lrw r1,instbkpt_b
      st.w r1,(r0,0)
      lrw r0,0xe0011028
      lrw r1,0xff
      st.w r1,(r0,0)
      lrw r0,0xe0011014
      lrw r1,0x0
      st.w r1,(r0,0)
      lrw r0,0xe0011080
      lrw r1,instbkpt_c
      st.w r1,(r0,0)
      lrw r0,0xe0011084
      lrw r1,0xff
      st.w r1,(r0,0)
      lrw r0,0xe0011088
      lrw r1,instbkpt_d
      st.w r1,(r0,0)
      lrw r0,0xe001108c
      lrw r1,0xff
      st.w r1,(r0,0)
      lrw r0,0xe0011090
      lrw r1,instbkpt_e
      st.w r1,(r0,0)
      lrw r0,0xe0011094
      lrw r1,0xff
      st.w r1,(r0,0)
      lrw r0,0xe0011098
      lrw r1,instbkpt_f
      st.w r1,(r0,0)
      lrw r0,0xe001109c
      lrw r1,0xff
      st.w r1,(r0,0)
      lrw r0,0xe00110a0
      lrw r1,instbkpt_g
      st.w r1,(r0,0)
      lrw r0,0xe00110a4
      lrw r1,0xff
      st.w r1,(r0,0)
      lrw r0,0xe00110a8
      lrw r1,instbkpt_h
      st.w r1,(r0,0)
      lrw r0,0xe00110ac
      lrw r1,0xff
      st.w r1,(r0,0)
      lrw r0,0xe00110b0
      lrw r1,instbkpt_i
      st.w r1,(r0,0)
      lrw r0,0xe00110b4
      lrw r1,0xff
      st.w r1,(r0,0)
      lrw r0,0xe0011054
      lrw r1,0xc0
      st.w r1,(r0,0)
      lrw r12,0x1111
      lrw r15,instbkpt_a
instbkpt_a:
      cmpnei r12,0x7777
      bt  __fail
      lrw r0,0xe0011054
      lrw r1,0xc0
      st.w r1,(r0,0)
      lrw r12,0x1111
      lrw r15,instbkpt_b
instbkpt_b:
      cmpnei r12,0x7777
      bt  __fail
      lrw r0,0xe0011054
      lrw r1,0xc0
      st.w r1,(r0,0)
      lrw r12,0x1111
      lrw r15,instbkpt_c
instbkpt_c:
      lrw r0,0xe00110ec
      ld.w r1,(r0,0)
      cmpnei r1,0x3
      bt  __fail
      cmpnei r12,0x7777
      bt  __fail
      lrw r0,0xe0011054
      lrw r1,0xc0
      st.w r1,(r0,0)
      lrw r15,instbkpt_d
      lrw r12,0x1111
instbkpt_d:
      lrw r0,0xe00110ec
      ld.w r1,(r0,0)
      cmpnei r1,0x4
      bt  __fail
      cmpnei r12,0x7777
      bt  __fail
      lrw r0,0xe0011054
      lrw r1,0xc0
      st.w r1,(r0,0)
      lrw r15,instbkpt_e
      lrw r12,0x1111
instbkpt_e:
      lrw r0,0xe00110ec
      ld.w r1,(r0,0)
      cmpnei r1,0x5
      bt  __fail
      cmpnei r12,0x7777
      bt  __fail
      lrw r0,0xe0011054
      lrw r1,0xc0
      st.w r1,(r0,0)
      lrw r15,instbkpt_f
      lrw r12,0x1111
instbkpt_f:
      lrw r0,0xe00110ec
      ld.w r1,(r0,0)
      cmpnei r1,0x6
      bt  __fail
      cmpnei r12,0x7777
      bt  __fail
      lrw r0,0xe0011054
      lrw r1,0xc0
      st.w r1,(r0,0)
      lrw r15,instbkpt_g
      lrw r12,0x1111
instbkpt_g:
      lrw r0,0xe00110ec
      ld.w r1,(r0,0)
      cmpnei r1,0x7
      bt  __fail
      cmpnei r12,0x7777
      bt  __fail
      lrw r0,0xe0011054
      lrw r1,0xc0
      st.w r1,(r0,0)
      lrw r15,instbkpt_h
      lrw r12,0x1111
instbkpt_h:
      lrw r0,0xe00110ec
      ld.w r1,(r0,0)
      cmpnei r1,0x8
      bt  __fail
      cmpnei r12,0x7777
      bt  __fail
      lrw r0,0xe0011054
      lrw r1,0xc0
      st.w r1,(r0,0)
      lrw r15,instbkpt_i
      lrw r12,0x1111
instbkpt_i:
      lrw r0,0xe00110ec
      ld.w r1,(r0,0)
      cmpnei r1,0x9
      bt  __fail
      cmpnei r12,0x7777
      bt  __fail
#endif


#ifdef CSKY_TEE
//tcipif access had reg need tee

      lrw r0,0xe0011034
      lrw r1,0x00
bkpt_type_cov:
      st.w r1,(r0,0)
      addi r1,0x41
      cmpnei r1,0x820
      bt  bkpt_type_cov
#endif

bseti_cov:
      lrw r0,0
      bseti r0,0
      cmpnei r0,0x1
      bt  __fail
      bseti r0,0
      bseti r0,1
      bseti r0,2
      bseti r0,3
      bseti r0,4
      bseti r0,5
      bseti r0,6
      bseti r0,7
      bseti r0,8
      bseti r0,9
      bseti r0,10
      bseti r0,11
      bseti r0,12
      bseti r0,13
      bseti r0,14
      bseti r0,15
      bseti r0,16
      bseti r0,17
      bseti r0,18
      bseti r0,19
      bseti r0,20
      bseti r0,21
      bseti r0,22
      bseti r0,23
      bseti r0,24
      bseti r0,25
      bseti r0,26
      bseti r0,27
      bseti r0,28
      bseti r0,29
      bseti r0,30
      bseti r0,31
      lrw r1,0xffffffff
      cmpne r0,r1
      bt  __fail
      lrw r1,1
#ifdef CSKY_TEE
had_reg_bank1:
      lrw r2,0xee
      lrw r1,0xe0011080
      lrw r4,0xe00110b8
#ifdef HAD_MBKPT_9
set_bkptc_bkpti:
      st.w r2,(r1,0)
      ld.w r3,(r1,0)
      cmpne r2,r3
      bt  __fail
      addi r1,0x4
      cmpne r4,r1
      bt  set_bkptc_bkpti
#endif
#endif
__success:
      br  __exit
      .align 2
      .data
SRS_BASE:
SRS_1:
      mov r0,r0
      mov r0,r0
SRS_2:
      mov r0,r0
      mov r0,r0
SRS_3:
      mov r0,r0
      mov r0,r0
//******this region is added by generator******

