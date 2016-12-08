( cfa -- addr )
: XT>
	LATEST @		\ start here
	BEGIN
		?DUP		\ as long as the link pointer isn't 0
	WHILE
		2DUP SWAP	( cfa curr curr cfa )
		< IF		( curr cfa -- ) \ have we reached it?
			NIP		( cfa curr -- curr )
			EXIT
		THEN
		@			( back up )
	REPEAT
	DROP			( cfa curr -- cfa )
	0				( cfa -- cfa 0 )
;

: CONSTANT
	CREATE
	,
	DOES>
	@
;

: VARIABLE
	CREATE
	0 ,
	DOES>
;