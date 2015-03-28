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

*/
.globl readController

.equ GPFSEL1, 0x20200004
.equ GPFSEL0, 0x20200000


readController:
    buttons .req    r0

    mov buttons, 0

    //Setting GPIO pin 11 (Clock) to output

    mov r1, #3
    ldr r2, =GPFSEL1
    mov r3, #0b0111
    lsl r3, r1          // r3 = 0111000
    bic r1, r2          //clears pin 11 bits
    mov r3, #1          //output function code
    lsl r3, r1          //r3 = 0 001 000
    orr r1, r3          //set pin 11 function
    str r1, [r0]        //write back to GPFSEL1

    //Setting GPIO pin 9 (Latch) to output

    mov r1, #27
    ldr r2, =GPFSEL0
    mov r3, #0b0111
    lsl r3, r1          //creats the mask to clear bits
    bic r1, r2          //clears pin 9 bits
    mov r3, #1          //output function code
    lsl r3, r1          //shifts output function code to match pin 9
    orr r1, r3          //set pin 9 function
    str r1, [r0]        //write back to GPFSEL0

    //Setting GPIO pin 10 (Data) to input

    mov r1, #0
    ldr r2, =GPFSEL1
    mov r3, #0b0111
    lsl r3, r1          //creates the mask to clear bits
    bic r1, r2          //clears pin 10 bits
    str r1, [r0]        //write back to GPFSEL1


    // Write r0 value to Clock
writeClock:
    mov r1, #11          //sets pin 11
    ldr r2, =GPFSEL0    //sets GPFSEL0
    mov r3, #1
    lsl r3, r0          //aligns bit for pin 11
    teq r0, #0          //checks what r0 is equal to
    streq r3, [r2, #40] //clears if r0=0
    strne r3, [r2, #28] //writes if r0=1

    // Write r0 value to Latch
writeLatch:
    mov r1, #9          //sets pin 9
    ldr r2, =GPFSEL0    //sets GPFSEL0
    mov r3, #1
    lsl r3, r0          //aligns bit for pin 9
    teq r0, #0          //checks what r0 is equal to
    streq r3, [r2, #40] //clears if r0=0
    strne r3, [r2, #28] //writes if r0=1

    /*Read from Data, only reads one bit
     *Return: r4 = bit held in data
     */
readData:
    r0 = #10            //sets pin 10
    ldr r2, =GPFSEL0    //sets GPFSEL0
    ldr r1, [r2, #52]   //sets GPLEV0
    mov r3, #1
    lsl r3, r0          //aligns pin 10 bit
    and r1, r3          //masks everything else
    teq r1, #0
    moveq r4, #0        //return 0
    movne r4, #1        //return 1

    //Clock loop, where r0 is the time delay in micro seconds
simpleWait:
    ldr r1, =0x20003004 //address of CLO
    ldr r1, [r0]        //reads CLO
    add r1, r0          //adds time delay
waitLoop:
    ldr r2, [r0]        //loads current CLO
    cmp r1, r2          //compares current CLO with CLO + time delay
    bhi waitLoop        //branches when times match up



    







/*  Initialize the frame buffer
 *  Returns: r0 - result
 */

.globl InitFrameBuffer
InitFrameBufer:
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
    str r1, [r4]                //Stores framebuffer pointer

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
    .int    8       // 20 - Bit Depth
    .int    0       // 24 - vX
    .int    0       // 28 - vY
    .int    0       // 32 - FB Pointer
    .int    0       // 36 - FB Size

.align 4
.globl FrameBufferPointer
FrameBufferPointer:
    .int    0