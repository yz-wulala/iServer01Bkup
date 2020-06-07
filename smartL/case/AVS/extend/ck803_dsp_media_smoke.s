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
// Author      :ck803e_dsp_media_smoke.s
// Project     :SMART_V2
// Function    :Test all DSP MEDIA instructions in CK803E
// Method      :Self Test
// ****************************************************************************

.text
.align 1
.export main
main:

//----------------mult----------------//
lrw r1,0x34
lrw r2,0xffffff12
mult r1,r2
lrw r3,0xffffcfa8
cmpne r1,r3
bt FAIL

//----------------muls----------------//
lrw r1,0x34
lrw r2,0xffffff12
muls r1,r2
mfhi r9
mflo r10
lrw r3,0xffffffff
lrw r4,0xffffcfa8
cmpne r9,r3
bt FAIL
cmpne r10,r4
bt FAIL

//----------------mulsa----------------//
lrw r1,0xffffffff
mthi r1
lrw r1,0xffffff12
mtlo r1
lrw r1,0x34
lrw r2,0xffffff12
mulsa r1,r2
mfhi r9
mflo r10
lrw r3,0xffffffff
lrw r4,0xffffceba
cmpne r9,r3
bt FAIL
cmpne r10,r4
bt FAIL

//----------------mulss----------------//
lrw r1,0xffffffff
mthi r1
lrw r1,0xffffff12
mtlo r1
lrw r1,0x34
lrw r2,0xffffff12
mulss r1,r2
mfhi r9
mflo r10
lrw r3,0x0
lrw r4,0x2f6a
cmpne r9,r3
bt FAIL
cmpne r10,r4
bt FAIL

//----------------mulu----------------//
lrw r1,0x34
lrw r2,0xffffff12
mulu r1,r2
mfhi r9
mflo r10
lrw r3,0x33
lrw r4,0xffffcfa8
cmpne r9,r3
bt FAIL
cmpne r10,r4
bt FAIL

//----------------mulua----------------//
lrw r1,0x34
mthi r1
lrw r1,0xffffff12
mtlo r1
lrw r1,0x34
lrw r2,0xffffff12
mulua r1,r2
mfhi r9
mflo r10
lrw r3,0x68
lrw r4,0xffffceba
cmpne r9,r3
bt FAIL
cmpne r10,r4
bt FAIL

//----------------mulus----------------//
lrw r1,0x34
mthi r1
lrw r1,0xffffff12
mtlo r1
lrw r1,0x34
lrw r2,0xffffff12
mulus r1,r2
mfhi r9
mflo r10
lrw r3,0x1
lrw r4,0x2f6a
cmpne r9,r3
bt FAIL
cmpne r10,r4
bt FAIL

//----------------mulsh----------------//
lrw r1,0xff12
lrw r2,0x34
mulsh r1,r2
lrw r3,0xffffcfa8
cmpne r1, r3
bt FAIL

//----------------mulsha----------------//
lrw r4,0xffffff12
mtlo r4
lrw r1,0xff12
lrw r2,0x34
mulsha r1,r2
mfhis r1
mflos r1
mflo r5
lrw r3,0xffffceba
cmpne r5,r3
bt FAIL

//----------------mulshs----------------//
lrw r4,0xffffff12
mtlo r4
lrw r1,0xff12
lrw r2,0x34
mulshs r1,r2
mflo r5
lrw r3,0x2f6a
cmpne r5,r3
bt FAIL

//----------------mulsw----------------//
lrw r1,0x345
lrw r2,0xffffff12
mulsw r1, r1,r2
lrw r3,0xfffffffc
cmpne r1,r3
bt FAIL

//----------------mulswa----------------//
lrw r4,0xffffff12
mtlo r4
lrw r1,0x345
lrw r2,0xffffff12
mulswa r1,r2
mflo r5
lrw r3,0xffffff0e
cmpne r5,r3
bt FAIL

