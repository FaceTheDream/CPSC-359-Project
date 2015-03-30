.section .text

start:	//start up the game
	ldr r0, =score	//set score to 0
	mov r1, #0
	str r1, [r0]
	ldr r0, =playerx	//move player to middle of screen
	ldr r1, =0x17E		//382
	str r1, [r0]
	ldr r0, =playery
	mov r1, #512
	str r1, [r0]
	mov r1, #1
	mov r2, #2
	mov r3, #3
	ldr r0, =npchp	//set each npc's hp
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
	ldr r0, =crntpause	//reset pause cursor
	mov r1, #0
	str r1, [r0]
	ldr r0, =obstaclexs	//set each obstacle's position
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
	ldr r0, =obstaclehp	//set each obstacle's hp
	mov r1, #3
	str r1, [r0]
	str r1, [r0, #4]
	str r1, [r0, #8]
	str r1, [r0, #12]
	str r1, [r0, #16]
	ldr r0, =crntbullet	//reset bullet counter
	mov r1, #0
	str r1, [r0]
	ldr r0, =npcys		//set each npc's y position
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
	ldr r0, =npcxs		//set each npc's x position
	mov r1, #512
	mov r2, #0
	mov r3, #16
	
nextLoop:
	cmp r2, r3
	beq finaLoop
	str r1, [r0, r2, lsl #2]
	add r2, r2, #1
	b nextLoop
	
finaLoop:
	mov r0, #5		//set each bullet to inactive
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
	bl drawScreen

oneTurn:
	bl readSNES		//detect inputs
	ldr r3, =0x8		//1000 = start button
	tst r0, r3
	beq oneTurn2
	b pauseMenu
	
oneTurn2:
	ldr r3, =0x10		// 10000 = up button
	tst r0, r3
	beq oneTurn3
	bl playerUp
	
oneTurn3:
	ldr r3, =0x20		// 100000 = down button
	tst r0, r3
	beq oneTurn4
	bl playerDown
	
oneTurn4:
	ldr r3, =0x40		// 1000000 = left button
	tst r0, r3
	beq oneTurn5
	bl playerLeft
	
oneTurn5:
	ldr r3, =0x80		// 10000000 = right button
	tst r0, r3
	beq oneTurn5
	bl playerRight
	
oneTurn6:
	ldr r3, =0x100		// 100000000 = 'a' button
	tst r0, r3
	beq oneTurn7
	bl playerShoot
	
oneTurn7:
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
	ldr r3, =0x10DCD	//69069
	ldr r2, =0x20003004	//clock address
	ldr r2, [r2]		//current clock value
	mul r2, r3, r2
	add r2, r3, r2
modLoop:
	sub r2, r2, #4		//r2 mod 4
	cmp r2, #0
	blt modLoopE
	b modLoop
	
modLoopE:
	add r2, r2, #4
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
	ldr r2, =0x20003004
	ldr r2, [r2]		//current clock value
	mul r2, r3, r2
	add r2, r3, r2
	
modLoop2:
	sub r2, r2, #10		//r2 mod 10
	cmp r2, #0
	blt modLoop2E
	b modLoop2
	
modLoop2E:
	add r2, r2, #10
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
	ldr r4, =0x2FF		//767
	cmp r2, r4
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
	ldr r4, =0x3FF		//1023
	cmp r2, r4
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
	bl drawScreen
	b oneTurn
	
pauseMenu:
	bl drawPauseScreen
	bl readSNES
	ldr r3, =0x8 //1000 = start button
	tst r0, r3
	beq pauseMenu2
	b endSub
	
pauseMenu2:
	//put up button value memory location in r2
	//put down button value memory location in r3
	ldr r3, =0x10 //10000 = up button
	tst r0, r3
	bleq pauseUp
	
pauseMenu3:
	ldr r3, =0x20 //100000 = down button
	tst r0, r3
	bleq pauseDown
	//put 'a' button value memory location in r2
	ldr r3, =0x100 // 'a' button
	tst r0, r3
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
	ldr r4, =0x2FF		//767
	cmp r1, r4
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
	ldr r4, =0x3FF		//1023
	cmp r1, r4
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
	ldr r4, =0x2FF		//767
	cmp r2, r4
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
	ldr r4, =0x3FF		//1023
	cmp r2, r4
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
	
drawScreen:
	mov r0, #1
	bl drawBG
	bl drawAuthorNames
	bl drawGameTitle
	ldr r2, =npcxs
	ldr r3, =npcys
	ldr r4, =npchp
	ldr r0, [r2]
	ldr r1, [r3]
	ldr r5, [r4]
	cmp r5, #0
	blne drawBeeP
	ldr r0, [r2, #4]
	ldr r1, [r3, #4]
	ldr r5, [r4, #4]
	cmp r5, #0
	blne DrawBeeP
	ldr r0, [r2, #8]
	ldr r1, [r3, #8]
	ldr r5, [r4, #8]
	cmp r5, #0
	blne DrawBeeP
	ldr r0, [r2, #12]
	ldr r1, [r3, #12]
	ldr r5, [r4, #12]
	cmp r5, #0
	blne DrawBeeP
	ldr r0, [r2, #16]
	ldr r1, [r3, #16]
	ldr r5, [r4, #16]
	cmp r5, #0
	blne DrawBeeP
	ldr r0, [r2, #20]
	ldr r1, [r3, #20]
	ldr r5, [r4, #20]
	cmp r5, #0
	blne DrawBeeP
	ldr r0, [r2, #24]
	ldr r1, [r3, #24]
	ldr r5, [r4, #24]
	cmp r5, #0
	blne DrawBeeP
	ldr r0, [r2, #28]
	ldr r1, [r3, #28]
	ldr r5, [r4, #28]
	cmp r5, #0
	blne DrawBeeP
	ldr r0, [r2, #32]
	ldr r1, [r3, #32]
	ldr r5, [r4, #32]
	cmp r5, #0
	blne DrawBeeP
	ldr r0, [r2, #36]
	ldr r1, [r3, #36]
	ldr r5, [r4, #36]
	cmp r5, #0
	blne DrawBeeP
	ldr r0, [r2, #40]
	ldr r1, [r3, #40]
	ldr r5, [r4, #40]
	cmp r5, #0
	blne DrawBeeK
	ldr r0, [r2, #44]
	ldr r1, [r3, #44]
	ldr r5, [r4, #44]
	cmp r5, #0
	blne DrawBeeK
	ldr r0, [r2, #48]
	ldr r1, [r3, #48]
	ldr r5, [r4, #48]
	cmp r5, #0
	blne DrawBeeK
	ldr r0, [r2, #52]
	ldr r1, [r3, #52]
	ldr r5, [r4, #52]
	cmp r5, #0
	blne DrawBeeK
	ldr r0, [r2, #56]
	ldr r1, [r3, #56]
	ldr r5, [r4, #56]
	cmp r5, #0
	blne DrawBeeK
	ldr r0, [r2, #60]
	ldr r1, [r3, #60]
	ldr r5, [r4, #60]
	cmp r5, #0
	blne DrawBeeQ
	ldr r0, [r2, #64]
	ldr r1, [r3, #64]
	ldr r5, [r4, #64]
	cmp r5, #0
	blne DrawBeeQ
	ldr r3, =obstaclexs
	ldr r4, =obstacleys
	ldr r5, =obstaclehp
	ldr r0, [r3]
	ldr r1, [r4]
	ldr r2, [r5]
	bl drawBush
	ldr r0, [r3, #4]
	ldr r1, [r4, #4]
	ldr r2, [r5, #4]
	bl drawBush
	ldr r0, [r3, #8]
	ldr r1, [r4, #8]
	ldr r2, [r5, #8]
	bl drawBush
	ldr r0, [r3, #8]
	ldr r1, [r4, #8]
	ldr r2, [r5, #8]
	bl drawBush
	ldr r0, [r3, #8]
	ldr r1, [r4, #8]
	ldr r2, [r5, #8]
	bl drawBush
	ldr r2, =playerx
	ldr r3, =playery
	ldr r0, [r2]
	ldr r1, [r3]
	bl drawPlayer
	bx lr

gameOver:
	bl drawGameOverScreen
	bl readSNES
	ldr r3, =0x8 //1000 = start button
	tst r0, r3
	beq start
	b gameOver
	
victory:
	bl drawVictoryScreen
	bl readSNES
	ldr r3, =0x8 //1000 = start button
	tst r0, r3
	beq start
	b victory
	
endSub:
	bx lr
	
.section .data

.align 4
score:		.int	0	//obvious
playerx:	.int	0	//player's x position
playery:	.int	0	//player's y position
playerface:	.int	0 	//direction player is facing 0 = up, 1 = down, 2 = left, 3 = right
currentnpc:	.int	0	//keep track of certain npc in loops
currentnpcface:	.int	0 	//direction current npc is facing 0 = up, 1 = down, 2 = left, 3 = right
npcxs:		.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	//each npc's x position
npcys:		.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	//each npc's y position
npchp:		.int	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3	//each npc's hp
crntpause:	.int	0 	//current pause cursor position 0 = resume game, 1 = restart game, 2 = quit game
bulletxs:	.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	//each bullet's x position
bulletys:	.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	//each bullet's y position
bulletfaces:	.int	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 	//direction each bullet is facing 0 = up, 1 = down, 2 = left, 3 = right 5 = inactive
crntbullet:	.int	0	//keep track of certain bullet in loops
obstaclexs:	.int	0, 0, 0, 0, 0	//each obstacle's x position
obstacleys:	.int	0, 0, 0, 0, 0	//each obstacle's y position
obstaclehp:	.int	0, 0, 0, 0, 0	//each obstacle's hp
