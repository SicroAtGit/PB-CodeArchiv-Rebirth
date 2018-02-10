;   Description: Convert HHTPHeader into a Map
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28100
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 Bisonte
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

Procedure _GetHTTPHeader(Url.s, Map Header.s())
  
  Protected String.s, i, bString.s
  
  ClearMap(Header())
  
  If InitNetwork()
    
    String = GetHTTPHeader(Url)
    If String <> ""
      For i = 1 To CountString(String, Chr(13) + Chr(10))
        bString = Trim(StringField(String, i, Chr(13) + Chr(10)))
        If bString <> ""
          If Left(LCase(bString), 4) = "http"
            Header("STATUS") = bString
          Else
            Header(UCase(StringField(bString, 1, ":"))) = Trim(StringField(bString, 2, ":"))
          EndIf
        EndIf
      Next i
    EndIf
    
  EndIf
  
  ProcedureReturn MapSize(Header())
  
EndProcedure

;- Example
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  NewMap kk.s()
  
  If _GetHTTPHeader("http://purebasic.fr/german/styles/subsilver2/imageset/PureBoardLogo.png", kk())
    If FindMapElement(kk(), "CONTENT-LENGTH")
      Debug LSet(MapKey(kk()), 30, " ") + kk()
    EndIf
    Debug "----"
    ForEach kk()
      Debug MapKey(kk())+" = "+kk()
    Next
  EndIf
CompilerEndIf
