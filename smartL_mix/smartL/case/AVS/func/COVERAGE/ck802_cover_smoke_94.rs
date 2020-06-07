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
// FILE NAME       : cover_smoke_80.rs
// AUTHOR          : Zhuanglin Yang
// FUNCTION        : For 80% line coverage
// METHOD          : 
// NOTE            : 
// ****************************************************************************
//CaseID:
//  G1{U0[1]&&U1[I1]&&U10[1]&&U11[1]&&U12[1]&&U13[1]&&U14[1]&&U15[1]&&U16[1]&&U17[1]&&U18[1]&&U19[1]&&U2[1]&&U20[1]&&U21[1]&&U22[1]&&U23[1]&&U24[1]&&U25[1]&&U26[1]&&U27[1]&&U28[1]&&U29[1]&&U3[1]&&U30[1]&&U31[1]&&U32[1]&&U33[1]&&U34[1]&&U35[1]&&U36[1]&&U37[1]&&U38[1]&&U39[1]&&U4[1]&&U40[1]&&U41[1]&&U42[1]&&U43[1]&&U44[1]&&U45[1]&&U46[1]&&U47[1]&&U48[1]&&U49[1]&&U5[I2]&&U50[1]&&U51[1]&&U52[1]&&U53[I1]&&U54[1]&&U55[1]&&U56[1]&&U57[1]&&U58[1]&&U59[1]&&U6[I1||I2]&&U7[1]&&U8[1]&&U9[1]}
//  G2{U0[1]&&U1[1]&&U2[1]}
//  G3{U0[1]&&U1[1]&&U2[1]&&U3[1]&&U4[1]&&U5[1]&&U6[1]}
//  G4{U0[1]&&U1[I1]}

#preserve_begin
.include  "core_init.h"

// ****************************************************************************
.set SPEC_ADDR, 0x3000
.set RANDOM_ADDR_0, 0x55555555
.set RANDOM_ADDR_1, 0xaaaaaaaa
.set IBUS_ACCERR_ADDR, 0x10000000

// ****************************************************************************
psrclr fe,ee,ie
psrset fe,ee,ie
 
.if CSKY_TTT  //int36 ~39 is sec int
movi r1,0xf0
lrw r8,0xE000E240 //ISSR
st.w r1,(r8,0x0)  //set int4~int8 is sec_int
.endif

mfcr  r3,cr<31,0> //CHR
mov   r2,r3
bseti r2,0x4    //int increase
mtcr r2,cr<31,0> 

mfcr  r3,cr<0,0> //PSR
bseti r3,26    //hardware stack
mtcr r3,cr<0,0> 

// env init
// SVBR
lrw r0, 0x0
mtcr r0, cr<1,3>
lrw r0, 0x0
mtcr r0, cr<1,1>  //EVBR
mfcr r0, cr<1,1>  //EVBR
cmpnei r0,0x0
bt __fail

mtcr r0, cr<10,3> //NSEVBR
mfcr r0, cr<10,3> //NSEVBR
cmpnei r0,0x0
bt __fail

// initial secure/super sp
lrw r14, 0x20001000

// initial nosecure/user sp
lrw r0, 0x20002000
mtcr r0,cr<14,1>
mfcr r1,cr<14,1>
cmpne r0,r1
bt __fail

// non-secure/supv sp
lrw r0, 0x20003000
mtcr r0, cr<6,3>
mfcr r1, cr<6,3>
cmpne r0,r1
bt __fail

// SUSP
lrw r0, 0x20004000
mtcr r0, cr<7,3>
mfcr r1, cr<7,3>
cmpne r0,r1
bt __fail




label wsc_to_unsec_set_int_expt
        lrw r12, unsec_world_1
        lrw r13, 0x0
        st.w r12,(r13,0x0)
        .short 0xc000 
        .short 0x3c20  //wsc world change
        br go_back_1
        label unsec_world_1
        lrw r14,0x20003000
        psrset ee
        psrset ie
        mfcr   r1,cr<0,0>
        lrw    r3,0xa0000140  //check in unsec world
        cmpne  r1,r3
        bt __fail
        
        //---------------------------//
        //int32
        //---------------------------//
        SETEXP 32 INT_SERVICE32_BEGIN INT_SERVICE32_END
        
        label INT_SERVICE32_BEGIN
        sync
        //clear pending bit for int1
        nie
        lrw r2,0xE000E280//ICPR
        movi r1,0x1
        st.w r1,(r2,0x0)
        //int counter
        lrw  r1,0x20000000
        //int 33 has high priority
        ld.w r0,(r1,4) //r0==33
        addi r0,32
        st.w r0,(r1,0) 
        mfcr r1, cr<0,0>
        nir
        label INT_SERVICE32_END


        //---------------------------//
        //int33
        //---------------------------//
        SETEXP 33 INT_SERVICE33_BEGIN INT_SERVICE33_END
        
        label INT_SERVICE33_BEGIN
        sync
        //clear pending bit for int1
        lrw r2,0xE000E280//ICPR
        movi r1,0x2
        st.w r1,(r2,0x0)
        //int counter
        lrw  r1,0x20000000
        movi r0,33
        st.w r0,(r1,4)
        rte
        label INT_SERVICE33_END

        //---------------------------//
        //int34
        //---------------------------//
        SETEXP 34 INT_SERVICE34_BEGIN INT_SERVICE34_END
        
        label INT_SERVICE34_BEGIN
        sync
        //clear pending bit for int1
        lrw r2,0xE000E280//ICPR
        movi r1,0x4
        st.w r1,(r2,0x0)
        //int counter
        lrw  r1,0x20000000
        movi r0,34
        st.w r0,(r1,8)
        rte
        label INT_SERVICE34_END

        //---------------------------//
        //int35
        //---------------------------//
        SETEXP 35 INT_SERVICE35_BEGIN INT_SERVICE35_END
        
        label INT_SERVICE35_BEGIN
        sync
        //clear pending bit for int1
        lrw r2,0xE000E280//ICPR
        movi r1,0x8
        st.w r1,(r2,0x0)
        //int counter
        lrw  r1,0x20000000
        ld.w r0,(r1,0x1c) //int 39
        addi r0,35
        st.w r0,(r1,0xc)  //39+35=74
        rte
        label INT_SERVICE35_END


        //---------------------------//
        //int39 to int64
        //---------------------------//
       	lrw      	r1, INT_SERVICE40_to_63_BEGIN
      	mfcr      	r2, cr<1, 0>
       	movi      	r3, 40         //int 34
       	lsli      	r3, r3, 2      //int 34*2
       	addu      	r2, r2, r3
        movi        r3,0x0
        label set_vectable_int_address
       	st.w      	r1, (r2, 0x0) //int40_int63
        addi        r2,0x4
        addi        r3,0x1
        cmpnei      r3,24
        bt  set_vectable_int_address
       	br      	INT_SERVICE40_to_63_END

        label INT_SERVICE40_to_63_BEGIN
        sync
        //clear pending bit for int1
        lrw  r2,0xE000E280//ICPR
        lrw  r1,0xffffffff //clear all pending
        st.w r1,(r2,0x0)
        //int counter
        lrw  r1,0x20000020
        ld.w r0,(r1,0) //
        addi r0,1      //int number ++
        st.w r0,(r1,0) 
        
        rte
        label INT_SERVICE40_to_63_END

        //enable int 34
        label unsec_world_unsec_int
        lrw r1,0x4       //
        lrw r3,0xE000E100//ISER
        st.w r1,(r3,0x0) //enbale int 34
        lrw  r1,0x4      //set int35 pending
        lrw  r3,0xE000E200//ISPR
        st.w r1,(r3,0x0)  //set  pending
        mov   r0,r0
        mov   r0,r0
        lrw   r0,0x20000000
        ld.w  r1,(r0,0x8) //check int34 happened
        cmpnei r1,34
        bt __fail

