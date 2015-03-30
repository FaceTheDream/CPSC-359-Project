.globl starTest

//don't change any uncommented lines

starTest:
	ldr r0, =0xFFFF			//background color: white
	push {r0}
	bl drawBG
	bl drawAuthorNames
	bl drawGameTitle
	pop {r0}
	

testRectB:
	mov r0, #100
	mov r1, #0
	mov r2, #30
	ldr r3, =0x0000
	ldr r4, =0x7FF
	mov r5, #768
	mov r6, #600
	push {r3, r4, r5, r6}
	bl drawRectB
	pop {r3, r4, r5, r6}
/*
testBee:
	ldr r0, =0x180
	ldr r1, =0xa
	mov r2, #5
	mov r3, #10
	ldr r4, =0xcc
	push {r0, r1, r2, r3, r4}
	bl drawBeeBody
	pop {r0, r1}
	

testPawn:		
//currently draws a yellow rectangle, a small vertical black line, and a long horizontal yellow line
//will not draw anything after drawn
	ldr r0, =0x180			//x coordinate of pawn bee
	ldr r1, =0xa			//y coordinate of pawn bee
	push {r0, r1}
	bl drawBeeP
	pop {r0, r1}

	
testKnight:		
//currently draws a yellow rectangle to the right and down of where it should be, a thicker black vertical line, and a long horizontal green line
//will not draw anything after drawn
	ldr r0, =0xa			//x coordinate of knight bee
	ldr r1, =0x200			//y coordinate of knight bee
	push {r0, r1}
	bl drawBeeK
	pop {r0, r1}

	
testQueen:		
//currently draws a yellow rectangle down of where it should be, and a thick black vertical line
//will not draw anything after drawn
	ldr r0, =0x2f5			//x coordinate of queen bee
	ldr r1, =0x200			//y coordinate of queen bee
	push {r0, r1}
	bl drawBeeQ
	pop {r0, r1}
	

testBush:		//needs to take the size inputted and multiply it to make a recognizable size
	ldr r0, =0x20			//x coordinate of bush
	ldr r1, =0x20			//y coordinate of bush
	mov r2, #20				//size of bush
	push {r0, r1, r2}
	bl drawBush
	pop {r0, r1, r2}

	
testPlayer:		//draws player slightly left and very down of where it should be
			//will not draw anything after being drawn
	ldr r0, =0x180			//x coordinate of player
	ldr r1, =0x200			//y coordinate of player
	push {r0, r1}
	bl drawPlayer
	pop {r0, r1}
	

testRect:
	ldr r0, =0xc0			//x coordinate of rectangle
	ldr r1, =0x100			//y coordinate of rectangle
	ldr r2, =0x0			//color of rectangle
	mov r3, #20				//length of rectangle
	mov r4, #40				//width of rectangle
	push {r0, r1, r2, r3, r4}
	bl drawRect
	pop {r0-r4}
	

testLazer:
	ldr r0, =0x240			//x coordinate of lazer
	ldr r1, =0x100			//y coordinate of lazer
	push {r0, r1}
	bl drawLazer
	pop {r0, r1}
	

testStinger:
	ldr r0, =0xc0			//x coordinate of stinger
	ldr r1, =0x300			//y coordinate of stinger
	push {r0, r1}
	bl drawBeeSting
	pop {r0, r1}
	

testPause:
	mov r0, #0				//currently selected pause option
	push {r0}
	bl drawPauseScreen
	pop {r0}
	

testGO:
	bl drawGameOverScreen
	
testVictory:
	bl drawVictoryScreen
	*/

