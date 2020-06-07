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
//	.rept   128
//	.long   __dummy
//	.endr
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   trap0_handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   tspend_handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler
        .long   Default_Handler

/* External interrupts */
        .long   USART_IRQHandler        /*  0:  UART         */
    	.long   CORET_IRQHandler        /*  1:  CoreTIM      */
    	.long   TIM0_IRQHandler         /*  2:  Timer0       */
    	.long   TIM1_IRQHandler         /*  3:  Timer1       */
    	.long   TIM2_IRQHandler         /*  4:  Timer2       */
    	.long   TIM3_IRQHandler         /*  5:  Timer3       */
    	.long   Default_Handler
//	.long   USI_IRQHandler          /*  6:  USI          */
    	.long   GPIO0_IRQHandler        /*  7:  GPIO0        */
    	.long   GPIO1_IRQHandler        /*  8:  GPIO1        */
    	.long   GPIO2_IRQHandler        /*  9:  GPIO2        */
    	.long   GPIO3_IRQHandler        /*  10: GPIO3        */
    	.long   GPIO4_IRQHandler        /*  11: GPIO4        */
    	.long   GPIO5_IRQHandler        /*  12: GPIO5        */
    	.long   GPIO6_IRQHandler        /*  13: GPIO6        */
    	.long   GPIO7_IRQHandler        /*  14: GPIO7        */
    	.long   STIM0_IRQHandler        /*  15: STimer0      */
    	.long   STIM1_IRQHandler        /*  16: STimer1      */
    	.long   STIM2_IRQHandler        /*  17: STimer2      */
    	.long   STIM3_IRQHandler        /*  18: STimer3      */
    	.long   PAD_IRQHandler          /*  19: pad          */

/* User interrupts */
        .long   SPISLAVE_IRQHandler     /*  20: spi slave    */
	.long   USI_IRQHandler        /* 21 add*/


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
 
__to_main:
	lrw r15, __exit
	lrw r0,main
	jmp r0
	mov r0, r0
	mov r0, r0
	mov r0, r0
	mov r0, r0
	mov r0, r0
	
   

.text
    

    .align  2
    .weak   Default_Handler
    .type   Default_Handler, %function
Default_Handler:
    br      Default_Handler
    .size   Default_Handler, . - Default_Handler
    

    .macro  def_irq_handler handler_name
    .weak   \handler_name
    .globl  \handler_name
    .set    \handler_name, Default_Handler      //assignment Default_Handler to irq_handler
    .endm

    def_irq_handler USART_IRQHandler
    def_irq_handler CORET_IRQHandler
    def_irq_handler TIM0_IRQHandler
    def_irq_handler TIM1_IRQHandler
    def_irq_handler TIM2_IRQHandler
    def_irq_handler TIM3_IRQHandler
    def_irq_handler GPIO0_IRQHandler
    def_irq_handler GPIO1_IRQHandler
    def_irq_handler GPIO2_IRQHandler
    def_irq_handler GPIO3_IRQHandler
    def_irq_handler GPIO4_IRQHandler
    def_irq_handler GPIO5_IRQHandler
    def_irq_handler GPIO6_IRQHandler
    def_irq_handler GPIO7_IRQHandler
    def_irq_handler STIM0_IRQHandler
    def_irq_handler STIM1_IRQHandler
    def_irq_handler STIM2_IRQHandler
    def_irq_handler STIM3_IRQHandler
    def_irq_handler PAD_IRQHandler
    def_irq_handler SPISLAVE_IRQHandler
    def_irq_handler trap0_handler
    def_irq_handler tspend_handler
    
    
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