//rte form unsec world
rte
label go_back_1

.if CSKY_TTT  //remove sec int

lrw r1,0xffffffff
lrw r8,0xE000E240 //ISSR
st.w r1,(r8,0x0)  //sec int cov
ld.w r2,(r8,0x0)  //sec int cov
cmpne r1,r2
bt __fail

lrw r8,0xE000E2C0 //ICSR
st.w r1,(r8,0x0)  //clear sec_int
ld.w r2,(r8,0x0)  //sec int cov
cmpnei r2,0
bt __fail
.endif


//---------------------------//
//int36
//---------------------------//
SETEXP 36 INT_SERVICE36_BEGIN INT_SERVICE36_END

label INT_SERVICE36_BEGIN
sync
//clear pending bit for int1
lrw r2,0xE000E280//ICPR
movi r1,0x10
st.w r1,(r2,0x0)
//int counter
lrw  r1,0x20000000
movi r0,36
st.w r0,(r1,0) 

rte
label INT_SERVICE36_END


//---------------------------//
//int37
//---------------------------//
SETEXP 37 INT_SERVICE37_BEGIN INT_SERVICE37_END

label INT_SERVICE37_BEGIN
sync
//clear pending bit for int1
lrw r2,0xE000E280//ICPR
movi r1,0x20
st.w r1,(r2,0x0)
//int counter
lrw  r1,0x20000000
movi r0,37
st.w r0,(r1,0x14)
rte
label INT_SERVICE37_END

//---------------------------//
//int38
//---------------------------//
SETEXP 38 INT_SERVICE38_BEGIN INT_SERVICE38_END

label INT_SERVICE38_BEGIN
sync
//clear pending bit for int1
lrw r2,0xE000E280//ICPR
movi r1,0x40
st.w r1,(r2,0x0)
//int counter
lrw  r1,0x20000000
movi r0,38
st.w r0,(r1,0x18)
rte
label INT_SERVICE38_END

//---------------------------//
//int39
//---------------------------//
SETEXP 39 INT_SERVICE39_BEGIN INT_SERVICE39_END

label INT_SERVICE39_BEGIN
//clear pending bit for int1
nie
ipush
ipop
ipush
ipop
lrw r2,0xE000E280//ICPR
movi r1,0x80
st.w r1,(r2,0x0)
//int counter
lrw  r1,0x20000000
movi r0,39
st.w r0,(r1,0x1c)
nir
label INT_SERVICE39_END


////WSC handler
//SETWSC 0 WSC_BEGIN WSC_END
//label WSC_BEGIN
//jmp r9
//label WSC_END
//
//SETSWSC 0 SWSC_BEGIN SWSC_END
//label SWSC_BEGIN
//jmp r9
//label SWSC_END



 

SETEXP 1 MISALIGN_HANDLE_BEGIN MISALIGN_HANDLE_END
label MISALIGN_HANDLE_BEGIN
mov r1,r1
mov r1,r1
mov r1,r1
movi r1,0xa000
rte
label MISALIGN_HANDLE_END

SETEXP 2 ACCESS_ERROR_BEGIN ACCESS_ERROR_END
label ACCESS_ERROR_BEGIN
mfcr r1, epc
addi r1, r1, 2
mtcr r1, epc
movi r3,0xacc
rte
label ACCESS_ERROR_END

SETEXP 3 DIV0_EXP_BEGIN DIV0_EXP_END
label DIV0_EXP_BEGIN
mfcr r0,cr<4,0>
addi r0,4
mtcr r0,cr<4,0>
rte
label DIV0_EXP_END

SETEXP 4 ILLEGAL_INST_EXP_BEGIN ILLEGAL_INST_EXP_END
label ILLEGAL_INST_EXP_BEGIN
lrw r1,0x8000
ld.w r1,(r1,0)
lrw  r2,0x3f800000
cmpne r1,r2
bt __fail
mfcr r0,cr<4,0>
addi r0,4
mtcr r0,cr<4,0>
rte
label ILLEGAL_INST_EXP_END

SETEXP 6 TRACE_EXP_BEGIN TRACE_EXP_END
label TRACE_EXP_BEGIN
addi16 r1, 4
mfcr r2, cr<4, 0>
lrw r1, 0x80064150
mfcr r2, cr<2, 0>
addi r11, 1
rte
label TRACE_EXP_END

SETEXP 7 BKPT_EXP_BEGIN BKPT_EXP_END  
label BKPT_EXP_BEGIN    
//********inside exception set r12=7777 
cmpnei    r12, 0x1111    
bt __fail    
lrw    r12, 0x7777    
//********Judge the value of EPC       
mov    r1, r15    
mfcr   r2, cr<4, 0>    
cmpne  r1,r2    
bt __fail    
//********Judge the value of EPSR      
//mov    r1, r13    
//mfcr   r2, cr<2, 0>    
//cmpne  r1,r2    
//bt __fail    
//********out of bkpt      

// ********set  CSR   = 0x0  ***********
lrw r0,0xe0011054
lrw r1,0x0
st.w r1,(r0,0)
//********modify current PC      
//mfcr   r2, cr<4, 0>    
//mtcr   r2, cr<4, 0>    
rte    
label BKPT_EXP_END    

SETEXP 10 AUTO_INT_BEGIN AUTO_INT_END
label AUTO_INT_BEGIN
movi r10, 0x9876
rte
label AUTO_INT_END

// set trap0 exception handler program:
//****************************************************
SETEXP 16 TRAP0_BEGIN TRAP0_END	
label TRAP0_BEGIN
mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
addi r1, r1, 4         
mtcr r1, cr<4,0>
rte                    //return the next pc of generating the TRAP0 exception
label TRAP0_END
//****************************************************
// set trap1 exception handler program:
//****************************************************
SETEXP 17 TRAP1_BEGIN TRAP1_END	
label TRAP1_BEGIN
mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
addi r1, r1, 4         
mtcr r1, cr<4,0>
rte                    //return the next pc of generating the TRAP0 exception
label TRAP1_END
//****************************************************
// set trap2 exception handler program:
//****************************************************
SETEXP 18 TRAP2_BEGIN TRAP2_END	
label TRAP2_BEGIN
mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
addi r1, r1, 4         
mtcr r1, cr<4,0>
rte                    //return the next pc of generating the TRAP0 exception
label TRAP2_END
//****************************************************
// set trap3 exception handler program:
//****************************************************
SETEXP 19 TRAP3_BEGIN TRAP3_END	
label TRAP3_BEGIN
//  mfcr r1, cr<0, 0>      
//  bseti r1, 31         
//  mtcr r1, cr<0,0>
mfcr r1, cr<4, 0>      //when entre into exception program, the EPC save the pc
addi r1, r1, 4         
mtcr r1, cr<4,0>
rte                    //return the next pc of generating the TRAP0 exception
label TRAP3_END

.if TSPEND
SETEXP 22 TSPEND_BEGIN TSPEND_END	
label TSPEND_BEGIN
lrw r1,0x8000
lrw r2,22
st.w r2,(r1,0)
rte                    //return the next pc of generating the TRAP0 exception
label TSPEND_END
.endif


//*************************************************
//             Main Start                        //
//*************************************************

//********************************Arithmetic Operation*****************************
label main_start

//---------initail registers r0~r15-------------
lrw r0, 0x00000000
lrw r1, 0x55555555
lrw r2, 0xaaaaaaaa
bmaski r3, 0x0     //r3=0xffffffff
mov r4, r0
mov r5, r0
lrw r6, 0x0
lrw r7, 0x55555555
//abs r8, r3
//cmpnei r8, 0x1
//bt __fail
mov r9, r0
mov r10, r0
mov r11, r0
mov r12, r11
mov r13, r12
mov r13, r13
//mov r16, r13
//mov r17, r13
//mov r28, r13
//push r4-r11,r15
//push r4
//push r4-r5
//push r4-r6
//push r4-r7
//pop  r4-r7
//pop  r4-r6
//pop  r4-r5
//pop  r4-r11,r15


