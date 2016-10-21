#primitive F_IMMED _F_IMMED
{
						LD			R0,F_IMMED
						JSR			PUSH_R0
						JSR			NEXT
F_IMMED					.FILL		x80
}
#primitive F_HIDDEN _F_HIDDEN
{
						LD			R0,F_HIDDEN
						JSR			PUSH_R0
						JSR			NEXT
F_HIDDEN				.FILL		x20
}
#primitive F_LENMASK _F_LENMASK
{
						LD			R0,F_LENMASK
						JSR			PUSH_R0
						JSR			NEXT
F_LENMASK				.FILL		x1f
}
#primitive CREATE CREATE
{
						JSR			POP_R0				( length of name )
						JSR			POP_R1				( address of name )
						LD			R2,var_HERE			( address of header )
						LD			R3,var_LATEST		( link pointer )
						STR			R3,R2,#0			( store link at head )
						ADD			R2,R2,#1			( increment pointer )
						STR			R0,R2,#0			( store the length )
						ADD			R2,R2,#1			( increment pointer )
						
_CREATE_copy_loop		LDR			R3,R1,#0			( load the char )
						STR			R3,R2,#0			( store it )
						ADD			R2,R2,#1			( increment destination pointer )
						ADD			R1,R1,#1			( increment source pointer )
						ADD			R0,R0,#-1			( and count down )
						BRp			_CREATE_copy_loop	( loop until zero )
						
						STR			R0,R2,#0			( store 0 [null-terminator] )
						ADD			R2,R2,#1			( increment destination pointer )
						
						LD			R0,var_HERE			( var_HERE is where we started making this definition )
						ST			R0,var_LATEST		( so make var_LATEST point there )
						ST			R2,var_HERE			( and make var_HERE point to the end )
						JSR			NEXT
}
#primitive , COMMA
{
						JSR			POP_R0				( code pointer we're going to store )
						JSR			_COMMA
						JSR			NEXT
						
_COMMA					LD			R1,var_HERE
						STR			R0,R1,#0			( store code pointer at HERE )
						ADD			R1,R1,#1			( increment pointer )
						ST			R1,var_HERE			( and store it in HERE )
						RET
}
#primitive [ LBRAC 128
{
						AND			R0,R0,#0
						ST			R0,var_STATE
						JSR			NEXT
}
#primitive ] RBRAC
{
						AND			R0,R0,#0
						ADD			R0,R0,#1
						ST			R0,var_STATE
						JSR			NEXT
}
#primitive ' TICK
{
						LDR			R0,R6,#0		( Grab the next address )
						ADD			R6,R6,#1		( Skip that address )
						JSR			PUSH_R0			( Push the address on the stack )
						JSR			NEXT
}
#primitive BRANCH BRANCH
{
						LDR			R0,R6,#0		( Grab the next item, this is our offset )
						ADD			R6,R6,R0		( Add it to R6 to skip forward )
						JSR			NEXT
}
#primitive 0BRANCH ZBRANCH
{
						JSR			POP_R0
						BRz			BRANCH			( If top of stack was zero, goto BRANCH )
						ADD			R6,R6,#1		( otherwise just skip the offset )
						JSR			NEXT
}