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
//
// FILE NAME  : ph_smoke.rs
// AUTHOR     : qiu jing
// FUNCTION   : smoke case for ck801, will generate: 
//                1. all exceptions except idly
//                2. all instructions except idly
// NOTE       :
// $Id: 
// ****************************************************************************
//CaseID:
//  G1{U0[1]&&U1[1]&&U10[1]&&U11[1]&&U12[1]&&U13[I1]&&U14[1]&&U15[1]&&U2[1]&&U3[1]&&U4[1]&&U5[1]&&U6[1]&&U7[1]&&U8[1]&&U9[1]}
//  G2{U0[1]&&U1[1]}
//  G3{U0[1]&&U1[1]&&U2[1]&&U3[1]&&U4[1]}
//  G4{U0[1]&&U1[I1]}


//---------------------------------------//
//include file
//---------------------------------------//
#preserve_begin
.include  "core_init.h"

//---------------------------------------//
//main execution routine
//---------------------------------------//
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
bt FAIL_1

mtcr r0, cr<10,3> //NSEVBR
mfcr r0, cr<10,3> //NSEVBR
cmpnei r0,0x0
bt FAIL_1

// initial secure/super sp
lrw r14, 0x20001000

// initial nosecure/user sp
lrw r0, 0x20002000
mtcr r0,cr<14,1>
mfcr r1,cr<14,1>
cmpne r0,r1
bt FAIL_1

// non-secure/supv sp
lrw r0, 0x20003000
mtcr r0, cr<6,3>
mfcr r1, cr<6,3>
cmpne r0,r1
bt FAIL_1

// SUSP
lrw r0, 0x20004000
mtcr r0, cr<7,3>
mfcr r1, cr<7,3>
cmpne r0,r1
bt FAIL_1



label wsc_to_unsec_set_int_expt
        lrw r8, unsec_world_1
        lrw r7, 0x0
        st.w r8,(r7,0x0)
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
        bt FAIL_1
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

//rte form unsec world
rte
label go_back_1

.if CSKY_TTT  //remove sec int

lrw r1,0xffffffff
lrw r8,0xE000E240 //ISSR
st.w r1,(r8,0x0)  //sec int cov
ld.w r2,(r8,0x0)  //sec int cov
cmpne r1,r2
bt FAIL_1

lrw r8,0xE000E2C0 //ICSR
st.w r1,(r8,0x0)  //clear sec_int
ld.w r2,(r8,0x0)  //sec int cov
cmpnei r2,0
bt FAIL_1
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

SETEXP 1 MISALIGN_HANDLE_BEGIN MISALIGN_HANDLE_END
label MISALIGN_HANDLE_BEGIN
mov r1,r1
mov r1,r1
mov r1,r1
lrw r1,0xa000
rte
label MISALIGN_HANDLE_END

SETEXP 2 ACCESS_ERROR_BEGIN ACCESS_ERROR_END
label ACCESS_ERROR_BEGIN
mfcr r1, epc
addi r1, r1, 2
mtcr r1, epc
lrw  r3,0xacc
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
bt FAIL_1
mfcr r0,cr<4,0>
addi r0,4
mtcr r0,cr<4,0>
rte
label ILLEGAL_INST_EXP_END

//SETEXP 6 TRACE_EXP_BEGIN TRACE_EXP_END
//label TRACE_EXP_BEGIN
//addi16 r1, 4
//mfcr r2, cr<4, 0>
//lrw r1, 0x80064150
//mfcr r2, cr<2, 0>
//addi r11, 1
//rte
//label TRACE_EXP_END

SETEXP 7 BKPT_EXP_BEGIN BKPT_EXP_END  
label BKPT_EXP_BEGIN    
//********inside exception set r12=7777 
lrw       r6,0x1111
cmpne     r7, r6
bt FAIL_1    
lrw    r7, 0x7777    
//********Judge the value of EPC       
mov    r1, r8    
mfcr   r2, cr<4, 0>    
cmpne  r1,r2    
bt FAIL_1    
//********Judge the value of EPSR      
//mov    r1, r13    
//mfcr   r2, cr<2, 0>    
//cmpne  r1,r2    
//bt FAIL_1    
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

//SETEXP 10 AUTO_INT_BEGIN AUTO_INT_END
//label AUTO_INT_BEGIN
//movi r10, 0x9876
//rte
//label AUTO_INT_END

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





label START
//Enable interrupt
psrset ee,ie
label LOOP_BEGIN

//---------------------------------------//
//instructions
//---------------------------------------//
//addc16 instruction    2
mfcr r1,cr<0,0>
bclri r1,0x0
mtcr r1,cr<0,0>
lrw16 r1, 0x45555555
lrw16 r2, 0xabaaaaaa
lrw16 r4, 0xf0ffffff
addc16 r2, r1
cmpne r4, r2
bt FAIL_1
br NEXT_1

label FAIL_1
FAIL

label NEXT_1
mov  r0,r0

////addc instruction      3
//&lrw16 r1, 0x45555555
//&lrw16 r2, 0xabaaaaaa
//&lrw16 r4, 0xf0ffffff
//&addc32 r3, r2, r1
//&cmpne r4, r3
//&bt TEST_FAIL


//addi16 instruction    4
movi r1, 5
movi r4, 0xf
addi16 r1, 0xa
cmpne r4, r1
//&bt TEST_FAIL
bt FAIL_2
br NEXT_2

label FAIL_2
FAIL

label NEXT_2
mov  r0,r0



//addi instruction    5
movi r1, 5
movi r4, 0xa
addi r3, r1, 0x5
cmpne r4, r3
//&bt TEST_FAIL
bt FAIL_3
br NEXT_3

