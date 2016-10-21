package forth.exceptions;

public class InvalidAssemblyException extends Exception
{
	private static final long serialVersionUID = -7885195057290427294L;
	
	private String badLine;
	private String label;
	
	public InvalidAssemblyException(String badLineIn)
	{
		super("Invalid assembly.");
		badLine = badLineIn;
	}
	
	@Override
	public String getMessage()
	{
		return "Invalid assembly in word \"" + label + "\". Assembly line: " + badLine;
	}
	
	public String getLine()
	{
		return badLine;
	}
	
	public String getLabel()
	{
		return label;
	}
	
	public void setLabel(String labelIn)
	{
		label = labelIn;
	}
}
