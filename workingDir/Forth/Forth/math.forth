: DECIMAL 10 BASE ! ;
: BINARY 2 BASE ! ;
: HEX 16 BASE ! ;

( c a b WITHIN returns true if a <= c < b )
: WITHIN
	-ROT				( b c a )
	OVER			( b c a c )
	<= IF
		> IF		( b c -- )
			TRUE
		ELSE
			FALSE
		THEN
	ELSE
		DROP DROP	( b c -- )
		FALSE
	THEN
;

: NEGATE 0 SWAP - ;

( A -- |A| )
: ABS
	DUP				( A A )
	0< IF			( A )
		NEGATE		( -A )
	THEN
;

: /
	/MOD NIP
;

: MOD
	/MOD DROP
;

: 2*
	DUP +	\ faster than multiplication
;

: 2/
	2 /
;

: LSHIFT
	?DUP IF
		0 DO
			2*
		LOOP
	THEN
;

HEX
( num times )
: RSHIFT
	?DUP IF
		SWAP			( times num )
		
		DUP 0<			( times num flag )
		IF				\ If it was negative
			8000 XOR	\ different than ABS, take off a bit
			2/
			4000 OR		( times num )	\ restore missing bit
		ELSE
			2/
		THEN
		
		SWAP 1-			\ We did it once, get ready to loop
		?DUP IF
			0 DO
				2/
			LOOP
		THEN
	THEN
;
DECIMAL

( a b -- MIN(a,b) )
: MIN
	2DUP		( a b a b )
	< IF		\ if a < b
		DROP
	ELSE
		SWAP DROP
	THEN
;

( a b -- MIN(a,b) )
: MAX
	2DUP		( a b a b )
	> IF		\ if a > b
		DROP
	ELSE
		SWAP DROP
	THEN
;