package forthcompiler.test.parse;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Collection;

import forth.Compiler;
import forth.FileIO;
import forth.exceptions.InvalidAssemblyException;
import forth.exceptions.UnknownNameException;

public class ParserTest
{
	public static void main(String[] args)
	{
		FileIO fileManager = new FileIO("workingDir\\Forth", "workingDir\\Output");
		try
		{
			Collection<String> lines = fileManager.load("_minimal.asm");
			Collection<String> template = fileManager.load("_template.asm");
			Collection<String> stdLib = Compiler.compileLines(lines, template);
			fileManager.write("compiled"
					+ ".asm", stdLib);
		}
		catch (FileNotFoundException e) {
			System.out.println("File not found!");
		}
		catch (IOException e) {
			e.printStackTrace();
		} catch (InvalidAssemblyException e)
		{
			e.getMessage();
		} catch (UnknownNameException e)
		{
			e.getMessage();
		} catch (Exception e)
		{
			e.printStackTrace();
		}
	}
}
