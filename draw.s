.section .init
.globl drawPixel	// draws a pixel at location (x,y)
			// r0 is x
			// r1 is y
			// r2 is colour
.globl drawBG
.globl drawRect
.globl drawLine
.globl drawTriangleUp
.globl drawTriangleDown
.globl drawTriangleLeft
.globl drawTriangleRight
.globl drawDiamond
.globl drawBeeBody
.globl drawBeeWings
.globl drawBeeP
.globl drawBeeK
.globl drawBeeQ
.globl drawPlayer
.globl drawRectB
.globl drawBeeSting
.globl drawBush
.globl drawLazer
.globl drawCursor
.globl drawPauseScreen
.globl drawGameOverScreen
.globl refreshGameScreen

.section .text

drawPixel: //r0 is assumed to be the x location, r1 is assumed to be the y location, r2 is assumed to be the colour data
	
	cmp    r0,    #1024                  //check max x
	bge    endDrawPixel                  //
	cmp    r0,    0                      //check min x
	blt    endDrawPixel                  //
	cmp    r1,    #768                   //check max y
	bge    endDrawPixel                  //
	cmp    r1,    0                      //check min y
	blt    endDrawPixel                  //
	
	mul    r1,    #1024                  //row-major
	add    r0,    r1                     //
	lsl    r0,    #3                     //8-bit colour assumed
	ldr    r1,    =frameBufferPointer    // should get frameBuffer location from file that contains frameBuffer information
	ldr    r1,    [r1]                   //
	add    r1,    r0                     // add offset
	strh   r2,   [r1]                    //
	
endDrawPixel:
	bx     lr                            //

drawBG: //r0 is the colour to set the background to
	push {r3-r5}
	mov	r5, r0 	      //colour
	mov	r3, #0        //row number
	rowBGloops:
	cmp	r3, #1024     //compare row number with 1024
	bge	rowBGloope    // end if row number >= 1024
	mov	r4, #0        //column number
	colBGloops:
	cmp	r4, #768      //compare column number with 768
	bge	colBGloope    //end if column number >= 768
	mov	r0, r3	      //set x to draw
	mov	r1, r4        //set y to draw
	mov	r2, r5        //set colour to draw
	bl	drawPixel     //draw current pixel
	add	r4, #1	      //increment column
	b	colBGloops    //back to start of column loop
	colBGloope:
	add	r3, #1        // increment row
	b	rowBGloops    //back to start of row loop
	rowBGloope:
	pop {r3-r5}            //restore registers
	bx	lr
	
