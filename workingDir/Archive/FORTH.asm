						.ORIG		x3000
; NEXT:
; Loads R3 with the next address to be executed
; by looking at the memory pointed to by R6.
; Increments R6 and jumps to R3's location.
; LDR R3,R6,#0
; ADD R6,R6,#1
; JMP R3

; PUSHRSP:
; ADD R5,R5,#1
; STR R5,R#,#0

; POPRSP:
; LDR R#,R5,#0
; ADD R5,R5,#-1
						
RESET					LD			R5,RET_STACK_ADDRESS
						LD			R4,DATA_STACK_ADDRESS
						STI			R4,var_SZ_loc
												
						LEA			R6,COLD_START			; R6 holds the address to the next address (%esi equivalent, IP)
						
						JSR			NEXT

var_SZ_loc				.FILL		var_SZ

COLD_START				.FILL		WORD
						.FILL		RESET
						
RET_STACK_ADDRESS		.FILL		RETURN_STACK
DATA_STACK_ADDRESS		.FILL		DATA_STACK
						
DOCOL					JSR			PUSHRSP_R3
						ADD			R3,R3,#1				; DOCOL is called at codeword in definition, so increment
						LDR			R6,R3,#0				; Then line them up. R6 and R3 now both point to the first real word
						ADD			R6,R6,#1				; NEXT
						JMP			R3
						
__DOCOL					LEA			R0,DOCOL
						JSR			PUSH_R0
						JSR			NEXT
						
DROP					ADD			R4,R4,#-1				; Just decrement the stack pointer
						JSR			NEXT

SWAP					JSR			POP_R0
						JSR			POP_R1
						JSR			PUSH_R0
						JSR			PUSH_R1
						JSR			NEXT
						
DUP						LDR			R0,R4,#0
						JSR			PUSH_R0
						JSR			NEXT

OVER					LDR			R0,R4,#-1
						JSR			PUSH_R0
						JSR			NEXT
						
ROT						JSR			POP_R0
						JSR			POP_R1
						JSR			POP_R2
						JSR			PUSH_R0
						JSR			PUSH_R2
						JSR			PUSH_R1
						JSR			NEXT
						
NROT					JSR			POP_R0
						JSR			POP_R1
						JSR			POP_R2
						JSR			PUSH_R1
						JSR			PUSH_R0
						JSR			PUSH_R2
						JSR			NEXT

QDUP					LDR			R0,R4,#0
						BRz			QDUP_skip
						JSR			PUSH_R0
QDUP_skip				JSR			NEXT

INCR					LDR			R0,R4,#0
						ADD			R0,R0,#1
						STR			R0,R4,#0
						JSR			NEXT
						
DECR					LDR			R0,R4,#0
						ADD			R0,R0,#-1
						STR			R0,R4,#0
						JSR			NEXT
						
ADDF					JSR			POP_R0
						LDR			R1,R4,#0
						ADD			R0,R0,R1
						STR			R0,R4,#0
						JSR			NEXT
						
SUBTRACT				JSR			POP_R0
						NOT			R0,R0
						ADD			R0,R0,#1
						LDR			R1,R4,#0
						ADD			R0,R0,R1
						STR			R0,R4,#0
						JSR			NEXT
						
EQUAL					JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				; Subtract A and B
						BRnp		EQUAL_false				; If result is 0 flag is 1
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		EQUAL_finish
EQUAL_false				AND			R0,R0,#0				; If false, set flag to 0
EQUAL_finish			JSR			PUSH_R0
						JSR			NEXT
												
NEQUAL					JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				; Subtract A and B
						BRz			NEQUAL_false			; If result is not 0 flag is 1
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		NEQUAL_finish
NEQUAL_false			AND			R0,R0,#0				; If false, set flag to 0
NEQUAL_finish			JSR			PUSH_R0
						JSR			NEXT
												
LT						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				; Subtract A and B
						BRnz		LT_false				; If result is + flag is 1 ( A B on stack -> B A in registers. B - A is + if A < B )
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		LT_finish
LT_false				AND			R0,R0,#0				; If false, set flag to 0
LT_finish				JSR			PUSH_R0
						JSR			NEXT
												
