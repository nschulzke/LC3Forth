#primitive 1+ INCR
{
						LDR			R0,R4,#0
						ADD			R0,R0,#1
						STR			R0,R4,#0
						JSR			NEXT
}
#primitive 1- DECR
{
						LDR			R0,R4,#0
						ADD			R0,R0,#-1
						STR			R0,R4,#0
						JSR			NEXT
}
#primitive + ADDF
{
						JSR			POP_R0
						LDR			R1,R4,#0
						ADD			R0,R0,R1
						STR			R0,R4,#0
						JSR			NEXT
}
#primitive - SUBTRACT
{
						JSR			POP_R0
						NOT			R0,R0
						ADD			R0,R0,#1
						LDR			R1,R4,#0
						ADD			R0,R0,R1
						STR			R0,R4,#0
						JSR			NEXT
}
#primitive AND ANDF
{
						JSR			POP_R0
						LDR			R1,R4,#0
						AND			R0,R0,R1
						STR			R0,R4,#0
						JSR			NEXT
}
#primitive OR OR
{
						JSR			POP_R0
						LDR			R1,R4,#0
						NOT			R0,R0
						NOT			R1,R1
						AND			R0,R0,R1
						NOT			R0,R0
						STR			R0,R4,#0
						JSR			NEXT
}
#primitive NOTB NOTF
{
						LDR			R0,R4,#0
						NOT			R0,R0
						STR			R0,R4,#0
						JSR			NEXT
}
: NOR
	OR NOTB
;
: NAND
	AND NOTB
;
: XOR
	OVER OVER	( A B A B )
	OR			( A B OR[A,B] )
	-ROT		( OR[A,B] A B )
	NAND		( OR[A,B] NAND[A,B] )
	AND			( AND[OR[A,B],NAND[A,B]] )
;
: XNOR
	XOR NOTB
;
#primitive = EQUAL
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				( Subtract A and B )
						BRnp		EQUAL_false				( If result is 0 flag is 1 )
						ADD			R0,R0,#1				( Add one to R0 to set flag to 1 )
						BRnzp		EQUAL_finish
EQUAL_false				AND			R0,R0,#0				( If false, set flag to 0 )
EQUAL_finish			JSR			PUSH_R0
						JSR			NEXT
}
#primitive <> NEQUAL
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				( Subtract A and B )
						BRz			NEQUAL_false			( If result is not 0 flag is 1 )
						AND			R0,R0,#0
						ADD			R0,R0,#1				( A <> B, so flag is true )
						BRnzp		NEQUAL_finish
NEQUAL_false			AND			R0,R0,#0				( If false, set flag to 0 )
NEQUAL_finish			JSR			PUSH_R0
						JSR			NEXT
}
#primitive < LT
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				( Subtract A and B )
						BRzp		LT_false				( If result is not 0 flag is 1 )
						AND			R0,R0,#0
						ADD			R0,R0,#1				( Add one to R0 to set flag to 1 )
						BRnzp		LT_finish
LT_false				AND			R0,R0,#0				( If false, set flag to 0 )
LT_finish				JSR			PUSH_R0
						JSR			NEXT
}
#primitive > GT
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				( Subtract A and B )
						BRnz		GT_false				( If result is - flag is 1 [ A B on stack -> B A in registers. B - A is - if A > B ] )
						AND			R0,R0,#0
						ADD			R0,R0,#1				( Add one to R0 to set flag to 1 )
						BRnzp		GT_finish
GT_false				AND			R0,R0,#0				( If false, set flag to 0 )
GT_finish				JSR			PUSH_R0
						JSR			NEXT
}
#primitive <= LTE
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				( Subtract A and B )
						BRp			LTE_false				( If result is + or 0 flag is 1 [ A B on stack -> B A in registers. B - A is + or 0 if A <= B ] )
						AND			R0,R0,#0
						ADD			R0,R0,#1				( Add one to R0 to set flag to 1 )
						BRnzp		LTE_finish
LTE_false				AND			R0,R0,#0				( If false, set flag to 0 )
LTE_finish				JSR			PUSH_R0
						JSR			NEXT
}
#primitive >= GTE
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				( Subtract A and B )
						BRn			GTE_false				( If result is - or 0 flag is 1 [ A B on stack -> B A in registers. B - A is - or 0 if A >= B ] )
						AND			R0,R0,#0
						ADD			R0,R0,#1				( Add one to R0 to set flag to 1 )
						BRnzp		GTE_finish