//label ipush_ipop_instruction
//lrw sp, 0x0800aaa0
//lrw r10, finish_ipop
//ipush
//ipop
//label finish_ipop

lrw sp, 0x5555aaaa
mov r15, r14 
//mov r28, r0
//addi r28, 1
//cmpnei r28, 1
//bt __fail




addc16 r6, r7
//r6=0x55555555,r7=0x55555555
addc32 r7, r6, r2
addi16 r7, 0x01
//r7=0
addi16 r4, r7, 0x01
addi16 r7, sp, 0xa8
addi32 sp, sp, 0xffc
cmpnei r4, 0x1
bt __fail
//r7=a8,r6=0x55555555
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
bt __fail
bclri32 r4, r7, 0x0
cmpnei r4, 0x4000
bt __fail

bf16 __bf_label
label __bf_label
bmaski r4, 17
lrw r3, 0x1ffff
cmpne r3, r4
//C=0
bt32 __bt_label
label __bt_label
bf32 __br16_label

br16 __br16_label
label __br16_label
br32 __br32_label
label __br32_label
//r0=0
//bseti16 r0, 0x0
bseti16 r0, 0x15
bseti16 r0, 0x0a
//r0=0x200400,r4=0x1ffff
bseti32 r4, r0, 0x00
bseti32 r4, r0, 0x15
bseti32 r4, r0, 0x1f

bsr32 __bsr32_label

label __bsr32_label
movi r1,0x1
.short 0x39c0 //inst btsti16
bt  jump_over
bt  __fail
label jump_over
btsti r1, 0x1
//r3=0x1ffff,r4=0x80200400
btsti r4, 0x5
//C=0
cmphs16 r4, r3
//cmphs32 r4, r3
//C=1
cmplt16 r4, r3
//cmplt32 r4, r3
//C=0
cmphsi16 r4, 0x1f
cmphsi32 r4, 0xffff
//C=1
cmplti16 r4, 0x1f
cmplti32 r4, 0xffff
//C=0
cmpne16 r4, r3
//C=1,r6=0x8000
cmpnei32 r6, 0x8000
//C=0,r6=0x8000
decf r4, r6, 0x1
dect r4, r4, 0x1
cmpnei r4, 0x7fff
bt __fail

//label  decgt_instruction
//movi r8, 32
//decgt r9, r8, 31
//bf __fail
//label  declt_instruction
//declt r8, r9, 1
//bt __fail
//label  decne_instruction
//decne r9, r8, 1
//bf __fail

movi r4, 0x1
label __ff_label
ff1 r0, r4
ff0 r0, r4
lsli r4, 0x1
cmpnei r4, 0
bt __ff_label
ff0 r6, r7
ff1 r7, r6
//C=0,r6=0,r7=0x20
incf32 r6, r7, 0x12
inct32 r7, r6, 0x03
//r6=0x32,r7=0x20
movi r2,0x1
movi r3,0x1
ixh32 r6, r7, r2 //0x20  +(1 <<1)
ixw32 r7, r6, r3 //0x22  +(1 <<2)
//ixd32 r8, r6, r7
//bclri r8, 22
//r8=0x4000f4,r0=1
//lsl16 r8, r0
lrw r8,0x26
cmpne r8, r7
bt __fail

lrw r4, __jmp_label
label grs_inst
grs r10, __jmp_label
cmpne r4, r10
bt __fail
jmp r4
label __jmp_label
lrw r15, __jmp15_label
jmp r15
label __jmp15_label
lrw r4, __jsr_label
jsr r4

label __jsr_label
movi r5, 0x20
movi r4, 0x0
label __lsl16_label
lsl16 r0, r4
addi r4, 0x1
cmpne r4, r5
bt __lsl16_label
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
//r1=0xffffffff, r7=0xffffffff
cmpne r7, r1
bt __fail

label push_pop
lrw sp, SPEC_ADDR
push r4-r11,r15
lrw r15, __pop_r15_label
push r15
pop r15
label __pop_r15_label
lrw r15, __pop_r4_r7_label
pop r4-r5
label __pop_r4_r7_label
lrw r15, __pop_r4_label
pop r4
label __pop_r4_label

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
bt __fail

sync

trap 0
trap 1
trap 2
trap 3

movi r1, 0xa 
tst16 r4, r0
//C=0
tstnbz16 r2
//C=1
tstnbz16 r3
//C=0
//tst32 r4, r1
//bf __fail
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
label  set_psr_mm_sd
mfcr  r1,cr<0,0>
bseti r1,0x9
bseti r1,26
mtcr  r1,cr<0,0>

//--------------load & store-------------------
label ld_st_instruction
lrw  r1, 0x40000
movi r2, 0x8
movi r4, 0x0
label stb_ldb_instruction
st.b r2,(r1,0)
st.b r2,(r1,1)
st.b r2,(r1,2)
st.b r2,(r1,3)
ld.b r2,(r1,0)
ld.b r2,(r1,1)
ld.b r2,(r1,2)
ld.b r2,(r1,3)
ld.w r2,(r1,0)
lrw  r3,0x08080808
cmpne r2,r3 
bt __fail

label sth_ldh_instruction
st.h r2,(r1,0)
st.h r2,(r1,2)
ld.h r3,(r1,0)
ld.h r4,(r1,2)
cmpnei r3,0x0808
bt __fail
cmpnei r4,0x0808
bt __fail

label unalign_store
lrw  r1, 0x40000
lrw  r2,0x12345678
st.w r2,(r1,0)
st.w r2,(r1,4)
lrw  r3,0x87654321
//offset 1
lrw r8,0x40001
st.w r3,(r8,0) //0x80,0x00808080
ld.w r4,(r8,0) //0x80,0x00808080
cmpne r3,r4 
bt __fail
//offset 2
lrw r8,0x40002
st.w r3,(r8,0) 
ld.w r4,(r8,0) //0x80,0x00808080
cmpne r3,r4 
bt __fail
//offset 3
lrw r8,0x40003
st.w r3,(r8,0) 
ld.w r4,(r8,0) //0x80,0x00808080
cmpne r3,r4 
bt __fail
label ldh_sth_unalign
lrw  r1, 0x40000
lrw  r2,0x12345678
st.w r2,(r1,0)
st.w r2,(r1,4)
lrw  r3,0x8765
//offset 1
lrw r8,0x40001
st.h r3,(r8,0) //0x80,0x00808080
ld.h r4,(r8,0) //0x80,0x00808080
cmpne r3,r4 
bt __fail
//offset 2
lrw r8,0x40002
st.h r3,(r8,0) 
ld.h r4,(r8,0) //0x80,0x00808080
cmpne r3,r4 
bt __fail
//offset 3
lrw r8,0x40003
st.h r3,(r8,0) 
ld.h r4,(r8,0) //0x80,0x00808080
cmpne r3,r4 
bt __fail
label ldb_stb_aualign
lrw  r1, 0x40000
lrw  r2,0x12345678
st.w r2,(r1,0)
st.w r2,(r1,4)
lrw  r3,0xab
//offset 1
lrw r8,0x40001
st.b r3,(r8,0) //0x80,0x00808080
ld.b r4,(r8,0) //0x80,0x00808080
cmpne r3,r4 
bt __fail
//offset 2
lrw r8,0x40002
st.b r3,(r8,0) 
ld.b r4,(r8,0) //0x80,0x00808080
cmpne r3,r4 
bt __fail
//offset 3
lrw r8,0x40003
st.b r3,(r8,0) 
ld.b r4,(r8,0) //0x80,0x00808080
cmpne r3,r4 
bt __fail


 
label  set_clr_mm
mfcr  r1,cr<0,0>
bclri r1,0x9
mtcr  r1,cr<0,0>


