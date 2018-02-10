;   Description: Gets the path of the parent directory
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

; Thanks goes to "davido" from the English forum for the inspiration to use GetPathPart():
; http://www.purebasic.fr/english/viewtopic.php?f=13&t=69183

Procedure$ GetParentDirectory(Path$)
  
  Select Right(Path$, 2)
    Case "./" : ProcedureReturn Path$ + "../"
    Case ".\" : ProcedureReturn Path$ + "..\"
  EndSelect
  
  Select Right(Path$, 3)
    Case "../" : ProcedureReturn Path$ + "../"
    Case "..\" : ProcedureReturn Path$ + "..\"
  EndSelect
  
  Path$ = GetPathPart(Left(Path$, Len(Path$) - 1))
  
  ProcedureReturn Path$
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Debug GetParentDirectory("C:\home\username\project\codes\")
    Debug GetParentDirectory("C:\home\username\project\codes\.\")
    Debug GetParentDirectory("C:\home\username\project\codes\..\")
    
  CompilerElse ; Linux, Mac
    Debug GetParentDirectory("/home/username/project/codes/")
    Debug GetParentDirectory("/home/username/project/codes/./")
    Debug GetParentDirectory("/home/username/project/codes/../")
    
  CompilerEndIf
  
CompilerEndIf
