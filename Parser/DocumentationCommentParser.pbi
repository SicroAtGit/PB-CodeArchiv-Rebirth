﻿;   Description: Parses the documentation comments in the code (also inside includes)
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2019-2020 Sicro
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

; =============================================================================
;- Include code files
; =============================================================================

XIncludeFile "../Lexer/PBLexer.pbi"

DeclareModule DocumentationCommentParser
    
    ; =========================================================================
    ;- Set compiler settings
    ; =========================================================================
    
    EnableExplicit
    
    ; =========================================================================
    ;- Set debugger settings
    ; =========================================================================
    
    ;DebugLevel 1
    
    ; =========================================================================
    ;- Define structures
    ; =========================================================================
    
    Structure DocumentationCommentStruc
        comment_summary$
        comment_paramTotal.i
        Map comment_param$()
        comment_return$
        comment_example$
    EndStructure
    
    ; =========================================================================
    ;- Declare procedure
    ; =========================================================================
    
    Declare  ParseFile(filePath$, Map procedures.DocumentationCommentStruc())
    
    Declare  ProcessToken(*lexer, currentDirectory$,
                          Map procedures.DocumentationCommentStruc())
    Declare  ProcessParsing(filePath$, Map procedures.DocumentationCommentStruc())
    
    Declare$ ProcessIncludePathKeyword(*lexer, currentDirectory$)
    Declare  ProcessIncludeFileKeyword(*lexer, currentDirectory$,
                                       Map procedures.DocumentationCommentStruc())
    Declare  ProcessXIncludeFileKeyword(*lexer, currentDirectory$,
                                        Map procedures.DocumentationCommentStruc())
    
    Declare$ ProcessProcedureParameters(*lexer)
    Declare  ProcessProcedure(*lexer, Map procedures.DocumentationCommentStruc())
    
    Declare  ProcessMacro(*lexer)
    Declare  ProcessConstant(*lexer)
    Declare  ProcessComment(*lexer)
    Declare  ProcessDocumentationComment(*lexer)
    
    ; Resolves recursively all constants, macros and strings
    Declare$ ResolveValue(value$)
    
    Declare$ GetStringInsideOf(string$, startString$, endString$)
    Declare$ RemoveAnyLeadingSpaces(string$)
    
EndDeclareModule

