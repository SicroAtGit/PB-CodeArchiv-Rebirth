;   Description: Determines if the path is an absolute path
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017 Sicro
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

Procedure.i IsAbsolutePath(Path$)
  
  If Path$ = "" : ProcedureReturn #False : EndIf
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    
    If Left(Path$, 2) = "//"   : ProcedureReturn #True : EndIf
    
    If Left(Path$, 4) = "\\\\" : ProcedureReturn #True : EndIf
    
    Select Asc(Path$)
      Case 'A' To 'Z', 'a' To 'z'
        If Mid(Path$, 2, 2) = ":/" Or Mid(Path$, 2, 2) = ":\" Or Mid(Path$, 2, 3) = ":\\"
          ProcedureReturn #True
        EndIf
    EndSelect
    
    ProcedureReturn #False
    
  CompilerElse ; Linux, MacOS
    
    If Asc(Path$) = '/' : ProcedureReturn #True : EndIf
    
    ProcedureReturn #False
    
  CompilerEndIf
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    
    Debug IsAbsolutePath("//server")
    Debug IsAbsolutePath("\\\\server")
    Debug IsAbsolutePath("C:/foo/..")
    Debug IsAbsolutePath("C:\\foo\\..")
    Debug IsAbsolutePath("bar\\baz")
    Debug IsAbsolutePath("bar/baz")
    Debug IsAbsolutePath(".")
    
  CompilerElse ; Linux, MacOS
    
    Debug IsAbsolutePath("/foo/bar")
    Debug IsAbsolutePath("/baz/..")
    Debug IsAbsolutePath("qux/")
    Debug IsAbsolutePath(".")
    
  CompilerEndIf
  
CompilerEndIf
