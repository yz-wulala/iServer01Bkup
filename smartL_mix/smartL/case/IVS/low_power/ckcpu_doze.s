// * **************************************************************************
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
// AUTHOR     : Tao Jiang
// CSKYCPU    : 802 
// HWCFIG     : WIC
// SMART_R    : yes 
// CTS        : no 
// FUNCTION   : wake cpu up from doze mode using event
// METHOD     : 
// NOTE       : 
// ****************************************************************************

.text
.align 1
.export main
main:

//***********************************
//set counter
//***********************************
lrw   r1, 0xf
lrw   r3, 0x40016004
stw   r1, (r3, 0)

//**********************************
// start counter/enable event
//**********************************
lrw r1, 0xa
lrw r2, 0x40016000
stw r1, (r2, 0)

//**********************************
// enter lpmd
//**********************************
doze
mov   r1, r1
mov   r1, r1

TEST_PASS:
  lrw r12, __exit
  jmp r12


