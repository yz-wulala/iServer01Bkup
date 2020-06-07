// ****************************************************************************
// *                                                                          *
// * C-Sky Microsystems Confidential                                          *
// * -------------------------------                                          *
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// FILE NAME       : ck802_biu_connect.s 
// AUTHOR          : weidy
// NOTE            : this case is test for biu connection  
// ID              : 
// HWCFG           : 
// CSKYCPU         : 802 
.text
.align 1
.export main
main:

//load store data at biu addr to test connection
  lrw r1,BASE_ADDR
  lrw r2,0xc5c5c5c5
  lrw r3,0x5c5c5c5c

  st.w r2,(r1,0)
  ld.w r4,(r1,0)
  cmpne r4,r2
  bt FAIL
  
//test for size  
  movi r4,0x0
  st.h r3,(r1,0x4)
  ld.b r4,(r1,0x4)
  lrw  r5,0x5c
  cmpne r5,r4
  bt FAIL

//toggle
  movi r4,0x0
  st.w r3,(r1,0)
  ld.w r4,(r1,0)
  cmpne r4,r3
  bt FAIL
//test for burst trans
  //set memory
  lrw  r1,BASE_ADDR    //0x60000100
  lrw  r2,0xabcd1234
  st.w r2,(r1,0)

//****************************************************
// Step1:invalid one cache
//****************************************************
  lrw  r1,BASE_ADDR       //set cache line addr
  lrw  r2, 0xfffffff0     
  and  r1, r2             //generate addr value
  lrw   r2, 0xe000f004    //set CIR register address
  bseti r1, 1             //set 0 bit : invalid one
  st.w  r1, (r2,0x0)      //begin to invalid one cache line

//****************************************************
// Step2:set CRCRx to control cache region
//****************************************************
   lrw  r1, BASE_ADDR
   lrw  r2, 0xfffffff0     
   and  r1, r2
   addi r1, 0x39        //base addr is BASE_ADDR which you set  ,size = 512M
`ifdef CSKY_TEE
   lrw  r1, BASE_ADDR
   lrw  r2, 0xfffffff0     
   and  r1, r2
   addi r1, 0x79        //base addr is  BASE_ADDR ,size=512M , CRCR[6]=1 secure
`endif
   lrw  r2, 0xe000f008  //CRCR0 addr,
                        //CRCR1 addr :0xe000f00c   
                        //CRCR2 addr :0xe000f010
                        //CRCR3 addr :0xe000f014
   st.w r1,(r2,0)       //begin to set cache region
//****************************************************
// Step3:enable cache
//**************************************************** 
   lrw   r2, 0xe000f000 
   ld.w  r1, (r2,0)
   bseti r1, 0           //cache enable
   bclri r1, 1           //set INST and DATA all cacheble
   st.w  r1, (r2,0)      //store the value to register

//load from base_addr to cause load miss to generate once refill burst transfer
  lrw  r1,BASE_ADDR
  ld.w r2,(r1,0)
  lrw  r3,0xabcd1234  
  cmpne r3,r2
  bt FAIL
PASS:
  lrw r15,__exit
  jmp r15 
  
FAIL:
   lrw r15,__fail
  jmp r15