//label idly_instruction
//mfcr r1,cr<0,0>
//bseti r1,0x0
//mtcr r1,cr<0,0>
//idly 20
//mfcr r1,cr<0,0>
//mov  r2,r1
//bclri r2,0x0
//cmpne r2,r1
//bt __fail


label system_bus_addres_access
lrw   r1,0xa0000000 //BASE_ADDR
lrw   r2,0x1234aaaa
st.w  r2,(r1,0)
ld.w  r3,(r1,0)
cmpne r2,r3
bt __fail

label illegial_isnt
lrw  r1,0x3f800000
lrw  r2,0x8000
st.w r1,(r2,0)
.short 0x3f80 //illegial inst
.short 0x3f80 //illegial inst
lrw  r2,0x8000
lrw  r1,0x40000000
st.w r1,(r2,0)





label st_ld_instruction
// initial r1 and r2 
lrw r1, 0x40000
lrw r2, 0x12349988
st16.w r2, (sp,0)
ld16.w r3, (sp,0)
//r3=0x12349988
st32.w r3, (r1,0)
ld32.w r2, (r1,0)
st16.h r2, (r1,0)
//r3=0x9988
ld16.h r3, (r1,0)
st32.h r3, (r1,0)
//r2=0x9988,r4=0xffff9988
ld32.h r2, (r1,0)
ld.hs r4, (r1,0)
lrw r6, 0xffff9988
cmpne r4, r6
bt __fail
st16.b r2, (r1,0)
//r3=0x88
ld16.b r3, (r1,0)
st32.b r3, (r1,0)
//r2=0x88, r5=0xffff8888
ld32.b r2, (r1,0)
cmpnei r2, 0x88
bt __fail
ld.bs r5, (r1,0)
lrw r6, 0xffffff88
cmpne r5, r6
bt __fail

//label str_ldr_instruction
//str.w r3, (r1,r6<<3)
//ldr.w r2, (r1,r6<<3)
//cmpnei r3, 0x88
//bt __fail

label stm_ldm_instruction
lrw r2,0x88
lrw r3,0x88
stm r2-r3, (r1)
ldm r4-r5, (r1)
cmpnei r4, 0x88
bt __fail
cmpnei r5, 0x88
bt __fail



//label srs_lrs_instruction
//lrw    r1, 0x12345641
//lrw   r28,SRS_BASE
//srs.w  r1, [SRS_1]
//lrs.w  r2, [SRS_1]
//srs.h  r2, [SRS_2]
//lrs.h  r3, [SRS_2]
//srs.b  r3, [SRS_3]
//lrs.b  r4, [SRS_3]
//cmpnei  r4, 0x41
//bt __fail

//label clrf_clrt_instruction
////C=0, clear r4
//clrf r4
//cmpnei r4, 0
////C=0, hold r3
//clrt r3
//cmpnei r3, 0x5641
//bt __fail

//label bgenr_inst
//bgenr r2, r3
//cmpnei r2, 2
//bt __fail

label div_inst
lrw    r1, 0x20000000
lrw    r4, 0x12345678
//lrw    r3, 0xffffffff
//lrw    r2, 0x7fffffff
//stm    r2-r4,(r1)
//ldm    r2-r4,(r1)
//divu r0, r2, r4
//divs r1, r2, r3
//cmpnei r0,0x7
//bt __fail
//lrw    r3,0x80000001
//cmpne  r1,r3
//bt __fail

//label mulsh_instruction
//      movi r1,0x4
//      movi r2,0x4
//      mulsh16 r1,r2
//      mulsh32 r3,r1,r2
//      cmpnei r3,64
//      bt  __fail
//label idly_instruction
//      idly 10
//      mfcr r1,cr<0,0>
//      bseti r1,14
//      mtcr r1,cr<0,0>
//      mfcr r5,cr<0,0>
//      bclri r5,14
//      mtcr r5,cr<0,0>
//      mfcr r3,cr<0,0>
//      andi r3,r3,0x1
//      cmpnei r3,0x1
//      bt  __fail
//      lrw r2,0x80064150;
//      cmpne r2,r1
//      bt  __fail
//label sce_instruction
//      sce 0xf
//      addi r2,0x1
//      addi r2,0x1
//      addi r2,0x1
//      addi r2,0x1
//      cmpne r2,r1
//      bt  __fail
//      sce 0x0
//      addi r2,0x1
//      addi r2,0x1
//      addi r2,0x1
//      addi r2,0x1
//      subi r2,0x4
//      cmpne r2,r1
//      bt  __fail
//label zext_instruction
//      movi r1,0xbeef
//      zext r2,r1,15,8
//      cmpnei r2,0xbe
//      bt  __fail
//label ins_instruction
//      ins r2,r1,7,0
//      cmpnei r2,0xef
//      bt  __fail
//label brev_instruction
//      brev r3,r2
//      movih r2,0xf700
//      cmpne r3,r2
//      bt  __fail
//label branch_instruction
//      movi r1,0x1
//      bez r1,__fail
//      movi r1,0x0
//      bnez r1,__fail
//      movi r1,0x0
//      bhz r1,__fail
//      movi r1,0x1
//      blsz r1,__fail
//      movi r1,0x0
//      blz r1,__fail
//      movi r1,0x0
//      bhsz r1,branch_pass
//      br  __fail
label branch_pass
      mov r0,r0

label close_mgu1
      movi r1,0x0
      mtcr r1,cr<18,0>

      lrw r10,0xffffff00
      mtcr r10,cr<19,0> //set,primision
      mfcr r1,cr<19,0>  //r1 use select which mgu
      cmpne r1,r10
      bt __fail

      movi r1,0x3       //set mgu region 3
      mtcr r1,cr<21,0>  //r1 use select which mgu
      mfcr r1,cr<21,0>  //r1 use select which mgu
      cmpnei r1,0x3
      bt __fail
      movi r2,0x3f      //mgu size 4G 
      mtcr r2,cr<20,0>
      mfcr r1,cr<20,0>  //r1 use select which mgu
      cmpnei r1,0x3f
      bt __fail

//loop set mgu0~mgu7 
      movi r1,0x0
label set_mgu0_mgu7
      movi r2,0xd        //mgu size
//loop set mgu size
      label set_mgu_size
            mtcr r1,cr<21,0>  //r1 use select which mgu
            mtcr r2,cr<20,0>
            mfcr r3,cr<20,0>
            cmpne r2,r3
            bt __fail
            addi r2,0x2
            cmpnei r2,0x41   //set size form 0x17 ~ 0x3f
      bt  set_mgu_size
      
      addi r1,0x1
      cmpnei r1,0x8          //ifdef mgu8
bt  set_mgu0_mgu7


label set_mgu_primision
      //mgu premission cov
      lrw r10,0xfe5555fe
      lrw r9, 0x0
      mtcr r10,cr<19,0> //set,primision
      mfcr r11,cr<19,0>
      cmpne r11,r10
      bt __fail

      lrw r10,0xfeaaaafe
      lrw r9, 0x0
      mtcr r10,cr<19,0> //set,primision
      mfcr r11,cr<19,0>
      cmpne r11,r10
      bt __fail

      lrw r10,0xfeff3ffe
      lrw r9, 0x0
      mtcr r10,cr<19,0> //set,primision
      mfcr r11,cr<19,0>
      cmpne r11,r10
      bt __fail

      movi r1,0x0
      lrw r3,0x0
      lrw r4,0x20000000
      lrw r5,0x17      //mgu size
