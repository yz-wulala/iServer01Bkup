//start from __start, 
//(0)initialize vector table
//(1)initialize all registers
//(2)prepare initial reg values for user process
//(3)initialize supervisor mode stack pointer
//(4)construct ASID Table
//(5)prepare PTE entry for user process start virtual address
//(6)creat a mapping between VPN:0 and PFN:0 for kernel
//(7)set VBR register
//(8)enable EE and MMU
//(9)jump to the main procedure using jsri main

.text
.export vector_table
.align  10
.export __start	
vector_table:	//totally 256 entries
	.long __start
.ifdef ck801
	.rept   128
	.long   __dummy
	.endr
  __start:
//initialize all registers
	movi r0, 0
	movi r1, 0
	movi r2, 0
	movi r3, 0
	movi r4, 0
	movi r5, 0
	movi r6, 0
	movi r7, 0
  .endif
.ifdef ck802
	.rept   128
	.long   __dummy
	.endr
__start:
//initialize all registers
	movi r0, 0
	movi r1, 0
	movi r2, 0
	movi r3, 0
	movi r4, 0
	movi r5, 0
	movi r6, 0
	movi r7, 0
	movi r8, 0
	movi r9, 0
	movi r10, 0
	movi r11, 0
	movi r12, 0
	movi r13, 0
	movi r14, 0
	movi r15, 0
.endif
.ifdef ck803s
	.rept   255
	.long   __dummy
	.endr
__start:
//initialize all registers
	movi r0, 0
	movi r1, 0
	movi r2, 0
	movi r3, 0
	movi r4, 0
	movi r5, 0
	movi r6, 0
	movi r7, 0
	movi r8, 0
	movi r9, 0
	movi r10, 0
	movi r11, 0
	movi r12, 0
	movi r13, 0
	movi r14, 0
	movi r15, 0
.ifdef hgpr
	movi r16, 0
	movi r17, 0
	movi r18, 0
	movi r19, 0
	movi r20, 0
	movi r21, 0
	movi r22, 0
	movi r23, 0
	movi r24, 0
	movi r25, 0
	movi r26, 0
	movi r27, 0
.endif
	movi r28, 0
.ifdef hgpr
	movi r29, 0
	movi r30, 0
	movi r31, 0
.endif
.endif
.ifdef ck804
	.rept   255
	.long   __dummy
	.endr
__start:
//initialize all registers
	movi r0, 0
	movi r1, 0
	movi r2, 0
	movi r3, 0
	movi r4, 0
	movi r5, 0
	movi r6, 0
	movi r7, 0
	movi r8, 0
	movi r9, 0
	movi r10, 0
	movi r11, 0
	movi r12, 0
	movi r13, 0
	movi r14, 0
	movi r15, 0
.ifdef hgpr
	movi r16, 0
	movi r17, 0
	movi r18, 0
	movi r19, 0
	movi r20, 0
	movi r21, 0
	movi r22, 0
	movi r23, 0
	movi r24, 0
	movi r25, 0
	movi r26, 0
	movi r27, 0
.endif
	movi r28, 0
.ifdef hgpr
	movi r29, 0
	movi r30, 0
	movi r31, 0
.endif
.endif
.ifdef ck801
//set VBR
	lrw r2, vector_table
	mtcr r2, cr<1,0>

	//enable IE and EE bit of psr
	mfcr r2, cr<0,0>
	bseti r2, r2, 6
	bseti r2, r2, 8
	mtcr r2, cr<0,0>


	//initialize kernel stack
	lrw  r14, __kernel_stack
	lrw  r4, __kernel_stack
	subi r4, 0x40
	lrw  r5, 0x0
	INIT_KERLE_STACK:
	addi r4, 0x4
	st.w r5, (r4)
	cmphs r14, r4
	bt  INIT_KERLE_STACK
 
__to_main:
	lrw r15, __exit
	lrw r0,main
	jmp r0
	mov r0, r0
	mov r0, r0
	mov r0, r0
	mov r0, r0
	mov r0, r0

.export __exit
__exit:
	mfcr    r1, cr<0,0>
	lrw     r1, 0xFFFF
	mtcr    r1, cr<11,0>
	lrw     r1, 0xFFF
	lrw     r0, __kernel_stack
	st      r1, (r0)

.export __fail
__fail:
	lrw     r1, 0xEEEE
	mtcr    r1, cr<11,0>
	lrw     r1, 0xEEE
	lrw     r0, __kernel_stack
	st      r1, (r0)

__dummy:
	br      __fail

.data
	.long 0
.else
	//set VBR
	lrw r2, vector_table
	mtcr r2, cr<1,0>

	//enable IE and EE bit of psr
	mfcr r2, cr<0,0>
	bseti r2, r2, 6
	bseti r2, r2, 8
	mtcr r2, cr<0,0>


	//initialize kernel stack
	lrw  r14, __kernel_stack
	lrw  r3, 0x40
	subu r4, r14, r3
	lrw  r5, 0x0
	INIT_KERLE_STACK:
	addi r4, 0x4
	st.w r5, (r4)
	cmphs r14, r4
	bt  INIT_KERLE_STACK


    //copy data section
lrw r1, __erodata
lrw r2, __data_start__
lrw r3, __data_end__

subu r3, r2
cmpnei r3, 0
bf .L_loop0_done

.L_loop0:
	ldw r0, (r1, 0)
	stw r0, (r2, 0)
	addi r1, 4
	addi r2, 4
	subi r3, 4
	cmpnei r3, 0
	bt .L_loop0
	
.L_loop0_done:
//clean BSS
	lrw r1, __bss_start__
	lrw r2, __bss_end__
	
	movi r0, 0
	subu r2, r1
	cmpnei r2, 0
	bf .L_loop1_done
	
.L_loop1:
	stw r0, (r1,0)
	addi r1, 4
	subi r2, 4
	cmpnei r2, 0
	bt .L_loop1
	
.L_loop1_done:
	movi r0, 0
	movi r1, 0
	movi r2, 0
	movi r3, 0

 
__to_main:
	lrw r15, __exit
	lrw r0,main
	jmp r0
	mov r0, r0
	mov r0, r0
	mov r0, r0
	mov r0, r0
	mov r0, r0

.export __exit
__exit:
	mfcr    r1, cr<0,0>
	movih   r1, 0xFFFF
	mtcr    r1, cr<11,0>
	movi    r1, 0xFFF
	lrw     r0, __kernel_stack
	st      r1, (r0)

.export __fail
__fail:
	movih   r1, 0xEEEE
	mtcr    r1, cr<11,0>
	movi    r1, 0xEEE
	lrw     r0, __kernel_stack
	st      r1, (r0)

__dummy:
	br      __fail

.data
	.long 0
.endif
