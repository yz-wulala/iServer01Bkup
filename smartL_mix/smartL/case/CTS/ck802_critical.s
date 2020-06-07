// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : weidy
// CSKYCPU    : 802 
// HWCFIG     : 
// FUNCTION   : cover the 802 critical path
// METHOD     : 
// NOTE       : 
// ****************************************************************************

.text
.align 1
.export main
main:
`ifdef VIC
//Path1:
//Path Group:CPU_CLOCK
//Startpoint :x_intc_kid_27_int_enable
//endpoint: x_nm_iu_top_x_nm_iu_wb_wb_data_buffer
      lrw r1, 0xe000e400        
      lrw r2, 0xc0c0c0c0
      st32.w r2, (r1,0x0)
      ld32.h r3, (r1,0x0)
      lrw r4, 0xc0c0
      cmpne16 r3, r4
      bt  FAIL
`endif      

//Path2:
//Path Group:CPU_CLOCK
//Startpoint :x_nm_core_top_x_nm_core_x_nm_ifu_top_x_ifdp_ifu_iu_ex_src0_reg_reg_
//endpoint: x_nm_core_top_x_nm_core_x_ifu_top_x_ifdp_ifu_iu_ex_imm_reg      
  lrw  r1,0xcdfc3
  lrw  r2,0x2f2
  addi r2,0x1    //r2 with dependency
  mult r1,r2
  lrw  r3,0x25f7ec19
  cmpne r3,r1
  bt FAIL
        
//Path3:
//Path Group: OUTPUT_PATH
//Startpoint: x_nm_core_top_x_nm_core_x_nm_ifu_top_x_ifdp_ifu_iu_ex_src0_reg_reg_0_
//Endpoint: biu_pad_htrans[1]
//Note: this section cover the INPUT_PATH at the same time
`ifdef MGU      
.macro SETEXP OFFSET, HANDLER_BEGIN, HANDLER_END
  lrw  r1, \HANDLER_BEGIN
  mfcr r2, cr<1, 0>
  movi r3, \OFFSET
  lsli r3, r3, 2
  addu r2, r2, r3
  st.w r1, (r2,0)
  br \HANDLER_END
.endm
//set exception handler
 SETEXP 2 ACC_ERR_BEGIN ACC_ERR_END
ACC_ERR_BEGIN:
  mfcr r5,  cr<2,0>       
  bseti r5, r5, 31
  mtcr r5, cr<2,0>       //enter superv mode again
  movi r6, 0x1           //set flag 
  mfcr r4, cr<4, 0>
  addi r4, 0x4
  mtcr r4, cr<4, 0>      //r4 is the next pc  
  rte                    //return the next pc of generating the access error exception
ACC_ERR_END:
//set mgu
  mfcr r0, cr<0, 0>
  bseti r0, 8            //set psr register ee bit
  mtcr r0, cr<0, 0>
//*********************************************************************
//configure the first MGU region: in user and super mode can read/write
//   AP0 = 2'b11
//   BASE_ADDRESS = 0
//   SIZE = 4G
//   the first area : 0x0~0xffffffff
//*********************************************************************
  lrw r2, 0
  mtcr r2, cr<21, 0>    //configure mgu RID of PRSR,select REGION0
  lrw r1, 0x0000003f    //set the mgu base address=0x0 and size=4G 
  mtcr r1, cr<20, 0>
  mfcr r3, cr<19, 0> 
  bseti r3, 8
  bseti r3, 9
  mtcr r3, cr<19, 0>    //configure the AP0=2'b11 and in user mode and super mode can read/write
  
//**********************************************************************
//configure the second MGU region: 
//   1,in super mode can read/write
//   2,in user mode only can read, if you writes, can occur access error
//   AP1 = 2'b10
//   BASE_ADDRESS = BASE_ADDR
//   SIZE = 4K
//   the second area : BASE_ADDR~ BASE_ADDR+0xfff
//***********************************************************************
  lrw  r2, 1
  mtcr r2, cr<21, 0>    //configure mgu RID of PRSR,select REGION1
  lrw  r1, BASE_ADDR       
  lrw  r2, 0xffff0000   
  and  r1, r2           //set mgu base is BASE_ADDR
  movi r3,0x17          //size =4K
  or   r1,r3
  mtcr r1,cr<20,0>

  mfcr r1,cr<19,0>
  bseti r1,1            //set REGION1
  bclri r1,10 
  bseti  r1,11          //AP1 = 2'b10
  mtcr  r1,cr<19,0>
  
//*********************************
// enable the mgu
//*********************************
  mfcr r0, cr<18, 0>
  bseti r0, 0
  mtcr r0, cr<18, 0> 
`endif

  lrw r1, 0x12345678
  lrw r2, BASE_ADDR
  st32.w r1, (r2,0x0)
  ld32.w r1, (r2,0x0)
  lrw r3, 0x12345678
  cmpne r1, r3
  bt  FAIL
        
  lrw r1, 0xe000e400  // hit tcip addr      
  lrw r2, 0xc0c0c0c0
  st32.w r2, (r1,0x0)
  ld32.h r3, (r1,0x0)
  lrw r4, 0xc0c0
  cmpne16 r3, r4
  bt  FAIL