GT						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				; Subtract A and B
						BRzp		GT_false				; If result is - flag is 1 ( A B on stack -> B A in registers. B - A is - if A > B )
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		GT_finish
GT_false				AND			R0,R0,#0				; If false, set flag to 0
GT_finish				JSR			PUSH_R0
						JSR			NEXT
												
LTE						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				; Subtract A and B
						BRn			LTE_false				; If result is + or 0 flag is 1 ( A B on stack -> B A in registers. B - A is + or 0 if A <= B )
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		LTE_finish
LTE_false				AND			R0,R0,#0				; If false, set flag to 0
LTE_finish				JSR			PUSH_R0
						JSR			NEXT
												
GTE						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				; Subtract A and B
						BRp			GTE_false				; If result is - or 0 flag is 1 ( A B on stack -> B A in registers. B - A is - or 0 if A >= B )
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		GTE_finish
GTE_false				AND			R0,R0,#0				; If false, set flag to 0
GTE_finish				JSR			PUSH_R0
						JSR			NEXT
												
ZEQUAL					JSR			POP_R0
						BRnp		ZEQUAL_false			; If popped value is not 0, flag is 0
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		ZEQUAL_finish
ZEQUAL_false			AND			R0,R0,#0				; If false, set flag to 0
ZEQUAL_finish			JSR			PUSH_R0
						JSR			NEXT
												
ZNEQUAL					JSR			POP_R0
						BRz			ZNEQUAL_false			; If popped value is 0, flag is 0
						AND			R0,R0,#0
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		ZNEQUAL_finish
ZNEQUAL_false			AND			R0,R0,#0				; If false, set flag to 0
ZNEQUAL_finish			JSR			PUSH_R0
						JSR			NEXT
												
ZLT						JSR			POP_R0
						BRzp		ZLT_false				; If popped value is 0 or positive, flag is 0
						AND			R0,R0,#0
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		ZLT_finish
ZLT_false				AND			R0,R0,#0				; If false, set flag to 0
ZLT_finish				JSR			PUSH_R0
						JSR			NEXT
												
ZGT						JSR			POP_R0
						BRnz		ZGT_false				; If popped value is 0 or negative, flag is 0
						AND			R0,R0,#0
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		ZGT_finish
ZGT_false				AND			R0,R0,#0				; If false, set flag to 0
ZGT_finish				JSR			PUSH_R0
						JSR			NEXT
												
ZLTE					JSR			POP_R0
						BRp			ZLTE_false					; If popped value is positive, flag is 0
						AND			R0,R0,#0
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		ZLTE_finish
ZLTE_false				AND			R0,R0,#0				; If false, set flag to 0
ZLTE_finish				JSR			PUSH_R0
						JSR			NEXT
												
ZGTE					JSR			POP_R0
						BRn			ZGTE_false				; If popped value is negative, flag is 0
						AND			R0,R0,#0
						ADD			R0,R0,#1				; Add one to R0 (which is 0 already) to set flag to 1
						BRnzp		ZGTE_finish
ZGTE_false				AND			R0,R0,#0				; If false, set flag to 0
ZGTE_finish				JSR			PUSH_R0
						JSR			NEXT

ANDF					JSR			POP_R0
						LDR			R1,R4,#0
						AND			R0,R0,R1
						STR			R0,R4,#0
						JSR			NEXT

OR						JSR			POP_R0
						LDR			R1,R4,#0
						NOT			R0,R0
						NOT			R1,R1
						AND			R0,R0,R1
						NOT			R0,R0
						STR			R0,R4,#0
						JSR			NEXT

INVERT					LDR			R0,R4,#0
						NOT			R0,R0
						STR			R0,R4,#0
						JSR			NEXT
						
EXIT					JSR			POPRSP_R6
						JSR			NEXT

