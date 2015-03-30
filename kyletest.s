.globl starTest

//don't change any uncommented lines

starTest:
	ldr r0, =0xFFFF			//background color: white
	push {r0}
	bl drawBG
	bl drawAuthorNames
	bl drawGameTitle
	pop {r0}
	
testPawn:
	ldr r0, =0x180			//x coordinate of pawn bee
	ldr r1, =0xa			//y coordinate of pawn bee
	push {r0, r1}
	bl drawBeeP
	pop {r0, r1}
	
testKnight:
	ldr r0, =0xa			//x coordinate of knight bee
	ldr r1, =0x200			//y coordinate of knight bee
	push {r0, r1}
	bl drawBeeK
	pop {r0, r1}
	
testQueen:
	ldr r0, =0x2f5			//x coordinate of queen bee
	ldr r1, =0x200			//y coordinate of queen bee
	push {r0, r1}
	bl drawBeeK
	pop {r0, r1}
	
testBush:
	ldr r0, =0x180			//x coordinate of bush
	ldr r1, =0x3f5			//y coordinate of bush
	ldr r2, #3				//size of bush
	push {r0, r1, r2}
	bl drawBush
	pop {r0, r1, r2}
	
testPlayer:
	ldr r0, =0x180			//x coordinate of player
	ldr r1, =0x200			//y coordinate of player
	push {r0, r1}
	bl drawPlayer
	pop {r0, r1}
	
testRect:
	ldr r0, =0xc0			//x coordinate of rectangle
	ldr r1, =0x100			//y coordinate of rectangle
	ldr r2, =0x0			//color of rectangle
	ldr r3, #5				//length of rectangle
	ldr r4, #5				//width of rectangle
	push {r0, r1, r2, r3, r4}
	bl drawRect
	pop {r0, r1}
	
	