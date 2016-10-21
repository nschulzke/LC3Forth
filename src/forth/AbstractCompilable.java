package forth;

/**
 * The abstract class for entries that are compilable, defining basic behavior
 * and properties common to all entries.
 * 
 * @author nschu
 */
abstract class AbstractCompilable implements Compilable
{
	protected String name;
	protected String label;
	protected int flags;
	protected String codeWord;

	/**
	 * This cannot be called to initialize an object of type AbstractCompilable,
	 * but is called by child classes
	 * 
	 * @param nameIn		The name of the word
	 * @param labelIn		The assembly label of the word
	 * @param flagsIn		The flags of the word
	 * @param codeWordIn	The dictionary codeword of the word (most often DOCOL or a label targetting assembly code)
	 */
	public AbstractCompilable(String nameIn, String labelIn, int flagsIn, String codeWordIn)
	{
		name = nameIn;
		label = labelIn;
		flags = flagsIn;
		codeWord = codeWordIn;
	}

	/**
	 * Gets the flags for the word as an integer value.
	 * 
	 * @return flags set as an integer
	 */
	public int getFlags()
	{
		return flags;
	}

	@Override
	public String getName()
	{
		return name;
	}

	@Override
	public String getLabel()
	{
		return label;
	}

	@Override
	public abstract boolean contains(Token tokenIn);
}
