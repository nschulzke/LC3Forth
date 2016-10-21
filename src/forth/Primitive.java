package forth;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Dictionary;

import forth.exceptions.InvalidAssemblyException;

public class Primitive extends AbstractCompilable
{
	Collection<Token> assembly;

	@Override
	public Iterable<Token> dependencies()
	{
		return new ArrayList<Token>(); // No dependencies
	}

	@Override
	public boolean contains(Token tokenIn)
	{
		return (codeWord.equals(tokenIn.getText()));
	}

	@Override
	public Collection<String> entry(String priorEntry, Dictionary<String, String> dictionary)
	{
		return Assembly.dictionaryEntry(name, label, priorEntry, flags, codeWord);
	}

	public Collection<String> assembly() throws InvalidAssemblyException
	{
		return Assembly.primitiveCode(label, assembly);
	}

	private Primitive(String nameIn, String labelIn, int flagsIn, Collection<Token> assemblyIn)
	{
		super(nameIn, labelIn, flagsIn, labelIn);
		assembly = assemblyIn;
	}

	public static Primitive primitive(String nameIn, String labelIn, int flagsIn, Collection<Token> assemblyIn)
	{
		return new Primitive(nameIn, labelIn, flagsIn, assemblyIn);
	}

	public static Primitive primitive(String nameIn, String labelIn, Collection<Token> assemblyIn)
	{
		return new Primitive(nameIn, labelIn, 0, assemblyIn);
	}

	public static Primitive variable(String nameIn, String labelIn, int flagsIn)
	{
		return new Primitive(nameIn, labelIn, flagsIn, Assembly.defineVariable(labelIn));
	}

	public static Primitive variable(String nameIn, String labelIn)
	{
		return new Primitive(nameIn, labelIn, 0, Assembly.defineVariable(labelIn));
	}

	public static Primitive variableInit(String nameIn, String labelIn, String initVal)
	{
		return new Primitive(nameIn, labelIn, 0, Assembly.defineVariable(labelIn, initVal));
	}
	
	public static Primitive latest(String latestEntry)
	{
		return new Primitive("LATEST", "LATEST", 0, Assembly.defineVarLatest(latestEntry));
	}
}
