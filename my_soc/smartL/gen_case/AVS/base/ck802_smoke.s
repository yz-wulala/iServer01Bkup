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
// SMART_R    : yes  
// FUNCTION   : Test all instructions
// METHOD     :
// NOTE       : basic inst test
// ****************************************************************************
.text
.align 1
.export main
main:
.set LD_ADDR, 0x60000300

//*************************************************
//             Main Start                        //
//*************************************************


//*********************************Arithmetic Operation*****************************
//**********************************ADDER*********************************************
//addc32,addc16
mfcr r1,cr<0,0>
bclri r1,0x0
mtcr r1,cr<0,0>
lrw r1, 0x45555555
lrw r2, 0xabaaaaaa
lrw r4, 0xf0ffffff
addc16 r2, r1
bt	TEST_FAIL
cmpne r4, r2
bt  TEST_FAIL
lrw r1, 0x1
lrw r2, 0xffffffff
lrw r4, 0x0
addc32 r3, r2, r1
bf	TEST_FAIL
cmpne r4, r3
bt  TEST_FAIL

//addi16,addi32
lrw r1, 0xffffff01
movi r4, 0x0
addi16 r1, 0xff
cmpne r4, r1
bt  TEST_FAIL
lrw r1, 0xfffff000
lrw r4, 0xffffffff
addi r3, r1, 0xfff
cmpne r4, r3
bt  TEST_FAIL

//addu16,addu32
lrw r1, 0x55555555
lrw r2, 0xaaaaaaaa
lrw r4, 0xffffffff
addu16 r2, r1
cmpne r4, r2
bt  TEST_FAIL
lrw r1, 0x55555555
lrw r2, 0xaaaaaaab
lrw r4, 0x0
addu32 r3, r2, r1
cmpne r4, r3
bt  TEST_FAIL

//subc16, subc32
lrw r2, 0x55555555
lrw r1, 0xaaaaaaaa
lrw r4, 0xaaaaaaab
btsti r2, 0
subc16 r2, r1
bt  TEST_FAIL
cmpne r4, r2
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r2, 0x0
lrw r4, 0x1
btsti r4, 0
subc32 r3, r2, r1
bt	TEST_FAIL
cmpne r4, r3
bt  TEST_FAIL

//subi16,subi32
lrw r1, 0xffffffff
lrw r4, 0xffffff00
subi16 r1, 0xff
cmpne r4, r1
bt  TEST_FAIL
lrw r1, 0xaa
lrw r4, 0x55
subi32 r2, r1, 0x55
cmpne r4, r2
bt  TEST_FAIL

//subu16,subu32,rsub
lrw r1, 0xffffffff
lrw r2, 0x0
lrw r4, 0x1
subu16 r2, r1
subu r3, r2, r1
bt  TEST_FAIL
cmpne r4, r2
bt  TEST_FAIL

mfcr r1,cr<0,0>
bseti r1,0x0
mtcr r1,cr<0,0>
lrw r1, 0xffffffff
lrw r2, 0x0
lrw r4, 0x1
subu32 r3, r2, r1
bf  TEST_FAIL
cmpne r4, r3
bt  TEST_FAIL

lrw r1, 0x55555555
lrw r2, 0xaaaaaaaa
lrw r4, 0x55555555
rsub32 r3, r1, r2
cmpne r4, r3
bt  TEST_FAIL

//ixh,ixw
lrw r1, 0x80000000
lrw r2, 0x40000000
lrw r4, 0x0
ixh r3, r1, r2
bt  TEST_FAIL
cmpne r4, r3
bt  TEST_FAIL

lrw r1, 0xb
lrw r2, 0x1
lrw r4, 0xf
ixw r3, r1, r2
cmpne r4, r3
bt  TEST_FAIL

//incf,inct
lrw r1, 0xffffffe1
lrw r4, 0x0
btsti r1, 1
incf r2, r1, 0x1f
bt  TEST_FAIL
cmpne r4, r2
bt  TEST_FAIL
lrw r1, 0x5
lrw r2, 0x5
lrw r4, 0x5
btsti r1, 1
inct r2, r1, 0x5
cmpne r4, r2
bt  TEST_FAIL

