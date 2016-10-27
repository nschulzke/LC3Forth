: [COMPILE] IMMEDIATE
	WORD FIND
	>CFA ,
;

: >DFA >CFA 1+ ;

: LITERAL IMMEDIATE
	' LIT ,
	,
;

: RECURSE IMMEDIATE
	LATEST @
	>CFA ,
;

: CONSTANT
	WORD CREATE		\ Create the entry
	DOCOL ,			\ Append DOCOL
	' LIT ,			\ Append LIT
	,				\ Append the top of the stack
	' EXIT ,		\ And append EXIT
;

\ Gets the address of a newly allocated bit of memory
: ALLOT
	HERE @ SWAP		\ ( here n )
	HERE +!			\ ( adds n to here, old here is still on stack )
;

: VARIABLE
	1 ALLOT			\ get our memory location
	CONSTANT		\ create a contant pointing to the ALLOTed address
;

: HIDE WORD FIND HIDDEN ;

: DEPTH
	DSP@ S0 -	( depth )
;

: 2DUP
	OVER OVER
;

: 2DROP
	DROP DROP
;

#include control.forth
#include comments.forth

: FORGET
	WORD FIND			\ find the word
	DUP 0= UNLESS
		DUP @ LATEST !	\ make LATEST point to the word above it
		HERE !			\ and move our current data up to that point
	ELSE
		DROP
	THEN
;

( A B -- B )
: NIP SWAP DROP ;

( A B -- B A B )
: TUCK DUP -ROT ;
( n_u ... n_1 n_0 u -- n_u .. n_1 n_0 u )
: PICK
	1+			( u -- u+1 )
	DSP@ SWAP -	( u+1 -- DSP-(u+1) )
	DUP S0 > IF	( make sure we're not underflowing )
		@		( addr -- val )
	ELSE
		DROP 0	( addr -- 0 )
	THEN
;

( A N -- A A A ... N times )
: DUP_TIMES
	DUP 1 = IF		\ If times = 1
		DROP EXIT	\ Then just drop the times and return
	THEN
	1-				\ Otherwise, subtract one
	BEGIN
		OVER -ROT	( A N -- A A N )
		1- DUP		( A N -- A N N )
	0<= UNTIL		\ While N > 0
	DROP
;

( c a b WITHIN returns true if a <= c < b )
: WITHIN
	-ROT				( b c a )
	OVER			( b c a c )
	<= IF
		> IF		( b c -- )
			TRUE
		ELSE
			FALSE
		THEN
	ELSE
		DROP DROP	( b c -- )
		FALSE
	THEN
;

#include math.forth
#include io.forth

: CLEAR
	S0 DSP!
;

( limit index -- | -- limit index )
: DO
	R>				\ ( limit index pointer )
	-ROT SWAP		\ ( pointer index limit )
	>R >R >R		\ ( limit index pointer ) on return
;

: DO IMMEDIATE
	' DO ,
	[ HIDE DO ]
	[COMPILE] BEGIN
;

: LOOP
	R> R> R>		\ ( pointer index limit )
	SWAP			\ ( pointer limit index )
	1+ 2DUP 		\ ( pointer limit index limit index )
	<=				\ ( pointer limit index flag )
	-ROT SWAP		\ ( pointer flag index limit )
	>R >R			\ ( pointer flag | limit index )
	SWAP >R			\ ( flag | limit index pointer )
;

: LOOP IMMEDIATE
	' LOOP ,
	[ HIDE LOOP ]
	[COMPILE] UNTIL
	' R> , ' R> ,	\ clean up return stack
	' 2DROP ,
;

: INTERPRET
	[ HIDE INTERPRET ]
	BEGIN
		WORD
		OVER OVER					( addr len addr len )
		FIND						( addr len wordAddr )
		?DUP IF						\ If we didn't find the word, jump
			-ROT 2DROP				( wordAddr )
			DUP ?IMMEDIATE			( wordAddr F_IMMED )
			STATE @	NOT				( wordAddr F_IMMED STATE' )
			OR IF					\ is it execution mode or IMMED?
				>CFA EXECUTE		\ execute the address
			ELSE
				>CFA ,				\ compile if: in compile mode & not F_IMMED
			THEN
		ELSE
			NUMBER						( addr len -- num err )
			0= UNLESS					\ Unless there's no error
				DROP ." UNKNOWN WORD" CR
				KEYSOURCE @ IF			\ If we're running a file
					0 KEYSOURCE !		\ Abort so we can see the message
				THEN
			ELSE
				STATE @ IF			\ Are we compiling?
					' LIT ,			( compile LIT )
					,				( compile the number )
				THEN
			THEN		\ No else: if we're not compiling, the number is already on the stack
		THEN
	AGAIN
;

: QUIT
	[ HIDE QUIT ]
	R0 RSP!
	INTERPRET
;

1 CONSTANT VERSION

: WELCOME
	CLS
	." 	Welcome to version " VERSION . ." of LC3-FORTH!
	This FORTH was built as a class project by
	Nathan Schulzke for CS 2810. It functions as a
	complete operating system for the LC-3.
	
	Type WORDS to get a list of available commands.
	
	Enjoy!"
	CR
	CR
;

QUIT

HIDE LOAD
WELCOME