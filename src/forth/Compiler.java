package forth;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Dictionary;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import forth.exceptions.InvalidAssemblyException;
import forth.exceptions.ParseException;
import forth.exceptions.UnknownNameException;

public final class Compiler
{

	private Compiler()
	{
	} // Static class

	public static Collection<Token> lex(Collection<String> linesIn) throws IOException
	{
		Collection<Token> ret = new ArrayList<Token>();
		Collection<String> split;

		for (String line : linesIn)
		{
			split = ParseHelper.splitString(line);
			for (String string : split)
				if (!string.equals(""))
					ret.add(new Token(string));
			ret.add(new Token("\n"));
		}

		return ret;
	}

	public static Collection<Compilable> parse(Collection<Token> tokensIn) throws Exception
	{
		Collection<Compilable> ret = new ArrayList<Compilable>();

		Iterator<Token> it = tokensIn.iterator();
		while (it.hasNext())
		{
			Token token = it.next();
			if (token.getType() == Token.Type.WORD)
			{
				switch (token.getText())
				{
					case ":":
						ParseHelper.handleColonDef(ret, it);
						break;
					case "(":
						ParseHelper.ignoreComment(it);
						break;
					case "\n":
						break;
					default:
						throw new Exception("Expected defining word");
				}
			} else if (token.getType() == Token.Type.DIRECTIVE)
			{
				switch (token.getText())
				{
					case "#primitive":
						ParseHelper.handlePrimitive(ret, it);
						break;
					case "#variable":
						ParseHelper.handleVariable(ret, it);
						break;
					default:
						throw new Exception("Bad directive");
				}
			} else if (token.getType() != Token.Type.NEW_LINE)
				throw new Exception("Expected defining word");
		}

		return ret;
	}

	public static Collection<String> compile(Collection<Compilable> words, Iterable<String> templateLines)
			throws UnknownNameException, InvalidAssemblyException
	{
		Dictionary<String, String> dictionary = new Hashtable<String, String>();
		Collection<String> assemblyLines = new ArrayList<String>();
		Collection<String> compileDict = new ArrayList<String>();
		Collection<String> ret = new ArrayList<String>();

		String latestVar = "";
		for (Compilable word : words)
		{
			dictionary.put(word.getName(), word.getLabel());
			latestVar = word.getLabel();
		}
		if (latestVar != "")
		{
			Primitive latest = Primitive.latest(latestVar);
			words.add(latest);
			dictionary.put(latest.getName(), latest.getLabel());
		}

		for (Compilable word : words)
			assemblyLines.addAll(word.assembly());

		String prior = "END_OF_DICT";
		compileDict.add(Assembly.dictionaryStart(prior));
		for (Compilable word : words)
		{
			compileDict.addAll(word.entry(prior, dictionary));
			prior = word.getLabel();
		}

		for (String tempLine : templateLines)
		{
			if (tempLine.equalsIgnoreCase("#insert primitives"))
				ret.addAll(assemblyLines);
			else if (tempLine.equalsIgnoreCase("#insert dictionary"))
				ret.addAll(compileDict);
			else
				ret.add(tempLine);
		}
		return ret;
	}

	public static Collection<String> compileLines(Collection<String> compileLines, Collection<String> templateLines)
			throws InvalidAssemblyException, Exception
	{
		return compile(parse(lex(compileLines)), templateLines);
	}

	private static class ParseHelper
	{
		private static Collection<String> splitString(String stringIn)
		{
			Collection<String> ret = new ArrayList<String>();

			String splitString[] = stringIn.split("\t");
			for (String string : splitString)
			{
				Matcher m = Pattern.compile("([^\"]\\S*|\".+?\")\\s*").matcher(string);
				while (m.find())
					ret.add(m.group(1));
			}

			return ret;
		}

		public static void handleColonDef(Collection<Compilable> ret, Iterator<Token> it) throws Exception
		{
			String name = iterate(it).getText();
			if (name.equals("<;>"))
				name = ";";
			Collection<Token> definition = parseUntilClose(it, ";");
			ret.add(new Word(name, definition));
		}

		public static void handlePrimitive(Collection<Compilable> ret, Iterator<Token> it) throws Exception
		{
			String name = iterate(it).getText();
			String label = iterate(it).getText();
			int flags = 0;

			Token next = iterate(it); // Either flags (if number) or opening
										// brace
			if (next.getType() == Token.Type.NUMBER) // If it's the flags
			{
				flags = Integer.parseInt(next.getText()); // Then update the
															// flag
				next = iterate(it); // And move on
			}
			while (next.getType() == Token.Type.NEW_LINE) // Skip unlimited new
															// lines
				next = iterate(it);
			if (!next.getText().equals("{")) // If it's not a brace, we got a
												// problem
				throw new Exception("Expected block");
			Collection<Token> assembly = parseUntilClose(it, "}", true);
			ret.add(Primitive.primitive(name, label, flags, assembly));
		}

		public static void handleVariable(Collection<Compilable> ret, Iterator<Token> it) throws Exception
		{
			String name = iterate(it).getText();
			String label = iterate(it).getText();

			String defaultVal = "";
			int flags = 0;

			Token next = iterate(it);
			if (next.getType() == Token.Type.NUMBER) // If it's the flags
			{
				flags = Integer.parseInt(next.getText()); // Then update
				next = iterate(it); // And move on
				ret.add(Primitive.variable(name, label, flags));
			} else if (next.getType() == Token.Type.LITERAL) // If default value
			{
				defaultVal = next.getText().replaceAll("<", "").replaceAll(">", "");
				next = iterate(it);
				ret.add(Primitive.variableInit(name, label, defaultVal));
			} else
			{
				ret.add(Primitive.variable(name, label));
			}
		}

		public static void ignoreComment(Iterator<Token> it) throws ParseException
		{
			iterate(it);
			Token token;
			boolean foundEnd = false;
			while (it.hasNext())
			{
				token = it.next();
				if (token.getText().equals(")"))
				{
					foundEnd = true;
					break;
				}
			}
			if (!foundEnd)
				throw new ParseException("Unexpected EOF");
		}

		private static Collection<Token> parseUntilClose(Iterator<Token> it, String closeTag, boolean keepNewLine)
				throws ParseException
		{
			Collection<Token> tokens = new ArrayList<Token>();
			if (keepNewLine == true)
			{
				Token token = it.next();
				if (token.getType() != Token.Type.NEW_LINE) // Skip initial
															// newline
					tokens.add(token);
			}
			while (it.hasNext())
			{
				Token token = it.next();
				if (token.getText().equals("("))
					ignoreComment(it);
				else if (token.getText().equals(closeTag))
					return tokens;
				else if ((token.getType() != Token.Type.NEW_LINE) || keepNewLine == true)
					tokens.add(token);
			}
			throw new ParseException("Unexpected EOF");
		}

		private static Collection<Token> parseUntilClose(Iterator<Token> it, String closeTag) throws ParseException
		{
			return parseUntilClose(it, closeTag, false);
		}

		public static Token iterate(Iterator<Token> it) throws ParseException
		{
			if (it.hasNext())
				return it.next();
			else
				throw new ParseException("Unexpected EOF");
		}
	}
}
