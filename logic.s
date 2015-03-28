.section .text

oneTurn:
	//detect inputs subroutine
	//put start button value memory location in r2
	ldr r2, [r2]
	mov r1, #0
	cmp r1, r2
	beq //pause menu subroutine
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
	beq //shoot bullet subroutine
	
	mov r1, #0
	mov r0, #17
npcStuff:
	mov r4, #0
	add r1, r1, #1
	cmp r1, r0
	bge afterNpc
	//make r4 = 1 if current npc is dead
	cmp r4, #1
	bge npcStuff
	//puts random number %4 in r2
	mov r3, #69069
	ldr r2, =x20003004
	ldr r2, [r2] //current clock value
	mul r2, r3, r2
	add r2, r3, r2
	mov r2, r2 MOD 4 //this might not work, refer to http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.kui0008a/a166_op_mod.htm
	cmp r2, #0
	beq //move npc up subroutine
	cmp r2, #1
	beq //move npc down subroutine
	cmp r2, #2
	beq //move npc left subroutine
	cmp r2, #3
	beq //move npc right subroutine
	//puts random number %10 in r2
	ldr r2, =x20003004
	ldr r2, [r2] //current clock value
	mul r2, r3, r2
	add r2, r3, r2
	mov r2, r2 MOD 10 //this might not work
	cmp r2, #0
	beq //shoot npc bullet subroutine
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
	
playerUp:
	ldr r0, =playery
	ldr r1, [r0]
	cmp r1, #0
	beq endSub
	sub r1, r1, #1
	str r1, [r0]
	b endSub
	
playerDown:
	ldr r0, =playery
	ldr r1, [r0]
	cmp r1, #767
	beq endSub
	add r1, r1, #1
	str r1, [r0]
	b endSub
	
playerLeft:
	ldr r0, =playerx
	ldr r1, [r0]
	cmp r1, #0
	beq endSub
	sub r1, r1, #1
	str r1, [r0]
	b endSub
	
playerRight:
	ldr r0, =playerx
	ldr r1, [r0]
	cmp r1, #1023
	beq endSub
	add r1, r1, #1
	str r1, [r0]
	b endSub

endSub:
	bx lr
	
.section .data

.align 4
playerx:	.int	0
playery:	.int	0
