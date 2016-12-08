VARIABLE KEYBUFFER 127 ALLOT

: SOURCE
	KEYBUFFER
	128
;

( bufferAddr char -- bufferAddr char )
: HANDLECHAR
	TUCK CASE		( char bufferAddr char )
		BKSP OF
			DUP KEYBUFFER >		( char addr addr>keybuffer? )
			IF					\ if we haven't hit the bottom of the buffer yet
				171 EMIT		\ Emit <<
				1-				( char addr-1 )
			THEN
			SWAP				( addr char )
			EXIT				\ Prevents storing of char
		ENDOF
		ESC OF
			167 EMIT			\ Emit ESC char
			QP @ EXECUTE		\ Restarts at QUIT
		ENDOF
		NL OF
			SPACE				( addr char )
		ENDOF
		DUP EMIT
	ENDCASE
	2DUP !		( char addr )
	1+ SWAP 	( addr+1 char )
;

( addr maxlen )
: ACCEPT
	0 >IN !
	DROP				( addr )
	\ We wont use the length: the spec says not to terminate when we reach it anyway...
	BEGIN
		KEY				( addr key )
		HANDLECHAR		( addr+1 key )
		NL =			( addr+1 flag )
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
HIDE BOOT

( addr len -- )
: ERROR" IMMEDIATE
	POSTPONE CR
	POSTPONE ."
	POSTPONE TELL
	POSTPONE ABORT
;

\ Compiles if in compile mode, otherwise executes
( wordAddr -- )
: ?COMPILE
	DUP IMMEDIATE?				( wordAddr F_IMMED )
	STATE @	NOT					( wordAddr F_IMMED STATE' )
	OR IF						\ is it execution mode or IMMED?
		>XT EXECUTE			\ execute the address
	ELSE
		>XT ,					\ compile if: in compile mode & not F_IMMED
	THEN
;

( addr len -- num | {ABORTS} )
: NUMBER?
	2DUP						( addr len addr len )
	NUMBER						( addr len num err )
	IF	\ if err				( addr len num )
		FALSE STATE !			\ No longer compiling ( if we were )
		DROP					( addr len )
		ERROR" Unknown word: " 	\ if there was an error, abort
	ELSE
		NIP NIP					( addr len num -- num )
	THEN
;

: INTERPRET
	BEGIN
		>IN @			( in )
		SKIP_BLANKS		( in+blanks )
		DUP >IN !		\ Store new >IN
		@				\ Keep going with WHILE until null-terminated
	WHILE
		WORD
		2DUP				( addr len addr len )
		FIND				( addr len wordAddr )
		?DUP IF				\ If we didn't find the word, jump
			-ROT 2DROP		( wordAddr )
			?COMPILE
		ELSE
			NUMBER?				\ returns num if valid, otherwise aborts
			STATE @ IF			\ Are we compiling?
				POSTPONE LIT ,	\ compile lit followed by the number found
			THEN				\ if we're not compiling, just leave the number on the stack
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
	>XT QP ! ]
	BEGIN
		PROMPT
		R0 RSP!
		SOURCE ACCEPT
		KEYBUFFER >IN !
		INTERPRET
		STATE @ 0= IF
			."  ok "
		THEN
	AGAIN
;

4 CONSTANT VERSION

: WELCOME
	PAGE
	TAB ." Welcome to version " VERSION . ." of LC3-FORTH!" CR
	TAB ." This FORTH was built as a final project by" CR
	TAB ." Nathan Schulzke for CS 2810. It functions as" CR
	TAB ." a shell interface for the LC-3." CR
	CR
	TAB ." Type WORDS to get a list of available commands." CR
	CR
	TAB ." Enjoy!"
	CR
	QUIT
;
