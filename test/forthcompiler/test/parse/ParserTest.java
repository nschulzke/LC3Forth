package forthcompiler.test.parse;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Collection;

import forth.FileIO;
import forth.Compiler;

public class ParserTest
{
	public static void main(String[] args)
	{
		FileIO fileManager = new FileIO("workingDir\\Forth", "workingDir\\Output");
		try
		{
			Collection<String> lines = fileManager.load("_minimal.forth");
			Collection<String> template = fileManager.load("_template.asm");
			Collection<String> stdLib = Compiler.compileLines(lines, template);
			fileManager.write("compiled.asm", stdLib);
		}
		catch (FileNotFoundException e) {
			System.out.println("File not found!");
		}
		catch (IOException e) {
			e.printStackTrace();
		} catch (Exception e)
		{
			e.printStackTrace();
		}
	}
}
