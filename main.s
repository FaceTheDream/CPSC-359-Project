.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:

	bl		EnableJTAG


    bl      InitFrameBuffer         // initialize the frame buffer
	bl		initSNES				// initialize the SNES controller

    // branch to the halt loop if there was an error initializing the framebuffer
//	cmp		r0, #0
//	beq		haltLoop

haltLoop:

	bl		start


	b		haltLoop
