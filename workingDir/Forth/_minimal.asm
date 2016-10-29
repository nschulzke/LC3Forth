#include constants.asm

#include stackops.asm
#include math.asm

#include memory.asm
#include io.asm

#include interpreter.asm
#include variables.asm

#binary _stdLib.forth

: LOAD
	FILELOC KEYSOURCE !
	1 LOADING !
;

: HEADER
	WORD (HEADER)
	DOCOL ,
;

: :
	HEADER
	LATEST @
	HIDDEN
	]
;

: <;> IMMEDIATE
	[
	' EXIT ,
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

: QUIT
	R0 RSP!
	INTERPRET
	BRANCH
	<#-2>
;

( address -- immediate_flag : 0 if not set, not 0 if set )
: ?IMMEDIATE 1+ @ F_IMMED AND ;

( address -- immediate_flag : 0 if not set, not 0 if set )
: ?HIDDEN 1+ @ F_HIDDEN AND ;

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
			KEYSOURCE @
			0BRANCH
			<#5>
				0 KEYSOURCE !
		BRANCH
		<#9>
			STATE @
			0BRANCH				( branch if not in compile mode )
			<#5>
				' LIT ,			( compile LIT )
				,				( compile the number )
			( if we're not in compile mode, we don't need to do anything, the number is on the stack )
;
