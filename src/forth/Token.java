package forth;

import java.util.regex.Pattern;

/**
 * This class represents individual tokens in the parsed file. The name is the
 * text which the token represents The type is the enum representation of what
 * kind of token that is (Token.Type)
 * 
 * @author nschu
 */
public class Token
{
	private String text;
	private Type type;

	/**
	 * Takes a name, runs it through Token.Type.idToken to identify what type it should be, then constructs.
	 * @param textIn	The text for the token
	 */
	public Token(String textIn)
	{
		text = textIn;
		type = Type.idToken(textIn);
	}

	/**
	 * Takes a name and type and constructs an object using those two values.
	 * @param typeIn	Token.Type object representing the type of token
	 * @param textIn	The text for the token
	 */
	public Token(Type typeIn, String textIn)
	{
		text = textIn;
		type = typeIn;
	}

	/**
	 * Gets the text held in the token
	 * @return			The text of the token
	 */
	public String getText()
	{
		return text;
	}

	/**
	 * Gets the type of the token
	 * @return			The Token.Type object of the token
	 */
	public Type getType()
	{
		return type;
	}
	
	
	@Override
	public String toString()
	{
		if (type != Type.NEW_LINE)
			return type + "(" + text + ")";
		else
			return type.toString();
	}
	
	@Override
	public boolean equals(Object o)
	{
		if (!(o instanceof Token))
			return false;	// False if not a member of the same class
		else if (((Token) o).getText().equals(text) && ((Token) o).getType().equals(type))
			return true;	// True if: 1) Texts are equal
		else				//			2) Types are equal
			return false;	// False otherwise
	}
	
	@Override
	public int hashCode()
	{
		int ret = 48;						// 48 is a randomly selected starting integer
		ret = 31 * ret + text.hashCode();	// Include the text
		ret = 31 * ret + type.hashCode();	// Include the type
		return ret;							// Return the hash
	}
	
	/**
	 * Enum holding the different types of tokens available
	 * @author nschu
	 */
	public static enum Type
	{
		INVALID_TOKEN, NEW_LINE, WORD, NUMBER, DIRECTIVE, LITERAL;

		/**
		 * Takes a string and checks it to see what kind of token it is.
		 * Currently will identify Numbers, Directives, Literals, and NewLines. Anything else
		 * is treated as a Word.
		 * @param nameIn	The string to be id'd
		 * @return			The Token.Type object that is appropriate for that string.
		 */
		public static Type idToken(String nameIn)
		{
			boolean isNumber = Pattern.matches("[-]?[0-9]+", nameIn);
			boolean isDirective = Pattern.matches("#.*", nameIn);
			boolean isLiteral = Pattern.matches("<.*>", nameIn);
			boolean isNewLine = nameIn.equals("\n");

			if (isNumber)
				return NUMBER;
			else if (isDirective)
				return DIRECTIVE;
			else if (isNewLine)
				return NEW_LINE;
			else if (isLiteral)
				return LITERAL;
			else
				return WORD;
		}
	}
}
