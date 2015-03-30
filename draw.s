.section .init

.globl drawAuthorNames	//draws the names of the authors of the game (Kyle Buettner, David Kenny, Justin Chu)
.globl drawBeeBody 	//has 9 vertical stripes of equal size upon the body
			// base stripe size is currently 10 pixels
			// base bee height is currently 90 pixels
			// r0, top left x
			// r1, top left y
			// r2, size multiplier (will be included in a shift operation, ex: 2^r2)
			// [sp], non-black colour
.globl drawBeeK		//draws a knight bee at location (x,y)
			//(x,y) is the location at the top left of the body
			//r0 is the x location
			//r1 is the y location
.globl drawBeeP		//draws a pawn bee at location (x,y)
			//(x,y) is the location at the top left of the body
			//r0 is the x location
			//r1 is the y location
.globl drawBeeQ		//draws a queen bee at location (x,y)
			//(x,y) is the location at the top left of the body
			//r0 is the x location
			//r1 is the y location
.globl drawBeeSting	//draws the bee projectile
.globl drawBeeWings	//draws the wing portion of the bees
.globl drawBG		//fills in the entire screen with a colour
			//r0 is that colour
.globl drawBush		//draws the bush cover
.globl drawCursor 	//draws triangle cursor for use on pause menu always faces right
			// r0 is x location
			// r1 is y location
			// (x,y) is the rightmost point
.globl drawDiamond	//draws a diamond
.globl drawGameOverScreen //draws the game over screen, does not take any arguments
.globl drawGameTitle	//draws the title of the game
.globl drawLazer	//draws the player projectile
.globl drawLine		//draws a line
.globl drawPixel	// draws a pixel at location (x,y)
			// r0 is x
			// r1 is y
			// r2 is colour
.globl drawPlayer	//draws the player
.globl drawPauseScreen	//the pause screen (colours currently unselected)
			//r0 indicates 0 (Resume), 1 (Restart Game), or 2 (Quit)
.globl drawRect		//draws a rectangle when given the top left point (x,y) 
			// where the right/left sides have length lenY and the top/bottom sides have length lenX
			// in order on stack: {x,y,colour,lenX,lenY}
.globl drawRectB 	//rectangle with border
			// r0 is x location
			// r1 is y location
			// r2 is borderwidth
			// [sp] is bordercolour
			// [sp+4] is main rectangle colour
			// [sp+8] is length (x-dist)
			// [sp+12] is width (y-dist)
.globl drawTriangleUp	//draws an isosceles triangle pointing upwards
			// (x,y) is the topmost tip of the triangle
			//r0 is x, r1 is y, r2 is height, colour is sent over stack
.globl drawTriangleDown	//draws an isosceles triangle pointing downwards
			// (x,y) is the bottommost tip of the triangle
			//r0 is x, r1 is y, r2 is height, colour is sent over stack
.globl drawTriangleLeft	//draws an isosceles triangle pointing leftwards
			// (x,y) is the leftmost tip of the triangle
			//r0 is x, r1 is y, r2 is height, colour is sent over stack
.globl drawTriangleRight //draws an isosceles triangle pointing rightwards
			// (x,y) is the rightmost tip of the triangle
			//r0 is x, r1 is y, r2 is height, colour is sent over stack
.globl drawVictoryScreen //draws the victory screen. Doesn't take any arguments
.globl refreshGameScreen //draws the game screen. Takes the array of object locations as an argument in r0
.globl setBeeStingerSize //allows the game to change bee projectile size if necessary
.globl setLazerDirection //allows the game to change the direction the lazer is moving in if necessary
.globl setPlayerSize	// allows the game to change the player size if necessary

.section .text

drawPixel: //r0 is assumed to be the x location, r1 is assumed to be the y location, r2 is assumed to be the colour data
	
	push	{r3-r6}
	mov	r4, r0
	mov	r5, r1
	mov	r6, r2
	
	cmp    r4,    #1024                  //check max x
	bge    endDrawPixel                  // if x >= 1024, don't draw
	cmp    r4,    #0                      //check min x
	blt    endDrawPixel                  // if x < 0, don't draw
	cmp    r5,    #768                   //check max y
	bge    endDrawPixel                  // if y >= 768, don't draw
	cmp    r5,    #0                      //check min y
	blt    endDrawPixel                  // if y < 0, don't draw
	
    mov    r3,    #1024
	mul    r5,    r3                 //row-major r1 <- (y*1024)
	add    r4,    r5                     //r0 <- (y*1024) + x
	lsl    r4,    #1                     //16-bit colour assumed
	ldr    r5,    =FrameBufferPointer    // should get frameBuffer location from file that contains frameBuffer information
	ldr    r5,    [r5]
    add    r5,    r4                     // add offset
	strh   r6,    [r5]                   // stores the colour into the FrameBuffer location
endDrawPixel:				     // end of drawPixel
	pop	{r3-r6}
	bx     lr                            // branch to calling code

drawBG: //r0 is the colour to set the background to
	//if the colour is 1, then the inGameBGColour should be used
	push 	{r4-r6,lr}	      //push registers onto stack so as not to alter them
	cmp	r0, #1
	bne	usualBGDrawing
	ldr	r0, =inGameBGColour
	ldr	r0, [r0]
usualBGDrawing:
	mov	r6, r0 	      //colour
	mov	r4, #0        //initialize row number

rowBGloops:	      // loop through all the rows on the screen
	cmp	r4, #1024      //compare row number with 1024
	bge	rowBGloope    // end if row number >= 1024
	mov	r5, #0        //initialize column number

