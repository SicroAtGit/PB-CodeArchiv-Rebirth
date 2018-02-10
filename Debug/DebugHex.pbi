;   Description: Returns the string in addition back as hexadecimal codes
;            OS: Mac, Windows, Linux
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?p=334262#p334262
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 mk-soft
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

Procedure.s DebugHex(text.s, spalten.i = 8)
  Protected *pString.character
  Protected spalte.i
  Protected hex.s, ausgabe.s, result.s
  *pString = @text
  While *pString\c <> 0
    CompilerIf #PB_Compiler_Unicode = 1
      hex + RSet(Hex(*pString\c, #PB_Unicode), 4, "0") + " "
    CompilerElse
      hex + RSet(Hex(*pString\c, #PB_Ascii), 2, "0") + " "
    CompilerEndIf
    If *pString\c >= 32
      ausgabe + Chr(*pString\c)
    Else
      ausgabe + "."
    EndIf
    *pString + SizeOf(character)
    spalte + 1
    If spalte > spalten
      spalte = 0
      hex + " | " + ausgabe + #LF$
      ausgabe = ""
    EndIf
  Wend
  If ausgabe
    hex + " | " + ausgabe
  EndIf
 
  ProcedureReturn hex
 
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  t1.s = "aB© äöüſßÄÖÜ"+#LF$+#CR$+"()[]"
  Debug DebugHex(t1)
CompilerEndIf
