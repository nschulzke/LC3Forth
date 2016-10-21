#include _minimal.forth
: *
	DUP
	0BRANCH <#3> BRANCH <#3> 0 EXIT			( return 0 if B is 0 )
	0< DUP 0BRANCH <#2> NEGATE				( stack: A |B| S )
	-ROT									( stack: S A B )
	DUP										( stack: S A B B )
	-ROT									( stack: S B A B )
	0 DO									( stack: S B A )
		DUP									( stack: S B A A )
		-ROT								( stack: S A B A )
	LOOP									( stack: S A1 A2 .. AB B A )
	DROP									( stack: S A1 A2 .. AB B )
	1 -										( stack: S A1 A2 .. AB [B-1] )
	0 DO									( stack: S A1 A2 .. AB )
		+
	LOOP									( stack: S [A*B] )
	SWAP									( stack: [A*B] S )
	IF NEGATE THEN							( stack: [A*B] )

;

: HIDE WORD FIND HIDDEN ;

: >DFA >CFA 1+ ;
