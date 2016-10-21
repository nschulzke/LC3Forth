#primitive R0 RZ
{
						LD			R0,RET_STACK_ADDRESS
						JSR			PUSH_R0
						JSR			NEXT
}
#primitive DOCOL _DOCOL
{
						LEA			R0,DOCOL
						JSR			PUSH_R0
						JSR			NEXT
}
#primitive S0 SZ
{
						LD			R0,DATA_STACK_ADDRESS
						JSR			PUSH_R0
						JSR			NEXT
}