LIT						LDR			R0,R6,#0				; Grab the next item to be executed
						ADD			R6,R6,#1				; Skip that item
						JSR			PUSH_R0					; Push it on the stack
						JSR			NEXT

STORE					JSR			POP_R0					; Address to store it at
						JSR			POP_R1					; What to store
						STR			R1,R0,#0				; Put R1 into address in R0
						JSR			NEXT
						
FETCH					JSR			POP_R0					; Address to fetch it at
						LDR			R0,R0,#0				; Load the data at that address
						JSR			PUSH_R0
						JSR			NEXT
						
ADDSTORE				JSR			POP_R2					; Address to add to
						JSR			POP_R1					; How much to add
						LDR			R0,R2,#0				; Bring in the number from memory
						ADD			R0,R1,#0				; Add them
						STR			R0,R2,#0				; Put R0 into address in R2
						JSR			NEXT
						
SUBSTORE				JSR			POP_R2					; Address to add to
						JSR			POP_R1					; How much to add
						NOT			R1,R1
						ADD			R1,R1,#1				; Two's complement
						LDR			R0,R2,#0				; Bring in the number from memory
						ADD			R0,R1,#0				; Add them
						STR			R0,R2,#0				; Put R0 into address in R2
						JSR			NEXT

STATE					LEA			R0,var_STATE
						JSR			PUSH_R0
						JSR			NEXT
						
BASE					LEA			R0,var_BASE
						JSR			PUSH_R0
						JSR			NEXT
						
SZ						LEA			R0,var_SZ
						JSR			PUSH_R0
						JSR			NEXT
						
RZ						LD			R0,RET_STACK_ADDRESS
						JSR			PUSH_R0
						JSR			NEXT
						
LATEST					LEA			R0,var_LATEST
						JSR			PUSH_R0
						JSR			NEXT
						
HERE					LEA			R0,var_HERE
						JSR			PUSH_R0
						JSR			NEXT
						
TOR						JSR			POP_R3
						JSR			PUSHRSP_R3
						JSR			NEXT

FROMR					JSR			POPRSP_R3
						JSR			PUSH_R3
						JSR			NEXT
						
RSPFETCH				AND			R0,R0,#0
						ADD			R0,R0,R5
						JSR			PUSH_R0
						JSR			NEXT
						
RSPSTORE				JSR			POP_R0
						AND			R5,R5,#0
						ADD			R5,R5,R0
						JSR			NEXT
						
RDROP					ADD			R5,R5,#-1
						JSR			PUSHRSP_R3
						JSR			NEXT
						
DSPFETCH				AND			R0,R0,#0
						ADD			R0,R0,R4
						JSR			PUSH_R0
						JSR			NEXT
						
DSPSTORE				JSR			POP_R0
						AND			R4,R4,#0
						ADD			R4,R4,R0
						JSR			NEXT

KEY						JSR			_KEY
						JSR			PUSH_R0
						JSR			NEXT
						
_KEY					ST			R7,KEY_CB
						GETC
						OUT
						LD			R7,KEY_CB
						RET
						
EMIT					JSR			POP_R0
						OUT
						JSR			NEXT
						
KEY_CB					.BLKW		1
						
WORD					JSR			_WORD
						JSR			PUSH_R2		; Base
						JSR			PUSH_R1		; Length
						JSR			NEXT
						
_WORD					ST			R7,WORD_CB

_WORD_start				JSR			_KEY
						LD			R1,c_BACKSLASH
						NOT			R1,R1
						ADD			R1,R1,#1
						ADD			R2,R1,R0	; Check if equal
						BRz			_WORD_skip_comments
						
						LEA			R3,_WORD_start
						JSR			_WORD_check_white
						LD			R1,WORD_buffbot
						STR			R0,R1,#0
						ADD			R1,R1,#1
						ST			R1,WORD_buffptr
	
_WORD_search			JSR			_KEY
						LEA			R3,_WORD_cleanup
						JSR			_WORD_check_white
						LD			R1,WORD_buffptr
						STR			R0,R1,#0
						ADD			R1,R1,#1
						ST			R1,WORD_buffptr
						BRnzp		_WORD_search
						
