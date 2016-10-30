#primitive EXIT EXIT
{
						JSR			POPRSP_R6
						JSR			NEXT
}
#primitive LIT LIT
{
						LDR			R0,R6,#0				( Grab the next item to be executed )
						ADD			R6,R6,#1				( Skip that item )
						JSR			PUSH_R0					( Push it on the stack )
						JSR			NEXT
}
#primitive LIT_XT LIT_XT
{
						LDR			R0,R6,#0				( Grab the next item to be executed )
						ADD			R6,R6,#1				( Skip that item )
						JSR			PUSH_R0					( Push it on the stack )
						JSR			NEXT
}
#primitive LITSTRING LITSTRING
{
						LDR			R0,R6,#0				( Grab the length )
						ADD			R6,R6,#1				( Skip it )
						AND			R1,R6,R6				( get the start )
						ADD			R6,R6,R0				( skip past the string )
						JSR			PUSH_R1					( the address )
						JSR			PUSH_R0					( the length )
						JSR			NEXT
}
#primitive WORD WORD
{
						JSR			_WORD
						JSR			PUSH_R2		( Base )
						JSR			PUSH_R1		( Length )
						JSR			NEXT		( Stack: Base Length )
												
_WORD					ST			R7,WORD_CB

_WORD_start				JSR			_KEY
						( make newlines appear as long as it's initial whitespace )
						LD			R1,c_NEW_LINE
						ADD			R2,R1,R0	( Check if equal )
						BRnp		_WORD_skip_NL
						NOT			R0,R1
						ADD			R0,R0,#1
						OUT
						AND			R1,R1,#0
						ST			R1,var_DELAYED_NL
						
_WORD_skip_NL			LD			R1,c_BACKSLASH
						ADD			R2,R1,R0	( Check if equal )
						BRz			_WORD_skip_comments
						
						LEA			R3,_WORD_start
						JSR			_WORD_check_white
						
						LD			R1,WORD_buffbot
						STR			R0,R1,#0
						ADD			R1,R1,#1
						ST			R1,WORD_buffptr
	
_WORD_search			JSR			_KEY
						LEA			R3,_WORD_cleanup
						JSR			_WORD_check_white
						LD			R1,WORD_buffptr
						STR			R0,R1,#0
						ADD			R1,R1,#1
						ST			R1,WORD_buffptr
						BRnzp		_WORD_search
						
_WORD_cleanup			LD			R2,WORD_buffbot
						LD			R1,WORD_buffptr
						NOT			R2,R2
						ADD			R2,R2,#1
						ADD			R1,R1,R2
						NOT			R2,R2
						ADD			R2,R2,#1
						LD			R7,WORD_CB
						RET
						
_WORD_skip_comments		JSR			_KEY
						LD			R1,c_NEW_LINE
						ADD			R2,R1,R0	( Check if equal )
						BRnp		_WORD_skip_comments
						BRzp		_WORD_start
						
_WORD_check_white		LD			R1,c_TAB
						ADD			R2,R1,R0	( Check if equal )
						BRz			_WORD_check_white_l
						
						LD			R1,c_SPACE
						ADD			R2,R1,R0	( Check if equal )
						BRz			_WORD_check_white_l
						
						LD			R1,c_NEW_LINE
						ADD			R2,R1,R0	( Check if equal )
						BRz			_WORD_check_white_l
						
						LD			R1,c_ESC
						ADD			R2,R1,R0	( Check if equal )
						BRz			_WORD_start
						
						LD			R1,c_BACKSPACE
						ADD			R2,R1,R0	( Check if equal )
						BRz			_WORD_start

						RET
						
_WORD_check_white_l		JMP			R3
						
c_BACKSLASH				.FILL		#-92
c_TAB					.FILL		#-9
c_NEW_LINE				.FILL		#-10
c_SPACE					.FILL		#-32
c_BACKSPACE				.FILL		#-8
c_ESC					.FILL		#-27

WORD_CB					.BLKW		1
WORD_buffptr			.FILL		WORD_BUFFER
WORD_buffbot			.FILL		WORD_BUFFER
}
#primitive NUMBER NUMBER
{
						JSR			POP_R0			( Length )
						JSR			POP_R1			( Base )
						JSR			_NUMBER		
						JSR			PUSH_R2			( Number )
						JSR			PUSH_R0			( Error check [0 = good] )
						JSR			NEXT

_NUMBER					ST			R7,NUMBER_CB

						AND			R2,R2,#0
						ST			R2,NUMBER_retval
						AND			R0,R0,R0
						BRnz 		_NUMBER_return	( if length is zero or negative, return 0 )
						
						LDR			R2,R1,#0		( get first char )
						ADD			R1,R1,#1		( increment char pointer )
						
						LD			R3,CHAR_neg_sign
						NOT			R3,R3
						ADD			R3,R3,#1
						ADD			R3,R3,R2		( subtract neg_sign from char )
						ST			R3,NUMBER_sign	( store the sign -- <> 0 means not neg )
						BRp			_NUMBER_process
						ADD			R0,R0,#-1		( we parsed a character, so decrement unparsed chars )
						BRp			_NUMBER_loop	( read next char if it was - )
						ADD			R0,R0,#1		( oops! - is the only character, which means this isn't a number! )
						LD			R7,NUMBER_CB
						LD			R2,NUMBER_retval
						RET							( put it back to 1 and return an error )
						
_NUMBER_loop			LD			R3,var_BASE		( if we still have digits to work with, then we need to multiply by the base )
						LD			R2,NUMBER_retval
						ST			R0,NUMBER_length
						AND			R0,R0,#0		( R0 is scratch )
_NUMBER_mult			ADD			R0,R0,R2		( add again )
						ADD			R3,R3,#-1		( decrement base counter )
						BRp			_NUMBER_mult	( multiply again if not zero )
						ST			R0,NUMBER_retval
						LD			R0,NUMBER_length
						
						LDR			R2,R1,#0		( get the next char )
						ADD			R1,R1,#1		( increment pointer )
						
						( at this point, R2 holds the character, R0 holds the loop iterator, R1 holds the data pointer )
						( when finished with _NUMBER_process, R3 will hold the value of the digit )
_NUMBER_process			LD			R3,CHAR_zero
						NOT			R3,R3
						ADD			R3,R3,#1		( negate 0 so we can subtract by it )
						ADD			R3,R3,R2		( subtracted, so now we can check digits )
						BRn			_NUMBER_cleanup ( ASCII < 0 means not valid digits )
						ADD			R2,R3,#-10		( ASCII <= 9 means we can save it )
						BRn			_NUMBER_save
						LD			R2,CHAR_subA
						ADD			R3,R3,R2		( subtract 17 to get to A B C )
						BRn			_NUMBER_cleanup	( if less than A but greater than 9, bad number )
						ADD			R3,R3,#10		( add 10 so A = 10, B = 11, etc )
						
_NUMBER_save			LD			R2,var_BASE
						NOT			R2,R2
						ADD			R2,R2,#1		( invert BASE -- we want to check to see if digit is in range )
						ADD			R2,R2,R3		( subtract BASE from digit -- negative if in range, zero if equal [bad -- no 10 digit in base-10] )
						BRzp		_NUMBER_cleanup	( if it wasn't in range, we're done )
						
						( if it was in range, let's add it to NUMBER_retval )
						LD			R2,NUMBER_retval
						ADD			R2,R2,R3			( add it -- _NUMBER_loop already prepped it for a new digit )
						ST			R2,NUMBER_retval	( and store it again )
						ADD			R0,R0,#-1			( subract 1 from num chars )
						BRp			_NUMBER_loop		( we need to keep looping if we still have chars to read )
						( otherwise, cleanup )
_NUMBER_cleanup			LD			R2,NUMBER_retval	( load the return value )
						LD			R3,NUMBER_sign		( load the stored sign )
						BRnp		_NUMBER_return		
						NOT			R2,R2				( if sign flag was 0, we need to invert output )
						ADD			R2,R2,#1
						( final output: R2 holds number, R0 holds number of characters unparsed )
_NUMBER_return			AND			R3,R3,#0
						ST			R3,NUMBER_sign
						LD			R7,NUMBER_CB
						RET

NUMBER_CB				.BLKW		1
NUMBER_retval			.BLKW		1
NUMBER_sign				.FILL		#0		( <> 0 means not neg )
NUMBER_length			.BLKW		1
CHAR_zero				.FILL		#48		( 0 )
CHAR_neg_sign			.FILL		#45
CHAR_subA				.FILL		#-17		( 'A' - '0', used to turn A into 0, B into 1, etc )
}
#primitive FIND FIND
{
						JSR			POP_R0			( Length )
						JSR			POP_R1			( Base )
						JSR			_FIND		
						JSR			PUSH_R2			( Address of entry )
						JSR			NEXT
						
_FIND					ST			R7,FIND_CB
						ST			R6,FIND_R6
						ST			R5,FIND_R5
						ST			R4,FIND_R4
						
						LD			R2,var_LATEST
						
_FIND_loop				AND			R2,R2,R2
						BRz			_FIND_fail		( if we hit zero, not found )
												
						LDR			R3,R2,#1		( grab the length word )
						
						LD			R4,F_HIDDEN		( prep to mask )
						AND			R4,R4,R3		( if the hidden bit is set in the length word )
						BRnp		_FIND_backtrack	( then move back more )
						LD			R4,F_LENMASK	( get the length mask )
						AND			R4,R4,R3		( mask the length )
						NOT			R5,R4
						ADD			R5,R5,#1		( negate to compare )
						ADD			R5,R5,R0		( compare to the length of the target word )
						BRnp		_FIND_backtrack	( if they don't match, then move on )
						
						ST			R1,FIND_base
						AND			R5,R2,R2
						ADD			R5,R5,#2		( 2 more will give us the first char in name )
						( INPUT: R1: target string pointer, R4: length, R5: test string pointer )
						( USING: R6: target char, R3: test char )
_FIND_comp_loop			LDR			R6,R1,#0		( target char )
						LDR			R3,R5,#0		( test char )
						NOT			R3,R3
						ADD			R3,R3,#1		( negate to compare )
						ADD			R3,R3,R6		( add them together )
						BRnp		_FIND_comp_fail ( didn't match, move on )
						ADD			R1,R1,#1		( increment pointers )
						ADD			R5,R5,#1
						ADD			R4,R4,#-1		( decrement counter )
						BRp		_FIND_comp_loop ( still matching, so loop )
						( if we got out of the above loop without going to _FIND_comp_fail, we found a match )
						BRnz		_FIND_end		( R2 will already point to target, so return )
						
_FIND_comp_fail			LD			R1,FIND_base	( restore pointer )
						
_FIND_backtrack			LDR			R2,R2,#0		( go to next entry )
						BRnzp		_FIND_loop
						
_FIND_fail				AND			R3,R3,#0		( Not found, return 0 )

_FIND_end				LD			R7,FIND_CB
						LD			R6,FIND_R6
						LD			R5,FIND_R5
						LD			R4,FIND_R4
						RET

FIND_CB					.BLKW		1
FIND_R6					.BLKW		1
FIND_R5					.BLKW		1
FIND_R4					.BLKW		1
FIND_base				.BLKW		1
}
#primitive >CFA TCFA
{
						JSR			POP_R0
						JSR			_TCFA
						JSR			PUSH_R0
						JSR			NEXT
						
_TCFA					AND			R1,R1,#0
						ADD			R0,R0,#1			( skip link pointer )
						LDR			R1,R0,#0			( load flags + len )
						LD			R2,F_LENMASK		( load lenmask )
						AND			R1,R1,R2			( mask length )
						ADD			R0,R0,#2			( skip length pointer and null terminator )
						ADD			R0,R0,R1			( skip length )
						RET
}
#primitive PARSE_ERROR PARSE_ERROR
{
						LEA			R0,const_PARSE_ERROR
						JSR			PUSH_R0
						JSR			NEXT
const_PARSE_ERROR		.STRINGZ	"\nUNKNOWN WORD"
}
#primitive EXECUTE EXECUTE
{
						JSR			POP_R3
						LDR			R2,R3,#0		( Load data at address -- this holds the next codeword )
						JMP			R2				( jump there -- NEXT will work from that point )
}
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
#primitive (HEADER) _HEADER
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