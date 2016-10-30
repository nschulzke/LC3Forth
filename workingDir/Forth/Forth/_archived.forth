
: WORDS
	0 LATEST
	BEGIN
		@ DUP @		\ while link pointer not 0
	WHILE
		DUP LENGTH	( len1 ptr len2 )
		ROT			( ptr len2 len1 )
		MAX			( ptr lenmax )
		SWAP		( lenmax ptr )
	REPEAT
	DROP
	
	LATEST				( lenmax ptr )
	BEGIN
		8 0 DO			( lenmax ptr )
			@ ?DUP		( lenmax ptr ptr )
			NOT IF			\ if our next pointer is zero
				DROP		\ drop lenmax
				2RDROP		\ get out of the loop
				EXIT
			THEN
			
			DUP ?HIDDEN		( lenmax ptr flag )
			NOT IF 			\ if not hidden
				DUP ID.		\ display name
				DUP LENGTH	( lenmax ptr len )
				ROT TUCK	( ptr lenmax len lenmax )
				SWAP -		( ptr lenmax lenmax-len )
				SPACES		( ptr lenmax )
				SWAP		( lenmax ptr )
			THEN
		LOOP
		CR
	AGAIN
;
