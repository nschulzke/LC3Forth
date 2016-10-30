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

\ ( a b -- a b a b )
: 2DUP
	OVER OVER
;

\ ( a b -- )
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