//----------------mulsws----------------//
lrw r4,0xffffff12
mtlo r4
lrw r1,0x345
lrw r2,0xffffff12
mulsws r1,r2
mflo r5
lrw r3,0xffffff16
cmpne r5,r3
bt FAIL

//----------------vmulsh----------------//
lrw r1,0xff120034
lrw r2,0x34ff12
vmulsh r1,r2
mfhi r3
mflo r4
lrw r5,0xffffcfa8
lrw r6,0xffffcfa8
cmpne r5,r3
bt FAIL
cmpne r6,r4
bt FAIL

//----------------vmulsha----------------//
lrw r3,0x123
mthi r3
mtlo r3
lrw r1,0xff120034
lrw r2,0x34ff12
vmulsha r1,r2
mfhi r8
mflo r9
lrw r5,0xffffd0cb
lrw r6,0xffffd0cb
cmpne r5,r8
bt FAIL
cmpne r6,r9
bt FAIL

//----------------vmulshs----------------//
lrw r3,0x123
mthi r3
mtlo r3
lrw r1,0xff120034
lrw r2,0x34ff12
vmulshs r1,r2
mfhi r8
mflo r9
lrw r5,0x317b
lrw r6,0x317b
cmpne r5,r8
bt FAIL
cmpne r6,r9
bt FAIL

//----------------vmulsw----------------//
lrw r1,0xff12ff12
lrw r2,0x345
vmulsw r1,r2
mfhi r8
mflo r9
lrw r5,0xfffffffc
lrw r6,0xfffffffc
cmpne r5,r8
bt FAIL
cmpne r6,r9
bt FAIL

//----------------vmulswa----------------//
lrw r3,0x123
mthi r3
mtlo r3
lrw r1,0xff12ff12
lrw r2,0x345
vmulswa r1,r2
mfhi r8
mflo r9
lrw r5,0x11f
lrw r6,0x11f
cmpne r5,r8
bt FAIL
cmpne r6,r9
bt FAIL

//----------------vmulsws----------------//
lrw r3,0x123
mthi r3
mtlo r3
lrw r1,0xff12ff12
lrw r2,0x345
vmulsws r1,r2
mfhi r8
mflo r9
lrw r5,0x127
lrw r6,0x127
cmpne r5,r8
bt FAIL
cmpne r6,r9
bt FAIL

//========================================================
//test the overflow detect function of mulsa mulss mulua mulus mulsha mulshs
//mulswa mulsws vmulsha vmulshs vmulswa vmulsws
//========================================================
//----------------mulsa max overflow----------------//
lrw r1,0x7fffffff
mthi r1
lrw r1,0xffffffff
mtlo r1
lrw r1,0x34
lrw r2,0x34
mulsa r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL

//----------------mulsa min overflow----------------//
lrw r1,0x80000000
mthi r1
lrw r1,0x0
mtlo r1
lrw r1,0xffffff12
lrw r2,0x34
mulsa r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL

//----------------mulss max overflow----------------//
lrw r1,0x7fffffff
mthi r1
lrw r1,0xffffffff
mtlo r1
lrw r1,0xffffff12
lrw r2,0x34
mulss r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL

//----------------mulss min overflow----------------//
lrw r1,0x80000000
mthi r1
lrw r1,0x0
mtlo r1
lrw r1,0x34
lrw r2,0x34
mulss r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL

//----------------mulua max overflow----------------//
lrw r1,0x7fffffff
mthi r1
lrw r1,0xffffffff
mtlo r1
lrw r1,0xf0000000
lrw r2,0xf0000000
mulua r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL

//----------------mulus min overflow----------------//
lrw r1,0x0
mthi r1
lrw r1,0x0
mtlo r1
lrw r1,0x34
lrw r2,0x34
mulus r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL

//----------------mulsha max overflow----------------//
lrw r1,0x7fffffff
mtlo r1
lrw r1,0x34
lrw r2,0x34
mulsha r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL
mflos r6
lrw r9,0x7fffffff
cmpne r6,r9
bt FAIL

