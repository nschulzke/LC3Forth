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
	DUP 0= IF
		DROP DROP
		0 EXIT		\ return 0
	THEN
	DUP 1 = IF
		DROP EXIT	\ return A
	THEN
	
	DUP	0< -ROT		( S A B )
	ABS				( S A |B| )
	DUP >R			( ret: |B| )
	DUP_TIMES		( S A A A ... )
	R>				( S A ... A A |B| )
	1-
	BEGIN			( S A ... A A |B| )
		-ROT		( S A ... |B| A A )
		+			( S A ... |B| A+A )
		SWAP		( S A ... A+A |B| )
		1-
		DUP 0<=		\ While we haven't hit zero
	UNTIL
	DROP
	SWAP			\ Get sign
	IF NEGATE THEN	\ If sign is TRUE, then it was Negative
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