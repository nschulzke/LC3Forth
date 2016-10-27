: '(' [ KEY ( ] LITERAL ;
: ')' [ KEY ) ] LITERAL ;

: ( IMMEDIATE
	1					\ allowed nested parens by keeping track of depth
	BEGIN
		KEY				\ read next character
		DUP '(' = IF	\ open paren?
			DROP		\ drop the open paren
			1+			\ depth increases
		ELSE
			')' = IF	\ close paren?
				1-		\ depth decreases
			THEN
		THEN
	DUP 0= UNTIL		\ continue until we reach matching close paren, depth 0
	DROP				\ drop the depth counter
;