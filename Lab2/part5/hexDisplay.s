.define HEX_ADDRESS 0x2000
.define SW_ADDRESS 0x3000
.define STACK 256 		

		mv  r6, #STACK 			// 'stack pointer
		sub r6, #1
		mv  r5, pc 				// 'return address for subroutine
		mv  pc, #BLANK 			// 'call subroutine to blank the HEX displays
MAIN:	mv  r0, #0				// 'initialize counter
LOOP: 	mvt r1, #HEX_ADDRESS 	// 'point to HEX port
		mv  r2, #DATA
		mvt r4, #SW_ADDRESS
		
		
		
DRAW:	st  r2, [r1]
		add r1, #1
		add r2, #1
		st  r2, [r1]
		add r1, #1
		add r2, #1
		st  r2, [r1]
		add r1, #1
		add r2, #1
		st  r2, [r1]
		add r1, #1
		add r2, #1
		st  r2, [r1]
		add r1, #1
		add r2, #1
		st  r2, [r1]

STALL:
		//add r0, #1 				// 'counter += 1
		//bcc #LOOP 				// 'continue until counter overflows
		//mv r5, pc 				// 'return address for subroutine
		//mv pc, #BLANK 			// 'call subroutine to blank the HEX displays
		b #STALL

// 'subroutine DIV10
// 'This subroutine divides the number in r0 by 10
// 'The algorithm subtracts 10 from r0 until r0 < 10, and keeps count in r1
// 'This subroutine assumes that r6 can be used as a stack pointer
// 'input: r0
// 'returns: quotient Q in r1, remainder R in r0

DIV10:  sub r6, #1 				// 'save registers that are modified
		st r2, [r6] 			// 'save on the stack
		mv r1, #0 				// 'init Q
DLOOP:  mv r2, #9 				// 'check if r0 is < 10 yet
		sub r2, r0
		bcc #RETDIV				// 'if so, then return
INC: 	add r1, #1 				// 'but if not, then increment Q
		sub r0, #10 			// 'r0 -= 10
		b #DLOOP 				// 'continue loop
RETDIV: ld r2, [r6] 			// 'restore from the stack
		add r6, #1
		add r5, #1 				// 'adjust the return address
		mv pc, r5 				// 'return results

		add r5, #1 				// 'adjust the return address
		mv pc, r5 				// 'return results
		
// 'subroutine BLANK
BLANK:	mv r0, #0 				// 'used for clearing
		mvt r1, #HEX_ADDRESS 	// 'point to HEX displays
		st r0, [r1] 			// 'clear HEX0
		add r1, #1
		st r0, [r1] 			// 'clear HEX1
		add r1, #1
		st r0, [r1] 			// 'clear HEX2
		add r1, #1
		st r0, [r1] 			// 'clear HEX3
		add r1, #1
		st r0, [r1] 			// 'clear HEX4
		add r1, #1
		st r0, [r1] 			// 'clear HEX5
		
		add r5, #1
		mv pc, r5 				// 'return from subroutine
		
DATA:   .word 0b00111111 		// '0'
		.word 0b00000110		// '1'
		.word 0b01011011		// '2' 	 
		.word 0b01001111		// '3'
		.word 0b01100110		// '4'  
		.word 0b01101101		// '5'
		.word 0b01111101		// '6'
		.word 0b00000111		// '7'
		.word 0b01111111		// '8' 
		.word 0b01101111		// '9'
