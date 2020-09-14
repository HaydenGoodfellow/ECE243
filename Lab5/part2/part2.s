.global _start
_start:
			MOV R4, #0
			MOV R5, #HEX_CODES
			LDR R12, =0xFF200020
			LDR R11, =0xFF200050
MLOOP:		LDR R10, [R11, #0xc]
			CMP R10, #0
			BNE STOP
			BL DELAY
			B DISPLAY
		
DELAY: 		PUSH {R9}
			LDR R9, =200000000 // delay counter
SUB_LOOP:	SUBS R9, R9, #1
		 	BNE SUB_LOOP
			POP {R9}
			MOV PC, LR
			
STOP: 		STR R10, [R11, #0xC]
SLOOP:		LDR R10, [R11, #0xC]
			CMP R10, #0
			BEQ SLOOP
			STR R10, [R11, #0xC]
			B DISPLAY
	
DISPLAY:	CMP R4, #99
			MOVGT R4, #0
			CMP R4, #0
			MOVLT R4, #0
			MOV R0, R4
			BL DIVIDE
			MOV R6, R5
			ADD R6, R0
			LDRB R3, [R6]
			MOV R7, R3
			MOV R6, R5
			ADD R6, R1
			LDRB R3, [R6]
			LSL R3, #8
			ORR R7, R3
			STR R7, [R12]
			ADD R4, #1
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