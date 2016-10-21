package forth;

import java.util.Collection;
import java.util.Dictionary;

import forth.exceptions.InvalidAssemblyException;
import forth.exceptions.UnknownNameException;

public interface Compilable
{
	/**
	 * Gets an Iterable of the words needed to define this compilable
	 * 
	 * @return Words needed for definition
	 */
	public Iterable<Token> dependencies();

	/**
	 * Checks whether the given token is used in the definition of this
	 * compilable
	 * 
	 * @param tokenIn
	 *            The token to check
	 * @return True if the token is used, False if not
	 */
	public boolean contains(Token tokenIn);

	/**
	 * Generates the dictionary entry for this compilable
	 * 
	 * @param priorEntry
	 *            The label for the previous word in the dictionary
	 * @param dictionary
	 *            The dictionary object we should check against to make sure
	 *            dependencies are satisfied
	 * @return A collection of the lines of assembly code that will make up the
	 *         dictionary entry
	 * @throws Exception
	 *             if unable to find a name this compilable depends on
	 */
	public Collection<String> entry(String priorEntry, Dictionary<String, String> dictionary) throws UnknownNameException;

	/**
	 * Generates the assembly code used in the definition of the behavior of the
	 * compilable
	 * 
	 * @return A collection of the lines of assembly code that define behavior
	 * @throws Exception
	 *             if the assembly tokens that were parsed into the object
	 *             aren't compilable
	 */
	public Collection<String> assembly() throws InvalidAssemblyException;

	public String getName();

	public String getLabel();
}