label FAIL_3
FAIL

label NEXT_3
mov  r0,r0

 
 

//addu16 instruction    6
lrw16 r1, 0x55555555
lrw16 r2, 0xaaaaaaaa
lrw16 r4, 0xffffffff
addu16 r2, r1 
cmpne r4, r2
//&bt TEST_FAIL
bt FAIL_4
br NEXT_4

label FAIL_4
FAIL

label NEXT_4
mov  r0,r0




////addu instruction    7
//&lrw16 r1, 0x55555555
//&lrw16 r2, 0xaaaaaaab
//&lrw16 r4, 0x0
//&addu32 r3, r2, r1 
//&cmpne r4, r3
//&bt TEST_FAIL
//
////and16 instruction    8
lrw16 r1, 0x55555555
lrw16 r2, 0xaaaaaaaa
lrw16 r4, 0
and16 r2, r1 
cmpne r4, r2
//&bt TEST_FAIL
bt FAIL_5
br NEXT_5

label FAIL_5
FAIL

label NEXT_5
mov  r0,r0


////and instruction     9
//&lrw16 r1, 0x0
//&lrw16 r2, 0xaaaaaaaa
//&lrw16 r4, 0
//&and32 r3, r2, r1 
//&cmpne r4, r3
//&bt TEST_FAIL
//
//////andi instruction     10
//&movi r1, 5
//&lrw16 r4, 0
//&andi r3, r1, 0xa
//&cmpne r4, r3
//&bt TEST_FAIL
//&addi16 r5, 1

//andn16 instruction    11
lrw16 r1, 0x55555555
lrw16 r2, 0xaaaaaaaa
lrw16 r4, 0xaaaaaaaa
andn16 r2, r1 
cmpne r4, r2
//&bt TEST_FAIL
bt FAIL_6
br NEXT_6

label FAIL_6
FAIL

label NEXT_6
mov  r0,r0


////andn instruction     12
//&lrw16 r1, 0x55555555
//&lrw16 r2, 0xaaaaaaaa
//&lrw16 r4, 0xaaaaaaaa
//&andn r3, r2, r1 
//&cmpne r4, r3
//&bt TEST_FAIL

////andni instruction     13
//&movi r1, 5
//&lrw16 r4, 0x5
//&andni r3, r1, 0xa
//&cmpne r4, r3
////&bt TEST_FAIL
//&bt FAIL_7
//&br NEXT_7
//
//&label FAIL_7
//&FAIL
//
//&label NEXT_7
//&mov  r0,r0
//

//asr16 instruction     14
lrw16 r1, 0xaaaaaaaa
lrw16 r2, 1
lrw16 r4, 0xd5555555
asr16 r1, r2
cmpne r4, r1
//&bt TEST_FAIL
bt FAIL_8
br NEXT_8

label FAIL_8
FAIL

label NEXT_8
mov  r0,r0


////asr instruction     15
//&lrw16 r1, 0xaaaaaaaa
//&lrw16 r2, 32
//&lrw16 r4, 0xffffffff
//&asr32 r3, r1, r2
//&cmpne r4, r3
//&bt TEST_FAIL
//
//////asrc instruction     16
//&lrw16 r1, 0x55555555
//&asrc r3, r1, 1
//&bf TEST_FAIL

//asri16 instruction     17
lrw16 r1, 0xaaaaaaaa
lrw16 r4, 0xd5555555
asri16 r1,r1,1
cmpne r4, r1
bt TEST_FAIL

//asri instruction     18
lrw16 r1, 0xaaaaaaaa
lrw16 r4, 0xd5555555
asri r3, r1, 1
cmpne r4, r3
bt TEST_FAIL

label INST_FINISH_A



//bclri16 instruction     19
lrw16 r1, 0xaaaaaaaa
lrw16 r4, 0xaaaaaaa8
bclri16 r1, 1
cmpne r4, r1
bt TEST_FAIL

////bclri instruction    20 
//&lrw16 r1, 0xaaaaaaaf
//&lrw16 r4, 0xaaaaaaa7
//&bclri32 r3, r1, 3
//&cmpne r4, r3
//&bt TEST_FAIL
//
//bmaski instruction    21 
//&lrw16 r4, 0x7fffffff
//&bmaski r1, 31
//&cmpne r4, r1
//&bt TEST_FAIL


//bf instruction    22

movi r1,0x0
movi r2,0x0
cmpne r2, r1
bf AFTER_BF
lrw16 r1, 0x55555555
br TEST_FAIL
label AFTER_BF



//br instruction    22
br AFTER_BR
lrw16 r1, 0x55555555
br TEST_FAIL
label AFTER_BR

//bseti16 instruction    23
lrw16 r1, 0x55555555
lrw16 r4, 0x55555557
bseti16 r1, 1
cmpne r4, r1
bt TEST_FAIL

////bseti instruction    24
//&lrw16 r1, 0x55555555
//&lrw16 r4, 0xd5555555
//&bseti32 r2, r1, 31
//&cmpne r4, r2
//&bt TEST_FAIL
//
//bsr instruction    25
bsr32 AFTER_BSR
lrw16 r1, 0x55555555
br TEST_FAIL
label AFTER_BSR

//btsti instruction    26
lrw16 r1, 0x55555555
btsti r1, 1
bt TEST_FAIL

label INST_FINISH_B


//cmphs16 instruction    27
lrw16 r1, 0xa5555555
lrw16 r2, 0xaaaaaaaa
cmphs16 r1, r2
bt TEST_FAIL


