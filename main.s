.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:

	bl		EnableJTAG

//	bl		initSNES				// initialize the SNES controller
    bl      InitFrameBuffer         // initialize the frame buffer

    // branch to the halt loop if there was an error initializing the framebuffer
	cmp		r0, #0
	beq		haltLoop

    mov		r1, #100
	mov		r2, #100
	ldr		r3,	=0xFFFFA
	bl		drawPixel

haltLoop:
	b		haltLoop
