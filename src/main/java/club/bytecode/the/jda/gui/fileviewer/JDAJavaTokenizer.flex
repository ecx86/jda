/*
 * 11/13/2004
 *
 * JDAJavaTokenizer.java - Scanner for the Java programming language.
 *
 * This library is distributed under a modified BSD license.  See the included
 * RSyntaxTextArea.License.txt file for details.
 */
 // COMPILE THIS FILE WITH GRAMMARKIT PLUGIN FOR INTELLIJ
 // (JFLEX 1.7.0)
 // OR ELSE IT WON'T FUCKING WORK
package club.bytecode.the.jda.gui.fileviewer;

import java.io.*;
import javax.swing.text.Segment;

import org.fife.ui.rsyntaxtextarea.*;


/**
 * Scanner for the Java programming language.<p>
 *
 * This implementation was created using
 * <a href="http://www.jflex.de/">JFlex</a> 1.4.1; however, the generated file
 * was modified for performance.  Memory allocation needs to be almost
 * completely removed to be competitive with the handwritten lexers (subclasses
 * of <code>AbstractTokenMaker</code>, so this class has been modified so that
 * Strings are never allocated (via yytext()), and the scanner never has to
 * worry about refilling its buffer (needlessly copying chars around).
 * We can achieve this because RText always scans exactly 1 line of tokens at a
 * time, and hands the scanner this line as an array of characters (a Segment
 * really).  Since tokens contain pointers to char arrays instead of Strings
 * holding their contents, there is no need for allocating new memory for
 * Strings.<p>
 *
 * The actual algorithm generated for scanning has, of course, not been
 * modified.<p>
 *
 * If you wish to regenerate this file yourself, keep in mind the following:
 * <ul>
 *   <li>The generated <code>JDAJavaTokenizer.java</code> file will contain two
 *       definitions of both <code>zzRefill</code> and <code>yyreset</code>.
 *       You should hand-delete the second of each definition (the ones
 *       generated by the lexer), as these generated methods modify the input
 *       buffer, which we'll never have to do.</li>
 *   <li>You should also change the declaration/definition of zzBuffer to NOT
 *       be initialized.  This is a needless memory allocation for us since we
 *       will be pointing the array somewhere else anyway.</li>
 *   <li>You should NOT call <code>yylex()</code> on the generated scanner
 *       directly; rather, you should use <code>getTokenList</code> as you would
 *       with any other <code>TokenMaker</code> instance.</li>
 * </ul>
 *
 * @author Robert Futrell
 * @version 1.0
 *
 */
%%

%public
%class JDAJavaTokenizer
%extends AbstractJFlexCTokenMaker
%unicode
%type org.fife.ui.rsyntaxtextarea.Token


