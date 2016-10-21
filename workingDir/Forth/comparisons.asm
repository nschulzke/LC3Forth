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