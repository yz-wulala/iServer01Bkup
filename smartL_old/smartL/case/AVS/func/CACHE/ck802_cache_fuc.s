// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : zhaor
// CSKYCPU    : 802 
// HWCFIG     : CACHE
// SMART_R    : yes 
// FUNCTION   : cache can read can't write 
// METHOD     : 
// NOTE       : 
// ****************************************************************************
.text
.align 1
.export main

main:

      //.set IBUS_ADDR,0x0                 //set IBUS address 
      .set IBUS_CACHEABLE_ADDR, IBUS_ADDR + 0x1000       //set cacheale address
      .set IBUS_UCACHEABLE_ADDR, IBUS_ADDR + 0x1000 + 0x400  //uncacheaable address


.macro EXIT
     lrw	r15, __exit
     jmp	r15
.endm

.macro FAIL
     lrw	r15, __fail 
     jmp	r15
.endm  

.macro CACHE_INV_IN
  subi sp, sp, 4
  st.w r1, (sp,0)
  subi sp, sp, 4
  st.w r2, (sp,0)

  lrw r1, 0xe000f004
  ld.w r2, (r1, 0x0)
  bseti r2, 0x0
  st.w r2, (r1,0)

  ld.w r2, (sp,0)
  addi sp, sp, 4
  ld.w r1, (sp,0)
  addi sp, sp, 4
.endm

.macro CACHE_EN_IN
  subi sp, sp, 4
  st.w r1, (sp,0)
  subi sp, sp, 4
  st.w r2, (sp,0)

  lrw  r1, 0xe000f000
  ld.w r2, (r1,0)
  bseti r2, 0   // enable and clear cifg
  bclri r2, 1   // enable and clear cifg
  st.w r2, (r1,0)
  ld.w r2, (sp,0)
  addi sp, sp, 4
  ld.w r1, (sp,0)
  addi sp, sp, 4
.endm

//cache enable set crcr0
      CACHE_INV_IN
      CACHE_EN_IN
      lrw r1, 0xe000f000
      lrw r3, IBUS_CACHEABLE_ADDR
      addi r3,0x13               //set crcr size 1K 
      .ifdef CSKY_TEE
      lrw r3, IBUS_CACHEABLE_ADDR
      addi r3,0x53              //set crcr size 1K 
      .endif
      st.w r3, (r1,0x8)         //set crcr0
      lrw r1, IBUS_CACHEABLE_ADDR
      lrw r2, IBUS_UCACHEABLE_ADDR
      add r3, r1,r1
      add r4, r1,r2
      add r5, r3,r1
      add r6, r3,r2
      add r7, r5,r1
      add r8, r5,r2
      lrw r9, 0x11223344
      lrw r10, 0x0
REGION0_0:
      st.w r10, (r1,0x0)  //write memory
      st.w r10, (r2,0x0)  //write memory
      ld.w r11, (r1,0x0)  //load data to cache
      ld.w r11, (r2,0x0)
      st.w r9, (r1,0x0)   //modify cache
      st.w r9, (r2,0x0)   //modify memory
      ld.w r11, (r1,0x0)
//check modify cache fail
      cmpne r11,r10
      bt  TEST_FAIL
//check modify memory success
      ld.w r12, (r2,0x0)
      cmpne r12, r9
      bt  TEST_FAIL
//address IBUS_UCACHEABLE_ADDR -4 cacheable 
      subi r11, r2, 0x4
      st.w r10, (r11,0x0)
      ld.w r10, (r11,0x0)
      st.w r9, (r11,0x0)
      ld.w r11, (r11,0x0)
      cmpne r11,r10
      bt  TEST_FAIL
//close cache
      lrw r1, 0xe000f000
      lrw r2, 0x0
      st.w r2, (r1,0x0)
//set crcr0 1K
      lrw r3, IBUS_CACHEABLE_ADDR
      addi r3,0x53              //set crcr size 1K
      st.w r3, (r1,0x8)
      lrw r1, IBUS_CACHEABLE_ADDR
      lrw r2, IBUS_UCACHEABLE_ADDR
      add r3, r1,r1
      add r4, r1,r2
      add r5, r3,r1
      add r6, r3,r2
      add r7, r5,r1
      add r8, r5,r2
      lrw r9, 0x11223344
      lrw r10, 0x0
REGION0_1:
      st.w r10, (r1,0x0) //write memory
      st.w r10, (r2,0x0)
      ld.w r11, (r1,0x0) //load memory
      ld.w r11, (r2,0x0)
      st.w r9, (r1,0x0) //modify momory
      st.w r9, (r2,0x0)
      ld.w r11, (r1,0x0)
//modify meomory success
      cmpne r11,r9
      bt  TEST_FAIL
//modify memory success
      ld.w r12, (r2,0x0)
      cmpne r12, r9
      bt  TEST_FAIL
//Ucacheable address -4 uncacheable
      subi r11, r2, 0x4
      st.w r10, (r11,0x0)
      ld.w r10, (r11,0x0)
      st.w r9, (r11,0x0)
      ld.w r11, (r11,0x0)
//uncacheable modify memory success
      cmpne r11,r9
      bt  TEST_FAIL
      CACHE_INV_IN
      CACHE_EN_IN
      lrw r1, 0xe000f000
      lrw r3, IBUS_CACHEABLE_ADDR
      addi r3,0x52              //set crcr size 1K,but not enable
      st.w r3, (r1,0x8)
      lrw r1, IBUS_CACHEABLE_ADDR
      lrw r2, IBUS_UCACHEABLE_ADDR
      lrw r9, 0x11223344
      lrw r10, 0x0
REGION0_2:
      st.w r10, (r1,0x0) //modify memory
      st.w r10, (r2,0x0)
      ld.w r11, (r1,0x0) //load to cache
      ld.w r11, (r2,0x0)
      st.w r9, (r1,0x0)  //cacheable fail modify mormory 
      st.w r9, (r2,0x0)  //modify memory
      ld.w r11, (r1,0x0)
//crcr0 not enable modify memory success
      cmpne r11,r9
      bt  TEST_FAIL
      ld.w r12, (r2,0x0)
      cmpne r12, r9
      bt  TEST_FAIL
//ucacheable address -4 uncachale
      subi r11, r2, 0x4
      st.w r10, (r11,0x0)
      ld.w r10, (r11,0x0)
      st.w r9, (r11,0x0)
      ld.w r11, (r11,0x0)
      cmpne r11,r9
      bt  TEST_FAIL
//check max crcr size, in tee crcr[6] is sec bit  
      lrw r1, 0xe000f000
      .ifdef CSKY_TEE 
      lrw r2, 0x3ff
      lrw r3, 0x7f
      st.w r2,(r1,0x8)
      ld.w r7,(r1,0x8)
      cmpne r3,r7
      bt  TEST_FAIL
      br  TEST_PASS
      .endif
      lrw r2, 0x3ff
      lrw r3, 0x3f
      st.w r2,(r1,0x8)
      ld.w r7,(r1,0x8)
      cmpne r3,r7
      bt TEST_FAIL
      bsr TEST_PASS


TEST_FAIL:
      FAIL
TEST_PASS:
      lrw r15,__exit
      jmp r15
//******this region is added by generator******

