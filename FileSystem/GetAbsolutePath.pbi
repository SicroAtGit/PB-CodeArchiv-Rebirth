;   Description: Returns the absolute path of a relative path
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017, 2020 Sicro
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

XIncludeFile "GetParentDirectory.pbi"

Procedure$ GetAbsolutePath(RelativePath$)
  
  Protected Slash$, PathPart$, AbsolutePath$
  Protected CountOfSlashes, i
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Slash$ = "\"
  CompilerElse ; Linux, Mac
    Slash$ = "/"
  CompilerEndIf
  
  AbsolutePath$ = GetCurrentDirectory()
  
  CountOfSlashes = CountString(RelativePath$, Slash$)
  For i = 1 To CountOfSlashes + 1
    PathPart$ = StringField(RelativePath$, i, Slash$)
    Select PathPart$
      Case "."
        Continue
      Case ".."
        AbsolutePath$ = GetParentDirectory(AbsolutePath$)
      Default
        If Right(AbsolutePath$, 1) <> Slash$
          AbsolutePath$ + Slash$
        EndIf
        AbsolutePath$ + PathPart$
    EndSelect
  Next
  
  ProcedureReturn AbsolutePath$
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  Define RelativePath$
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    RelativePath$ = "..\..\Test1\Test2\"
  CompilerElse ; Linux, Mac
    RelativePath$ = "../../Test1/Test2/"
  CompilerEndIf
  
  Debug GetCurrentDirectory()
  Debug GetAbsolutePath(RelativePath$)
  Debug GetAbsolutePath(RelativePath$ + "File")
  Debug GetAbsolutePath(".")
  Debug GetAbsolutePath("")
  
CompilerEndIf
