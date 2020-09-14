.section 		.vectors, "ax"
				B _start // reset vector
				B SERVICE_UND // undefined instruction vector
				B SERVICE_SVC // software interrupt vector
				B SERVICE_ABT_INST // aborted prefetch vector
				B SERVICE_ABT_DATA // aborted data vector
				.word 0 // unused vector
				B SERVICE_IRQ // IRQ interrupt vector
				B SERVICE_FIQ // FIQ interrupt vector
				.text
				.global _start
_start:
/* Set up stack pointers for IRQ and SVC processor modes */
				MOV	R1, #0b11010010					// interrupts masked, MODE = IRQ
				MSR	CPSR_c, R1						// change to IRQ mode
				LDR	SP, =0x20000           			// set IRQ stack pointer
/* Change to SVC (supervisor) mode with interrupts disabled */
				MOV	R1, #0b11010011					// interrupts masked, MODE = SVC
				MSR	CPSR, R1						// change to supervisor mode
				LDR	SP, =0x40000				    // set SVC stack 
				BL CONFIG_GIC 						// configure the ARM generic interrupt controller
/* Configure the KEY pushbuttons port to generate interrupts */
				LDR	R0, =0xFF200050				// pushbutton KEY base address
				MOV	R1, #0xF				   	// set interrupt mask bits
				STR	R1, [R0, #0x8]				// interrupt mask register is (base + 8)
/* Enable IRQ interrupts in the ARM processor */
				MOV	R0, #0b01010011					// IRQ unmasked, MODE = SVC
				MSR	CPSR, R0
IDLE:
				B IDLE // main program simply idles
				
/* Define the exception service routines */
SERVICE_IRQ: 	PUSH {R0-R7, LR}
				LDR R4, =0xFFFEC100 // GIC CPU interface base address
				LDR R5, [R4, #0x0C] // read the ICCIAR in the CPU
// interface
KEYS_HANDLER:	CMP R5, #73 // check the interrupt ID
UNEXPECTED: 	BNE UNEXPECTED // if not recognized, stop here
				BL KEY_ISR
EXIT_IRQ: 		STR R5, [R4, #0x10] // write to the End of Interrupt
				// Register (ICCEOIR)
				POP {R0-R7, LR}
				SUBS PC, LR, #4 // return from exception

KEY_ISR:		PUSH {R0-R7, LR}
				LDR	R0, =0xFF200050		// base address of pushbutton KEY port
				LDR R6, =0xFF200020
				LDR R7, [R6]
				LDR R1, [R0, #0xC]
				
				MOV R2, R1
				AND R2, #0b0001
				CMP R2, #0b0001
				MOVEQ R3, #0b00111111
				EOREQ R7, R3
				
				MOV R2, R1
				AND R2, #0b0010
				CMP R2, #0b0010
				MOVEQ R3, #0b00000110
				LSLEQ R3, #8
				EOREQ R7, R3
				
				MOV R2, R1
				AND R2, #0b0100
				CMP R2, #0b0100
				MOVEQ R3, #0b01011011
				LSLEQ R3, #16
				EOREQ R7, R3
				
				MOV R2, R1
				AND R2, #0b1000
				CMP R2, #0b1000
				MOVEQ R3, #0b01001111
				LSLEQ R3, #24
				EOREQ R7, R3
				
				LDR R6, =0xFF200020
				STR R7, [R6]
				
				MOV	R2, #0xF
				STR	R2, [R0, #0xC]			// clear the interrupt
				
				POP {R0-R7, LR}
				MOV	PC, LR					// return

/*
 * Configure the Generic Interrupt Controller (GIC)
*/
            /* Interrupt controller (GIC) CPU interface(s) */
            .equ   MPCORE_GIC_CPUIF,     0xFFFEC100   /* PERIPH_BASE + 0x100 */
            .equ   ICCICR,               0x00         /* CPU interface control register */
            .equ   ICCPMR,               0x04         /* interrupt priority mask register */
            .equ   ICCIAR,               0x0C         /* interrupt acknowledge register */
            .equ   ICCEOIR,              0x10         /* end of interrupt register */
            /* Interrupt controller (GIC) distributor interface(s) */
            .equ   MPCORE_GIC_DIST,      0xFFFED000   /* PERIPH_BASE + 0x1000 */
            .equ   ICDDCR,               0x00         /* distributor control register */
            .equ   ICDISER,              0x100        /* interrupt set-enable registers */
            .equ   ICDICER,              0x180        /* interrupt clear-enable registers */
            .equ   ICDIPTR,              0x800        /* interrupt processor targets registers */
            .equ   ICDICFR,              0xC00        /* interrupt configuration registers */
				
CONFIG_GIC:		PUSH {LR}
    			/* To configure the FPGA KEYS interrupt (ID 73):
				 *	1. set the target to cpu0 in the ICDIPTRn register
				 *	2. enable the interrupt in the ICDISERn register */
				/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
    			MOV	R0, #73					// KEY port (interrupt ID = 73)
    			MOV	R1, #1					// this field is a bit-mask; bit 0 targets cpu0
    			BL CONFIG_INTERRUPT

				/* configure the GIC CPU interface */
    			LDR	R0, =MPCORE_GIC_CPUIF	// base address of CPU interface
    			/* Set Interrupt Priority Mask Register (ICCPMR) */
    			LDR	R1, =0xFFFF 			// enable interrupts of all priorities levels
    			STR	R1, [R0, #ICCPMR]
    			/* Set the enable bit in the CPU Interface Control Register (ICCICR). This bit
				 * allows interrupts to be forwarded to the CPU(s) */
    			MOV	R1, #1
    			STR	R1, [R0]
    
    			/* Set the enable bit in the Distributor Control Register (ICDDCR). This bit
				 * allows the distributor to forward interrupts to the CPU interface(s) */
    			LDR	R0, =MPCORE_GIC_DIST
    			STR	R1, [R0]    
    
    			POP {PC}
				
/* 
 * Configure registers in the GIC for an individual interrupt ID
 * We configure only the Interrupt Set Enable Registers (ICDISERn) and Interrupt 
 * Processor Target Registers (ICDIPTRn). The default (reset) values are used for 
 * other registers in the GIC
 * Arguments: R0 = interrupt ID, N
 *            R1 = CPU target
*/
CONFIG_INTERRUPT:
    			PUSH {R4-R5, LR}
    
    			/* Configure Interrupt Set-Enable Registers (ICDISERn). 
				 * reg_offset = (integer_div(N / 32) * 4
				 * value = 1 << (N mod 32) */
    			LSR	R4, R0, #3							// calculate reg_offset
    			BIC	R4, R4, #3							// R4 = reg_offset
				LDR	R2, =MPCORE_GIC_DIST+ICDISER
				ADD	R4, R2, R4							// R4 = address of ICDISER
    
    			AND	R2, R0, #0x1F   					// N mod 32
				MOV	R5, #1								// enable
    			LSL	R2, R5, R2							// R2 = value

				/* now that we have the register address (R4) and value (R2), we need to set the
				 * correct bit in the GIC register */
    			LDR	R3, [R4]								// read current register value
    			ORR	R3, R3, R2							// set the enable bit
    			STR	R3, [R4]								// store the new register value

    			/* Configure Interrupt Processor Targets Register (ICDIPTRn)
     			 * reg_offset = integer_div(N / 4) * 4
     			 * index = N mod 4 */
    			BIC	R4, R0, #3							// R4 = reg_offset
				LDR	R2, =MPCORE_GIC_DIST+ICDIPTR
				ADD	R4, R2, R4							// R4 = word address of ICDIPTR
    			AND	R2, R0, #0x3						// N mod 4
				ADD	R4, R2, R4							// R4 = byte address in ICDIPTR

				/* now that we have the register address (R4) and value (R2), write to (only)
				 * the appropriate byte */
				STRB R1, [R4]
    
    			POP	{R4-R5, PC}
				
/* Undefined instructions */
SERVICE_UND:	B SERVICE_UND

/* Software interrupts */
SERVICE_SVC:	B SERVICE_SVC

/* Aborted data reads */
SERVICE_ABT_DATA:B SERVICE_ABT_DATA

/* Aborted instruction fetch */
SERVICE_ABT_INST:B SERVICE_ABT_INST

SERVICE_FIQ: 	B SERVICE_FIQ