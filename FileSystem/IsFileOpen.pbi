;   Description: Checks whether a process has opened the file
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

Procedure IsFileOpen(filePath$)
  Protected result
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ; https://www.purebasic.fr/english/viewtopic.php?p=360442#p360442
    result = Bool(RenameFile(filePath$, filePath$) = #False)
    
  CompilerElse
    ; https://pubs.opengroup.org/onlinepubs/9699919799/utilities/fuser.html
    ; https://linux.die.net/man/8/lsof
    ; https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man8/lsof.8.html
    Protected program = RunProgram("fuser", filePath$, "", #PB_Program_Open | #PB_Program_Wait)
    If program
      result = Bool(ProgramExitCode(program) = 0)
      CloseProgram(program)
    EndIf
    
  CompilerEndIf
  
  ProcedureReturn result
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  Define filePath$ = GetTemporaryDirectory() + "Test"
  
  Define file = CreateFile(#PB_Any, filePath$)
  If Not file
    Debug "Error"
    End
  EndIf
  
  Debug IsFileOpen(filePath$)
  CloseFile(file)
  Debug IsFileOpen(filePath$)
CompilerEndIf