//cmphsi16 instruction    29
lrw16 r1, 0x5
cmphsi16 r1, 0xa
bt TEST_FAIL

////cmphsi instruction    30
//&lrw16 r1, 0x5
//&cmphsi32 r1, 0xa
//&bt TEST_FAIL

//cmplt16 instruction    31
lrw16 r1, 0x55555555
lrw16 r2, 0xffffffff
cmplt16 r1, r2
bt TEST_FAIL

////cmplti16 instruction    33
//&lrw16 r1, 0xf
//&cmplti16 r1, 0xa
//&bt TEST_FAIL
//&addi16 r5, 1

/////cmplti instruction    34
///&lrw16 r1, 0xf
///&cmplti r1, 0xa
///&bt TEST_FAIL
///&addi16 r5, 1

//cmpne16 instruction    35
lrw16 r1, 0xffffffff
lrw16 r2, 0xffffffff
cmpne16 r2, r1
bt TEST_FAIL

//cmpnei16 instruction   37 
lrw16 r1, 0x5
cmpnei16 r1, 0x5
bt TEST_FAIL

////cmpne instruction    38
//&lrw16 r1, 0xf
//&cmpnei32 r1, 0xf
//&bt TEST_FAIL

label INST_FINISH_C

////decf instruction    52
//&lrw16 r1, 0x5
//&lrw16 r2, 0x5
//&lrw16 r4, 0x5
//&btsti r1, 0
//&decf r2, r1, 5
//&cmpne r4, r2
//&bt TEST_FAIL
//
//
////dect instruction    56
//&lrw16 r1, 0x5
//&lrw16 r2, 0x5
//&lrw16 r4, 0x5
//&btsti r1, 1
//&dect r2, r1, 0x5
//&cmpne r4, r2
//&bt TEST_FAIL
//
////ff1 instruction   57
//&movi r1, 0         //RX = 0
//&ff1  r2, r1          //RZ = 32
//&movi r3, 32
////bne  r2, r3, TEST_FAIL
//&cmpne r2,r3
//&bt TEST_FAIL
//
////ff0 instruction   58
//
//&movi r1, 1         //RX = 0
//&ff0  r2, r1          //RZ = 32
//&movi r3, 0
////bne  r2, r3, TEST_FAIL
//&cmpne r2,r3
//&bt TEST_FAIL

//&label INST_FINISH_F


////grs instruction   62
//&grs r2,INST_FINISH_F
//&movi r3,0x0
//&cmpne r3, r2
//&bt TEST_FAIL



////incf instruction   62
//&lrw16 r1, 0x5
//&lrw16 r2, 0x5
//&lrw16 r4, 0x5
//&btsti r1, 0
//&incf r2, r1, 0x5
//&cmpne r4, r2
//&bt TEST_FAIL
//
////inct instruction   63
//&lrw16 r1, 0x5
//&lrw16 r2, 0x5
//&lrw16 r4, 0x5
//&btsti r1, 1
//&inct r2, r1, 0x5
//&cmpne r4, r2
//&bt TEST_FAIL
//
////ixh instruction   65
//&lrw16 r1, 0x5
//&lrw16 r2, 0x5
//&lrw16 r4, 0xf
//&ixh r3, r1, r2
//&cmpne r4, r3
//&bt TEST_FAIL
//
////ixw instruction   66
//&lrw16 r1, 0xb
//&lrw16 r2, 0x1
//&lrw16 r4, 0xf
//&ixw r3, r1, r2
//&cmpne r4, r3
//&bt TEST_FAIL
//
label INST_FINISH_I


//jmp instruction   39
lrw16 r1, AFTER_JMP
jmp r1
lrw16 r1, 0x55555555
br TEST_FAIL
label AFTER_JMP

//jmpi instruction   40
//jmpi AFTER_JMPI
//&mov r1,r1
//&bsr TEST_FAIL
//&label AFTER_JMPI

//jsr instruction   41
lrw16 r1, AFTER_JSR
jsr r1
lrw16 r1, 0x55555555
bsr32 TEST_FAIL
label AFTER_JSR

//jsri instruction   42
//&jsri AFTER_JSRI
//&lrw16 r1, 0x55555555
//&bsr TEST_FAIL
sync
label INST_FINISH_J


//ld.b && st.b instruction   43
lrw16 r1, 0xa100aaaa
lsri r1, 16
lrw16 r2, 0xa1a2a3aa
lrw16 r4, 0xaa
st.b r2, (r1,0)
ld.b r3, (r1,0)
cmpne r4, r3
bt TEST_FAIL

////ld.bs instruction   44
//&lrw16 r1, 0xa100aaaa
//&lsri r1, 16
//&lrw16 r2, 0xaaaaaaaa
//&lrw16 r4, 0xffffffaa
//&st.b r2, (r1,0)
//&ld.bs r3, (r1,0)
//&cmpne r4, r3
//&bt TEST_FAIL

//ld.h && st.h instruction   45
lrw16 r1, 0xa100aaaa
lsri r1, 16
lrw16 r2, 0x1111aaaa
lrw16 r4, 0xaaaaaaaa
lsri r4, 16
st.h r2, (r1,0)
ld.h r3, (r1,0)
cmpne r4, r3
bt TEST_FAIL



////ld.hs instruction   46
//&lrw16 r1, 0xa100aaaa
//&lsri r1, 16
//&lrw16 r2, 0xaaaaaaaa
//&lrw16 r4, 0xffffaaaa
//&st.h r2, (r1,0)
//&ld.hs r3, (r1,0)
//&cmpne r4, r3
//&bt TEST_FAIL
//&addi16 r5, 1

