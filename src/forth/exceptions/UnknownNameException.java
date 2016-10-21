package forth.exceptions;

import java.util.Dictionary;

import forth.Word;

public class UnknownNameException extends ParseException
{
	private static final long serialVersionUID = -7885195057290427294L;
	
	private String badName;
	private Dictionary<String, String> dictionary;
	
	public UnknownNameException(String badNameIn, Word wordIn, Dictionary<String, String> dictionaryIn)
	{
		super("Unknown name", wordIn);
		badName = badNameIn;
		dictionary = dictionaryIn;
	}
	
	public String getName()
	{
		return badName;
	}
	
	@Override
	public String getMessage()
	{
		return super.getMessage() + "\nName: " + badName;
	}

	public Dictionary<String, String> getDictionary()
	{
		return dictionary;
	}
}