//decf,dect
lrw r1, 0x1e
lrw r2, 0x5
lrw r4, 0xffffffff
btsti r1, 0
decf r2, r1, 0x1f
cmpne r4, r2
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r2, 0xffffffff
lrw r4, 0xffffffff
btsti r1, 1
dect r2, r1, 0x0
cmpne r4, r2
bt  TEST_FAIL

//***********************************LOGIC*****************************************
//and16,and32
lrw r1, 0xffffffff
lrw r2, 0x0
lrw r4, 0
and16 r2, r1
cmpne r4, r2
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r2, 0xffffffff
lrw r4, 0xffffffff
and32 r3, r2, r1
cmpne r4, r3
bt  TEST_FAIL

//andi32,andni32
lrw	r1, 0xffffffff
lrw r4, 0xfff
andi r3, r1, 0xfff
cmpne r4, r3
bt  TEST_FAIL
lrw	r1, 0xffffffff
lrw r4, 0xfffff000
andni r3, r1, 0xfff
cmpne r4, r3
bt  TEST_FAIL

//andn32,andn16
lrw r1, 0xffffffff
lrw r2, 0xffffffff
lrw r4, 0x0
andn16 r2, r1
cmpne r4, r2
bt  TEST_FAIL
lrw r1, 0x0
lrw r2, 0xffffffff
lrw r4, 0xffffffff
andn r3, r2, r1
cmpne r4, r3
bt  TEST_FAIL

//or16,or32,ori32
lrw r1, 0xffffffff
lrw r2, 0x0
lrw r4, 0xffffffff
or16 r2, r1
cmpne r4, r2
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r2, 0xffffffff
lrw r4, 0xffffffff
or r3, r2, r1
cmpne r4, r3
bt  TEST_FAIL
lrw r1, 0xffff0000
lrw r4, 0xffffffff
ori r2, r1, 0xffff
cmpne r4, r2
bt  TEST_FAIL

//xor16,xor32,xori32
lrw r1, 0x55555555
lrw r2, 0xaaaaaaaa
lrw r4, 0xffffffff
xor16 r1, r2
cmpne r4, r1
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r2, 0xffffffff
lrw r4, 0x0
xor32 r3, r1, r2
cmpne r4, r3
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r4, 0xfffff000
xori r2, r1, 0xfff
cmpne r4, r2
bt  TEST_FAIL

//nor16,nor32
lrw r1, 0x5555ffff
lrw r2, 0xaaaa0000
lrw r4, 0
nor16 r2, r1
cmpne r4, r2
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r2, 0x0
lrw r4, 0
nor32 r3, r2, r1
cmpne r4, r3
bt  TEST_FAIL

//not16,not32
lrw r1, 0xffffffff
lrw	r2, 0x0
not16 r1
cmpne r1, r2
bt  TEST_FAIL
lrw r1, 0x0
lrw r4, 0xffffffff
not32 r2, r1
cmpne r4, r2
bt  TEST_FAIL

//**************************************SHIFTER***********************************
//lsl16,lsl32
lrw r1, 0xffffffff
lrw r2, 0xffffffff
lrw r4, 0x0
lsl32 r3, r1, r2
cmpne r4, r3
bt  TEST_FAIL
lrw r5, 0x1
lsli r9, r5, 13
lsri r9, r5, 13
lsli r3, r5, 17
lsri r3, r5, 17
bt TEST_FAIL
lrw r1, 0xffffffff
lrw r2, 0x1
lrw r4, 0xfffffffe
lsl16 r1, r2
cmpne r4, r1
bt  TEST_FAIL

//lsli16,lsli32,lslc
lrw r1, 0x55555555
lrw r4, 0xaaaaaaaa
lsli16 r1, r1, 1
cmpne r4, r1
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r4, 0x80000000
lsli r2, r1, 0x1f
cmpne r4, r2
bt  TEST_FAIL
lrw r1, 0xffffffff
lslc r2, r1, 32
bf  TEST_FAIL

