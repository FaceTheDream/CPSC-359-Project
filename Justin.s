.section    .text

.equ GPFSEL1, 0x20200004
.equ GPFSEL0, 0x20200000
.globl initSNES




initSNES:
    //Setting GPIO pin 11 (Clock) to output



    //Setting GPIO pin 9 (Latch) to output


    ldr		r0, =GPFSEL0
	ldr		r1, [r0]
	
	// clear bits 27-29 and set them to 001 (Output)
	bic		r1, #0x38000000
	orr		r1, #0x08000000

	// write back to GPIOFSEL0
	str		r1, [r0]



    //Setting GPIO pin 10 (Data) to input

    ldr		r0, =GPFSEL1
	ldr		r1, [r0]

	// clear bits 0-2 (GPIO 10) and 3-5 (GPIO 11), set 0-2 to 000 (Input) and 3-5 to 001 (Output)
	bic		r1, #0x0000003F
	orr		r1, #0x00000008

	// write back to GPIOFSEL1
	str		r1, [r0]


    bx lr

.globl writeClock
    // Write r0 value to Clock
writeClock:
    mov r1, #11          //sets pin 11
    ldr r2, =0x20200000    //sets GPFSEL1
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
    ldr r2, =0x20200000    //sets GPFSEL0
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
    ldr r2, =0x20200000    //sets GPFSEL0
    ldr r1, [r2, #52]   //sets GPLEV0
    mov r3, #1

    lsl r3, r0          //aligns pin 10 bit
    and r1, r3          //masks everything else
testRead:
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
    i .req          r6  //sets register to store iterator
    mov i, #0



    mov r0, #1           //writes 1 to clock
    bl writeClock

    mov r0, #1           //writes 1 to latch
    bl writeLatch

    mov r0, #12          //waits 12 microseconds
    bl simpleWait

    mov r0, #0           //writes 0 to latch
    bl writeLatch

    b testPulse
   
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
    ror buttons, #1     //rotates right, (stores a 0 bit)*/

finishReading:
    mov r0, #1          //writes 1 to clock
    bl writeClock
testPulse:
    add i, #1           //increments i
    cmp i, #16
    blt pulseLoop       //branches if i < 16 to start of loop

    ror buttons, #17    //rotates to get the correct format
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
	push {lr}
    mov r1, #0
    mov r2, #0
    ldr r3, =0x0000
    mov r0, #'S'
    bl drawChar

    mov r1, #10
    mov r2, #0
    ldr r3, =0x0000
    mov r0, #'c'
    bl drawChar

    mov r1, #20
    mov r2, #0
    ldr r3, =0x0000
    mov r0, #'o'
    bl drawChar

    mov r1, #30
    mov r2, #0
    ldr r3, =0x0000
    mov r0, #'r'
    bl drawChar

    mov r1, #40
    mov r2, #0
    ldr r3, =0x0000
    mov r0, #'e'
    bl drawChar

    mov r1, #50
    mov r2, #0
    ldr r3, =0x0000
    mov r0, #':'
    bl drawChar

    pop {pc}

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
    ldr r3, =0x0000
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
    ldr r3, =0x0000
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
    ldr r3, =0x0000
    b drawChar

    pop {r4, r5, pc}

    

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



