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
#primitive 2R> DFROMR
{
						JSR			POPRSP_R3		( R3: b ret: a )
						AND			R2,R3,R3		( R2: b ret: a )
						JSR			POPRSP_R3		( R2: b R3: a )
						JSR			PUSH_R3
						JSR			PUSH_R2			( data: a b )
						JSR			NEXT
}
#primitive 2>R DTOR
{
						JSR			_DTOR
						JSR			NEXT

_DTOR					ST			R7,DTOR_CB

						JSR			POP_R2
						JSR			POP_R3			( R3: a R2: b )
						JSR			PUSHRSP_R3		( R2: b ret: a )
						AND			R3,R2,R2
						JSR			PUSHRSP_R3		( ret: a b )
						
						LD			R7,DTOR_CB
						RET
DTOR_CB					.BLKW		1
}
#primitive R@ RFETCH
{
						LDR			R0,R5,#0
						JSR			PUSH_R0
						JSR			NEXT
}
#primitive I I
{
						LDR			R0,R5,#0
						JSR			PUSH_R0
						JSR			NEXT						
}
#primitive J J
{
						LDR			R0,R5,#-2
						JSR			PUSH_R0
						JSR			NEXT
}
#primitive UNLOOP UNLOOP
{
						JSR			POPRSP_R3
						JSR			POPRSP_R3
						JSR			NEXT
}
#primitive (DO) DO
{
						JSR			_DTOR
						JSR			NEXT
}
#primitive (LOOP) LOOP
{
						AND			R3,R3,#0
						LDR			R1,R5,#0	( index )
						ADD			R1,R1,#1
						LDR			R0,R5,#-1	( limit )
						NOT			R2,R1
						ADD			R2,R2,#1	( -index )
						ADD			R2,R2,R0	( limit-index )
						BRp			LOOP_continue
						ADD			R3,R3,#-1
LOOP_continue			JSR			PUSH_R3
						STR			R1,R5,#0
						JSR			NEXT
}