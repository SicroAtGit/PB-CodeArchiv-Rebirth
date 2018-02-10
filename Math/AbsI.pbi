;   Description: Abs() for integer
;            OS: Mac, Windows, Linux
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27835
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 Sicro
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

Procedure.i AbsI(Number.i)
  If number<0
    ProcedureReturn -Number
  EndIf
  ProcedureReturn Number
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  x=ElapsedMilliseconds()
  For i=-100000000 To 100000000
    result=AbsI(i)
  Next
  
  a$+"AbsI:"+Str(x-ElapsedMilliseconds())+Chr(10)
  x=ElapsedMilliseconds()
  
  Macro mAbsI(intValue)
    intValue!(intValue>>63)+((intValue>>63)&1)
  EndMacro
  
  For i=-100000000 To 100000000
    result=mAbsI(i)
  Next
  a$+"mAbsI:"+Str(x-ElapsedMilliseconds())+Chr(10)
  x=ElapsedMilliseconds()
  
  MessageRequester("Results",a$)
CompilerEndIf