%{
    public static final String SYNTAX_STYLE_JDA_JAVA = "text/jda_java";


	/**
	 * Constructor.  This must be here because JFlex does not generate a
	 * no-parameter constructor.
	 */
	public JDAJavaTokenizer() {
	}

	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 * @see #addToken(int, int, int)
	 */
	private void addHyperlinkToken(int start, int end, int tokenType) {
		int so = start + offsetShift;
		addToken(zzBuffer.toString().toCharArray(), start,end, tokenType, so, true);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 */
	private void addToken(int tokenType) {
		addToken(zzStartRead, zzMarkedPos-1, tokenType);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 * @see #addHyperlinkToken(int, int, int)
	 */
	private void addToken(int start, int end, int tokenType) {
		int so = start + offsetShift;
		addToken(zzBuffer.toString().toCharArray(), start,end, tokenType, so, false);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param array The character array.
	 * @param start The starting offset in the array.
	 * @param end The ending offset in the array.
	 * @param tokenType The token's type.
	 * @param startOffset The offset in the document at which this token
	 *                    occurs.
	 * @param hyperlink Whether this token is a hyperlink.
	 */
	@Override
	public void addToken(char[] array, int start, int end, int tokenType,
						int startOffset, boolean hyperlink) {
		super.addToken(array, start,end, tokenType, startOffset, hyperlink);
		zzStartRead = zzMarkedPos;
	}


	/**
	 * {@inheritDoc}
	 */
	@Override
	public String[] getLineCommentStartAndEnd(int languageIndex) {
		return new String[] { "//", null };
	}


	/**
	 * Returns the first token in the linked list of tokens generated
	 * from <code>text</code>.  This method must be implemented by
	 * subclasses so they can correctly implement syntax highlighting.
	 *
	 * @param text The text from which to get tokens.
	 * @param initialTokenType The token type we should start with.
	 * @param startOffset The offset into the document at which
	 *        <code>text</code> starts.
	 * @return The first <code>Token</code> in a linked list representing
	 *         the syntax highlighted text.
	 */
	public Token getTokenList(Segment text, int initialTokenType, int startOffset) {

		resetTokenList();
		this.offsetShift = startOffset;

		// Start off in the proper state.
		int state = Token.NULL;
		switch (initialTokenType) {
			case Token.COMMENT_MULTILINE:
				state = MLC;
				start = 0;
				break;
			case Token.COMMENT_DOCUMENTATION:
				state = DOCCOMMENT;
				start = 0;
				break;
			default:
				state = Token.NULL;
		}

		s = text;
		try {
			reset(text, 0, text.count, state);
			return yylex();
		} catch (IOException ioe) {
			ioe.printStackTrace();
			return new TokenImpl();
		}

	}


%}

Letter							= ([A-Za-z])
LetterOrUnderscore				= ({Letter}|"_")
Underscores						= ([_]+)
NonzeroDigit						= ([1-9])
BinaryDigit						= ([0-1])
Digit							= ("0"|{NonzeroDigit})
HexDigit							= ({Digit}|[A-Fa-f])
OctalDigit						= ([0-7])
AnyCharacterButApostropheOrBackSlash	= ([^\\'])
AnyCharacterButDoubleQuoteOrBackSlash	= ([^\\\"\n])
EscapedSourceCharacter				= ("u"{HexDigit}{HexDigit}{HexDigit}{HexDigit})
Escape							= ("\\"(([btnfr\"'\\])|([0123]{OctalDigit}?{OctalDigit}?)|({OctalDigit}{OctalDigit}?)|{EscapedSourceCharacter}))
NonSeparator						= ([^\t\f\r\n\ \(\)\{\}\[\]\;\,\.\=\>\<\!\~\?\:\+\-\*\/\&\|\^\%\"\']|"#"|"\\")
IdentifierStart					= ({LetterOrUnderscore}|"$")
IdentifierPart						= ({IdentifierStart}|{Digit}|("\\"{EscapedSourceCharacter}))

LineTerminator				= (\n|\r)
WhiteSpace				= ([ \t\f])

CharLiteral				= ([\']({AnyCharacterButApostropheOrBackSlash}|{Escape})[\'])
UnclosedCharLiteral			= ([\'][^\'\n]*)
ErrorCharLiteral			= ({UnclosedCharLiteral}[\'])
StringLiteral				= ([\"]({AnyCharacterButDoubleQuoteOrBackSlash}|{Escape})*[\"])
UnclosedStringLiteral		= ([\"]([\\].|[^\\\"])*[^\"]?)
ErrorStringLiteral			= ({UnclosedStringLiteral}[\"])

MLCBegin					= "/*"
MLCEnd					= "*/"
DocCommentBegin			= "/**"
LineCommentBegin			= "//"

DigitOrUnderscore			= ({Digit}|[_])
DigitsAndUnderscoresEnd		= ({DigitOrUnderscore}*{Digit})
IntegerHelper				= (({NonzeroDigit}{DigitsAndUnderscoresEnd}?)|"0")
IntegerLiteral				= ({IntegerHelper}[lL]?)

BinaryDigitOrUnderscore		= ({BinaryDigit}|[_])
BinaryDigitsAndUnderscores	= ({BinaryDigit}({BinaryDigitOrUnderscore}*{BinaryDigit})?)
BinaryLiteral				= ("0"[bB]{BinaryDigitsAndUnderscores})

HexDigitOrUnderscore		= ({HexDigit}|[_])
HexDigitsAndUnderscores		= ({HexDigit}({HexDigitOrUnderscore}*{HexDigit})?)
OctalDigitOrUnderscore		= ({OctalDigit}|[_])
OctalDigitsAndUnderscoresEnd= ({OctalDigitOrUnderscore}*{OctalDigit})
HexHelper					= ("0"(([xX]{HexDigitsAndUnderscores})|({OctalDigitsAndUnderscoresEnd})))
HexLiteral					= ({HexHelper}[lL]?)

FloatHelper1				= ([fFdD]?)
FloatHelper2				= ([eE][+-]?{Digit}+{FloatHelper1})
FloatLiteral1				= ({Digit}+"."({FloatHelper1}|{FloatHelper2}|{Digit}+({FloatHelper1}|{FloatHelper2})))
FloatLiteral2				= ("."{Digit}+({FloatHelper1}|{FloatHelper2}))
FloatLiteral3				= ({Digit}+{FloatHelper2})
FloatLiteral				= ({FloatLiteral1}|{FloatLiteral2}|{FloatLiteral3}|({Digit}+[fFdD]))

ErrorNumberFormat			= (({IntegerLiteral}|{HexLiteral}|{FloatLiteral}){NonSeparator}+)
BooleanLiteral				= ("true"|"false")

Separator					= ([\(\)\{\}\[\]])
Separator2				= ([\;,.])

NonAssignmentOperator		= ("+"|"-"|"<="|"^"|"++"|"<"|"*"|">="|"%"|"--"|">"|"/"|"!="|"?"|">>"|"!"|"&"|"=="|":"|">>"|"~"|"|"|"&&"|">>>")
AssignmentOperator			= ("="|"-="|"*="|"/="|"|="|"&="|"^="|"+="|"%="|"<<="|">>="|">>>=")
Operator					= ({NonAssignmentOperator}|{AssignmentOperator})

CurrentBlockTag				= ("author"|"deprecated"|"exception"|"param"|"return"|"see"|"serial"|"serialData"|"serialField"|"since"|"throws"|"version")
ProposedBlockTag			= ("category"|"example"|"tutorial"|"index"|"exclude"|"todo"|"internal"|"obsolete"|"threadsafety")
BlockTag					= ({CurrentBlockTag}|{ProposedBlockTag})
InlineTag					= ("code"|"docRoot"|"inheritDoc"|"link"|"linkplain"|"literal"|"value")

Identifier				= ({IdentifierStart}{IdentifierPart}*)
ErrorIdentifier			= ({NonSeparator}+)

Annotation				= ("@"{Identifier}?)

URLGenDelim				= ([:\/\?#\[\]@])
URLSubDelim				= ([\!\$&'\(\)\*\+,;=])
URLUnreserved			= ({LetterOrUnderscore}|{Digit}|[\-\.\~])
URLCharacter			= ({URLGenDelim}|{URLSubDelim}|{URLUnreserved}|[%])
URLCharacters			= ({URLCharacter}*)
URLEndCharacter			= ([\/\$]|{Letter}|{Digit})
URL						= (((https?|f(tp|ile))"://"|"www.")({URLCharacters}{URLEndCharacter})?)


%state MLC
%state DOCCOMMENT
%state EOL_COMMENT

%%

<YYINITIAL> {

	/* Keywords */
	"abstract"|
	"assert" |
	"break"	 |
	"case"	 |
	"catch"	 |
	"class"	 |
	"const"	 |
	"continue" |
	"default" |
	"do"	 |
	"else"	 |
	"enum"	 |
	"extends" |
	"final"	 |
	"finally" |
	"for"	 |
	"goto"	 |
	"if"	 |
	"implements" |
	"import" |
	"instanceof" |
	"interface" |
	"native" |
	"new"	 |
	"null"	 |
	"package" |
	"private" |
	"protected" |
	"public" |
	"static" |
	"strictfp" |
	"super"	 |
	"switch" |
	"synchronized" |
	"this"	 |
	"throw"	 |
	"throws" |
	"transient" |
	"try"	 |
	"void"	 |
	"volatile" |
	"while"					{ addToken(Token.RESERVED_WORD); }
	"return"				{ addToken(Token.RESERVED_WORD_2); }

	/* Data types. */
	"boolean" |
	"byte" |
	"char" |
	"double" |
	"float" |
	"int" |
	"long" |
	"short"					{ addToken(Token.DATA_TYPE); }

	/* Booleans. */
	{BooleanLiteral}			{ addToken(Token.LITERAL_BOOLEAN); }

	/* java.lang classes */
	"Appendable" |
	"AutoCloseable" |
	"CharSequence" |
	"Cloneable" |
	"Comparable" |
	"Iterable" |
	"Readable" |
	"Runnable" |
	"Thread.UncaughtExceptionHandler" |
	"Boolean" |
	"Byte" |
	"Character" |
	"Character.Subset" |
	"Character.UnicodeBlock" |
	"Class" |
	"ClassLoader" |
	"ClassValue" |
	"Compiler" |
	"Double" |
	"Enum" |
	"Float" |
	"InheritableThreadLocal" |
	"Integer" |
	"Long" |
	"Math" |
	"Number" |
	"Object" |
	"Package" |
	"Process" |
	"ProcessBuilder" |
	"ProcessBuilder.Redirect" |
	"Runtime" |
	"RuntimePermission" |
	"SecurityManager" |
	"Short" |
	"StackTraceElement" |
	"StrictMath" |
	"String" |
	"StringBuffer" |
	"StringBuilder" |
	"System" |
	"Thread" |
	"ThreadGroup" |
	"ThreadLocal" |
	"Throwable" |
	"Void" |
	"Character.UnicodeScript" |
	"ProcessBuilder.Redirect.Type" |
	"Thread.State" |
	"ArithmeticException" |
	"ArrayIndexOutOfBoundsException" |
	"ArrayStoreException" |
	"ClassCastException" |
	"ClassNotFoundException" |
	"CloneNotSupportedException" |
	"EnumConstantNotPresentException" |
	"Exception" |
	"IllegalAccessException" |
	"IllegalArgumentException" |
	"IllegalMonitorStateException" |
	"IllegalStateException" |
	"IllegalThreadStateException" |
	"IndexOutOfBoundsException" |
	"InstantiationException" |
	"InterruptedException" |
	"NegativeArraySizeException" |
	"NoSuchFieldException" |
	"NoSuchMethodException" |
	"NullPointerException" |
	"NumberFormatException" |
	"RuntimeException" |
	"SecurityException" |
	"StringIndexOutOfBoundsException" |
	"TypeNotPresentException" |
	"UnsupportedOperationException" |
	"AbstractMethodError" |
	"AssertionError" |
	"BootstrapMethodError" |
	"ClassCircularityError" |
	"ClassFormatError" |
	"Error" |
	"ExceptionInInitializerError" |
	"IllegalAccessError" |
	"IncompatibleClassChangeError" |
	"InstantiationError" |
	"InternalError" |
	"LinkageError" |
	"NoClassDefFoundError" |
	"NoSuchFieldError" |
	"NoSuchMethodError" |
	"OutOfMemoryError" |
	"StackOverflowError" |
	"ThreadDeath" |
	"UnknownError" |
	"UnsatisfiedLinkError" |
	"UnsupportedClassVersionError" |
	"VerifyError" |
	"VirtualMachineError" |

	/* java.io classes*/
    "Closeable" |
    "DataInput" |
    "DataOutput" |
    "Externalizable" |
    "FileFilter" |
    "FilenameFilter" |
    "Flushable" |
    "ObjectInput" |
    "ObjectInputValidation" |
    "ObjectOutput" |
    "ObjectStreamConstants" |
    "Serializable" |

    "BufferedInputStream" |
    "BufferedOutputStream" |
    "BufferedReader" |
    "BufferedWriter" |
    "ByteArrayInputStream" |
    "ByteArrayOutputStream" |
    "CharArrayReader" |
    "CharArrayWriter" |
    "Console" |
    "DataInputStream" |
    "DataOutputStream" |
    "File" |
    "FileDescriptor" |
    "FileInputStream" |
    "FileOutputStream" |
    "FilePermission" |
    "FileReader" |
    "FileWriter" |
    "FilterInputStream" |
    "FilterOutputStream" |
    "FilterReader" |
    "FilterWriter" |
    "InputStream" |
    "InputStreamReader" |
    "LineNumberInputStream" |
    "LineNumberReader" |
    "ObjectInputStream" |
    "ObjectInputStream.GetField" |
    "ObjectOutputStream" |
    "ObjectOutputStream.PutField" |
    "ObjectStreamClass" |
    "ObjectStreamField" |
    "OutputStream" |
    "OutputStreamWriter" |
    "PipedInputStream" |
    "PipedOutputStream" |
    "PipedReader" |
    "PipedWriter" |
    "PrintStream" |
    "PrintWriter" |
    "PushbackInputStream" |
    "PushbackReader" |
    "RandomAccessFile" |
    "Reader" |
    "SequenceInputStream" |
    "SerializablePermission" |
    "StreamTokenizer" |
    "StringBufferInputStream" |
    "StringReader" |
    "StringWriter" |
    "Writer" |

    "CharConversionException" |
    "EOFException" |
    "FileNotFoundException" |
    "InterruptedIOException" |
    "InvalidClassException" |
    "InvalidObjectException" |
    "IOException" |
    "NotActiveException" |
    "NotSerializableException" |
    "ObjectStreamException" |
    "OptionalDataException" |
    "StreamCorruptedException" |
    "SyncFailedException" |
    "UncheckedIOException" |
    "UnsupportedEncodingException" |
    "UTFDataFormatException" |
    "WriteAbortedException" |

    "IOError" |

	/* java.util classes */
    "Collection" |
    "Comparator" |
    "Deque" |
    "Enumeration" |
    "EventListener" |
    "Formattable" |
    "Iterator" |
    "List" |
    "ListIterator" |
    "Map" |
    "Map.Entry" |
    "NavigableMap" |
    "NavigableSet" |
    "Observer" |
    "PrimitiveIterator" |
    "PrimitiveIterator.OfDouble" |
    "PrimitiveIterator.OfInt" |
    "PrimitiveIterator.OfLong" |
    "Queue" |
    "RandomAccess" |
    "Set" |
    "SortedMap" |
    "SortedSet" |
    "Spliterator" |
    "Spliterator.OfDouble" |
    "Spliterator.OfInt" |
    "Spliterator.OfLong" |
    "Spliterator.OfPrimitive" |

    "AbstractCollection" |
    "AbstractList" |
    "AbstractMap" |
    "AbstractMap.SimpleEntry" |
    "AbstractMap.SimpleImmutableEntry" |
    "AbstractQueue" |
    "AbstractSequentialList" |
    "AbstractSet" |
    "ArrayDeque" |
    "ArrayList" |
    "Arrays" |
    "Base64" |
    "Base64.Decoder" |
    "Base64.Encoder" |
    "BitSet" |
    "Calendar" |
    "Calendar.Builder" |
    "Collections" |
    "Currency" |
    "Date" |
    "Dictionary" |
    "DoubleSummaryStatistics" |
    "EnumMap" |
    "EnumSet" |
    "EventListenerProxy" |
    "EventObject" |
    "FormattableFlags" |
    "Formatter" |
    "GregorianCalendar" |
    "HashMap" |
    "HashSet" |
    "Hashtable" |
    "IdentityHashMap" |
    "IntSummaryStatistics" |
    "LinkedHashMap" |
    "LinkedHashSet" |
    "LinkedList" |
    "ListResourceBundle" |
    "Locale" |
    "Locale.Builder" |
    "Locale.LanguageRange" |
    "LongSummaryStatistics" |
    "Objects" |
    "Observable" |
    "Optional" |
    "OptionalDouble" |
    "OptionalInt" |
    "OptionalLong" |
    "PriorityQueue" |
    "Properties" |
    "PropertyPermission" |
    "PropertyResourceBundle" |
    "Random" |
    "ResourceBundle" |
    "ResourceBundle.Control" |
    "Scanner" |
    "ServiceLoader" |
    "SimpleTimeZone" |
    "Spliterators" |
    "Spliterators.AbstractDoubleSpliterator" |
    "Spliterators.AbstractIntSpliterator" |
    "Spliterators.AbstractLongSpliterator" |
    "Spliterators.AbstractSpliterator" |
    "SpliteratorRandom" |
    "Stack" |
    "StringJoiner" |
    "StringTokenizer" |
    "Timer" |
    "TimerTask" |
    "TimeZone" |
    "TreeMap" |
    "TreeSet" |
    "UUID" |
    "Vector" |
    "WeakHashMap" |

    "Formatter.BigDecimalLayoutForm" |
    "Locale.Category" |
    "Locale.FilteringMode" |

    "ConcurrentModificationException" |
    "DuplicateFormatFlagsException" |
    "EmptyStackException" |
    "FormatFlagsConversionMismatchException" |
    "FormatterClosedException" |
    "IllegalFormatCodePointException" |
    "IllegalFormatConversionException" |
    "IllegalFormatException" |
    "IllegalFormatFlagsException" |
    "IllegalFormatPrecisionException" |
    "IllegalFormatWidthException" |
    "IllformedLocaleException" |
    "InputMismatchException" |
    "InvalidPropertiesFormatException" |
    "MissingFormatArgumentException" |
    "MissingFormatWidthException" |
    "MissingResourceException" |
    "NoSuchElementException" |
    "TooManyListenersException" |
    "UnknownFormatConversionException" |
    "UnknownFormatFlagsException" |

    "ServiceConfigurationError" 		{ addToken(Token.FUNCTION); }

	{LineTerminator}				{ addNullToken(); return firstToken; }

	{Identifier}					{ addToken(Token.IDENTIFIER); }

	{WhiteSpace}+					{ addToken(Token.WHITESPACE); }

	/* String/Character literals. */
	{CharLiteral}					{ addToken(Token.LITERAL_CHAR); }
	{UnclosedCharLiteral}			{ addToken(Token.ERROR_CHAR); addNullToken(); return firstToken; }
	{ErrorCharLiteral}				{ addToken(Token.ERROR_CHAR); }
	{StringLiteral}				{ addToken(Token.LITERAL_STRING_DOUBLE_QUOTE); }
	{UnclosedStringLiteral}			{ addToken(Token.ERROR_STRING_DOUBLE); addNullToken(); return firstToken; }
	{ErrorStringLiteral}			{ addToken(Token.ERROR_STRING_DOUBLE); }

	/* Comment literals. */
	"/**/"						{ addToken(Token.COMMENT_MULTILINE); }
	{MLCBegin}					{ start = zzMarkedPos-2; yybegin(MLC); }
	{DocCommentBegin}				{ start = zzMarkedPos-3; yybegin(DOCCOMMENT); }
	{LineCommentBegin}			{ start = zzMarkedPos-2; yybegin(EOL_COMMENT); }

	/* Annotations. */
	{Annotation}					{ addToken(Token.ANNOTATION); }

	/* Separators. */
	{Separator}					{ addToken(Token.SEPARATOR); }
	{Separator2}					{ addToken(Token.SEPARATOR); }

	/* Operators. */
	{Operator}					{ addToken(Token.OPERATOR); }

	/* Numbers */
	{IntegerLiteral}				{ addToken(Token.LITERAL_NUMBER_DECIMAL_INT); }
	{BinaryLiteral}					{ addToken(Token.LITERAL_NUMBER_DECIMAL_INT); }
	{HexLiteral}					{ addToken(Token.LITERAL_NUMBER_HEXADECIMAL); }
	{FloatLiteral}					{ addToken(Token.LITERAL_NUMBER_FLOAT); }
	{ErrorNumberFormat}				{ addToken(Token.ERROR_NUMBER_FORMAT); }

	{ErrorIdentifier}				{ addToken(Token.ERROR_IDENTIFIER); }

	/* Ended with a line not in a string or comment. */
	<<EOF>>						{ addNullToken(); return firstToken; }

	/* Catch any other (unhandled) characters and flag them as identifiers. */
	.							{ addToken(Token.ERROR_IDENTIFIER); }

}


<MLC> {

	[^hwf\n\*]+				{}
	{URL}					{ int temp=zzStartRead; addToken(start,zzStartRead-1, Token.COMMENT_MULTILINE); addHyperlinkToken(temp,zzMarkedPos-1, Token.COMMENT_MULTILINE); start = zzMarkedPos; }
	[hwf]					{}

	\n						{ addToken(start,zzStartRead-1, Token.COMMENT_MULTILINE); return firstToken; }
	{MLCEnd}					{ yybegin(YYINITIAL); addToken(start,zzStartRead+1, Token.COMMENT_MULTILINE); }
	\*						{}
	<<EOF>>					{ addToken(start,zzStartRead-1, Token.COMMENT_MULTILINE); return firstToken; }

}


<DOCCOMMENT> {

	[^hwf\@\{\n\<\*]+			{}
	{URL}						{ int temp=zzStartRead; addToken(start,zzStartRead-1, Token.COMMENT_DOCUMENTATION); addHyperlinkToken(temp,zzMarkedPos-1, Token.COMMENT_DOCUMENTATION); start = zzMarkedPos; }
	[hwf]						{}

	"@"{BlockTag}				{ int temp=zzStartRead; addToken(start,zzStartRead-1, Token.COMMENT_DOCUMENTATION); addToken(temp,zzMarkedPos-1, Token.COMMENT_KEYWORD); start = zzMarkedPos; }
	"@"							{}
	"{@"{InlineTag}[^\}]*"}"	{ int temp=zzStartRead; addToken(start,zzStartRead-1, Token.COMMENT_DOCUMENTATION); addToken(temp,zzMarkedPos-1, Token.COMMENT_KEYWORD); start = zzMarkedPos; }
	"{"							{}
	\n							{ addToken(start,zzStartRead-1, Token.COMMENT_DOCUMENTATION); return firstToken; }
	"<"[/]?({Letter}[^\>]*)?">"	{ int temp=zzStartRead; addToken(start,zzStartRead-1, Token.COMMENT_DOCUMENTATION); addToken(temp,zzMarkedPos-1, Token.COMMENT_MARKUP); start = zzMarkedPos; }
	\<							{}
	{MLCEnd}					{ yybegin(YYINITIAL); addToken(start,zzStartRead+1, Token.COMMENT_DOCUMENTATION); }
	\*							{}
	<<EOF>>						{ yybegin(YYINITIAL); addToken(start,zzEndRead, Token.COMMENT_DOCUMENTATION); return firstToken; }

}


<EOL_COMMENT> {
	[^hwf\n]+				{}
	{URL}					{ int temp=zzStartRead; addToken(start,zzStartRead-1, Token.COMMENT_EOL); addHyperlinkToken(temp,zzMarkedPos-1, Token.COMMENT_EOL); start = zzMarkedPos; }
	[hwf]					{}
	\n						{ addToken(start,zzStartRead-1, Token.COMMENT_EOL); addNullToken(); return firstToken; }
	<<EOF>>					{ addToken(start,zzStartRead-1, Token.COMMENT_EOL); addNullToken(); return firstToken; }

}