package forth;

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
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

	private void load(String fileNameIn, Collection<String> linesOut) throws IOException
	{
		BufferedReader reader = Files.newBufferedReader(Paths.get(workingDir, fileNameIn));
		String line;
		includedFiles.add(fileNameIn);
		while ((line = reader.readLine()) != null)
		{
			if (line.contains("#include"))
				addIncludes(line, linesOut);
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
