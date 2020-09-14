/* Program that finds the largest number in a list of integers */
		.text 					// executable code follows
		.global _start
_start:
		MOV R4, #RESULT 		// R4 points to result location
		LDR R0, [R4, #4] 		// R0 holds the number of elements in the list
		MOV R1, #NUMBERS 		// R1 points to the start of the list
		BL LARGE
		STR R0, [R4] 			// R0 holds the subroutine return value
		END: B END

/* Subroutine to find the largest integer in a list
* Parameters: R0 has the number of elements in the lisst
* R1 has the address of the start of the list
* Returns: R0 returns the largest item in the list
*/
LARGE:  LDR R2, [R1]			// R2 Stores largest val so far
LOOP: 	SUBS R0, #1 			// Reduce loop counter by 1
		BEQ DONE				// If equal to zero return
		ADD R1, #4				// Next item on list
		LDR R3, [R1]			// Store next item into R3
		CMP R2, R3				// Checks if R3 is larger val
		BGE LOOP				// If not then go back to loop
		MOV R2, R3				// If it is then store new largest val
		B LOOP					// Loop until end of list
DONE:   MOV R0, R2				// Store largest val into R2
		MOV PC, LR				// Return from subroutine
		
RESULT: .word 0
N: 		.word 7 				// number of entries in the list
NUMBERS:.word 8, 5, 3, 6 		// the data
		.word 1, 8, 2
		.end
