package forth.exceptions;

import forth.Word;

public class ParseException extends Exception
{
	private static final long serialVersionUID = -8916672885631795650L;
	
	private Word word;
	
	public ParseException(String message)
	{
		super("Error: \"" + message);
		word = null;
	}
	
	public ParseException(String message, Word wordIn)
	{
		super("Error: \"" + message + "\" in word \"" + wordIn.getName() + "\"");
		word = wordIn;
	}
	
	public void setWord(Word wordIn)
	{
		word = wordIn;
	}
	
	public Word getWord()
	{
		return word;
	}
	
	@Override
	public String getMessage()
	{
		if (word != null)
			return super.getMessage() + "\" in word \"" + word.getName() + "\"";
		else
			return super.getMessage();
	}
}
