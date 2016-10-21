package forthcompiler.test.parse;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;

import forth.FileIO;

public class FileIOTest {
	public static void main(String[] args) {
		FileIO fileManager = new FileIO("workingDir", "workingDir");
		ArrayList<String> append = new ArrayList<String>();
		append.add("these are some lines");
		append.add("that will be appended to the file");
		
		try {
			Collection<String> linesIn = fileManager.load("testFileIO.forth");
			fileManager.write("output.forth", linesIn);
			fileManager.append("output.forth", append);
		} catch (FileNotFoundException e) {
			System.out.println("File not found!");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
