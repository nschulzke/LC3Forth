#include primitives.asm

( A T -- A1 A2 .. AT )
: DUP_TIMES 1 DO DUP LOOP ;

( A -- A A | 0 )
: ?DUP DUP IF DUP THEN ;

( A B C -- C A B )
: -ROT ROT ROT ;

( A B -- A B A )
: OVER SWAP DUP -ROT ;

( A B -- B )
: NIP SWAP DROP ;

( A B -- B A B )
: TUCK SWAP OVER ;

( A B -- (A*B) )
: *
	DUP
	IF ELSE 0 EXIT THEN			( return 0 if B is 0 )
	0< IF NEGATE 1 ELSE 0 THEN	( stack: A B S )
	-ROT						( stack: S A B )
	DUP							( stack: S A B B )
	-ROT						( stack: S B A B )
	0 DO						( stack: S B A )
		DUP						( stack: S B A A )
		-ROT					( stack: S A B A )
	LOOP						( stack: S A1 A2 .. AB B A )
	DROP						( stack: S A1 A2 .. AB B )
	1 -							( stack: S A1 A2 .. AB (B-1) )
	0 DO						( stack: S A1 A2 .. AB )
		+
	LOOP						( stack: S (A*B) )
	SWAP						( stack: (A*B) S )
	IF NEGATE THEN				( stack: (A*B) )
;

: IF IMMEDIATE
	' 0BRANCH ,		( compile 0BRANCH into code )
	HERE @			( fetch HERE and put it on the stack for future reference )
	0 ,				( dummy offset of 0 until told otherwise )
;

: ELSE IMMEDIATE
	' BRANCH ,		( branch around the false )
	HERE @			( ifAddress -- ifAddress elseAddress )
	0 ,				( dummy offset )
	SWAP			( ifAddress elseAddress -- elseAddress ifAddress )
	DUP				( duplicate ifAddress for subtraction )
	HERE @ SWAP -	( get the offset to the current location [beginning of false part] )
	SWAP !			( store the offset in the location that was saved )
;

: THEN IMMEDIATE
	DUP				( duplicate the HERE from the stack )
	HERE @ SWAP -	( ifOrElseAddress ifOrElseAddress -- ifOrElseAddress offset )
	SWAP !			( ifOrElseAddress offset -- ) ( store the offset in the variable )
;