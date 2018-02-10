;   Description: Returns a single-line string from a multiline string
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

Procedure$ ReadStringLine(String$, *StringPosition.Integer, StringLength = 0)
  
  Protected StringLineStartPosition
  Protected Result$
  
  If StringLength = 0
    StringLength = Len(String$)
  EndIf
  
  If *StringPosition\i = 0
    *StringPosition\i = 1
  EndIf
  
  StringLineStartPosition = *StringPosition\i
  
  While *StringPosition\i <= StringLength
    Select Mid(String$, *StringPosition\i, 1)
      Case #CR$, #LF$
        Break
      Default
        *StringPosition\i + 1
    EndSelect
  Wend
  
  Result$ = Mid(String$, StringLineStartPosition, *StringPosition\i - StringLineStartPosition)
  
  *StringPosition\i + 1
  
  If Mid(String$, *StringPosition\i, 1) = #LF$
    *StringPosition\i + 1
  EndIf
  
  ProcedureReturn Result$
  
EndProcedure

Define String$, StringLine$
Define StringLength, Pos

String$ = "Line 1" + #CRLF$ +
          "Line 2" + #CRLF$ +
          "Line 3"

StringLength = Len(String$)

StringLine$ = ReadStringLine(String$, @Pos, StringLength)
While StringLine$ <> ""
  Debug StringLine$
  StringLine$ = ReadStringLine(String$, @Pos, StringLength)
Wend
