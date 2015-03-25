//include(frameBuffer) should have a line to include/reference the frameBuffer initialization file

.section .init
.globl drawPixel
.globl drawRect

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
	b     drawPixel
	add   r6, #1
	b     dRFL2s
	dRFL2e:
	add   r5, #1
	b     dRFL1s
	dRFL1e:
	pop{r3,r4,r5,r6,r7,r8}
	bx	lr
	
	
drawLine: //takes thickness as a parameter, vertical/horizontal/diagonalU/diagonalD as parameters
	


drawCircle:

drawTriangle:

drawDiamond:

drawSquare:

drawStripedCircle:

drawCircleB: //bordered circle

drawArc:

drawHalfCircle:

drawRectB: //rectangle with border

drawBG: //draw background colour


drawFlower: //draw multiple circles in a flower-like shape

drawBee: //draw a bee with size and colour of yellow stripes being variables

drawBeeP: //draws pawn bee

drawBeeK: //draws knight bee

drawBeeQ: //draws queen bee

drawPlayer: //draws player

drawBush: //draws "bush" cover

drawLazer: //draws player lazer projectile

drawBeeSting: //draws bee bullet projectile

drawCursor: //draws cursor for use on pause menu

