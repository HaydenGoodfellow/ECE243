			.text				// executable code follows
			.global _start                  

_start: 	MOV R5, #0
			MOV R6, #0
			MOV R7, #0
        	MOV R4, #TEST_NUM   // Load data
M_LOOP:		LDR R1, [R4]        // Load word into R1
			CMP R1, #0			// Check if 0
			BEQ DISPLAY			// End if 0
			BL ONES				// Else use ones subroutine
			CMP R0, R5			// Check if new val is larger
			MOVGT R5, R0		// If it is store it in r5
			LDR R1, [R4]		// Load same val as before
			BL ZEROS			// Use zeros subroutine
			CMP R0, R6			// Check if new val is larger
			MOVGT R6, R0		// If it is store it in r6
			LDR R1, [R4]		// Load same val as before
			BL ALTERNATE		// Use alternate subroutine
			CMP R0, R7			// Check if new val is larger
			MOVGT R7, R0		// If it is store it in r7
			ADD R4, #4			// Move to next word
			B M_LOOP

ONES:   	MOV R0, #0          // R0 will hold the result
O_LOOP: 	CMP R1, #0          // Loop until the data contains no more 1's
			BEQ O_END             
			LSR R2, R1, #1      // Perform SHIFT, followed by AND
			AND R1, R1, R2      
			ADD R0, #1          // Count the string length so far
			B O_LOOP            
O_END:		MOV PC, LR

ZEROS:		MOV R0, #0          // R0 will hold the result
			MVN R1, R1			// Invert r1 to find longest string of 0's
Z_LOOP: 	CMP R1, #0          // Loop until the data contains no more 1's
			BEQ Z_END             
			LSR R2, R1, #1      // Perform SHIFT, followed by AND
			AND R1, R1, R2      
			ADD R0, #1          // Count the string length so far
			B Z_LOOP            
Z_END:		MOV PC, LR


ALTERNATE:	MOV R0, #0			// Store result in r0
			MOV R3, #ALT_NUM	// r3 = 01010101....
			LDR R3, [R3]
			MOV R2, R1			// Copy r1 into r2
			EOR R1, R2, R3
			PUSH {R2, LR}		// Store r2 and our link to main
			BL ONES 			
			POP {R2}
			LSL R3, #1			// r3 = 10101010.....
			EOR R1, R2, R3
			PUSH {R0}			// Push our current r0
			BL ONES
			MOV R1, R0			// Move new r0 into r1
			POP {R0}			
			CMP R1, R0			// Compare new r0 (r1) with old r0 (r0)
			MOVGT R0, R1		// If larger then store new value
			POP {PC}			// Return to main

DISPLAY:    LDR R8, =0xFF200020 // base address of HEX3-HEX0
            MOV R0, R5          // display R5 on HEX1-0
            BL DIVIDE          	// ones digit will be in R0; tens digit in R1
            MOV R9, R1          // save the tens digit
            BL SEG7_CODE       
            MOV R4, R0          // save bit code
            MOV R0, R9          // retrieve the tens digit, get bit code
            BL SEG7_CODE       
            LSL R0, #8
            ORR R4, R0
			MOV R0, R6			// display R6 on HEX3-2
			BL DIVIDE          	// ones digit will be in R0; tens digit in R1
            MOV R9, R1          // save the tens digit
            BL SEG7_CODE
			LSL r0, #16
            ORR R4, R0          // save bit code
            MOV R0, R9          // retrieve the tens digit, get bit code
            BL SEG7_CODE       
            LSL R0, #24
            ORR R4, R0
            STR R4, [R8]        // display the numbers from R6 and R5
            LDR R8, =0xFF200030 // base address of HEX5-HEX4
			MOV R0, R7			// display R7 on HEX5-4
			BL DIVIDE          	// ones digit will be in R0; tens digit in R1
            MOV R9, R1          // save the tens digit
            BL SEG7_CODE       
            MOV R4, R0          // save bit code
            MOV R0, R9          // retrieve the tens digit, get bit code
            BL SEG7_CODE       
            LSL R0, #8
            ORR R4, R0
            STR R4, [R8]        // display the number from R7
			B END

/* Subroutine to perform the integer division R0 / 10.
* Returns: quotient in R1, and remainder in R0
*/
DIVIDE: 	MOV R2, #0
CONT: 		CMP R0, #10
			BLT DIV_END
			SUB R0, #10
			ADD R2, #1
			B CONT
DIV_END: 	MOV R1, R2 				// quotient in R1 (remainder in R0)
			MOV PC, LR

/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit patterm to be written to the HEX display
 */
SEG7_CODE:  MOV R1, #BIT_CODES  
            ADD R1, R0         		// index into the BIT_CODES "array"
            LDRB R0, [R1]       	// load the bit pattern (to be returned)
            MOV PC, LR              

END:    	B END             

BIT_CODES:  .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip 2      // pad with 2 bytes to maintain word alignment

ALT_NUM: 	.word 0x55555555	// 010101010101... in binary

TEST_NUM: 	.word 0x103fe00f
			.word 0x420b1a23 
			.word 0x11111111 
			.word 0x00000003
			.word 0x00000001 
			.word 0xffffffff 
			.word 0x12345678 
			.word 0x9abcdef0
			.word 0x42042069 
			.word 0xfedcba98 
			.word 0x00000000
			.end                            
