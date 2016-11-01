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
_ADDSTORE				LDR			R0,R2,#0				( Bring in the number from memory )
						ADD			R0,R0,R1				( Add them )
						STR			R0,R2,#0				( Put R0 into address in R2 )
						JSR			NEXT
}
#primitive -! SUBSTORE
{
						JSR			POP_R2					( Address to add to )
						JSR			POP_R1					( How much to add )
						NOT			R1,R1
						ADD			R1,R1,#1				( Two's complement )
						JSR			_ADDSTORE				( Run ADDSTORE from here -- only with a negative value )
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