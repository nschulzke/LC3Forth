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
#primitive NOT NOTF
{
						LDR			R0,R4,#0
						NOT			R0,R0
						STR			R0,R4,#0
						JSR			NEXT
}
: NOR
	OR NOT
;
: NAND
	AND NOT
;
: XOR
	OVER OVER	( A B A B )
	OR			( A B OR[A,B] )
	-ROT		( OR[A,B] A B )
	NAND		( OR[A,B] NAND[A,B] )
	AND			( AND[OR[A,B],NAND[A,B]] )
;
: XNOR
	XOR NOT
;