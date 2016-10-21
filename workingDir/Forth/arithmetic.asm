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