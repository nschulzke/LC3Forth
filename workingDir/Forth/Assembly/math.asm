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
#primitive INVERT INVERT
{
						LDR			R0,R4,#0
						NOT			R0,R0
						STR			R0,R4,#0
						JSR			NEXT
}
: NOR
	OR INVERT
;
: NAND
	AND INVERT
;
: XOR
	OVER OVER	( A B A B )
	OR			( A B OR[A,B] )
	-ROT		( OR[A,B] A B )
	NAND		( OR[A,B] NAND[A,B] )
	AND			( AND[OR[A,B],NAND[A,B]] )
;
: XNOR
	XOR INVERT
;
#primitive = EQUAL
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1			( Subtract A by B )
						BRz			_EQUALITY_true		( If result is 0, equal )
						BRnzp		_EQUALITY_false		( otherwise false )
						
_EQUALITY_false			AND			R0,R0,#0
						BRnzp		_EQUALITY_finish
_EQUALITY_true			AND			R0,R0,#0
						ADD			R0,R0,#-1
_EQUALITY_finish		JSR			PUSH_R0
						JSR			NEXT
}
#primitive <> NEQUAL
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				( Subtract A by B )
						BRnp		_EQUALITY_true			( If result is <>0, nequal )
						BRnzp		_EQUALITY_false			( otherwise false )
}
#primitive < LT
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				( Subtract A by B )
						BRn			_EQUALITY_true			( If result is <0, A<B )
						BRnzp		_EQUALITY_false			( otherwise false )
}
#primitive > GT
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				( Subtract A by B )
						BRp			_EQUALITY_true			( If result is >0, A>B )
						BRnzp		_EQUALITY_false			( otherwise false )
}
#primitive <= LTE
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				( Subtract A and B )
						BRnz		_EQUALITY_true			( If result is <=0, A<=B )
						BRnzp		_EQUALITY_false			( otherwise false )
}
#primitive >= GTE
{
						JSR			POP_R0
						JSR			POP_R1
						NOT			R0,R0
						ADD			R0,R0,#1
						ADD			R0,R0,R1				( Subtract A and B )
						BRzp		_EQUALITY_true			( If result is >=0, A>=B )
						BRnzp		_EQUALITY_false			( otherwise false )
}
#primitive 0= ZEQUAL
{
						JSR			POP_R0
						BRz			_EQUALITY_true			( If result is =0, A=0 )
						BRnzp		_EQUALITY_false			( otherwise false )
}
#primitive 0<> ZNEQUAL
{
						JSR			POP_R0
						BRnp		_EQUALITY_true			( If result is <>0, A<>0 )
						BRnzp		_EQUALITY_false			( otherwise false )
}
#primitive 0< ZLT
{
						JSR			POP_R0
						BRn			_EQUALITY_true			( If result is <0, A<0 )
						BRnzp		_EQUALITY_false			( otherwise false )
}
#primitive 0> ZGT
{
						JSR			POP_R0
						BRp			_EQUALITY_true			( If result is >0, A>0 )
						BRnzp		_EQUALITY_false			( otherwise false )
}
#primitive 0<= ZLTE
{
						JSR			POP_R0
						BRnz		_EQUALITY_true			( If result is <=0, A<=0 )
						BRnzp		_EQUALITY_false			( otherwise false )
}
#primitive 0>= ZGTE
{
						JSR			POP_R0
						BRzp		_EQUALITY_true			( If result is >=0, A>=0 )
						BRnzp		_EQUALITY_false			( otherwise false )
}
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
#primitive * MULT
{
						JSR		POP_R2
						JSR		POP_R1
						JSR		_MULTIPLY
						JSR		PUSH_R3
						JSR		NEXT

_MULTIPLY				ST		R7,MULT_CB

						AND		R0,R0,#0				( Initialize our scratch )
		
						JSR		SIGN_LOGIC
						ST		R3,MULT_SIGN

						NOT		R3,R1					( Check R1 )
						NOT		R3,R3
						BRz		MULT_ZERO				( Return 0 if 0 )
						NOT		R3,R2					( Check R2 )
						NOT		R3,R3
						BRz		MULT_ZERO				( Return 0 if 0 )
						
						AND		R3,R3,#0				( Initialize our return register )

						ADD		R0,R0,R1				( Set R0 to equal R1, this will be our counter )
MULT_LOOP				ADD		R3,R3,R2				( Add to return value )
						ADD		R0,R0,#-1				( Decrement counter )
						BRp		MULT_LOOP				( Loop back until zero )

						LD		R0,MULT_SIGN
						BRp		MULT_CLEANUP
						NOT		R3,R3
						ADD		R3,R3,#1

MULT_CLEANUP			LD		R7,MULT_CB
						RET

MULT_ZERO				AND		R3,R3,#0
						BRnzp	MULT_CLEANUP

MULT_CB					.BLKW	1
MULT_SIGN				.BLKW	1
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
					JSR		RESET
DIV_ZERO_ERR_MSG	.STRINGZ "\nDivide by zero error! "

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