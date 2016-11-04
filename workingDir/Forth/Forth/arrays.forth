( -- start size )
: ARRAY
	CREATE
	DUP ,		\ store the number of indices
	ALLOT		\ allot the number of cells
	DOES>
	DUP 1+		\ get the first index
	SWAP @		\ get the number of indices
;

( addr u -- )
: ARRAY.
	." [ "
	0 ?DO
		DUP @
		. ." , "
		1+
	LOOP
	DROP
	." ] "
;

( size index -- flag )
: ?INDEX
	TUCK >		( index flag )
	SWAP 0>=	( flag flag )
	AND
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