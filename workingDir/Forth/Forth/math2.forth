
( A B -- GCD )
: GCD
	?DUP UNLESS		\ if B = zero
		EXIT		\ leave A on the stack
	THEN
	SWAP ?DUP UNLESS	\ if A = zero
		EXIT		\ leave B on the stack
	THEN SWAP
	TUCK			\ ( B A B )
	MOD				\ ( B R )
	RECURSE
;
