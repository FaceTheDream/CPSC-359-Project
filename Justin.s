.section    .text
/*
.globl InitUArt
.equ AUXENB, 0x7E215004
.equ AUX_MU_IIR_REG, 0x7E215044
.equ AUX_MU_CNTL_REG, 0x7E215060
.equ AUX_MU_LCR_REG, 0x7E21504C
.equ AUX_MU_MCR_REG, 0x7E215050
.equ AUX_MU_IIR_REG, 0x7E215048
.equ AUX_MU_BAUD_REG, 0x7E215068
.equ GPFSEL1, 0x20200004



InitUArt:
    ldr r2, =AUXENB
    mov r1, 0x00000001
    str r1, [r2]

    ldr r2, =AUX_MU_IIR_REG
    mov r1, 0x000000000
    str r1, [r2]

    ldr r2, =AUX_MU_CNTL_REG
    mov r1, 0x00000000
    str r1, [r2]

    ldr r2, =AUX_MU_LCR_REG
    mov r1, 0x00000011
    str r1, [r2]

    ldr r2, =AUX_MU_MCR_REG
    mov r1, 0x00000000
    str r1, [r2]

    ldr r2, =AUX_MU_IIR_REG
    mov r1, 0x000000C6
    str r1, [r2]

    ldr r2 =AUX_MU_BAUD_REG
    mov r1, 270
    str r1, [r2]

    ldr r0 = GPFSEL1
    ldr r1, [r0]
    mov r2, #0b0111111
    lsl r2, #12
    bic r1, r2

    bx, lr

*/
.globl initSNES

.equ GPFSEL1, 0x20200004
.equ GPFSEL0, 0x20200000


initSNES:
    //Setting GPIO pin 11 (Clock) to output

    ldr r0, =GPFSEL1
    ldr r1, [r0]
    mov r2, #0b0111
    lsl r2, #3
    bic r1, r2
    mov r3, #1
    lsl r3, #3
    orr r1, r3
    str r1, [r0]
/*
    mov r1, #3
    ldr r0, =GPFSEL1
    ldr r2, [r0]
    mov r3, #0b0111
    lsl r3, r1          // r3 = 0111000
    bic r2, r3          //clears pin 11 bits
    mov r3, #1          //output function code
    lsl r3, r1          //r3 = 0 001 000
    orr r2, r3          //set pin 11 function
    str r2, [r0]        //write back to GPFSEL1*/

    //Setting GPIO pin 9 (Latch) to output


    ldr r0, =GPFSEL0
    ldr r1, [r0]
    mov r2, #0b0111
    lsl r2, #27
    bic r1, r2
    mov r3, #1
    lsl r3, #3
    orr r1, r3
    str r1, [r0]
/*    mov r1, #27
    ldr r0, =GPFSEL0
    ldr r2, [r0]
    mov r3, #0b0111
    lsl r3, r1          //creates the mask to clear bits
    bic r2, r3          //clears pin 9 bits
    mov r3, #1          //output function code
    lsl r3, r1          //shifts output function code to match pin 9
    orr r2, r3          //set pin 9 function
    str r2, [r0]        //write back to GPFSEL0*/


    //Setting GPIO pin 10 (Data) to input

    ldr r0, =GPFSEL1
    ldr r1, [r0]
    mov r2, #0b0111
    lsl r2, #0
    bic r1, r2
    str r1, [r0]
/*
    mov r1, #0
    ldr r0, =GPFSEL1
    ldr r2, [r0]
    mov r3, #0b0111
    lsl r3, r1          //creates the mask to clear bits
    bic r2, r3          //clears pin 10 bits
    str r2, [r0]        //write back to GPFSEL1
    */
    bx lr

.globl writeClock
    // Write r0 value to Clock
