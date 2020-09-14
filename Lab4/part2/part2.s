        .text                   // executable code follows
        .global _start                  

_start: MOV R5, #0
        MOV R4, #TEST_NUM   // Load data
M_LOOP:	LDR R1, [R4]        // Load word into R1
		CMP R1, #0			// Check if 0
		BEQ END				// End if 0
		BL ONES				// Else use ones subroutine
		CMP R0, R5			// Check if new val is larger
		MOVGT R5, R0		// If it is store it in r5
		ADD R4, #4			// Move to next word
		B M_LOOP

ONES:   MOV R0, #0          // R0 will hold the result
O_LOOP: CMP R1, #0          // Loop until the data contains no more 1's
        BEQ O_END             
        LSR R2, R1, #1      // Perform SHIFT, followed by AND
        AND R1, R1, R2      
        ADD R0, #1          // Count the string length so far
        B O_LOOP            
O_END:	MOV PC, LR

END:    B END             

TEST_NUM: .word 0x103fe00f
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