//lsr16,lsr32,lsrc32
lrw r1, 0xffffffff
lrw r2, 0xffffffff
lrw r4, 0x0
lsr16 r1, r2
cmpne r4, r1
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r2, 0x0
lrw r4, 0xffffffff
lsr32 r3, r1, r2
cmpne r4, r3
lrw r1, 0xaaaaaaaa
lsrc32 r2, r1, 32
bf  TEST_FAIL

//lsl
lrw r1, 3
lrw r2, 0x55555555
lsl r3, r2, r1
lrw r1, 4
lsl r3, r2, r1
lrw r1, 5
lsl r3, r2, r1
lrw r1, 6
lsl r3, r2, r1
lrw r1, 7
lsl r3, r2, r1
lrw r1, 8
lsl r3, r2, r1
lrw r1, 9
lsl r3, r2, r1
lrw r1, 10
lsl r3, r2, r1
lrw r1, 11
lsl r3, r2, r1
lrw r1, 12
lsl r3, r2, r1
lrw r1, 14
lsl r3, r2, r1
lrw r1, 15
lsl r3, r2, r1
lrw r1, 16
lsl r3, r2, r1
lrw r1, 18
lsl r3, r2, r1
lrw r1, 19
lsl r3, r2, r1
lrw r1, 20
lsl r3, r2, r1
lrw r1, 21
lsl r3, r2, r1
lrw r1, 22
lsl r3, r2, r1
lrw r1, 23
lsl r3, r2, r1
lrw r1, 24
lsl r3, r2, r1
lrw r1, 25
lsl r3, r2, r1
lrw r1, 26
lsl r3, r2, r1
lrw r1, 27
lsl r3, r2, r1
lrw r1, 28
lsl r3, r2, r1
lrw r1, 29
lsl r3, r2, r1
lrw r1, 3
lsr r3, r2, r1
lrw r1, 4
lsr r3, r2, r1
lrw r1, 5
lsr r3, r2, r1
lrw r1, 6
lsr r3, r2, r1
lrw r1, 7
lsr r3, r2, r1
lrw r1, 8
lsr r3, r2, r1
lrw r1, 9
lsr r3, r2, r1
lrw r1, 10
lsr r3, r2, r1
lrw r1, 11
lsr r3, r2, r1
lrw r1, 12
lsr r3, r2, r1
lrw r1, 14
lsr r3, r2, r1
lrw r1, 15
lsr r3, r2, r1
lrw r1, 16
lsr r3, r2, r1
lrw r1, 18
lsr r3, r2, r1
lrw r1, 19
lsr r3, r2, r1
lrw r1, 20
lsr r3, r2, r1
lrw r1, 21
lsr r3, r2, r1
lrw r1, 22
lsr r3, r2, r1
lrw r1, 23
lsr r3, r2, r1
lrw r1, 24
lsr r3, r2, r1
lrw r1, 25
lsr r3, r2, r1
lrw r1, 26
lsr r3, r2, r1
lrw r1, 27
lsr r3, r2, r1
lrw r1, 28
lsr r3, r2, r1
lrw r1, 29
lsr r3, r2, r1

//bseti
lrw r1, 0x1
bseti r1, 13
bseti r1, 14
bseti r1, 20
bseti r1, 22
bseti r1, 23
bseti r1, 24
bseti r1, 25
bseti r1, 26
bseti r1, 28
bseti r1, 29

//addi subi sp
subi r3, sp, 4
addi r3, sp, 4
lrw r1, 10
lrw r2, 6
addi r3, r1, 2
subi r3, r1, 2
subu r3, r1, r2

//lsri16,lsri32
lrw r1, 0xaaaaaaa1
lrw r4, 0x55555550
lsri16 r1, r1, 1
cmpne r4, r1
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r4, 0x1
lsri r2, r1, 0x1f
cmpne r4, r2
bt  TEST_FAIL

