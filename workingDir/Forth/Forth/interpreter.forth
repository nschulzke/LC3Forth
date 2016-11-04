VARIABLE KEYBUFFER 127 ALLOT

: SOURCE
	KEYBUFFER
	128
;

( addr maxlen )
: ACCEPT
	0 >IN !
	DROP				( addr )
	\ We wont use the length: the spec says not to terminate when we reach it anyway...
	BEGIN
		KEY				( addr key )
		DUP 8 = IF		\ backspace functionality
			171 EMIT			\ Emit <<
			SWAP				( key addr )
			DUP KEYBUFFER >		( addr addr>keybuffer? )
			IF			\ if we haven't hit the bottom of the buffer yet
				1 -
			THEN
			SWAP				( addr-1 key )
		ELSE
			DUP NL = UNLESS
				DUP EMIT
			ELSE SPACE THEN
			2DUP SWAP !		( addr key )
			SWAP 1+ SWAP 	( addr+1 key )
		THEN
		NL =
	UNTIL
	0 SWAP !			\ null terminator
;

: BLANK?
	( char -- flag )
	DUP NL = SWAP	( flag char )
	DUP BL = SWAP	( flag flag char )
	TB =			( flag flag flag )
	OR OR			( flag )
;

: SKIP_BLANKS
	( pointer -- pointer2 )
	BEGIN
		DUP @		( pointer char )
		BLANK?
	WHILE
		1+
	REPEAT
;

HIDE INTERPRET
HIDE QUIT

: INTERPRET
	BEGIN
		>IN @
		SKIP_BLANKS
		DUP >IN !
		@
	WHILE
		WORD
		OVER OVER						( addr len addr len )
		FIND							( addr len wordAddr )
		?DUP IF							\ If we didn't find the word, jump
			-ROT 2DROP					( wordAddr )
			DUP ?IMMEDIATE				( wordAddr F_IMMED )
			STATE @	NOT					( wordAddr F_IMMED STATE' )
			OR IF						\ is it execution mode or IMMED?
				>CFA EXECUTE			\ execute the address
			ELSE
				>CFA ,					\ compile if: in compile mode & not F_IMMED
			THEN
		ELSE
			2DUP						( addr len addr len )
			NUMBER						( addr len num err )
			IF	\ if err				( addr len num )
				DROP					( addr num )
				CR ." Unknown word: " TELL	\ if there was an error, abort
				ABORT
			ELSE
				NIP NIP					( addr len num -- num )
			THEN
			STATE @ IF				\ Are we compiling?
				POSTPONE LIT ,		\ compile lit followed by the number found
			THEN					\ if we're not compiling, just leave the number on the stack
		THEN
	REPEAT
;

: PROMPT
		CR
		STATE @ IF
			SPACE SPACE
		ELSE
			." > "
		THEN
;

: QUIT
	[ LATEST @
	>CFA QUITPTR ! ]
	BEGIN
		PROMPT
		R0 RSP!
		SOURCE ACCEPT
		KEYBUFFER >IN !
		INTERPRET
		STATE @ 0= IF
			SPACE ." ok "
		THEN
	AGAIN
;

3 CONSTANT VERSION

: WELCOME
	CLS
	." 	Welcome to version " VERSION . ." of LC3-FORTH!
	This FORTH was built as a class project by
	Nathan Schulzke for CS 2810. It functions as a
	complete operating system for the LC-3.
	
	Type WORDS to get a list of available commands.
	
	Enjoy!"
	CR
	QUIT
;