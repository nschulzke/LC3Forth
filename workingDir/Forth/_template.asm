						.ORIG		x3000
						
RESET					LD			R5,RET_STACK_ADDRESS
						LD			R4,DATA_STACK_ADDRESS
						
						LD			R6,COLD_START			; R6 holds the address to the next address (%esi equivalent, IP)
						
						JSR			NEXT
						
RET_STACK_ADDRESS		.FILL		RETURN_STACK
DATA_STACK_ADDRESS		.FILL		DATA_STACK

COLD_START				.FILL		var_QP
						
DOCOL					JSR			PUSHRSP_R6				; Push the current IP onto the return stack
						ADD			R6,R3,#1				; R3 points at the location of DOCOL, make R6 point to the location after it
						JSR			NEXT

; Def looks like: link name dodat word data
DODAT					JSR			PUSHRSP_R6				; Push the current IP onto the return stack
						LDR			R6,R3,#1				; R3 points at the location of DODAT, make R6 point to the location defined by the cell after
						ADD			R0,R3,#2				; R0 will be the address of the first data item
						JSR			PUSH_R0					; push first data address onto stack
						JSR			NEXT

#insert primitives

; <-- Other subroutines
NEXT					AND			R3,R6,R6				; Set R3 equal to R6
						ADD			R6,R6,#1				; Increment R6 (now points at next instruction)
						LDR			R3,R3,#0				; Load data at address -- this holds the next codeword
						LDR			R2,R3,#0				; Load address pointed to by next codeword
						JMP			R2						; Jump to that address
; -->						
				
; <-- POP subroutines
POP_R0					LD			R0,STACK_START
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R0,R4,#0				; Store the stack item in R0
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R0,R0,R0				; Make the nzp bits match
						RET

POP_R1					LD			R1,STACK_START
						NOT			R1,R1
						ADD			R1,R1,#1
						ADD			R1,R1,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R1,R4,#0				; Store the stack item in R1
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R1,R1,R1				; Make the nzp bits match
						RET

POP_R2					LD			R2,STACK_START
						NOT			R2,R2
						ADD			R2,R2,#1
						ADD			R2,R2,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R2,R4,#0				; Store the stack item in R2
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R2,R2,R2				; Make the nzp bits match
						RET

POP_R3					LD			R3,STACK_START
						NOT			R3,R3
						ADD			R3,R3,#1
						ADD			R3,R3,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R3,R4,#0				; Store the stack item in R2
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R3,R3,R3				; Make the nzp bits match
						RET

POPRSP_R3				LD			R3,RETURN_STACK_START
						NOT			R3,R3
						ADD			R3,R3,#1
						ADD			R3,R3,R5				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R3,R5,#0				; Store the stack item in R3
						ADD			R5,R5,#-1				; Shrink the stack
						AND			R3,R3,R3				; Make the nzp bits match
						RET
						
POPRSP_R6				LD			R6,RETURN_STACK_START
						NOT			R6,R6
						ADD			R6,R6,#1
						ADD			R6,R6,R5				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R6,R5,#0				; Store the stack item in R3
						ADD			R5,R5,#-1				; Shrink the stack
						RET
						
RETURN_STACK_START		.FILL		RETURN_STACK
STACK_START				.FILL		DATA_STACK
; END POP -->

; <-- PUSH subroutines
PUSH_R0					ADD			R4,R4,#1				; Incrememt stack pointer
						STR			R0,R4,#0				; Store in the stack
						RET
				
PUSH_R1					ADD			R4,R4,#1				; Incrememt stack pointer
						STR			R1,R4,#0				; Store in the stack
						RET
				
PUSH_R2					ADD			R4,R4,#1				; Incrememt stack pointer
						STR			R2,R4,#0				; Store in the stack
						RET

PUSH_R3					ADD			R4,R4,#1				; Incrememt stack pointer
						STR			R3,R4,#0				; Store in the stack
						RET
			
PUSHRSP_R3				ADD			R5,R5,#1				; Incrememt return stack pointer
						STR			R3,R5,#0				; Store in the stack
						RET
			
PUSHRSP_R6				ADD			R5,R5,#1				; Incrememt return stack pointer
						STR			R6,R5,#0				; Store in the stack
						RET
; END PUSH -->

EMPTY_STACK				LEA			R0,EMPTY_STACK_ERR
						ST			R7,EMPTY_STACK_RET
						PUTS
						AND			R2,R2,#0
						STI			R2,EMPTY_STACK_KEYSOURCE
						LD			R0,ABORT_addr
						JMP			R0

ABORT_addr				.FILL		RESET
EMPTY_STACK_KEYSOURCE	.FILL		var_BIN
EMPTY_STACK_ERR			.STRINGZ	"\nStack underflow! "

EMPTY_STACK_RET			.BLKW		1

WORD_BUFFER				.BLKW		32

RETURN_STACK			.BLKW		64

DATA_STACK				.BLKW		512

#insert dictionary

USER_DATA				.BLKW		1
						.END