;   Description: Creates a new empty file or sets access and modification time of the file to now
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

Procedure.i TouchFile(FilePath$)
  
  Protected File
  
  Select FileSize(FilePath$)
      
    Case -2 ; Directory
      ProcedureReturn #False
      
    Case -1 ; File doesn't exists
      File = CreateFile(#PB_Any, FilePath$)
      If File
        CloseFile(File)
      EndIf
      ProcedureReturn Bool(File)
      
    Default
      If Not SetFileDate(FilePath$, #PB_Date_Accessed, Date())
        ProcedureReturn #False
      EndIf
      If Not SetFileDate(FilePath$, #PB_Date_Modified, Date())
        ProcedureReturn #False
      EndIf
      ProcedureReturn #True
      
  EndSelect
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  ; Run the code more times to see the effect
  
  Define TestFilePath$ = GetTemporaryDirectory() + "TestFile"
  
  Debug TouchFile(TestFilePath$)
  Debug FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", GetFileDate(TestFilePath$, #PB_Date_Accessed))
  Debug FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", GetFileDate(TestFilePath$, #PB_Date_Modified))
  
CompilerEndIf