GTE_false				AND			R0,R0,#0				( If false, set flag to 0 )
GTE_finish				JSR			PUSH_R0
						JSR			NEXT
}
#primitive 0= ZEQUAL
{
						JSR			POP_R0
						BRnp		ZEQUAL_false			( If popped value is not 0, flag is 0 )
						ADD			R0,R0,#1				( Add one to R0 to set flag to 1 )
						BRnzp		ZEQUAL_finish
ZEQUAL_false			AND			R0,R0,#0				( If false, set flag to 0 )
ZEQUAL_finish			JSR			PUSH_R0
						JSR			NEXT
}
#primitive 0<> ZNEQUAL
{
						JSR			POP_R0
						BRz			ZNEQUAL_false			( If popped value is 0, flag is 0 )
						AND			R0,R0,#0
						ADD			R0,R0,#1				( Add one to R0 to set flag to 1 )
						BRnzp		ZNEQUAL_finish
ZNEQUAL_false			AND			R0,R0,#0				( If false, set flag to 0 )
ZNEQUAL_finish			JSR			PUSH_R0
						JSR			NEXT
}
#primitive 0< ZLT
{
						JSR			POP_R0
						BRzp		ZLT_false				( If popped value is 0 or positive, flag is 0 )
						AND			R0,R0,#0
						ADD			R0,R0,#1				( Add one to R0 to set flag to 1 )
						BRnzp		ZLT_finish
ZLT_false				AND			R0,R0,#0				( If false, set flag to 0 )
ZLT_finish				JSR			PUSH_R0
						JSR			NEXT
}
#primitive 0> ZGT
{
						JSR			POP_R0
						BRnz		ZGT_false				( If popped value is 0 or negative, flag is 0 )
						AND			R0,R0,#0
						ADD			R0,R0,#1				( Add one to R0 to set flag to 1 )
						BRnzp		ZGT_finish
ZGT_false				AND			R0,R0,#0				( If false, set flag to 0 )
ZGT_finish				JSR			PUSH_R0
						JSR			NEXT
}
#primitive 0<= ZLTE
{
						JSR			POP_R0
						BRp			ZLTE_false				( If popped value is positive, flag is 0 )
						AND			R0,R0,#0
						ADD			R0,R0,#1				( Add one to R0 to set flag to 1 )
						BRnzp		ZLTE_finish
ZLTE_false				AND			R0,R0,#0				( If false, set flag to 0 )
ZLTE_finish				JSR			PUSH_R0
						JSR			NEXT
}
#primitive 0>= ZGTE
{
						JSR			POP_R0
						BRn			ZGTE_false				( If popped value is negative, flag is 0 )
						AND			R0,R0,#0
						ADD			R0,R0,#1				( Add one to R0 to set flag to 1 )
						BRnzp		ZGTE_finish
ZGTE_false				AND			R0,R0,#0				( If false, set flag to 0 )
ZGTE_finish				JSR			PUSH_R0
						JSR			NEXT
}
#primitive /MOD DIVMOD
{
					JSR		POP_R2
					JSR		POP_R1
					JSR		_DIVIDE
					JSR		PUSH_R1
					JSR		PUSH_R0
					JSR		NEXT
					
_DIVIDE				ST		R7,DIV_R7

					AND		R2,R2,R2				( Check denominator )
					BRz		DIV_ZERO_ERROR			( Error if zero )
					AND		R1,R1,R1				( Check the numerator )
					BRz		DIV_ZERO_RETURN			( Return 0 if 0 )
					
					JSR		SIGN_LOGIC

					ST		R3,DIV_SIGN				( Store sign )
					
					NOT		R3,R2					( Using R3 as a scratch for the negative denominator )
					ADD		R3,R3,#1				( This is guaranteed to be overwritten at end to return the remainder )

					AND 	R0,R0,#0				( Initialize our counter )

DIV_LOOP			ADD		R0,R0,#1				( Increment counter )
					ADD		R1,R1,R3				( Subtract numerator by denominator (using R3 as negative denominator) )
					BRp		DIV_LOOP				( Repeat until zero or less )

					BRz		DIV_EVEN				( If our last subtraction yielded zero, then it was an even division )
					ADD		R0,R0,#-1				( If it wasn't an even division, subtract 1 from counter )
					ADD		R1,R1,R2				( Set R1 to the remainder (Remainder = Deonominator + Last subtraction value (which is negative)) )
					BRnzp	DIV_RETURN

DIV_EVEN			AND		R1,R1,#0
					
DIV_RETURN			LD		R3,DIV_SIGN				( Load the sign into R3 to check )
					BRzp	DIV_CLEANUP				( If the sign is zero or positive, we're done )
					NOT		R0,R0
					ADD		R0,R0,#1				( If the sign is negative, make the result negative )
					
DIV_CLEANUP			LD		R7,DIV_R7
					RET

DIV_ZERO_RETURN		AND		R0,R0,#0
					AND		R1,R1,#0
					BRnzp	DIV_CLEANUP

DIV_ZERO_ERROR		LEA		R0,DIV_ZERO_ERR_MSG
					PUTS
					HALT
DIV_ZERO_ERR_MSG	.STRINGZ "\nATTEMPTED TO DIVIDE BY ZERO\n"

DIV_R0			.BLKW	1
DIV_R1			.BLKW	1
DIV_R2			.BLKW	1
DIV_R7			.BLKW	1
DIV_SIGN		.BLKW	1

SIGN_LOGIC			ST		R7,SIGN_CALLBACK

					AND		R3,R3,#0
					ADD		R3,R3,#1				( Start with 1 in the sign value )
					
SIGN_TEST_R1		AND		R1,R1,R1
					BRzp	SIGN_TEST_R2			( Leave the sign alone if R1 isn't negative )
					JSR		SIGN_FLIP				( Otherwise, invert the return sign )
					NOT		R1,R1
					ADD		R1,R1,#1				( And make R1 positive )

SIGN_TEST_R2		AND		R2,R2,R2
					BRzp	SIGN_CLEANUP			( Leave the sign alone if R2 isn't negative )
					JSR		SIGN_FLIP				( Otherwise, invert the return sign )
					NOT		R2,R2
					ADD		R2,R2,#1				( And make R2 positive )

SIGN_CLEANUP		LD		R7,SIGN_CALLBACK
					RET
					
SIGN_FLIP			NOT		R3,R3
					ADD		R3,R3,#1				( Invert the sign bit and return )
					RET

SIGN_CALLBACK		.BLKW	1
}