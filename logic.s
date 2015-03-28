.section .text

start:
	ldr r0, =score
	mov r1, #0
	str r1, [r0]
	ldr r0, =playerx
	mov r1, #382
	str r1, [r0]
	ldr r0, =playery
	mov r1, #512
	str r1, [r0]
	mov r1, #1
	mov r2, #2
	mov r3, #3
	ldr r0, =npchp
	str r1, [r0]
	str r1, [r0, #4]
	str r1, [r0, #8]
	str r1, [r0, #12]
	str r1, [r0, #16]
	str r1, [r0, #20]
	str r1, [r0, #24]
	str r1, [r0, #28]
	str r1, [r0, #32]
	str r1, [r0, #36]
	str r2, [r0, #40]
	str r2, [r0, #44]
	str r2, [r0, #48]
	str r2, [r0, #52]
	str r2, [r0, #56]
	str r3, [r0, #60]
	str r3, [r0, #64]
	ldr r0, =crntpause
	mov r1, #0
	str r1, [r0]
	ldr r0, =npcys
	mov r1, #0
	mov r2, #0
	mov r3, #16
startLoop:
	cmp r2, r3
	beq endLoop
	str r1, [r0, r2, lsl #2]
	add r2, r2, #1
	b startLoop
	
endLoop:
	mov r1, #512
	mov r2, #0
	mov r3, #16
	
nextLoop:
	cmp r2, r3
	beq oneTurn
	str r1, [r0, r2, lsl #2]
	add r2, r2, #1
	b nextLoop

oneTurn:
	//detect inputs
	//put start button value memory location in r2
	ldr r2, [r2]
	mov r1, #0
	cmp r1, r2
	beq pauseMenu
	//put up button value memory location in r2
	//put down button value memory location in r3
	//put left button value memory location in r4
	//put right button value memory location in r5
	ldr r2, [r2]
	ldr r3, [r3]
	ldr r4, [r4]
	ldr r5, [r5]
	cmp r1, r2
	bleq playerUp
	cmp r1, r3
	bleq playerDown
	cmp r1, r4
	bleq playerLeft
	cmp r1, r5
	bleq playerRight
	//put 'a' button value memory location in r2
	ldr r2, [r2]
	cmp r1, r2
	bleq //shoot bullet subroutine
	
	mov r1, #0	// current npc, add this offset*4 to get current npc's stats
	mov r0, #16
npcStuff:
	mov r4, #0
	cmp r1, r0
	bge afterNpc
	ldr r5, =npchp
	ldr r5, [r5, r1, lsl #2]	//r5 = current npc's hp
	cmp r5, #0			//skip update if hp = 0
	beq npcStuff
	//puts random number %4 in r2
	mov r3, #69069
	ldr r2, =x20003004
	ldr r2, [r2] //current clock value
	mul r2, r3, r2
	add r2, r3, r2
	mov r2, r2 MOD 4 //this might not work, refer to http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.kui0008a/a166_op_mod.htm
	ldr r6, =currentnpc
	str r1, [r6]
	cmp r2, #0
	bleq npcUp
	cmp r2, #1
	bleq npcDown
	cmp r2, #2
	bleq npcLeft
	cmp r2, #3
	bleq npcRight
	//puts random number %10 in r2
	ldr r2, =x20003004
	ldr r2, [r2] //current clock value
	mul r2, r3, r2
	add r2, r3, r2
	mov r2, r2 MOD 10 //this might not work
	cmp r2, #0
	bleq //shoot npc bullet subroutine
	add r1, r1, #1
	b npcStuff
	
afterNpc:
	//detect collisions:
	//if bullet is overlapped by player, player is hit
		//make a loop which compares location of each bullet's front pixel to each location of player's drawn shape
	//if bullet is overlapped by npc, npc is hit
	//if bullet is overlapped by obstacle, obstacle is hit
	//if player is hit, score - 10
	//if npc is hit, hp - 1
	//if npc hp = 0, kill npc and increase score
	//if npc is hit and hp != 0, shrink npc
	//if obstacle is hit, hp - 1
	//if obstacle hp = 0, kill obstacle
	//if obstacle is hit and hp != 0, shrink obstacle
	//draw screen subroutine
	b oneTurn
	
pauseMenu:
	//detect inputs
	//put start button value memory location in r2
	ldr r2, [r2]
	mov r1, #0
	cmp r1, r2
	b endSub
	//put up button value memory location in r2
	//put down button value memory location in r3
	ldr r2, [r2]
	ldr r3, [r3]
	cmp r2, #0
	bleq pauseUp
	cmp r3, #0
	bleq pauseDown
	//put 'a' button value memory location in r2
	ldr r2, [r2]
	cmp r2, #0
	beq pSelect
	b pauseMenu
	
pauseUp:
	ldr r0, =crntpause
	ldr r0, [r0]
	cmp r0, #1
	subeq r0, r0, #1
	cmp r0, #2
	subeq r0, r0, #1
	bx lr
	
pauseDown:
	ldr r0, =crntpause
	ldr r0, [r0]
	cmp r0, #0
	addeq r0, r0, #1
	cmp r0, #1
	addeq r0, r0, #1
	bx lr
	
pSelect:
	ldr r0, =crntpause
	ldr r0, [r0]
	cmp r0, #0
	beq endSub
	cmp r0, #1
	beq start
	//QUIT GAME HERE
	
playerUp:
	ldr r0, =playery
	ldr r1, [r0]
	cmp r1, #0
	beq endSub
	sub r1, r1, #1
	str r1, [r0]
	bx lr
	
playerDown:
	ldr r0, =playery
	ldr r1, [r0]
	cmp r1, #767
	beq endSub
	add r1, r1, #1
	str r1, [r0]
	bx lr
	
playerLeft:
	ldr r0, =playerx
	ldr r1, [r0]
	cmp r1, #0
	beq endSub
	sub r1, r1, #1
	str r1, [r0]
	bx lr
	
playerRight:
	ldr r0, =playerx
	ldr r1, [r0]
	cmp r1, #1023
	beq endSub
	add r1, r1, #1
	str r1, [r0]
	bx lr

npcUp:
	ldr r0, =currentnpc
	ldr r0, [r0]
	ldr r1, =npcys
	ldr r2, [r1, r0, lsl #2]
	cmp r2, #0
	beq endSub
	sub r2, r2, #1
	str r2, [r1, r0, lsl #2]
	bx lr
	
npcDown:
	ldr r0, =currentnpc
	ldr r0, [r0]
	ldr r1, =npcys
	ldr r2, [r1, r0, lsl #2]
	cmp r2, #767
	beq endSub
	add r2, r2, #1
	str r2, [r1, r0, lsl #2]
	bx lr
	
npcLeft:
	ldr r0, =currentnpc
	ldr r0, [r0]
	ldr r1, =npcxs
	ldr r2, [r1, r0, lsl #2]
	cmp r2, #0
	beq endSub
	sub r2, r2, #1
	str r2, [r1, r0, lsl #2]
	b endSub
	
npcRight:
	ldr r0, =currentnpc
	ldr r0, [r0]
	ldr r1, =npcxs
	ldr r2, [r1, r0, lsl #2]
	cmp r2, #1023
	beq endSub
	sub r2, r2, #1
	str r2, [r1, r0, lsl #2]
	bx lr

endSub:
	bx lr
	
.section .data

.align 4
score:		.int	0
playerx:	.int	0
playery:	.int	0
currentnpc:	.int	0
npcxs:		.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
npcys:		.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
npchp:		.int	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3
crntpause:	.int	0 //0 = resume game, 1 = restart game, 2 = quit game
