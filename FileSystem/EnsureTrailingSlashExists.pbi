;   Description: Ensures that a trailing slash exists at the path
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
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

Procedure$ EnsureTrailingSlashExists(Path$)
  
  CompilerSelect #PB_Compiler_OS
      
    CompilerCase #PB_OS_Windows
      
      If Right(Path$, 1) <> "\"
        Path$ + "\"
      EndIf
      
    CompilerDefault ; Mac, Linux
      
      If Right(Path$, 1) <> "/"
        Path$ + "/"
      EndIf
      
  CompilerEndSelect
  
  ProcedureReturn Path$
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  Define DirectoryPath$
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      DirectoryPath$ = "X:\Tools\Test"
    CompilerDefault
      DirectoryPath$ = "/tools/test"
  CompilerEndSelect
  
  Debug "Before: " + DirectoryPath$
  Debug "After:  " + EnsureTrailingSlashExists(DirectoryPath$)
  
CompilerEndIf