//----------------mulsha min overflow----------------//
lrw r1,0x80000000
mtlo r1
lrw r1,0xffffff12
lrw r2,0x34
mulsha r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL
mflos r6
lrw r9,0x80000000
cmpne r6,r9
bt FAIL

//----------------mulshs max overflow----------------//
lrw r1,0x7fffffff
mtlo r1
lrw r1,0xff12
lrw r2,0x34
mulshs r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL
mflos r6
lrw r9,0x7fffffff
cmpne r6,r9
bt FAIL

//----------------mulshs min overflow----------------//
lrw r1, 0x80000000
mtlo r1
lrw r1, 0x34
lrw r2, 0x34
mulshs r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL
mflos r6
lrw r9,0x80000000
cmpne r6,r9
bt FAIL

//----------------mulswa max overflow----------------//
lrw r1,0x345
lrw r2,0x345
lrw r4,0x7fffffff
mtlo r4
mulswa r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL
mflos r5
lrw r3,0x7fffffff
cmpne r5,r3
bt FAIL

//----------------mulswa min overflow----------------//
lrw r1,0x345
lrw r2,0xffffff12
lrw r4,0x80000000
mtlo r4
mulswa r1,r2
mfhis r1
mflos r1
mvtc
bf FAIL
mflos r6
lrw r9,0x80000000
cmpne r6,r9
bt FAIL

//----------------mulsws max overflow----------------//
lrw r1,0x345
lrw r2,0xffffff12
lrw r4,0x7fffffff
mtlo r4
mulsws r1,r2
mvtc
bf FAIL
mflos r5
lrw r3,0x7fffffff
cmpne r5,r3
bt FAIL

//----------------mulsws min overflow----------------//
lrw r1,0x345
lrw r2,0x345
lrw r4,0x80000000
mtlo r4
mulsws r1,r2
mvtc
bf FAIL
mflos r6
lrw r9,0x80000000
cmpne r6,r9
bt FAIL

//----------------vmulsha----------------//
lrw r1,0x34ff12
lrw r2,0x340034
lrw r3,0x7fffffff
lrw r4,0x80000000
mthi r3
mtlo r4
vmulsha r1,r2
mfhis r5
mflos r6
lrw r9,0x7fffffff
lrw r10,0x80000000
mvtc
bf FAIL
cmpne r5,r9
bt FAIL
cmpne r6,r10
bt FAIL

//----------------vmulshs----------------//
lrw r1,0x340034
lrw r2,0xff120034
lrw r3,0x7fffffff
lrw r4,0x80000000
mthi r3
mtlo r4
vmulshs r1,r2
mfhis r5
mflos r6
lrw r9,0x7fffffff
lrw r10,0x80000000
mvtc
bf FAIL
cmpne r5,r9
bt FAIL
cmpne r6,r10
bt FAIL

//----------------vmulswa----------------//
lrw r1,0x345ff12
lrw r2,0x3450345
lrw r3,0x7fffffff
lrw r4,0x80000000
mthi r3
mtlo r4
vmulswa r1,r2
mfhis r5
mflos r6
lrw r9,0x7fffffff
lrw r10,0x80000000
mvtc
bf FAIL
cmpne r5,r9
bt FAIL
cmpne r6,r10
bt FAIL

//----------------vmulsws----------------//
lrw r1,0xff120345
lrw r2,0x3450345
lrw r3,0x7fffffff
lrw r4,0x80000000
mthi r3
mtlo r4
vmulsws r1,r2
mfhis r5
mflos r6
lrw r9,0x7fffffff
lrw r10,0x80000000
mvtc
bf FAIL
cmpne r5,r9
bt FAIL
cmpne r6,r10
bt FAIL

//********************************************************
//                    Fraction Mode
//********************************************************
lrw r9,0x80000000
mtcr r9,cr<14, 0>

//----------------muls----------------//
lrw r1,0x34
lrw r2,0xffffff12
muls r1,r2
mfhi r9
mflo r10
//lrw r3 0xffffffff
//lrw r4 0xffffcfa8
lrw r3,0xffffffff
lrw r4,0xffff9f50
cmpne r9,r3
bt FAIL
cmpne r10,r4
bt FAIL

