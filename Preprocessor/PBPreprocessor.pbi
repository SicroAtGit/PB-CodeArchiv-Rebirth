;   Description: Uses the PB compiler to expand macros, includes and so on
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

XIncludeFile "../File/GetFileContentAsString.pbi"

Procedure$ GetContentOfPreProcessedFile(CodeFilePath$, CompilerFilePath$,
                                        CompilerEnableDebugger = #False,
                                        CompilerEnableThread = #False,
                                        CompilerSubsystem$ = "")
  
  Protected TempCodeFilePath$, Parameters$, Result$, Error$
  Protected Compiler
  
  If CodeFilePath$ = ""
    ProcedureReturn ""
  EndIf
    
  TempCodeFilePath$ = GetTemporaryDirectory() + "TempCodeFile"
  
  Parameters$ = #DQUOTE$ + CodeFilePath$ + #DQUOTE$ +
               " --preprocess " + #DQUOTE$ + TempCodeFilePath$ + #DQUOTE$
  
  If CompilerEnableDebugger
    Parameters$ + " --debugger"
  EndIf
  
  If CompilerEnableThread
    Parameters$ + " --thread"
  EndIf
  
  If CompilerSubsystem$
    Parameters$ + " --subsystem " + CompilerSubsystem$
  EndIf
  
  DeleteFile(TempCodeFilePath$)
  
  Compiler = RunProgram(CompilerFilePath$, Parameters$, GetPathPart(CodeFilePath$),
                        #PB_Program_Open | #PB_Program_Read)
  If Compiler
    While ProgramRunning(Compiler)
      While AvailableProgramOutput(Compiler)
        Result$ + ReadProgramString(Compiler) + #CRLF$
      Wend
    Wend
    If ProgramExitCode(Compiler)
      Error$ = "Error:" + #CRLF$ + Result$
    EndIf
    CloseProgram(Compiler)
  Else
    Error$ = "Error:" + #CRLF$ +
             "PureBasic compiler could not be started!"
  EndIf
  
  If Error$ = ""
    ProcedureReturn GetFileContentAsString(TempCodeFilePath$)
  Else
    ProcedureReturn Error$
  EndIf
  
EndProcedure