//ld.w && st.w instruction   47
lrw16 r1, 0xa100aaaa
lsri r1, 16
lrw16 r2, 0xaaaaaaaa
lrw16 r4, 0xaaaaaaaa
st.w r2, (r1,0)
ld.w r3, (r1,0)
cmpne r4, r3
bt TEST_FAIL
addi16 r5, 1

////ldm && stm instruction   48
//&lrw16 r1, 0xa100aaaa
//&lsri r1, 16
//&lrw16 r2, 0xaaaaaaaa
//&lrw16 r4, 0xaaaaaaaa
//&stm r2-r2, (r1)
//&ldm r3-r3, (r1)
//&cmpne r4, r3
//&bt TEST_FAIL
//&addi16 r5, 1

////ldr.b && str.b instruction   77
//&lrw16 r1, 0x100
//&lrw16 r2, 0x1
//&lrw16 r3, 0xaaaaaaaa
//&lrw16 r4, 0xaa
//&str.b r3, (r1,r2<<1)
//&ldr.b r8, (r1,r2<<1)
//&cmpne r4, r8
//&bt TEST_FAIL
//&addi16 r5, 1
//
////ldr.bs instruction   78
//&lrw16 r1, 0x100
//&lrw16 r2, 0x1
//&lrw16 r3, 0xaaaaaaaa
//&lrw16 r4, 0xffffffaa
//&str.b r3, (r1,r2<<1)
//&ldr.bs r8, (r1,r2<<1)
//&cmpne r4, r8
//&bt TEST_FAIL
//&addi16 r5, 1
//
////ldr.h && str.h instruction   79
//&lrw16 r1, 0x100
//&lrw16 r2, 0x1
//&lrw16 r3, 0xaaaaaaaa
//&lrw16 r4, 0xaaaa
//&str.h r3, (r1,r2<<1)
//&ldr.h r8, (r1,r2<<1)
//&cmpne r4, r8
//&bt TEST_FAIL
//&addi16 r5, 1
//
////ldr.hs instruction   80
//&lrw16 r1, 0x100
//&lrw16 r2, 0x1
//&lrw16 r3, 0xaaaaaaaa
//&lrw16 r4, 0xffffaaaa_
//&str.h r3, (r1,r2<<1)
//&ldr.hs r8, (r1,r2<<1)
//&cmpne r4, r8
//&bt TEST_FAIL
//&addi16 r5, 1
//
////ldr.w && str.w instruction   81
//&lrw16 r1, 0x100
//&lrw16 r2, 0
//&lrw16 r3, 0xffffffff
//&lrw16 r4, 0xffffffff
//&str.w r3, (r1,r2<<0)
//&ldr.w r8, (r1,r2<<0)
//&cmpne r4, r8
//&bt TEST_FAIL
//&addi16 r5, 1
//&cmpne r4, r1
//&bt TEST_FAIL
//
////lsl instruction   49
//&lrw16 r1, 0x55555555
//&lrw16 r2, 0x1
//&lrw16 r4, 0xaaaaaaaa
//&lsl32 r3, r1, r2
//&cmpne r4, r3
//&bt TEST_FAIL

////lslc instruction   50
//&lrw16 r1, 0x55555555
//&lslc r2, r1, 1
//&bt TEST_FAIL

//lsli16 instruction   51
lrw16 r1, 0x55555555
lrw16 r4, 0xaaaaaaaa
lsli16 r1,r1,1
cmpne r4, r1
bt TEST_FAIL

////lsli instruction   52
//&lrw16 r1, 0x55555555
//&lrw16 r4, 0xaaaaaaaa
//&lsli32 r2, r1, 1
//&cmpne r4, r2
//&bt TEST_FAIL

//lsr16 instruction   53
lrw16 r1, 0xaaaaaaaa
lrw16 r2, 0x1
lrw16 r4, 0x55555555
lsr16 r1, r2
cmpne r4, r1
bt TEST_FAIL

////lsr instruction   54
//&lrw16 r1, 0xaaaaaaaa
//&lrw16 r2, 0x1
//&lrw16 r4, 0x55555555
//&lsr32 r3, r1, r2
//&cmpne r4, r3

////lsrc instruction   55
//&lrw16 r1, 0xaaaaaaaa
//&lsrc r2, r1, 1
//&bt TEST_FAIL

//lsri16 instruction   56
lrw16 r1, 0xaaaaaaa1
lrw16 r4, 0x55555550
lsri16 r1,r1, 1
cmpne r4, r1
bt TEST_FAIL

////lsri instruction   57
//&lrw16 r1, 0xaaaaaaa0
//&lrw16 r4, 0x55555550
//&lsri32 r2, r1, 1
//&cmpne r4, r2
//&bt TEST_FAIL

label INST_FINISH_L
//mov16  instruction   58
lrw r1, 0x55555555
mov16 r4,r1
cmpne r4, r1
bt TEST_FAIL

////movi  instruction   58
//&movi r1, 0x5d01
//&lrw16 r4, 0x5d01
//&cmpne r4, r1
//&bt TEST_FAIL
//
////lrw   instruction   59
//&lrw  r1, 0x5f55
//&lrw16 r4, 0x5f550000
//&cmpne r4, r1
//&bt TEST_FAIL
//
//mult16  instruction  60 
lrw16 r1, 0x55555555
lrw16 r2, 2
lrw16 r4, 0xaaaaaaaa
mult16 r1, r2
cmpne r4, r1
bt TEST_FAIL


////mult  instruction   61
//&lrw16 r1, 0x55555555
//&lrw16 r2, 2
//&lrw16 r4, 0xaaaaaaaa
//&mult32 r3, r1, r2
//&cmpne r4, r3
//&bt TEST_FAIL