//----------------mulsa----------------//
lrw r1,0xffffffff
mthi r1
lrw r1,0xffffff12
mtlo r1
lrw r1,0x34
lrw r2,0xffffff12
mulsa r1,r2
mfhi r9
mflo r10
//lrw r3 0xffffffff
//lrw r4 0xffffceba
lrw r3,0xffffffff
lrw r4,0xffff9e62
cmpne r9,r3
bt FAIL
cmpne r10,r4
bt FAIL

//----------------mulss----------------//
lrw r1,0xffffffff
mthi r1
lrw r1,0xffffff12
mtlo r1
lrw r1,0x34
lrw r2,0xffffff12
mulss r1,r2
mfhi r9
mflo r10
lrw r3,0x0
lrw r4,0x5fc2
cmpne r9,r3
bt FAIL
cmpne r10,r4
bt FAIL

//----------------mulsh----------------//
lrw r1,0xff12
lrw r2,0x34
mulsh r1,r2
lrw r3,0xffff9f50
cmpne r1, r3
bt FAIL

//----------------mulsha----------------//
lrw r4,0xffffff12
mtlo r4
lrw r1,0xff12
lrw r2,0x34
mulsha r1,r2
mflo r5
lrw r3,0xffff9e62
cmpne r5,r3
bt FAIL

//----------------mulshs----------------//
lrw r4,0xffffff12
mtlo r4
lrw r1,0xff12
lrw r2,0x34
mulshs r1,r2
mflo r5
lrw r3,0x5fc2
cmpne r5,r3
bt FAIL

//----------------mulsw----------------//
lrw r1,0x345
lrw r2,0xffffff12
mulsw r1,r1,r2
lrw r3,0xfffffff9
cmpne r1,r3
bt FAIL

//----------------mulswa----------------//
lrw r4,0xffffff12
mtlo r4
lrw r1,0x345
lrw r2,0xffffff12
mulswa r1,r2
mflo r5
lrw r3,0xffffff0b
cmpne r5,r3
bt FAIL

//----------------mulsws----------------//
lrw r4,0xffffff12
mtlo r4
lrw r1,0x345
lrw r2,0xffffff12
mulsws r1,r2
mflo r5
lrw r3,0xffffff19
cmpne r5,r3
bt FAIL

//----------------vmulsh----------------//
lrw r1,0xff120034
lrw r2,0x34ff12
vmulsh r1,r2
mfhi r3
mflo r4
lrw r5,0xffff9f50
lrw r6,0xffff9f50
cmpne r5,r3
bt FAIL
cmpne r6,r4
bt FAIL

//----------------vmulsha----------------//
lrw r3,0x123
mthi r3
mtlo r3
lrw r1,0xff120034
lrw r2,0x34ff12
vmulsha r1,r2
mfhi r8
mflo r9
lrw r5,0xffffa073
lrw r6,0xffffa073
cmpne r5,r8
bt FAIL
cmpne r6,r9
bt FAIL

//----------------vmulshs----------------//
lrw r3,0x123
mthi r3
mtlo r3
lrw r1,0xff120034
lrw r2,0x34ff12
vmulshs r1,r2
mfhi r8
mflo r9
lrw r5,0x61d3
lrw r6,0x61d3
cmpne r5,r8
bt FAIL
cmpne r6,r9
bt FAIL

//----------------vmulsw----------------//
lrw r1,0xff12ff12
lrw r2,0x345
vmulsw r1,r2
mfhi r8
mflo r9
lrw r5,0xfffffff9
lrw r6,0xfffffff9
cmpne r5,r8
bt FAIL
cmpne r6,r9
bt FAIL

//----------------vmulswa----------------//
lrw r3,0x123
mthi r3
mtlo r3
lrw r1,0xff12ff12
lrw r2,0x345
vmulswa r1,r2
mfhi r8
mflo r9
lrw r5,0x11c
lrw r6,0x11c
cmpne r5,r8
bt FAIL
cmpne r6,r9
bt FAIL