label set_mgu_region
      mtcr r1,cr<21,0>
      lrw r2,0x39
      add r2,r3
      mtcr r2,cr<20,0>
      add r3,r4
      addi r1,0x1
      cmpnei r1,0x8
      bt  set_mgu_region

label set_mgu_region3_accerr
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
      //lrw r1, 0x20001000
      //movi r2, 0x777
      //st.w r2, (r1,0)
      //ld.w r3, (r1,0)
      //cmpnei r3, 0x777
      //bt  __fail
label check_access_err
      lrw r1, 0x20001000
      movi r2, 0x777
      st16.w r2, (r1,0)
      cmpnei r3, 0xacc
      bt  __fail

label wsc_to_unsec_accerr
        lrw r12, unsec_world_3
        lrw r13, 0x0
        st.w r12,(r13,0x0)
        .short 0xc000 
        .short 0x3c20  //wsc world change
        br go_back_3
        label unsec_world_3
        //access error
        movi r3,0x0
        lrw r1, 0x20001000
        movi r2, 0x777
        st16.w r2, (r1,0)
        cmpnei r3, 0xacc
        bt  __fail
        rte
label go_back_3

label close_mgu
      movi r1,0
      mtcr r1,cr<18,0>


      movi r1,0x0
      movi r2,0x0 
label close_mgu_entry
      mtcr r1,cr<21,0>  //r1 use select which mgu
      mtcr r2,cr<20,0>  //close mgu entry
      addi r1,0x1
      cmpnei r1,0x8
      bt  close_mgu_entry

label set_mgu_entry_one_by_one
      
      lrw r10,0xffffff00
      mtcr r10,cr<19,0> //set,primision

      movi r1,0x0
      mtcr r1,cr<21,0>  //mgu0
      movi r1,0x3f
      mtcr r1,cr<20,0>  //mgu0 size 4G
      mfcr r1,cr<18,0>
      bseti r1,0
      bclri r1,1
      mtcr r1,cr<18,0>  //mgu enable

      lrw  r1,0x08000000    
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt __fail
      //set_mgu1_close_mgu0
      movi r1,0x1
      mtcr r1,cr<21,0>  //mgu1
      movi r2,0x3f
      mtcr r2,cr<20,0>  //mgu1 size 4G

      movi r1,0x0
      mtcr r1,cr<21,0>  //mgu0
      movi r2,0x0
      mtcr r2,cr<20,0>  //mgu0 close
      lrw  r1,0x08000000//check mem    
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt __fail
      //set_mgu2_close_mgu1
      movi r1,0x2
      mtcr r1,cr<21,0>  //mgu1
      movi r2,0x3f
      mtcr r2,cr<20,0>  //mgu1 size 4G
      movi r1,0x1
      mtcr r1,cr<21,0>  //mgu0
      movi r2,0x0
      mtcr r2,cr<20,0>  //mgu0 close
      lrw  r1,0x08000000//check mem    
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt __fail
      //set_mgu3_close_mgu2
      movi r1,0x3
      mtcr r1,cr<21,0>  
      movi r2,0x3f
      mtcr r2,cr<20,0>  
      movi r1,0x2
      mtcr r1,cr<21,0>  
      movi r2,0x0
      mtcr r2,cr<20,0>  
      lrw  r1,0x08000000 
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt __fail
      //set_mgu4_close_mgu3
      movi r1,0x4
      mtcr r1,cr<21,0>  
      movi r2,0x3f
      mtcr r2,cr<20,0>  
      movi r1,0x3
      mtcr r1,cr<21,0>  
      movi r2,0x0
      mtcr r2,cr<20,0>  
      lrw  r1,0x08000000 
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt __fail
      //set_mgu5_close_mgu4
      movi r1,0x5
      mtcr r1,cr<21,0>  
      movi r2,0x3f
      mtcr r2,cr<20,0>  
      movi r1,0x4
      mtcr r1,cr<21,0>  
      movi r2,0x0
      mtcr r2,cr<20,0>  
      lrw  r1,0x08000000 
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt __fail
      //set_mgu6_close_mgu5
      movi r1,0x6
      mtcr r1,cr<21,0>  
      movi r2,0x3f
      mtcr r2,cr<20,0>  
      movi r1,0x5
      mtcr r1,cr<21,0>  
      movi r2,0x0
      mtcr r2,cr<20,0>  
      lrw  r1,0x08000000 
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt __fail

      //set_mgu7_close_mgu6
      movi r1,0x7
      mtcr r1,cr<21,0>  
      movi r2,0x3f
      mtcr r2,cr<20,0>  
      movi r1,0x6
      mtcr r1,cr<21,0>  
      movi r2,0x0
      mtcr r2,cr<20,0>  
      lrw  r1,0x08000000 
      st.w r1,(r1,0)
      ld.w r2,(r1,0)
      cmpne r1,r2
      bt __fail
      //close mgu
      movi r1,0
      mtcr r1,cr<18,0>








      //lrw  r1,0x20000000    
      //st.w r2,(r1,0)  
      //ld.w r2,(r1,0)
      //lrw  r1,0x20000000    
      //st.w r2,(r1,0)
      //ld.w r2,(r1,0)
      //lrw  r1,0x10000000    
      //cmpne r1,r2
      //bt __fail
      

     


label modify_memory
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


label set_crcr0_crcr3_for_cov
      lrw  r3,0xe000f008 //crcr0 address
      movi r1,0x0
      .if CSKY_TTT
      movi r2,0x57        //define CSKY_TTT, need set secu
      .else
      movi r2,0x17        //cache size 
      .endif
      label set_crcr_size
            st.w r2,(r3,0x0) //set crcr0
            st.w r2,(r3,0x4) //set crcr1
            st.w r2,(r3,0x8) //set crcr2
            st.w r2,(r3,0xc) //set crcr3
            ld.w r4,(r3,0x0) //set crcr0
            cmpne r2,r4
            bt __fail
            addi r2,0x2
            .if CSKY_TTT
            cmpnei r2,0x81        //define CSKY_TTT, need set secu
            .else
            cmpnei r2,0x41   //set size form 0x17 ~ 0x3f
            .endif
      bt  set_crcr_size

label cache_test
      movi r1,0x1
      lrw r2,0xe000f000
      st.w r1,(r2,0x0) //cache en
      st.w r1,(r2,4)   //invalid all 
      movi r3,0x3f   //set size form 0x17 ~ 0x3f
      .if CSKY_TTT
      movi r3,0x7f        //define CSKY_TTT, need set secu
      .endif

      //set crcr0~3
      st.w r3,(r2,0x8) //crcr0
      st.w r3,(r2,0xc)
      st.w r3,(r2,0x10)
      st.w r3,(r2,0x14)
      
      //load data to cache modify
      label cache_cannot_write
      movi r1, 0x8000
      movi r3, 0x777
      ld.w r4, (r1,0x10) //load to cache
      st.w r3, (r1,0x10) //modify cache 
      ld.w r4, (r1,0x20) //load to cache
      st.w r3, (r1,0x20) //modify cache 
      ld.w r4, (r1,0)
      st.w r3, (r1,0) //modify cache 
      ld.w r4, (r1,0) //cache can't write
      cmpnei r4,0x888
      bt __fail
      label dlite_memory_uncacheable
      lrw  r1, 0x20008000
      movi r3, 0x777
      ld.w r4, (r1,0)
      st.w r3, (r1,0) //modify cache 
      ld.w r4, (r1,0) //dlite uncacheable
      cmpnei r4,0x777
      bt __fail
      //close cache check memory data
      lrw r2,0xe000f000
      movi r1,0x0
      st.w r1,(r2,0x0) //close cache
      movi r1, 0x8000
      ld.w r4, (r1,0)
      cmpnei r4,0x777 //memory data changed
      bt __fail

      label cache_inv_one
      //inv_one, inv_all check
      movi r1,0x1
      lrw r2,0xe000f000
      st.w r1,(r2,0x0) //open cache and clr_one
      lrw r1,0x8002
      st.w r1,(r2,0x4) //cir inv one

      lrw r1, 0x8000
      ld16.w r3, (r1,0)
      cmpnei r3,0x777
      bt  __fail

      label cache_inv_all
      lrw r1,1
      lrw r2,0xe000f000
      st.w r1,(r2,0x4)  //inv all

      lrw r1, 0x8000
      ld16.w r3, (r1,0x10)
      cmpnei r3,0x777
      bt  __fail
      ld16.w r3, (r1,0x20)
      cmpnei r3,0x777
      bt  __fail
      lrw r1,0
      st.w r1,(r2,0x0)  //close cache
      
      