////mvc  instruction   62
//&lrw16 r1, 1
//&lrw16 r2, 0xffffffff
//&lrw16 r4, 1
//&btsti r1, 0
//&mvc r2
//&cmpne r4, r2
//&bt TEST_FAIL
//
//
////movf  instruction   63
//&movi r1,0x0
//&movi r2,0x0
//&movi r4,0x12
//&cmpne r1,r2
//&movf r5,r4
//&cmpne r5,r4
//&bt TEST_FAIL
//
////movt  instruction   63
//&movi r1,0x2
//&movi r2,0x0
//&movi r4,0x12
//&cmpne r1,r2
//&movt r5,r4
//&cmpne r5,r4
//&bt TEST_FAIL
//


label INST_FINISH_M

//nor16  instruction   64
lrw16 r1, 0x5555ffff
lrw16 r2, 0xaaaa0001
bclri r2,0x0
lrw16 r4, 0
nor16 r2, r1
cmpne r4, r2
bt TEST_FAIL
addi16 r5, 1

////nor  instruction   65
//&lrw16 r1, 0x55555555
//&lrw16 r2, 0xaaaaaaaa
//&lrw16 r4, 0
//&nor r3, r2, r1
//&cmpne r4, r3
//&bt TEST_FAIL
//&addi16 r5, 1
//
//&label INST_FINISH_N


//or16  instruction   66
lrw16 r1, 0x55555555
lrw16 r2, 0xaaaaaaaa
lrw16 r4, 0xffffffff
or16 r2, r1
cmpne r4, r2
bt TEST_FAIL
addi16 r5, 1

////or  instruction   67
//&lrw16 r1, 0x55555555
//&lrw16 r2, 0xaaaaaaaa
//&lrw16 r4, 0xffffffff
//&or r3, r2, r1
//&cmpne r4, r3
//&bt TEST_FAIL
//&addi16 r5, 1

////ori  instruction   68
//&lrw16 r1, 0x55555555
//&lrw16 r4, 0x5555555f
//&ori r2, r1, 0xf
//&cmpne r4, r2
//&bt TEST_FAIL
//&addi16 r5, 1


label INST_FINISH_O

////psrclr && psrset  instruction   69
//&mfcr r1, cr<0,0>
//&mov r2, r1
//&mov r3, r1
//&psrclr ee
//&bclri r2, 8
//&mfcr r4, cr<0,0>
//&cmpne r4, r2
//&bt TEST_FAIL
//&psrset ee
//&bseti r3, 8
//&mfcr r4, cr<0,0>
//&cmpne r4, r3
//&bt TEST_FAIL
//&mtcr r1, cr<0,0>

//rotl16  instruction   72
lrw16 r1, 0x55555555
lrw16 r2, 2
lrw16 r4, 0x55555555
rotl16 r1, r2
cmpne r4, r1
bt TEST_FAIL

////rotl  instruction   73
//&lrw16 r1, 0xaaaaaaaa
//&lrw16 r2, 2
//&lrw16 r4, 0xaaaaaaaa
//&rotl32 r3, r1, r2
//&cmpne r4, r3
//&bt TEST_FAIL

//rotli16  instruction   74
//&lrw16 r1, 0x55555555
//&lrw16 r4, 0x55555555
//&rotli16 r1,r1,2
//&cmpne r4, r1
//&bt TEST_FAIL

////rotli  instruction   75
//&lrw16 r1, 0x55555555
//&lrw16 r4, 0x55555555
//&rotli32 r3, r1, 2
//&cmpne r4, r3
//&bt TEST_FAIL

label INST_FINISH_R


//sexth  instruction   76
lrw16 r1, 0x55555555
lrw16 r4, 0x55551212
lsri  r4,16
sexth r2, r1
cmpne r4, r2
bt TEST_FAIL

////sextb  instruction   77
lrw16 r1, 0x55555555
lrw16 r4, 0x55
sextb r2, r1
cmpne r4, r2
bt TEST_FAIL


////subc16  instruction   78
//&lrw16 r1, 0x55555555
//&lrw16 r2, 0xaaaaaaaa
//&lrw16 r4, 0x55555555
//&btsti r1, 0
//&subc16 r2, r1
//&cmpne r4, r2
//&bt TEST_FAIL
//
////subc  instruction   79
//&lrw16 r1, 0x55555555
//&lrw16 r2, 0xaaaaaaaa
//&lrw16 r4, 0x55555555
//&btsti r1, 0
//&subc r3, r2, r1
//&cmpne r4, r3
//&bt TEST_FAIL

//subi16  instruction   80
lrw16 r1, 0xa
lrw16 r4, 0x5
subi16 r1, 0x5
cmpne r4, r1
bt TEST_FAIL

////subi  instruction   81
//&lrw16 r1, 0xaa
//&lrw16 r4, 0x55
//&subi r2, r1, 0x55
//&cmpne r4, r2
//&bt TEST_FAIL

//subu16  instruction   82
lrw16 r1, 0x55555555
lrw16 r2, 0xaaaaaaaa
lrw16 r4, 0x55555555
subu16 r2, r1
cmpne r4, r2
bt TEST_FAIL

//subu  instruction   83
lrw16 r1, 0x55555555
lrw16 r2, 0xaaaaaaaa
lrw16 r4, 0x55555555
subu r3, r2, r1
cmpne r4, r3
bt TEST_FAIL

//sync  instruction   83
sync

label INST_FINISH_S



//tst16  instruction   84
lrw16 r1, 0x55555555
lrw16 r2, 0xaaaaaaaa
tst16 r1, r2
bt TEST_FAIL


