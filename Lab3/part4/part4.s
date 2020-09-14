/* Program that converts a binary number to decimal */
			.text // executable code follows
			.global _start
_start:
			MOV R4, #N
			MOV R5, #Digits 	// R5 points to the decimal digits storage location
			LDR R4, [R4] 		// R4 holds N
			MOV R0, R4 			// parameter for DIVIDE goes in R0
			MOV R1, #10			// Default divisor
			CMP R0, #100 		// Is R0 > 100?
			MOVGE R1, #100		// Yes: Set divisor to 100
			CMP R0, #1000 		// Is R0 > 1000?
			MOVGE R1, #1000		// Yes: Set divisor to 1000
			BL DIVIDE
			STRB R3, [R5, #3] 	// Thousands digit is in R3
			STRB R2, [R5, #2] 	// Hundreds digit is in R2
			STRB R1, [R5, #1] 	// Tens digit is in R1
			STRB R0, [R5] 		// Ones digit is in R0
			END: B END

/* Subroutine to perform the integer division R0 / R1.
* Returns: quotient in R3, R2, R1, and remainder in R0
*/
DIVIDE: 	MOV R6, LR 			// R6 stores return address
			MOV R7, #1			// R7 stores num times we need to divide
			CMP R1, #100 		// Divisor is 100?
			MOVEQ R7, #3		// Yes: Need to divide 2 times
			CMP R1, #1000		// Divisor is 1000?
			MOVEQ R7, #4		// Yes: Need to divide 3 times
			MOV R8, R7 			// Copy to know how many divisions were done
			BL DIVIDE_10
			MOV R9, R0			// R9 stores 1's digit
			SUBS R7, #1
			BEQ DIV_DONE		// Need to keep dividing
			MOV R0, R1			// Move last remainder into R0
			BL DIVIDE_10
			MOV R10, R0			// R10 stores 10's digit
			SUBS R7, #1
			BEQ DIV_DONE
			MOV R0, R1
			BL DIVIDE_10
			MOV R11, R0			// R11 stores 100's digit
			SUBS R7, #1
			BEQ DIV_DONE
			MOV R0, R1
			BL DIVIDE_10
			MOV R12, R0			// R12 stores 1000's digit
			SUBS R7, #1
			B DIV_DONE

DIV_DONE:	MOV R0, R9
			SUBS R8, #1
			MOVEQ PC, R6
			MOV R1, R10
			SUBS R8, #1
			MOVEQ PC, R6
			MOV R2, R11
			SUBS R8, #1
			MOVEQ PC, R6
			MOV R3, R12
			MOV PC, R6

/* Subroutine to perform the integer division R0 / 10.
* Returns: quotient in R1, and remainder in R0
*/
DIVIDE_10: 	MOV R2, #0
CONT: 		CMP R0, #10
			BLT DIV_END
			SUB R0, #10
			ADD R2, #1
			B CONT
DIV_END: 	MOV R1, R2 			// quotient in R1 (remainder in R0)
			MOV PC, LR
			
N: 			.word 9876 			// the decimal number to be converted
Digits: 	.space 4 			// storage space for the decimal digits
			.end