//      
//      .if CSKY_TTT
//      movi r1,0x7f
//      .else
//      movi r1,0x3f
//      .endif
//
//loop set crcr0~crcr3 size
//label set_crcr0_crcr3_for_cov
//      lrw  r3,0xe000f008 //crcr0 address
//      movi r1,0x0
//      .if CSKY_TTT
//      movi r2,0x57        //define CSKY_TTT, need set secu
//      .else
//      movi r2,0x17        //cache size 
//      .endif
//      
//      label set_crcr_size
//            st.w r2,(r3,0x0) //set crcr0
//            st.w r2,(r3,0x4) //set crcr1
//            st.w r2,(r3,0x8) //set crcr2
//            st.w r2,(r3,0xc) //set crcr3
//            addi r2,0x2
//            .if CSKY_TTT
//            cmpnei r2,0x81        //define CSKY_TTT, need set secu
//            .else
//            cmpnei r2,0x41   //set size form 0x17 ~ 0x3f
//            .endif
//      bt  set_crcr_size
//      
//label set_crcr_for_rdl_test
//      lrw  r3,0xe000f000 //crcr0 address
//      lrw  r1,0x1000005f //base 0x1000_0000 size 64K
//      st.w r1,(r3,0x08)   //
//      lrw  r1,0x2000005f //base 0x2000_0000 size 64K
//      st.w r1,(r3,0x0c)   //
//      lrw  r1,0x2000005f //base 0x2000_0000 size 64K
//      st.w r1,(r3,0x10) 
//      movi r1,0x0
//      st.w r1,(r3,0x14)   //close crcr3
//label cache_inv_all
//      movi r1,0x1
//      st.w r1,(r3,0x4) //cir inv_all
////store data to mem
//label rdl_test
//      lrw  r1,0x0
//      lrw  r2,0x10000000
//      lrw  r3,0x20000000
//      lrw  r4,0x20000000
//      lrw  r5,0x20008000  //0x2000_0000 + 32K
//      lrw  r6,0x10008000  //0x1000_0000 + 32K
//      lrw  r7,0x20008000  //0x2000_0000 + 32K
//      label set_mem
//      st.w r1,(r2,0)
//      st.w r1,(r3,0)
//      st.w r1,(r4,0)
//      st.w r1,(r5,0)
//      st.w r1,(r6,0)
//      st.w r1,(r7,0)
//      //address +4
//      addi r2,0x4
//      addi r3,0x4
//      addi r4,0x4
//      addi r5,0x4
//      addi r6,0x4
//      addi r7,0x4
//      //loop count
//      addi r1,0x1
//      cmpnei r1,0x4
//      bt set_mem
//      label load_data_to_cache
//      movih  r2,0x1000
//      movih  r3,0x2000
//      movih  r4,0x2000
//      lrw    r5,0x20008000
//      ld.w r1,(r2,0)
//      ld.w r1,(r3,0)
//      ld.w r1,(r4,0)
//      ld.w r1,(r5,0)
//      label modify_data_in_cache
//      movi r1,0x1234
//      st.w r1,(r2,0)
//      st.w r1,(r3,0)
//      st.w r1,(r4,0)
//      st.w r1,(r5,0)
//      label cacheline_replaced
//      lrw  r2,0x10008000
//      lrw  r3,0x20008000
//      ld.w r1,(r2,4)
//      cmpnei r1,0x1
//      bt __fail
//      ld.w r1,(r3,4)
//      cmpnei r1,0x1 
//      bt __fail
//
//      movih  r2,0x1000
//      movih  r3,0x2000
//      ld.w r1,(r2,0)
//      cmpnei r1,0x1234 
//      bt __fail
//      ld.w r1,(r3,0)
//      cmpnei r1,0x1234 
//      bt __fail
//
//      //movih  r4,0x2000
//      //lrw    r5,0x20008000
//      ld.w r1,(r4,0)
//      cmpnei r1,0x1234 
//      bt __fail
//      ld.w r1,(r5,0)
//      cmpnei r1,0x1234 
//      bt __fail


label int_test
//enable 
lrw r1,0xffffffff
lrw r2,0xE000E180//ICER
lrw r3,0xE000E100//ISER
st.w r1,(r3,0x0) //for cov enable  all int
st.w r1,(r2,0x0) //for cov disable all int
lrw  r4,0xffffffff     //enable  int32
st.w r4,(r3,0x0) //enable  32 int

//priority cov
movi r2,0x0
lrw r8,0x00000000
lrw r9,0xE000E400
label int_priority_cov
st.w r8,(r9,0x0)
st.w r8,(r9,0x4)
st.w r8,(r9,0x8)
st.w r8,(r9,0xc)
st.w r8,(r9,0x10)
st.w r8,(r9,0x14)
st.w r8,(r9,0x18)
st.w r8,(r9,0x1c)
lrw  r3,0x40404040
add  r8,r3
addi r2,0x1
cmpnei r2,0x4
bt int_priority_cov

//set priority 00 01  10 11 
lrw r8,0x004080c0
st.w r8,(r9,0x0) //set priority int0~int3
st.w r8,(r9,0x4) //set priority int4~int7
//set sec int
movi r1,0xf0
lrw r8,0xE000E240 //ISSR
st.w r1,(r8,0x0)  //set int4~int8 is sec_int



//lmpd awake
lrw r1,0xffffffff
lrw r8,0xE000E1C0//IWDR
lrw r9,0xE000E140//IWER
st.w r1,(r8,0x0)
st.w r1,(r9,0x0)
label int0_int7 test
//pending int0~int7
lrw  r1,0xff
lrw  r2,0xE000E280//ICPR
lrw  r3,0xE000E200//ISPR
st.w r1,(r2,0x0) //clear  pending
st.w r1,(r3,0x0) //enable pending
mov  r0,r0
mov  r0,r0
mov  r0,r0
mov  r0,r0
mov  r0,r0
mov  r0,r0
mov  r0,r0
mov  r0,r0
mov  r0,r0
movih  r1,0x2000 
ld.w   r2,(r1,0)   //check int32 =  33+32
cmpnei r2,65
bt __fail
ld.w   r2,(r1,0xc) //check int35 =  35+39 
cmpnei r2,74
bt __fail



//pending int8~int31
//set initial int counter
lrw   r1,0x20000020
movi  r4,0x0
st.w  r4,(r1,0x0) //clear  pending


lrw  r1,0x100
movi r4,0x0
label int8_int31_test
lrw  r2,0xE000E280//ICPR
lrw  r3,0xE000E200//ISPR
st.w r1,(r2,0x0) //clear  pending
st.w r1,(r3,0x0) //enable pending
mov  r0,r0
lsli r1,0x1      //pending bit
addi r4,0x1
cmpnei r4,24
bt  int8_int31_test

lrw    r1,0x20000020 
ld.w   r2,(r1,0)   
cmpnei r2,24       //24 int happened
bt __fail