//----------------vmulsws----------------//
lrw r3,0x123
mthi r3
mtlo r3
lrw r1,0xff12ff12
lrw r2,0x345
vmulsws r1,r2
mfhi r8
mflo r9
lrw r5,0x12a
lrw r6,0x12a
cmpne r5,r8
bt FAIL
cmpne r6,r9
bt FAIL

//========================================================
//test the overflow detect function of mulsa mulss mulua mulus mulsha mulshs
//mulswa mulsws vmulsha vmulshs vmulswa vmulsws
//========================================================
//----------------mulsa max overflow----------------//
lrw r1,0x7fffffff
mthi r1
lrw r1,0xfffffffd
mtlo r1
lrw r1,0x1
lrw r2,0x2
mulsa r1,r2
mvtc
bf FAIL

//----------------mulsa min overflow----------------//
lrw r1,0x80000000
mthi r1
lrw r1,0x3
mtlo r1
lrw r1,0xffffffff
lrw r2,0x2
mulsa r1,r2
mvtc
bf FAIL

//----------------mulss max overflow----------------//
lrw r1,0x7fffffff
mthi r1
lrw r1,0xfffffffd
mtlo r1
lrw r1,0xffffffff
lrw r2,0x2
mulss r1,r2
mvtc
bf FAIL

//----------------mulss min overflow----------------//
lrw r1,0x80000000
mthi r1
lrw r1,0x3
mtlo r1
lrw r1,0x1
lrw r2,0x2
mulss r1,r2
mvtc
bf FAIL

//----------------mulua max overflow----------------//
lrw r1,0xffffffff
mthi r1
lrw r1,0xfffffffd
mtlo r1
lrw r1,0x1
lrw r2,0x2
mulua r1,r2
mvtc
bf FAIL

//----------------mulus min overflow----------------//
lrw r1,0x0
mthi r1
lrw r1,0x3
mtlo r1
lrw r1,0x1
lrw r2,0x2
mulus r1,r2
mvtc
bf FAIL

//----------------mulsha max overflow----------------//
lrw r1,0x7ffffffd
mtlo r1
lrw r1,0x1
lrw r2,0x2
mulsha r1,r2
mvtc
bf FAIL
mflos r6
lrw r9, 0x7fffffff
cmpne r6,r9
bt FAIL

//----------------mulsha min overflow----------------//
lrw r1,0x80000003
mtlo r1
lrw r1,0xffff
lrw r2,0x2
mulsha r1,r2
mvtc
bf FAIL
mflos r6
lrw r9,0x80000000
cmpne r6,r9
bt FAIL

//----------------mulshs max overflow----------------//
lrw r1,0x7ffffffd
mtlo r1
lrw r1,0xffff
lrw r2,0x2
mulshs r1,r2
mvtc
bf FAIL
mflos r6
lrw r9,0x7fffffff
cmpne r6,r9
bt FAIL

//----------------mulshs min overflow----------------//
lrw r1,0x80000003
mtlo r1
lrw r1,0x1
lrw r2,0x2
mulshs r1,r2
mvtc
bf FAIL
mflos r6
lrw r9,0x80000000
cmpne r6,r9
bt FAIL

//----------------mulswa max overflow----------------//
lrw r1,0x345
lrw r2,0x345
lrw r4,0x7fffffef
mtlo r4
mulswa r1,r2
mvtc
bf FAIL
mflos r5
lrw r3,0x7fffffff
cmpne r5,r3
bt FAIL

//----------------mulswa min overflow----------------//
lrw r1,0x345
lrw r2,0xffffff12
lrw r4,0x80000006
mtlo r4
mulswa r1,r2
mvtc
bf FAIL
mflos r6
lrw r9,0x80000000
cmpne r6,r9
bt FAIL

