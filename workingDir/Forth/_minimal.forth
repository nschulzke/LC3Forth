#include _minimal.asm

: IF IMMEDIATE
	' 0BRANCH ,
	HERE @			( ifAddress )
	0 ,				( dummy offset of 0 until told otherwise )
;

: ELSE IMMEDIATE
	' BRANCH ,		( branch around the false )
	HERE @			( ifAddress -- ifAddress elseAddress )
	0 ,				( dummy offset )
	SWAP			( ifAddress elseAddress -- elseAddress ifAddress )
	DUP				( duplicate ifAddress for subtraction )
	HERE @ SWAP -	( get the offset to the current location [beginning of false part] )
	SWAP !			( store the offset in the location that was saved )
;

: THEN IMMEDIATE
	DUP				( duplicate the HERE from the stack )
	HERE @ SWAP -	( ifOrElseAddress ifOrElseAddress -- ifOrElseAddress offset )
	SWAP !			( ifOrElseAddress offset -- ) ( store the offset in the variable )
;

: 2DUP
	OVER OVER
;

: CR
	10 EMIT
;

: NEGATE
	NOT 1+
;

: :
	WORD CREATE
	DOCOL ,
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

( nondestructive display of stack in binary )
: .S
	DSP@		( dsp )
	S0			( dsp S0<addr> )
	OVER OVER	( dsp addr dsp addr )
	>			( dsp addr dsp>addr )
	0BRANCH		( dsp addr )
	<#8>		( if dsp > addr [we haven't hit the top yet] then keep going, otherwise skip to end )
	1+			( dsp addr+1 )
	DUP @		( dsp addr+1 data )
	.B CR		( dsp addr+1 ) ( output binary )
	BRANCH
	<#-11>		( back to first DUP )
	DROP DROP	( clean up after ourselves )
;

: CLEAR
	S0 DSP!
;

: QUIT
	R0 RSP!
	INTERPRET
	BRANCH
	<#-2>
;

( A B -- B )
: NIP SWAP DROP ;

( address -- immediate_flag : 0 if not set, not 0 if set )
: NOT_IMMED 1+ @ F_IMMED AND ;

: INTERPRET
	WORD
	OVER OVER					( addr len -- addr len addr len )
	FIND						( addr len -- wordAddr )
	DUP							( so we don't lose the address when we branch )
	0BRANCH						( If we didn't find the word, jump )
	<#19>
								( if we found it, we now have the address on the stack )
		NIP NIP					( Clean up the back of the stack so we just have the address )
		STATE @
		0BRANCH					( branch if not in compile mode )
		<#5>					( to EXECUTE, because we aren't compiling anything )
			DUP NOT_IMMED		( dup addr, check if an immediate word )
			0BRANCH				( branch if not immediate )
			<#5>				( go to >CFA )
				>CFA EXECUTE	( execute the address )
			BRANCH				( skip compiling if we already executed )
			<#3>				( skip to the next branch )
				>CFA ,			( compile if: in compile mode & not F_IMMED )
	BRANCH
	<#18>					( skip if we found the entry, this is ELSE block )
		DROP				( we don't care about the extra 0 on the stack for the address )
		NUMBER				( addr len -- num err )
		0BRANCH				( if err == 0, we found a number! )
		<#6>
			DROP PARSE_ERROR EMITS  ( Not a number, emit a parse error and drop the number )
		BRANCH
		<#9>
			STATE @
			0BRANCH				( branch if not in compile mode )
			<#5>
				' LIT ,			( compile LIT )
				,				( compile the number )
			( if we're not in compile mode, we don't need to do anything, the number is on the stack )
;
