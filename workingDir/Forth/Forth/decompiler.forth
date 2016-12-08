: LOCATE
	NAME H.
;

( len -- linelen )
: .linelen
	8 /MOD			( len%8 len/8 )
	IF 8 NIP THEN
;

( start len -- start finish )
: .loop-setup
	.linelen		( start linelen )
	OVER + SWAP		( start finish )
;

( addr len -- )
: DUMP
	BEGIN
		?DUP			\ while len > 0 )
	WHILE
		CR
		
		OVER H.			\ print address padded to 4
		TAB TAB
		
		2DUP			( addr len addr len )
		.loop-setup		( addr len start finish )
		DO				( addr len )
			I @			( addr len data )
			H. SPACE	\ print the data
		LOOP
		
		TAB
		( ASCII equivalents )
		2DUP			( addr len addr len )
		.loop-setup		( addr len start finish )
		DO				( addr len )
			I @			( addr len char )
			32 128 WITHIN IF	\ 32 <= char < 128?
				I @ EMIT		\ Emit char
			ELSE
				[CHAR] . EMIT
			THEN
		LOOP
		
		DUP .linelen		( addr len linelen )
		TUCK				( addr linelen len linelen )
		-					( addr linelen len-linelen )
		-ROT +				( len-linelen addr+linelen )
		SWAP				( addr+linelen len-linelen )
	REPEAT		\ And now we're ready to loop back
;

HIDE .linelen
HIDE .loop-setup

: FORGET
	NAME			\ find the word
	?DUP 0= ABORT" Couldn't find word"
	DUP @ LATEST !	\ make LATEST point to the word above it
	DP !			\ and move our current data up to that point
;

( -- end start )
: BOUNDS
	NAME			\ Get the word
	
	?DUP 0= ABORT" Unknown word! "
	
	\ This loop finds the start of this word and of the next
	HERE			( word last ) \ last word
	LATEST @		( word last curr )
	BEGIN
		2 PICK		( word last curr word )
		OVER		( word last curr word curr )
		<>			( word last curr word<>curr? )
	WHILE			( word last curr )
		NIP			( word curr )
		DUP @		( word curr prev )
	REPEAT
	DROP			( start-of-word start-of-next )
	
	\ This loop finds the EXIT
	BEGIN
		2DUP <				\ are we still within range?
		OVER @ ['] EXIT <>	\ still no sign of EXIT?
		AND					\ iterate if both are true
	WHILE
		1-	( start-of-word location-1 )
	REPEAT
	\ At the end of this loop, if start and end are equal, then there's no EXIT.
	\ This means it's either a primitive or a CREATE word.
	SWAP	( end start )
;

: .seeword
	CASE
		['] LIT OF
			1+
			DUP	@ .  \ if LIT, print the literal value
		ENDOF
		['] LIT_XT OF
			." ['] "
			1+
			DUP @ XT> ID. SPACE
		ENDOF
		['] LITSTRING OF
			[CHAR] S EMIT '"' EMIT SPACE	\ print 'S" '
			1+ DUP @		( end lenAddr len )
			SWAP 1+ SWAP	( end addr len )
			2DUP TELL		\ print the string
			'"' EMIT SPACE	\ final quote and space
			+				( end addr+len )
			1-				\ we're going to add 1 again below
		ENDOF
		['] (DO) OF
			." DO "
			1+				\ skip offset
		ENDOF
		['] (?DO) OF
			." ?DO "
			1+				\ skip offset
		ENDOF
		['] (LOOP) OF
			." LOOP "
			1+				\ skip offset
		ENDOF
		['] (+LOOP) OF
			." LOOP "
			1+				\ skip offset
		ENDOF
		['] (LEAVE) OF
			." LEAVE "
			1+				\ skip offset
		ENDOF
		['] 0BRANCH OF
			." 0BRANCH ( "
			1+ DUP @ .		\ print offset
			." ) "
		ENDOF
		['] BRANCH OF
			." BRANCH ( "
			1+ DUP @ .		\ print offset
			." ) "
		ENDOF
		['] EXIT OF
			2DUP			( end start end start )
			1+				( end start end start+1 )
			<> IF
				." EXIT "	\ if it's not the last EXIT, print it
			THEN
		ENDOF
		\ If it's not a special case above
		( end start )
		DUP XT> ID. SPACE	\ print the word
	ENDCASE
;

: .notcolon
	>XT @
	DODAT = IF
		DUP >CODE @ XT> ID.
		DUP SPACE ID. ."  = "
		DUP >BODY @ .
	ELSE
		." CODE "
		DUP ID.	SPACE
		>XT @ H.
	THEN
;

: SEE
	BOUNDS			( end-of-word start-of-word )
	
	CR
	2DUP = IF		\ If start=end, then it's not a colon definition
		.notcolon	\ handle non-colon word
		EXIT		\ and leave
	THEN
	
	\ start with ": NAME [IMMEDIATE] "
	':' EMIT SPACE DUP ID. SPACE
	DUP IMMEDIATE? IF ." IMMEDIATE " THEN
	CR
	
	>CODE			( end start )
	BEGIN
		2DUP >		\ as long as we haven't hit end
	WHILE
		DUP @		( end start word )
		.seeword	( end start+offset )
		1+			( end start+offset+1 )
	REPEAT
	CR ';' EMIT SPACE
	
	2DROP
;

HIDE .notcolon
HIDE .seeword