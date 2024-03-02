
; ==========================================================================================================================
;- Inclusions of code files
; ==========================================================================================================================
XIncludeFile "../../RegularExpression/RegEx-Engine/Source/DfaMatcher.pbi"

; ==========================================================================================================================
;- Declaration of module 'PBLexer'
; ==========================================================================================================================
DeclareModule PBLexer
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Compiler settings
  ; ------------------------------------------------------------------------------------------------------------------------
  EnableExplicit
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Declaration of procedures
  ; ------------------------------------------------------------------------------------------------------------------------
  Declare  Create(*string, includeWhitespaceTokens=#False, includeCommentTokens=#False)
  Declare  Free(*lexer)
  Declare  NextToken(*lexer)
  Declare$ TokenName(*lexer)
  Declare  TokenType(*lexer)
  Declare$ TokenValue(*lexer)
  Declare  TokenValueLength(*lexer)
  Declare  StringOffset(*lexer, value=-1)
  Declare  StringLineNumber(*lexer)
  Declare  StringColumnNumber(*lexer)
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Definition of constants
  ; ------------------------------------------------------------------------------------------------------------------------
  Enumeration
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
    #TokenType_Unknown
    #TokenType_EndOfString
  EndEnumeration
  
EndDeclareModule

Module PBLexer
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Definition of structures
  ; ------------------------------------------------------------------------------------------------------------------------
  Structure LexerStruc
    *string.Unicode
    *stringStartPosition ; Needed for StringOffset()
    includeWhitespaceTokens.i
    includeCommentTokens.i
    stringLineNumber.i
    stringColumnNumber.i
    *lastNewLineCharacterEndPosition ; Needed for StringColumnNumber()
    currentTokenType.i
    currentTokenValueLength.i
  EndStructure
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Create token names array
  ; ------------------------------------------------------------------------------------------------------------------------
  Global Dim TokenNames$(#TokenType_EndOfString)
  TokenNames$(#TokenType_Whitespace)  = "Whitespace"
  TokenNames$(#TokenType_Newline)     = "Newline"
  TokenNames$(#TokenType_Identifier)  = "Identifier"
  TokenNames$(#TokenType_Separator)   = "Separator"
  TokenNames$(#TokenType_Operator)    = "Operator"
  TokenNames$(#TokenType_Keyword)     = "Keyword"
  TokenNames$(#TokenType_Comment)     = "Comment"
  TokenNames$(#TokenType_Number)      = "Number"
  TokenNames$(#TokenType_String)      = "String"
  TokenNames$(#TokenType_Constant)    = "Constant"
  TokenNames$(#TokenType_Period)      = "Period"
  TokenNames$(#TokenType_Colon)       = "Colon"
  TokenNames$(#TokenType_DoubleColon) = "DoubleColon"
  TokenNames$(#TokenType_Unknown)     = "Unknown"
  TokenNames$(#TokenType_EndOfString) = "EndOfString"
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Definition of procedures
  ; ------------------------------------------------------------------------------------------------------------------------
  Procedure Create(*string, includeWhitespaceTokens=#False, includeCommentTokens=#False)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Creates a new lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    |                 *string -- Pointer to the pointer of the string to be scanned
    ;               | includeWhitespaceTokens -- Specifies whether white-space tokens should be created
    ;               |                            (Optional - default is #False)
    ;               |    includeCommentTokens -- Specifies whether comment tokens should be created
    ;               |                            (Optional - default is #False)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | On success the handle of the created lexer, otherwise #False
    ; ----------------------------------------------------------------------------------------------------------------------
    Protected.LexerStruc *lexer
    If *string = 0
      ProcedureReturn #False
    EndIf
    *lexer = AllocateStructure(LexerStruc)
    If *lexer
      *lexer\string = *string
      *lexer\stringStartPosition = *string
      *lexer\includeWhitespaceTokens = includeWhitespaceTokens
      *lexer\includeCommentTokens = includeCommentTokens
      *lexer\stringLineNumber = 1
      *lexer\stringColumnNumber = 1
      *lexer\lastNewLineCharacterEndPosition = *string
    EndIf
    ProcedureReturn *lexer
  EndProcedure
  
  Procedure Free(*lexer.LexerStruc)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Frees the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer to be freed
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | None
    ; ----------------------------------------------------------------------------------------------------------------------
    If *lexer
      FreeStructure(*lexer)
    EndIf
  EndProcedure
  
  Procedure NextToken(*lexer.LexerStruc)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Determines the next token
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | #True, if a token was found, otherwise #False
    ; ----------------------------------------------------------------------------------------------------------------------
    Protected length, type
    If *lexer = 0
      ProcedureReturn #False
    EndIf
    While *lexer\string\u
      length = DfaMatcher::Match(?dfaTable, *lexer\string, @type)
      If length
        Select type
          Case #TokenType_Whitespace
            *lexer\stringColumnNumber = ((*lexer\string - *lexer\lastNewLineCharacterEndPosition) >> 1) + 1
            If *lexer\includeWhitespaceTokens = #False
              *lexer\string + length
              length = 0
              Continue
            EndIf
          Case #TokenType_Comment
            *lexer\stringColumnNumber = ((*lexer\string - *lexer\lastNewLineCharacterEndPosition) >> 1) + 1
            If *lexer\includeCommentTokens = #False
              *lexer\string + length
              length = 0
              Continue
            EndIf
          Case #TokenType_Newline
            *lexer\stringLineNumber + 1
            *lexer\stringColumnNumber = ((*lexer\string - *lexer\lastNewLineCharacterEndPosition) >> 1) + 1
            *lexer\lastNewLineCharacterEndPosition = *lexer\string + length
          Default
            *lexer\stringColumnNumber = ((*lexer\string - *lexer\lastNewLineCharacterEndPosition) >> 1) + 1
        EndSelect
      EndIf
      Break
    Wend
    If length
      *lexer\currentTokenValueLength = length
      *lexer\currentTokenType = type
      *lexer\string + length
      ProcedureReturn #True
    ElseIf *lexer\string\u <> 0
      length = SizeOf(Unicode)
      *lexer\currentTokenValueLength = length
      *lexer\currentTokenType = #TokenType_Unknown
      *lexer\string + length
      ProcedureReturn #True
    Else
      *lexer\currentTokenValueLength = 0
      *lexer\currentTokenType = #TokenType_EndOfString
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  Procedure$ TokenName(*lexer.LexerStruc)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Returns the name of the current token
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | Token name
    ; ----------------------------------------------------------------------------------------------------------------------
    If *lexer
      ProcedureReturn TokenNames$(*lexer\currentTokenType)
    EndIf
  EndProcedure
  
  Procedure TokenType(*lexer.LexerStruc)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Returns the type of the current token
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | Token type. On error: #TokenType_Unknown
    ; ----------------------------------------------------------------------------------------------------------------------
    If *lexer
      ProcedureReturn *lexer\currentTokenType
    Else
      ProcedureReturn #TokenType_Unknown
    EndIf
  EndProcedure
  
  Procedure$ TokenValue(*lexer.LexerStruc)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Returns the value of the current token
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | Token value
    ; ----------------------------------------------------------------------------------------------------------------------
    If *lexer
      ProcedureReturn DfaMatcher::GetString(*lexer\string - *lexer\currentTokenValueLength, *lexer\currentTokenValueLength)
    EndIf
  EndProcedure
  
  Procedure TokenValueLength(*lexer.LexerStruc)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Returns the value length of the current token
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | Token value length. On error: -1
    ; ----------------------------------------------------------------------------------------------------------------------
    If *lexer
      ProcedureReturn *lexer\currentTokenValueLength >> 1 ; Fast division by 2
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  
  Procedure StringOffset(*lexer.LexerStruc, value=-1)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Returns or sets the current string offset from the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer
    ;               | value  -- The new string offset
    ;               |           (Optional - default is -1 (set nothing))
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | String offset. On error: -1
    ; ----------------------------------------------------------------------------------------------------------------------
    If *lexer = 0
      ProcedureReturn -1
    EndIf
    If value <> -1
      *lexer\string = *lexer\stringStartPosition + value
    EndIf
    ProcedureReturn *lexer\string - *lexer\stringStartPosition
  EndProcedure
  
  Procedure StringLineNumber(*lexer.LexerStruc)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Returns the current string line number from the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | String line number. On error: -1
    ; ----------------------------------------------------------------------------------------------------------------------
    If *lexer
      If *lexer\currentTokenType = #TokenType_Newline
        ProcedureReturn *lexer\stringLineNumber - 1
      Else
        ProcedureReturn *lexer\stringLineNumber
      EndIf
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  
  Procedure StringColumnNumber(*lexer.LexerStruc)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Returns the current column number from the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | String column number. On error: -1
    ; ----------------------------------------------------------------------------------------------------------------------
    If *lexer
      ProcedureReturn *lexer\stringColumnNumber
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Data section
  ; ------------------------------------------------------------------------------------------------------------------------
  DataSection
    dfaTable:
    IncludeBinary "DFA.dat"
  EndDataSection
  
EndModule

; ==========================================================================================================================
;- Example code
; ==========================================================================================================================
CompilerIf #PB_Compiler_IsMainFile
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Compiler settings
  ; ------------------------------------------------------------------------------------------------------------------------
  EnableExplicit
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Definition of procedures
  ; ------------------------------------------------------------------------------------------------------------------------
  Procedure$ GetContentOfFile(fileName$)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Returns the complete content of the file
    ;               | Supported BOMs: Ascii, UTF8, Unicode
    ;               | In case of a unsupported BOM the file will be readed as UTF8
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | fileName$
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | File content
    ; ----------------------------------------------------------------------------------------------------------------------
    Protected file, stringFormat
    Protected content$
    file = ReadFile(#PB_Any, fileName$)
    If file
      stringFormat = ReadStringFormat(file)
      Select stringFormat
        Case #PB_Ascii, #PB_UTF8, #PB_Unicode
        Default
          ; ReadString() supports fewer string formats than ReadStringFormat(), so in case of an
          ; unsupported format it is necessary to fall back to a supported format
          stringFormat = #PB_UTF8
      EndSelect
      content$ = ReadString(file, stringFormat|#PB_File_IgnoreEOL)
      CloseFile(file)
    EndIf
    ProcedureReturn content$
  EndProcedure
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Definition of local variables
  ; ------------------------------------------------------------------------------------------------------------------------
  Define fileName$ = #PB_Compiler_File ; For the example, the PBLexer code file itself is used
  Define code$
  Define *pbLexer
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Read code file
  ; ------------------------------------------------------------------------------------------------------------------------
  code$ = GetContentOfFile(fileName$)
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Create lexer
  ; ------------------------------------------------------------------------------------------------------------------------
  *pbLexer = PBLexer::Create(@code$, #True, #True)
  If *pbLexer = 0
    Debug "PBLexer can't be created!"
    End
  EndIf
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Lex the PB code and output the token types and the token values as debug output
  ; ------------------------------------------------------------------------------------------------------------------------
  While PBLexer::NextToken(*pbLexer)
    Debug "[" + PBLexer::TokenName(*pbLexer) + "]: " + PBLexer::TokenValue(*pbLexer)
  Wend
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Free lexer
  ; ------------------------------------------------------------------------------------------------------------------------
  PBLexer::Free(*pbLexer)
CompilerEndIf