label tspending_test
//set tspending priority TSPR  
lrw    r0,0xe000ec10
lrw    r1,0x3
st.w   r1,(r0,0)
//set tspending pending TSPEND 
lrw    r0,0xe000ec08
lrw    r1,0x1
st.w   r1,(r0,0)
//after 2 cycle of tspening 
mov r0,r0
mov r0,r0
//check 
lrw r1,0x8000
ld.w r2,(r1,0)
cmpnei r2,22
bt __fail



.if CSKY_TTT
label sec_int_in_unsec_world
        lrw r12, unsec_world_4
        lrw r13, 0x0
        st.w r12,(r13,0x0)
        .short 0xc000 
        .short 0x3c20  //wsc world change
        br go_back_4
        label unsec_world_4
        //sec int happened
        lrw  r1,0x20
        lrw  r3,0xE000E200//ISPR
        st.w r1,(r3,0x0) //enable pending   
        mov r0,r0
        mov r0,r0
        mov r0,r0
        lrw  r1,0x20000000
        ld.w r0,(r1,0x14)
        cmpnei r0,37
        bt __fail
        rte
label go_back_4

.endif 


lrw r1,0xffffffff
lrw r2,0xE000E180//ICER
st.w r1,(r2,0x0) //disable all int
movi r5,0x0
label set_coretimer

lrw  r1,0xE000E010 //CSR
movi r2,0x50
st.w r2,(r1,4)     //RVR,32cycle  
st.w r2,(r1,8)     //CVR, clear  
ld.w r2,(r1,4)     //RVR,32cycle  
cmpnei r2,0x50
bt __fail

movi r2,0x7
st.w r2,(r1,0)     //enable core timer
ld.w r2,(r1,0)     //enable core timer
cmpnei r2,0x7
bt __fail

addi r5,0x1

label inst_wait
cmpnei r5,0x1
bt inst_doze
wait
lrw r2,0xE000E280//ICPR
movi r1,0x1
st.w r1,(r2,0x0) //clear pending
br set_coretimer

label inst_doze
cmpnei r5,0x2
bt inst_stop
doze
lrw r2,0xE000E280//ICPR
movi r1,0x1
st.w r1,(r2,0x0) //clear pending
br set_coretimer

label inst_stop
cmpnei r5,0x3
bt lpmd_end
stop
lrw r2,0xE000E280//ICPR
movi r1,0x1
st.w r1,(r2,0x0) //clear pending
br set_coretimer
label lpmd_end
movi r2,0x0
st.w r2,(r1,0)     //disable core timer


label group0_cr_test
//lrw r1,0x80000000
//mtcr r1,cr<0,0>  //psr
//mfcr r2,cr<0,0> 
//cmpne r1,r2 
//bt __fail

lrw r1,0x00000000
mtcr r1,cr<1,0> //vbr
mfcr r2,cr<1,0> 
cmpne r1,r2 
bt __fail

lrw r1,0x80000000
mtcr r1,cr<13,0> //cpuid
mfcr r2,cr<13,0> 
lrw r1,0x4891073

cmpne r1,r2 
bt __fail


mfcr  r3,cr<2,0> 
mov   r2,r3
bclri r2,0x6 //clear ie
bclri r2,0x8 //clear ee
mtcr r2,cr<2,0> //epsr
mfcr r2,cr<2,0> //epsr
subu r3,r2
cmpnei r3,0x140
bt __fail

lrw r1,0x80000000
mtcr r1,cr<4,0> //epc
mfcr r2,cr<4,0> 
cmpne r1,r2 
bt __fail


mfcr  r3,cr<31,0> //CHR
mov   r2,r3
//bclri r2,0x1    //not support busrst
bclri r2,0x4    //disable increase nie int
mtcr r2,cr<31,0> 
mfcr r2,cr<31,0> 
subu r3,r2
cmpnei r3,0x10
bt __fail
br group3_cr_check

.align 4
label group3_cr_check
movi r2,0x240
mtcr r2,cr<0,3>  //NSPSR
mfcr r3,cr<0,3> 
cmpnei r3,0x240
bt __fail

mfcr r3,cr<1,3>  //NSVBR
cmpnei r3,0x0
bt __fail

mfcr r3,cr<10,3> //NSEBR
cmpnei r3,0x0
bt __fail


movi r2,0x240
mtcr r2,cr<2,3>  //NSEPSR
mfcr r3,cr<2,3> 
cmpnei r3,0x240
bt __fail


movi r2,0x240
mtcr r2,cr<4,3>  //NSEPSR
mfcr r3,cr<4,3> 
cmpnei r3,0x240
bt __fail

movi r2,0x22     //only [1:0]  valid
mtcr r2,cr<8,3>  //SDCR
mfcr r3,cr<8,3> 
cmpnei r3,0x2
bt __fail

movi r2,0x1     //only [0]  valid
mtcr r2,cr<8,3>  //SPCR
mfcr r3,cr<8,3> 
cmpnei r3,0x1
bt __fail

label had_reg_test
lrw  r2,0xee
lrw  r1,0xe0011010 //address MBCA
label all_had_reg_test
st.w r2,(r1,0)     //MBCA
ld.w r3,(r1,0)     //
cmpne r2,r3
bt __fail
st.w r2,(r1,4)     //MBCB
ld.w r3,(r1,4)     //
cmpne r2,r3
bt __fail

st.w r2,(r1,0xc)    //BABA
ld.w r3,(r1,0xc)    //
cmpne r2,r3
bt __fail

st.w r2,(r1,0x10)    //BABB
ld.w r3,(r1,0x10)    //
cmpne r2,r3
bt __fail

st.w r2,(r1,0x14)    //BAMA
ld.w r3,(r1,0x14)    //
cmpne r2,r3
bt __fail

st.w r2,(r1,0x18)    //BAMB
ld.w r3,(r1,0x18)    //
cmpne r2,r3
bt __fail

//st.w r2,(r1,0x20)    //bpyass
//ld.w r3,(r1,0x20)    //
//cmpne r2,r3
//bt __fail

label bank0_ctl_reg
//st.w r2,(r1,0x24)    //hcr
//ld.w r3,(r1,0x24)    //
//cmpne r2,r3
//bt __fail

//st.w r2,(r1,0x28)    //hsr read only
//ld.w r3,(r1,0x28)    //
//cmpne r2,r3
//bt __fail

//st.w r2,(r1,0x2c)    //hsr2
//ld.w r3,(r1,0x2c)    //
//cmpne r2,r3
//bt __fail


//st.w r2,(r1,0x34)    //wbbr
//ld.w r3,(r1,0x34)    //
//cmpne r2,r3
//bt __fail
lrw  r2,0x80000140
st.w r2,(r1,0x38)    //psr
ld.w r3,(r1,0x38)    //
cmpne r2,r3
bt __fail
label inst_bkpt_debug_exception_a_to_i
psrset ee

.if CSKY_TTT
lrw r1,0x3      //debug level
mtcr r1,cr<8,3> //sdcr
.else
lrw r1,0x1
mtcr r1,cr<8,3> //sdcr
.endif

label mem_bkptb_test
// ********set  HCR   = 0xc0  ***********
lrw r0,0xe0011034
lrw r1,0xc0   //memory bkpt
st.w r1,(r0,0)
// ********set  BABB  =  0x20000000     ***********
lrw r0,0xe0011020
lrw r1, 0x8000 
st.w r1,(r0,0)
// ********set  BAMB  = 0xff  ***********
lrw r0,0xe0011028
lrw r1,0xff
st.w r1,(r0,0)
// ********set  MBCB  = 0x0  ***********
lrw r0,0xe0011014
lrw r1,0x0
st.w r1,(r0,0)
//************set CSR.MBEE and FDB          
lrw r0,0xe0011054
lrw r1,0xc0
st.w r1,(r0,0)
mov r0,r0
lrw r12,0x1111
lrw r1,0x8000
lrw r15,mem_bkpt_a
addi r15,0x4
label mem_bkpt_a
st32.w r1,(r1,0)
cmpnei r12,0x7777
bt __fail


