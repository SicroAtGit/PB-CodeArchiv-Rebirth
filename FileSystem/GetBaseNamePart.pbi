;   Description: Gets the trailing name component of path
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

Procedure$ GetBaseNamePart(Path$, Suffix$="")
  ; https://secure.php.net/manual/de/function.basename.php
  
  Protected i
  Protected PathSlash$, Char$, Result$
  
  CompilerSelect #PB_Compiler_OS
      
    CompilerCase #PB_OS_Windows
      ReplaceString(Path$, "/", "\", #PB_String_InPlace)
      PathSlash$ = "\"
      
    CompilerDefault ; Linux und Mac
      PathSlash$ = "/"
      
  CompilerEndSelect
  
  If Right(Path$, 1) = PathSlash$
    Path$ = Left(Path$, Len(Path$) - 1)
  EndIf
  
  For i = Len(Path$) To 1 Step -1
    Char$ = Mid(Path$, i, 1)
    If Char$ = PathSlash$
      Break
    EndIf
    Result$ = Char$ + Result$
  Next
  
  If Suffix$ And Right(Result$, Len(Suffix$)) = Suffix$
    Result$ = Left(Result$, Len(Result$) - Len(Suffix$))
  EndIf
  
  ProcedureReturn Result$
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  Debug GetBaseNamePart("/etc/sudoers.d", ".d")
  Debug GetBaseNamePart("/etc/sudoers.d")
  Debug GetBaseNamePart("/etc/passwd")
  Debug GetBaseNamePart("/etc/")
  Debug GetBaseNamePart(".")
  Debug GetBaseNamePart("/")
  
  ; https://secure.php.net/manual/de/function.basename.php#74429
  Debug GetBaseNamePart("path/to/file.xml#xpointer(/Texture)", ".xml#xpointer(/Texture)")
  
  Debug GetBaseNamePart("C:\Windows\System32\") ; Works only on windows
  
CompilerEndIf
