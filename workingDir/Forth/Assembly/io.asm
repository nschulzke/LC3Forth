#primitive (KEY) KEYp
{
						JSR			_KEYp
						JSR			PUSH_R0
						JSR			NEXT
						
_KEYp					ST			R7,KEYp_CB

						LD			R1,var_KEYSOURCE
						BRz			KEY_board
						
						( We only get here if we're reading a file )
						LDR			R0,R1,#0
						BRz			KEY_eof
						
						LD			R2,var_KEYECHO
						BRz			KEY_noecho
					
						OUT	( This OUT is only called when we're reading from a file. If we're not reading a file. )
						
KEY_noecho				ADD			R1,R1,#1
						ST			R1,var_KEYSOURCE
						BRnzp		KEYp_cleanup
						
KEY_eof					AND			R1,R1,#0			( set KEYSOURCE back to 0 if eof )
						ST			R1,var_KEYSOURCE	( and we're going to want to read the next key from the keyboard )
						LD			R0,key_NL
						NOT			R0,R0
						ADD			R0,R0,#1
						BRnzp		KEYp_cleanup
						
						( we come here if we're reading from keyboard )
KEY_board				GETC

KEYp_cleanup			LD			R7,KEYp_CB
						RET

KEYp_CB					.BLKW		1
}
#variable KEYECHO KEYECHO <#1>
#primitive KEY KEY
{
						JSR			_KEY
						JSR			PUSH_R0
						JSR			NEXT
						
_KEY					ST			R7,KEY_CB

						JSR			_KEYp
						
						LD			R1,var_KEYSOURCE
						BRnp		KEY_cleanup
						
						LD			R1,key_NL
						ADD			R1,R1,R0
						BRz			KEY_cleanup_NL
						
						LD			R1,key_TAB			( we need to check this so we print tabs instead of ignoring them below )
						ADD			R1,R1,R0
						BRz			KEY_out
						
						LD			R1,key_PRINTABLE
						ADD			R1,R1,R0
						BRn			KEY_cleanup			( not printable char )
						
KEY_out					OUT

KEY_cleanup				LD			R7,KEY_CB
						RET
						
KEY_cleanup_NL			ST			R0,var_DELAYED_NL
						LD			R0,key_SPACE
						OUT
						LD			R0,var_DELAYED_NL
						BRnzp		KEY_cleanup
						
KEY_CB					.BLKW		1
key_TAB					.FILL		#-9
key_NL					.FILL		#-10
key_PRINTABLE			.FILL		#-32
key_SPACE				.FILL		#32
}
#variable DELAYED_NL DELAYED_NL <#0>
#variable KEYSOURCE KEYSOURCE <#0>
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