`ifdef MGU
//modify to user mode  
  mfcr r1, cr<0,0>
  bclri r1, r1, 31
  mtcr r1, cr<0,0>
  lrw r1,BASE_ADDR     //hit region1 protect region
  lrw r2,0xffffffff
  st.w r2,(r1,0x0)     //user mode only can read, if you writes, can occur access error
  ld.w r3,(r1,0x0)
  lrw  r3,0x1
  cmpne r6, r3
  bt  FAIL

//modify to user mode  
  mfcr r1, cr<0,0>
  bclri r1, r1, 31
  mtcr r1, cr<0,0>
  lrw r1, 0xe000e400  // hit tcip addr      
  lrw r2, 0xffffffff
  st32.w r2, (r1,0x0) //user mode only can read, if you writes, can occur access error
  ld32.h r3, (r1,0x0)
  lrw r4, 0xc0c0
  cmpne16 r3, r4
  bt  FAIL
`endif

//PATH4
//Note:memory out
`ifdef CACHE
  lrw  r1,IBUS_ADDR    
  lrw  r2,0xabcd1234
  lrw  r3,0x1234abcd
  lrw  r4,0x12345678
  lrw  r5,0x9898cdcf
  
  lrw r8,0x1000
  addu r1,r8
  st.w r2,(r1,0)
  st.w r3,(r1,0x4)
  st.w r4,(r1,0x8)
  st.w r5,(r1,0xc)      //fill one cacheline 

  lrw r8,0x1000
  addu r1,r8
  st.w r2,(r1,0)
  st.w r3,(r1,0x4)
  st.w r4,(r1,0x8)
  st.w r5,(r1,0xc)      //fill one cacheline

  lrw r8,0x1000
  addu r1,r8
  st.w r2,(r1,0)
  st.w r3,(r1,0x4)
  st.w r4,(r1,0x8)
  st.w r5,(r1,0xc)      //fill one cacheline

  lrw r8,0x1000
  addu r1,r8
  st.w r2,(r1,0)
  st.w r3,(r1,0x4)
  st.w r4,(r1,0x8)
  st.w r5,(r1,0xc)      //fill one cacheline
  
  
//****************************************************
// Step1:invalid all cache
//****************************************************
  lrw r1, 0xe000f004   //set CIR register address
  ld.w r2, (r1, 0x0)   
  bseti r2, 0x0        //set the 0 bit :invalid all
  st.w r2, (r1,0)      //begin to invalid all cache
//****************************************************
// Step2:set CRCRx to control cache region
//****************************************************
   lrw  r1, IBUS_ADDR
   lrw  r2, 0xfffffff0     
   and  r1, r2
   addi r1, 0x23        //base addr is IBUS_ADDR  ,size=256K
`ifdef CSKY_TEE
   lrw  r1, IBUS_ADDR
   lrw  r2, 0xfffffff0     
   and  r1, r2
   addi r1, 0x63        //base addr is IBUS_ADDR  ,size=256K , CRCR[6]=1 secure 
