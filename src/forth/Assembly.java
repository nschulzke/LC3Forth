package forth;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;

import forth.exceptions.InvalidAssemblyException;

public final class Assembly
{
	private static final String varPrefix = "var_";
	private static final String codeWordPrefix = "code_";
	private static final String namePrefix = "name_";
	
	private static final String outputFormat = "%1$-20s %2$-10s %3$s";
	
	private static final String sanitary[][] = {
				{"~", "tild"},
				{"`", "btck"},
				{"*", "star"},
				{"!", "excl"},
				{"@", "at"},
				{"#", "lb"},
				{"$", "dol"},
				{"%", "pcnt"},
				{"^", "crt"},
				{"&", "amp"},
				{"*", "star"},
				{"(", "lprn"},
				{")", "rprn"},
				{"-", "dash"},
				{"{", "lbrc"},
				{"}", "rbrc"},
				{"[", "lbrk"},
				{"]", "rbrk"},
				{";", "semi"},
				{":", "colo"},
				{"\"", "quot"},
				{"'", "tick"},
				{"<", "less"},
				{">", "more"},
				{",", "comm"},
				{".", "dot"},
				{"?", "ques"},
				{"/", "slsh"},
				{"|", "pipe"},
				{"\\", "whac"},
		};
	
	private static final String opcodes[] = {
			"ADD",
			"BRn",
			"BRz",
			"BRp",
			"BRnz",
			"BRnp",
			"BRzp",
			"BRnzp",
			"AND",
			"JMP",
			"JSR",
			"JSRR",
			"LD",
			"LDI",
			"LDR",
			"LEA",
			"NOT",
			"RET",
			"RTI",
			"ST",
			"STI",
			"STR",
			"TRAP",
			"GETC",
			"OUT",
			"PUTS",
			"IN",
			"PUTSP",
			"HALT"
	};
	
	private Assembly() {};		// Static class
	
	public static Collection<Token> defineVariable(String labelIn)
	{
		String varName = varPrefix + labelIn;
		Collection<Token> ret = new ArrayList<Token>();
		
		addTokenLine(ret, "", "LEA", "R0," + varName);
		addTokenLine(ret, "", "JSR", "PUSH_R0");
		addTokenLine(ret, "", "JSR", "NEXT");
		addTokenLine(ret, varName, ".BLKW", "1");
		
		return ret;
	}
	
	public static Collection<Token> defineVariable(String labelIn, String defaultVal)
	{
		String varName = varPrefix + labelIn;
		Collection<Token> ret = new ArrayList<Token>();
		
		addTokenLine(ret, "", "LEA", "R0," + varName);
		addTokenLine(ret, "", "JSR", "PUSH_R0");
		addTokenLine(ret, "", "JSR", "NEXT");
		addTokenLine(ret, varName, ".FILL", defaultVal);
		
		return ret;
	}

	public static Collection<Token> defineVarLatest(String latestIn)
	{
		return defineVariable("LATEST", namePrefix + "LATEST");
	}
	
	private static void addTokenLine(Collection<Token> tokensOut, String labelIn, String opcodeIn, String operandsIn)
	{
		if (labelIn != "")
			tokensOut.add(new Token(labelIn));
		if (opcodeIn != "")
			tokensOut.add(new Token(opcodeIn));
		if (operandsIn != "")
			tokensOut.add(new Token(operandsIn));
		tokensOut.add(new Token("\n"));
	}
	
	public static String sanitize(String stringIn)
	{
		String ret = stringIn;
		for (String sane[] : sanitary)
		{
			ret = ret.replace(sane[0], sane[1]);
		}
		return ret;
	}
	
	private static String formatLine(String labelIn, String opcodeIn, String operandsIn)
	{
		return String.format(outputFormat, labelIn, opcodeIn, operandsIn);
	}
	
	private static String stringsToAssembly(Collection<String> stringsIn) throws InvalidAssemblyException
	{
		Iterator<String> it = stringsIn.iterator();
		
		String string1;
		String string2;
		String string3;
		switch (stringsIn.size())
		{
			case 0:
				return "";
			case 1:
				string1 = it.next();
				if (Arrays.asList(opcodes).contains(string1))
					return formatLine("", string1, "");
				else
					return formatLine(string1, "", "");
			case 2:
				string1 = it.next();
				string2 = it.next();
				if (Arrays.asList(opcodes).contains(string1))
					return formatLine("", string1, string2);
				else
					return formatLine(string1, string2, "");
			case 3:
				string1 = it.next();
				string2 = it.next();
				string3 = it.next();
				return formatLine(string1, string2, string3);
			default: throw new InvalidAssemblyException(stringsIn.toString());
		}
	}
	
	public static Collection<String> primitiveCode(String labelIn, Iterable<Token> tokensIn) throws InvalidAssemblyException
	{
		Collection<String> ret = new ArrayList<String>();
		ArrayList<String> temp = new ArrayList<String>();
		ret.add(labelIn);
		for (Token token : tokensIn)
		{
			if (token.getType() == Token.Type.NEW_LINE)
			{
				try {
				ret.add(stringsToAssembly(temp));
				temp.clear();
				} catch (InvalidAssemblyException e) {
					e.setLabel(labelIn);
				}
			}
			else
				temp.add(token.getText());
		}
		return ret;
	}
	
	public static String codeWordLine(String label, String codeWord)
	{
		return dataLine(codeWordPrefix + label, codeWord);
	}
	
	public static String definitionLine(String target)
	{
		if (target.charAt(0) == '#')
			return dataLine("", target);
		else if (target.charAt(0) == '<')
			return dataLine("", target.replaceAll("<", "").replaceAll(">", ""));
		else
			return dataLine("", codeWordPrefix + target);
	}
	
	public static String dataLine(String label, String data)
	{
		return formatLine(label, ".FILL", data);
	}
	
	public static String dictionaryStart(String startLabel)
	{
		return dataLine(namePrefix + startLabel, "#0");
	}
	
	public static Collection<String> dictionaryEntry(String nameIn, String labelIn, String priorEntry, int flagsIn, String codeWord, Iterable<String> targetsIn)
	{
		Collection<String> ret = dictionaryEntry(nameIn, labelIn, priorEntry, flagsIn, codeWord);
		for (String target : targetsIn)
			ret.add(definitionLine(target));
		return ret;
	}
	
	public static Collection<String> dictionaryEntry(String nameIn, String labelIn, String priorEntry, int flagsIn, String codeWord)
	{
		int sizeAndFlags = nameIn.length() + flagsIn;
		
		Collection<String> ret = new ArrayList<String>();
		ret.add(dataLine(namePrefix + labelIn, namePrefix + priorEntry));
		ret.add(dataLine("", "#" + sizeAndFlags));
		ret.add(formatLine("", ".STRINGZ", "\"" + nameIn + "\""));
		ret.add(codeWordLine(labelIn, codeWord));
		return ret;
	}
}
