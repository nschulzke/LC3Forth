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

( A B -- A*B )
: *
	?DUP UNLESS
		DROP		\ drop A
		0 EXIT		\ return 0
	THEN
	
	DUP 1 = IF
		DROP EXIT	\ return A
	THEN
	
	DUP	0< -ROT		( S A B )
	ABS				( S A |B| )
	
	OVER SWAP		( S A A |B| )
	1 DO
		OVER +		( S A A+A )
	LOOP
	SWAP DROP		( S A*B )

	SWAP IF NEGATE THEN		\ If sign is TRUE, then it was Negative
;

: 2*
	2 *
;

: 2/
	2 /
;

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