//asr16,asr32,asrc32
lrw r1, 0xaaaaaaaa
lrw r2, 1
lrw r4, 0xd5555555
asr16 r1, r2
cmpne r4, r1
bt  TEST_FAIL
lrw r1, 0xaaaaaaaa
lrw r2, 32
lrw r4, 0xffffffff
asr32 r3, r1, r2
cmpne r4, r3
bt  TEST_FAIL
lrw r1, 0x55555555
asrc r3, r1, 32
bt  TEST_FAIL

//asri16,asri32
lrw r1, 0xffffffff
lrw r4, 0xffffffff
asri16 r1, r1, 0
cmpne r4, r1
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r4, 0xffffffff
asri32 r3, r1, 0x1f
cmpne r4, r3
bt  TEST_FAIL

//rotl16,rotl32,rotli32,xsr32
lrw r1, 0x55555555
lrw r2, 2
lrw r4, 0x55555555
rotl16 r1, r2
cmpne r4, r1
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r2, 0x3f
lrw r4, 0x0
rotl32 r3, r1, r2
cmpne r4, r3
bt  TEST_FAIL
lrw r1, 0xffffffff
lrw r4, 0xffffffff
rotli32 r1, r1, 0
cmpne r4, r1
bt  TEST_FAIL
lrw r1, 0xaaaaaaaa
lrw r4, 0xd5555555
btsti r1, 1
xsr r2, r1, 1
bt  TEST_FAIL
lrw r1, 0x1
lrw r4, 0x6
btsti r1, 0
xsr r2, r1, 31
bt  TEST_FAIL
cmpne r4, r2
bt  TEST_FAIL

//***************************************CMPARE****************************************
//cmphsi32,cmplti32,cmpnei32,cmphs16,cmplt16,cmpne16,cmphsi16,cmplti16,cmpnei16
 	lrw r1, 0xffffffff
	lrw r2, 0xffffffff
	cmphs16 r1, r2
	bf  TEST_FAIL
	lrw r1, 0x0
	cmphsi16 r1, 0x1f
	bt  TEST_FAIL
	lrw r1, 0xffff
	cmphsi32 r1, 0xffff
	bf  TEST_FAIL
	lrw r1, 0x55555555
	lrw r2, 0xffffffff
	cmplt16 r1, r2
	bt  TEST_FAIL
	lrw r1, 0x1f
	cmplti16 r1, 0x1f
	bt  TEST_FAIL
	lrw r1, 0xffffffff
	cmplti32 r1, 0xffff
	bf  TEST_FAIL
	addi16 r5, 1
	lrw r1, 0xffffffff
	lrw r2, 0xffffffff
	cmpne16 r2, r1
	bt  TEST_FAIL
	lrw r1, 0x1f
	cmpnei16 r1, 0x1f
	bt  TEST_FAIL
	lrw r1, 0xffffffff
	cmpnei32 r1, 0xffff
	bf  TEST_FAIL

//****************************************MOVE****************************************
//movi16,movi32,movih32,mvc32,mvcv16,movf,movt,mov16,mov32,lrw
	movi16 r1, 0xff
	mov16 r4,r1
	cmpne r4, r1
	bt  TEST_FAIL
	movi32 r1, 0xffff
	lrw r4, 0xffff
	cmpne r4, r1
	bt  TEST_FAIL
	movih32 r1, 0xffff
	lrw r4, 0xffff0000
	cmpne r4, r1
	bt  TEST_FAIL
	lrw r1, 1
	lrw r2, 0xffffffff
	lrw r4, 1
	btsti r1, 0
	mvc32 r2
	cmpne r4, r2
	bt  TEST_FAIL
	lrw r1, 1
	lrw r2, 0xffffffff
	lrw r4, 0
	btsti r1, 0
	mvcv16 r2
	cmpne r4, r2
	bt  TEST_FAIL
	movi r1,0x0
	movi r2,0x0
	movi r4,0xffff
	cmpne r1,r2
	movf r5,r4
	cmpne r5,r4
	bt  TEST_FAIL
	movi r1,0x2
	movi r2,0x0
	movi r4,0xffff
	cmpne r1,r2
	movt r5,r4
	cmpne r5,r4
	bt  TEST_FAIL