_WORD_cleanup			LD			R2,WORD_buffbot
						LD			R1,WORD_buffptr
						NOT			R2,R2
						ADD			R2,R2,#1
						ADD			R1,R1,R2
						NOT			R2,R2
						ADD			R2,R2,#1
						LD			R7,WORD_CB
						RET
						
_WORD_skip_comments		JSR			_KEY
						LD			R1,c_NEW_LINE
						NOT			R1,R1
						ADD			R1,R1,#1
						ADD			R2,R1,R0	; Check if equal
						BRnp		_WORD_skip_comments
						BRzp		_WORD_start
						
_WORD_check_white		LD			R1,c_TAB
						NOT			R1,R1
						ADD			R1,R1,#1
						ADD			R2,R1,R0	; Check if equal
						BRz			_WORD_check_white_l
						LD			R1,c_SPACE
						NOT			R1,R1
						ADD			R1,R1,#1
						ADD			R2,R1,R0	; Check if equal
						BRz			_WORD_check_white_l
						RET
_WORD_check_white_l		JMP			R3

NUMBER					JSR			POP_R0		; Length
						JSR			POP_R1		; Base
						JSR			_NUMBER		
						JSR			PUSH_R2		; Number
						JSR			PUSH_R0		; Error check (0 = good)

_NUMBER					AND			R2,R2,#0
						AND			R0,R0,R0
						BRz 		_NUMBER_error
						
						LD			R3,var_BASE
						
						
_NUMBER_error			RET
						
c_BACKSLASH				.FILL		#92
c_TAB					.FILL		#9
c_NEW_LINE				.FILL		#10
c_SPACE					.FILL		#32

WORD_CB					.BLKW		1
WORD_buffptr			.FILL		WORD_BUFFER
WORD_buffbot			.FILL		WORD_BUFFER

; <-- Other subroutines
NEXT					AND			R3,R3,#0
						ADD			R3,R3,R6
						ADD			R6,R6,#1
						LDR			R3,R3,#0
						JMP			R3
; -->						
				
; <-- POP subroutines
POP_R0					LEA			R0,STACK_START
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R0,R4,#0				; Store the stack item in R0
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R0,R0,R0				; Make the nzp bits match
						RET

POP_R1					LEA			R1,STACK_START
						NOT			R1,R1
						ADD			R1,R1,#1
						ADD			R1,R1,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R1,R4,#0				; Store the stack item in R1
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R1,R1,R1				; Make the nzp bits match
						RET

POP_R2					LEA			R2,STACK_START
						NOT			R2,R2
						ADD			R2,R2,#1
						ADD			R2,R2,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R2,R4,#0				; Store the stack item in R2
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R2,R2,R2				; Make the nzp bits match
						RET

POP_R3					LEA			R3,STACK_START
						NOT			R3,R3
						ADD			R3,R3,#1
						ADD			R3,R3,R4				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R3,R4,#0				; Store the stack item in R2
						ADD			R4,R4,#-1				; Shrink the stack
						AND			R3,R3,R3				; Make the nzp bits match
						RET

POPRSP_R3				LEA			R3,STACK_START
						NOT			R3,R3
						ADD			R3,R3,#1
						ADD			R3,R3,R5				; Subtract bottom from top, if positive then stack has items to pop
						BRnz		EMPTY_STACK
						LDR			R3,R5,#0				; Store the stack item in R3
						ADD			R5,R5,#-1				; Shrink the stack
						AND			R3,R3,R3				; Make the nzp bits match
						RET
						
POPRSP_R6				LEA			R6,STACK_START
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
; END PUSH -->

var_STATE				.BLKW		1
var_BASE				.FILL		#10
var_SZ					.BLKW		1
var_LATEST				.FILL		name_SUBSTORE
var_HERE				.BLKW		1

EMPTY_STACK				BRnzp		EMPTY_STACK

WORD_BUFFER				.BLKW		32

RETURN_STACK			.BLKW		1024

DATA_STACK				.BLKW		1024