( A -- )
#primitive DROP DROP
{
						ADD			R4,R4,#-1
						JSR			NEXT
}
( A B -- B A )
#primitive SWAP SWAP
{
						JSR			POP_R0
						JSR			POP_R1
						JSR			PUSH_R0
						JSR			PUSH_R1
						JSR			NEXT
}
( A -- A A )
#primitive DUP DUP
{
						LDR			R0,R4,#0
						JSR			PUSH_R0
						JSR			NEXT
}
( A B -- A B A )
#primitive OVER OVER
{
						LDR			R0,R4,#-1
						JSR			PUSH_R0
						JSR			NEXT
}
( A B C -- B C A )
#primitive ROT ROT
{
						JSR			POP_R0
						JSR			POP_R1
						JSR			POP_R2
						JSR			PUSH_R1
						JSR			PUSH_R0
						JSR			PUSH_R2
						JSR			NEXT
}
( A B C -- C A B )
#primitive -ROT NROT
{
						JSR			POP_R0
						JSR			POP_R1
						JSR			POP_R2
						JSR			PUSH_R0
						JSR			PUSH_R2
						JSR			PUSH_R1
						JSR			NEXT
}
( A -- A A [A<>0] )
#primitive ?DUP QDUP
{
						LDR			R0,R4,#0
						BRz			QDUP_skip
						JSR			PUSH_R0
QDUP_skip				JSR			NEXT
}
#primitive >R TOR
{
						JSR			POP_R3
						JSR			PUSHRSP_R3
						JSR			NEXT
}
#primitive R> FROMR
{
						JSR			POPRSP_R3
						JSR			PUSH_R3
						JSR			NEXT
}