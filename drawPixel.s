//include(frameBuffer) should have a line to include/reference the frameBuffer initialization file

.section .init
.globl drawPixel
.globl drawRect
.globl drawLine
.globl drawTriangleUp
.globl drawTriangleDown
.globl drawTriangleLeft
.globl drawTriangleRight

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
	
	mul    r0,    #1024                  //row-major
	add    r0,    r1                     //
	lsl    r0,    #3                     //8-bit colour assumed
	ldr    r1,    =frameBufferPointer    // should get frameBuffer location from file that contains frameBuffer information
	ldr    r1,    [r1]                   //
	add    r1,    r0                     // add offset
	strh   r2,   [r1]                    //
	
endDrawPixel:
	bx     lr                            //

drawBG: //r0 is the colour to set the background to
	push{r3-r5}
	mov	r5, r0 //colour
	mov	r3, #0 //row number
	rowBGloops:
	cmp	r3, #1024
	bge	rowBGloope
	mov	r4, #0 //column number
	colBGloops:
	cmp	r4, #768
	bge	colBGloope
	mov	r0, r3	//set x to draw
	mov	r1, r4 //set y to draw
	mov	r2, r5 //set colour to draw
	bl	drawPixel
	add	r4, #1
	b	colBGloops
	colBGloope:
	add	r3, #1
	b	rowBGloops
	rowBGloope:
	pop{r3-r5}
	bx	lr
	
