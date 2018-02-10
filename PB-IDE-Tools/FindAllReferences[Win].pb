;   Description: Find all references of a variable
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28292
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 Kiffi
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

; FindAllReferences

CompilerIf #PB_Compiler_OS<>#PB_OS_Windows
  CompilerError "Windows Only!"
CompilerEndIf

EnableExplicit

Enumeration ; Windows
  #frmMain
EndEnumeration
Enumeration ; Gadgets
  #frmMain_References
EndEnumeration
Enumeration ; Menu-/Toolbaritems
  #frmMain_Shortcut_Escape_Event
EndEnumeration

Global PbIdeHandle = Val(GetEnvironmentVariable("PB_TOOL_MainWindow"))
If PbIdeHandle = 0 : End : EndIf

Global ScintillaHandle = Val(GetEnvironmentVariable("PB_TOOL_Scintilla"))
If ScintillaHandle = 0 : End : EndIf

Procedure.s RemoveLeadingWhitespaceFromString(InString.s)
  
  While Left(InString, 1) = Chr(32) Or Left(InString, 1) = Chr(9)
    InString = LTrim(InString, Chr(32))
    InString = LTrim(InString, Chr(9))
  Wend
  
  ProcedureReturn InString
  
EndProcedure

Procedure.s GetScintillaText()
  
  Protected ReturnValue.s
  
  Protected length
  Protected buffer
  Protected processId
  Protected hProcess
  Protected result
  
  length = SendMessage_(ScintillaHandle, #SCI_GETLENGTH, 0, 0)
  If length
    length + 2
    buffer = AllocateMemory(length)
    If buffer   
      SendMessageTimeout_(ScintillaHandle, #SCI_GETCHARACTERPOINTER, 0, 0, #SMTO_ABORTIFHUNG, 2000, @result)
      If result
        GetWindowThreadProcessId_(ScintillaHandle, @processId)
        hProcess = OpenProcess_(#PROCESS_ALL_ACCESS, #False, processId)
        If hProcess
          ReadProcessMemory_(hProcess, result, buffer, length, 0)   
          ReturnValue = PeekS(buffer, -1, #PB_UTF8)
        EndIf
      EndIf
    EndIf
    FreeMemory(buffer)
  EndIf
  
  ProcedureReturn ReturnValue
  
EndProcedure

Procedure frmMain_SizeWindow_Event()
  ResizeGadget(#frmMain_References, #PB_Ignore, #PB_Ignore, WindowWidth(#frmMain) - 20, WindowHeight(#frmMain) - 20)
EndProcedure

Procedure frmMain_References_Event()
  
  Protected SelectedLine
  
  SelectedLine = Val(GetGadgetItemText(#frmMain_References, GetGadgetState(#frmMain_References), 0))
  
  If SelectedLine > 0
    SendMessage_(ScintillaHandle, #SCI_GOTOLINE, SelectedLine - 1, 0)
    SendMessage_(ScintillaHandle, #SCI_ENSUREVISIBLE, SelectedLine - 1, 0)
    SetForegroundWindow_(PbIdeHandle)
    SetActiveWindow_(PbIdeHandle)
  EndIf
  
EndProcedure

Define SelectedWord.s = GetEnvironmentVariable("PB_TOOL_Word")
If SelectedWord = "" : End : EndIf

Define ScintillaText.s = GetScintillaText()
If ScintillaText = "" : End : EndIf

Define Line.s
Define CountLines, LineCounter
Define CountTokens, TokenCounter
Define WWE
Define RegexLines, PbRegexTokens

Structure sFoundReference
  LineNo.i
  Reference.s
EndStructure

NewList FoundReference.sFoundReference()

Dim Tokens.s(0)

;http://www.purebasic.fr/english/viewtopic.php?f=12&t=37823
RegexLines = CreateRegularExpression(#PB_Any , ".*\r\n")
PbRegexTokens = CreateRegularExpression(#PB_Any, #DOUBLEQUOTE$ + "[^" + #DOUBLEQUOTE$ + "]*" + #DOUBLEQUOTE$ + "|[\*]?[a-zA-Z_]+[\w]*[\x24]?|#[a-zA-Z_]+[\w]*[\x24]?|[\[\]\(\)\{\}]|[-+]?[0-9]*\.?[0-9]+|;.*|\.|\+|-|[&@!\\\/\*,\|]|::|:|\|<>|>>|<<|=>{1}|>={1}|<={1}|=<{1}|={1}|<{1}|>{1}|\x24+[0-9a-fA-F]+|\%[0-1]*|%|'")

CountLines = CountString(ScintillaText, #CRLF$)

Dim Lines.s(0)

CountLines = ExtractRegularExpression(RegexLines, ScintillaText, Lines())

SelectedWord = LCase(SelectedWord)

For LineCounter = 0 To CountLines - 1
  
  Line = Lines(LineCounter)   
  
  CountTokens = ExtractRegularExpression(PbRegexTokens, Line, Tokens())
  
  For TokenCounter = 0 To CountTokens - 1   
    If SelectedWord = LCase(Tokens(TokenCounter))
      AddElement(FoundReference())
      FoundReference()\LineNo = LineCounter + 1
      FoundReference()\Reference = Line
    EndIf
  Next
  
Next

If ListSize(FoundReference()) = 0 : End : EndIf

OpenWindow(#frmMain,
           #PB_Ignore,
           #PB_Ignore,
           600,
           300,
           "All references for: '" + SelectedWord + "'",
           #PB_Window_SystemMenu |
           #PB_Window_SizeGadget |
           #PB_Window_ScreenCentered)

StickyWindow(#frmMain, #True)

ListIconGadget(#frmMain_References,
               10,
               10,
               WindowWidth(#frmMain) - 20,
               WindowHeight(#frmMain) - 20,
               "LineNo.",
               50,
               #PB_ListIcon_FullRowSelect |   
               #PB_ListIcon_GridLines |
               #PB_ListIcon_AlwaysShowSelection)

AddGadgetColumn(#frmMain_References, 1, "Reference", 400)

ForEach FoundReference()
  AddGadgetItem(#frmMain_References, -1, Str(FoundReference()\LineNo) + #LF$ + FoundReference()\Reference)   
Next

AddKeyboardShortcut(#frmMain, #PB_Shortcut_Escape, #frmMain_Shortcut_Escape_Event)
BindEvent(#PB_Event_SizeWindow, @frmMain_SizeWindow_Event(), #frmMain)
BindGadgetEvent(#frmMain_References, @frmMain_References_Event())
SetActiveGadget(#frmMain_References)

Repeat
  
  WWE = WaitWindowEvent()
  
  If (WWE = #PB_Event_Menu And EventMenu() = #frmMain_Shortcut_Escape_Event) Or (WWE = #PB_Event_CloseWindow)
    Break
  EndIf
  
ForEver