drawRect: // in order on stack: {x,y,colour,lenX,lenY}
	push {r3,r4,r5,r6,r7,r8} //save registers
	ldr   r7, [sp,#24] // x
	ldr   r8, [sp,#28] // y
	ldr   r2, [sp,#32] // colour
	ldr   r3, [sp,#36] // lenX
	ldr   r4, [sp,#40] // lenY
	mov   r5, #0       // i=0
	dRFL1s:
	cmp	  r5, r3   // compare i and lenX
	bge	  dRFL1e   // if i>= lenX, the for loop ends
	mov   r6, #0       // j=0
	dRFL2s:
	cmp   r6, r4       // compares j with lenY
	bge   dRFL2e	   // if j >= lenY, the loop ends
	add   r0, r7, r5   // stores x+i in r0
	add   r1, r8, r6   // stores y+j in r1
	bl     drawPixel   // calls drawPixel
	add   r6, #1       // increments j
	b     dRFL2s       // back to the start of column iterating loop
	dRFL2e:
	add   r5, #1       // increments i
	b     dRFL1s       // back to the start of row iterating loop
	dRFL1e:
	pop {r3,r4,r5,r6,r7,r8} // restore registers
	bx	lr         //branch to calling code
	
	
drawLine: //takes thickness as a parameter, vertical/horizontal/diagonalU/diagonalD as parameters
	push  {r3-r10}     // save registers
	ldr   r0, [sp,#32] // x
	ldr   r1, [sp,#36] // y
	ldr   r2, [sp,#56] // colour
	ldr   r3, [sp,#48] // length
	ldr   r4, [sp,#52] // thickness
	ldr   r5, [sp,#44] // direction
	sub   r6, r4, #1   // stores thickness - 1 into r6
	lsr   r6, #1 	   // stores (thickness-1)/2 into r6 (a)
	mov   r7, #0       // i
	mov   r8, r0       // x (constant)
	mov   r9, r1       // y (constant)
	dLFL1s:
	cmp   r7, r3       // compares i with length
	bge   dLFL1e       // end loop if i >= length
	mov   r0, r8       // store x in r0
	mov   r1, r9       // store y in r1
	bl    drawPixel    // draws pixel in (x,y) with colour r2
	cmp   r4, #1       // compares thickness with 1
	ble   afterif1     // if thickness <= 1, end loop
	and   r0, r5, #2   // store direction & 0x0010 into r0
	lsr   r0, #1       // store r0/2 into r0
	and   r1, r5, #4   // store direction & 0x0100 into r1
	lsr   r1, #2       // store r1/4 into r1
	orr   r0, r1       // set the first bit to be one in r0 if it is so in either r0 , r1
	ldr   r1, =0xFFFFFFFE
	bic   r0, r1       // clears every bit in r0 excluding the first bit
	cmp   r0, #1       // checks if either bit 1 or bit 2 of direction is 1
	bne   afterif1     // if neither are 1, go to the else portion
	sub   r0, r8, r6   // stores x - a in r0
	mov   r1, r9       // stores y in r1
	mov   r10, #1      // stores 1 in r10
	push {r0,r1,r2,r6,r10} // push required parameters onto the stack
	bl     drawRect    // call drawRect
	pop {r0,r1,r2,r6,r10} // remove parameters from stack
	mov    r0, r8      // store x in r0
	push {r0,r1,r2,r6,r10} // push required parameters onto the stack
	bl     drawRect     // call drawRect
	pop {r0,r1,r2,r6,r10}  // remove parameters from stack
	afterif1:          // after thickness for horizontal
	and   r0, r5, #1    // 
	cmp   r0, #1
	bne   afterif2      // if (direction & 1) != 1, go to else 
	cmp	  r4, #1
	ble   afterif3      // if thickness <= 1, go to else
	push  {r4}
	mov   r0, #1
	push  {r0}
	push  {r2}
	mov   r0,r8
	sub   r1,r9,r4
	push  {r0,r1}
	bl     drawRect
	pop  {r0,r1}
	pop  {r0,r1}
	pop   {r0}
	push  {r4}
	mov   r0, #1
	push {r0}
	mov   r0, r8
	mov   r1, r9
	push {r0,r1,r2}
	bl     drawRect
	pop {r0,r1}
	pop {r0,r1}
	pop {r0}
	afterif3:             //after thickness for vertical line
	add   r8, #1
	afterif2:
	tst  r5, #2
	bne  ifpart2          // direction & 2 != 1
	add  r9, #1	      // increment y
	ifpart2:
	tst r5, #4
	bne  afterif4        // direction & 4 != 1
	sub  r9, #1          // decrement y
	afterif4:
	add  r7, #1
	b    dLFL1s
	dLFL1e:	
	pop {r3-r9}           // restore registers
	bx	lr           // branch to calling code


drawTriangleUp: //r0 is x, r1 is y, r2 is height, colour is sent over stack
push {r3-r8}
mov	r3, r0       //x
mov	r4, r1       //y
mov	r5, r2       // height
ldr	r6, [sp,#24] //colour
mov	r7, #0       // i
dtufl1start:         //draw triangle up for loop 1 start
cmp	r7, r5       
bge	dtufl1end   
push	 {r6} 	     //push 6th paramter, colour onto stack
mov	r0, #1
push	 {r0} 	     //push 5th parameter, thickness (1) onto stack
add	r0, r7, r7
add	r0, #1
pus	 {r0}	     //push 4th parameter, length (2i+1) onto stack
mov	r0, #1
push 	{r0}	     //push 3rd parameter, direction (1)(horizontal) onto stack
add	r0, r4, r7
push 	{r0}	     //push 2nd paramteter, (y+i) onto stack
sub	r0, r3, r7
push    {r0}	     //push 1st paramter, (x-i) onto stack
bl	drawLine
add	sp, #24
add	r7, #1
b	dtufl1start
dtufl1end:
pop    {r3-r8}
bx	lr


drawTriangleDown: //r0 is x, r1 is y, r2 is height, colour is sent over stack
push {r3-r7}
mov	r3, r0 //x
mov	r4, r1 //y
mov	r5, r2 // height
ldr	r6, [sp,#20] //colour
mov	r7, #0 // i
dtdfl1start: //draw triangle down for loop 1 start
cmp	r7, r5
bge	dtdfl1end
push {r6} 	//push 6th paramter, colour onto stack
mov	r0, #1
push {r0} 	//push 5th parameter, thickness (1) onto stack
add	r0, r7, r7
add	r0, #1
push {r0}	//push 4th parameter, length (2i+1) onto stack
mov	r0, #1
push {r0}	//push 3rd parameter, direction (1)(horizontal) onto stack
sub	r0, r4, r7
push {r0}	//push 2nd paramteter, (y-i) onto stack
sub	r0, r3, r7
push {r0}	//push 1st paramter, (x-i) onto stack
bl	drawLine
add	sp, #24
add	r7, #1
b	dtdfl1start
dtdfl1end:
pop {r3-r7}
bx	lr


drawTriangleLeft: //r0 is x, r1 is y, r2 is height, colour is sent over stack
push {r3-r7}
mov	r3, r0 //x
mov	r4, r1 //y
mov	r5, r2 // height
ldr	r6, [sp,#20] //colour
mov	r7, #0 // i
dtlfl1start: //draw triangle left for loop 1 start
cmp	r7, r5
bge	dtlfl1end
push {r6} 	//push 6th paramter, colour onto stack
mov	r0, #1
push {r0} 	//push 5th parameter, thickness (1) onto stack
add	r0, r7, r7
add	r0, #1
push {r0}	//push 4th parameter, length (2i+1) onto stack
mov	r0, #2
push {r0}	//push 3rd parameter, direction (2)(vertical) onto stack
add	r0, r4, r7
push {r0}	//push 2nd paramteter, (y+i) onto stack
add	r0, r3, r7
push {r0}	//push 1st paramter, (x+i) onto stack
bl	drawLine
add	sp, #24
add	r7, #1
b	dtlfl1start
dtlfl1end:
pop {r3-r7}
bx	lr

drawTriangleRight: //r0 is x, r1 is y, r2 is height, colour is sent over stack
push {r3-r7}
mov	r3, r0 //x
mov	r4, r1 //y
mov	r5, r2 // height
ldr	r6, [sp,#20] //colour
mov	r7, #0 // i
dtrfl1start: //draw triangle right for loop 1 start
cmp	r7, r5
bge	dtrfl1end
push {r6} 	//push 6th paramter, colour onto stack
mov	r0, #1
push {r0} 	//push 5th parameter, thickness (1) onto stack
add	r0, r7, r7
add	r0, #1
push {r0}	//push 4th parameter, length (2i+1) onto stack
mov	r0, #2
push {r0}	//push 3rd parameter, direction (2)(vertical) onto stack
add	r0, r4, r7
push {r0}	//push 2nd paramteter, (y+i) onto stack
sub	r0, r3, r7
push {r0}	//push 1st paramter, (x-i) onto stack
bl	drawLine
add	sp, #24
add	r7, #1
b	dtrfl1start
dtrfl1end:
pop {r3-r7}
bx	lr

drawDiamond:
//r0 is x, r1 is y, r2 is height
//[sp] is colour
// (x,y) is the topmost point of the diamond
push {r3-r6}    //save registers to restore after use
mov	r3, r0  // x
mov	r4, r1  // y
lsr	r2, #1  // divide height in half
mov	r5, r2  // height/2
ldr	r6, [sp,#16] // colour
push {r6}	//push colour onto the stack
bl	drawTriangleUp //draw the top half of the diamond
add	sp, #4  //remove colour off the stack
add	r4, r5  
add	r4, r5  //add the full height to the y coordinate
mov	r0, r3  //set x for drawing
mov	r1, r4  // set y for drawing
mov	r2, r5  // set height for drawing
push {r6}	//push colour onto the stack
bl	drawTriangleDown //draw the bottom half of the diamond
add	sp, #4  //remove colour off the stack
pop {r3-r10}	//restore registers
bx	lr	//branch to calling code

drawBeeBody:
	// r0, top left x
	// r1, top left y
	// r2, size multiplier (will be included in a shift operation, ex: 2^r2)
	// [sp], non-black colour
	// nine-striped bees
	push {r3-r8}	     // save registers
	mov	r8, r2       // number of times to multiply size by 2
	mov	r3, r0       // x
	mov	r4, r1       // y
	mov	r5, #0       // stripe counter initialization
	ldr	r6, =beeBlackColour
	ldr	r6, [r6]     //black colour
	ldr	r7, [sp,#24] //other colour
	startStripBeeLoop:
	cmp	r5, #10
	bge	endStripBeeLoop
	mov	r0, #10        // init stripe xlength
	lsl	r0, r8        // adjust stripe xlength
	mov	r1, #90       // init bee height
	lsl	r1, r8        // adjusted bee height
	push {r1}              //push p4
	push {r0}              //push p3
	tst	r5, #1
	bne	stripecolourelse
	push {r6}              //push p2
	b 	stripecolourafterif
	stipecolourelse:
	push {r7}              //push p2
	stripecolourafterif:
	push {r4}              //push p1
	push {r3}              //push p0
	bl	drawRect
	add	sp, #20       //remove parameters from stack
	add	r5, #1        //increment stripe counter
	endStripBeeLoop:
	pop {r3-r8}	      // restore registers
	bx	lr	      // branch to calling code

drawRectB: //rectangle with border
	// r0 is x location
	// r1 is y location
	// r2 is borderwidth
	// [sp] is bordercolour
	// [sp+4] is main rectangle colour
	// [sp+8] is length
	// [sp+12] is width
	push {r3-r10}
	mov	r3, r0 // x
	mov	r4, r1 // y
	mov	r5, r2  //border width
	ldr	r6, [sp,#44] // overall width
	mov	r0, r6
	sub	r0, r5
	sub	r0, r5
	push {r0}
	ldr	r7, [sp,#40] //overall length
	sub	r0, r7, r5
	sub	r0, r5
	push {r0}
	ldr	r0, [sp,#36] //main rectangle colour
	push {r0}
	add	r0, r4, r5
	push {r0}
	add	r0, r3, r5
	push {r0}
	bl	drawRect	//draws center rectangle
	add	sp, #20
	push {r5, r6}
	ldr	r8, [sp,#32]     //border colour
	push {r8}
	push {r3,r4}
	bl	drawRect	//draws left portion of border
	add	sp, #20
	push {r5}
	push {r7,r8}
	push {r3,r4}
	bl	drawRect	//draws top portion of border
	add	sp, #20
	push {r6}
	push {r5}
	push {r8}
	push {r4}
	add	r0, r3, r7
	sub	r0, r5
	push {r0}
	bl	drawRect	// draws right portion of border
	add	sp, #20
	push {r5}
	push {r7}
	push {r8}
	add	r0, r4, r6
	sub	r0, r5
	push {r0}
	push {r3}
	bl	drawRect	// draws bottom portion of border
	add	sp, #20
	pop {r3-r10}
	bx	lr
	

drawBeeWings: //very boxy wings
	//r0 is x location
	//r1 is y location
	//r2 is size (square-ish)
	push {r3-r6}
	mov	r3, r0 //x
	mov	r4, r1 //y
	mov	r5, r2 //size
	ldr	r6, =beeWingColour
	ldr	r6, [r6] //colour
	push {r5}
	push {r5}
	push {r6}
	push {r4}
	push {r3}
	bl	drawRect //main wing
	add	sp, #20
	sub	r4,#1
	push {r6}
	mov	r0, #1
	push {r0}
	sub	r1,r2,#2
	push {r1}
	push {r0}
	add	r1,r3,#1
	sub	r0,r4,#1
	push {r0,r1}
	bl	drawLine  //hint of wing-curve
	add	sp, #24
	pop {r3-r6}
	bx	lr
	
drawBeeEye:
	bx	lr
	

drawBeeP: //draws pawn bee (top left)
	// r0 is the x location
	// r1 is the y location
	// make wingLength int in memory (TODO)
	push {r3-r10}
	mov	r2, #0
	ldr	r3, =beeYellowColour
	ldr	r3, [r3]
	push {r3}
	mov	r4, r0 //top-left x
	mov	r5, r1 // top-left y
	bl	drawBeeBody //draw bee body
	add	sp, #4
	mov	r6, r4
	add	r6, #90 //add in bee body width (will probably need to be changed later) POTENTIAL DISEMBODIED WING ERROR
	sub	r6, #5 //breathing room
	ldr	r7, =wingLength
	ldr	r7, [r7]
	sub	r6, r7
	mov	r0, r6
	mov	r1, r5
	add	r1, #15 //more natural looking wings
	mov	r2, r7
	bl	drawBeeWings
	//now both body and wings are drawn
	pop {r3-r10}
	bx	lr

drawBeeK: //draws knight bee
	bx	lr

drawBeeQ: //draws queen bee
	bx	lr

drawPlayer: //draws player at location (x,y) that is the leftmost portion of their helmet
	//r0 is x location
	//r1 is y location
	push {r3-r7}
	mov	r3, r0
	mov	r4, r1
	ldr	r5, =playerSize
	ldr	r5, [r5]
	ldr	r6, =playerHelmColour
	ldr	r6, [r6]
	push {r5}
	push {r5}
	push {r6}
	push {r4}
	push {r3}
	bl	drawRect //draws head
	add	sp, #20
	ldr	r6, =playerBodyColour
	ldr	r6, [r6]
	mov	r7, r5
	add	r7, r5
	add	r7, r5 //r7 = 3*r5
	sub	r0, r3, r5
	add	r1, r4, r5
	push {r5}
	push {r7}
	push {r6}
	push {r1}
	push {r0}
	bl	drawRect	//draw body
	add	sp, #20
	add	r0, r4, r5
	add	r0, r5
	push {r5}
	push {r5}
	push {r6}
	push {r0}
	push {r3}
	bl	drawRect	//draw feet things
	add	sp, #20
	add	r0, r4, r5
	add	r0, r5
	lsr	r1, r5, #1     // logical shift right
	add	r1, r3
	ldr	r6, =beeBlackColour
	ldr	r6, [r6]
	mov	r2, #2
	push {r6}
	push {r2}
	push {r5}
	push {r2}
	push {r0}
	push {r1}
	bl	drawLine    //calls drawLine
	add	sp, #24
	pop {r3-r7}
	bx	lr

drawBush: //draws "bush" cover
	//r0 is the x location
	//r1 is the y location
	//r2 is the size of the bush (bush is square)
	push {r3}
	ldr	r3, =bushColour
	ldr	r3, [r3]
	push {r2}
	push {r2}
	push {r3}
	push {r1}
	push {r0}
	bl	drawRect
	add	sp, #20
	pop {r3}
	bx	lr

drawLazer: //draws player lazer projectile
	// r0 is x location
	// r1 is y location
	// (x,y) is the top left-most location
	// returns memory location of lazerSize
	push {r3-r8}
	mov	r3, r0 //x location (xMin)
	mov	r4, r1 // y location (yMin)
	ldr	r5, =lazerSize
	mov	r8, r5
	ldr	r6, [r5] //length
	ldr	r5, [r5,#4] //width
	ldr	r7, =lazerColour
	ldr	r7, [r7]
	push {r5}
	push {r6}
	push {r7}
	push {r4}
	push {r3}
	bl	drawRect
	mov	r0, r8
	pop {r3-r7}
	bx	lr


drawBeeSting: //draws bee bullet projectile
	//r2 is bee sting direction
	//r0 is x location
	//r1 is y location
	// 0 is up
	// 1 is down
	// 2 is left
	// 3 is right
	push   {r3-r4}
	mov 	r4, r2
	ldr	r2, =beeStingSize
	ldr	r2, [r2]
	ldr	r3, =beeStingColour
	ldr	r3, [r3]
	push    {r3}
	cmp	r4, #0
	bne	bdsif2
	bl	drawTriangleUp
	bdsif2:
	cmp	r4, #1
	bne	bdsif3
	bl	drawTriangleDown
	bdsif3:
	cmp	r4, #2
	bne	bdselse
	bl	drawTriangleLeft
	bdselse:
	bl	drawTriangleRight
	add	sp, #4
	pop   {r3-r4}
	bx	lr

drawCursor: //draws triangle cursor for use on pause menu always faces right
	// r0 is x location
	// r1 is y location
	// (x,y) is the rightmost point
	push {r3-r6}
	mov	r3, r0
	mov	r4, r1
	ldr	r5, =cursorSize
	ldr	r5, [r5]
	ldr	r6, =cursorColour
	ldr	r6, [r6]
	mov	r0, r3
	mov	r1, r4
	mov	r2, r5
	push {r6}
	bl	drawTriangleRight
	add	sp, #4 //removes colour from stack
	pop {r3-r6}
	bx	lr

drawPauseScreen:
	\\r0 will indicate which option is selected
	bx	lr

drawGameOverScreen:
	bx	lr

refreshGameScreen:
	\\r0 will be the memory address for all toDraws
	bx	lr


.section .data

beeBlackColour: .word	0x000000
beeRedColour:	.word
beeYellowColour: .word
beeStingColour:	.word	
beeWingColour:	.word	
bushColour:	.word
cursorColour:	.word
lazerColour:	.word
playerBodyColour: .word
playerHelmColour: .word
beeStingSize:  .int   6
playerSize:	.int	
cursorSize:	.int	10 //triangle height
lazerSize:     .int   50, 1 //rectangle length by width
font:	.incbin		"font.bin"
