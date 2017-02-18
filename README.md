LC3Forth is a complete Forth implementation for the LC-3, and an accompanying compiler.
  [What is Forth?](https://www.forth.com/starting-forth/0-starting-forth/#Introduction_for_Professionals_Forth_in_the_Real_World)

For the easiest way to take a look at it in action, download LC3Forth.zip and read the README. Alternatively, you can view my short [in-class presentation video here.](https://www.youtube.com/watch?v=alPzVbVq2TU)

This was my final project for Computer Architecture at UVU. We were assigned to build something using the LC-3 Assembly language, and I'd been reading a bit about Forth, which was built originally on 16-bit computers like the LC-3. I thought it would be neat to build my own Forth.

My best estimate is that I spent around 300 hours working on this project. That's significantly more than I'd normally spend on a school project, but I had a blast working on it!

I started just writing assembly code, but it was getting really repetitive, and the LC-3's assembler doesn't support macros. So I decided to build a simple compiler to make things easier to work on, then built the Forth system using that tool.

[(You can download the official LC-3 simulator and assembler here)](https://highered.mheducation.com/sites/0072467509/student_view0/lc-3_simulator.html)

# The Java Compiler
This was my first attempt at anything resembling a compiler, and I knew very little about what would be needed when I started this. I'm sure I did some things wrong, but at least it works! I'm going to come back and tidy it up, right now it's feature complete, but a little bit disorganized (main() is still in a testing file, for example).

The Java compiler works in four phases.

### File I/O
We start by reading /workingDir/Forth/_minimal.asm. Before passing this file on to the lexer, we include any files indicated by #include statements.

Additionally, we take files indicated by #binary statements convert them into a UTF-16BE encoded .obj file that can be loaded into the LC-3 simulator. This will just be plain text, the point is just to get it into a format that can be parsed and compiled by the LC-3 Forth system itself.

### The Lexer
Here, we take the lines from File I/O and tokenize them. Pretty simple.

### The Parser
This phase is where most of the work is done.

First, we take the tokens and interpret them. We could encounter any of the following:
* Primitives, defined with #primitive in .asm files, with a body of assembly code
* Variables, defined with #variable in .asm files
* Forth words, indicated in traditional Forth colon definitions: ": ... ;"

Once we've isolated the definitions and determined what kind they are (each will have a different assembly implementation), we simply parse and store it in an appropriate data structure for compiling.

This phase also includes the building of the dictionary of words, which is important. This is where most exceptions will be thrown: if there's a word that's used but never defined, we catch it and stop compiling until that's resolved.

### The Compiler
This phase takes the data structures we generated in the Parser phase and turns them into assembly.

For Primitives, we take the assembly code found in the brackets and put it into the assembly portion of the Forth implementation.
For Variables, we generate assembly code that will handle variables properly. All variables behave the same, so we just insert the appropriate options defined in the #variable tag.

Finally, we build the dictionary. This was the biggest reason I built the Java program. The dictionary consists of a linked list of all the words that were found during the Parse phase. For Primitives and Variables, the body of the entry is simply a pointer to the assembly code. For Forth words, the entry is a series of pointers to the words that are called.

The Compiler inserts these two portions (primitives and dictionary) into the appropriate locations (indicated by #insert statements) in /workingDir/Forth/_template.asm, which defines the standard subroutines and stacks for the implementation. 

# The Forth Implementation
Most of the work went into this. There are two basic subdivisions of this implementation: the primitive environment, and the library.

### The Environment
This is all of the stuff found in .asm files. The basic set of Forth words, pretty much only what was absolutely needed for the Forth interpreter.

When the environment initially loads up, it will look for a library at data location x4000. If it can't find that, then it runs a very basic interpreter, accepting input and compiling/executing commands. If it does find the library, then it reads it as if it were input from the keyboard, building the full Forth system as it goes.

### The Library
This is what we converted into an .obj with our #binary statement in _minimal.asm, it initially starts out as essentially a long text file (all of the .forth files combined into one, with comments removed). This is then loaded by the Forth interpreter, which compiles it into a full Forth system. The last commands in the .obj that are interpreted replace the super-simple interpreter with a fancier one (that handles backspace and newlines and stuff!), and then clear the screen and display a welcome message.
