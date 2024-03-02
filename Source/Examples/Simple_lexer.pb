
EnableExplicit

IncludePath ".."
IncludeFile "RegExEngine.pbi"

Enumeration TokenTypes
  #TokenType_Operator_EqualSign
  #TokenType_Operator_Plus
  #TokenType_Number
  #TokenType_String
  #TokenType_Variable
  #TokenType_Whitespace
EndEnumeration

Procedure$ GetTokenTypeName(tokenType)
  Select tokenType
    Case #TokenType_Operator_EqualSign
      ProcedureReturn "Operator_EqualSign"
    Case #TokenType_Operator_Plus
      ProcedureReturn "Operator_Plus"
    Case #TokenType_Number
      ProcedureReturn "Number"
    Case #TokenType_String
      ProcedureReturn "String"
    Case #TokenType_Variable
      ProcedureReturn "Variable"
    Case #TokenType_Whitespace
      ProcedureReturn "Whitespace"
  EndSelect
EndProcedure

Define *lexer = RegEx::Init()
If *lexer = 0
  Debug "Error: Lexer could not be created!"
  End
EndIf

RegEx::AddNfa(*lexer, "=", #TokenType_Operator_EqualSign)
RegEx::AddNfa(*lexer, "\+", #TokenType_Operator_Plus)
RegEx::AddNfa(*lexer, "\d+", #TokenType_Number)
RegEx::AddNfa(*lexer, "'[^']*'", #TokenType_String)
RegEx::AddNfa(*lexer, "[A-Za-z]+", #TokenType_Variable)
RegEx::AddNfa(*lexer, "\s", #TokenType_Whitespace)
; RegEx::CreateDfa(*lexer)

Define code$ = "sum = 100 + 5" + #CRLF$ +
               "string = 'Example text'"

Define *stringPointer = @code$
Define matchLength
Define tokenType

Repeat
  matchLength = RegEx::Match(*lexer, *stringPointer, @tokenType)
  If matchLength
    If tokenType <> #TokenType_Whitespace
      Debug "[" + GetTokenTypeName(tokenType) + "]: " + RegEx::GetString(*stringPointer, matchLength)
      Debug ""
    EndIf
    *stringPointer + matchLength
  EndIf
Until matchLength = 0

RegEx::Free(*lexer)