Module DocumentationCommentParser
    
    ; =========================================================================
    ;- Include code files
    ; =========================================================================
    
    XIncludeFile "../FileSystem/IsAbsolutePath.pbi"
    XIncludeFile "../File/GetFileContentAsString.pbi"
    
    ; =========================================================================
    ;- Define local variables
    ; =========================================================================
    
    NewMap constants$()
    NewMap macros$()
    Define currentDocumentationComment.DocumentationCommentStruc
    
    ; The value of the items are not needed, so we use the smallest variable
    ; type to safe memory space
    NewMap xIncludedFilePaths.b()
    
    ; =========================================================================
    ;- Define procedures
    ; =========================================================================
    
    Procedure ParseFile(filePath$, Map procedures.DocumentationCommentStruc())
        Shared constants$(), macros$(), xIncludedFilePaths(),
               currentDocumentationComment
        
        ClearMap(procedures())
        ClearMap(constants$())
        ClearMap(macros$())
        ClearMap(xIncludedFilePaths())
        ResetStructure(@currentDocumentationComment, DocumentationCommentStruc)
        
        ProcedureReturn ProcessParsing(filePath$,
                                       procedures.DocumentationCommentStruc())
    EndProcedure
    
    Procedure ProcessToken(*lexer, currentDirectory$,
                           Map procedures.DocumentationCommentStruc())
        Select PBLexer::TokenType(*lexer)
            Case PBLexer::#TokenType_Keyword
                Select LCase(PBLexer::TokenValue(*lexer))
                    Case "procedure", "procedure$"
                        ProcessProcedure(*lexer, procedures())
                    Case "macro"
                        ProcessMacro(*lexer)
                    Case "includepath"
                        currentDirectory$ = ProcessIncludePathKeyword(*lexer,
                                                                      currentDirectory$)
                    Case "includefile"
                        ProcessIncludeFileKeyword(*lexer, currentDirectory$,
                                                  procedures())
                    Case "xincludefile"
                        ProcessXIncludeFileKeyword(*lexer, currentDirectory$,
                                                   procedures())
                EndSelect
            Case PBLexer::#TokenType_Constant
                ProcessConstant(*lexer)
            Case PBLexer::#TokenType_Comment
                ProcessComment(*lexer)
        EndSelect
    EndProcedure
    
    Procedure ProcessParsing(filePath$, Map procedures.DocumentationCommentStruc())
        Protected code$
        Protected *lexer
        
        Debug "", 1
        Debug "Parse file: " + filePath$, 1
        Debug "", 1
        
        code$ = GetFileContentAsString(filePath$)
        If code$ = ""
            Debug ">>> File could not be read!", 1
            Debug "", 1
            ProcedureReturn #False
        EndIf
        
        *lexer = PBLexer::Create(@code$, 250, #False, #True)
        If Not *lexer
            Debug ">>> Lexer could not be created!", 1
            Debug "", 1
            ProcedureReturn #False
        EndIf
        
        While PBLexer::NextToken(*lexer)
            ProcessToken(*lexer, GetPathPart(filePath$),
                         procedures.DocumentationCommentStruc())
        Wend
        
        PBLexer::Free(*lexer)
        
        ProcedureReturn #True
    EndProcedure
    
    Procedure ProcessMacro(*lexer)
        Protected macroName$, macroValue$
        Shared macros$()
        
        If PBLexer::NextToken(*lexer)
            macroName$ = LCase(PBLexer::TokenValue(*lexer))
        EndIf
        
        ; Skip macro parameters
        ; TODO: Process macro parameters instead of skipping them
        While PBLexer::NextToken(*lexer)
            If PBLexer::TokenType(*lexer) = PBLexer::#TokenType_Newline Or
               PBLexer::TokenValue(*lexer) = ":"
                Break
            EndIf
        Wend
        
        While PBLexer::NextToken(*lexer)
            ; We only support single-line macros on the include keywords
            If PBLexer::TokenType(*lexer) = PBLexer::#TokenType_Newline Or
               PBLexer::TokenValue(*lexer) = ":"
                Break
            EndIf
            macroValue$ + PBLexer::TokenValue(*lexer)
        Wend
        
        AddMapElement(macros$(), macroName$)
        macros$() = macroValue$
        
        Debug "ProcessMacro()", 1
        Debug "  Name:  " + macroName$, 1
        Debug "  Value: " + macroValue$, 1
        Debug "--------------------", 1
    EndProcedure
    
    Procedure$ ProcessIncludePathKeyword(*lexer, currentDirectory$)
        Protected path$
        
        While PBLexer::NextToken(*lexer)
            If PBLexer::TokenType(*lexer) = PBLexer::#TokenType_Newline Or
               PBLexer::TokenValue(*lexer) = ":"
                Break
            EndIf
            path$ + PBLexer::TokenValue(*lexer)
        Wend
        
        If Right(path$, 1) <> #PS$
            path$ + #PS$
        EndIf
        path$ = ResolveValue(path$)
        If Not IsAbsolutePath(path$)
            path$ = currentDirectory$ + path$
        EndIf
        
        Debug "ProcessIncludePathKeyword()", 1
        Debug "  Value: " + path$, 1
        Debug "--------------------", 1
        
        ProcedureReturn path$
    EndProcedure
    
    Procedure ProcessIncludeFileKeyword(*lexer, currentDirectory$,
                                        Map procedures.DocumentationCommentStruc())
        Protected filePath$
        
        While PBLexer::NextToken(*lexer)
            If PBLexer::TokenType(*lexer) = PBLexer::#TokenType_Newline Or
               PBLexer::TokenValue(*lexer) = ":"
                Break
            EndIf
            filePath$ + PBLexer::TokenValue(*lexer)
        Wend
        filePath$ = ResolveValue(filePath$)
        
        If Not IsAbsolutePath(filePath$)
            filePath$ = currentDirectory$ + filePath$
        EndIf
        
        Debug "ProcessIncludeFileKeyword()", 1
        Debug "  Value: " + filePath$, 1
        Debug "--------------------", 1
        
        ProcessParsing(filePath$, procedures.DocumentationCommentStruc())
    EndProcedure
    
    Procedure ProcessXIncludeFileKeyword(*lexer, currentDirectory$,
                                         Map procedures.DocumentationCommentStruc())
        Protected filePath$
        Shared xIncludedFilePaths()
        
        While PBLexer::NextToken(*lexer)
            If PBLexer::TokenType(*lexer) = PBLexer::#TokenType_Newline Or
               PBLexer::TokenValue(*lexer) = ":"
                Break
            EndIf
            filePath$ + PBLexer::TokenValue(*lexer)
        Wend
        
        filePath$ = ResolveValue(filePath$)
        
        If Not IsAbsolutePath(filePath$)
            filePath$ = currentDirectory$ + filePath$
        EndIf
        
        Debug "ProcessXIncludeFileKeyword()", 1
        Debug "  Value: " + filePath$, 1
        
        If Not FindMapElement(xIncludedFilePaths(), filePath$)
            AddMapElement(xIncludedFilePaths(), filePath$)
            Debug "--------------------", 1
            ProcessParsing(filePath$, procedures.DocumentationCommentStruc())
        Else
            ; The file has already been included and the include keyword does
            ; not allow more than one inclusion of the same file, therefore
            ; further inclusions are ignored
            Debug "  >>> Ignore it. File was already included!", 1
            Debug "--------------------", 1
        EndIf
    EndProcedure
    
    Procedure ProcessConstant(*lexer)
        Protected constantName$, constantValue$
        Shared constants$()
        
        constantName$ = LCase(PBLexer::TokenValue(*lexer))
        
        PBLexer::NextToken(*lexer) ; Go to the '=' token
        If PBLexer::TokenValue(*lexer) <> "="
            ; No constant definition
            ProcedureReturn 
        EndIf
        
        While PBLexer::NextToken(*lexer)
            If PBLexer::TokenType(*lexer) = PBLexer::#TokenType_Newline Or
               PBLexer::TokenValue(*lexer) = ":"
                Break
            EndIf
            constantValue$ + PBLexer::TokenValue(*lexer)
        Wend
        
        AddMapElement(constants$(), constantName$)
        constants$() = constantValue$
        
        Debug "ProcessConstant()", 1
        Debug "  Name:  " + constantName$, 1
        Debug "  Value: " + constantValue$, 1
        Debug "--------------------", 1
    EndProcedure
    
    Procedure$ ProcessProcedureParameters(*lexer)
        Protected tokenValue$, parameters$
        Protected roundedBracketsCounter = 1
        
        While PBLexer::NextToken(*lexer)
            tokenValue$ = PBLexer::TokenValue(*lexer)
            
            If PBLexer::TokenType(*lexer) = PBLexer::#TokenType_Newline
                Continue
                
            ElseIf PBLexer::TokenValue(*lexer) = "("
                roundedBracketsCounter + 1
                
            ElseIf PBLexer::TokenValue(*lexer) = ")"
                roundedBracketsCounter - 1
                
            ElseIf PBLexer::TokenType(*lexer) = PBLexer::#TokenType_Keyword
                ; The leading keywords should be separated from the variable
                ; name by a whitespace character
                tokenValue$ + " "
                
            ElseIf PBLexer::TokenValue(*lexer) = ","
                ; After a comma should be a whitespace character
                tokenValue$ + " "
                
            EndIf
            
            If roundedBracketsCounter = 0
                Break
            EndIf
            
            parameters$ + tokenValue$
        Wend
        
        ProcedureReturn parameters$
    EndProcedure
    
    Procedure ProcessProcedure(*lexer,
                               Map procedures.DocumentationCommentStruc())
        Protected procedureReturnType$, procedureName$, procedureParameters$
        Protected tokenValue$
        Protected i
        Shared macros$(), currentDocumentationComment
        
        ; TODO: Support for procedure names with macros
        ; TODO: Support for procedure parameters with macros
        
        If Right(PBLexer::TokenValue(*lexer), 1) = "$"
            procedureReturnType$ = "s"
            PBLexer::NextToken(*lexer) ; Skip "Procedure$"
        Else
            PBLexer::NextToken(*lexer) ; Skip "Procedure"
            If PBLexer::TokenValue(*lexer) = "."
                PBLexer::NextToken(*lexer) ; Skip "."
                procedureReturnType$ = PBLexer::TokenValue(*lexer)
                PBLexer::NextToken(*lexer) ; Skip procedure return type
            Else
                procedureReturnType$ = "i"
            EndIf
        EndIf
        
        ; Process procedure name
        Repeat
            tokenValue$ = PBLexer::TokenValue(*lexer)
            If tokenValue$ = "("
                Break
            EndIf
            procedureName$ + tokenValue$
        Until Not PBLexer::NextToken(*lexer)
        
        procedureParameters$ = ProcessProcedureParameters(*lexer)
        
        Debug "ProcessProcedure()", 1
        Debug "  Return type: " + procedureReturnType$, 1
        Debug "  Name:        " + procedureName$, 1
        Debug "  Parameters:  " + procedureParameters$, 1
        Debug "--------------------", 1
        
        AddMapElement(procedures(), procedureName$)
        CopyStructure(@currentDocumentationComment, procedures(),
                      DocumentationCommentStruc)
        ResetStructure(@currentDocumentationComment, DocumentationCommentStruc)
    EndProcedure
    
    Procedure ProcessComment(*lexer)
        Protected comment$
        
        comment$ = PBLexer::TokenValue(*lexer)
        Debug "ProcessComment()", 1
        Debug "  Comment: " + comment$, 1
        Debug "--------------------", 1
        comment$ = LTrim(comment$, ";")
        If comment$ = "<comment>"
            ProcessDocumentationComment(*lexer)
        EndIf
    EndProcedure
    
    Procedure$ GetStringInsideOf(string$, startString$, endString$)
        Protected startStringPos, endStringPos
        
        startStringPos = FindString(string$, startString$)
        startStringPos + Len(startString$)
        endStringPos   = FindString(string$, endString$, startStringPos + 1)
        
        ProcedureReturn Mid(string$, startStringPos,
                            endStringPos - startStringPos)
    EndProcedure
    
    Procedure$ RemoveAnyLeadingSpaces(string$)
        Repeat
            Select Asc(string$)
                Case ' ', #TAB
                    string$ = LTrim(string$, " ")
                    string$ = LTrim(string$, #TAB$)
                Default
                    Break
            EndSelect
        ForEver
        
        ProcedureReturn string$
    EndProcedure
    
    Procedure ProcessDocumentationCommentTags(comment$)
        Shared currentDocumentationComment
        
        ; https://docs.microsoft.com/en-us/dotnet/csharp/codedoc
        
        With currentDocumentationComment
            If Left(comment$, Len("<summary>")) = "<summary>"
                
                \comment_summary$ = GetStringInsideOf(comment$,
                                                      "<summary>",
                                                      "</summary>")
                
            ElseIf Left(comment$, Len("<param>")) = "<param>"
                
                \comment_paramTotal + 1
                
                AddMapElement(\comment_param$(), Str(\comment_paramTotal))
                
                \comment_param$() = GetStringInsideOf(comment$,
                                                      "<param>",
                                                      "</param>")
                
            ElseIf Left(comment$, Len("<return>")) = "<return>"
                
                \comment_return$ = GetStringInsideOf(comment$,
                                                     "<return>",
                                                     "</return>")
                
            ElseIf Left(comment$, Len("<example>")) = "<example>"
                
                \comment_example$ = GetStringInsideOf(comment$,
                                                      "<example>",
                                                      "</example>")
                
            ElseIf comment$ = "</comment>"
                ProcedureReturn #False
                
            EndIf
        EndWith
        
        ProcedureReturn #True
    EndProcedure
    
    Procedure ProcessDocumentationComment(*lexer)
        Protected comment$
        
        Debug "ProcessDocumentationComment()", 1
        Debug "--------------------", 1
        
        While PBLexer::NextToken(*lexer)
            
            ; Skip process of newline tokens
            If PBLexer::TokenType(*lexer) = PBLexer::#TokenType_Newline
                Continue
            EndIf
            
            comment$ = PBLexer::TokenValue(*lexer)
            comment$ = LTrim(comment$, ";")
            comment$ = RemoveAnyLeadingSpaces(comment$)
            
            If Not ProcessDocumentationCommentTags(comment$)
                Break ; The tag "</comment>" has been reached
            EndIf
        Wend
    EndProcedure
    
    Procedure$ ResolveValue(value$)
        Protected *lexer
        Protected result$, string$, tokenValue$
        Shared constants$(), macros$()
        
        *lexer = PBLexer::Create(@value$)
        If Not *lexer
            ProcedureReturn ""
        EndIf
        
        While PBLexer::NextToken(*lexer)
            tokenValue$ = PBLexer::TokenValue(*lexer)
            
            Select PBLexer::TokenType(*lexer)
                Case PBLexer::#TokenType_Constant
                    result$ + ResolveValue(constants$(LCase(tokenValue$)))
                    
                Case PBLexer::#TokenType_Identifier
                    If FindMapElement(macros$(), LCase(tokenValue$))
                        result$ + ResolveValue(macros$())
                    EndIf
                    
                Case PBLexer::#TokenType_String
                    If Left(tokenValue$, 1) = "~"
                        ; String with escape sequences: ~"string"
                        tokenValue$ = LTrim(tokenValue$, "~")
                        tokenValue$ = UnescapeString(tokenValue$)
                    EndIf
                    result$ + Trim(tokenValue$, #DQUOTE$)
                    
            EndSelect
        Wend
        
        PBLexer::Free(*lexer)
        
        ProcedureReturn result$
    EndProcedure
    
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
    Define filePath$
    NewMap procedures.DocumentationCommentParser::DocumentationCommentStruc()
    
    ; Set the code file to parse and start the process
    filePath$ = OpenFileRequester("Open file", "",
                                  "PureBasic code files|*.pb;*.pbi", 0)
    If FileSize(filePath$) < 1
        MessageRequester("DocumentationCommentParser",
                         "File could not be read or is empty!",
                         #PB_MessageRequester_Error)
        End
    EndIf
    DocumentationCommentParser::ParseFile(filePath$, procedures())
    
    ; Output a list of all documentation comments which have been found
    ForEach procedures()
        If procedures()\comment_summary$
            Debug "Procedure:   " + MapKey(procedures()) + "()"
            Debug "Summary:     " + procedures()\comment_summary$
            
            For i = 1 To procedures()\comment_paramTotal
                Debug "Parameter:   " + procedures()\comment_param$(Str(i))
            Next
            
            Debug "Return:      " + procedures()\comment_return$
            Debug "Example:     " + procedures()\comment_example$
            Debug "------------------------------------"
        EndIf
    Next
CompilerEndIf
