;   Description: Creates arbitrarily deep directory level
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=30020
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

Procedure.i CreatePath(Path$)
  
  Protected CountOfDirectories, i
  Protected TempPath$, Slash$
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      Slash$ = "\"
    CompilerDefault
      Slash$ = "/"
  CompilerEndSelect
  
  Path$ = Trim(Path$, Slash$)
  
  CountOfDirectories = CountString(Path$, Slash$) + 1
  For i = 1 To CountOfDirectories
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If i = 1
        TempPath$ = StringField(Path$, i, Slash$)
        Continue
      EndIf
    CompilerEndIf
    TempPath$ + Slash$ + StringField(Path$, i, Slash$)
    If FileSize(TempPath$) <> -2 And Not CreateDirectory(TempPath$)
      ProcedureReturn #False
    EndIf
  Next
  
  ProcedureReturn #True
EndProcedure

;Debug CreatePath("/home/username/myproject/codes/gui")
;Debug CreatePath("C:\Dokumente und Einstellungen\Benutzername\Programmieren\Mein Projekt\GUI") 
