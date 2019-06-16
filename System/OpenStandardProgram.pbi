;   Description: Starts the default program for a file type or the default email program with defined data
;            OS: Windows, Linux, Mac
; English-Forum:
;  French-Forum:
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=30942
; -----------------------------------------------------------------------------

; MIT License
;
; Copyright (c) 2018 Sicro
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

Procedure.i OpenWithStandardProgram(FilePath$)
  
  Protected Result
  
  ; Avoid problems with paths containing spaces
  FilePath$ = #DQUOTE$ + FilePath$ + #DQUOTE$
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      ; https://docs.microsoft.com/en-us/windows/desktop/api/shellapi/nf-shellapi-shellexecutew
      Result = Bool(ShellExecute_(0, "open", FilePath$, #Null, #Null, #SW_SHOW) > 32)
    CompilerCase #PB_OS_Linux
      ; https://portland.freedesktop.org/doc/xdg-open.html
      Result = Bool(RunProgram("xdg-open", FilePath$, GetCurrentDirectory()))
    CompilerCase #PB_OS_MacOS
      Result = Bool(RunProgram("open", FilePath$, GetCurrentDirectory()))
  CompilerEndSelect
  
  ProcedureReturn Result
  
EndProcedure

Macro AddParameter_Windows_MacOS(_String_, _Variable_)
  
  If _String_
    Parameters$ + _Variable_ + _String_
  EndIf
  
EndMacro

Macro AddParameter_Linux(_String_, _Variable_)
  
  If _String_
    Parameters$ + _Variable_ + #DQUOTE$ + _String_ + #DQUOTE$
  EndIf
  
EndMacro

Macro AddMultiParameter_Linux(_String_, _Variable_)
  
  If _String_
    Count = CountString(_String_, ",")
    If Count = 0
      Parameters$ + _Variable_ + #DQUOTE$ + _String_ + #DQUOTE$
    Else
      Count + 1
      For i = 1 To Count
        Parameters$ + _Variable_ + #DQUOTE$ + StringField(_String_, i, ",") + #DQUOTE$
      Next
    EndIf
  EndIf
  
EndMacro

Procedure.i OpenStandardMailProgram(RecipientAddress$, Subject$="", Body$="", AttachFile$="", CCRecipientAddress$="", BCCRecipientAddress$="")
  
  Protected Result, Program, i, Count
  Protected Parameters$
  
  If RecipientAddress$ = ""
    ProcedureReturn #False
  EndIf
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    ; https://portland.freedesktop.org/doc/xdg-email.html
    Parameters$ = " --utf8"
    AddParameter_Linux(Subject$, " --subject ")
    Body$ = ReplaceString(Body$, #CRLF$, #CR$)
    AddParameter_Linux(Body$, " --body ")
    AddMultiParameter_Linux(AttachFile$, " --attach ")
    AddMultiParameter_Linux(CCRecipientAddress$, " --cc ")
    AddMultiParameter_Linux(BCCRecipientAddress$, " --bcc ")
    AddMultiParameter_Linux(RecipientAddress$, " ")
    Program = RunProgram("xdg-email", Parameters$, GetCurrentDirectory(), #PB_Program_Open)
    If Program
      WaitProgram(Program)
      Result = Bool(ProgramExitCode(Program) = 0)
      CloseProgram(Program)
    EndIf
  CompilerElse
    ; #PB_OS_Windows, #PB_OS_MacOS
    ; https://tools.ietf.org/html/rfc6068
    If AttachFile$
      ; The "mailto" protocol does not support file attachments
      ProcedureReturn #False
    EndIf
    AddParameter_Windows_MacOS(Subject$, "&subject=")
    AddParameter_Windows_MacOS(Body$, "&body=")
    AddParameter_Windows_MacOS(CCRecipientAddress$, "&cc=")
    AddParameter_Windows_MacOS(BCCRecipientAddress$, "&bcc=")
    If Parameters$
      Parameters$ = "?" + LTrim(Parameters$, "&")
    EndIf
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        ; https://docs.microsoft.com/en-us/windows/desktop/api/shellapi/nf-shellapi-shellexecutew
        Result = Bool(ShellExecute_(0, "open", "mailto:" + URLEncoder(RecipientAddress$ + Parameters$), #Null, #Null, #SW_SHOW) > 32)
      CompilerCase #PB_OS_MacOS
        Result = Bool(RunProgram("open", "mailto:" + URLEncoder(RecipientAddress$ + Parameters$), GetCurrentDirectory()))
    CompilerEndSelect
  CompilerEndIf
  
  ProcedureReturn Result
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  Debug OpenWithStandardProgram("https://www.purebasic.com")
  Define PictureFilePath$ = #PB_Compiler_Home + "examples/sources/Data/PureBasic.bmp"
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ReplaceString(PictureFilePath$, "/", "\", #PB_String_InPlace)
  CompilerEndIf
  Debug OpenWithStandardProgram(PictureFilePath$)
  
  Define RecipientAddress$, Subject$, Body$, AttachFile$, CCRecipientAddress$, BCCRecipientAddress$
  RecipientAddress$    = "FirstName Surname <aaa@mailserver.com>,bbb@mailserver.com"
  Subject$             = "A test email"
  Body$                = "Ladies and gentlemen," + #CRLF$ + #CRLF$ + "this is a test." + #CRLF$ + #CRLF$ + "With kind regards" + #CRLF$ + "The Tester"
  AttachFile$          = ""
  CCRecipientAddress$  = "cc1@test.de,FirstName Surname <cc2@test.de>"
  BCCRecipientAddress$ = "FirstName Surname <bcc1@test.de>,bcc2@test.de"
  Debug OpenStandardMailProgram(RecipientAddress$, Subject$, Body$, AttachFile$, CCRecipientAddress$, BCCRecipientAddress$)
  
CompilerEndIf
