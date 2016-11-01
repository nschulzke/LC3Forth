: TRUE -1 ;
: FALSE 0 ;
: NOT 0= ;

( -- addr )
: >MARK
	HERE @		\ get the current compiling location
	0 ,			\ save dummy at current location
;

( addr -- )
: >RESOLVE
	DUP				( addr addr )
	HERE @ SWAP -	( addr offset )
	SWAP !			\ and back-fill it in the original location
;

( -- addr )
: <MARK
	HERE @
;

( addr -- )
: <RESOLVE
	HERE @ - ,		\ Offset = BEGIN_addr - AGAIN_addr
;

( -- BEGIN_addr )
: BEGIN IMMEDIATE
	<MARK
;

( BEGIN_addr -- )
: AGAIN IMMEDIATE
	POSTPONE BRANCH	\ Set branch
	<RESOLVE
;

( BEGIN_addr -- )
: UNTIL IMMEDIATE
	POSTPONE 0BRANCH	\ Same as AGAIN except conditional
	<RESOLVE
;

\ ( BEGIN_addr -- BEGIN_addr WHILE_addr )
: WHILE IMMEDIATE
	POSTPONE 0BRANCH	\ Set 0BRANCH
	>MARK
;

\ ( BEGIN_addr WHILE_addr -- )
: REPEAT IMMEDIATE
	POSTPONE BRANCH	\ Set BRANCH
	SWAP			\ WHILE_addr BEGIN_addr
	<RESOLVE		\ Get offset and compile it ( WHILE_addr )
	>RESOLVE
;

: IF IMMEDIATE
	POSTPONE 0BRANCH
	>MARK
;

\ ( IF_addr  -- )
: ELSE IMMEDIATE
	POSTPONE BRANCH	\ branch around the false
	>MARK
	SWAP			\ ifAddress elseAddress -- elseAddress ifAddress
	>RESOLVE
;

\ ( IF/ELSE_addr -- )
: THEN IMMEDIATE
	>RESOLVE
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
	POSTPONE IF			\ append IF
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
	>MARK
;

: ?DO IMMEDIATE
	POSTPONE (?DO)
	>MARK
;

: LOOP IMMEDIATE
	POSTPONE (LOOP)
	DUP 1+			( do-addr back-addr )
	<RESOLVE		\ Resolve back to DO/?DO
	>RESOLVE		\ Resolve forward ( where ?DO skips to )
;