drawRect: // in order on stack: {x,y,colour,lenX,lenY}
	push{r3,r4,r5,r6,r7,r8}
	ldr   r7, [sp,#24] //x
	ldr   r8, [sp,#28] //y
	ldr   r2, [sp,#32] //colour
	ldr   r3, [sp,#36] //lenX
	ldr   r4, [sp,#40] //lenY
	mov	  r5, #0 //i
	dRFL1s:
	cmp	  r5, r3
	bge	  dRFL1e
	mov   r6, #0 //j
	dRFL2s:
	cmp   r6, r4
	bge   dRFL2e
	add   r0, r7, r5
	add   r1, r8, r6
	bl     drawPixel
	add   r6, #1
	b     dRFL2s
	dRFL2e:
	add   r5, #1
	b     dRFL1s
	dRFL1e:
	pop{r3,r4,r5,r6,r7,r8}
	bx	lr
	
	
drawLine: //takes thickness as a parameter, vertical/horizontal/diagonalU/diagonalD as parameters
	push(r3-r10)
	ldr   r0, [sp,#40] // x
	ldr   r1, [sp,#44] // y
	ldr   r2, [sp,#60] // colour
	ldr   r3, [sp,#52] // length
	ldr   r4, [sp,#56] // thickness
	ldr   r5, [sp,#48] // direction
	sub   r6, r4, #1
	rsl   r6, #1 // a
	mov   r7, #0 // i
	mov   r8, r0 // x (constant)
	mov   r9, r1 // y (constant)
	dLFL1s:
	cmp   r7, r3
	bge   dLFL1e
	mov   r0, r8
	mov   r1, r9
	bl     drawPixel
	cmp   r4, #1
	ble   afterif1
	and   r0, r5, #2
	srl   r0, #1
	and   r1, r5, #4
	srl   r1, #2
	orr   r0, r1
	cmp   r0, #1
	bne   afterif1
	sub   r0, r8, r6
	mov   r1, r9
	mov   r10, #1
	push{r0,r1,r2,r6,r10}
	bl     drawRect
	pop{r0,r1,r2,r6,r10}
	mov    r0, r8
	push{r0,r1,r2,r6,r10}
	bl     drawRect
	pop{r0,r1,r2,r6,r10}
	afterif1:
	and   r0, r5, #1
	cmp   r0, #1
	bne   afterif2
	cmp	  r4, #1
	ble   afterif3
	push{r4}
	mov   r0, #1
	push{r0}
	push{r2}
	mov   r0,r8
	sub   r1,r9,r4
	push{r0,r1}
	bl     drawRect
	pop{r0,r1}
	pop{r0,r1}
	pop{r0}
	push{r4}
	mov   r0, #1
	push{r0}
	mov   r0, r8
	mov   r1, r9
	push{r0,r1,r2}
	bl     drawRect
	pop{r0,r1}
	pop{r0,r1}
	pop{r0}
	afterif3:
	add   r8, #1
	afterif2:
	tst  r5, #2
	bne  ifpart2
	add  r9, #1
	ifpart2:
	tst r5, #4
	bne  afterif4
	sub  r9, #1
	afterif4:
	add  r7, #1
	b    dLFL1s
	dLFL1e:	
	pop(r3-r9)
	bx	lr


drawTriangleUp: //r0 is x, r1 is y, r2 is height, colour is sent over stack
push{r3-r8}
mov	r3, r0 //x
mov	r4, r1 //y
mov	r5, r2 // height
ldr	r6, [sp,#24] //colour
mov	r7, #0 // i
dtufl1start: //draw triangle up for loop 1 start
cmp	r7, r5
bge	dtufl1end
push{r6} 	//push 6th paramter, colour onto stack
mov	r0, #1
push{r0} 	//push 5th parameter, thickness (1) onto stack
add	r0, r7, r7
add	r0, #1
push{r0}	//push 4th parameter, length (2i+1) onto stack
mov	r0, #1
push{r0}	//push 3rd parameter, direction (1)(horizontal) onto stack
add	r0, r4, r7
push{r0}	//push 2nd paramteter, (y+i) onto stack
sub	r0, r3, r7
push{r0}	//push 1st paramter, (x-i) onto stack
bl	drawLine
add	sp, #24
add	r7, #1
b	dtufl1start
dtufl1end:
pop{r3-r8}
bx	lr


drawTriangleDown:
push{r3-r7}
mov	r3, r0 //x
mov	r4, r1 //y
mov	r5, r2 // height
ldr	r6, [sp,#20] //colour
mov	r7, #0 // i
dtdfl1start: //draw triangle down for loop 1 start
cmp	r7, r5
bge	dtdfl1end
push{r6} 	//push 6th paramter, colour onto stack
mov	r0, #1
push{r0} 	//push 5th parameter, thickness (1) onto stack
add	r0, r7, r7
add	r0, #1
push{r0}	//push 4th parameter, length (2i+1) onto stack
mov	r0, #1
push{r0}	//push 3rd parameter, direction (1)(horizontal) onto stack
sub	r0, r4, r7
push{r0}	//push 2nd paramteter, (y-i) onto stack
sub	r0, r3, r7
push{r0}	//push 1st paramter, (x-i) onto stack
bl	drawLine
add	sp, #24
add	r7, #1
b	dtdfl1start
dtdfl1end:
pop{r3-r7}
bx	lr


drawTriangleLeft:
push{r3-r7}
mov	r3, r0 //x
mov	r4, r1 //y
mov	r5, r2 // height
ldr	r6, [sp,#20] //colour
mov	r7, #0 // i
dtlfl1start: //draw triangle left for loop 1 start
cmp	r7, r5
bge	dtlfl1end
push{r6} 	//push 6th paramter, colour onto stack
mov	r0, #1
push{r0} 	//push 5th parameter, thickness (1) onto stack
add	r0, r7, r7
add	r0, #1
push{r0}	//push 4th parameter, length (2i+1) onto stack
mov	r0, #2
push{r0}	//push 3rd parameter, direction (2)(vertical) onto stack
add	r0, r4, r7
push{r0}	//push 2nd paramteter, (y+i) onto stack
add	r0, r3, r7
push{r0}	//push 1st paramter, (x+i) onto stack
bl	drawLine
add	sp, #24
add	r7, #1
b	dtlfl1start
dtlfl1end:
pop{r3-r7}
bx	lr

drawTriangleRight:
push{r3-r7}
mov	r3, r0 //x
mov	r4, r1 //y
mov	r5, r2 // height
ldr	r6, [sp,#20] //colour
mov	r7, #0 // i
dtrfl1start: //draw triangle right for loop 1 start
cmp	r7, r5
bge	dtrfl1end
push{r6} 	//push 6th paramter, colour onto stack
mov	r0, #1
push{r0} 	//push 5th parameter, thickness (1) onto stack
add	r0, r7, r7
add	r0, #1
push{r0}	//push 4th parameter, length (2i+1) onto stack
mov	r0, #2
push{r0}	//push 3rd parameter, direction (2)(vertical) onto stack
add	r0, r4, r7
push{r0}	//push 2nd paramteter, (y+i) onto stack
sub	r0, r3, r7
push{r0}	//push 1st paramter, (x-i) onto stack
bl	drawLine
add	sp, #24
add	r7, #1
b	dtrfl1start
dtrfl1end:
pop{r3-r7}
bx	lr

drawDiamond:

drawSquare:

drawStripedCircle:

drawRectB: //rectangle with border

drawBG: //draw background colour

drawBee: //draw a bee with size and colour of yellow stripes being variables

drawBeeP: //draws pawn bee

drawBeeK: //draws knight bee

drawBeeQ: //draws queen bee

drawPlayer: //draws player

drawBush: //draws "bush" cover

drawLazer: //draws player lazer projectile

drawBeeSting: //draws bee bullet projectile

drawCursor: //draws cursor for use on pause menu
