: CLEAR
	S0 DSP!
;

( A B -- B )
: NIP SWAP DROP ;

( A B -- B A B )
: TUCK DUP -ROT ;

\ ( -- depth )
: DEPTH
	DSP@ S0 -	( depth )
;

\ ( d1 -- d1 d1 )
: 2DUP
	OVER OVER
;

\ ( d1 -- )
: 2DROP
	DROP DROP
;

\ ( a b -- )	\ return stack
: 2R>
	R> R> R>	( pointer b a )
	ROT >R		( b a | pointer )
	SWAP		( a b | pointer )
;

\ ( a b -- | -- a b )
: 2>R
	R> -ROT			\ ( pointer a b )
	SWAP >R >R		\ ( pointer | a b )
	>R				\ ( | a b pointer )
;

\ ( | a b -- )
: 2RDROP
	R>				\ ( pointer )
	2R>				\ ( pointer a b )
	2DROP			\ ( pointer )
	>R
;

\ ( d1 d2 -- d2 d1 )
: 2SWAP
	>R -ROT R> -ROT
;

\ ( d1 d2 -- d1 d2 d1 )
: 2OVER
	2>R 2DUP 2R> 2SWAP
;