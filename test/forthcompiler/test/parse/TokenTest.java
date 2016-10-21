package forthcompiler.test.parse;

import forth.Token;

public class TokenTest {
	public static void main(String[] args) {
		Token[] tokens =
			{
					new Token("#include"),
					new Token("#primitive"),
					new Token("#variable"),
					new Token("#constant"),
					new Token("10"),
					new Token("-10"),
					new Token("10a"),
					new Token("d10"),
					new Token("d10a"),
					new Token("-10a"),
					new Token("d-10"),
					new Token("d-10d"),
					new Token("SWAP"),
			};
		for (Token token : tokens)
			System.out.println(token.toString());
	}
}
