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
	beq //move up subroutine
	cmp r1, r3
	beq //move down subroutine
	cmp r1, r4
	beq //move left subroutine
	cmp r1, r5
	beq //move right subroutine
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
	cmp r1, #1
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
	//if bullet is overlapped by npc, npc is hit
	//if player is hit, score - 10
	//if npc is hit, hp - 1
	//if npc hp = 0, kill npc and increase score
	//draw screen subroutine
	b oneTurn