//tstnbz16  instruction   134
lrw16 r1, 0x55555500
tstnbz16 r1
bt TEST_FAIL



label INST_FINISH_T


//xor16  instruction   86
lrw16 r1, 0x55555555
lrw16 r2, 0xaaaaaaaa
lrw16 r4, 0xffffffff
xor16 r1, r2
cmpne r4, r1
bt TEST_FAIL

////xor  instruction   87
//&lrw16 r1, 0x55555555
//&lrw16 r2, 0xaaaaaaaa
//&lrw16 r4, 0xffffffff
//&xor32 r3, r1, r2
//&cmpne r4, r3
//&bt TEST_FAIL

////xori  instruction   88
//&lrw16 r1, 0x5
//&lrw16 r4, 0xf
//&xori r2, r1, 0xa
//&cmpne r4, r2
//&bt TEST_FAIL

////xsr  instruction   89
//&lrw16 r1, 0xaaaaaaaa
//&lrw16 r4, 0xd5555555
//&btsti r1, 1
//&xsr r2, r1, 1
//&bt TEST_FAIL

////xtrb0  instruction   140
//&lrw16 r1, 0x00555555
//&lrw16 r4, 0
//&xtrb0 r2, r1
//&cmpne r4, r2
//&bt TEST_FAIL
//
////xtrb1  instruction   141
//&lrw16 r1, 0x55005555
//&lrw16 r4, 0
//&xtrb1 r2, r1
//&cmpne r4, r2
//&bt TEST_FAIL
//
////xtrb2  instruction   142
//&lrw16 r1, 0x55550055
//&lrw16 r4, 0
//&xtrb2 r2, r1
//&cmpne r4, r2
//&bt TEST_FAIL
//
////xtrb3  instruction   143
//&lrw16 r1, 0x55555500
//&lrw16 r4, 0
//&xtrb3 r2, r1
//&cmpne r4, r2
//&bt TEST_FAIL



label INST_FINISH_X

//zextb  instruction   76
lrw16 r1, 0x55555555
lrw16 r4, 0x55
zextb r2, r1
cmpne r4, r2
bt TEST_FAIL


//zexth  instruction   76
lrw16 r1, 0x55555555
lrw16 r4, 0x55554242
lsri  r4, 16
zexth r2, r1
cmpne r4, r2
bt TEST_FAIL

//addi.sp rz,sp,imm8 instruction   8888
mov r1, sp
lrw16 r3, 0x55555000
mov   sp,r3
lrw16 r3, 0x55555000
lrw16 r4, 0x55555154
addi16 r2, sp, 0x154
cmpne r4, r2
bt TEST_FAIL
cmpne r3, sp
bt TEST_FAIL
mov sp, r1

//addi.sp sp,sp,imm7 instruction   8889
mov r1, sp
lrw16 r4, 0x55555000
mov   sp, r4
lrw16 r4, 0x55555154
addi16 sp, sp, 0x154
cmpne r4, sp
bt TEST_FAIL
mov sp, r1

//subi.sp sp,sp,imm7 instruction   8890
mov r1, sp
lrw16 r4, 0x55555154
mov   sp, r4
lrw16 r4, 0x55555000
subi16 sp, sp, 0x154
cmpne r4, sp
bt TEST_FAIL
mov sp, r1

//push instruction   8891
mov r1, sp
lrw r2, 0xa1201111
lsri r2,16
mov  sp,r2
lrw r3, 0xa1101111
lsri r3,16
movi r4 , 0x4
movi r5 , 0x5
movi r6 , 0x6
movi r7 , 0x7
push r4-r7
cmpne r3, sp
bt TEST_FAIL

//pop instruction   8892
movi r4 , 0x0
movi r5 , 0x0
movi r6 , 0x0
movi r7 , 0x0
lrw  r4, POP_CONT
mov  r15,r4
movi r4,0x0
pop r4-r7
br TEST_FAIL
label POP_CONT
lrw16 r3, 0xa120aaaa
lsri  r3,16
cmpnei r4 , 0x4
bt TEST_FAIL
cmpnei r5 , 0x5
bt TEST_FAIL
cmpnei r6 , 0x6
bt TEST_FAIL
cmpnei r7 , 0x7
bt TEST_FAIL
cmpne r3, sp
bt TEST_FAIL
mov sp, r1

//addu16 instruction    8893
lrw16 r1, 0x55555555
lrw16 r2, 0xaaaaaaaa
lrw16 r4, 0xffffffff
addu16 r3, r2, r1
cmpne r4, r3
bt TEST_FAIL

//subu16 instruction    8894
lrw16 r1, 0x55555555
lrw16 r2, 0xaaaaaaaa
lrw16 r4, 0x55555555
subu16 r3, r2, r1
cmpne r4, r3
bt TEST_FAIL

//addi16 rz,rx,imm3 instruction    8895
lrw16 r1, 0x55555555
lrw16 r4, 0x5555555a
addi16 r2, r1, 5
cmpne r4, r2
bt TEST_FAIL

//subi16 rz,rx,imm3 instruction    8896
lrw16 r1, 0x55555555
lrw16 r4, 0x55555550
subi16 r2, r1, 5
cmpne r4, r2
bt TEST_FAIL

//st16.w rz,sp instruction   8897
mov r1, sp
lrw16 r4, 0xa1001111
lsri  r4,16
mov   sp, r4
lrw16 r4, 0x55555555
stw r4, (sp, 0x300)

//ld16.w rz,sp instruction   8898
movi r3, 0
ldw r3, (sp, 0x300)
cmpne r4, r3
bt TEST_FAIL