//----------------mulsws max overflow----------------//
lrw r1,0x345
lrw r2,0xffffff12
lrw r4,0x7ffffffa
mtlo r4
mulsws r1,r2
mvtc
bf FAIL
mflos r5
lrw r3,0x7fffffff
cmpne r5,r3
bt FAIL

//----------------mulsws min overflow----------------//
lrw r1,0x345
lrw r2,0x345
lrw r4,0x80000010
mtlo r4
mulsws r1,r2
mvtc
bf FAIL
mflos r6
lrw r9,0x80000000
cmpne r6,r9
bt FAIL

//----------------vmulsha----------------//
lrw r1,0x1ffff
lrw r2,0x20002
lrw r3,0x7ffffffd
lrw r4,0x80000003
mthi r3
mtlo r4
vmulsha r1,r2
mfhis r5
mflos r6
lrw r9,0x7fffffff
lrw r10,0x80000000
mvtc
bf FAIL
cmpne r5,r9
bt FAIL
cmpne r6,r10
bt FAIL

//----------------vmulshs----------------//
lrw r1,0x20002
lrw r2,0xffff0001
lrw r3,0x7ffffffd
lrw r4,0x80000003
mthi r3
mtlo r4
vmulshs r1,r2
mfhis r5
mflos r6
lrw r9,0x7fffffff
lrw r10,0x80000000
mvtc
bf FAIL
cmpne r5,r9
bt FAIL
cmpne r6,r10
bt FAIL

//----------------vmulswa----------------//
lrw r1,0xf0ff10
lrw r2,0xf0
lrw r3,0x7fffffff
lrw r4,0x80000001
mthi r3
mtlo r4
vmulswa r1,r2
mfhis r5
mflos r6
lrw r9,0x7fffffff
lrw r10,0x80000000
mvtc
bf FAIL
cmpne r5,r9
bt FAIL
cmpne r6,r10
bt FAIL

//----------------vmulsws----------------//
lrw r1,0xff1000f0
lrw r2,0xf0
lrw r3,0x7ffffffe
lrw r4,0x80000000
mthi r3
mtlo r4
vmulsws r1,r2
mfhis r5
mflos r6
lrw r9,0x7fffffff
lrw r10,0x80000000
mvtc
bf FAIL
cmpne r5,r9
bt FAIL
cmpne r6,r10
bt FAIL

