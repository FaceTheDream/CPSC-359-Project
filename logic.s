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
	ldr r0, =obstaclexs
	mov r1, #128
	str r1, [r0]
	mov r1, #256
	str r1, [r0, #4]
	mov r1, #384
	str r1, [r0, #8]
	mov r1, #512
	str r1, [r0, #12]
	mov r1, #640
	str r1, [r0, #16]
	ldr r0, =obstacleys
	mov r1, #256
	str r1, [r0, #8]
	mov r1, #512
	str r1, [r0]
	str r1, [r0, #16]
	mov r1, #768
	str r1, [r0, #4]
	str r1, [r0, #12]
	ldr r0, =crntbullet
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
	
finaLoop:
	mov r0, #5
	mov r1, #0
	mov r2, #14
	
finaLoop2:
	cmp r1, r2
	beq finaLoop3
	ldr r3, =bulletfaces
	str r0, [r3, r1, lsl #2]
	add r1, r1, #1
	b finaLoop2
	
finaLoop3:
	//draw screen

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
	bleq playerShoot
	
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
	bleq npcShoot
	add r1, r1, #1
	b npcStuff
	
afterNpc:
	//detect collisions:
	//if bullet is overlapped by player, player is hit
	mov r4, #0
	mov r5, #14
	
movBulls:
	ldr r7, =crntbullet
	str r4, [r7]
	//make each bullet continue moving
	cmp r4, r5
	beq afterBulls
	ldr r0, =bulletfaces
	ldr r0, [r0, r4, lsl #2]
	cmp r0, #5
	bge skipBull
	ldr r1, =bulletxs
	ldr r1, [r1, r4, lsl #2]
	ldr r2, =bulletys
	ldr r2, [r2, r4, lsl #2]
	cmp r0, #0
	beq bullUp
	cmp r0, #1
	beq bullDown
	cmp r0, #2
	beq bullLeft
	cmp r0, #3
	beq bullRight
	add r4, r4, #1
	b movBulls
	
bullUp:
	ldr r0, =crntbullet
	ldr r0, [r0]
	ldr r2, =bulletys
	ldr r2, [r2, r0, lsl #2]
	sub r2, r2, #1
	str r2, [r2, r0, lsl #2]
	ldr r1, =bulletfaces
	ldr r3, [r1, r0, lsl #2]
	cmp r2, #0
	moveq r3, #5
	str r3, [r1, r0, lsl #2]

bullDown:
	ldr r0, =crntbullet
	ldr r0, [r0]
	ldr r2, =bulletys
	ldr r2, [r2, r0, lsl #2]
	add r2, r2, #1
	str r2, [r2, r0, lsl #2]
	ldr r1, =bulletfaces
	ldr r3, [r1, r0, lsl #2]
	cmp r2, #767
	moveq r3, #5
	str r3, [r1, r0, lsl #2]

bullLeft:
	ldr r0, =crntbullet
	ldr r0, [r0]
	ldr r2, =bulletxs
	ldr r2, [r2, r0, lsl #2]
	sub r2, r2, #1
	str r2, [r2, r0, lsl #2]
	ldr r1, =bulletfaces
	ldr r3, [r1, r0, lsl #2]
	cmp r2, #0
	moveq r3, #5
	str r3, [r1, r0, lsl #2]

bullRight:
	ldr r0, =crntbullet
	ldr r0, [r0]
	ldr r2, =bulletxs
	ldr r2, [r2, r0, lsl #2]
	add r2, r2, #1
	str r2, [r2, r0, lsl #2]
	ldr r1, =bulletfaces
	ldr r3, [r1, r0, lsl #2]
	cmp r2, #1023
	moveq r3, #5
	str r3, [r1, r0, lsl #2]
	
skipBull:
	add r4, r4, #1
	b movBulls
	
afterBulls:
	mov r4, #0	//bullet#
	mov r5, #14	//max bullets
	
colLoop:
	cmp r4, r5
	beq colLoop2
	ldr r0, =playerx
	ldr r0, [r0]
	ldr r1, =playery
	ldr r1, [r1]
	ldr r2, =bulletxs
	ldr r2, [r2, r4, lsl #2]
	ldr r3, =bulletys
	ldr r3, [r3, r4, lsl #2]
	cmp r0, r2
	beq colLoopY
	add r4, r4, #1
	b colLoop
	
colLoopY:
	cmp r1, r3
	beq scoreDown
	add r4, r4, #1
	b colLoop
	
scoreDown:
	ldr r6, =score
	ldr r6, [r6]
	sub r6, r6, #10
	cmp r6, #0
	ble gameOver
	add r4, r4, #1
	b colLoop
	
colLoop2:
	mov r4, #0	//bullet#
	mov r5, #0	//npc#
	mov r6, #14	//max bullets
	mov r7, #16	//max npcs
	
colLoop2x:
	cmp r4, r6
	beq colLoopNpc
	//if bullet is overlapped by npc, npc is hit
	ldr r0, =bulletxs
	ldr r0, [r0, r4, lsl #2]
	ldr r1, =npcxs
	ldr r1, [r1, r5, lsl #2]
	cmp r0, r1
	beq colLoop2y
	add r4, r4, #1
	b colLoop2x
	
colLoop2y:
	ldr r0, =bulletys
	ldr r0, [r0, r4, lsl #2]
	ldr r1, =npcys
	ldr r1, [r1, r5, lsl #2]
	cmp r0, r1
	beq npcHit
	add r4, r4, #1
	b colLoop2x

colLoopNpc:
	cmp r5, r7
	beq colLoop3
	mov r4, #0
	add r5, r5, #1
	b colLoop2x
	
npcHit:
	// r5 = npc#
	ldr r8, =npchp
	ldr r9, [r8, r5, lsl #2]
	cmp r9, #1
	beq npcDie
	b npcHit2
	
npcDie:
	ldr r11, =score
	ldr r10, [r11]
	add r10, r10, #5
	cmp r5, #10
	addge r10, r10, #5
	cmp r5, #15
	addge r10, r10, #90
	str r10, [r11]
	
npcHit2:
	sub r9, r9, #1
	str r9, [r8, r5, lsl #2]
	add r4, r4, #1
	b colLoop2x
	
colLoop3:
	mov r4, #0 //npc counter
	mov r5, #14 //npc max
	
vicLoop:
	ldr r6, =npchp
	ldr r6, [r6, r4, lsl #2]
	cmp r6, #0
	bne colLoop3s
	cmp r4, r5
	beq victory
	add r4, r4, #1
	b vicLoop
	
colLoop3s:
	mov r4, #0	//bullet#
	mov r5, #0	//obstacle#
	mov r6, #14	//max bullets
	mov r7, #4	//max obstacles
	
colLoop3x:
	cmp r4, r6
	beq colLoopObs
	//if bullet is overlapped by obstacle, obstacle is hit
	ldr r0, =bulletxs
	ldr r0, [r0, r4, lsl #2]
	ldr r1, =obstaclexs
	ldr r1, [r1, r5, lsl #2]
	cmp r0, r1
	beq colLoop3y
	add r4, r4, #1
	b colLoop3x
	
colLoop3y:
	ldr r0, =bulletys
	ldr r0, [r0, r4, lsl #2]
	ldr r1, =obstacleys
	ldr r1, [r1, r5, lsl #2]
	cmp r0, r1
	beq obsHit
	add r4, r4, #1
	b colLoop3x

colLoopObs:
	cmp r5, r7
	beq colEnd
	mov r4, #0
	add r5, r5, #1
	b colLoop3x
	
obsHit:
	// r5 = obstacle#
	ldr r8, =obstaclehp
	ldr r9, [r8, r5, lsl #2]
	sub r9, r9, #1
	str r9, [r8, r5, lsl #2]
	add r4, r4, #1
	b colLoop3x
	
colEnd:
	//DRAW SCREEN NOW
	b oneTurn
	
pauseMenu:
	//detect inputs
	//put start button value memory location in r2
	ldr r2, [r2]
	mov r1, #0
	cmp r1, r2
	beq endSub
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
	ldr r0, =playerface
	mov r1, #0
	str r1, [r0]
	ldr r0, =playery
	ldr r1, [r0]
	cmp r1, #0
	beq endSub
	sub r1, r1, #1
	str r1, [r0]
	bx lr
	
playerDown:
	ldr r0, =playerface
	mov r1, #1
	str r1, [r0]
	ldr r0, =playery
	ldr r1, [r0]
	cmp r1, #767
	beq endSub
	add r1, r1, #1
	str r1, [r0]
	bx lr
	
playerLeft:
	ldr r0, =playerface
	mov r1, #2
	str r1, [r0]
	ldr r0, =playerx
	ldr r1, [r0]
	cmp r1, #0
	beq endSub
	sub r1, r1, #1
	str r1, [r0]
	bx lr
	
playerRight:
	ldr r0, =playerface
	mov r1, #3
	str r1, [r0]
	ldr r0, =playerx
	ldr r1, [r0]
	cmp r1, #1023
	beq endSub
	add r1, r1, #1
	str r1, [r0]
	bx lr
	
playerShoot:
	ldr r0, =playerface
	ldr r0, [r0]
	ldr r1, =playerx
	ldr r1, [r1]
	ldr r2, =playery
	ldr r2, [r2]
	ldr r3, =crntbullet
	ldr r4, [r3]
	cmp r4, #14
	moveq r4, #0
	cmp r4, #14
	addlt r4, r4, #1
	str r4, [r3]
	ldr r3, =bulletfaces
	str r0, [r3, r4, lsl #2]
	ldr r3, =bulletxs
	str r1, [r3, r4, lsl #2]
	ldr r3, =bulletys
	str r2, [r3, r4, lsl #2]
	bx lr

npcUp:
	ldr r0, =currentnpcface
	mov r1, #0
	str r1, [r0]
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
	ldr r0, =currentnpcface
	mov r1, #1
	str r1, [r0]
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
	ldr r0, =currentnpcface
	mov r1, #2
	str r1, [r0]
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
	ldr r0, =currentnpcface
	mov r1, #3
	str r1, [r0]
	ldr r0, =currentnpc
	ldr r0, [r0]
	ldr r1, =npcxs
	ldr r2, [r1, r0, lsl #2]
	cmp r2, #1023
	beq endSub
	sub r2, r2, #1
	str r2, [r1, r0, lsl #2]
	bx lr
	
npcShoot:
	ldr r5, =currentnpc
	ldr r5, [r5]
	ldr r0, =currentnpcface
	ldr r0, [r0]
	ldr r1, =npcxs
	ldr r1, [r1, r5, lsl #2]
	ldr r2, =npcys
	ldr r2, [r2, r5, lsl #2]
	ldr r3, =crntbullet
	ldr r4, [r3]
	cmp r4, #14
	moveq r4, #0
	cmp r4, #14
	addlt r4, r4, #1
	str r4, [r3]
	ldr r3, =bulletfaces
	str r0, [r3, r4, lsl #2]
	ldr r3, =bulletxs
	str r1, [r3, r4, lsl #2]
	ldr r3, =bulletys
	str r2, [r3, r4, lsl #2]
	bx lr

gameOver:
	//display game over screen
	//detect inputs
	//put start button value memory location in r2
	ldr r2, [r2]
	mov r1, #0
	cmp r1, r2
	beq start
	b gameOver
	
victory:
	//display victory screen
	//detect inputs
	//put start button value memory location in r2
	ldr r2, [r2]
	mov r1, #0
	cmp r1, r2
	beq start
	b victory
	
endSub:
	bx lr
	
.section .data

.align 4
score:		.int	0
playerx:	.int	0
playery:	.int	0
playerface:	.int	0 //0 = up, 1 = down, 2 = left, 3 = right
currentnpc:	.int	0
currentnpcface:	.int	0 //0 = up, 1 = down, 2 = left, 3 = right
npcxs:		.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
npcys:		.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
npchp:		.int	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3
crntpause:	.int	0 //0 = resume game, 1 = restart game, 2 = quit game
bulletxs:	.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
bulletys:	.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
bulletfaces:	.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 //0 = up, 1 = down, 2 = left, 3 = right
crntbullet:	.int	0
obstaclexs:	.int	0, 0, 0, 0, 0
obstacleys:	.int	0, 0, 0, 0, 0
obstaclehp:	.int	0, 0, 0, 0, 0