label INST_FINISH_Z
lrw r1, ABCDEF
mov r15,r1
movi r4,0x4
movi r5,0x5
push r15,r4-r5
pop  r15,r4-r5
label ABCDEF
cmpnei r4,0x4
bt TEST_FAIL
cmpnei r5,0x5
bt TEST_FAIL

label mul_and_lsr_instruction
lrw r1, 0x1
lrw r3, 0x1
lrw r2,0xffffffff
label mult_and_lsr_cov
mult r1,r2
cmpne r1,r2 
bt TEST_FAIL
lrw r1, 0x1
lrw r2,0xffffffff
lsr r2,r3
addi r3,0x1
cmpnei r2,0x0
bt mult_and_lsr_cov


label mvcv_instruction
mvcv r1
cmpnei r1,0x1 //psr.c reverse
bt TEST_FAIL




br int_test

//---------------------------------------//
//fail
//---------------------------------------//
label TEST_FAIL
FAIL



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
lrw r7,0xE000E400
label int_priority_cov
st.w r8,(r7,0x0)
st.w r8,(r7,0x4)
st.w r8,(r7,0x8)
st.w r8,(r7,0xc)
st.w r8,(r7,0x10)
st.w r8,(r7,0x14)
st.w r8,(r7,0x18)
st.w r8,(r7,0x1c)
lrw  r3,0x40404040
add  r8,r3
addi r2,0x1
cmpnei r2,0x4
bt int_priority_cov

//set priority 00 01  10 11 
lrw r8,0x004080c0
st.w r8,(r7,0x0) //set priority int0~int3
st.w r8,(r7,0x4) //set priority int4~int7
//set sec int
movi r1,0xf0
lrw r8,0xE000E240 //ISSR
st.w r1,(r8,0x0)  //set int4~int8 is sec_int



//lmpd awake
lrw r1,0xffffffff
lrw r8,0xE000E1C0//IWDR
lrw r7,0xE000E140//IWER
st.w r1,(r8,0x0)
st.w r1,(r7,0x0)
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
lrw   r1,0x20000000 
ld.w   r2,(r1,0)   //check int32 =  33+32
lrw    r3,65
cmpne r2,r3
bt TEST_FAIL_2
ld.w   r2,(r1,0xc) //check int35 =  35+39 
lrw    r3,74
cmpne r2,r3
bt TEST_FAIL_2



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
bt TEST_FAIL_2

.if CSKY_TTT
label sec_int_in_unsec_world
        lrw r8, unsec_world_4
        lrw r7, 0x0
        st.w r8,(r7,0x0)
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
        lrw   r3,37
        cmpne r0,r3
        bt TEST_FAIL_2
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
lrw  r3,0x50
cmpne r2,r3
bt TEST_FAIL_2

movi r2,0x7
st.w r2,(r1,0)     //enable core timer
ld.w r2,(r1,0)     //enable core timer
cmpnei r2,0x7
bt TEST_FAIL_2

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



label close_mgu1
      movi r1,0x0
      mtcr r1,cr<18,0>

      lrw r8,0xffffff00
      mtcr r8,cr<19,0> //set,primision
      mfcr r1,cr<19,0>  //r1 use select which mgu
      cmpne r1,r8
      bt TEST_FAIL_2

      movi r1,0x3       //set mgu region 3
      mtcr r1,cr<21,0>  //r1 use select which mgu
      mfcr r1,cr<21,0>  //r1 use select which mgu
      cmpnei r1,0x3
      bt TEST_FAIL_2
      lrw r2,0x3f      //mgu size 4G 
      mtcr r2,cr<20,0>
      mfcr r1,cr<20,0>  //r1 use select which mgu
      cmpne r1,r2
      bt TEST_FAIL_2

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
            bt TEST_FAIL_2
            addi r2,0x2
            lrw  r4,0x41
            cmpne r2,r4   //set size form 0x17 ~ 0x3f
      bt  set_mgu_size
      
      addi r1,0x1
      cmpnei r1,0x8          //ifdef mgu8
bt  set_mgu0_mgu7


label set_mgu_primision
      //mgu premission cov
      lrw r8,0xfe5555fe
      lrw r7, 0x0
      mtcr r8,cr<19,0> //set,primision
      mfcr r7,cr<19,0>
      cmpne r8,r7
      bt TEST_FAIL_2

      lrw r8,0xfeaaaafe
      lrw r7, 0x0
      mtcr r8,cr<19,0> //set,primision
      mfcr r7,cr<19,0>
      cmpne r8,r7
      bt TEST_FAIL_2

      lrw r8,0xfeff3ffe
      lrw r7, 0x0
      mtcr r8,cr<19,0> //set,primision
      mfcr r7,cr<19,0>
      cmpne r8,r7
      bt TEST_FAIL_2

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

      lrw r1, 0x8000
      lrw r2, 0x777
      st.w r2, (r1,0)
      ld.w r3, (r1,0)
      cmpne r3, r2
      bt  TEST_FAIL_2
      //lrw r1, 0x20001000
      //movi r2, 0x777
      //st.w r2, (r1,0)
      //ld.w r3, (r1,0)
      //cmpnei r3, 0x777
      //bt  TEST_FAIL_2
label check_access_err
      lrw r1, 0x20001000
      lrw r2, 0x777
      st16.w r2, (r1,0)
      lrw    r4,0xacc
      cmpne r3, r4
      bt  TEST_FAIL_2

