.define LED_ADDRESS 0x1000
.define SW_ADDRESS  0x3000
		mvt r5, #LED_ADDRESS
		mvt r4, #SW_ADDRESS
MAIN:	ld r3, [r4]

START:	mvt r1, 0x1F00
		add r1, 0xAC
		
LOOP:   sub r1, #1
		bcc #LOOP

		add r3, #0 			// Check if equal to zero
		beq #DRAW
		sub r3, #1 			// Not equal to zero
		bne #START
		
DRAW:   add r0, #1
		st r0, [r5]
		mv pc, #MAIN
		
		
