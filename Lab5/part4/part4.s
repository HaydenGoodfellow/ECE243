.global _start
_start:
			MOV R3, #0 				// Milliseconds
			MOV R4, #0				// Seconds
			MOV R9, #HEX_CODES
			LDR R10, =0xFFFEC600	// Timer
			LDR R11, =0xFF200050	// Buttons
			LDR R12, =0xFF200020	// Display
MLOOP:		LDR R8, [R11, #0xC]
			CMP R8, #0
			BNE STOP
			BL DELAY
			B DISPLAY
		
DELAY: 		LDR R0, =2000000 // 200MHz / 100 = 2MHz
			STR R0, [R10] 
			MOV R1, #0b1
			STR R1, [R10, #8]
DLOOP:		LDR R2, [R10, #0xC]
			CMP R2, #0
			BEQ DLOOP
			STR R1, [R10, #0xC]
			MOV PC, LR
			
STOP: 		STR R8, [R11, #0xC]
SLOOP:		LDR R8, [R11, #0xC]
			CMP R8, #0
			BEQ SLOOP
			STR R8, [R11, #0xC]
			B DISPLAY
	
DISPLAY:	CMP R3, #99
			MOVGT R3, #0
			ADDGT R4, #1
			CMP R4, #59
			MOVGT R3, #0
			MOVGT R4, #0
			MOV R0, R3
			BL DIVIDE
			MOV R5, R9
			ADD R5, R0
			LDRB R6, [R5]
			MOV R7, R6
			MOV R5, R9
			ADD R5, R1
			LDRB R6, [R5]
			LSL R6, #8
			ORR R7, R6
			MOV R0, R4
			BL DIVIDE
			MOV R5, R9
			ADD R5, R0
			LDRB R6, [R5]
			LSL R6, #16
			ORR R7, R6
			MOV R5, R9
			ADD R5, R1
			LDRB R6, [R5]
			LSL R6, #24
			ORR R7, R6
			STR R7, [R12]
			ADD R3, #1
			B MLOOP
		
DIVIDE: 	MOV R2, #0
CONT: 		CMP R0, #10
			BLT DIV_END
			SUB R0, #10
			ADD R2, #1
			B CONT
DIV_END: 	MOV R1, R2 				// quotient in R1 (remainder in R0)
			MOV PC, LR
		
HEX_CODES: .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
           .byte 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
		   .skip 2