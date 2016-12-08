( size index -- flag )
: ?INDEX
	TUCK >		( index flag )
	SWAP 0>=	( flag flag )
	AND
;

( addr len -- end begin )
: FOREACH
	OVER + SWAP		( addr+len addr )
;

( -- start size )
: ARRAY
	CREATE
	DUP ,		\ store the number of indices
	ALLOT		\ allot the number of cells
	DOES>
	DUP 1+		\ get the first index
	SWAP @		\ get the number of indices
;

( addr len -- )
: ARRAY.
	FOREACH ?DO
		I @ .
	LOOP
;

( addr size val index -- )
: ARRAY!
	ROT OVER		( addr val index u index )
	?INDEX IF		( addr val index )
		ROT +		( val index+addr )
		!
	ELSE
		ABORT" Index out of bounds!"
	THEN
;

( addr size index )
: ARRAY@
	TUCK			( addr index u index )
	?INDEX IF		( addr index )
		+ @			( val )
	ELSE
		ABORT" Index out of bounds!"
	THEN
;

( addr1 addr2 -- )
: SWAP!
	OVER @ OVER @	( addr1 addr2 mem1 mem2 )
	-ROT			( addr1 mem2 addr2 mem1 )
	SWAP !
	SWAP !
;

( addr len -- )
: ARRAY-SORT
	BEGIN
		2DUP FALSE -ROT	( addr len flag addr len )
		FOREACH 1+		( addr len flag end begin )
		DO	( flag )
			I 1- @
			I @		( flag mem[i-1] mem[i] )
			> DUP IF ( flag flag )
				I 1- I SWAP!
			THEN
			OR
		LOOP
	0=
	UNTIL
	2DROP
;