`endif
   lrw  r2, 0xe000f008  //CRCR0 addr,
                        //CRCR1 addr :0xe000f00c   
                        //CRCR2 addr :0xe000f010
                        //CRCR3 addr :0xe000f014
   st.w r1,(r2,0)       //begin to set cache region
   st.w r1,(r2,0x4)
   st.w r1,(r2,0x8)
   st.w r1,(r2,0xc)
//****************************************************
// Step3:enable cache
//**************************************************** 
   lrw   r2, 0xe000f000 
   ld.w  r1, (r2,0)
   bseti r1, 0           //cache enable
   bclri r1, 1           //set INST and DATA all cacheble
   st.w  r1, (r2,0)      //store the value to register
  //load from base_addr to cause load miss to generate once refill burst transfer
  lrw  r1,IBUS_ADDR 
  lrw  r3,0xabcd1234 
  lrw  r4,0x1234abcd
  lrw  r5,0x12345678
  lrw  r6,0x9898cdcf
  lrw  r7,0xffffffff

  lrw r8 ,0x1000
  addu r1,r8
  ld.w r2,(r1,0)
  ld.w r2,(r1,0) // load data from cache
  cmpne r3,r2
  bt FAIL
  ld.w r2,(r1,0x4)
  ld.w r2,(r1,0x4) // load data from cache
  cmpne r4,r2
  bt FAIL
  ld.w r2,(r1,0x8)
  ld.w r2,(r1,0x8) // load data from cache
  cmpne r5,r2
  bt FAIL
  ld.w r2,(r1,0xc)
  ld.w r2,(r1,0xc) // load data from cache
  cmpne r6,r2
  bt FAIL


  lrw r8 ,0x1000
  addu r1,r8
  ld.w r2,(r1,0) 
  ld.w r2,(r1,0) // load data from cache
  cmpne r3,r2
  bt FAIL
  ld.w r2,(r1,0x4)
  ld.w r2,(r1,0x4) // load data from cache
  cmpne r4,r2
  bt FAIL
  ld.w r2,(r1,0x8)
  ld.w r2,(r1,0x8) // load data from cache
  cmpne r5,r2
  bt FAIL
  ld.w r2,(r1,0xc)
  ld.w r2,(r1,0xc) // load data from cache
  cmpne r6,r2
  bt FAIL

  lrw r8 ,0x1000
  addu r1,r8
  ld.w r2,(r1,0) 
  ld.w r2,(r1,0) // load data from cache
  cmpne r3,r2
  bt FAIL
  ld.w r2,(r1,0x4)
  ld.w r2,(r1,0x4) // load data from cache
  cmpne r4,r2
  bt FAIL
  ld.w r2,(r1,0x8)
  ld.w r2,(r1,0x8) // load data from cache
  cmpne r5,r2
  bt FAIL
  ld.w r2,(r1,0xc)
  ld.w r2,(r1,0xc) // load data from cache
  cmpne r6,r2
  bt FAIL

  lrw r8 ,0x1000
  addu r1,r8
  ld.w r2,(r1,0) 
  ld.w r2,(r1,0) // load data from cache
  cmpne r3,r2
  bt FAIL
  ld.w r2,(r1,0x4)
  ld.w r2,(r1,0x4) // load data from cache
  cmpne r4,r2
  bt FAIL
  ld.w r2,(r1,0x8)
  ld.w r2,(r1,0x8) // load data from cache
  cmpne r5,r2
  bt FAIL
  ld.w r2,(r1,0xc)
  ld.w r2,(r1,0xc) // load data from cache
  cmpne r6,r2
  bt FAIL

  
 `endif
EXIT:
      lrw32 r15,__exit
      jmp r15
FAIL:
      lrw32 r15,__fail
      jmp r15

