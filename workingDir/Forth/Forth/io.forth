( addr u char -- )
: FILL
	SWAP			( addr char u )
	0 ?DO
		OVER I +	( addr char addr+i )
		OVER SWAP !	( addr char )
	LOOP
	2DROP
;

( addr1 addr2 u -- )
: MOVE
	0 ?DO
		OVER I + @	( addr1 addr2 val[i] )
		OVER I + !	( addr1 addr2 )
	LOOP
	2DROP
;

: [CHAR] IMMEDIATE INPUT POSTPONE LITERAL ;
: '"' [CHAR] " ;
: ':' [CHAR] : ;
: ';' [CHAR] ; ;
10 CONSTANT NL
9 CONSTANT TB
32 CONSTANT BL
8 CONSTANT BKSP
27 CONSTANT ESC
: CR NL EMIT ;
: TAB TB EMIT ;
: SPACE	BL EMIT ;

: SPACES
	BEGIN
		DUP 0>
	WHILE
		SPACE
		1-
	REPEAT
	DROP
;

( u -- )
: U.
	BASE @ /MOD		( rem quot )
	?DUP IF			\ only dup if quot <> 0, then check )
		RECURSE		\ keep going
	THEN
	
	\ print the remainder
	DUP 10 < IF		\ if less than 10, then digits
		[CHAR] 0
	ELSE
		10 -
		[CHAR] A
	THEN
	+
	EMIT
;

: UWIDTH
	BASE @ /
	?DUP IF				\ If we have further to go
		RECURSE 1+		\ Then return the recursive value +1
	ELSE
		1				\ Otherwise just 1
	THEN
;

: U.R			( u width )
	SWAP		( width u )
	DUP			( width u u )
	UWIDTH		( width u uwidth )
	ROT			( u uwidth width )
	SWAP -		( u width-uwidth ) \ width - uwidth is padding
	SPACES
	U.
;

: U.0			( u width )
	SWAP		( width u )
	DUP			( width u u )
	UWIDTH		( width u uwidth )
	ROT			( u uwidth width )
	SWAP -		( u width-uwidth ) \ width - uwidth is padding
	
	BEGIN
		DUP 0>
	WHILE
		[CHAR] 0 EMIT
		1-
	REPEAT
	DROP
	U.
;


: .R			( n width -- )
	SWAP		( width n )
	DUP 0< IF	\ if negative
		NEGATE	( width u )
		TRUE	( width u flag )
		-ROT	( flag width u )
		SWAP	( flag u width )
		1-		( flag u width-1 )
	ELSE
		FALSE	( width u flag )
		-ROT	( flag width u )
		SWAP	( flag u width )
	THEN
	SWAP DUP	( flag width u u )
	UWIDTH		( flag width u uwidth )
	ROT			( flag u uwidth width )
	SWAP -		( flag u width-uwidth ) \ padding
	
	SPACES		( flag u )
	SWAP		( u flag )
	
	IF
		[CHAR] - EMIT
	THEN
	
	U.
;

: . 0 .R SPACE ;
: U. U. [ HIDE U. ] SPACE ;

HEX
: B.
	BASE @ SWAP
	BINARY

	8000		( num mask )
	BEGIN
		2DUP	( num mask num mask )
		AND		( num mask masked )
		IF [CHAR] 1 EMIT ELSE [CHAR] 0 EMIT THEN
		1 RSHIFT
		DUP 0=
	UNTIL
	2DROP

	SPACE
	BASE !
;

( num -- )
: H.
	BASE @ SWAP
	HEX
	
	DUP 0< IF
		000F 0 >R >R	\ Format: mask shift
		00F0 4 >R >R	\ Highest digit last
		0F00 8 >R >R	\ Lowest digit first
		F000 C >R >R	\ We do this because RSHIFT has an overhead
		BEGIN
			DUP			( num num )
			R> AND		( num masked )
			R> TUCK		( num shifts masked shifts )
			RSHIFT		( num shifts digit )
			0 U.0		( num shifts )
			0=
		UNTIL
		DROP
	ELSE
		4 U.0 SPACE
	THEN
	
	BASE !
;
DECIMAL

: ? @ . ;

: .S
	DSP@ S0			( dsp S0<addr> )
	BEGIN
		2DUP >		( dsp addr dsp>addr )
	WHILE
		1+			( dsp addr+1 )
		DUP @		( dsp addr+1 data )
		.			( dsp addr+1 ) \ output number
	REPEAT
	2DROP
;

25 CONSTANT ROWS

: PAGE
	ROWS 1 DO
		CR
	LOOP
;

: ID.
	2 +				\ skip link pointer and length
	EMITS			\ in this forth names are null-terminated, use EMITS
;

: WORDS
	LATEST @
	BEGIN
		DUP	@		( pointer next )
	WHILE
		DUP HIDDEN?	\ check if hidden
		NOT IF 		\ if not hidden
			DUP ID.	\ display name
			SPACE	\ and tabs to separate
		THEN
		@			\ jump to previous word
	REPEAT
	DROP
;

( addr len -- )
: TELL
	SWAP	( len addr )
	BEGIN
		DUP @ EMIT	\ emit the char at location
		1+			\ move forward
		SWAP 1-		( addr count )	\ decrement counter
		TUCK		( count addr count )
	0<= UNTIL
	2DROP			\ cleanup stack
;

: S" IMMEDIATE
	[CHAR] " PARSE			( addr len )
	STATE @ IF				\ Are we compiling?
		POSTPONE LITSTRING	\ append LITSTRING
		DUP ,				\ compile length
		HERE SWAP			( addr here len )
		DUP DP +!
		MOVE				\ move the string from the buffer to the definition
	THEN
; \ NOTE: HERE is not updated if not in compile mode, so very temporary

: ." IMMEDIATE
	STATE @ IF			\ are we compiling?
		POSTPONE S"		\ get the string
		POSTPONE TELL	\ compile TELL
	THEN
;

: .( IMMEDIATE
	[CHAR] ) PARSE TELL
;

: ( IMMEDIATE
	[CHAR] ) PARSE 2DROP
;

: ABORT
	S0 DSP!
	QP @ EXECUTE
;

: ABORT" IMMEDIATE
	POSTPONE IF
	POSTPONE CR
	POSTPONE ."
	POSTPONE SPACE
	POSTPONE ABORT
	POSTPONE THEN
;