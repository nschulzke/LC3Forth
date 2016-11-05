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

: FORGET
	WORD FIND			\ find the word
	?DUP 0= ABORT" Couldn't find word"
	DUP @ LATEST !	\ make LATEST point to the word above it
	DP !			\ and move our current data up to that point
;

: BOUNDS
	WORD FIND		\ Get the word

	?DUP 0= ABORT" Unknown word! "
	
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
	
	BEGIN
		2DUP <				\ are we still within range?
		IF 1 ELSE 0 THEN
		OVER @ ['] EXIT <>		\ still no sign of EXIT?
		IF 1 ELSE 0 THEN
		AND
	WHILE
		1-			( start-of-word location-1 )
	REPEAT
;

: (SEE)
	CASE
		['] LIT OF
			1+
			DUP	@ .  \ if LIT, print the literal value
		ENDOF
		['] LIT_XT OF
			." ['] "
			1+					
			DUP @ CFA> ID. SPACE
		ENDOF
		['] LITSTRING OF
			[CHAR] S EMIT '"' EMIT SPACE \ print 'S" '
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
		DUP CFA> ID. SPACE	\ print the word
	ENDCASE
;

: SEE
	BOUNDS
	
	CR
	
	2DUP
	= IF
		>CFA @
		DODAT = IF
			DUP >DFA @ CFA> ID.
			DUP SPACE ID. ."  = "
			DUP >DFA 1+ @ .
		ELSE
			." CODE "
			DUP ID.	SPACE
			>CFA @ H.
		THEN
		EXIT
	THEN		
	
	SWAP		( end-of-word start-of-word )
	
	\ start with ": NAME [IMMEDIATE] "
	':' EMIT SPACE DUP ID. SPACE
	DUP ?IMMEDIATE IF ." IMMEDIATE " THEN
	
	>DFA			( end start )
	BEGIN
		2DUP >		\ as long as we haven't hit end
	WHILE
		DUP @		( end start word )
		(SEE)
		1+			( end start+1 )
	REPEAT
	';' EMIT SPACE
	2DROP
;