//**************************************other instructions********************
//xtrb0,xtrb1,xtrb2,xtrb3
	lrw r1, 0x00ffffff
	lrw r4, 0
	btsti r1, 0
	xtrb0 r2, r1
	bt	TEST_FAIL
	cmpne r4, r2
	bt  TEST_FAIL
	lrw r1, 0xffffffff
	lrw r4, 0xff
	btsti r1, 0
	xtrb1 r2, r1
	bf  TEST_FAIL
	cmpne r4, r2
	bt  TEST_FAIL
	lrw r1, 0xffff00ff
	lrw r4, 0
	xtrb2 r2, r1
	cmpne r4, r2
	bt  TEST_FAIL
	lrw r1, 0xffffff00
	lrw r4, 0
	xtrb3 r2, r1
	cmpne r4, r2
	bt  TEST_FAIL

//mult16,mult32
	lrw r1, 0x55555555
    lrw r2, 2
	lrw r3, 3
    lrw r4, 0xaaaaaaaa
	mult r3, r2
	mult r3, r2
	mult r3, r2
	mult r3, r2
	mult r3, r2
	mult r3, r2
	mult r3, r2
	mult r3, r2
    mult16 r1, r2
	mov r5, r1
    cmpne r4, r1
    bt  TEST_FAIL
    lrw r1, 0xffffffff
    lrw r2, 0xffffffff
    lrw r4, 0x1
	btsti r4, 1
    mult32 r3, r1, r2
    bt  TEST_FAIL
    cmpne r4, r3
    bt  TEST_FAIL

//ff0,ff1
	lrw r1, 0x7fffffff
    ff0 r2, r1
    movi r3, 0
    cmpne r2,r3
    bt  TEST_FAIL
    movi r1, 0
    ff1 r2, r1
    movi r3, 32
    cmpne r2,r3
    bt  TEST_FAIL
//FF1
  lrw r1, 0x1
  ff1 r2, r1
  lrw r1, 0x2
  ff1 r2, r1
  lrw r1, 0x4
  ff1 r2, r1
  lrw r1, 0x8
  ff1 r2, r1
  lrw r1, 0x10
  ff1 r2, r1
  lrw r1, 0x20
  ff1 r2, r1
  lrw r1, 0x100
  ff1 r2, r1
  lrw r1, 0x400
  ff1 r2, r1
  lrw r1, 0x800
  ff1 r2, r1
  lrw r1, 0x1000
  ff1 r2, r1
  lrw r1, 0x2000
  ff1 r2, r1
  lrw r1, 0x10000
  ff1 r2, r1
  lrw r1, 0x20000
  ff1 r2, r1
  lrw r1, 0x40000
  ff1 r2, r1
  lrw r1, 0x80000
  ff1 r2, r1
  lrw r1, 0x100000
  ff1 r2, r1
  lrw r1, 0x200000
  ff1 r2, r1
  lrw r1, 0x400000
  ff1 r2, r1
  lrw r1, 0x800000
  ff1 r2, r1
  lrw r1, 0x1000000
  ff1 r2, r1
  lrw r1, 0x2000000
  ff1 r2, r1
  lrw r1, 0x4000000
  ff1 r2, r1
  lrw r1, 0x8000000
  ff1 r2, r1
  lrw r1, 0x10000000
  ff1 r2, r1
  lrw r1, 0x20000000
  ff1 r2, r1
  lrw r1, 0x40000000
  ff1 r2, r1

	
//bmaski,bgeni
	lrw r4, 0x7fffffff
    bmaski r1, 31
    cmpne r4, r1
    bt  TEST_FAIL
	lrw r4, 0xffffffff
	movi r2, 1
    bgeni r4, 0
    cmpne r4, r2
	bt  TEST_FAIL

//bclri16,bclri32
	lrw r1, 0xaaaaaaaa
    lrw r4, 0xaaaaaaa8
    bclri16 r1, 1
    cmpne r4, r1
    bt  TEST_FAIL
    lrw r1, 0xffffffff
    lrw r4, 0x7fffffff
    bclri32 r3, r1, 31
    cmpne r4, r3
    bt  TEST_FAIL

