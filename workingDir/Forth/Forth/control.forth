: TRUE -1 ;
: FALSE 0 ;
: NOT 0= ;

\ ( -- BEGIN_addr )
: BEGIN IMMEDIATE HERE @ ;

\ ( BEGIN_addr -- )
: AGAIN IMMEDIATE
	POSTPONE BRANCH	\ Set branch
	HERE @ - ,		\ Offset = BEGIN_addr - AGAIN_addr
;

\ ( BEGIN_addr -- )
: UNTIL IMMEDIATE
	POSTPONE 0BRANCH	\ Same as AGAIN except conditional
	HERE @ - ,
;

\ ( BEGIN_addr -- BEGIN_addr WHILE_addr )
: WHILE IMMEDIATE
	POSTPONE 0BRANCH	\ Set 0BRANCH
	HERE @			\ New offset on stack
	0 ,				\ Dummy offset
;

\ ( BEGIN_addr WHILE_addr -- )
: REPEAT IMMEDIATE
	POSTPONE BRANCH	\ Set BRANCH
	SWAP			\ WHILE_addr BEGIN_addr
	HERE @ - ,		\ Get offset and compile it ( WHILE_addr )
	DUP				\ WHILE_addr WHILE_addr
	HERE @ SWAP -	\ WHILE_addr offset
	SWAP !			\ and back-fill it in the original location
;

: IF IMMEDIATE
	POSTPONE 0BRANCH
	HERE @			\ ifAddress
	0 ,				\ dummy offset of 0 until told otherwise
;

: ELSE IMMEDIATE
	POSTPONE BRANCH	\ branch around the false
	HERE @			\ ifAddress -- ifAddress elseAddress
	0 ,				\ dummy offset
	SWAP			\ ifAddress elseAddress -- elseAddress ifAddress
	DUP				\ duplicate ifAddress for subtraction
	HERE @ SWAP -	\ get the offset to the current location (beginning of false part)
	SWAP !			\ store the offset in the location that was saved
;

: THEN IMMEDIATE
	DUP				\ duplicate the HERE from the stack
	HERE @ SWAP -	\ ifOrElseAddress ifOrElseAddress -- ifOrElseAddress offset
	SWAP !			\ ifOrElseAddress offset -- \ store the offset in the variable
;

: UNLESS IMMEDIATE
	POSTPONE NOT
	POSTPONE IF
;

\ CASE...ENDCASE is just a big nested IF ELSE THEN
: CASE IMMEDIATE
	0				\ marks bottom of stack
;

: OF IMMEDIATE
	POSTPONE OVER		\ append OVER
	POSTPONE =			\ append =
	POSTPONE IF		\ append IF
	POSTPONE DROP		\ append DROP
;

: ENDOF IMMEDIATE
	POSTPONE ELSE
;

: ENDCASE IMMEDIATE
	POSTPONE DROP		\ append DROP to clean up
	
	\ close all THENs until we get to the zero
	BEGIN
		?DUP
	WHILE
		POSTPONE THEN
	REPEAT
;

: DO IMMEDIATE
	POSTPONE (DO)
	POSTPONE BEGIN
;

: LOOP IMMEDIATE
	POSTPONE (LOOP)
	POSTPONE UNTIL
	POSTPONE UNLOOP		\ Empty return stack
;