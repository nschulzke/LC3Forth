: TRUE 1 ;
: FALSE 0 ;
: NOT 0= ;

\ ( -- BEGIN_addr )
: BEGIN IMMEDIATE HERE @ ;

\ ( BEGIN_addr -- )
: AGAIN IMMEDIATE
	' BRANCH ,		\ Set branch
	HERE @ - ,		\ Offset = BEGIN_addr - AGAIN_addr
;

\ ( BEGIN_addr -- )
: UNTIL IMMEDIATE
	' 0BRANCH ,		\ Same as AGAIN except conditional
	HERE @ - ,
;

\ ( BEGIN_addr -- BEGIN_addr WHILE_addr )
: WHILE IMMEDIATE
	' 0BRANCH ,		\ Set 0BRANCH
	HERE @			\ New offset on stack
	0 ,				\ Dummy offset
;

\ ( BEGIN_addr WHILE_addr -- )
: REPEAT IMMEDIATE
	' BRANCH ,		\ Set BRANCH
	SWAP			\ WHILE_addr BEGIN_addr
	HERE @ - ,		\ Get offset and compile it ( WHILE_addr )
	DUP				\ WHILE_addr WHILE_addr
	HERE @ SWAP -	\ WHILE_addr offset
	SWAP !			\ and back-fill it in the original location
;

: IF IMMEDIATE
	' 0BRANCH ,
	HERE @			\ ifAddress
	0 ,				\ dummy offset of 0 until told otherwise
;

: ELSE IMMEDIATE
	' BRANCH ,		\ branch around the false
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
	' NOT ,
	[COMPILE] IF
;

\ CASE...ENDCASE is just a big nested IF ELSE THEN
: CASE IMMEDIATE
	0				\ marks bottom of stack
;

: OF IMMEDIATE
	' OVER ,		\ append OVER
	' = ,			\ append =
	[COMPILE] IF	\ append IF
	' DROP ,		\ append DROP
;

: ENDOF IMMEDIATE
	[COMPILE] ELSE
;

: ENDCASE IMMEDIATE
	' DROP ,		\ append DROP to clean up
	
	\ close all THENs until we get to the zero
	BEGIN
		?DUP
	WHILE
		[COMPILE] THEN
	REPEAT
;

( limit index -- | -- limit index )
: (DO)
	R>				\ ( limit index pointer )
	-ROT			\ ( pointer limit index )
	2>R >R			\ ( limit index pointer ) on return
;

: (LOOP)
	R>				\ ( pointer | limit index )
	2R>				\ ( pointer limit index | )
	1+ 2DUP 		\ ( pointer limit index limit index )
	<=				\ ( pointer limit index flag )
	-ROT 2>R		\ ( pointer flag | limit index )
	SWAP >R			\ ( flag | limit index pointer )
;

: DO IMMEDIATE
	' (DO) ,
	[COMPILE] BEGIN
;

: LOOP IMMEDIATE
	' (LOOP) ,
	[COMPILE] UNTIL
	' 2RDROP ,		\ Empty return stack
;