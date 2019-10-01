;   Description: Uses the PB compiler to expand macros, includes and so on
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

Procedure$ GetContentOfPreProcessedFile(CodeFilePath$, CompilerFilePath$,
                                        CompilerEnableDebugger,
                                        CompilerEnableThread,
                                        CompilerSubsystem$)
  
  Protected File, StringFormat
  Protected TempCodeFilePath$, Content$, Parameters$
  
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
  
  If Not RunProgram(CompilerFilePath$, Parameters$, GetPathPart(CodeFilePath$),
                    #PB_Program_Wait | #PB_Program_Hide)
    ProcedureReturn ""
  EndIf
  
  File = ReadFile(#PB_Any, TempCodeFilePath$)
  If Not File
    ProcedureReturn ""
  EndIf
  
  StringFormat = ReadStringFormat(File)
  Select StringFormat
    Case #PB_Ascii, #PB_UTF8, #PB_Unicode
    Default
      ; ReadString() supports fewer string formats than ReadStringFormat(), so
      ; in case of an unsupported format it is necessary to fall back to a
      ; supported format
      StringFormat = #PB_UTF8
  EndSelect
  
  Content$ = ReadString(File, StringFormat | #PB_File_IgnoreEOL)
  
  CloseFile(File)
  
  ProcedureReturn Content$
  
EndProcedure
