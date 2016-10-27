package forth;

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Collection;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class FileIO
{
	private String workingDir;
	private String outputDir;
	private Collection<String> includedFiles;

	public FileIO(String workingDirIn, String outputDirIn)
	{
		workingDir = workingDirIn;
		outputDir = outputDirIn;
		includedFiles = new ArrayList<String>();
	}

	private void addIncludes(String lineIn, Collection<String> linesOut) throws IOException
	{
		String include = lineIn.replace("#include", "");
		Collection<String> includeFiles = new ArrayList<String>();

		String pattern = "[^\\s\"',]+|\"([^\"]*)\"|'([^']*)'";
		Pattern regex = Pattern.compile(pattern);
		Matcher match = regex.matcher(include);
		while (match.find())
		{
			if (match.group(1) != null)
			{
				includeFiles.add(match.group(1)); // In double quotes
			} else if (match.group(2) != null)
			{
				includeFiles.add(match.group(2)); // In single quotes
			} else
			{
				includeFiles.add(match.group()); // Whole word (no quotes)
			}
		}

		for (String file : includeFiles)
		{
			if (!includedFiles.contains(file))
			{
				includedFiles.add(file);
				load(file, linesOut);
			}
		}
	}

	private void processBinary(String lineIn) throws IOException
	{
		String include = lineIn.replace("#binary", "");
		Collection<String> binaryFiles = new ArrayList<String>();

		String pattern = "[^\\s\"',]+|\"([^\"]*)\"|'([^']*)'";
		Pattern regex = Pattern.compile(pattern);
		Matcher match = regex.matcher(include);
		while (match.find())
		{
			if (match.group(1) != null)
			{
				binaryFiles.add(match.group(1)); // In double quotes
			} else if (match.group(2) != null)
			{
				binaryFiles.add(match.group(2)); // In single quotes
			} else
			{
				binaryFiles.add(match.group()); // Whole word (no quotes)
			}
		}

		for (String file : binaryFiles)
		{
			Collection<String> withComments = load(file);
			Collection<String> stringsIn = new ArrayList<String>();
			
			int numChars = 0;
			for (String string : withComments)
			{
				// Remove all comments to save space
				// This cuts the size almost in half ( 23kb -> 13kb on my tests )
				// We can take up to 32kb before we get into the negatives and start having problems iterating
				// This will probably be plenty for any purpose we need with comments not counting
				string = string.replaceAll("[ \t]+\\\\[ \t]+.*", "");	// line comments after commands
				string = string.replaceAll("^\\\\[ \t]+.*", "");		// line comments on own line
				string = string.replaceAll("[ \t]+\\([ \t]+.*\\)", "");	// paren comments after commands
				string = string.replaceAll("^\\([ \t]+.*\\)", "");		// paren comments on own line
				for (int i = 0; i < string.length(); i++)
					numChars++;
				stringsIn.add(string);
			}
			int numLines = stringsIn.size();
			int wordSize = 2;
			int padding = 4;
			int numBytes = ((numChars + numLines) * wordSize) + padding;
			byte[] bytes = new byte[numBytes];
			
			int address = 0;
			bytes[address++] = 0x40;
			bytes[address++] = 0x00;
			for (String string : stringsIn)
			{
				byte[] bytesIn = string.getBytes(StandardCharsets.UTF_16BE);
				for (byte in : bytesIn)
					bytes[address++] = in;
				bytes[address++] = 0x00;
				bytes[address++] = '\n';
			}
			bytes[address++] = 0x00;
			bytes[address++] = 0x00;
			
			String outFile = file.replace(".forth", ".obj");
		    Path path = Paths.get(outputDir, outFile);
		    Files.write(path, bytes);
		}
	}

	private void load(String fileNameIn, Collection<String> linesOut) throws IOException
	{
		BufferedReader reader = Files.newBufferedReader(Paths.get(workingDir, fileNameIn));
		String line;
		includedFiles.add(fileNameIn);
		while ((line = reader.readLine()) != null)
		{
			if (line.contains("#include"))
				addIncludes(line, linesOut);
			else if (line.contains("#binary"))
				processBinary(line);
			else
				linesOut.add(line);
		}
		reader.close();
	}

	public Collection<String> load(String fileNameIn) throws IOException
	{
		Collection<String> linesOut = new ArrayList<String>();
		load(fileNameIn, linesOut);
		includedFiles.clear();
		return linesOut;
	}

	public void write(String fileNameIn, Iterable<? extends CharSequence> linesIn) throws IOException
	{
		Files.write(Paths.get(outputDir, fileNameIn), linesIn);
	}

	public void append(String fileNameIn, Iterable<? extends CharSequence> linesIn) throws IOException
	{
		Files.write(Paths.get(outputDir, fileNameIn), linesIn, Charset.defaultCharset(), StandardOpenOption.APPEND);
	}
}
