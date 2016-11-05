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
: CR NL EMIT ;
: TAB TB EMIT ;
: SPACE	BL EMIT ;

24 CONSTANT ROWS

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

: CLS
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
		DUP ?HIDDEN	\ check if hidden
		NOT IF 		\ if not hidden
			DUP ID.	\ display name
			SPACE	\ and tabs to separate
		THEN
		@			\ jump to previous word
	REPEAT
	DROP
;

( cfa -- addr )
: CFA>
	LATEST @		\ start here
	BEGIN
		?DUP		\ as long as the link pointer isn't 0
	WHILE
		2DUP SWAP	( cfa curr curr cfa )
		< IF		( curr cfa -- ) \ have we reached it?
			NIP		( cfa curr -- curr )
			EXIT
		THEN
		@			( back up )
	REPEAT
	DROP			( cfa curr -- cfa )
	0				( cfa -- cfa 0 )
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
	QUITPTR @ EXECUTE
;

: ABORT" IMMEDIATE
	POSTPONE IF
	POSTPONE CR
	POSTPONE ."
	POSTPONE SPACE
	POSTPONE ABORT
	POSTPONE THEN
;

HEX
: H.
	BASE @ SWAP		( base num )
	HEX
	
	DUP 0< IF
		F			( num mask )
		BEGIN
			2DUP		( num mask num mask )
			AND			( num mask masked )
			-ROT		( masked num mask )
			4 LSHIFT	( masked num newmask )
			DUP 0=
		UNTIL
		2DROP
		
		C 8 4 0
		>R >R >R >R
		
		( m_0 m_1 m_2 m_3 )
		BEGIN
			R> TUCK		( n m n )
			RSHIFT		( n out )
			0 U.0
			0=
		UNTIL
		SPACE
	ELSE
		4 U.0 SPACE
	THEN
	BASE !
;
DECIMAL

: LOCATE
	WORD FIND
	H. SPACE
;

( addr len -- )
: DUMP
	BEGIN
		?DUP		\ while len > 0 )
	WHILE
		CR
		
		OVER H.		\ print address padded to 4
		TAB TAB
		
		( hex values, 8 per line )
		2DUP			( addr len addr len )
		1- 7 AND 1+		( addr len addr linelen )
		BEGIN
			?DUP		\ as long as linelen > 0
		WHILE
			SWAP		( addr len linelen addr )
			DUP @		( addr len linelen addr data )
			H. SPACE	\ print the data
			1+ SWAP 1-	( addr len linelen addr -- addr len addr+1 linelen-1 )
		REPEAT
		DROP			( addr len )
		
		TAB TAB
		( ASCII equivalents )
		2DUP			( addr len addr len )
		1- 7 AND 1+		( addr len addr linelen )
		BEGIN
			?DUP
		WHILE
			SWAP		( addr len linelen addr )
			DUP @		( addr len linelen addr data )
			DUP 32 128 WITHIN IF		( 32 <= char < 128? )
				EMIT
			ELSE
				DROP [CHAR] . EMIT
			THEN
			1+ SWAP 1-	( addr len linelen addr -- addr len addr+1 linelen-1 )
		REPEAT
		DROP			( addr len )
		
		DUP 1- 7 AND 1+		( addr len linelen )
		TUCK				( addr linelen len linelen )
		-					( addr linelen len-linelen )
		-ROT +				( len-linelen addr+linelen )
		SWAP				( addr+linelen len-linelen )
	REPEAT		\ And now we're ready to loop back
;