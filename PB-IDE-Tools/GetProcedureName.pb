;   Description: Find the name of the procedure of the current cursor position
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28267
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014-2015 Kiffi
; Copyright (c) 2014 Sicro
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

; Tool Settings:
; - Arguments: "%TEMPFILE"
; - Event:     Menu Or Shortcut

EnableExplicit

Procedure.s RemoveLeadingWhitespaceFromString(InString.s)
  
  While Left(InString, 1) = Chr(32) Or Left(InString, 1) = Chr(9)
    InString = LTrim(InString, Chr(32))
    InString = LTrim(InString, Chr(9))
  Wend
  
  ProcedureReturn InString
  
EndProcedure

Procedure.s GetScintillaText()
  
  ; thx to sicro (http://www.purebasic.fr/german/viewtopic.php?p=324916#p324916)
  
  Protected ReturnValue.s
  Protected FilePath.s
  Protected File, BOM
  
  FilePath = ProgramParameter(0) ; %TEMPFILE (Datei existiert auch, wenn Code nicht gespeichert ist)
  
  File = ReadFile(#PB_Any, FilePath, #PB_File_SharedRead)
  If IsFile(File)
    BOM = ReadStringFormat(File) ; BOM überspringen, wenn vorhanden
    ReturnValue = ReadString(File, #PB_File_IgnoreEOL | BOM)
    CloseFile(File)
  EndIf
  
  ProcedureReturn ReturnValue
  
EndProcedure

Define ScintillaText.s
Define CursorLine = Val(StringField(GetEnvironmentVariable("PB_TOOL_Cursor"), 1, "x"))
Define Line.s
Define LineCounter

ScintillaText = GetScintillaText()

CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
    #LineFeed = #CRLF$
  CompilerDefault
    #LineFeed = #LF$
CompilerEndSelect

If ScintillaText <> ""
  
  For LineCounter = CursorLine - 1 To 1 Step - 1
    
    Line = RemoveLeadingWhitespaceFromString(StringField(ScintillaText, LineCounter, #LineFeed))
    
    If Left(LCase(Line), Len("endprocedure")) = "endprocedure"
      Break
    EndIf
    
    If Left(LCase(Line), Len("procedure")) = "procedure"
      If Left(LCase(Line), Len("procedurereturn")) <> "procedurereturn"
        MessageRequester("You are here:", Line)
        Break
      EndIf
    EndIf
    
  Next
  
EndIf