// ********set  HCR   = 0x10000000  ***********
lrw r0,0xe0011034 //enble DDAE
lrw r1,0x1fc00082 //enbale bkpt a ~ i
st.w r1,(r0,0)

//bkpt_a
// ********set  BABA  =  BKPT_HIT     ***********
lrw r0,0xe001101c
lrw r1, instbkpt_a
st.w r1,(r0,0)
// ********set  BAMA  = 0xff  ***********
lrw r0,0xe0011024
lrw r1,0xff
st.w r1,(r0,0)
// ********set  MBCA  = 0x0  ***********
lrw r0,0xe0011010
lrw r1,0x0
st.w r1,(r0,0)

//bkpt_b
// ********set  BABB  =  BKPT_HIT  a  ***********
lrw r0,0xe0011020
lrw r1, instbkpt_b
st.w r1,(r0,0)
// ********set  BAMB  = 0xff  ***********
lrw r0,0xe0011028
lrw r1,0xff
st.w r1,(r0,0)
// ********set  MBCB  = 0x10  ***********
lrw r0,0xe0011014
lrw r1,0x0
st.w r1,(r0,0)

//bkpt_c
lrw r0,0xe0011080
lrw r1,instbkpt_c  //address
st.w r1,(r0,0)
lrw r0,0xe0011084
lrw r1,0xff       //mask
st.w r1,(r0,0)
//bkpt_d
lrw r0,0xe0011088
lrw r1,instbkpt_d  //address
st.w r1,(r0,0)
lrw r0,0xe001108c
lrw r1,0xff       //mask
st.w r1,(r0,0)
//bkpt_e
lrw r0,0xe0011090
lrw r1,instbkpt_e  //address
st.w r1,(r0,0)
lrw r0,0xe0011094
lrw r1,0xff
st.w r1,(r0,0)
//bkpt_f
lrw r0,0xe0011098
lrw r1,instbkpt_f  //address
st.w r1,(r0,0)
lrw r0,0xe001109c
lrw r1,0xff
st.w r1,(r0,0)
//bkpt_g
lrw r0,0xe00110a0
lrw r1,instbkpt_g  //address
st.w r1,(r0,0)
lrw r0,0xe00110a4
lrw r1,0xff
st.w r1,(r0,0)
//bkpt_h
lrw r0,0xe00110a8
lrw r1,instbkpt_h  //address
st.w r1,(r0,0)
lrw r0,0xe00110ac
lrw r1,0xff
st.w r1,(r0,0)
//bkpt_i
lrw r0,0xe00110b0
lrw r1,instbkpt_i
st.w r1,(r0,0)
lrw r0,0xe00110b4
lrw r1,0xff
st.w r1,(r0,0)
//************set CSR.MBEE and FDB          
lrw r0,0xe0011054
lrw r1,0xc0
st.w r1,(r0,0)
lrw r12,0x1111
lrw r15,instbkpt_a
label instbkpt_a
//lrw  r0,0xe00110ec
//ld.w r1,(r0,0)
//cmpnei r1,0x2
//bt __fail
cmpnei r12,0x7777
bt __fail

//************set CSR.MBEE and FDB          
lrw r0,0xe0011054
lrw r1,0xc0
st.w r1,(r0,0)
lrw r12,0x1111
lrw r15,instbkpt_b
label instbkpt_b
//lrw  r0,0xe00110ec
//ld.w r1,(r0,0)
//cmpnei r1,0x2
//bt __fail
cmpnei r12,0x7777
bt __fail

//************set CSR.MBEE and FDB    
lrw r0,0xe0011054
lrw r1,0xc0
st.w r1,(r0,0)
//********** mbir check 
lrw r12,0x1111
lrw r15,instbkpt_c
label instbkpt_c
lrw  r0,0xe00110ec
ld.w r1,(r0,0)
cmpnei r1,0x3
bt __fail
cmpnei r12,0x7777
bt __fail
//************set CSR.MBEE and FDB    
lrw r0,0xe0011054
lrw r1,0xc0
st.w r1,(r0,0)
//check mbir
lrw r15,instbkpt_d
lrw r12,0x1111
label instbkpt_d
lrw  r0,0xe00110ec
ld.w r1,(r0,0)
cmpnei r1,0x4
bt __fail
cmpnei r12,0x7777
bt __fail

//************set CSR.MBEE and FDB    
lrw r0,0xe0011054
lrw r1,0xc0
st.w r1,(r0,0)
//check mbir
lrw r15,instbkpt_e
lrw r12,0x1111
label instbkpt_e
lrw  r0,0xe00110ec
ld.w r1,(r0,0)
cmpnei r1,0x5
bt __fail
cmpnei r12,0x7777
bt __fail

//************set CSR.MBEE and FDB    
lrw r0,0xe0011054
lrw r1,0xc0
st.w r1,(r0,0)
//check mbir
lrw r15,instbkpt_f
lrw r12,0x1111
label instbkpt_f
lrw  r0,0xe00110ec
ld.w r1,(r0,0)
cmpnei r1,0x6
bt __fail
cmpnei r12,0x7777
bt __fail

//************set CSR.MBEE and FDB    
lrw r0,0xe0011054
lrw r1,0xc0
st.w r1,(r0,0)
//check mbir
lrw r15,instbkpt_g
lrw r12,0x1111
label instbkpt_g
lrw  r0,0xe00110ec
ld.w r1,(r0,0)
cmpnei r1,0x7
bt __fail
cmpnei r12,0x7777
bt __fail

//************set CSR.MBEE and FDB    
lrw r0,0xe0011054
lrw r1,0xc0
st.w r1,(r0,0)
//check mbir
lrw r15,instbkpt_h
lrw r12,0x1111
label instbkpt_h
lrw  r0,0xe00110ec
ld.w r1,(r0,0)
cmpnei r1,0x8
bt __fail
cmpnei r12,0x7777
bt __fail

//************set CSR.MBEE and FDB    
lrw r0,0xe0011054
lrw r1,0xc0
st.w r1,(r0,0)
//check mbir
lrw r15,instbkpt_i
lrw r12,0x1111
label instbkpt_i
lrw  r0,0xe00110ec
ld.w r1,(r0,0)
cmpnei r1,0x9
bt __fail
cmpnei r12,0x7777
bt __fail


//************cov bkpt_type
lrw r0,0xe0011034 // HCR address
lrw r1,0x00 // bkpt_type_cov
label bkpt_type_cov
st.w r1,(r0,0)
addi r1,0x41
cmpnei r1,0x820
bt bkpt_type_cov

label bseti_cov
lrw r0,0
bseti r0,0
cmpnei r0,0x1
bt __fail
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
lrw   r1,0xffffffff
cmpne r0,r1
bt __fail

lrw r1,1




label had_reg_bank1
lrw  r2,0xee
lrw  r1,0xe0011080 //bkptc
lrw  r4,0xe00110b8 //bkpti+4
label set_bkptc_bkpti
st.w r2,(r1,0)     //bkpti
ld.w r3,(r1,0)     //
cmpne r2,r3
bt __fail
addi r1,0x4
cmpne r4,r1 
bt set_bkptc_bkpti


//----------------------finish----------------------//
label __success
br __exit

//******************************************************
.align 2
.data

label SRS_BASE
label SRS_1
mov  r0,r0
mov  r0,r0
label SRS_2
mov  r0,r0
mov  r0,r0
label SRS_3
mov  r0,r0
mov  r0,r0

#preserve_end