//------------------803 mad basic function test---------------//
      lrw r1, 0x8fffffff
      lrw r2, 0x1
      divu r3, r1, r2
      lrw r1, 0x8fffffff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x4fffffff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x2fffffff
      lrw r2, 0x2
      divu r3, r1, r2   
      lrw r1, 0x1fffffff
      lrw r2, 0x2
      divu r3, r1, r2   
      lrw r1, 0x8ffffff
      lrw r2, 0x2
      divu r3, r1, r2   
      lrw r1, 0x4ffffff
      lrw r2, 0x2
      divu r3, r1, r2   
      lrw r1, 0x2ffffff
      lrw r2, 0x2
      divu r3, r1, r2   
      lrw r1, 0x1ffffff
      lrw r2, 0x2
      divu r3, r1, r2   
      lrw r1, 0x8fffff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x4fffff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x2fffff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x1fffff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x8ffff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x4ffff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x2ffff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x1ffff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x8fff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x4fff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x2fff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x1fff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x8ff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x4ff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x2ff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x1ff
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x8f
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x4f
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x2f
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x1f
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x8
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x4
      lrw r2, 0x2
      divu r3, r1, r2
      lrw r1, 0x2
      lrw r2, 0x1
      divu r3, r1, r2
      lrw r1, 0x1
      lrw r2, 0x1
      divu r3, r1, r2
	//lsrc
	lrw r1, 0xffffffff
	movi r2, 0
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 1
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 2
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 3
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 4
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 5
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 6
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 7
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 8
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 9
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 10
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 11
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 12
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 13
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 14
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 15
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 16
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 17
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 18
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 19
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 20
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 21
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 22
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 23
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 24
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 25
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 26
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 27
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 28
	lsr r1, r2
	lrw r1, 0xffffffff
	movi r2, 29
	lsr r1, r2

      addi16 r2,sp, 4
      addi16 sp, sp,4 

     
      psrset ee, ie
      movi r3, 8
      movih r4, 0x0700
      movi r2, 8

      addi16 r2, r1, 0x4
      subu16 r3, r2, r4
      subi16 r1, r5, 0x4
      addi r2, r28, 0x55
      ld16.w r6, (sp)
      st16.w r6, (sp)

      lrw r12,0x6000b008
      lrw r13,0x6000b102
      lrw r18,0x80000018
      lrw r19,0x00000018
      st.w r2,(r12,0x4)
      ld.w r2,(r12,0x4)
      st.h r3,(r13,0x0)
      ld.h r3,(r13,0x0)
      st.b r5,(r12,0x32)
      ld.b r6,(r12,0x32)
      movi r15,0x2
      str.w r2,(r12,r15<<0x1)
      ldr.w r2,(r12,r15<<0x1)
      str.w r2,(r12,r15<<0x2)
      ldr.w r2,(r12,r15<<0x2)
      str.w r2,(r12,r15<<0x3)
      ldr.w r2,(r12,r15<<0x3)
      str.h r3,(r13,r15<<0x1)
      ldr.h r3,(r13,r15<<0x1)
      str.h r3,(r13,r15<<0x2)
      ldr.h r3,(r13,r15<<0x2)
      str.h r3,(r13,r15<<0x3)
      ldr.h r3,(r13,r15<<0x3)
      str.b r5,(r12,r15<<1)
      ldr.b r6,(r12,r15<<1)
      str.b r5,(r12,r15<<2)
      ldr.b r6,(r12,r15<<2)
      str.b r5,(r12,r15<<3)
      ldr.b r6,(r12,r15<<3)
      str.b r18,(r12,r15<<0x1)
      ldr.bs r18,(r12,r15<<0x1)
      str.b r18,(r12,r15<<0x2)
      ldr.bs r18,(r12,r15<<0x2)
      str.b r18,(r12,r15<<0x3)
      ldr.bs r18,(r12,r15<<0x3)
      str.h r18,(r12,r15<<0x1)
      ldr.hs r18,(r12,r15<<0x1)
      str.h r18,(r12,r15<<0x2)
      ldr.hs r18,(r12,r15<<0x2)
      str.h r18,(r12,r15<<0x3)
      ldr.hs r18,(r12,r15<<0x3)
      st.w r19,(r12,0x8)
      ld.hs r19,(r12,0x8)
      cmphs r19,r12
      cmpne r18,r19
      mvcv r19
      tst r19,r18
      tstnbz16 r8
      tstnbz32 r18
 
    
      lsli r12, r10, 6
      lsri r12, r10, 6
      grs  r4, 0x19999
        
      lrw    r1, 0x12345678
      movi   r2, 0x1234
      movi   r3, 0x12
      srs.w  r1, [SRS_1]  
      srs.h  r2, [SRS_2]
      srs.b  r3, [SRS_3]
      movi   r4, 0x0
      movi   r5, 0x0
      movi   r6, 0x0
      lrs.w  r4, [SRS_1] 
      lrs.h  r5, [SRS_2]
      lrs.b  r6, [SRS_3]      
      movi r28,0x1234
      lrw    r1, 0x010
      srs.w  r1, [SRS_4]
      lrs.h  r4, [SRS_4]
      
      movi r1,0x7076      
      subi r1,r1,0x134      
      movi r2,0xBC54      
      subi r2,r2,0x97D      
      movi r3,0x905D      
      subi r3,r3,0xAA2      
      movi r4,0xC000      
      subi r4,r4,0x2B7      
      movi r5,0x1AB3      
      subi r5,r5,0x7C6      
      movi r6,0x740D      
      subi r6,r6,0x6A6      
      movi r7,0xDCD7      
      subi r7,r7,0x171      
      movi r8,0x80A9      
      subi r8,r8,0xF4E      
      movi r9,0x882A      
      subi r9,r9,0x8C2      
      movi r10,0x46DF      
      subi r10,r10,0xD03      
      movi r11,0x40C1      
      subi r11,r11,0x697      
      movi r12,0x7910      
      subi r12,r12,0x781      
      movi r13,0xDED4      
      subi r13,r13,0x96      
      movi r14,0x7D6      
      subi r14,r14,0x56B      
      movi r16,0x9899      
      subi r16,r16,0xB37      
      movi r17,0x4679      
      subi r17,r17,0xF5C      
      movi r18,0xB6E5      
      subi r18,r18,0x600      
      movi r19,0xDC01      
      subi r19,r19,0xB6D      
      movi r20,0xF71C      
      subi r20,r20,0x43B      
      movi r21,0x44C7      
      subi r21,r21,0x7F5      
      movi r22,0x997D      
      subi r22,r22,0x3EA      
      movi r23,0x8CEF      
      subi r23,r23,0xE6F      
      movi r24,0x11B3      
      subi r24,r24,0x664      
      movi r25,0x8B07      
      subi r25,r25,0x2A3      
      movi r26,0x4ECD      
      subi r26,r26,0xE60      
      movi r27,0xF24C      
      subi r27,r27,0x84B      
      movi r28,0xDD64      
      subi r28,r28,0x82F      
      movi r29,0x1BD2      
      subi r29,r29,0xC11      
      movi r30,0x914B      
      subi r30,r30,0x6DB      
      movi r31,0xD3BB      
      subi r31,r31,0x490      
      cmplt r1, r2
      bt32  bt_label
      andni32 r8,r14,0x2E5      
