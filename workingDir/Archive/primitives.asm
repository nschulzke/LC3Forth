#include constants.asm
#include stackops.asm
#include arithmetic.asm
#include comparisons.asm
#include logic.asm
#primitive EXIT EXIT
{
						JSR			POPRSP_R6
						JSR			NEXT
}
#primitive LIT LIT
{
						LDR			R0,R6,#0				( Grab the next item to be executed )
						ADD			R6,R6,#1				( Skip that item )
						JSR			PUSH_R0					( Push it on the stack )
						JSR			NEXT
}
#primitive ! STORE
{
						JSR			POP_R0					( Address to store it at )
						JSR			POP_R1					( What to store )
						STR			R1,R0,#0				( Put R1 into address in R0 )
						JSR			NEXT
}
#primitive @ FETCH
{
						JSR			POP_R0					( Address to fetch it at )
						LDR			R0,R0,#0				( Load the data at that address )
						JSR			PUSH_R0
						JSR			NEXT
}
#primitive +! ADDSTORE
{
						JSR			POP_R2					( Address to add to )
						JSR			POP_R1					( How much to add )
						LDR			R0,R2,#0				( Bring in the number from memory )
						ADD			R0,R1,#0				( Add them )
						STR			R0,R2,#0				( Put R0 into address in R2 )
						JSR			NEXT
}
#primitive -! SUBSTORE
{
						JSR			POP_R2					( Address to add to )
						JSR			POP_R1					( How much to add )
						NOT			R1,R1
						ADD			R1,R1,#1				( Two's complement )
						LDR			R0,R2,#0				( Bring in the number from memory )
						ADD			R0,R1,#0				( Add them )
						STR			R0,R2,#0				( Put R0 into address in R2 )
						JSR			NEXT
}
#primitive RSP@ RSPFETCH
{
						AND			R0,R0,#0
						ADD			R0,R0,R5
						JSR			PUSH_R0
						JSR			NEXT
}
#primitive RSP! RSPSTORE
{
						JSR			POP_R0
						AND			R5,R5,#0
						ADD			R5,R5,R0
						JSR			NEXT
}
#primitive RDROP RDROP
{
						ADD			R5,R5,#-1
						JSR			PUSHRSP_R3
						JSR			NEXT
}
#primitive DSP@ DSPFETCH
{
						AND			R0,R0,#0
						ADD			R0,R0,R4
						JSR			PUSH_R0
						JSR			NEXT
}
#primitive DSP! DSPSTORE
{
						JSR			POP_R0
						AND			R4,R4,#0
						ADD			R4,R4,R0
						JSR			NEXT
}
#include io.asm
#include interpreter.asm
#include variables.asm
#include compiling.asm

: *
	DUP
	0BRANCH <#3> BRANCH <#3> 0 EXIT			( return 0 if B is 0 )
	0< DUP 0BRANCH <#2> NEGATE				( stack: A |B| S )
	-ROT									( stack: S A B )
	DUP										( stack: S A B B )
	-ROT									( stack: S B A B )
	0 DO									( stack: S B A )
		DUP									( stack: S B A A )
		-ROT								( stack: S A B A )
	LOOP									( stack: S A1 A2 .. AB B A )
	DROP									( stack: S A1 A2 .. AB B )
	1 -										( stack: S A1 A2 .. AB [B-1] )
	0 DO									( stack: S A1 A2 .. AB )
		+
	LOOP									( stack: S [A*B] )
	SWAP									( stack: [A*B] S )
	IF NEGATE THEN							( stack: [A*B] )

;

( A B -- B )
: NIP SWAP DROP ;

: HIDE WORD FIND HIDDEN ;

: >DFA >CFA 1+ ;

: :
	WORD CREATE
	DOCOL ,
	LATEST @
	HIDDEN
	]
;

: <;>
	WORD CREATE
	DOCOL ,
	LATEST @
	HIDDEN
	]
;