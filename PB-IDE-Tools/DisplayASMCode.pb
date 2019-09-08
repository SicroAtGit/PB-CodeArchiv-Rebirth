;   Description: Displays the commented ASM code from the PB compiler
;            OS: Windows, Linux, Mac
; English-Forum:
;  French-Forum:
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=10&t=30935
; -----------------------------------------------------------------------------

; MIT License
;
; Copyright (c) 2018-2019 Sicro
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
; - Arguments: "%FILE" "%TEMPFILE"
; - Event:     Menu Or Shortcut

EnableExplicit

; =============
;-Include Codes
; =============

XIncludeFile "../System/OpenStandardProgram.pbi"

; ================
;-Define Constants
; ================

#Program_Name     = "Display ASM Code"
#ErrorWindowTitle = #Program_Name + " - ERROR"

#Window_Main = 0

Enumeration Gadget
  #Editor_Output
  #Button_OpenStandardEditor
  #Button_CopyToClipboard
EndEnumeration

; ======================
;-Define Local Variables
; ======================

Define compilerHomePath$, compilerFilePath$, workingDirectoryPath$, codeFilePath$, codeTempFilePath$,
       asmCodeFilePath$, exeFilePath$, outputFilePathForStandardProgram$
Define asmCode$, output$, compilerOutput$
Define program, file, event, isCompilerError

; ==============================
;-Set Values For Local Variables
; ==============================

outputFilePathForStandardProgram$ = GetTemporaryDirectory() + RemoveString(#Program_Name, " ") + "-Output.txt"

compilerFilePath$ = GetEnvironmentVariable("PB_TOOL_Compiler")
compilerHomePath$ = GetPathPart(compilerFilePath$)
codeFilePath$     = ProgramParameter(0) ; "%FILE"
codeTempFilePath$ = ProgramParameter(1) ; "%TEMPFILE"

If codeFilePath$ = ""
  ; The code has not yet been saved
  ; Use the path of the auto-generated temp code file
  codeFilePath$ = codeTempFilePath$
EndIf

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  asmCodeFilePath$ = compilerHomePath$ + "purebasic.asm"
CompilerElse
  asmCodeFilePath$ = GetPathPart(codeFilePath$) + "purebasic.asm"
CompilerEndIf

; The EXE file is only created so that the PB compiler does not execute the code, but only creates the ASM code
exeFilePath$ = GetTemporaryDirectory() + "purebasic"

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  workingDirectoryPath$ = GetPathPart(compilerFilePath$)
CompilerElse
  workingDirectoryPath$ = GetPathPart(codeFilePath$)
CompilerEndIf

; =======================
;-Delete Old Output Files
; =======================

; Make sure that there are no previous output files, to prevent old output files from being read, if an error occurs.
DeleteFile(asmCodeFilePath$)
DeleteFile(exeFilePath$)

; ====================
;-Create ASM Code File
; ====================

; Run the PB compiler to create the ASM code file
program = RunProgram(compilerFilePath$,
                     #DQUOTE$ + codeFilePath$ + #DQUOTE$ + " --commented --executable " + #DQUOTE$ + exeFilePath$ + #DQUOTE$,
                     workingDirectoryPath$,
                     #PB_Program_Open | #PB_Program_Read)

; Read the PB compiler output
If program
  While ProgramRunning(program)
    While AvailableProgramOutput(program)
      compilerOutput$ + ReadProgramString(program) + #CRLF$
    Wend
  Wend
  isCompilerError = Bool(ProgramExitCode(program))
  CloseProgram(program)
Else
  isCompilerError = #True
EndIf

; Read the ASM code file
file = ReadFile(#PB_Any, asmCodeFilePath$)
If file
  asmCode$ + ReadString(file, #PB_File_IgnoreEOL)
  CloseFile(file)
EndIf

; If an error has occurred, output detailed information
If isCompilerError Or asmCode$ = ""
  MessageRequester(#ErrorWindowTitle, "Tool could not create the asm output!" + #CRLF$ +
                                      #CRLF$ +
                                      "Note that the PB compiler only generates ASM output if the PB code is syntaxically correct!" +
                                      #CRLF$ + #CRLF$ +
                                      "-------------------------------------" +
                                      #CRLF$ + #CRLF$ +
                                      "Compiler File Path:"        + #CRLF$ + compilerFilePath$     + #CRLF$ + #CRLF$ +
                                      "Compiler Working Dir Path:" + #CRLF$ + workingDirectoryPath$ + #CRLF$ + #CRLF$ +
                                      "Code File Path:"            + #CRLF$ + codeFilePath$         + #CRLF$ + #CRLF$ +
                                      "ASM Code File Path:"        + #CRLF$ + asmCodeFilePath$      + #CRLF$ + #CRLF$ +
                                      "EXE File Path:"             + #CRLF$ + exeFilePath$,
                   #PB_MessageRequester_Error)
  End
EndIf

output$ = "##############################################" + #CRLF$ +
          compilerOutput$ + #CRLF$ +
          "##############################################" + #CRLF$ +
          asmCode$

; =============================
;-Create ASM Code Output Window
; =============================

Procedure UpdateWindow()
  ResizeGadget(#Editor_Output, #PB_Ignore, #PB_Ignore, WindowWidth(#Window_Main), WindowHeight(#Window_Main) - 40)
  ResizeGadget(#Button_OpenStandardEditor, 5, GadgetHeight(#Editor_Output) + 5, WindowWidth(#Window_Main) / 2 - 8, #PB_Ignore)
  ResizeGadget(#Button_CopyToClipboard, GadgetWidth(#Button_OpenStandardEditor) + 10, GadgetHeight(#Editor_Output) + 5,
               WindowWidth(#Window_Main) / 2 - 8, #PB_Ignore)
EndProcedure
 
; Display the ASM code in an EditorGadget
If Not OpenWindow(#Window_Main, #PB_Ignore, #PB_Ignore, 500, 500, #Program_Name, #PB_Window_SystemMenu | #PB_Window_SizeGadget |
                                                                                 #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget)
  MessageRequester(#ErrorWindowTitle, "The program window could not be created!", #PB_MessageRequester_Error)
  End
EndIf
EditorGadget(#Editor_Output, 0, 0, WindowWidth(#Window_Main), WindowHeight(#Window_Main) - 40)
ButtonGadget(#Button_OpenStandardEditor, 5, GadgetHeight(#Editor_Output) + 5, WindowWidth(#Window_Main) / 2 - 8, 30, "Open Standard Editor")
ButtonGadget(#Button_CopyToClipboard, GadgetWidth(#Button_OpenStandardEditor) + 10, GadgetHeight(#Editor_Output) + 5,
             WindowWidth(#Window_Main) / 2 - 8, 30, "Copy To Clipboard")
SetGadgetText(#Editor_Output, output$)

BindEvent(#PB_Event_SizeWindow, @UpdateWindow(), #Window_Main)

Repeat
  event = WaitWindowEvent()
  Select event
    Case #PB_Event_Gadget
      Select EventGadget()
        Case #Button_OpenStandardEditor
          file = CreateFile(#PB_Any, outputFilePathForStandardProgram$)
          If file
            WriteStringN(file, output$)
            CloseFile(file)
          EndIf
          If Not OpenWithStandardProgram(outputFilePathForStandardProgram$)
            MessageRequester(#ErrorWindowTitle, "The output could not be opened in the standard editor!", #PB_MessageRequester_Error)
          EndIf
        Case #Button_CopyToClipboard
          SetClipboardText(output$)
      EndSelect
  EndSelect
Until event = #PB_Event_CloseWindow
