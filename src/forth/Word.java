package forth;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Dictionary;

import forth.exceptions.UnknownNameException;

/**
 * This class represents words that were written in Forth (not primitives
 * written in assembly)
 * 
 * @author nschu
 */
public class Word extends AbstractCompilable
{
	Collection<Token> definition;
	
	private final int F_IMMED = 128;

	@Override
	public Iterable<Token> dependencies()
	{
		return definition;
	}

	@Override
	public boolean contains(Token tokenIn)
	{
		return definition.contains(tokenIn);
	}

	@Override
	public Collection<String> entry(String priorEntry, Dictionary<String, String> dictionary) throws UnknownNameException
	{
		Collection<String> targets = new ArrayList<String>();
		for (Token token : definition)
		{
			String target = dictionary.get(token.getText());
			if (target != null)
				targets.add(target);
			else if (token.getType() == Token.Type.NUMBER)
				targets.add("#" + token.getText());
			else if (token.getType() == Token.Type.LITERAL)
				targets.add(token.getText());
			else
				throw new UnknownNameException(token.getText(), this, dictionary);
		}
		return Assembly.dictionaryEntry(name, label, priorEntry, flags, codeWord, targets);
	}

	@Override
	public Collection<String> assembly()
	{
		return new ArrayList<String>(); // No assembly
	}

	public Word(String nameIn, Collection<Token> definitionIn)
	{
		this(nameIn, 0, definitionIn);
	}

	public Word(String nameIn, int flagsIn, Collection<Token> definitionIn)
	{
		super(nameIn, Assembly.sanitize(nameIn), flagsIn, "DOCOL");
		definition = new ArrayList<Token>();
		for (Token token : definitionIn)
		{
			if (token.getType() == Token.Type.NUMBER)
				definition.add(new Token("LIT"));
			definition.add(token);
		}
		definition.add(new Token("EXIT"));
		Token testImm = new Token("IMMEDIATE");
		if (definition.contains(testImm))
		{
			flags += F_IMMED;
			definition.remove(testImm);
		}
	}
}