label wsc_to_unsec_accerr
        lrw r8, unsec_world_3
        lrw r7, 0x0
        st.w r8,(r7,0x0)
        .short 0xc000 
        .short 0x3c20  //wsc world change
        br go_back_3
        label unsec_world_3
        //access error
        movi r3,0x0
        lrw r1, 0x20001000
        lrw r2, 0x777
        st16.w r2, (r1,0)
	lrw    r4,0xacc
	cmpne r3, r4
        bt  TEST_FAIL_2
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
      
      lrw r8,0xffffff00
      mtcr r8,cr<19,0> //set,primision

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
      bt TEST_FAIL_2
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
      bt TEST_FAIL_2
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
      bt TEST_FAIL_2
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
      bt TEST_FAIL_2
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
      bt TEST_FAIL_2
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
      bt TEST_FAIL_2
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
      bt TEST_FAIL_2

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
      bt TEST_FAIL_2
      //close mgu
      movi r1,0
      mtcr r1,cr<18,0>
      br had_reg_test

label TEST_FAIL_2
FAIL


label had_reg_test
lrw  r2,0xee
lrw  r1,0xe0011010 //address MBCA

label all_had_reg_test
st.w r2,(r1,0)     //MBCA
ld.w r3,(r1,0)     //
cmpne r2,r3
bt TEST_FAIL_3
st.w r2,(r1,4)     //MBCB
ld.w r3,(r1,4)     //
cmpne r2,r3
bt TEST_FAIL_3

st.w r2,(r1,0xc)    //BABA
ld.w r3,(r1,0xc)    //
cmpne r2,r3
bt TEST_FAIL_3

st.w r2,(r1,0x10)    //BABB
ld.w r3,(r1,0x10)    //
cmpne r2,r3
bt TEST_FAIL_3

st.w r2,(r1,0x14)    //BAMA
ld.w r3,(r1,0x14)    //
cmpne r2,r3
bt TEST_FAIL_3

st.w r2,(r1,0x18)    //BAMB
ld.w r3,(r1,0x18)    //
cmpne r2,r3
bt TEST_FAIL_3


lrw r1,0xe0011080
st.w r2,(r1,0x0)    //BABC
ld.w r3,(r1,0x0)    //
cmpne r2,r3
bt TEST_FAIL_3

lrw r1,0xe0011080
st.w r2,(r1,0x4)    //BAMC
ld.w r3,(r1,0x4)    //
cmpne r2,r3
bt TEST_FAIL_3

lrw r1,0xe0011080
st.w r2,(r1,0x8)    //BABD
ld.w r3,(r1,0x8)    //
cmpne r2,r3
bt TEST_FAIL_3

lrw r1,0xe0011080
st.w r2,(r1,0xc)    //BAMD
ld.w r3,(r1,0xc)    //
cmpne r2,r3
bt TEST_FAIL_3

lrw r1,0xe0011080
st.w r2,(r1,0x10)    //BABE
ld.w r3,(r1,0x10)    //
cmpne r2,r3
bt TEST_FAIL_3

lrw r1,0xe0011080
st.w r2,(r1,0x14)    //BAME
ld.w r3,(r1,0x14)    //
cmpne r2,r3
bt TEST_FAIL_3

lrw r1,0xe0011080
st.w r2,(r1,0x18)    //BABF
ld.w r3,(r1,0x18)    //
cmpne r2,r3
bt TEST_FAIL_3

lrw r1,0xe0011080
st.w r2,(r1,0x1c)    //BAMF
ld.w r3,(r1,0x1c)    //
cmpne r2,r3
bt TEST_FAIL_3


lrw r1,0xe0011080
st.w r2,(r1,0x20)    //BABG
ld.w r3,(r1,0x20)    //
cmpne r2,r3
bt TEST_FAIL_3

lrw r1,0xe0011080
st.w r2,(r1,0x24)    //BAMG
ld.w r3,(r1,0x24)    //
cmpne r2,r3
bt TEST_FAIL_3


lrw r1,0xe0011080
st.w r2,(r1,0x28)    //BABH
ld.w r3,(r1,0x28)    //
cmpne r2,r3
bt TEST_FAIL_3

lrw r1,0xe0011080
st.w r2,(r1,0x2c)    //BAMH
ld.w r3,(r1,0x2c)    //
cmpne r2,r3
bt TEST_FAIL_3

lrw r1,0xe0011080
st.w r2,(r1,0x30)    //BABI
ld.w r3,(r1,0x30)    //
cmpne r2,r3
bt TEST_FAIL_3

lrw r1,0xe0011080
st.w r2,(r1,0x34)    //BAMI
ld.w r3,(r1,0x34)    //
cmpne r2,r3
bt TEST_FAIL_3

//lrw r0,0xe0011080
//st.w r2,(r1,0x20)    //BABH
//ld.w r3,(r1,0x20)    //
//cmpne r2,r3
//bt TEST_FAIL_3
//
//lrw r0,0xe0011080
//st.w r2,(r1,0x24)    //BAMH
//ld.w r3,(r1,0x24)    //
//cmpne r2,r3
//bt TEST_FAIL_3



//************cov bkpt_type
lrw r0,0xe0011034 // HCR address
lrw r1,0x00 // bkpt_type_cov
label bkpt_type_cov
st.w r1,(r0,0)
addi r1,0x41
lrw  r6,0x820
cmpne r1,r6
bt bkpt_type_cov

label bseti_cov
lrw r0,0
bseti r0,0
cmpnei r0,0x1
bt TEST_FAIL_3
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
bt TEST_FAIL_3

lrw r1,1

//-------------------------------------//
//exit
//---------------------------------------//
label EXIT_2
EXIT
//---------------------------------------//
//fail
//---------------------------------------//
label TEST_FAIL_3
FAIL
#preserve_end
