;   Description: Adds support for inline-if
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29487
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016 Sicro
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

Macro Iif(Expression, TrueValue, FalseValue)
  FalseValue + Bool(Expression) * (TrueValue - FalseValue)
EndMacro

Macro IifS(Expression, TrueString, FalseString, Separator = "|")
  StringField(FalseString + Separator + TrueString, Bool(Expression) + 1, Separator)
EndMacro

;-Example
CompilerIf #PB_Compiler_IsMainFile
  Debug IifS(1 = 1, "Ja", "Nein")
  Debug IifS(1 = 0, "Ja", "Nein")
  
  Debug Iif(1 = 1, 11, 55)
  Debug Iif(1 = 0, 11, 55)
CompilerEndIf