writeClock:
    mov r1, #1          //sets pin 11
    ldr r2, =GPFSEL1    //sets GPFSEL1
    mov r3, #1
    lsl r3, r1          //aligns bit for pin 11
    teq r0, #0          //checks what r0 is equal to
    streq r3, [r2, #40] //clears if r0=0
    strne r3, [r2, #28] //writes if r0=1

    bx lr


    // Write r0 value to Latch
.globl writeLatch
writeLatch:
    mov r1, #9          //sets pin 9
    ldr r2, =GPFSEL0    //sets GPFSEL0
    mov r3, #1
    lsl r3, r1          //aligns bit for pin 9
    teq r0, #0          //checks what r0 is equal to
    streq r3, [r2, #40] //clears if r0=0
    strne r3, [r2, #28] //writes if r0=1

    bx lr

    /*Read from Data, only reads one bit
     *Return: r0 = bit held in data
     */
.globl readData
readData:
    mov r0, #10            //sets pin 10
    ldr r2, =GPFSEL0    //sets GPFSEL0
    ldr r1, [r2, #52]   //sets GPLEV0
    mov r3, #1
    lsl r3, r0          //aligns pin 10 bit
    and r1, r3          //masks everything else
    teq r1, #0
    moveq r0, #0        //return 0
    movne r0, #1        //return 1

    bx lr

    //Clock loop, where r0 is the time delay in micro seconds
.globl simpleWait
simpleWait:
    push    {r4-r6}
    ldr r4, =0x20003004 //address of CLO
    ldr r5, [r4]        //reads CLO
    add r5, r0          //adds time delay
waitLoop:
    ldr r6, [r4]        //loads current CLO
    cmp r5, r6          //compares current CLO with CLO + time delay
    bhi waitLoop        //branches when times match up

    pop     {r4-r6}
    bx lr


    //Read from SNES
.globl readSNES
readSNES:
    push {r5, r6, lr}
    buttons .req    r5  //Sets register to store buttons
    mov buttons, #0

    mov r0, #1           //writes 1 to clock
    bl writeClock

    mov r0, #1           //writes 1 to latch
    bl writeLatch

    mov r0, #12          //waits 12 microseconds
    bl simpleWait

    mov r0, #0           //writes 0 to latch
    bl writeLatch

    i .req          r6  //sets register to store iterator
    mov i, #0
pulseLoop:
    
    mov r0, #6           //waits 6 microseconds
    bl simpleWait

    mov r0, #0           //writes 0 to clock
    bl writeClock

    mov r0, #6           //waits 6 microseconds
    bl simpleWait

    bl readData         //reads data and stores it in buttons
    teq r0, #0
    beq add0

    eor buttons, #1     //places a 1 in bit 0, then rotates right
    ror buttons, #1
    b   finishReading

add0:
    ror buttons, #1     //rotates right, (stores a 0 bit)

finishReading:
    mov r0, #1          //writes 1 to clock
    bl writeClock

    add i, #1           //increments i
    cmp i, #16
    blt pulseLoop       //branches if i < 16 to start of loop

    ror buttons, #16    //rotates to get the correct format
    mov r0, buttons     //moves buttons to r0 to be returned
    pop {r5,r6,pc}
    .unreq  buttons     //unregisters buttons
    .unreq  i           //unregisters iterator

    

/* Draw the character in r0 to (r1, r2) with colour r3
 */
 .globl drawChar
drawChar:
    push {r4-r10, lr}

    chAdr	.req	r4
	px		.req	r5
	py		.req	r6
    colour  .req    r7
	row		.req	r8
	mask	.req	r9
	originalX	.req	r10

    mov     px, r1
    mov     originalX, r1
    mov     py, r2
    mov     colour, r3

	ldr		chAdr,	=font		// load the address of the font map
	add		chAdr,	r0, lsl #4	// char address = font base + (char * 16)

charLoop$:

    mov     px, originalX

	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$

	mov r0, px
    mov     r1, py
    mov     r2, colour
	bl		drawPixel			// draw red pixel at (px, py)

noPixel$:
	add		px,		#1			// increment x coordinate by 1
	lsl		mask,	#1			// shift bitmask left by 1

	tst		mask,	#0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$

	add		py,		#1			// increment y coordinate by 1

	tst		chAdr,	#0xF
	bne		charLoop$			// loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop		{r4-r10, pc}


.globl drawScore
drawScore:
    mov r1, #0
    mov r2, #0
    ldr r3, =0xFFFF
    mov r0, #'S'
    bl drawChar

    mov r1, #10
    mov r2, #0
    ldr r3, =0xFFFF
    mov r0, #'c'
    bl drawChar

    mov r1, #20
    mov r2, #0
    ldr r3, =0xFFFF
    mov r0, #'o'
    bl drawChar

    mov r1, #30
    mov r2, #0
    ldr r3, =0xFFFF
    mov r0, #'r'
    bl drawChar

    mov r1, #40
    mov r2, #0
    ldr r3, =0xFFFF
    mov r0, #'e'
    bl drawChar

    mov r1, #50
    mov r2, #0
    ldr r3, =0xFFFF
    mov r0, #':'
    bl drawChar

    bx lr

    //Takes in score in r0, and draws it on screen
.globl drawScoreNum
drawScoreNum:
    push {r4,r5, lr}

    mov r4, r0

    cmp r4, #300
    movhs r0, #'3'
    subhs r4, #300
    bhs drawHundred

    cmp r4, #200
    movhs r0, #'2'
    subhs r4, #200
    bhs drawHundred

    cmp r4, #100
    movhs r0, #'1'
    subhs r4, #100
    bhs drawHundred

    mov r0, #'0'

drawHundred:
    mov r1, #60
    mov r2, #0
    ldr r3, =0xFFFF
    b drawChar

    cmp r4, #90
    movhs r0, #'9'
    subhs r4, #90
    bhs drawTen

    cmp r4, #80
    movhs r0, #'8'
    subhs r4, #80
    bhs drawTen

    cmp r4, #70
    movhs r0, #'7'
    subhs r4, #70
    bhs drawTen

    cmp r4, #60
    movhs r0, #'6'
    subhs r4, #60
    bhs drawTen

    cmp r4, #50
    movhs r0, #'5'
    subhs r4, #50
    bhs drawTen

    cmp r4, #40
    movhs r0, #'4'
    subhs r4, #40
    bhs drawTen

    cmp r4, #30
    movhs r0, #'3'
    subhs r4, #30
    bhs drawTen

    cmp r4, #20
    movhs r0, #'2'
    subhs r4, #20
    bhs drawTen

    cmp r4, #10
    movhs r0, #'1'
    subhs r4, #10
    bhs drawTen

    mov r0, #'0'

drawTen:
    mov r1, #70
    mov r2, #0
    ldr r3, =0xFFFF
    bl drawChar

    cmp r4, #9
    moveq r0, #'9'
    beq drawOne

    cmp r4, #8
    moveq r0, #'8'
    beq drawOne

    cmp r4, #7
    moveq r0, #'7'
    beq drawOne

    cmp r4, #6
    moveq r0, #'6'
    beq drawOne

    cmp r4, #5
    moveq r0, #'5'
    beq drawOne

    cmp r4, #4
    moveq r0, #'4'
    beq drawOne

    cmp r4, #3
    moveq r0, #'3'
    beq drawOne

    cmp r4, #2
    moveq r0, #'2'
    beq drawOne

    cmp r4, #1
    moveq r0, #'1'
    beq drawOne

    mov r0, #'0'

drawOne:
    mov r1, #80
    mov r2, #0
    ldr r3, =0xFFFF
    b drawChar

    pop {r4, pc}

    

/*  Initialize the frame buffer
 *  Returns: r0 - result
 */

.globl InitFrameBuffer
InitFrameBuffer:
    mailbox .req    r2          //Sets mailbox to R2
    ldr mailbox,    =0x2000B880 //Loads the memory address for the mailbox

    fbinfo  .req    r3          //Sets fbinfo to R3
    ldr fbinfo, =FrameBufferInfo//Loads the memory address for the frame buffer info

mailboxFull:
    ldr r0, [mailbox, #0x18]    //Checks status of the mailbox
    tst r0, #0x80000000         //Checks to see if mailbox is currently full
    bne mailboxFull             //Waits until mailbox is not full
    add r0, fbinfo, #0x40000000 //r0 = framebufferinfo
    orr r0, #0b0001             //Sets mailbox channel to 1
    str r0, [mailbox, #0x20]    //Sets framebufferinfo to write register

mailboxEmpty:
    ldr r0, [mailbox, #0x18]
    tst r0, #0x40000000         //Checks to see if mailbox is currently empty
    bne mailboxFull             //Waits until mailbox is not empty
    ldr r0, [mailbox, #0x00]    //Reads from the mailbox read register
    and r1, r0, #0xF            //Extracts the channel information
    teq r1, #0b0001             //Checks to see if the channel is equal to 1 for the framebuffer channel
    bne mailboxEmpty            //Loops if the message is not for framebuffer channel
    bic r1, r0, #0xF            //Extracts high 28 bits (everything minus channel)
    teq r1, #0                  //Tests to see if the high 28 bits are 0
    movne r0, #0                //Returns 0 if high 28 bits are not 0
    bxne    lr                  //Returns if not equal

pointerWait:
    ldr r0, [fbinfo, #0x20]     //Loads the value of the pointer from the frame buffer info
    teq r0, #0                  //tests to see if the pointer is 0
    beq pointerWait             //Branches if the pointer is still 0

    ldr r4, =FrameBufferPointer //Sets r4 to [FrameBufferPointer]
    str r0, [r4]                //Stores framebuffer pointer

    .unreq mailbox              //Unregisters mailbox
    .unreq  fbinfo              //Unregisters fbinfo

    bx  lr                      //Returns pointer value to indicate success
    

.section    .data

.align 12
FrameBufferInfo:
    .int    1024    // 0 - Width
    .int    768     // 4 - Height
    .int    1024    // 8 - vWidth
    .int    768*2   // 12 - vHeight
    .int    0       // 16 - GPU - Pitch
    .int    16      // 20 - Bit Depth
    .int    0       // 24 - vX
    .int    0       // 28 - vY
    .int    0       // 32 - FB Pointer
    .int    0       // 36 - FB Size

.align 4
.globl FrameBufferPointer

FrameBufferPointer:
    .int    0
.globl font
font:
    .incbin	"font.bin"


/*
.globl InitFrameBuffer
InitFrameBuffer:
    infoAdr .req r4
    push    {r4, lr}
    ldr     infoAdr, =FrameBufferInfo       // get framebuffer info address
    
	result  .req r0

    mov     r0, infoAdr                     // store fb info address as mail message
	add		r0,	#0x40000000					// set bit 30; tell GPU not to cache changes
    mov     r1, #1                          // mailbox channel 1
    bl      MailboxWrite                    // write message
    
    mov     r0, #1                          // mailbox channel 1
    bl      MailboxRead                     // read message
    
    teq     result, #0
    movne   result, #0
    popne   {r4, pc}                        // return 0 if message from mailbox is 0
    
pointerWait$:
    ldr     result, [infoAdr, #32]
    teq     result, #0
    beq     pointerWait$                    // loop until the pointer is set
	
	ldr		r1,		=FrameBufferPointer
	str		result,	[r1]					// store the framebuffer pointer
    
    mov     result, infoAdr                 // set result to address of fb info struct
    pop     {r4, pc}                        // return
    
    .unreq  result
    .unreq  infoAdr

.globl MailboxWrite
MailboxWrite:
    tst     r0, #0b1111                     // if lower 4 bits of r0 != 0 (must be a valid message)
    movne   pc, lr                          //  return
    
    cmp     r1, #15                         // if r1 > 15 (must be a valid channel)
    movhi   pc, lr                          //  return
    
    channel .req r1
    value   .req r2
    mov     value, r0
    
    mailbox .req r0
	ldr     mailbox,=0x2000B880
    
wait1$:
    status  .req r3
    ldr     status, [mailbox, #0x18]        // load mailbox status
    
    tst     status, #0x80000000             // test bit 32
    .unreq  status
    bne     wait1$                          // loop while status bit 32 != 0
    
    add     value, channel                  // value += channel
    .unreq  channel
    
    str     value, [mailbox, #0x20]         // store message to write offset
    
    .unreq  value
    .unreq  mailbox
    
    bx		lr


* Read from mailbox
 * Args:
 *  r0 - channel
 * Return:
 *  r0 - message
 *
.globl MailboxRead
MailboxRead:
    cmp     r0, #15                         // return if invalid channel (> 15)
    movhi   pc, lr
    
    channel .req r1
    mov     channel, r0
    
    mailbox .req r0
	ldr     mailbox,=0x2000B880
    
rightmail$:
wait2$:
    status  .req r2
    ldr     status, [mailbox, #0x18]        // load mailbox status
    
    tst     status, #0x4000000              // test bit 30
    .unreq  status
    bne     wait2$                          // loop while status bit 30 != 0
    
    mail    .req r2
    ldr     mail, [mailbox, #0]             // retrieve message
    
    inchan  .req r3
    and     inchan, mail, #0b1111           // mask out lower 4 bits of message into inchan
    
    teq     inchan, channel
    .unreq  inchan
    bne     rightmail$                      // if not the right channel, loop
    
    .unreq  mailbox
    .unreq  channel
    
    and     r0, mail, #0xfffffff0           // mask out channel from message, store in return (r0)
    .unreq  mail
    
	bx		lr
*/

/*  interupt stuff

hang:
	b		hang

InstallIntTable:
	ldr		r0, =IntTable
	mov		r1, #0x00000000

	// load the first 8 words and store at the 0 address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// load the second 8 words and store at the next address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// switch to IRQ mode and set stack pointer
	mov		r0, #0xD2
	msr		cpsr_c, r0
	mov		sp, #0x8000

	// switch back to Supervisor mode, set the stack pointer
	mov		r0, #0xD3
	msr		cpsr_c, r0
	mov		sp, #0x8000000

	bx		lr	

irq:
	push	{r0-r12, lr}

	// test if there is an interrupt pending in IRQ Pending 2
	ldr		r0, =0x2000B200
	ldr		r1, [r0]
	tst		r1, #0x200		// bit 9
	beq		irqEnd

	// test that at least one GPIO IRQ line caused the interrupt
	ldr		r0, =0x2000B208		// IRQ Pending 2 register
	ldr		r1, [r0]
	tst		r1, #0x001E0000
	beq		irqEnd

	// test if GPIO line 10 caused the interrupt
	ldr		r0, =0x20200040		// GPIO event detect status register
	ldr		r1, [r0]
	tst		r1, #0x400			// bit 10
	beq		irqEnd

	// invert the LSB of SNESDat
	ldr		r0, =SNESDat
	ldr		r1, [r0]
	eor		r1, #1
	str		r1, [r0]

	// clear bit 10 in the event detect register
	ldr		r0, =0x20200040
	mov		r1, #0x400
	str		r1, [r0]
	
irqEnd:
	pop		{r0-r12, lr}
	subs	pc, lr, #4

.section .data

SNESDat:
	.int	1

IntTable:
	// Interrupt Vector Table (16 words)
	ldr		pc, reset_handler
	ldr		pc, undefined_handler
	ldr		pc, swi_handler
	ldr		pc, prefetch_handler
	ldr		pc, data_handler
	ldr		pc, unused_handler
	ldr		pc, irq_handler
	ldr		pc, fiq_handler

reset_handler:		.word InstallIntTable
undefined_handler:	.word hang
swi_handler:		.word hang
prefetch_handler:	.word hang
data_handler:		.word hang
unused_handler:		.word hang
irq_handler:		.word irq
fiq_handler:		.word hang

*/
