#primitive KEY KEY
{
						JSR			_KEY
						JSR 		PUSH_R0
						JSR 		NEXT
						
_KEY					ST			R7,KEY_CB
						ST			R1,KEY_R1
						ST			R2,KEY_R2
						
_KEY_loop				GETC
						JSR			_VALID_CHAR
						AND			R2,R2,R2
						BRnp		_KEY_loop			( zero means good char, if not zero, get a new char )
						
						LD			R7,KEY_CB
						LD			R1,KEY_R1
						LD			R2,KEY_R2
						RET

_VALID_CHAR				AND			R2,R2,#0

						LD			R1,key_PRINTABLE
						ADD			R1,R1,R0
						BRzp		_V_CH_cleanup	( 31+ is good )
						
						LD			R1,key_ESC
						ADD			R1,R1,R0
						BRz			_V_CH_cleanup	( 27 is esc, we'll keep it )
						
						LD			R1,key_BKSPC
						ADD			R1,R1,R0
						BRn			_V_CH_badchar	( < 8 is bad )
						
						LD			R1,key_NL
						ADD			R1,R1,R0
						BRnz		_V_CH_cleanup	( 8 <= c <= 10 is good )

_V_CH_badchar			ADD			R2,R2,#1
_V_CH_cleanup			RET

key_BKSPC				.FILL		#-8
key_ESC					.FILL		#-27
key_NL					.FILL		#-10
key_PRINTABLE			.FILL		#-32
KEY_CB					.BLKW		1
KEY_R1					.BLKW		1
KEY_R2					.BLKW		1
}
#primitive INPUT INPUT
{
						JSR			_INPUT
						JSR			PUSH_R0
						JSR			NEXT
						
_INPUT					ST			R7,INPUT_CB
						
						LD			R1,var_BIN
						BRnp		INPUT_file

						JSR			_KEY
						
						LD			R1,key_NL
						ADD			R1,R1,R0
						BRz			INPUT_cleanup_NL
						
						OUT
						
INPUT_cleanup			LD			R7,INPUT_CB
						RET

INPUT_cleanup_NL		AND			R1,R0,R0
						LD			R0,key_SPACE
						OUT
						AND			R1,R0,R0
						BRnzp		INPUT_cleanup

						( We only get here if we're reading a file )
INPUT_file				LDR			R0,R1,#0
						BRz			INPUT_eof
						
						LD			R2,var_KEYECHO
						BRz			INPUT_noecho
					
						OUT	( This OUT is only called when we're reading from a file. )
						
INPUT_noecho			ADD			R1,R1,#1
						ST			R1,var_BIN
						ST			R1,var_BIN
						BRnzp		INPUT_cleanup
						
INPUT_eof				AND			R1,R1,#0			( set BIN back to 0 if eof )
						ST			R1,var_BIN	( and we're going to want to read the next key from the keyboard )
						LD			R0,key_NL
						NOT			R0,R0
						ADD			R0,R0,#1
						BRnzp		INPUT_cleanup
												
INPUT_CB				.BLKW		1
key_SPACE				.FILL		#32
}
#primitive PARSE PARSE
{
						JSR			POP_R2				( delimiter )
						LD			R3,var_BIN			( parse location )
						JSR			_PARSE
						JSR			PUSH_R0				( start location )
						JSR			PUSH_R1				( length of parsed string )
						JSR			NEXT
						
_PARSE					AND			R1,R1,#0			( length counter )
						NOT			R2,R2
						ADD			R2,R2,#1			( negate delim )
						ST			R2,_PARSE_delim
						
_PARSE_loop				LDR			R0,R3,#0			( char to be parsed )
						ADD			R3,R3,#1			( increment pointer )
						LD			R2,_PARSE_delim
						ADD			R2,R2,R0			( compare to delimiter )
						BRz			_PARSE_done
						LD			R2,key_NL			( get the newline )
						ADD			R2,R2,R0			( compare to delimiter )
						BRz			_PARSE_done
						ADD			R1,R1,#1			( add one char if not done )
_PARSE_noecho			BRnzp		_PARSE_loop
						
_PARSE_done				LD			R0,var_BIN			( return value for start )
						ST			R3,var_BIN			( update >IN )
						RET
						
_PARSE_delim			.BLKW		1
}
#variable KEYECHO KEYECHO <#1>
#variable >IN BIN <#0>
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
#primitive B. BDOT
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