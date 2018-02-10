;   Description: Formated number
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28640&p=333457#p333457
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 GPI
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

;Original idea from RSBasic and NicTheQuick
EnableExplicit

Procedure.s NumberFormat(Value.d,  DecimalGroup=2, DecimalSep$=".",ThousandGroup=3, ThousandSep$=",",SignFirst=#True,AlwaysSign=#False)
  Protected ret.s
  Protected sign
  If value<0
    value=-value
    sign=1
  EndIf
  Protected number$=StrD(Value,DecimalGroup)  +"."
  Protected left.s=StringField(number$,1,".")
  Protected right.s=StringField(number$,2,".")
  Protected i=Len(left)-ThousandGroup
  
  If ThousandGroup>0
    While i>0
      left=Left(left,i)+ThousandSep$+Right(left,Len(left)-i)
      i-ThousandGroup
    Wend
  EndIf
  If left=""
    left="0"
  EndIf
  ret=left+DecimalSep$+right
  If sign Or AlwaysSign
    If signfirst
      ret=Mid("+-",sign+1,1)+ret
    Else
      ret=ret+Mid("+-",sign+1,1)
    EndIf
  EndIf
  
  ProcedureReturn ret
EndProcedure
Procedure.s ByteFormat(value.q, force=0, binary.i = #True)
  Static shorts.s = "kMGTPE"
  
  Protected i.i = 0, result.d = value
  
  
  
  If force
    While force
      result / (1000 + 24 * Bool(binary))
      i + 1
      force-1
    Wend
  Else
    If value < 1024 And force=0
      ProcedureReturn NumberFormat(value) + " B"
    EndIf
    While result >= 1024
      result / (1000 + 24 * Bool(binary))
      i + 1
    Wend
  EndIf
  
  
  ProcedureReturn NumberFormat(result,2)+ " " + Mid(shorts, i, 1) + Left("i", Bool(binary)) + "B"
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  Debug NumberFormat(-1234567899.2356, 2)
  Debug NumberFormat(-1234567899.2356, 3,",",3,".")
  Debug NumberFormat(-1234567899.2356, 3,",",0)
  
  Debug NumberFormat(1234567899.2356, 2,".",3,",",#False,#True)
  Debug NumberFormat(1234567899.2356, 3,",",3,".",#True,#True)
  Debug NumberFormat(1234567899.2356, 3,",",0,".",#False,#True)
  
  Define i
  
  Debug "Binärpräfixe:"
  For i = 1 To 18
    Debug ByteFormat(Pow(10, i),0, #True)
  Next
  
  Debug ""
  Debug "Dezimalpräfixe:"
  For i = 1 To 18
    Debug ByteFormat(Pow(10, i),0, #False)
  Next
  
  Debug ""
  Debug "Dezimalpräfixe in mb"
  For i = 1 To 18
    Debug ByteFormat(Pow(10, i),2, #False)
  Next
CompilerEndIf
