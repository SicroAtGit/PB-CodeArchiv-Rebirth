
IncludeFile "../../RegularExpression/RegEx-Engine/Source/RegExEngine.pbi"

Enumeration TokenTypes
  #TokenType_Whitespace
  #TokenType_Newline
  #TokenType_Identifier
  #TokenType_Separator
  #TokenType_Operator
  #TokenType_Keyword
  #TokenType_Comment
  #TokenType_Number
  #TokenType_String
  #TokenType_Constant
  #TokenType_Period
  #TokenType_Colon
  #TokenType_DoubleColon ; ModuleName::ObjectName
EndEnumeration

Define *lexer = RegEx::Init()

RegEx::AddNfa(*lexer, "[ \t]", #TokenType_Whitespace)

RegEx::AddNfa(*lexer, "(\r\n|\r|\n)", #TokenType_Newline)

RegEx::AddNfa(*lexer, ":", #TokenType_Colon)

RegEx::AddNfa(*lexer, "::", #TokenType_DoubleColon)

RegEx::AddNfa(*lexer, "[()\[\]{}\\:,]", #TokenType_Separator)

RegEx::AddNfa(*lexer, "[A-Z_][A-Z0-9_]*$?", #TokenType_Identifier, RegEx::#RegExMode_NoCase | RegEx::#RegExMode_Ascii)

RegEx::AddNfa(*lexer, "(align|Array|As|Break|CallDebugger|Case|CompilerCase|CompilerDefault|CompilerElse|CompilerElseIf|" +
                      "compilerendif|compilerendselect|compilererror|compilerif|compilerselect|compilerwarning|continue|data|" +
                      "datasection|debug|debuglevel|declare|declarec|declarecdll|declaredll|declaremodule|default|define|dim|" +
                      "disableasm|disabledebugger|disableexplicit|else|elseif|enableasm|enabledebugger|enableexplicit|end|" +
                      "enddatasection|enddeclaremodule|endenumeration|endif|endimport|endinterface|endmacro|endmodule|endprocedure|" +
                      "endselect|endstructure|endstructureunion|endwith|enumeration|enumerationbinary|extends|fakereturn|for|foreach|" +
                      "forever|global|gosub|goto|if|import|importc|includebinary|includefile|includepath|interface|list|macro|" +
                      "macroexpandedcount|map|module|newlist|newmap|next|procedure|procedurec|procedurecdll|proceduredll|" +
                      "procedurereturn|protected|prototype|prototypec|read|redim|repeat|restore|return|runtime|select|shared|static|" +
                      "step|structure|structureunion|swap|threaded|to|undefinemacro|until|unusemodule|usemodule|wend|while|with|" +
                      "xincludefile)$?", #TokenType_Keyword, RegEx::#RegExMode_NoCase | RegEx::#RegExMode_Ascii)

RegEx::AddNfa(*lexer, ~"(\"[^\"]*\")|(~\"([^\"]|(\\\\\"))*\")|('[^']*')", #TokenType_String)

RegEx::AddNfa(*lexer, "and|or|xor|not|<<|>>|<=|>=|=<|=>|[|+\-*/!%&<>=@?~]", #TokenType_Operator, RegEx::#RegExMode_NoCase | RegEx::#RegExMode_Ascii)

RegEx::AddNfa(*lexer, ";[^\r\n]*", #TokenType_Comment)

RegEx::AddNfa(*lexer, "[0-9]+(\.[0-9]+)?(e([ \t]*[+\-][ \t]*)?[0-9]+)?" + ; Integers, decimal numbers and binary numbers
                      "|" +
                      "$[ \t]*[0-9A-F]+" + ; Hexadecimal numbers
                      "|" +
                      "'[^']*'", #TokenType_Number, RegEx::#RegExMode_NoCase | RegEx::#RegExMode_Ascii)

RegEx::AddNfa(*lexer, "#[ \t]*[A-Z_]+[A-Z0-9_]*$?", #TokenType_Constant, RegEx::#RegExMode_NoCase | RegEx::#RegExMode_Ascii)

RegEx::AddNfa(*lexer, "\.", #TokenType_Period)

RegEx::CreateDfa(*lexer)
RegEx::ExportDfa(*lexer, "DFA.dat")

RegEx::Free(*lexer)
