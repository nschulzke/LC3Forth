#primitive KEY KEY
{
						JSR			_KEY
						JSR			PUSH_R0
						JSR			NEXT
						
_KEY					ST			R7,KEY_CB
						GETC
						OUT
						LD			R7,KEY_CB
						RET
KEY_CB					.BLKW		1
}
#primitive EMIT EMIT
{
						JSR			POP_R0
						OUT
						JSR			NEXT
}
( This is designed for use with String constants and other null-terminated strings. Be careful! )
#primitive EMITS EMITS
{												
						JSR			POP_R0		( Base )
						PUTS					( We're going to trust in null-terminator )
						JSR			NEXT
}
#primitive .B DOTB
{
						JSR			POP_R1		( number to show )
						AND			R3,R3,#0
						ADD			R3,R3,#1	( initialize the mask )
						
DOTB_loop				AND			R0,R1,R3	( mask the number )
						BRnp		DOTB_one
						LD			R0,char_ZERO
						JSR			PUSH_R0		( store the value to be emitted )
						BRnzp		DOTB_incr
DOTB_one				LD			R0,char_ZERO
						ADD			R0,R0,#1
						JSR			PUSH_R0		( store the value to be emitted )
DOTB_incr				ADD			R3,R3,R3	( bitshift left )
						BRnp		DOTB_loop	( if we haven't shifted off the left edge, then repeat )
( now we have a stack of 16 characters to be emitted, loop through them )
						ADD			R3,R3,#15	( R3 is zero already, make it the counter )
DOTB_outloop			JSR			POP_R0
						OUT
						ADD			R3,R3,#-1
						BRzp		DOTB_outloop
						
						JSR			NEXT
char_ZERO				.FILL		#48
}