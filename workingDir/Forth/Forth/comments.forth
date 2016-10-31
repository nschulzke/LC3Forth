: ( IMMEDIATE
	1					\ allowed nested parens by keeping track of depth
	BEGIN
		INPUT				\ read next character
		DUP [ INPUT ( ] LITERAL
			= IF	\ open paren?
			DROP		\ drop the open paren
			1+			\ depth increases
		ELSE
			[ INPUT ) ] LITERAL
			= IF	\ close paren?
				1-		\ depth decreases
			THEN
		THEN
	DUP 0= UNTIL		\ continue until we reach matching close paren, depth 0
	DROP				\ drop the depth counter
;