colBGloops:	      //loop through all the columns on the screen
	cmp	r5, #768      //compare column number with 768
	bge	colBGloope    //end if column number >= 768

	mov	r0, r4	      //set x to draw
	mov	r1, r5        //set y to draw
	mov	r2, r6        //set colour to draw
	bl	drawPixel     //draw current pixel

	add	r5, #1	      //increment column
	b	colBGloops    //back to start of column loop

colBGloope:	      // end of column loop
	add	r4, #1        // increment row
	b	rowBGloops    //back to start of row loop

rowBGloope:	      // end of row loop
	pop {r4-r6,pc}           //restore registers

	
drawRect: // in order on stack: {x,y,colour,lenX,lenY}
	push {r3,r4,r5,r6,r7,r8, lr} //save registers
	ldr   r7, [sp,#28] 	// x
	ldr   r8, [sp,#32] 	// y
	ldr   r2, [sp,#36] 	// colour
	ldr   r3, [sp,#40] 	// lenX
	ldr   r4, [sp,#44] 	// lenY
	mov   r5, #0       	// i=0
dRFL1s:				// draw rectangle for loop 1 start
	cmp	  r5, r3   	// compare i and lenX
	bge	  dRFL1e   	// if i>= lenX, the for loop ends
	mov   r6, #0     	// j=0
dRFL2s:				//draw rectangle for loop 2 start
	cmp   r6, r4       	// compares j with lenY
	bge   dRFL2e	   	// if j >= lenY, the loop ends
	add   r0, r7, r5	// stores x+i in r0
	add   r1, r8, r6  	// stores y+j in r1
	bl     drawPixel   	// calls drawPixel
	add   r6, #1       	// increments j
	b     dRFL2s       	// back to the start of column iterating loop
dRFL2e:				// draw rectangle for loop 2 end
	add   r5, #1       	// increments i
	b     dRFL1s       	// back to the start of row iterating loop
dRFL1e:				// draw rectangle for loop 1 end
	pop {r3,r4,r5,r6,r7,r8, pc} // restore register
	
	
drawLine: //takes thickness as a parameter, vertical/horizontal/diagonalU/diagonalD as parameters
	push  	{r3-r10, lr}     // save registers
	ldr   	r0, [sp,#36] // x
	ldr   	r1, [sp,#40] // y
	ldr   	r2, [sp,#60] // colour
	ldr   	r3, [sp,#52] // length
	ldr   	r4, [sp,#56] // thickness
	ldr   	r5, [sp,#48] // direction
	sub   	r6, r4, #1   // stores thickness - 1 into r6
	lsr   	r6, #1 	     // stores (thickness-1)/2 into r6 (a)
	mov   	r7, #0       // i
	mov   	r8, r0       // x (constant)
	mov   	r9, r1       // y (constant)
dLFL1s:
	cmp   	r7, r3       // compares i with length
	bge   	dLFL1e       // end loop if i >= length
	mov   	r0, r8       // store x in r0
	mov   	r1, r9       // store y in r1
	bl    	drawPixel    // draws pixel in (x,y) with colour r2
	cmp   	r4, #1       // compares thickness with 1
	ble   	afterif1     // if thickness <= 1, end loop
	and   	r0, r5, #2   // store direction & 0x0010 into r0
	lsr   	r0, #1       // store r0/2 into r0
	and   	r1, r5, #4   // store direction & 0x0100 into r1
	lsr   	r1, #2       // store r1/4 into r1
	orr   	r0, r1       // set the first bit to be one in r0 if it is so in either r0 , r1
	ldr   	r1, =0xFFFFFFFE
	bic   	r0, r1       // clears every bit in r0 excluding the first bit
	cmp   	r0, #1       // checks if either bit 1 or bit 2 of direction is 1
	bne   	afterif1     // if neither are 1, go to the else portion
	sub   	r0, r8, r6   // stores x - a in r0
	mov   	r1, r9       // stores y in r1
	mov   	r10, #1      // stores 1 in r10
	push 	{r0,r1,r2,r6,r10} // push required parameters onto the stack
	bl     	drawRect    	  // call drawRect
	pop 	{r0,r1,r2,r6,r10} // remove parameters from stack
	mov    	r0, r8      	  // store x in r0
	push 	{r0,r1,r2,r6,r10} // push required parameters onto the stack
	bl	drawRect     	  // call drawRect
	pop 	{r0,r1,r2,r6,r10} // remove parameters from stack
afterif1:          		  // after thickness for horizontal
	and   	r0, r5, #1    // 
	cmp   	r0, #1
	bne   	afterif2      // if (direction & 1) != 1, go to else 
	cmp	r4, #1
	ble   	afterif3      // if thickness <= 1, go to else
	push  	{r4}		//the following pushes are to send parameters to drawRect
	mov   	r0, #1
	push  	{r0}
	push  	{r2}
	mov   	r0,r8
	sub   	r1,r9,r4
	push  	{r0,r1}		// the previous pushes were to send parameters to drawRect
	bl     	drawRect	    //vertical above-line thickness
	pop  	{r0,r1}
	pop  	{r0,r1}
	pop   	{r0}
	push  	{r4}
	mov   	r0, #1
	push 	{r0}
	mov   	r0, r8
	mov   	r1, r9
	push 	{r0,r1,r2}
	bl     	drawRect	      //vertical below-line thickness
	pop 	{r0,r1}
	pop 	{r0,r1}
	pop 	{r0}
afterif3:             //after thickness for vertical line
	add   	r8, #1
afterif2:
	tst  	r5, #2
	bne  	ifpart2          // direction & 2 != 1
	add  	r9, #1	      // increment y
ifpart2:
	tst 	r5, #4
	bne  	afterif4        // direction & 4 != 1
	sub  	r9, #1          // decrement y
afterif4:
	add  	r7, #1
	b    	dLFL1s
dLFL1e:	
	pop 	{r3-r9, pc}           // restore registers


drawTriangleUp: //r0 is x, r1 is y, r2 is height, colour is sent over stack
	push	{r3-r8, lr}
	mov	r3, r0       //x
	mov	r4, r1       //y
	mov	r5, r2       // height
	ldr	r6, [sp,#24] //colour
	mov	r7, #0       // i
dtufl1start:         	     //draw triangle up for loop 1 start
	cmp	r7, r5       
	bge	dtufl1end   
	push	{r6} 	     //push 6th paramter, colour onto stack
	mov	r0, #1
	push	{r0} 	     //push 5th parameter, thickness (1) onto stack
	add	r0, r7, r7
	add	r0, #1
	push	{r0}	     //push 4th parameter, length (2i+1) onto stack
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
	pop    {r3-r8, pc}


drawTriangleDown: //r0 is x, r1 is y, r2 is height, colour is sent over stack
	push	{r3-r7, lr}
	mov	r3, r0 	//x
	mov	r4, r1 	//y
	mov	r5, r2 	// height
	ldr	r6, [sp,#20] //colour
	mov	r7, #0 	// i
dtdfl1start: 		//draw triangle down for loop 1 start
	cmp	r7, r5
	bge	dtdfl1end
	push 	{r6} 	//push 6th paramter, colour onto stack
	mov	r0, #1
	push	{r0} 	//push 5th parameter, thickness (1) onto stack
	add	r0, r7, r7
	add	r0, #1
	push 	{r0}	//push 4th parameter, length (2i+1) onto stack
	mov	r0, #1
	push 	{r0}	//push 3rd parameter, direction (1)(horizontal) onto stack
	sub	r0, r4, r7
	push 	{r0}	//push 2nd paramteter, (y-i) onto stack
	sub	r0, r3, r7
	push 	{r0}	//push 1st paramter, (x-i) onto stack
	bl	drawLine
	add	sp, #24
	add	r7, #1
	b	dtdfl1start
dtdfl1end:
	pop {r3-r7, pc}


drawTriangleLeft: //r0 is x, r1 is y, r2 is height, colour is sent over stack
	push 	{r3-r7, lr}
	mov	r3, r0 //x
	mov	r4, r1 //y
	mov	r5, r2 // height
	ldr	r6, [sp,#20] //colour
	mov	r7, #0 // i
dtlfl1start: //draw triangle left for loop 1 start
	cmp	r7, r5
	bge	dtlfl1end
	push 	{r6} 	//push 6th paramter, colour onto stack
	mov	r0, #1
	push 	{r0} 	//push 5th parameter, thickness (1) onto stack
	add	r0, r7, r7
	add	r0, #1
	push 	{r0}	//push 4th parameter, length (2i+1) onto stack
	mov	r0, #2
	push 	{r0}	//push 3rd parameter, direction (2)(vertical) onto stack
	add	r0, r4, r7
	push 	{r0}	//push 2nd paramteter, (y+i) onto stack
	add	r0, r3, r7
	push 	{r0}	//push 1st paramter, (x+i) onto stack
	bl	drawLine
	add	sp, #24
	add	r7, #1
	b	dtlfl1start
dtlfl1end:
	pop 	{r3-r7, pc}

drawTriangleRight: //r0 is x, r1 is y, r2 is height, colour is sent over stack
	push 	{r3-r7, lr}
	mov	r3, r0 //x
	mov	r4, r1 //y
	mov	r5, r2 // height
	ldr	r6, [sp,#20] //colour
	mov	r7, #0 // i
dtrfl1start: //draw triangle right for loop 1 start
	cmp	r7, r5
	bge	dtrfl1end
	push 	{r6} 	//push 6th paramter, colour onto stack
	mov	r0, #1
	push	{r0} 	//push 5th parameter, thickness (1) onto stack
	add	r0, r7, r7
	add	r0, #1
	push 	{r0}	//push 4th parameter, length (2i+1) onto stack
	mov	r0, #2
	push 	{r0}	//push 3rd parameter, direction (2)(vertical) onto stack
	add	r0, r4, r7
	push 	{r0}	//push 2nd paramteter, (y+i) onto stack
	sub	r0, r3, r7
	push 	{r0}	//push 1st paramter, (x-i) onto stack
	bl	drawLine
	add	sp, #24
	add	r7, #1
	b	dtrfl1start
dtrfl1end:
	pop 	{r3-r7, pc}

drawDiamond:
//r0 is x, r1 is y, r2 is height
//[sp] is colour
// (x,y) is the topmost point of the diamond
	push 	{r3-r6, lr}    	//save registers to restore after use
	mov	r3, r0 		// x
	mov	r4, r1  	// y
	lsr	r2, #1  	// divide height in half
	mov	r5, r2  	// height/2
	ldr	r6, [sp,#16] 	// colour
	push 	{r6}		//push colour onto the stack
	bl	drawTriangleUp 	//draw the top half of the diamond
	add	sp, #4  	//remove colour off the stack
	add	r4, r5  	//see next line's comment
	add	r4, r5  	//add the full height to the y coordinate
	mov	r0, r3  	//set x for drawing
	mov	r1, r4  	// set y for drawing
	mov	r2, r5  	// set height for drawing
	push 	{r6}		//push colour onto the stack
	bl	drawTriangleDown //draw the bottom half of the diamond
	add	sp, #4  	//remove colour off the stack
	pop 	{r3-r10, pc}	//restore registers

drawBeeBody:
// r0, top left x
// r1, top left y
// r2, size multiplier (will be included in a shift operation, ex: 2^r2)
// [sp], non-black colour
// nine-striped bees
	push 	{r3-r8, lr}	     // save registers
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
	push 	{r1}              //push p4
	push 	{r0}              //push p3
	tst	r5, #1
	bne	stipecolourelse
	push 	{r6}              //push p2
	b 	stripecolourafterif
stipecolourelse:
	push 	{r7}              //push p2
stripecolourafterif:
	push 	{r4}              //push p1
	push 	{r3}              //push p0
	bl	drawRect
	add	sp, #20       //remove parameters from stack
	add	r5, #1        //increment stripe counter
endStripBeeLoop:
	pop 	{r3-r8, pc}	      // restore registers

drawRectB: //rectangle with border
// r0 is x location
// r1 is y location
// r2 is borderwidth
// [sp] is bordercolour
// [sp+4] is main rectangle colour
// [sp+8] is length
// [sp+12] is width
	push 	{r3-r10, lr}
	mov	r3, r0 // x
	mov	r4, r1 // y
	mov	r5, r2  //border width
	ldr	r6, [sp,#44] // overall width
	mov	r0, r6
	sub	r0, r5
	sub	r0, r5
	push 	{r0}
	ldr	r7, [sp,#40] //overall length
	sub	r0, r7, r5
	sub	r0, r5
	push 	{r0}
	ldr	r0, [sp,#36] //main rectangle colour
	push 	{r0}
	add	r0, r4, r5
	push 	{r0}
	add	r0, r3, r5
	push 	{r0}
	bl	drawRect	//draws center rectangle
	add	sp, #20
	push 	{r5, r6}
	ldr	r8, [sp,#32]     //border colour
	push 	{r8}
	push 	{r3,r4}
	bl	drawRect	//draws left portion of border
	add	sp, #20
	push 	{r5}		// push last drawRect argument onto stack	
	push 	{r7,r8}		// push 3rd and 4th drawRect arguments onto stack
	push 	{r3,r4}		// push 1st and 2nd drawRect arguments onto stack
	bl	drawRect	//draws top portion of border
	add	sp, #20		// remove drawRect parameters off of stack
	push 	{r6}		
	push 	{r5}
	push 	{r8}
	push 	{r4}
	add	r0, r3, r7
	sub	r0, r5
	push 	{r0}
	bl	drawRect	// draws right portion of border
	add	sp, #20		// remove drawRect parameters from the stack
	push 	{r5}
	push 	{r7}
	push 	{r8}
	add	r0, r4, r6
	sub	r0, r5
	push 	{r0}
	push 	{r3}
	bl	drawRect	// draws bottom portion of border
	add	sp, #20		// remove drawRect parameters from the stack
	pop 	{r3-r10, pc}
	

drawBeeWings: //very boxy wings
//r0 is x location
//r1 is y location
//r2 is size (square-ish)
	push 	{r3-r6, lr}
	mov	r3, r0 		//x
	mov	r4, r1 		//y
	mov	r5, r2 		//size
	ldr	r6, =beeWingColour
	ldr	r6, [r6]	//colour
	push    {r5}
	push    {r5}
	push    {r6}
	push 	{r4}
	push 	{r3}
	bl	drawRect 	//main wing
	add	sp, #20		//remove drawRect parameters from the stack
	sub	r4,#1
	push 	{r6}
	mov	r0, #1
	push 	{r0}
	sub	r1,r2,#2
	push 	{r1}
	push 	{r0}
	add	r1,r3,#1
	sub	r0,r4,#1
	push 	{r0,r1}
	bl	drawLine  	//hint of wing-curve
	add	sp, #24		//remove drawLine parameters from the stack
	pop 	{r3-r6, pc}
	
drawBeeEye:
//r0 is x
//r1 is y
	push	{r4-r10, lr}	//make room for local registers
	sub	sp, #8 		//make room for two local variables on the stack
	mov	r4, #13		//default inner eye length
	mov	r5, #26		//default outer-eye length
	mov	r6, #20	 	//default inner-eye width
	mov	r7, #40 	//default outer-eye width
	mov	r8, #0		//default inner-eye colour
	ldr	r9, =0xFFFFFFF	//default outer-eye colour
	str	r0, [sp,#4]	//saves x as a local variable (sp+4)
	str	r1, [sp]	//saves y as a local variable (sp)
	push	{r5,r7}		//push lenX, lenY onto stack
	push	{r0,r1,r9}	//push x,y,colour onto stack
	bl	drawRect	//draws outer-eye
	add	sp, #20		//removes paramters of outer-eye off of the stack
	ldr	r0, [sp,#4]	//load x from local storage
	lsl	r7, #2		//divide outer length by 4
	add	r0, r7		//add (oLen/4) to x
	str	r0, [sp, #4]	//save the changes to x
	ldr	r1, [sp]	//load y from local storage
	lsl	r5, #2		//divide outer width by 4
	add	r1, r5		//add (oWid/4) to y
	str	r1, [sp]	//save changes to y
	ldr	r0, [sp, #4]	//load x from the stack
	ldr	r1, [sp]	//load y from the stack
	push	{r4,r6}		//push lenX, lenY onto the stack
	push	{r0,r1,r8}	//push x,y,colour onto the stack
	bl	drawRect	//draw the inner-eye (pupil)
	add	sp, #20		//remove parameters left on stack
	add	sp, #8		//remove local variables from the stack
	pop	{r4-r10, pc}	//restore original registers
	

drawBeeP: //draws pawn bee (top left)
// r0 is the x location
// r1 is the y location
/*	push 	{r3-r10, lr}
	mov	r2, #0
	ldr	r3, =beeYellowColour
	ldr	r3, [r3]
	push 	{r3}
	mov	r4, r0 		//top-left x
	mov	r5, r1 		// top-left y
	bl	drawBeeBody 	//draw bee body
	add	sp, #4
	mov	r6, r4
	add	r6, #90 	//add in bee body width (will probably need to be changed later)
	sub	r6, #5 		//breathing room
	ldr	r7, =wingLength
	ldr	r7, [r7]
	sub	r6, r7
	mov	r0, r6
	mov	r1, r5
	add	r1, #15 	//more natural looking wings
	mov	r2, r7		//store wingLength so it may be used by drawBeeWings
	bl	drawBeeWings	//call drawBeeWings
	add	r0, r4, #12	// make the drawing position for the bee's eye (x)
	add	r1, r5, #7	// make the drawing position for the bee's eye (y)
	bl	drawBeeEye	// draw the bee's eye
	//now both body and wings are drawn along with the eye
	pop 	{r3-r10, pc}	//restore registers
	*/
	push	{lr}
	mov	r2, #5
	mov	r3, #45
	push	{r3}
	push	{r3}
	ldr	r3, =0xFFED //yellow
	push	{r3}
	ldr	r3, =0xBDF7 //light gray
	push	{r3}
	bl	drawRectB
	add	sp, #16
	pop	{lr}

drawBeeK:
//draws knight bee (top left)
// r0 is the x location
// r1 is the y location
	push 	{r3-r10, lr}
	mov	r2, #1
	ldr	r3, =beeRedColour
	ldr	r3, [r3]
	push 	{r3}
	mov	r4, r0 		//top-left x
	mov	r5, r1 		// top-left y
	bl	drawBeeBody 	//draw bee body
	add	sp, #4
	mov	r6, r4
	add	r6, #180 	//add in bee body width (will probably need to be changed later)
	sub	r6, #10 	//breathing room
	ldr	r7, =wingLength
	ldr	r7, [r7]
	sub	r6, r7
	mov	r0, r6
	mov	r1, r5
	add	r1, #15 	//more natural looking wings
	mov	r2, r7		//store wingLength so it may be used by drawBeeWings
	bl	drawBeeWings	//call drawBeeWings
	add	r0, r4, #12	// make the drawing position for the bee's eye (x)
	add	r1, r5, #7	// make the drawing position for the bee's eye (y)
	bl	drawBeeEye	// draw the bee's eye
	//now both body and wings are drawn along with the eye
	pop 	{r3-r10, pc}	//restore registers

drawBeeQ: //draws queen bee (top left)
// r0 is the x location
// r1 is the y location
	push 	{r3-r10, lr}
	mov	r2, #1
	ldr	r3, =beeYellowColour
	ldr	r3, [r3]
	push 	{r3}
	mov	r4, r0 		//top-left x
	mov	r5, r1 		// top-left y
	bl	drawBeeBody	//draw bee body
	add	sp, #4
	mov	r0, r4
	mov	r1, r5
	bl	drawCrown	//draws the royal crown onto our royal queen bee
	mov	r6, r4
	add	r6, #180 	//add in bee body width (will probably need to be changed later)
	sub	r6, #10 	//breathing room
	ldr	r7, =wingLength
	ldr	r7, [r7]
	sub	r6, r7
	mov	r0, r6
	mov	r1, r5
	add	r1, #15 	//more natural looking wings
	mov	r2, r7		//store wingLength so it may be used by drawBeeWings
	bl	drawBeeWings	//call drawBeeWings
	add	r0, r4, #12	// make the drawing position for the bee's eye (x)
	add	r1, r5, #7	// make the drawing position for the bee's eye (y)
	bl	drawBeeEye	// draw the bee's eye
	//now both body and wings are drawn along with the eye
	pop 	{r3-r10, pc}	//restore registers

drawCrown:	//draws the crown that the queen bee shall wear
//r0 is the x at the top left of the crown's rectangular base
//r1 is the y at the top left of the crown's rectangular base
//crownColour is stored in the data section of this file
//height of base is 25 pixels
//length of base is 50 pixels
//height of triangles is 15 pixels
//total crown height is 25+15=40 pixels
	push	{r4-r10, lr}
	mov	r4, r0		//x
	mov	r5, r1		//y
	mov	r7, #15		//triangle height
	ldr	r6, =crownColour //colour address 
	ldr	r6, [r6]	//colour
	mov	r1, #25
	mov	r0, #50
	push	{r0,r1}
	push	{r4,r5,r6}
	bl	drawRect	//draw rectangular base of crown
	add	sp, #20
	add	r4, #12		//add roughly 1/4th of the base's length to x
	add	r5, r7		//add the triangle's height to y
	mov	r0, r4
	mov	r1, r5
	mov	r2, r7		//move height of triangle into r2
	push	{r6}
	bl	drawTriangleUp	//draws an upward pointing triangle
	add	sp, #4		//remove drawTriangle parameter from the stack
	add	r4, #13		//add roughly 1/4th of the base's length to x
	mov	r0, r4
	mov	r1, r5
	mov	r2, r7
	push	{r6}
	bl	drawTriangleUp	//draws an upward pointing triangle
	add	sp, #4		//remove drawTriangle parameter from the stack
	add	r4, #13		//add roughly 1/4th of the base's length to x
	mov	r0, r4
	mov	r1, r5
	mov	r2, r7
	push	{r6}
	bl	drawTriangleUp	//draws an upward pointing triangle
	add	sp, #4		//remove parameters from the stack
	pop	{r4-r10, pc}	//restore registers

.ltorg	//Fix to literal pool being too far

drawPlayer: //draws player at location (x,y) that is the leftmost portion of their helmet
//r0 is x location
//r1 is y location
	push {r3-r7, lr}
	mov	r3, r0
	mov	r4, r1
	ldr	r5, =playerSize
	ldr	r5, [r5]
	ldr	r6, =playerHelmColour
	ldr	r6, [r6]
	push 	{r5}
	push 	{r5}
	push 	{r6}
	push 	{r4}
	push 	{r3}
	bl	drawRect 	//draws head
	add	sp, #20
	ldr	r6, =playerBodyColour
	ldr	r6, [r6]
	mov	r7, r5
	add	r7, r5
	add	r7, r5 		//r7 = 3*r5
	sub	r0, r3, r5
	add	r1, r4, r5
	push 	{r5}
	push 	{r7}
	push 	{r6}
	push 	{r1}
	push 	{r0}
	bl	drawRect	//draw body
	add	sp, #20
	add	r0, r4, r5
	add	r0, r5
	push 	{r5}
	push 	{r5}
	push 	{r6}
	push 	{r0}
	push 	{r3}
	bl	drawRect	//draw feet things
	add	sp, #20
	add	r0, r4, r5
	add	r0, r5
	lsr	r1, r5, #1     	// logical shift right
	add	r1, r3
	ldr	r6, =beeBlackColour
	ldr	r6, [r6]
	mov	r2, #2
	push 	{r6}
	push 	{r2}
	push	{r5}
	push	{r2}
	push	{r0}
	push 	{r1}
	bl	drawLine    	//calls drawLine
	add	sp, #24
	pop 	{r3-r7, pc}

drawBush: //draws "bush" cover
//r0 is the x location
//r1 is the y location
//r2 is the size of the bush (bush is square)
	push	{lr}
	cmp	r2, #0
	ble	endOfDrawBush	//skips drawing the bush if size is less than or equal to 0
	push {r3}
	ldr	r3, =bushColour
	ldr	r3, [r3]
	push 	{r2}
	push 	{r2}
	push 	{r3}
	push 	{r1}
	push	{r0}
	bl	drawRect
	add	sp, #20		//remove drawRect parameters from stack
	pop {r3}		//restore registers
endOfDrawBush:
	pop	{pc}

drawLazer: //draws player lazer projectile
// r0 is x location
// r1 is y location
// (x,y) is the top left-most location
// returns memory location of lazerSize
	push 	{r3-r8,lr}
	mov	r3, r0 		// x location (xMin)
	mov	r4, r1 		// y location (yMin)
	ldr	r5, =lazerSize
	mov	r8, r5
	ldr	r6, [r5] 	//length
	ldr	r5, [r5,#4] 	//width
	ldr	r7, =lazerColour
	ldr	r7, [r7]
	push 	{r5}
	push 	{r6}
	push 	{r7}
	push 	{r4}
	push 	{r3}
	bl	drawRect
	mov	r0, r8
	pop 	{r3-r7, pc}		//restore registers


drawBeeSting: //draws bee bullet projectile
//r2 is bee sting direction
//r0 is x location
//r1 is y location
// 0 is up
// 1 is down
// 2 is left
// 3 is right
	push    {r3-r4, lr}
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
	pop   	{r3-r4, pc}			//restore registers

drawCursor: //draws triangle cursor for use on pause menu always faces right
// r0 is x location
// r1 is y location
// (x,y) is the rightmost point
	push 	{r3-r6, lr}			//save registers
	mov	r3, r0			//move x location to r3
	mov	r4, r1			//move y location to r4
	ldr	r5, =cursorSize		//load the memory address of cursorSize into r5
	ldr	r5, [r5]		//load the value of cursorSize into r5
	ldr	r6, =cursorColour	//load the memory address of cursorColour into r6
	ldr	r6, [r6]		//load the value of cursorColour into r6
	mov	r0, r3			//move the x location into r0
	mov	r1, r4			//move the y location into r1
	mov	r2, r5			//move the cursorSize (height) into r2
	push 	{r6}			//push the cursorColour onto the stack
	bl	drawTriangleRight	//draws the rightwards pointing triangle
	add	sp, #4 			//removes colour from stack
	pop 	{r3-r6, pc}			//restores registers

drawPauseScreen:
//r0 will indicate which option is selected
// 0 indicates Resume
// 1 indicates Restart Game
// 2 indicates Quit
	push	{r4-r10, lr}
	
	//pause menu will be drawn with top-left-most coordinates (100, 0)
	//768 pixels wide, 600 pixels long, border width of 30 pixels
	//a newline will be 20 pixels tall
	mov	r4, r0	//r4 is now the option selected
	
	mov	r0, #100	//x
	mov	r1, #0		//y
	mov	r2, #30
	mov	r5, #768
	push	{r5}
	mov	r5, #600
	push	{r5}
	ldr	r5, =pauseMenuMC
	ldr	r5, [r5]
	push	{r5}
	ldr	r5, =pauseMenuBC
	ldr	r5, [r5]
	push	{r5}
	bl	drawRectB
	add	sp, #16
	
	mov	r5, #20		//r5 is now the newline distance
	//start writing words at (150,50)
	mov	r6, #150	//x
	mov	r7, #50		//y
	ldr	r8, =0xFFFFFF	//white text for pause menu
	
	//starts with the word "Resume"
	add 	r0, r6, #0	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'R'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #10	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'e'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #20	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'s'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #30	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'u'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #40	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'m'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #50	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'e'	//draw character
	bl 	drawChar	//call to subroutine
	add	r7, r5		//adds the newline distance
	
	//Next is "Restart Game"
	add 	r0, r6, #0	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'R'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #20	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'e'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #30	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'s'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #40	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'t'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #50	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'a'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #60	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'r'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #70	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'t'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #90	//draw x skips one character slot for space
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'G'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #100	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'a'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #0	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'m'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #0	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'e'	//draw character
	bl 	drawChar	//call to subroutine
	add	r7, r5		//adds the newline distance
	
	//third word is "Quit"
	add 	r0, r6, #0	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'Q'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #10	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'u'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #20	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'i'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r0, r6, #30	//draw x
	mov 	r1, r7	        //draw y
	mov 	r3, r8		//draw colour
	mov 	r2, #'t'	//draw character
	bl 	drawChar	//call to subroutine
	
	mov	r6, #150 	//x
	
	cmp	r4, #0
	bne	ifPauseNotResume
	mov	r0, r6
	mov	r1, #60
	b	afterPauseIfs
ifPauseNotResume:
	cmp	r4, #1
	bne	ifPauseElse
	mov	r0, r6
	mov	r1, #80
	b	afterPauseIfs
ifPauseElse:
	mov	r0, r6
	mov	r1, #100
afterPauseIfs:
	pop	{r4-r10, pc}

drawGameOverScreen: //in the "loss" situation
// background colour will be initialized to losingColour
// "GAME OVER!" at ( 400 , 380)
	push	{lr}
	ldr	r0, =losingColour
	ldr	r0, [r0]
	bl	drawBG
	mov	r0, #400	//set first character x
	mov	r1, #380	//set first character y
	bl	drawGameOverWords
	pop	{pc}
	
drawVictoryScreen:
// background colour will be initialized to winningColour
// "VICTORY!" at (400, 380)
// "Congratulations!" at (370,400)
	push	{r4, lr}
	ldr	r0, =victoryBGColour
	ldr	r0, [r0]
	bl	drawBG
	ldr	r4, =victoryTextColour
	ldr	r4, [r4]
	mov 	r1, #400	//draw x
	mov 	r2, #380	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'V'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x19A	//draw x (410)
	mov 	r2, #380	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'I'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x1A4	//(420)
	//draw x
	mov 	r2, #380	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'C'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x1AE	//draw x (430)
	mov 	r2, #380	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'T'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x1B8	//draw x (44)
	mov 	r2, #380	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'O'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x1C2	//draw x (450)
	mov 	r2, #380	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'R'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x1CC	//draw x (460)
	mov 	r2, #380	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'Y'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x1D6	//draw x (470)
	mov 	r2, #380	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'!'	//draw character
	bl 	drawChar	//call to subroutine
	//"VICTORY!" drawn
	//commence drawing of "Congratulations!"
	ldr 	r1, =0x172	//draw x (370)
	ldr 	r2, =0x190	//draw y (400)
	mov 	r3, r4		//draw colour
	mov 	r0, #'C'	//draw character
	bl 	drawChar	//call to subroutine
	mov 	r1, #380	//draw x
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'o'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x186	//draw x (390)
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'n'	//draw character
	bl 	drawChar	//call to subroutine
	mov 	r1, #400	//draw x
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'g'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x19A	//draw x (410)
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'r'	//draw character
	bl 	drawChar	//call to subroutine
	mov 	r1, #420	//draw x
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'a'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x1AE	//draw x (430)
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'t'	//draw character
	bl 	drawChar	//call to subroutine
	mov 	r1, #440	//draw x
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'u'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x1C2	//draw x (450)
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'l'	//draw character
	bl 	drawChar	//call to subroutine
	mov 	r1, #460	//draw x
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'a'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x1D6	//draw x (470)
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'t'	//draw character
	bl 	drawChar	//call to subroutine
	mov 	r1, #480	//draw x
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'i'	//draw character
	bl 	drawChar	//call to subroutine
	ldr 	r1, =0x1EA	//draw x (490)
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'o'	//draw character
	bl 	drawChar	//call to subroutine
	mov 	r1, #500	//draw x
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'n'	//draw character
	bl 	drawChar	//call to subroutine
	ldr	r1, =0x1FE	//draw x (510)
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'s'	//draw character
	bl 	drawChar	//call to subroutine
	mov 	r1, #520	//draw x
	mov 	r2, #400	//draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'!'	//draw character
	bl 	drawChar	//call to subroutine
	pop	{r4, pc}		//restore registers

drawGameOverWords:
// should draw "GAME OVER!" at start location ( x=r0 , y=r1)
	push	{r4-r6, lr}
	mov	r4, r0
	mov	r5, r1
	ldr	r6, =losWordColour
	ldr	r6, [r6]
	add 	r1, r4, #0	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'G'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #10	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'A'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #20	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'M'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #30	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'E'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #50	//draw x (skips one position because of space)
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'O'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #60	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'V'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #70	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'E'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #80	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'R'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #90	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'!'	//draw character
	bl 	drawChar	//call to subroutine
	pop	{r4-r6, pc}		//restore registers

refreshGameScreen:
//expects r0 to be the address of score
//[r0+4] to be the address of playerx
//[r0+8] to be the address of playery
//[r0+12] to be the address of playerface
//[r0+16] to be the address of currentnpc
//[r0+20] to be the address of currentnpcface
//[r0+24] to be the address of npcxs (17)
//[r0+92] to be the address of npcys (17)
//[r0+160] to be the address of npchp (17)
//[r0+228] to be the address of crntpause
//[r0+232] to be the address of bulletxs (15)
//[r0+292] to be the address of bulletys (15)
//[r0+352] to be the address of bulletfaces (15)
//[r0+412] to be the address of crntbullet
//[r0+416] to be the address of obstaclexs (5)
//[r0+436] to be the address of obstacleys (5)
//[r0+456] to be the address of obstaclehp (5)
//[r0+474] to be the last element of obstaclehp
	
	bx	lr

setPlayerSize:
//r0 is the new size
	ldr	r1, =playerSize
	str	r0, [r1]
	bx	lr

setBeeStingerSize:
//r0 is the new "height"
	ldr	r1, =beeStingSize
	str	r1, [r0]
	bx	lr

setLazerDirection:
//r0 is direction
//0 is horizontal
//anything else is vertical
	mov	r1, #50		//hard-coded length of lazer
	mov	r2, #1		//hard-coded width of lazer
	cmp	r0, #0
	bne	makeLazerVertical
	ldr	r0, =lazerSize
	str	r1, [r0]
	str	r2, [r0,#4]
	b	endOfSetLazerDirection
makeLazerVertical:
	ldr	r0, =lazerSize
	str	r1, [r0,#4]
	str	r2, [r0]
endOfSetLazerDirection:
	bx	lr		//branch to calling code

drawAuthorNames: //draws the author names in the top right corner of the screen
		//takes no arguments
	push	{lr}
	ldr	r0, =0x37D	//(893)
	mov	r1, #15
	bl	drawKyleBuettner
	ldr	r0, =0x39B	// (923)
	mov	r1, #30
	bl	drawJustinChu
	ldr	r0, =0x391	// (913)
	mov	r1, #45
	bl	drawDavidKenny
	pop	{pc}

drawGameTitle: //Moon Bees
	//should draw on top left corver of the screen
	push	{r4-r6, lr}
	ldr	r4, =0x3A5	//933 into r4
	mov	r5, #0
	ldr	r6, =authorTextColour
	ldr	r6, [r6]
	add 	r1, r4, #0	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'M'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #10	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'o'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #20	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'o'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #30	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'n'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #50	//draw x, skips one due to space
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'B'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #60	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'e'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #70	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'e'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r4, #80	//draw x
	mov 	r2, r5	        //draw y
	mov 	r3, r6		//draw colour
	mov 	r0, #'s'	//draw character
	bl 	drawChar	//call to subroutine
	pop	{r4-r6, pc}		//restore registers
	
drawKyleBuettner:
//r0 is x location
//r1 is y location
//colour is authorTextColour in .data section
	push	{r4-r6, lr}
	ldr	r4, =authorTextColour
	ldr	r4, [r4]
	mov	r5, r0
	mov	r6, r1
	add 	r1, r5, #0	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'K'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #10	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'y'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #20	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'l'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #30	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'e'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #50	//draw x skip one due to space
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'B'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #60	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'u'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #70	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'e'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #80	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'t'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #90	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'t'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #100	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'n'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #110	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'e'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #120	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'r'	//draw character
	bl 	drawChar	//call to subroutine
	pop	{r4-r6, pc}

drawDavidKenny:
//r0 is x location
//r1 is y location
//colour is authorTextColour in .data section
	push	{r4-r6, lr}
	ldr	r4, =authorTextColour
	ldr	r4, [r4]
	mov	r5, r0
	mov	r6, r1
	add 	r1, r5, #0	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'D'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #10	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'a'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #20	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'v'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #30	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'i'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #40	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'d'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #60	//draw x, skips one due to space
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'K'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #70	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'e'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #80	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'n'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #90	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'n'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #100	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'y'	//draw character
	bl 	drawChar	//call to subroutine
	pop	{r4-r6, pc}

drawJustinChu:
//r0 is x location
//r1 is y location
//colour is authorTextColour in .data section
	push	{r4-r6, lr}
	ldr	r4, =authorTextColour
	ldr	r4, [r4]
	mov	r5, r0
	mov	r6, r1
	add 	r1, r5, #0	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'J'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #10	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'u'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #20	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'s'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #30	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'t'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #40	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'i'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #50	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'n'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #70	//draw x, skips one due to space
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'C'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #80	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'h'	//draw character
	bl 	drawChar	//call to subroutine
	add 	r1, r5, #90	//draw x
	mov 	r2, r6	        //draw y
	mov 	r3, r4		//draw colour
	mov 	r0, #'u'	//draw character
	bl 	drawChar	//call to subroutine
	pop	{r4-r6, pc}

.section .data
// Colour codes from http://wiibrew.org/wiki/U16_colors
authorTextColour: .word	0x0000	//black
beeBlackColour: .word	0x0000	//black
beeRedColour:	.word	0xF81F	//lightish red
beeYellowColour: .word	0xFFE0	//yellow
beeStingColour:	.word	0x79E0	//brown
beeWingColour:	.word	0xFFFF	//white
bushColour:	.word	0x7E0	//green
crownColour:	.word	0xF81F	//purple
cursorColour:	.word	0xFFFF	//white
lazerColour:	.word	0xF800	//red
losingColour:	.word	0x1F	//dark blue
losWordColour:	.word	0xF81F	//pink
inGameBGColour:	.word	0x7BEF	//gray
pauseMenuMC:	.word	0x0000	//black
pauseMenuBC:	.word	0x7FF	//cyan
playerBodyColour: .word	0x79E0	//brown
playerHelmColour: .word	0xFFFF	//white
victoryBGColour: .word	0x7E0	//green
victoryTextColour: .word 0x0000	//black
beeStingSize:  .int   6		//
playerSize:	.int	75	//
cursorSize:	.int	10 	//triangle height
lazerSize:     .int   50, 1 	//rectangle length by width
wingLength:	.int   25
font:	.incbin		"font.bin"