bt_label:
      cmplt r3, r4
      bf32  bf_label
      subi16 r2,0x88      
bf_label:
      cmpne r5, r6
      bf  be_label
      or16 r12,r10      
be_label:
      cmpne r7, r8
      bt  bne_label
      mvcv32 r3      
bne_label:
      bez r9,bez_label
      clrf32 r12      
bez_label:
      bnez r10,bnez_label
      declt32 r15,r5,0xD      
bnez_label:
      bhz r11,bhz_label
      zexth32 r9,r4      
bhz_label:
      blsz r12,blsz_label
      zexth16 r1,r0      
blsz_label:
      blz r13,blz_label
      zexth32 r3,r15      
blz_label:
      bhsz r14,bhsz_label
      cmpnei32 r4,0xC809      
bhsz_label:
      br  br_label
      xsr32 r6,r8,0xD      
br_label:
      bsr32  bsr_label
      revb32 r13,r9      
bsr_label:
      jmpi32  jmpi_label
      andni32 r15,r4,0xFDC      
jmpi_label:
      jsri32  jsri_label
      addi32 r9,r28,0x3DD13      
jsri_label:
      lrw r2,jmp_label
      jmp32 r2
      lsl16 r8,r10      
jmp_label:
      lrw r6,jsr_label
      jsr32 r6
      incf32 r12,r1,0x6      
jsr_label:
      lrw r15,rts_label
      rts32
      cmplt16 r7,r7      
rts_label:
      cmplt r17, r18
      bt16  bt16_label
      revb16 r10,r15      
bt16_label:
      cmplt r9, r2
      bf16  bf16_label
      mvc32 r4      
bf16_label:
      br16  br16_label
      revh16 r14,r12      
br16_label:
      bsr32  bsr32_label
      zextb16 r0,r12      
bsr32_label:
      jsri32  jsri16_label
      mov16 r12,r4      
jsri16_label:
      lrw r15,rts16_label
      rts16
      movf32 r11,r1      
rts16_label:
      revb16 r13,r13 

SUCCESS:
      jmpi  __exit
FAIL:
      jmpi  __fail

.data
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
SRS_1:
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
SRS_4:
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
SRS_6:
      mov  r0,r0
      mov  r0,r0
SRS_2:
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
SRS_5:
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
SRS_3:
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
      mov  r0,r0
