#variable STATE STATE
#variable BASE BASE <#10>
#variable QP QP <code_BOOT>
#primitive HERE HERE
{
						LD			R0,var_DP
						JSR			PUSH_R0
						JSR			NEXT
}
#variable DP DP <USER_DATA>