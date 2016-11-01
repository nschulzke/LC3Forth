: CLEAR
	S0 DSP!
;

\ ( -- depth )
: DEPTH
	DSP@ S0 -	( depth )
;

( A B -- B )
: NIP SWAP DROP ;

( A B -- B A B )
: TUCK DUP -ROT ;

\ ( d1 -- d1 d1 )
: 2DUP
	OVER OVER
;

\ ( d1 -- )
: 2DROP
	DROP DROP
;

\ ( d1 d2 -- d2 d1 )
: 2SWAP
	>R -ROT R> -ROT
;

\ ( d1 d2 -- d1 d2 d1 )
: 2OVER
	2>R 2DUP 2R> 2SWAP
;