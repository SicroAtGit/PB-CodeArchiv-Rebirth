;   Description: Displays the commented C code from the PB compiler
;            OS: Windows, Linux, Mac
; English-Forum:
;  French-Forum:
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=10&t=30935
; -----------------------------------------------------------------------------

; MIT License
;
; Copyright (c) 2018-2020 Sicro
; Copyright (c) 2022 mk-soft
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
; For MacOS, the field "Commandline" must contain the full path to the executable
; file, e.g.: .../Program.app/Contents/MacOS/Program

EnableExplicit

; =============
;-Include Codes
; =============

XIncludeFile "../System/OpenStandardProgram.pbi"
XIncludeFile "../File/GetFileContentAsString.pbi"

; ================
;-Define Constants
; ================

CompilerIf Not Defined(PB_Processor_Arm32, #PB_Constant)
  #PB_Processor_Arm32 = 7
CompilerEndIf

CompilerIf Not Defined(PB_Processor_Arm64, #PB_Constant)
  #PB_Processor_Arm64 = 6
CompilerEndIf

#Program_Name     = "Display C Code"
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
       cCodeFilePath$, exeFilePath$, compilerParameters$, compilerUserParameters$
Define cCode$, output$, compilerOutput$
Define program, event, isCompilerError, countOfParameters, i, isLibrary
Define compilerVersion$, isCompilerV6

; ==============================
;-Set Values For Local Variables
; ==============================

compilerFilePath$ = GetEnvironmentVariable("PB_TOOL_Compiler")
If compilerFilePath$ = ""
  MessageRequester(#ErrorWindowTitle, "Run only as PB IDE tool", #PB_MessageRequester_Error)
  End
EndIf

CompilerSelect #PB_Compiler_Processor
  CompilerCase #PB_Processor_Arm32
    ;
  CompilerCase #PB_Processor_Arm64
    ;
  CompilerDefault
    If Not FindString(compilerFilePath$, "pbcompilerc")
      compilerFilePath$ = ReplaceString(compilerFilePath$, "pbcompiler", "pbcompilerc")
    EndIf
CompilerEndSelect

; Run the PB compiler to get compiler version
program = RunProgram(compilerFilePath$, "-v", "", #PB_Program_Open | #PB_Program_Read)
If program
  While ProgramRunning(program)
    While AvailableProgramOutput(program)
      compilerVersion$ + ReadProgramString(program) + #CRLF$
    Wend
  Wend
  isCompilerError = Bool(ProgramExitCode(program))
  CloseProgram(program)
Else
  isCompilerError = #True
EndIf

If FindString(compilerVersion$, "PureBasic 6.")
  isCompilerV6 = #True
EndIf

compilerHomePath$ = GetPathPart(compilerFilePath$)
codeFilePath$     = ProgramParameter(0) ; "%FILE"
codeTempFilePath$ = ProgramParameter(1) ; "%TEMPFILE"

If codeFilePath$ = ""
  ; The code has not yet been saved
  ; Use the path of the auto-generated temp code file
  codeFilePath$ = codeTempFilePath$
EndIf

cCodeFilePath$ = GetPathPart(codeFilePath$) + "purebasic.c"

; The EXE file is only created so that the PB compiler does not execute the code, but only creates the ASM code
exeFilePath$ = GetTemporaryDirectory() + "purebasic"

workingDirectoryPath$ = GetPathPart(codeFilePath$)

compilerParameters$ = "--commented"

; The PB compiler parameter for constants has changed since PB 6.0
If isCompilerV6
  compilerParameters$ + " -co PB_Editor_BuildCount=0 -co PB_Editor_CompileCount=0"
Else
  compilerParameters$ + " -o PB_Editor_BuildCount=0 -o PB_Editor_CompileCount=0"
EndIf

If Val(GetEnvironmentVariable("PB_TOOL_Thread"))
  compilerParameters$ + " --thread"
EndIf

If Val(GetEnvironmentVariable("PB_TOOL_Unicode"))
  compilerParameters$ + " --unicode"
EndIf

If GetEnvironmentVariable("PB_TOOL_SubSystem")
  compilerParameters$ + " --subsystem " + GetEnvironmentVariable("PB_TOOL_SubSystem")
EndIf

Procedure$ ProcessParameter(parameter$, exeFilePath$, *isLibrary.Integer)
  Select LCase(parameter$)
    Case "-dl", "--dylib", "-so", "--sharedobject"
      parameter$ = parameter$ + " " + #DQUOTE$ + exeFilePath$ + #DQUOTE$
      *isLibrary\i = #True
    Case "/dll"
      parameter$ = "--executable " + #DQUOTE$ + exeFilePath$ + #DQUOTE$ + parameter$
      *isLibrary\i = #True
  EndSelect
  ProcedureReturn parameter$
EndProcedure

; Get user parameters
countOfParameters = CountProgramParameters()
For i = 2 To countOfParameters - 1
  compilerUserParameters$ + " " + ProcessParameter(ProgramParameter(i), exeFilePath$, @isLibrary)
Next
If Not isLibrary
  compilerParameters$ + " --executable " + #DQUOTE$ + exeFilePath$ + #DQUOTE$
EndIf
compilerParameters$ + compilerUserParameters$

; =======================
;-Delete Old Output Files
; =======================

; Make sure that there are no previous output files, to prevent old output files from being read, if an error occurs.
DeleteFile(cCodeFilePath$)
DeleteFile(exeFilePath$)

; ====================
;-Create ASM Code File
; ====================

; Run the PB compiler to create the ASM code file
program = RunProgram(compilerFilePath$,
                     #DQUOTE$ + codeFilePath$ + #DQUOTE$ + " " + compilerParameters$,
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

cCode$ = GetFileContentAsString(cCodeFilePath$)

; If an error has occurred, output detailed information
If isCompilerError Or cCode$ = ""
  MessageRequester(#ErrorWindowTitle, "Tool could not create the asm output!" +
                                      #CRLF$ + #CRLF$ +
                                      "Note that the PB compiler only generates ASM output if the PB code is syntaxically correct!" +
                                      #CRLF$ + #CRLF$ +
                                      "-------------------------------------" +
                                      #CRLF$ + #CRLF$ +
                                      "Compiler File Path:"        + #CRLF$ + compilerFilePath$     + #CRLF$ + #CRLF$ +
                                      "Compiler Parameters:"       + #CRLF$ + compilerParameters$   + #CRLF$ + #CRLF$ +
                                      "Compiler Working Dir Path:" + #CRLF$ + workingDirectoryPath$ + #CRLF$ + #CRLF$ +
                                      "C Code File Path:"          + #CRLF$ + cCodeFilePath$        +
                                      #CRLF$ + #CRLF$ +
                                      "-------------------------------------" +
                                      #CRLF$ + #CRLF$ +
                                      "Compiler Output:"           + #CRLF$ + compilerOutput$,
                   #PB_MessageRequester_Error)
  End
EndIf

DeleteFile(exeFilePath$)

output$ = "##############################################" + #CRLF$ +
          "Compiler File Path:  " + compilerFilePath$      + #CRLF$ +
          "Compiler Parameters: " + compilerParameters$    + #CRLF$ +
          "C Code File Path:    " + cCodeFilePath$         + #CRLF$ +
          #CRLF$ +
          "##############################################" + #CRLF$ +
          compilerOutput$ + #CRLF$ +
          "##############################################" + #CRLF$ +
          #CRLF$ +
          cCode$

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

CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  If Not IsMenu(#Window_Main)
    CreateMenu(0, WindowID(#Window_Main))
  EndIf
  
  ;MenuItem(#PB_Menu_About, "")
  ;MenuItem(#PB_Menu_Preferences, "")
  MenuItem(#PB_Menu_Quit, "")
CompilerEndIf

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
          If Not OpenWithStandardProgram(cCodeFilePath$)
            MessageRequester(#ErrorWindowTitle, "The output could not be opened in the standard editor!", #PB_MessageRequester_Error)
          EndIf
        Case #Button_CopyToClipboard
          SetClipboardText(cCode$)
      EndSelect
    Case #PB_Event_Menu
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
        ; MacOS 'Application' menu
        Select EventMenu()
          Case #PB_Menu_About
          Case #PB_Menu_Preferences
          Case #PB_Menu_Quit
            Break
        EndSelect
      CompilerEndIf
  EndSelect
Until event = #PB_Event_CloseWindow
