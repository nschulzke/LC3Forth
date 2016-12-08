: VALUE
	CREATE
	,
	DOES>
	@
;

( val -- )
: TO IMMEDIATE
	NAME				( addr )
	>CODE				( codeAddr )
	DUP @ XT>			( codeAddr value? )
	LIT_XT VALUE XT>	( codeAddr value? value )
	= IF
		1+				( dataAddr )
		STATE @ IF		
			POSTPONE LIT ,	\ At runtime, put dataAddr on stack
			POSTPONE !		\ and then store it (LIT num was already compiled)
		ELSE ! THEN			\ Store the data if not compiling
	ELSE
		ABORT" Not a VALUE!"
	THEN
;