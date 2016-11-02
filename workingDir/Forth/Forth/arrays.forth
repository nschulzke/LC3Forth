( addr u char -- )
: FILL
	SWAP			( addr char u )
	0 ?DO
		OVER I +	( addr char addr+i )
		OVER SWAP !	( addr char )
	LOOP
	2DROP
;

( -- start size )
: ARRAY
	CREATE
	DUP ,		\ store the number of indices
	DUP ALLOT	\ allot the number of cells
	DOES>
	DUP 1+		\ get the first index
	SWAP @		\ get the number of indices
;

( addr u -- )
: .ARRAY
	." [ "
	0 ?DO
		DUP @
		. ." , "
		1+
	LOOP
	DROP
	." ] "
;
