\ Takes the top of the stack, stores as literal
: LITERAL IMMEDIATE
	LIT_XT LIT ,	\ compile literal LIT in current word
	,				\ compile the top of the stack
;

: LITERAL_XT IMMEDIATE
	LIT_XT LIT_XT ,			\ same as LITERAL, but with LIT_XT
	,
;

\ Gets xt for word, pushes to stack
: '
	WORD FIND
	>CFA
;

\ Gets a word's xt, compiles it.
\	Used to compile an IMMEDIATE word
: [COMPILE] IMMEDIATE
	' ,
;
\ Gets xt for word and compiles it as a literal
\ Used in a colon-definition, future calls to
\ 	the word being defined will push the xt
\	to the stack
: ['] IMMEDIATE
	'
	[COMPILE] LITERAL_XT
;
\ Gets xt for the following word. Future calls to
\	the parent word will compile the target instead
\	of executing it.
: COMPILE IMMEDIATE
	[COMPILE] [']	\ later calls run ['] to get xt and store as LITERAL
	['] , ,			\ puts xt of , on stack and compiles it into the word
;
\ Does [COMPILE] for IMMEDIATE words, COMPILE otherwise
: POSTPONE IMMEDIATE
	WORD FIND					( addr )
	DUP >CFA SWAP				( xt addr )
	?IMMEDIATE 0BRANCH [ 4 , ]	( xt )
		,
	BRANCH [ 5 , ]
		[COMPILE] LITERAL_XT
		COMPILE ,
;

: >DFA >CFA 1+ ;

: RECURSE IMMEDIATE
	LATEST @
	>CFA ,
;

: CREATE
	HEADER
	POSTPONE LIT
	HERE @ 2 + ,		\ variable begins two spaces down
	POSTPONE EXIT
;

: CONSTANT
	HEADER
	POSTPONE LIT		\ Append LIT
	,					\ Append the top of the stack
	POSTPONE EXIT		\ And append EXIT
;

: VARIABLE
	CREATE
	0 ,				\ Variable
;

\ Reserves memory locations after HERE
: ALLOT
	HERE +!			\ ( adds n to here, old here is still on stack )
;

: HIDE WORD FIND HIDDEN ;

( wordptr -- length )
: LENGTH
	1+ @			( lenflags )
	F_LENMASK AND	( length )	
;