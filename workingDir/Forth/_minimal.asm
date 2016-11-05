#include Assembly\constants.asm

#include Assembly\stackops.asm
#include Assembly\memory.asm
#include Assembly\math.asm

#include Assembly\control.asm
#include Assembly\io.asm

#include Assembly\interpreter.asm
#include Assembly\variables.asm

#binary _stdLib.forth

: \ IMMEDIATE
	10 PARSE DROP DROP
;

: :
	HEADER
	DOCOL ,
	LATEST @
	HIDDEN
	]
;

: <;> IMMEDIATE
	[
	LIT_XT EXIT ,
	LATEST @
	HIDDEN
;

: HIDDEN
	1+			( lenAddr )
	DUP @		( lenAddr len )
	F_HIDDEN	( lenAddr len F_HIDDEN )
	XOR			( lenAddr lenNew )
	SWAP !		( clear stack, now hidden )
;

: IMMEDIATE IMMEDIATE
	LATEST @ 1+	( lenAddr )
	DUP @		( lenAddr len )
	F_IMMED		( lenAddr len F_IMMED )
	XOR			( lenAddr lenNew )
	SWAP !		( lenNew lenAddr )
;

( address -- immediate_flag : 0 if not set, not 0 if set )
: ?HIDDEN 1+ @ F_HIDDEN AND ;

( address -- immediate_flag : 0 if not set, not 0 if set )
: ?IMMEDIATE 1+ @ F_IMMED AND ;

: QUIT
	10 EMIT
	R0 RSP!
	FILELOC >IN !
	INTERPRET
	BRANCH
	<#-2>
;

: INTERPRET
	WORD
	OVER OVER					( addr len -- addr len addr len )
	FIND						( addr len -- wordAddr )
	DUP							( so we don't lose the address when we branch )
	0BRANCH						( If we didn't find the word, jump )
	<#21>
								( if we found it, we now have the address on the stack )
		SWAP DROP SWAP DROP		( Clean up the back of the stack so we just have the address )
		STATE @
		0BRANCH					( branch if not in compile mode )
		<#5>					( to EXECUTE, because we aren't compiling anything )
			DUP ?IMMEDIATE		( dup addr, check if an immediate word )
			0BRANCH				( branch if not immediate )
			<#5>				( go to >CFA )
				>CFA EXECUTE	( execute the address )
			BRANCH				( skip compiling if we already executed )
			<#3>				( skip to the next branch )
				>CFA ,			( compile if: in compile mode & not F_IMMED )
	BRANCH
	<#26>					( skip if we found the entry, this is ELSE block )
		DROP				( we don't care about the extra 0 on the stack for the address )
		NUMBER				( addr len -- num err )
		0BRANCH				( if err == 0, we found a number! )
		<#14>
			DROP PARSE_ERROR EMITS  ( Not a number, emit a parse error and drop the number )
			>IN @
			0BRANCH
			<#5>
				0 >IN !
		BRANCH
		<#9>
			STATE @
			0BRANCH				( branch if not in compile mode )
			<#5>
				LIT_XT LIT ,		( compile LIT )
				,				( compile the number )
			( if we're not in compile mode, we don't need to do anything, the number is on the stack )
;