//bseti16,bseti32
	lrw r1, 0x0
    lrw r4, 0x80000000
    bseti16 r1, 31
    cmpne r4, r1
    bt  TEST_FAIL
    lrw r1, 0xfffffffe
    lrw r4, 0xffffffff
    bseti32 r2, r1, 0
    cmpne r4, r2
    bt  TEST_FAIL

//revb16,revh16
	lrw r1, 0xaabbccdd
    lrw r4, 0xddccbbaa
    revb r2, r1
    cmpne r4, r2
    bt  TEST_FAIL
    lrw r1, 0xaabbccdd
    lrw r4, 0xbbaaddcc
    revh r2, r1
    cmpne r4, r2
    bt  TEST_FAIL


//tst16,tstnbz16
	lrw r1, 0xaaaaaaaa
	lrw r2, 0x55555555
	btsti r1, 1
	tst16 r1, r2
	bt  TEST_FAIL
	lrw r1, 0xfffffffe
	btsti r1, 0
	tstnbz16 r1
	bf  TEST_FAIL

//psrset32,psrclr32
    mfcr r1, cr<0,0>
    mov r2, r1
    mov r3, r1
    psrclr ee
    bclri r2, 8
    mfcr r4, cr<0,0>
    cmpne r4, r2
    bt  TEST_FAIL
    psrset ee
    bseti r3, 8
	bclri r3, 0
    mfcr r4, cr<0,0>
    cmpne r4, r3
    bt  TEST_FAIL

//zextb16,zextb32,zexth16,zexth32,sextb16,sexth32,sexth16,sexth32
	lrw r1, 0x55555555
    lrw r4, 0x55
    zextb16 r2, r1
    cmpne r4, r2
    bt  TEST_FAIL
    lrw r1, 0xffffffff
    lrw r4, 0xff
    zextb r2, r1
    cmpne r4, r2
    bt  TEST_FAIL
    lrw r1, 0x55555555
    lrw r4, 0x5555
    zexth16 r2, r1
    cmpne r4, r2
    bt  TEST_FAIL
    lrw r1, 0xffffffff
    lrw r4, 0xffff
    zexth r2, r1
    cmpne r4, r2
    bt  TEST_FAIL
    lrw r1, 0x55555555
    lrw r4, 0x5555
    sexth16 r2, r1
    cmpne r4, r2
    bt  TEST_FAIL
    lrw r1, 0xffffffff
    lrw r4, 0xffffffff
    sexth r2, r1
    cmpne r4, r2
    bt  TEST_FAIL
    lrw r1, 0x55555555
    lrw r4, 0x55
    sextb16 r2, r1
    cmpne r4, r2
    bt  TEST_FAIL
    lrw r1, 0xffffffff
    lrw r4, 0xffffffff
    sextb r2, r1
    cmpne r4, r2
    bt  TEST_FAIL
	
//****************************************Branch Operation ***************************
//*************************************************************************************
//jmp16,jsr16,rts16,sync32
	lrw r1,AFTER_JMP
	jmp r1
	br  TEST_FAIL
AFTER_JMP:
	lrw r1,AFTER_JSR
	jsr16 r1
	mov16 r0,r0
	bsr32 AFTER_RTS 
AFTER_JSR:
	rts16
AFTER_RTS:
	sync

//cmpnei16,cmpnei32,bf16,bf32,br16,br32,bsr32,bsr32
	movi r1,0x0
	cmpnei16 r1, 0
	bf16  AFTER_BF16
	br  TEST_FAIL
AFTER_BF16:
	br16  AFTER_BR16
	br  TEST_FAIL
AFTER_BR16:
	bsr32  AFTER_BSR16
	br  TEST_FAIL
AFTER_BSR16:
	lrw	r1, 0xffff
	cmpnei32 r1, 0xffff
	bf32  AFTER_BF32
	br  TEST_FAIL
AFTER_BF32:
	br32  AFTER_BR32
	br  TEST_FAIL
AFTER_BR32:
	bsr32  AFTER_BSR32
	br  TEST_FAIL
