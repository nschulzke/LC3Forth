( n_u ... n_1 n_0 u -- n_u .. n_1 n_0 u )
: PICK
	1+			( u -- u+1 )
	DSP@ SWAP -	( u+1 -- DSP-(u+1) )
	DUP S0 > IF	( make sure we're not underflowing )
		@		( addr -- val )
	ELSE
		DROP 0	( addr -- 0 )
	THEN
;

( A N -- A A A ... N times )
: DUP_TIMES
	DUP 1 = IF		\ If times = 1
		DROP EXIT	\ Then just drop the times and return
	THEN
	1-				\ Otherwise, subtract one
	BEGIN
		OVER -ROT	( A N -- A A N )
		1- DUP		( A N -- A N N )
	0<= UNTIL		\ While N > 0
	DROP
;