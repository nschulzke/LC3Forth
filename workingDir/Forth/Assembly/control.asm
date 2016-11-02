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
#primitive (?DO) QDO
{
						LDR			R0,R4,#0	( index )
						LDR			R1,R4,#-1	( limit )
						NOT			R1,R1
						ADD			R1,R1,#1	( -limit )
						ADD			R1,R1,R0	( index-limit )
						BRnp		DO			( act like DO if we can iterate )
						ADD			R4,R4,#-2	( drop them if not equal )
						BRnzp		BRANCH		( and branch to the offset )
}
#primitive (DO) DO
{
						JSR			_DTOR
						ADD			R6,R6,#1	( skip offset, we don't care about it )
						JSR			NEXT
}
#primitive (LEAVE) LEAVE
{
						JSR			POPRSP_R3
						JSR			POPRSP_R3
						BRnzp		BRANCH
}
#primitive (LOOP) LOOP
{
						LDR			R1,R5,#0	( index )
						ADD			R1,R1,#1
_LOOP					STR			R1,R5,#0	( store the new index )
						LDR			R0,R5,#-1	( limit )
						NOT			R1,R1
						ADD			R1,R1,#1	( -index )
						
						ADD			R1,R1,R0	( limit-index )
						BRp			BRANCH		( if still positive, branch back )
						ADD			R6,R6,#1	( otherwise, move past offset )
						
						BRnzp		UNLOOP
}
#primitive (+LOOP) pLOOP
{
						LDR			R1,R5,#0	( index )
						JSR			POP_R2
						ADD			R1,R1,R2	( index + stackval )
						
						JSR			_LOOP
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