AFTER_BSR32:

	
//******************************LOAD/STORE**************************************
//******************************************************************************
//push16,pop16
    lrw r15, AFTER_POP_R15
	push r15
	lrw r1, 0x80000000
	lrw r2, 0x2
	mult r2, r1
	mult r2, r1
	mult r2, r1
	mult r2, r1
	mult r2, r1
	mult r2, r1
	mult r2, r1
	mult r2, r1
	mult r2, r1
	pop r15
AFTER_POP_R15:
	lrw	r4, 0xf
	lrw	r5, 0xff
	push16 r4-r5
	movi r5, 0
	movi r4, 0
	lrw r15, AFTER_POP
	pop16 r4-r5
AFTER_POP:
	cmpnei	r4, 0xf
	bt	TEST_FAIL
	cmpnei	r5, 0xff
	bt	TEST_FAIL

//ld.b,ld.bs,ld.h,ld.hs,st.b,st.h,ldm,stm
	lrw r1, LD_ADDR
    lrw r2, 0xa1a2a3aa
    lrw r9, 0xa1a2a3aa
    lrw r4, 0xaa
	lrw r5, 0x110000
	ld.w r6, (r5,0)
    st.b r2, (r1,0)
    st.b r9, (r1,0)
    ld.b r3, (r1,0)
    ld.b r9, (r1,0)
	ld.b r9, (r1,1)
	ld.b r9, (r1,3)
    cmpne r4, r3
    bt  TEST_FAIL
    lrw r1, LD_ADDR
    lrw r2, 0xaaaaaaaa
    lrw r4, 0xffffffaa
    st.b r2, (r1,0)
    ld.bs r3, (r1,0)
    cmpne r4, r3
    bt  TEST_FAIL
    lrw r1, LD_ADDR
    lrw r2, 0x1111aaaa
    lrw r9, 0x1111aaaa
    lrw r4, 0xaaaa
    st.h r2, (r1,0)
    st.h r9, (r1,0)
    ld.h r3, (r1,0)
    ld.h r9, (r1,0)
    ld.h r9, (r1,0)
    cmpne r4, r3
    bt  TEST_FAIL
    lrw r1, LD_ADDR
    lrw r2, 0xaaaaaaaa
    lrw r4, 0xffffaaaa
    st.h r2, (r1,0)
    ld.hs r3, (r1,0)
    cmpne r4, r3
    bt  TEST_FAIL
    lrw r1, LD_ADDR
    lrw r2, 0xaaaaaaaa
    lrw r9, 0xaaaaaaaa
    lrw r4, 0xaaaaaaaa
    st.w r2, (r1,0)
    st.w r9, (r1,0)
    ld.w r3, (r1,0)
    ld.w r9, (r1,0)
    cmpne r4, r3
    bt  TEST_FAIL
    addi16 r5, 1
    lrw r1, LD_ADDR
    lrw r2, 0xaaaaaaaa
	lrw r3, 0xbbbbbbbb
	lrw r4, 0xcccccccc
	lrw r5, 0xdddddddd
    lrw r9, 0xaaaaaaaa
    stm r2-r5, (r1)
    ldm r4-r7, (r1)
    cmpne r4, r9
    bt  TEST_FAIL

 lrw r1, 0xaabbccdd
    lrw r2, LD_ADDR
    addi r2,0x10
    st.w r1,(r2)
    lrw r1, 0xff00ff00
    st.b r1, (r2)
    ld.h r3,(r2)
    lrw r1, 0x12345678
    st.h r1, (r2)
    ld.w r3,(r2)
    lrw r4, 0xaabb5678
    cmpne r4,r3
    bt TEST_FAIL
    lrw r4, 0xaa785678
    lrw r8, LD_ADDR
    addi r8,0x12
    st.b r1, (r8)
    ld.w r3,(r2)
    cmpne r4,r3
    bt TEST_FAIL

	
TEST_PASS:
  lrw  r1, __exit 
  jsr  r1

TEST_FAIL:
  lrw  r1, __fail
  jsr  r1
