;   Description: Universal lexer with regex-definable tokens
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2019 Sicro
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; ==========================================================================================================================
;- Declaration of module 'Lexer'
; ==========================================================================================================================
DeclareModule Lexer
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Compiler settings
  ; ------------------------------------------------------------------------------------------------------------------------
  EnableExplicit
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Declaration of procedures
  ; ------------------------------------------------------------------------------------------------------------------------
  Declare  Create(*string, maxTokenValueLength=200)
  Declare  Free(*lexer)
  Declare  DefineNewToken(*lexer, tokenType, tokenValueRegEx$, skipToken=#False, tokenName$="")
  Declare  NextToken(*lexer)
  Declare$ TokenName(*lexer)
  Declare  TokenType(*lexer)
  Declare$ TokenValue(*lexer)
  Declare  TokenValueLength(*lexer)
  Declare  StringOffset(*lexer, value=-1)
  Declare  StringLineNumber(*lexer)
  Declare  StringColumnNumber(*lexer)
  Declare$ TokenDefinitionsListTuningInfo(*lexer)
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Definition of structures
  ; ------------------------------------------------------------------------------------------------------------------------
  Structure TokenDefinitionsListStruc
    regEx.i
    skipToken.i
    tokenName$
    tokenType.i
    countOfMatches.i
  EndStructure
  
  Structure LexerStruc
    maxTokenValueLength.i
    newLineRegEx.i ; Needed for 'stringLineNumber' and 'lastNewLineCharacterEndPosition'
    *string
    stringOffset.i
    stringLineNumber.i
    stringColumnNumber.i
    lastNewLineCharacterEndPosition.i ; Needed for 'stringColumnNumber'
    List tokenDefinitionsList.TokenDefinitionsListStruc()
    currentTokenName$
    currentTokenType.i
    currentTokenValue$
    currentTokenValueLength.i
  EndStructure
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Definition of constants
  ; ------------------------------------------------------------------------------------------------------------------------
  #TokenType_Unkown = -1
EndDeclareModule

Module Lexer
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Definition of structures
  ; ------------------------------------------------------------------------------------------------------------------------
  Structure TokenDefinitionsListTuningInfoListStruc
    countOfMatches.i
    tokenName$
    tokenType.i
  EndStructure
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Definition of procedures
  ; ------------------------------------------------------------------------------------------------------------------------
  Procedure Create(*string, maxTokenValueLength=200)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Creates a new lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    |            *string$ -- The pointer to the pointer of the string to be scanned
    ;               | maxTokenValueLength -- Specifies the length of the substring in which a token is to be scanned.
    ;               |                        Too large values slow down the Lexer.
    ;               |                        Too low values can cause the substring to be too short and some tokens can no
    ;               |                        longer be read out completely. It is also possible that some tokens are not
    ;               |                        recognized at all, because the RegEx of the token no longer matches
    ;               |                        (Optional - default is 200)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | On success the handle of the created lexer, otherwise #False
    ; ----------------------------------------------------------------------------------------------------------------------
    Protected *lexer.LexerStruc
    If *string <> 0
      *lexer = AllocateStructure(LexerStruc)
      If *lexer
        With *lexer
          \string           = *string
          \stringOffset     = 1
          \stringLineNumber = 1
          \newLineRegEx     = CreateRegularExpression(#PB_Any, "^(\r\n|\r|\n)")
          \maxTokenValueLength  = maxTokenValueLength
        EndWith
      EndIf
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
      ForEach *lexer\tokenDefinitionsList()
        FreeRegularExpression(*lexer\tokenDefinitionsList()\regEx)
      Next
      FreeStructure(*lexer)
    EndIf
  EndProcedure
  
  Procedure DefineNewToken(*lexer.LexerStruc, tokenType, tokenValueRegEx$, skipToken=#False, tokenName$="")
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Defines a new token for the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    |           *lexer -- The handle of the lexer
    ;               |        tokenType -- A positive, unique number to be assigned to the type of token.
    ;               |                     This number is used later when iterating the tokens to determine the type of the
    ;               |                     current token
    ;               | tokenValueRegEx$ -- A regular expression that matches the desired token
    ;               |                     (T #PB_RegularExpression_NoCase)
    ;               |        skipToken -- Specifies whether the token found is to be skipped or returned
    ;               |                     Possible values are: #True or #False
    ;               |                     (Optional - default is #False) 
    ;               |       tokenName$ -- A string to be used as token name. The token name is the same as the token type,
    ;               |                     but as a string. The token name is not intended to determine the type of a token,
    ;               |                     but only to display the token type as a string, because string comparsions are
    ;               |                     slow
    ;               |                     (Optional - default is "")
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Notes:        | Keep the number of token definitions small. Large token definitions lists slow down the lexer very
    ;               | quickly
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | None
    ; ----------------------------------------------------------------------------------------------------------------------
    Protected result
    With *lexer
      If *lexer And AddElement(\tokenDefinitionsList())
        \tokenDefinitionsList()\tokenType  = tokenType
        \tokenDefinitionsList()\tokenName$ = tokenName$
        \tokenDefinitionsList()\skipToken  = skipToken
        \tokenDefinitionsList()\regEx      = CreateRegularExpression(#PB_Any, "^(?:"+tokenValueRegEx$+")", #PB_RegularExpression_NoCase)
        If \tokenDefinitionsList()\regEx = 0
          Debug "===================================================================================="
          Debug "In the procedure '" + #PB_Compiler_Procedure + "' the creation of this RegEx failed:"
          Debug "    Error in RegEx: " + tokenValueRegEx$
          Debug "    Error message:  " + RegularExpressionError()
          Debug "===================================================================================="
          DeleteElement(\tokenDefinitionsList()) ; Delete the invalid token definition from the token definitions list
          result = #False
        EndIf
        result = #True
      Else
        result = #False
      EndIf
    EndWith
    ProcedureReturn result
  EndProcedure
  
  Procedure NextToken(*lexer.LexerStruc)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Determines the next token
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | #True, if a token was found, otherwise #False
    ; ----------------------------------------------------------------------------------------------------------------------
    Protected found, result
    Protected string$
    If *lexer
      With *lexer
        Repeat
          ; This loop is required to perform a new pass if the current token is to be skipped
          found   = #False
          
          ; Always passing the whole string to "ExamineRegularExpression()" would slow down the lexer very much. Therefore,
          ; only a limited length of the string is passed
          string$ = PeekS(\string + (\stringOffset - 1) * SizeOf(Character), \maxTokenValueLength)
          
          If string$ = "" : Break : EndIf
          ; Check whether a new line of code begins
          If ExamineRegularExpression(\newLineRegEx, string$) And NextRegularExpressionMatch(\newLineRegEx)
            \stringLineNumber + 1
            \lastNewLineCharacterEndPosition = \stringOffset + RegularExpressionMatchLength(\newLineRegEx)
          EndIf
          ForEach \tokenDefinitionsList()
            ; Compare current string with all defined tokens
            If ExamineRegularExpression(\tokenDefinitionsList()\regEx, string$) And NextRegularExpressionMatch(\tokenDefinitionsList()\regEx)
              found = #True
              \tokenDefinitionsList()\countOfMatches + 1
              \stringColumnNumber = \stringOffset - \lastNewLineCharacterEndPosition + 1
              \stringOffset + RegularExpressionMatchLength(\tokenDefinitionsList()\regEx)
              If Not \tokenDefinitionsList()\skipToken
                \currentTokenType        = \tokenDefinitionsList()\tokenType
                \currentTokenName$       = \tokenDefinitionsList()\tokenName$
                \currentTokenValue$      = RegularExpressionMatchString(\tokenDefinitionsList()\regEx)
                \currentTokenValueLength = RegularExpressionMatchLength(\tokenDefinitionsList()\regEx)
                result = #True
                Break 2 ; New token was found. Exit procedure
              Else
                Break ; Token to skip found. Start a new loop pass to find the next token
              EndIf
            EndIf
          Next
          If Not found
            ; The current string contains characters that do not match any of the defined tokens. In this case, a token of
            ; type "Unknown" is created
            \currentTokenType   = #TokenType_Unkown
            \currentTokenName$  = "Unkown"
            \currentTokenValue$ = Left(string$, 1)
            \stringColumnNumber = \stringOffset - \lastNewLineCharacterEndPosition + 1
            \stringOffset       + 1
            result = #True
            Break
          EndIf
        ForEver
      EndWith
    EndIf
    ProcedureReturn result
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
      ProcedureReturn *lexer\currentTokenName$
    EndIf
  EndProcedure
  
  Procedure TokenType(*lexer.LexerStruc)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Returns the type of the current token
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | Token type. On error: -1
    ; ----------------------------------------------------------------------------------------------------------------------
    If *lexer
      ProcedureReturn *lexer\currentTokenType
    Else
      ProcedureReturn -1
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
      ProcedureReturn *lexer\currentTokenValue$
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
      ProcedureReturn *lexer\currentTokenValueLength
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
    If *lexer
      If value > -1
        *lexer\stringOffset = value
      EndIf
      ProcedureReturn *lexer\stringOffset
    Else
      ProcedureReturn -1
    EndIf
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
      ProcedureReturn *lexer\stringLineNumber
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
  
  Procedure$ TokenDefinitionsListTuningInfo(*lexer.LexerStruc)
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Description:  | Helps to optimize the order of the token definitions in the token definitions list.
    ;               | The Lexer counts during his work how often each individual token definition was found. With this
    ;               | information it is clear how the list of token definitions must be sorted in order to minimize
    ;               | unnecessary iterations
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Parameter:    | *lexer -- The handle of the lexer
    ; ----------------------------------------------------------------------------------------------------------------------
    ; Return value: | The token definitions list in optimized order
    ; ----------------------------------------------------------------------------------------------------------------------
    Protected result$ = #CRLF$ + "Best token list order:" ; Add '#CRLF$' at the beginning of 'result$' to make sure that the
                                                          ; output is cleanly listed in the log of the PB-IDE, even if the
                                                          ; time display is enabled
    Protected NewList tokenDefinitionsListTuningInfoList.TokenDefinitionsListTuningInfoListStruc()
    With tokenDefinitionsListTuningInfoList()
      ; Maps can not be sorted. Therefore, a list must be created and all map elements to be sorted must be inserted in this
      ; list.
      ForEach *lexer\tokenDefinitionsList()
        If AddElement(tokenDefinitionsListTuningInfoList())
          \countOfMatches = *lexer\tokenDefinitionsList()\countOfMatches
          \tokenName$     = *lexer\tokenDefinitionsList()\tokenName$
          \tokenType      = *lexer\tokenDefinitionsList()\tokenType
        EndIf
      Next
      SortStructuredList(tokenDefinitionsListTuningInfoList(), #PB_Sort_Descending,
                         OffsetOf(TokenDefinitionsListTuningInfoListStruc\countOfMatches), #PB_Integer)
      ; Combine the entries of the sorted list in a string
      ForEach tokenDefinitionsListTuningInfoList()
        result$ = #CRLF$ +
                  "[" +
                  "TokenType: " + Str(\tokenType) +
                  " | " +
                  "TokenName: " + \tokenName$ +
                  "]" +
                  " (" + Str(\countOfMatches) + " times of matches)"
      Next
    EndWith
    ProcedureReturn result$
  EndProcedure
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
  ;- > Definition of enumerations
  ; ------------------------------------------------------------------------------------------------------------------------
  Enumeration TokenType
    #TokenType_ArrowBracketOpen
    #TokenType_ArrowBracketClose
    #TokenType_Operator
    #TokenType_String
    #TokenType_Identifier
    #TokenType_Whitespace
  EndEnumeration
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Definition of local variables
  ; ------------------------------------------------------------------------------------------------------------------------
  Define *lexer
  Define htmlCode$ = ~"<html><head><title></title></head><body><a href=\"url\" style='color: green;'></a></body></html>"
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Create lexer
  ; ------------------------------------------------------------------------------------------------------------------------
  *lexer = Lexer::Create(@htmlCode$)
  If *lexer = 0
    Debug "Lexer can't be created!"
    End
  EndIf
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Definition of all token types
  ; ------------------------------------------------------------------------------------------------------------------------
  Lexer::DefineNewToken(*lexer, #TokenType_ArrowBracketOpen, "</?", #False, "ArrowBracketOpen")
  
  Lexer::DefineNewToken(*lexer, #TokenType_ArrowBracketClose, ">", #False, "ArrowBracketClose")
  
  Lexer::DefineNewToken(*lexer, #TokenType_Operator, "=", #False, "Operator")
  
  Lexer::DefineNewToken(*lexer, #TokenType_String, ~"(['\"]).*?\\1", #False, "String")
  
  Lexer::DefineNewToken(*lexer, #TokenType_Identifier, "[A-Z]+", #False, "Identifier")
  
  Lexer::DefineNewToken(*lexer, #TokenType_Whitespace, "\s+", #True)
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Iterate through all tokens
  ; ------------------------------------------------------------------------------------------------------------------------
  While Lexer::NextToken(*lexer)
    If Lexer::TokenType(*lexer) <> Lexer::#TokenType_Unkown
      Debug RSet(Lexer::TokenName(*lexer), 17) + " (" + Str(Lexer::TokenType(*lexer)) + "): " + Lexer::TokenValue(*lexer)
    Else
      ; Character found that does not match any RegEx of the defined token types. Possibly a syntax error or the character
      ; was forgotten when defining the token types
      Debug Lexer::TokenName(*lexer) + ": " + Lexer::TokenValue(*lexer)
    EndIf
  Wend
  
  ; ------------------------------------------------------------------------------------------------------------------------
  ;- > Free lexer
  ; ------------------------------------------------------------------------------------------------------------------------
  Lexer::Free(*lexer)
CompilerEndIf
