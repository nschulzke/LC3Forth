: DECIMAL 10 BASE ! ;
: BINARY 2 BASE ! ;
: HEX 16 BASE ! ;

: '0' [ KEY 0 ] LITERAL ;
: 'A' [ KEY A ] LITERAL ;
: '-' [ KEY - ] LITERAL ;
: '"' [ KEY " ] LITERAL ;
: ':' [ KEY : ] LITERAL ;
: ';' [ KEY ; ] LITERAL ;
: '.' [ KEY . ] LITERAL ;
: CR 10 EMIT ;
: TAB 9 EMIT ;
: SPACE	32 EMIT ;

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
		'0'
	ELSE
		10 -
		'A'
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
		'-' EMIT
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
	CR				\ newline to finish
;

: LOCATE
	BASE @
	WORD FIND
	HEX
	. CR
	BASE !
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
	STATE @ IF			\ Are we compiling?
		' LITSTRING ,	\ append LITSTRING
		HERE @			( addr )
		0 ,				\ we don't yet know length, dummy value
		BEGIN
			KEY			\ next char
			DUP '"'
		<> WHILE		\ as long as not close quote, continue
			,			\ compile character
		REPEAT
		DROP			\ drop the final double quote
		DUP				( addr addr )
		HERE @ SWAP -	( addr length+1 ) \ we measured from length word
		1-				( addr length )
		SWAP !			\ store length at location, empty stack
	ELSE
		HERE @			( addr )
		BEGIN
			KEY			\ same as above
			DUP '"'
		<> WHILE
			OVER !		\ store char @ addr
			1+			( addr+1 )
		REPEAT
		DROP			\ drop final " ( addr )
		HERE @ -		\ calculate length
		HERE @			( len addr )
		SWAP			( addr len )
	THEN
; \ NOTE: HERE is not updated if not in compile mode, so very temporary

: ." IMMEDIATE
	STATE @ IF			\ are we compiling?
		[COMPILE] S"	\ get the string
		' TELL ,		\ compile TELL
	ELSE
		[COMPILE] S"	\ if not compiling, run S"
		CR				\ and print out the string when done
		TELL
		CR
	THEN
;

( addr len -- )
: DUMP
	BASE @ -ROT		( base addr len ) \ so we can get it later
	HEX
	
	BEGIN
		?DUP		\ while len > 0 )
	WHILE
		OVER 4 U.R	\ print address padded to 4
		TAB TAB
		
		( hex values, 8 per line )
		2DUP			( addr len addr len )
		1- 7 AND 1+		( addr len addr linelen )
		BEGIN
			?DUP		\ as long as linelen > 0
		WHILE
			SWAP		( addr len linelen addr )
			DUP @		( addr len linelen addr data )
			4 .R SPACE	\ print the data
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
				DROP '.' EMIT
			THEN
			1+ SWAP 1-	( addr len linelen addr -- addr len addr+1 linelen-1 )
		REPEAT
		DROP			( addr len )
		CR
		
		DUP 1- 7 AND 1+		( addr len linelen )
		TUCK				( addr linelen len linelen )
		-					( addr linelen len-linelen )
		-ROT +				( len-linelen addr+linelen )
		SWAP				( addr+linelen len-linelen )
	REPEAT		\ And now we're ready to loop back
	
	DROP		( base )
	BASE !		\ back to how we found it
;

: SEE
	WORD FIND		\ Get the word
	?DUP IF
		\ Search the stack for the next word to get the length
		HERE @			( word last ) \ last word
		LATEST @		( word last curr )
		BEGIN
			2 PICK		( word last curr word )
			OVER		( word last curr word curr )
			<>			( word last curr word<>curr? )
		WHILE			( word last curr )
			NIP			( word curr )
			DUP @		( word curr prev )
		REPEAT
		
		DROP SWAP		( end-of-word start-of-word )
		
		\ start with ": NAME [IMMEDIATE] "
		':' EMIT SPACE DUP ID. SPACE
		DUP ?IMMEDIATE IF ." IMMEDIATE " THEN
		
		>DFA			( end start )
		BEGIN
			2DUP >		\ as long as we haven't hit end
		WHILE
			DUP @		( end start word )
		
			CASE
				' LIT OF
					1+ DUP @ .  \ if LIT, print the literal value
				ENDOF
				' LITSTRING OF
					[ KEY S ] LITERAL EMIT '"' EMIT SPACE \ print 'S" '
					1+ DUP @		( end lenAddr len )
					SWAP 1+ SWAP	( end addr len )
					2DUP TELL		\ print the string
					'"' EMIT SPACE	\ final quote and space
					+				( end addr+len )
					1-				\ we're going to add 1 again below
				ENDOF
				' 0BRANCH OF
					." 0BRANCH ( "
					1+ DUP @ .		\ print offset
					." ) "
				ENDOF
				' BRANCH OF
					." BRANCH ( "
					1+ DUP @ .		\ print offset
					." ) "
				ENDOF
				' ' OF
					[ KEY ' ] LITERAL EMIT SPACE
					1+ DUP @		\ get the next word
					CFA> ID. SPACE	\ and print the next name
				ENDOF
				' EXIT OF
					2DUP			( end start end start )
					1+				( end start end start+1 )
					<> IF
						." EXIT "	\ if it's not the last EXIT, print it
					THEN
				ENDOF
				\ If it's not a special case above
				( end start )
				DUP CFA> ID. SPACE		\ print the word
			ENDCASE
			1+	( end start+1 )
		REPEAT
		';' EMIT CR
		DROP DROP
	ELSE
		." UNKNOWN WORD" CR
	THEN	\ ends IF found
;