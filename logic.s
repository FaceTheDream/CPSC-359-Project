.globl start

.section .text

start:	//start up the game
	push {lr}
	ldr r0, =score	//set score to 0
	mov r1, #0
	str r1, [r0]
	ldr r0, =playerx	//move player to middle of screen
	ldr r1, =0x200		//512
	str r1, [r0]
	ldr r0, =playery
	ldr r1, =0x17E		//382
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
	mov r1, #170
	str r1, [r0]
	mov r1, #340
	str r1, [r0, #4]
	mov r1, #512
	str r1, [r0, #8]
	ldr r1, =0x2aa
	str r1, [r0, #12]
	ldr r1, =0x355
	str r1, [r0, #16]
	ldr r0, =obstacleys
	mov r1, #192
	str r1, [r0, #8]
	mov r1, #384
	str r1, [r0]
	str r1, [r0, #16]
	mov r1, #576
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

	ldr r0, =bulletxs	//set each npc's hp
	mov r1, #0
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

	ldr r0, =bulletys	//set each npc's hp
	ldr r1, =0x2ff
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

	ldr r0, =npcys		//set each npc's y position
	mov r1, #0		//input to store
	mov r2, #0		//npc counter
	mov r3, #17

startLoop:
	cmp r2, r3
	beq endLoop
	str r1, [r0, r2, lsl #2]
	add r2, r2, #1
	b startLoop
	
endLoop:
	ldr r0, =npcxs		//set each npc's x position
	mov r1, #512		//input to store
	mov r2, #0		//npc counter
	mov r3, #17
	
nextLoop:
	cmp r2, r3
	beq finaLoop
	str r1, [r0, r2, lsl #2]
	add r2, r2, #1
	b nextLoop
	
finaLoop:
	mov r0, #5		//set each bullet to inactive
	mov r1, #0
	mov r2, #15
	
finaLoop2:
	cmp r1, r2
	beq finaLoop3
	ldr r3, =bulletfaces
	str r0, [r3, r1, lsl #2]
	add r1, r1, #1
	b finaLoop2
	
finaLoop3:
	bl drawScreen	//draw the initial screen

oneTurn:
	bl readSNES		//detect inputs
	ldr r1, =crntinputs
	str r0, [r1]
	ldr r3, =0x8		//1000 = start button
	tst r0, r3
	bne oneTurn2
	b pauseMenu
	
oneTurn2:
	ldr r0, =crntinputs
	ldr r0, [r0]
	ldr r3, =0x10		// 10000 = up button
	tst r0, r3
	bne oneTurn3
	bl playerUp
	
oneTurn3:
	ldr r0, =crntinputs
	ldr r0, [r0]
	ldr r3, =0x20		// 100000 = down button
	tst r0, r3
	bne oneTurn4
	bl playerDown
	
oneTurn4:
	ldr r0, =crntinputs
	ldr r0, [r0]
	ldr r3, =0x40		// 1000000 = left button
	tst r0, r3
	bne oneTurn5
	bl playerLeft
	
oneTurn5:
	ldr r0, =crntinputs
	ldr r0, [r0]
	ldr r3, =0x80		// 10000000 = right button
	tst r0, r3
	bne oneTurn6
	bl playerRight
	
oneTurn6:
	ldr r0, =crntinputs
	ldr r0, [r0]
	ldr r3, =0x100		// 100000000 = 'a' button
	tst r0, r3
	bne oneTurn7
	bl playerShoot
	
oneTurn7:
	mov r1, #0	// current npc, add this offset*4 to get current npc's stats
	ldr r0, =currentnpc
	str r1, [r0]
npcStuff:
	mov r0, #17
	mov r4, #0
	cmp r1, r0
	bge afterNpc
	ldr r5, =npchp
	ldr r5, [r5, r1, lsl #2]	//r5 = current npc's hp
	cmp r5, #0					//skip update if hp = 0
	ble modLoop3
	//puts random number %4 in r2
	ldr r3, =0x5				//5
	ldr r2, =0x20003004			//clock address
	ldr r2, [r2]				//current clock value
	ldr r6, =0xFFFFFFFC
	bic r2, r6
	add r2, r3, r2				//clock*5+5
modLoop:				//r2 mod 4
	sub r2, r2, #4
	cmp r2, #0
	blt modLoopE
	b modLoop
	
modLoopE:
	add r2, r2, #4
	//ldr r6, =currentnpc				//find the npc to move
	//str r1, [r6]
	cmp r2, #0
	ldreq r3, =currentnpcface
	streq r2, [r3]
	bleq npcUp
	cmp r2, #1
	ldreq r3, =currentnpcface
	streq r2, [r3]
	bleq npcDown
	cmp r2, #2
	ldreq r3, =currentnpcface
	streq r2, [r3]
	bleq npcLeft
	cmp r2, #3
	ldreq r3, =currentnpcface
	streq r2, [r3]
	bleq npcRight
	//puts random number %10 in r2
	ldr r2, =0x20003004				//clock address
	ldr r2, [r2]					//current clock value
	ldr r6, =0xFFFFFFFC
	bic r2, r6
	add r2, r3, r2
	
/*modLoop2:				//r2 mod 10
	sub r2, r2, #10
	cmp r2, #0
	blt modLoop2E
	b modLoop2
	
modLoop2E:
	add r2, r2, #10*/
	mov r2, #0
	cmp r2, #0				//if the random number from 0-9 is 0, npc shoots a bullet
	//bleq npcShoot

modLoop3:
	ldr r2, =currentnpc
	ldr r1, [r2]
	add r1, r1, #1
	str r1, [r2]
	b npcStuff
	
afterNpc:
	//detect collisions:
	//if bullet position matches player position, player is hit
	mov r4, #0				//bullet counter
	mov r5, #15				//max bullets
	
movBulls:
	ldr r7, =crntbullet			//current bullet
	str r4, [r7]				//set current bullet, starts at 0
	//make each bullet continue moving
	cmp r4, r5					//if max bullets is reached, leave loop
	bge afterBulls
	ldr r0, =bulletfaces		//direction bullets face
	ldr r0, [r0, r4, lsl #2]
	cmp r0, #5
	bge skipBull
	ldr r1, =bulletxs			//each bullet's x position	
	ldr r1, [r1, r4, lsl #2]
	ldr r2, =bulletys			//each bullet's y position
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
	
bullUp:			//move current bullet up
	ldr r0, =crntbullet
	ldr r0, [r0]
	ldr r8, =bulletys
	ldr r2, [r8, r0, lsl #2]
	sub r2, r2, #1
	str r2, [r8, r0, lsl #2]
	ldr r1, =bulletfaces
	ldr r3, [r1, r0, lsl #2]
	cmp r2, #0
	moveq r3, #5
	str r3, [r1, r0, lsl #2]
	b skipBull

bullDown:		//move current bullet down
	ldr r0, =crntbullet
	ldr r0, [r0]
	ldr r8, =bulletys
	ldr r2, [r8, r0, lsl #2]
	add r2, r2, #15
	str r2, [r8, r0, lsl #2]
	ldr r1, =bulletfaces
	ldr r3, [r1, r0, lsl #2]
	ldr r4, =0x2FF		//767
	cmp r2, r4
	moveq r3, #5
	str r3, [r1, r0, lsl #2]
	b skipBull

bullLeft:		//move current bullet left
	ldr r0, =crntbullet
	ldr r0, [r0]
	ldr r8, =bulletxs
	ldr r2, [r8, r0, lsl #2]
	sub r2, r2, #15
	str r2, [r8, r0, lsl #2]
	ldr r1, =bulletfaces
	ldr r3, [r1, r0, lsl #2]
	cmp r2, #0
	moveq r3, #5
	str r3, [r1, r0, lsl #2]
	b skipBull

bullRight:			//move current bullet right
	ldr r0, =crntbullet
	ldr r0, [r0]
	ldr r8, =bulletxs
	ldr r2, [r8, r0, lsl #2]
	add r2, r2, #15
	str r2, [r8, r0, lsl #2]
	ldr r1, =bulletfaces
	ldr r3, [r1, r0, lsl #2]
	ldr r4, =0x3FF		//1023
	cmp r2, r4
	moveq r3, #5
	str r3, [r1, r0, lsl #2]
	b skipBull
	
skipBull:			//if bullet is inactive, do not move bullet
	ldr r4, =crntbullet
	ldr r4, [r4]
	ldr r0, =bulletxs
	ldr r0, [r0, r4, lsl #2]
	ldr r1, =bulletys
	ldr r1, [r1, r4, lsl #2]
	bl drawLazer
	add r4, r4, #1
	b movBulls
	
afterBulls:			//reset bullet counter
	mov r4, #0	//bullet#
	mov r5, #15	//max bullets
	
colLoop:			//start detecting collisions
	cmp r4, r5		//when last bullet is reached, leave loop
	beq colLoop2
	ldr r0, =playerx
	ldr r0, [r0]
	ldr r1, =playery
	ldr r1, [r1]
	ldr r2, =bulletxs
	ldr r2, [r2, r4, lsl #2]
	ldr r3, =bulletys
	ldr r3, [r3, r4, lsl #2]
	cmp r0, r2			//if player's x and bullet's x are the same, compare y values
	beq colLoopY
	add r4, r4, #1		//else, check next bullet
	b colLoop
	
colLoopY:			//check if player's y and bullet's y are the same
	cmp r1, r3
	beq scoreDown		//if so, decrease score
	add r4, r4, #1		//else, check next bullet
	b colLoop
	
scoreDown:
	ldr r7, =score
	ldr r6, [r7]
	sub r6, r6, #10		//decrease score by 10
	str r6, [r7]
	cmp r6, #0
	ble gameOver		//if score is 0, game over
	add r4, r4, #1		//else, check next bullet
	b colLoop
	
colLoop2:
	mov r4, #0	//bullet#
	mov r5, #0	//npc#
	mov r6, #15	//max bullets
	mov r7, #17	//max npcs
	
colLoop2x:				//check if any bullets have hit any npcs
	cmp r4, r6			//if last bullet is reached, leave loop
	beq colLoopNpc
	//if bullet is overlapped by npc, npc is hit
	ldr r0, =bulletxs
	ldr r0, [r0, r4, lsl #2]
	ldr r1, =npcxs
	ldr r1, [r1, r5, lsl #2]
	cmp r0, r1			//if npc's x and bullet's x match, check y values
	beq colLoop2y
	add r4, r4, #1		//else, check next bullet
	b colLoop2x
	
colLoop2y:
	ldr r0, =bulletys
	ldr r0, [r0, r4, lsl #2]
	ldr r1, =npcys
	ldr r1, [r1, r5, lsl #2]
	cmp r0, r1			//if npc's y and bullet's y match, the npc has been hit
	beq npcHit
	add r4, r4, #1		//else, check next bullet
	b colLoop2x

colLoopNpc:				//after checking all the bullets against one npc, check the next npc against all bullets
	cmp r5, r7			//if last npc has been checked, leave loop
	beq colLoop3
	mov r4, #0			//else, reset bullet counter, and
	add r5, r5, #1		//increase npc counter, and check the next npc
	b colLoop2x
	
npcHit:
	// r5 = npc#
	ldr r8, =npchp
	ldr r9, [r8, r5, lsl #2]
	cmp r9, #1			//if npc's hp was 1 when it was hit, it is now dead
	beq npcDie
	b npcHit2			//else, lower its hp
	
npcDie:
	ldr r11, =score
	ldr r10, [r11]			//get the current score value
	add r10, r10, #5		//increase score by 5 when any enemy is killed
	cmp r5, #10
	addge r10, r10, #5		//increase score by another 5 if they were a knight or queen
	cmp r5, #15
	addge r10, r10, #90		//increase score by another 90 if they were a queen
	str r10, [r11]			//store the score value back in memory
	
npcHit2:
	sub r9, r9, #1				//decrease npc's hp by 1
	str r9, [r8, r5, lsl #2]	//and store it back in memory
	add r4, r4, #1				//then check next bullet
	b colLoop2x
	
colLoop3:
	mov r4, #0	//npc counter
	mov r5, #17	//npc max
	
vicLoop:
	ldr r6, =npchp				//get array of npcs' hp values
	ldr r6, [r6, r4, lsl #2]
	cmp r6, #0					//if any npc has more than 1 hp, no victory
	bgt colLoop3s
	cmp r4, r5					//if last npc is reached and all have 0 hp, a winner is you
	beq victory
	add r4, r4, #1				//else, check next npc
	b vicLoop
	
colLoop3s:
	mov r4, #0	//bullet#
	mov r5, #0	//obstacle#
	mov r6, #15	//max bullets
	mov r7, #4	//max obstacles
	
colLoop3x:
	cmp r4, r6					//if bullet reaches last bullet, leave loop
	beq colLoopObs
	//if bullet is overlapped by obstacle, obstacle is hit
	ldr r0, =bulletxs
	ldr r0, [r0, r4, lsl #2]
	ldr r1, =obstaclexs
	ldr r1, [r1, r5, lsl #2]
	cmp r0, r1					//if bullet's x matches obstacle's x, check y values
	beq colLoop3y
	add r4, r4, #1				//else, check next bullet
	b colLoop3x
	
colLoop3y:
	ldr r0, =bulletys
	ldr r0, [r0, r4, lsl #2]
	ldr r1, =obstacleys
	ldr r1, [r1, r5, lsl #2]
	cmp r0, r1					//if bullet's y matches obstacle's y, obstacles is hit
	beq obsHit
	add r4, r4, #1				//else, check next bullet
	b colLoop3x

colLoopObs:
	cmp r5, r7			//if last obstacle is reached, leave loop
	beq colEnd
	mov r4, #0			//else, reset bullet counter, and
	add r5, r5, #1		//increase obstacle counter
	b colLoop3x
	
obsHit:
	// r5 = obstacle#
	ldr r8, =obstaclehp
	ldr r9, [r8, r5, lsl #2]
	sub r9, r9, #1				//decrease obstacle's hp
	str r9, [r8, r5, lsl #2]
	add r4, r4, #1				//check next bullet
	b colLoop3x
	
colEnd:
	bl drawScreen		//draw screen for this turn
	b oneTurn			//start next turn
	
pauseMenu:
	ldr r0, =crntpause
	ldr r0, [r0]
	bl drawPauseScreen		//draw the pause screen
pauseTest:
	bl readSNES				//detect inputs
	ldr r3, =0x8			//1000 = start button
	tst r0, r3				//if start button is pressed, leave pause screen
	beq oneTurn
	
pauseMenu2:
	//put up button value memory location in r2
	//put down button value memory location in r3
	ldr r3, =0x10	//10000 = up button
	tst r0, r3		//if up is pressed, move cursor up
	beq pauseUp
	ldr r3, =0x20	//100000 = down button
	tst r0, r3		//if down is pressed, move cursor down
	beq pauseDown
	//put 'a' button value memory location in r2
	ldr r3, =0x100	//'a' button
	tst r0, r3		//if 'a' button is pressed, execute current selected pause option
	beq pSelect
	b pauseTest		//else, loop pause menu
	
pauseUp:
	ldr r1, =crntpause	//check current pause cursor location
	ldr r0, [r1]
	cmp r0, #1			//if cursor is at middle position, move to top position
	subeq r0, r0, #1
	cmp r0, #2			//if cursor is at bottom position, move to middle position
	subeq r0, r0, #1
	str r0, [r1]
	//bl drawPauseScreen
	//b pauseTest
	b pauseMenu
	
pauseDown:
	ldr r1, =crntpause	//check current pause cursor location
	ldr r0, [r1]
	cmp r0, #1			//if cursor is at middle position, move to bottom position
	addeq r0, r0, #1
	cmp r0, #0			//if cursor is at top position, move to middle position
	addeq r0, r0, #1
	str r0, [r1]
	//bl drawPauseScreen
	//b pauseTest
	b pauseMenu
	
pSelect:
	ldr r0, =crntpause	//check current pause cursor location
	ldr r0, [r0]
	cmp r0, #0			//if cursor is at top position (resume game), leave pause menu
	beq oneTurn
	cmp r0, #1			//if cursor is at middle position (restart game), go to start of game
	beq start
	ldr r0, =0x0000
	bl drawBG
	b haltLoop			//else, quit game
	
playerUp:
	push {lr}
	ldr r0, =playerface
	mov r1, #0
	str r1, [r0]		//make current player direction up
	ldr r0, =playery
	ldr r1, [r0]
	cmp r1, #0			//if player is at topmost pixel row, do not move
	movle r1, #0
	strle r1, [r0]
	ble endSub
	sub r1, r1, #10		//else, move player up
	str r1, [r0]
	pop {pc}
	
playerDown:
	push {lr}
	ldr r0, =playerface
	mov r1, #1
	str r1, [r0]		//make current player direction down
	ldr r0, =playery
	ldr r1, [r0]
	ldr r2, =0x2d0		//720
	cmp r1, r2			//if player is at bottommost pixel row, do not move
	strge r2, [r0]
	bge endSub
	add r1, r1, #10		//else, move player down
	str r1, [r0]
	pop {pc}
	
playerLeft:
	push {lr}
	ldr r0, =playerface
	mov r1, #2
	str r1, [r0]		//make current player direction left
	ldr r0, =playerx
	ldr r1, [r0]
	cmp r1, #0			//if player is at leftmost pixel column, do not move
	movle r1, #0
	strle r1, [r0]
	ble endSub
	sub r1, r1, #10		//else, move player left
	str r1, [r0]
	pop {pc}
	
playerRight:
	push {lr}
	ldr r0, =playerface
	mov r1, #3
	str r1, [r0]		//make current player direction right
	ldr r0, =playerx
	ldr r1, [r0]
	ldr r2, =0x3de		//990
	cmp r1, r2			//if player is at rightmost pixel column, do not move
	strge r2, [r0]
	bge endSub
	add r1, r1, #10		//else, move player right
	str r1, [r0]
	pop {pc}
	
playerShoot:
	push {r4, r5, lr}
	ldr r2, =playerface
	ldr r2, [r2]
	ldr r0, =playerx
	ldr r0, [r0]
	//sub r0, r0, #5
	ldr r1, =playery
	ldr r1, [r1]
	sub r1, r1, #5
	ldr r3, =shotbullet
	ldr r4, [r3]
	mov r5, r4					//copy value
	cmp r4, #15					//if last bullet shot was the last in the array, move to front of the array
	moveq r4, #0
	cmp r5, #15					//if last bullet was not the last in the array, increase current bullet by 1
	addne r4, r4, #1
	str r4, [r3]
	ldr r3, =bulletxs			//change current bullet's x to match player's
	str r0, [r3, r4, lsl #2]
	ldr r3, =bulletys			//change current bullet's y to match player's
	str r1, [r3, r4, lsl #2]				//store current bullet
	ldr r3, =bulletfaces		//change current bullet's direction to match player's
	str r2, [r3, r4, lsl #2]
	bl drawLazer
	pop {r4, r5, pc}

npcUp:
	push {lr}
	ldr r0, =currentnpcface		//check current npc's direction
	mov r1, #0
	str r1, [r0]
	ldr r0, =currentnpc
	ldr r0, [r0]
	ldr r1, =npcys
	ldr r2, [r1, r0, lsl #2]
	cmp r2, #0
	movle r2, #0
	strle r2, [r1, r0, lsl #2]
	ble endSub2
	sub r2, r2, #5
	str r2, [r1, r0, lsl #2]
	pop {pc}
	
npcDown:
	push {r4, lr}
	ldr r0, =currentnpcface
	mov r1, #1
	str r1, [r0]
	ldr r0, =currentnpc
	ldr r0, [r0]
	ldr r1, =npcys
	ldr r2, [r1, r0, lsl #2]
	ldr r4, =0x2d0		//720
	cmp r2, r4
	strge r4, [r1, r0, lsl #2]
	bge endSub2
	add r2, r2, #5
	str r2, [r1, r0, lsl #2]
	pop {r4, pc}
	
npcLeft:
	push {lr}
	ldr r0, =currentnpcface
	mov r1, #2
	str r1, [r0]
	ldr r0, =currentnpc
	ldr r0, [r0]
	ldr r1, =npcxs
	ldr r2, [r1, r0, lsl #2]
	cmp r2, #0
	movle r2, #0
	strle r2, [r1, r0, lsl #2]
	ble endSub2
	sub r2, r2, #5
	str r2, [r1, r0, lsl #2]
	pop {pc}
	
npcRight:
	push {r4, lr}
	ldr r0, =currentnpcface
	mov r1, #3
	str r1, [r0]
	ldr r0, =currentnpc
	ldr r0, [r0]
	ldr r1, =npcxs
	ldr r2, [r1, r0, lsl #2]
	ldr r4, =0x3de		//990
	cmp r2, r4
	strge r4, [r1, r0, lsl #2]
	bge endSub2
	sub r2, r2, #5
	str r2, [r1, r0, lsl #2]
	pop {r4, pc}
	
npcShoot:
	push {r4, r5, r6, lr}
	ldr r5, =currentnpc
	ldr r5, [r5]
	ldr r6, =currentnpcface
	ldr r6, [r6]
	ldr r0, =npcxs
	ldr r0, [r0, r5, lsl #2]
	ldr r1, =npcys
	ldr r1, [r1, r5, lsl #2]
	ldr r3, =shotbullet
	ldr r4, [r3]
	cmp r4, #15
	moveq r4, #0
	cmp r4, #15
	addlt r4, r4, #1
	str r4, [r3]
	ldr r2, =bulletfaces
	str r6, [r2, r4, lsl #2]
	ldr r3, =bulletxs
	str r0, [r3, r4, lsl #2]
	ldr r3, =bulletys
	str r1, [r3, r4, lsl #2]
	bl drawLazer
	pop {r4, r5, r6, pc}
	
drawScreen:
	push {r0,r4,r5,lr}
	ldr r0, =0xFFFF
	bl drawBG
	bl drawAuthorNames
	bl drawGameTitle
	bl drawScore
	ldr r0, =score
	ldr r0, [r0]
	bl drawScoreNum
	ldr r2, =npcxs
	ldr r3, =npcys
	ldr r4, =npchp
	ldr r0, [r2]
	ldr r1, [r3]
	ldr r5, [r4]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeP
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #4]
	ldr r1, [r3, #4]
	ldr r5, [r4, #4]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeP
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #8]
	ldr r1, [r3, #8]
	ldr r5, [r4, #8]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeP
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #12]
	ldr r1, [r3, #12]
	ldr r5, [r4, #12]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeP
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #16]
	ldr r1, [r3, #16]
	ldr r5, [r4, #16]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeP
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #20]
	ldr r1, [r3, #20]
	ldr r5, [r4, #20]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeP
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #24]
	ldr r1, [r3, #24]
	ldr r5, [r4, #24]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeP
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #28]
	ldr r1, [r3, #28]
	ldr r5, [r4, #28]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeP
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #32]
	ldr r1, [r3, #32]
	ldr r5, [r4, #32]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeP
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #36]
	ldr r1, [r3, #36]
	ldr r5, [r4, #36]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeP
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #40]
	ldr r1, [r3, #40]
	ldr r5, [r4, #40]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeK
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #44]
	ldr r1, [r3, #44]
	ldr r5, [r4, #44]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeK
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #48]
	ldr r1, [r3, #48]
	ldr r5, [r4, #48]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeK
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #52]
	ldr r1, [r3, #52]
	ldr r5, [r4, #52]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeK
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #56]
	ldr r1, [r3, #56]
	ldr r5, [r4, #56]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeK
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #60]
	ldr r1, [r3, #60]
	ldr r5, [r4, #60]
	cmp r5, #0
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeQ
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r2, #64]
	ldr r1, [r3, #64]
	ldr r5, [r4, #64]
	push {r0, r1, r2, r3, r4, r5}
	cmp r5, #0
	blgt drawBeeQ
	pop {r0, r1, r2, r3, r4, r5}
	ldr r3, =obstaclexs
	ldr r4, =obstacleys
	ldr r5, =obstaclehp
	ldr r0, [r3]
	ldr r1, [r4]
	ldr r2, [r5]
	push {r0, r1, r2, r3, r4, r5}
	bl drawBush
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r3, #4]
	ldr r1, [r4, #4]
	ldr r2, [r5, #4]
	push {r0, r1, r2, r3, r4, r5}
	bl drawBush
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r3, #8]
	ldr r1, [r4, #8]
	ldr r2, [r5, #8]
	push {r0, r1, r2, r3, r4, r5}
	bl drawBush
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r3, #12]
	ldr r1, [r4, #12]
	ldr r2, [r5, #12]
	push {r0, r1, r2, r3, r4, r5}
	bl drawBush
	pop {r0, r1, r2, r3, r4, r5}
	ldr r0, [r3, #16]
	ldr r1, [r4, #16]
	ldr r2, [r5, #16]
	push {r0, r1, r2, r3, r4, r5}
	bl drawBush
	pop {r0, r1, r2, r3, r4, r5}
	ldr r2, =playerx
	ldr r3, =playery
	ldr r0, [r2]
	ldr r1, [r3]
	push {r0, r1, r2, r3}
	bl drawPlayer
	pop {r0, r1, r2, r3}
	pop {r0, r4, r5, pc}

gameOver:
	bl drawGameOverScreen
	bl drawAuthorNames
	bl drawGameTitle
	bl readSNES
	ldr r3, =0x00FFFF //any button
	teq r0, r3
	bne start
	b gameOver
	
victory:
	bl drawVictoryScreen
	bl drawAuthorNames
	bl drawGameTitle
	bl drawScore
	ldr r0, =score
	ldr r0, [r0]
	bl drawScoreNum
	bl readSNES
	ldr r3, =0x00FFFF //any button
	teq r0, r3
	bne start
	b victory
	
endSub:
	pop {pc}

endSub2:
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
crntinputs:	.int	0
shotbullet:	.int	0
