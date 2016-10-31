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

: ?NL
	DELAYED_NL @
	IF
		CR
		0 DELAYED_NL !
	THEN
;

: SPACES
	DUP 0> IF
		0 DO
			SPACE
		LOOP
	ELSE
		DROP
	THEN
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
	DUP 0> IF
		0 DO
			[CHAR] 0 EMIT
		LOOP
	ELSE
		DROP
	THEN
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
		?DUP		\ link pointer not 0
	WHILE
		DUP ?HIDDEN	\ check if hidden
		NOT IF 		\ if not hidden
			DUP ID.	\ display name
			SPACE	\ and tabs to separate
		THEN
		@			\ jump to previous word
	REPEAT
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
	STATE @ IF				\ Are we compiling?
		POSTPONE LITSTRING	\ append LITSTRING
		HERE @				( addr )
		0 ,					\ we don't yet know length, dummy value
		BEGIN
			INPUT			\ next char
			DUP '"'	
		<> WHILE			\ as long as not close quote, continue
			,				\ compile character
		REPEAT
		DROP				\ drop the final double quote
		DUP					( addr addr )
		HERE @ SWAP -		( addr length+1 ) \ we measured from length word
		1-					( addr length )
		SWAP !				\ store length at location, empty stack
	ELSE
		HERE @				( addr )
		BEGIN
			INPUT			\ same as above
			DUP '"'
		<> WHILE
			OVER !			\ store char @ addr
			1+				( addr+1 )
		REPEAT
		DROP				\ drop final " ( addr )
		HERE @ -			\ calculate length
		HERE @				( len addr )
		SWAP				( addr len )
	THEN
; \ NOTE: HERE is not updated if not in compile mode, so very temporary

: ." IMMEDIATE
	POSTPONE S"			\ get the string
	STATE @ IF			\ are we compiling?
		POSTPONE TELL	\ compile TELL
	ELSE
		SPACE
		TELL			\ print out the string
	THEN
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