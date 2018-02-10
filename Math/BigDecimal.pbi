;   Description: Calculating with infinitely large and exact numbers
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=22466
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2010, 2014 CSHW89 (Kevin Jasik)
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

; Name: BigDecimal
; Author: Kevin Jasik (CSHW89)
; Date: 23.04.2014
; Description: Rechnen mit unendlich großen und genauen Zahlen

EnableExplicit


#BDMaxInLong = 1000000000
#BDDigitsInLong = 9

#BDExpNull = 0
#BDExpNaN  = 1
#BDExpInf  = 2

Global Dim BDMultiExp.l(#BDDigitsInLong-1)


Enumeration 0
  #BDRoundDown     ; zur 0 runden
  #BDRoundUp       ; weg von der 0 runden
  #BDRoundCeiling  ; zu Infinity runden
  #BDRoundFloor    ; zu -Infinity runden
  #BDRoundHalfDown ; zur nächsten ganzen Zahl runden (bei .5 zur 0 runden)
  #BDRoundHalfUp   ; zur nächsten ganzen Zahl runden (bei .5 weg von der 0 runden)
EndEnumeration

Structure BigDecimal
  sgn.i  ; Signum
  exp.i  ; Zahl multiplizieren mit (10^9)^exp
  size.i ; wieviele Mantissenteile gibt es
  Array man.l(0) ; Mantisse
EndStructure

Declare BDAdd(*bda.BigDecimal, *bdb.BigDecimal, *result.BigDecimal, digits=#PB_Default)
Declare BDSub(*bda.BigDecimal, *bdb.BigDecimal, *result.BigDecimal, digits=#PB_Default)
Declare BDFromQuad(quad.q, *result.BigDecimal)


Global BDRoundMode
Global BDSpecValueNegInf.BigDecimal
Global BDSpecValueInf.BigDecimal
Global BDSpecValNegOne.BigDecimal
Global Dim BDSpecValue.BigDecimal(10)


; Initializations-Methode (für Tailbite)
Procedure BigDecimal_Init()
  Protected i
  BDRoundMode = #BDRoundDown
  
  BDMultiExp(0) = 1
  For i = 1 To #BDDigitsInLong-1
    BDMultiExp(i) = BDMultiExp(i-1)*10
  Next
  
  BDFromQuad(-1, BDSpecValNegOne)
  For i = 0 To 10
    BDFromQuad(i, BDSpecValue(i))
  Next
  
  BDSpecValueInf\sgn = 1
  BDSpecValueInf\exp = #BDExpInf
  BDSpecValueNegInf\sgn = -1
  BDSpecValueNegInf\exp = #BDExpInf
EndProcedure
BigDecimal_Init()


; Verkleinert eine BigDecimal-Zahl auf 'digits'-Nachkomma-
; stellen (rundet dabei) und normalisiert sie
; (d.h. keine Nullen am Anfang und am Ende)
Procedure _BDNorm(*bd.BigDecimal, digits=#PB_Default)
  Protected count, eman, sman, i, stmax, exp, long, rup
  If (*bd\size = 0)
    ; ist 0, Infinity oder NaN
    ProcedureReturn 
  EndIf
  i = 0
  If (digits >= 0)
    ; Zahl wird verkleinert
    ; Alle überflüssigen Teile der Mantisse auf 0 setzen
    exp = *bd\exp - *bd\size
    While ((exp+1)*#BDDigitsInLong < -digits)
      *bd\man(i) = 0
      i + 1
      exp + 1
    Wend
    If (exp*#BDDigitsInLong < -digits)
      ; Alle überflüssigen Stellen ignorieren, außer die die
      ; zum Runden wichtig ist (long%10)
      long = *bd\man(i) / BDMultiExp(#BDDigitsInLong-digits%#BDDigitsInLong-1)
      ; Wenn rup = 1, dann wird aufgerundet
      Select BDRoundMode
        Case #BDRoundDown
        Case #BDRoundUp
          rup = 1
        Case #BDRoundCeiling
          If (*bd\sgn > 0)
            rup = 1
          EndIf
        Case #BDRoundFloor
          If (*bd\sgn < 0)
            rup = 1
          EndIf
        Case #BDRoundHalfDown, #BDRoundHalfUp
          If (long%10 > 5)
            rup = 1
          ElseIf (long%10 = 5)
            If (BDRoundMode = #BDRoundHalfUp)
              rup = 1
            EndIf
          EndIf
      EndSelect
      If (digits%#BDDigitsInLong = 0)
        ; Spezialfall, wenn die Stelle, die zum Runden wichtig ist,
        ; im nächsten Mantissenteil steht
        *bd\man(i) = 0
        i + 1
        If (i = *bd\size)
          If (rup = 0)
            ClearStructure(*bd, BigDecimal)
            *bd\exp = #BDExpNull
            ProcedureReturn 
          EndIf
          ; Für das Aufrunden ist kein Platz, Mantisse muss vergrößert werden
          ReDim *bd\man(i)
          *bd\size + 1
          *bd\exp + 1
        EndIf
        *bd\man(i) + rup
      Else
        ; Die Zahl ohne die überflüssigen Stellen wird wieder
        ; in die Mantisse geschrieben (ggf. wird aufgerundet)
        *bd\man(i) = (long/10 + rup) * BDMultiExp(#BDDigitsInLong-digits%#BDDigitsInLong)
      EndIf
      If (rup = 1)
        ; Durch das Aufrunden ist die Zahl im Mantissenteil zu groß
        While (*bd\man(i) = #BDMaxInLong)
          *bd\man(i) = 0
          i + 1
          If (i = *bd\size)
            ; Für das Aufrunden ist kein Platz, Mantisse muss vergrößert werden
            ReDim *bd\man(i)
            *bd\size + 1
            *bd\exp + 1
          EndIf
          *bd\man(i) + 1
        Wend
      EndIf
    EndIf
  EndIf
  ; Ist der Mantissenteil am Ende gleich 0
  eman = i
  While (*bd\man(eman) = 0)
    eman + 1
    If (eman = *bd\size)
      ; Die gesammte Mantisse ist gleich 0 -> Zahl ist 0
      ClearStructure(*bd, BigDecimal)
      *bd\exp = #BDExpNull
      ProcedureReturn 
    EndIf
  Wend
  ; Ist der Mantissenteil am Anfang gleich 0
  sman = 0
  While (*bd\man(*bd\size-sman-1) = 0)
    sman + 1
  Wend
  If (eman+sman > 0)
    ; Mantisse muss verkleinert werden
    Protected Dim help.l(*bd\size-eman-sman-1)
    For i = eman To *bd\size-sman-1
      help(i-eman) = *bd\man(i)
    Next
    CopyArray(help(), *bd\man())
    *bd\size = *bd\size-eman-sman
    *bd\exp - sman
  EndIf
EndProcedure


; Kopiert eine BigDecimal-Zahl und speichert das Ergebnis
; in '*result', ggf. wird '*result' ungenauer durch Angabe von 'digits'
Procedure BDCopy(*bd.BigDecimal, *result.BigDecimal, digits=#PB_Default)
  If (*bd <> *result)
    If (*bd\man() <> #Null)
      Dim *result\man(0)
    EndIf
    *result\exp  = *bd\exp
    *result\sgn  = *bd\sgn
    *result\size = *bd\size
    CopyArray(*bd\man(), *result\man())
    ;   CopyStructure(*bd, *result, BigDecimal)
  EndIf
  If (digits >= 0)
    _BDNorm(*result, digits)
  EndIf
  ProcedureReturn *result
EndProcedure

; Negiert eine BigDecimal-Zahl und speichert das Ergebnis
; in '*result', ggf. wird '*result' ungenauer durch Angabe von 'digits'
Procedure BDNegative(*bd.BigDecimal, *result.BigDecimal, digits=#PB_Default)
  BDCopy(*bd, *result, #PB_Default)
  *result\sgn * (-1)
  If (digits >= 0)
    _BDNorm(*result, digits)
  EndIf
  ProcedureReturn *result
EndProcedure


; Setzt den Modus, wie gerundet wird
Procedure BDRoundMode(mode)
  If (mode >= 0) And (mode <= #BDRoundHalfUp)
    BDRoundMode = mode
  EndIf
EndProcedure


; Konvertiert ein String in eine BigDecimal-Zahl und
; speichert das Ergebnis in '*result'
Procedure BDFromString(str.s, *result.BigDecimal)
  Protected *string.Character, pos, i, cntvman, cntnman, count
  ClearStructure(*result, BigDecimal)
  *result\sgn = 1
  *string = @str
  If (PeekC(*string) = '-')
    ; Zahl ist negativ
    *string + SizeOf(Character)
    *result\sgn = -1
  ElseIf (PeekC(*string) = '+')
    *string + SizeOf(Character)
  EndIf
  If (CompareMemoryString(*string, @"infinity", #PB_String_NoCase, 8) = #PB_String_Equal)
    ; Zahl ist Infinity
    *result\exp = #BDExpInf
    ProcedureReturn *result
  ElseIf (CompareMemoryString(*string, @"nan", #PB_String_NoCase, 8) = #PB_String_Equal)
    *result\exp = #BDExpNaN
    ProcedureReturn *result
  EndIf
  str = PeekS(*string)
  *string = @str
  pos = FindString(str, ".", 0)
  If (pos = 0)
    pos = Len(str)+1
  EndIf
  ; Anzahl der Mantissenteile hinter/vor dem Punkt
  cntnman = Round((Len(str)-pos)/#BDDigitsInLong,#PB_Round_Up)
  cntvman = Round((pos-1)/#BDDigitsInLong,#PB_Round_Up)
  If (cntnman+cntvman <= 0)
    *result\sgn = 0
    *result\exp = #BDExpNull
    ProcedureReturn *result
  EndIf
  Dim *result\man(cntvman+cntnman-1)
  count = #BDDigitsInLong - (cntnman*#BDDigitsInLong-(Len(str)-pos))
  For i = 0 To cntnman-1
    ; Mantisse erstellen für Ziffern hinterm Punkt
    *result\man(i) = Val(PeekS(*string+(pos+(cntnman-1-i)*#BDDigitsInLong)*SizeOf(Character), count)) * BDMultiExp(#BDDigitsInLong-count)
    count = #BDDigitsInLong
  Next
  pos - 1
  count = #BDDigitsInLong
  For i = cntnman To cntnman+cntvman-1
    ; Mantisse erstellen für Ziffern vorm Punkt
    pos - #BDDigitsInLong
    If (pos < 0)
      count = #BDDigitsInLong+pos
      pos = 0
    EndIf
    *result\man(i) = Val(PeekS(*string+pos*SizeOf(Character), count))
  Next
  *result\size = cntnman+cntvman
  *result\exp = cntvman
  _BDNorm(*result, #PB_Default)
  ProcedureReturn *result
EndProcedure


; Konvertiert ein Double in eine BigDecimal-Zahl und
; speichert das Ergebnis in '*result'
Procedure BDFromDouble(double.d, *result.BigDecimal, digits=#PB_Default)
  ClearStructure(*result, BigDecimal)
  If IsNAN(double)
    *result\exp = #BDExpNaN
  ElseIf (double = 0)
    *result\sgn = 0
    *result\exp = #BDExpNull
  Else
    If (digits < 0)
      digits = 15*#BDDigitsInLong-1
    EndIf
    BDFromString(StrD(double, digits+1), *result)
  EndIf
  _BDNorm(*result, digits)
  ProcedureReturn *result
EndProcedure


; Konvertiert ein Long in eine BigDecimal-Zahl und
; speichert das Ergebnis in '*result'
Procedure BDFromQuad(quad.q, *result.BigDecimal)
  ClearStructure(*result, BigDecimal)
  If (quad < 0)
    quad * (-1)
    *result\sgn = -1
  Else
    *result\sgn = 1
  EndIf
  If (quad = 0)
    *result\sgn = 0
    *result\exp = #BDExpNull
    ProcedureReturn *result
  ElseIf (quad < #BDMaxInLong)
    Dim *result\man(0)
    *result\man(0) = quad
    *result\exp = 1
  ElseIf (quad < #BDMaxInLong*#BDMaxInLong)
    Dim *result\man(1)
    *result\man(0) = quad % #BDMaxInLong
    *result\man(1) = quad / #BDMaxInLong
    *result\exp = 2
  Else
    Dim *result\man(2)
    *result\man(0) =  quad % #BDMaxInLong
    *result\man(1) = (quad / #BDMaxInLong) % #BDMaxInLong
    *result\man(2) =  quad / #BDMaxInLong  / #BDMaxInLong
    *result\exp = 3
  EndIf
  *result\size = *result\exp
  _BDNorm(*result, #PB_Default)
  ProcedureReturn *result
EndProcedure


; Konvertiert die BigDecimal-Zahl in ein String
Procedure.s BDStr(*bd.BigDecimal, digits=#PB_Default)
  Protected str.s
  Protected i, cntdig
  If (digits >= 0)
    BDCopy(*bd, *bd, digits)
  EndIf
  If (*bd\sgn = -1)
    str = "-"
    ;   ElseIf (*bd\sgn = 1)
    ;     str = "+"
  EndIf
  If (*bd\size = 0)
    ; Spezielle Werte
    Select *bd\exp
      Case #BDExpNaN
        ProcedureReturn "NaN"
      Case #BDExpInf
        ProcedureReturn str+"Infinity"
    EndSelect
  EndIf
  cntdig = -1
  If (*bd\exp <= 0)
    ; Zahl ist kleiner 0
    If (digits = 0)
      ProcedureReturn str+"0"
    EndIf
    cntdig = -*bd\exp*#BDDigitsInLong
    str + "0."
    If (cntdig <> 0)
      ; Schreibt Nullen, die nicht in der Mantisse gespeichert sind
      str + RSet("", cntdig, "0")
    EndIf
  EndIf
  i = *bd\size
  While (#True)
    i - 1
    If (digits >= 0) And (cntdig >= digits)
      ; Zu viele Ziffern sind im String -> String wird gekürzt
      str = PeekS(@str, Len(str)-(cntdig-digits))
      Break
    EndIf
    If (cntdig = -1)
      If (*bd\size-i-1 = *bd\exp)
        If (digits <> 0)
          str + "."
        EndIf
        cntdig = #BDDigitsInLong
      EndIf
    Else
      cntdig + #BDDigitsInLong
    EndIf
    If (i >= 0)
      ; Schreibt die Zahl aus der Mantisse (ggf. mit Nullen vorweg)
      If (i = *bd\size-1) And (*bd\exp > 0)
        str + Str(*bd\man(i))
      Else
        str + RSet(Str(*bd\man(i)), #BDDigitsInLong, "0")
      EndIf
    Else
      ; Die Mantisse ist durchlaufen
      If (digits < 0) And (cntdig <> -1)
        ; Wenn 'digits' nicht angegeben wurde, sind wir fertig
        Break
      EndIf
      str + RSet("", #BDDigitsInLong, "0")
    EndIf
  Wend
  ProcedureReturn str
EndProcedure


Macro BDIsNull(_bd_)
  ((_bd_\size = 0) And (_bd_\exp = #BDExpNull) And 1)
EndMacro

Macro BDIsNaN(_bd_)
  ((_bd_\size = 0) And (_bd_\exp = #BDExpNaN) And 1)
EndMacro

Macro BDIsNegative(_bd_)
  ((_bd_\sgn < 0) And 1)
EndMacro

Macro BDIsLittleNumber(_bd_)
  (((_bd_\size = 0) Or ((_bd_\size - _bd_\exp >= 0) And (_bd_\size = 1))) And 1)
EndMacro


; Vergleicht zwei BigDecimal-Zahlen
; -1: *bda < *bdb, 0: *bda = *bdb, 1: *bda > *bdb
Procedure BDCompare(*bda.BigDecimal, *bdb.BigDecimal)
  If ((*bda\size = 0) And (*bda\exp = #BDExpNaN)) Or ((*bdb\size = 0) And (*bdb\exp = #BDExpNaN))
    ; Wenn eine Zahl 'NaN' ist, ist das Ergebnis 0
    ProcedureReturn 0
  EndIf
  ; Signum vergleichen
  If (*bda\sgn < *bdb\sgn)
    ProcedureReturn -1
  ElseIf (*bda\sgn > *bdb\sgn)
    ProcedureReturn 1
  ElseIf (*bda\sgn = 0)
    ; Beide Zahlen sind gleich 0
    ProcedureReturn 0
  EndIf
  ; Vergleich mit Infinity
  If (*bda\size = 0) And (*bda\exp = #BDExpInf)
    If (*bdb\size = 0) And (*bdb\exp = #BDExpInf)
      ProcedureReturn 0
    EndIf
    ProcedureReturn 1 * *bda\sgn
  ElseIf (*bdb\size = 0) And (*bdb\exp = #BDExpInf)
    ProcedureReturn (-1) * *bda\sgn
  EndIf
  ; Vergleich zweier normaler Zahlen
  Protected ia, ib, cmp
  cmp = *bda\exp - *bdb\exp
  ; Vergleich der Exponenten
  If (cmp < 0)
    ProcedureReturn (-1) * *bda\sgn
  ElseIf (cmp > 0)
    ProcedureReturn 1 * *bda\sgn
  EndIf
  ia = *bda\size
  ib = *bdb\size
  Repeat
    ia - 1
    ib - 1
    If (ia < 0) And (ib < 0)
      ; Beide Zahlen enden gleichzeitig
      Break
    EndIf
    ; Eine Zahl endet, die andere Zahl ist größer (bei +) bzw. kleiner (bei -)
    If (ia < 0)
      ProcedureReturn (-1) * *bda\sgn
    ElseIf (ib < 0)
      ProcedureReturn 1 * *bda\sgn
    EndIf
    ; Vergleich der Mantissenteile
    cmp = *bda\man(ia) - *bdb\man(ib)
    If (cmp < 0)
      ProcedureReturn (-1) * *bda\sgn
    ElseIf (cmp > 0)
      ProcedureReturn 1 * *bda\sgn
    EndIf
  ForEver
  ProcedureReturn 0
EndProcedure


; Addiert zwei BigDecimal-Zahlen und speichert das Ergebnis
; in '*result'
Procedure BDAdd(*bda.BigDecimal, *bdb.BigDecimal, *result.BigDecimal, digits=#PB_Default)
  If ((*bda\size = 0) And (*bda\exp = #BDExpNaN)) Or ((*bdb\size = 0) And (*bdb\exp = #BDExpNaN))
    ; Eine Zahl ist 'NaN'
    ClearStructure(*result, BigDecimal)
    *result\exp = #BDExpNaN
    ProcedureReturn *result
  ElseIf (*bda\size = 0) And (*bda\exp = #BDExpNull)
    ; '*bda' ist 0, das Ergebnis ist '*bdb'
    ProcedureReturn BDCopy(*bdb, *result, digits)
  ElseIf (*bdb\size = 0) And (*bdb\exp = #BDExpNull)
    ; '*bdb' ist 0, das Ergebnis ist '*bda'
    ProcedureReturn BDCopy(*bda, *result, digits)
  EndIf
  Protected sub.BigDecimal
  ; Zwei verschiedene Signums -> es wird subrahiert
  If (*bdb\sgn = -1) And (*bda\sgn = 1)
    BDNegative(*bdb, sub, #PB_Default)
    ProcedureReturn BDSub(*bda, sub, *result, digits)
  ElseIf (*bda\sgn = -1) And (*bdb\sgn = 1)
    BDNegative(*bda, sub, #PB_Default)
    ProcedureReturn BDSub(*bdb, sub, *result, digits)
  EndIf
  ; Addition mit Infinity
  If (*bda\size = 0) And (*bda\exp = #BDExpInf)
    BDCopy(*bda, *result, digits)
    ProcedureReturn *result
  ElseIf (*bdb\size = 0) And (*bdb\exp = #BDExpInf)
    BDCopy(*bdb, *result, digits)
    ProcedureReturn *result
  EndIf
  ; Addition zweier normaler Zahlen
  Protected sman, eman, i, ia, ib, longa, longb, ub, sgn
  sgn = *bda\sgn
  ; Suche den größeren Exponenten
  sman = *bda\exp
  If (sman < *bdb\exp)
    sman = *bdb\exp
  EndIf
  ; Suche den kleineren Exponenten (bzw. Grenze ist 'digits')
  If (digits < 0)
    eman = *bda\exp - *bda\size
    If (eman > *bdb\exp - *bdb\size)
      eman = *bdb\exp - *bdb\size
    EndIf
  Else
    eman = -Round((digits+1)/#BDDigitsInLong, #PB_Round_Up)
  EndIf
  Protected Dim help.l(sman-eman)
  i = eman
  ub = 0
  While (i < sman)
    ; Addiere beide Mantissenteile
    longa = 0
    longb = 0
    ia = i + *bda\size - *bda\exp
    ib = i + *bdb\size - *bdb\exp
    If (ia < 0)
    ElseIf (ia < *bda\size)
      longa = *bda\man(ia)
    EndIf
    If (ib < 0)
    ElseIf (ib < *bdb\size)
      longb = *bdb\man(ib)
    EndIf
    help(i-eman) = (longa+longb+ub) % #BDMaxInLong
    ; Übertrag der Addition
    ub = (longa+longb+ub) / #BDMaxInLong
    i + 1
  Wend
  ; Speichere letzten Übertrag
  help(sman-eman) = ub
  ClearStructure(*result, BigDecimal)
  Dim *result\man(sman-eman)
  CopyArray(help(), *result\man())
  *result\exp = sman+1
  *result\sgn = sgn
  *result\size = sman-eman+1
  _BDNorm(*result, digits)
  ProcedureReturn *result
EndProcedure


; Subtrahiert zwei BigDecimal-Zahlen und speichert das Ergebnis
; in '*result'
Procedure BDSub(*bda.BigDecimal, *bdb.BigDecimal, *result.BigDecimal, digits=#PB_Default)
  If ((*bda\size = 0) And (*bda\exp = #BDExpNaN)) Or ((*bdb\size = 0) And (*bdb\exp = #BDExpNaN))
    ; Eine Zahl ist 'NaN'
    ClearStructure(*result, BigDecimal)
    *result\exp = #BDExpNaN
    ProcedureReturn *result
  EndIf
  Protected add.BigDecimal
  If (*bda\sgn * *bdb\sgn < 1)
    ; Zahlen haben verscheidene Signums, oder eine Zahl ist 0
    BDNegative(*bdb, add, #PB_Default)
    ProcedureReturn BDAdd(*bda, add, *result, digits)
  EndIf
  ; Subtraktion mit Infinity
  If (*bda\size = 0) And (*bda\exp = #BDExpInf)
    If (*bdb\size = 0) And (*bdb\exp = #BDExpInf)
      ; Infinity-Infinity = NaN
      ClearStructure(*result, BigDecimal)
      *result\exp = #BDExpNaN
      ProcedureReturn *result
    EndIf
    BDCopy(*bda, *result, digits)
    ProcedureReturn *result
  ElseIf (*bdb\size = 0) And (*bdb\exp = #BDExpInf)
    BDNegative(*bdb, *result, digits)
    ProcedureReturn *result
  EndIf
  ; Subtraktion mit normalen Zahlen
  Protected cmp, sman, eman, i, ia, ib, longa, longb, long, ub
  ; 'cmp' ist Signum der neuen Zahl
  cmp = BDCompare(*bda, *bdb)
  If (cmp = 0)
    ClearStructure(*result, BigDecimal)
    *result\exp = #BDExpNull
    ProcedureReturn *result
  ElseIf (cmp * *bda\sgn < 0)
    ; Vertausche die Zahlen, falls |*bda|<|*bdb|
    Swap *bda, *bdb
  EndIf
  sman = *bda\exp
  ; Suche den kleineren Exponenten (bzw. Grenze ist 'digits')
  If (digits < 0)
    eman = *bda\exp - *bda\size
    If (eman > *bdb\exp - *bdb\size)
      eman = *bdb\exp - *bdb\size
    EndIf
  Else
    eman = -Round((digits+1)/#BDDigitsInLong, #PB_Round_Up)
  EndIf
  Protected Dim help.l(sman-eman-1)
  i = eman
  ub = 0
  While (i < sman)
    ; Subtrahiere beide Mantissenteile
    longa = 0
    longb = 0
    ia = i + *bda\size - *bda\exp
    ib = i + *bdb\size - *bdb\exp
    If (ia < 0)
    ElseIf (ia < *bda\size)
      longa = *bda\man(ia)
    EndIf
    If (ib < 0)
    ElseIf (ib < *bdb\size)
      longb = *bdb\man(ib)
    EndIf
    long = longa-longb-ub
    If (long < 0)
      ; Erste Zahl ist kleiner als zweite -> Übertrag
      long + #BDMaxInLong
      ub = 1
    Else
      ub = 0
    EndIf
    help(i-eman) = long
    i + 1
  Wend
  ClearStructure(*result, BigDecimal)
  Dim *result\man(sman-eman-1)
  CopyArray(help(), *result\man())
  *result\exp = sman
  *result\sgn = cmp
  *result\size = sman-eman
  _BDNorm(*result, digits)
  ProcedureReturn *result
EndProcedure


; Multipliziert zwei BigDecimal-Zahlen und speichert das Ergebnis
; in '*result'
Procedure BDMul(*bda.BigDecimal, *bdb.BigDecimal, *result.BigDecimal, digits=#PB_Default)
  If ((*bda\size = 0) And (*bda\exp = #BDExpNaN)) Or ((*bdb\size = 0) And (*bdb\exp = #BDExpNaN))
    ; Eine Zahl ist 'NaN'
    ClearStructure(*result, BigDecimal)
    *result\exp = #BDExpNaN
    ProcedureReturn *result
  EndIf
  Protected sgn
  sgn = *bda\sgn * *bdb\sgn
  If ((*bda\size = 0) And (*bda\exp = #BDExpInf)) Or ((*bdb\size = 0) And (*bdb\exp = #BDExpInf))
    ; Multiplikation mit Infinity
    ClearStructure(*result, BigDecimal)
    *result\sgn = sgn
    If (*result\sgn = 0)
      ; 0*Infinity = NaN
      *result\exp = #BDExpNaN
    Else
      *result\exp = #BDExpInf
    EndIf
    ProcedureReturn *result
  EndIf
  ; Multiplikation mit normalen Zahlen
  Protected size, exp, stman, i, k, rsi, ub, quad.q
  If (sgn = 0)
    ClearStructure(*result, BigDecimal)
    *result\exp = #BDExpNull
    ProcedureReturn *result
  EndIf
  stman = 0
  ; Neuer Exponent und Länge der Mantisse
  exp  = *bda\exp  + *bdb\exp
  size = *bda\size + *bdb\size
  If (digits >= 0)
    ; Wenn 'digits' angegeben, werden die hinteren Teile nicht berechnet
    i = Round((digits+2)/#BDDigitsInLong, #PB_Round_Up)
    If (size > i+exp)
      stman = size-(i+exp)
      size = i+exp
    EndIf
  EndIf
  If (size <= 0)
    ClearStructure(*result, BigDecimal)
    *result\exp = #BDExpNull
    ProcedureReturn *result
  EndIf
  Protected Dim help.l(size-1)
  For i = 0 To *bda\size-1
    ; Gehe erste Zahl durch
    ub = 0
    For k = 0 To *bdb\size-1
      ; Gehe zweite Zahl durch
      rsi = i+k-stman
      If (rsi >= 0)
        ; Multipliziere beide Mantissenteile, addiere dazu
        ; den vorherigen Übertrag und ggf. den alten Wert
        ; im Ergebnis (schriftliches Multiplizieren)
        If (i > 0)
          quad = *bda\man(i) * *bdb\man(k) + ub + help(rsi)
        Else
          quad = *bda\man(i) * *bdb\man(k) + ub
        EndIf
        help(rsi) = quad % #BDMaxInLong
        ub = quad / #BDMaxInLong
      EndIf
    Next
    rsi = i+*bdb\size-stman
    ; Speichere letzten Übertrag
    If (rsi >= 0)
      help(rsi) + ub
    EndIf
  Next
  ClearStructure(*result, BigDecimal)
  Dim *result\man(size-1)
  CopyArray(help(), *result\man())
  *result\exp = exp
  *result\sgn = sgn
  *result\size = size
  _BDNorm(*result, digits)
  ProcedureReturn *result
EndProcedure


; Dividiert zwei BigDecimal-Zahlen und speichert das Ergebnis
; in '*result'
Procedure BDDiv(*bda.BigDecimal, *bdb.BigDecimal, *result.BigDecimal, *modres.BigDecimal=#Null, digits=#PB_Default)
  If ((*bda\size = 0) And (*bda\exp = #BDExpNaN)) Or ((*bdb\size = 0) And (*bdb\exp = #BDExpNaN))
    ; Eine Zahl ist 'NaN'
    If (*modres <> #Null)
      ClearStructure(*modres, BigDecimal)
      *modres\exp = #BDExpNaN
    EndIf
    If (*result <> #Null)
      ClearStructure(*result, BigDecimal)
      *result\exp = #BDExpNaN
    EndIf
    ProcedureReturn *result
  EndIf
  
  Protected sgn
  sgn = *bda\sgn * *bdb\sgn
  If (*bda\size = 0) And (*bda\exp = #BDExpInf)
    If (*bdb\size = 0) And (*bdb\exp = #BDExpInf)
      ; Infinity/Infinity = NaN
      If (*modres <> #Null)
        ClearStructure(*modres, BigDecimal)
        *modres\exp = #BDExpNaN
      EndIf
      If (*result <> #Null)
        ClearStructure(*result, BigDecimal)
        *result\exp = #BDExpNaN
      EndIf
      ProcedureReturn *result
    EndIf
    If (sgn = 0)
      sgn = *bda\sgn
    EndIf
    If (*modres <> #Null)
      ClearStructure(*modres, BigDecimal)
      *modres\exp = #BDExpInf
      *modres\sgn = sgn
    EndIf
    If (*result <> #Null)
      ClearStructure(*result, BigDecimal)
      *result\exp = #BDExpInf
      *result\sgn = sgn
    EndIf
    ProcedureReturn *result
    
  ElseIf (*bdb\size = 0) And (*bdb\exp = #BDExpInf)
    If (*modres <> #Null)
      ClearStructure(*modres, BigDecimal)
      *modres\exp = #BDExpNull
    EndIf
    If (*result <> #Null)
      ClearStructure(*result, BigDecimal)
      *result\exp = #BDExpNull
    EndIf
    ProcedureReturn *result
  EndIf
  If (*bdb\size = 0) And (*bdb\exp = #BDExpNull)
    ; Division durch 0
    If (*modres <> #Null)
      ClearStructure(*modres, BigDecimal)
      *modres\exp = #BDExpNaN
    EndIf
    If (*result <> #Null)
      ClearStructure(*result, BigDecimal)
      *result\exp = #BDExpNaN
    EndIf
    ProcedureReturn *result
  ElseIf (*bda\size = 0) And (*bda\exp = #BDExpNull)
    ; Divident ist 0
    If (*modres <> #Null)
      ClearStructure(*modres, BigDecimal)
      *modres\exp = #BDExpNull
    EndIf
    If (*result <> #Null)
      ClearStructure(*result, BigDecimal)
      *result\exp = #BDExpNull
    EndIf
  EndIf
  
  Protected size, exp, i, ia, k, ka, asize, multiDigits
  Protected diva.q, quad.q, quadb.q, ub, qhat, qrem, double.d
  Protected modsgn, modexp
  
  ; Neuer Exponent und Länge der Mantisse
  If (digits < 0)
    digits = ((*bda\size-*bda\exp) + (*bdb\size-*bdb\exp) + 1) * #BDDigitsInLong
  EndIf
  exp = *bda\exp - *bdb\exp + 1
  If (*modres <> #Null)
    size = exp
  Else
    size = exp+Round((digits+2)/#BDDigitsInLong, #PB_Round_Up)
  EndIf
  If (size <= 0)
    If (*modres <> 0)
      BDCopy(*bda, *modres, digits)
    EndIf
    If (*result <> 0)
      ClearStructure(*result, BigDecimal)
      *result\exp = #BDExpNull
    EndIf
    ProcedureReturn *result
  EndIf
  
  ; Divident braucht neue Länge
  asize = size + *bdb\size
  If (asize <= *bda\size)
    asize = *bda\size+1
  EndIf
  Dim help.l(size-1)
  Protected Dim diva.l(asize-1)
  Protected Dim divb.l(*bdb\size-1)
  
  ; Divisor normieren (erste Mantisse darf nicht mit einer 0 starten)
  multiDigits = 0
  qhat = *bdb\man(*bdb\size-1)
  Repeat
    qhat / 10
    multiDigits + 1
  Until (qhat = 0)
  
  ; Divident speichern (dabei normieren)
  ub = 0
  ia = asize-*bda\size-1
  For i = 0 To *bda\size-1
    quad = *bda\man(i) * BDMultiExp(#BDDigitsInLong-multiDigits)
    diva(ia) = quad % #BDMaxInLong + ub
    ub = quad / #BDMaxInLong
    ia + 1
  Next
  diva(ia) = ub
  
  ; Divisor speichern (dabei normieren)
  ub = 0
  For i = 0 To *bdb\size-1
    quad = *bdb\man(i) * BDMultiExp(#BDDigitsInLong-multiDigits)
    divb(i) = quad % #BDMaxInLong + ub
    ub = quad / #BDMaxInLong
  Next
  
  ; Berechnung starten
  ia = asize-1
  For i = size-1 To 0 Step -1
    If (ia > 0)
      diva = diva(ia) * #BDMaxInLong + diva(ia-1)
    Else
      diva = diva(ia) * #BDMaxInLong
    EndIf
    qhat = diva / divb(*bdb\size-1)
    qrem = diva % divb(*bdb\size-1)
    If (*bdb\size >= 2)
      ; Divisor hat mehr als einen Mantissenteil
      ; Ergebnis der Divisorn korrigieren
      If (ia >= 2)
        quad = qrem * #BDMaxInLong + diva(ia-2)
      Else
        quad = qrem * #BDMaxInLong
      EndIf
      quadb = divb(*bdb\size-2) * qhat
      If (quad < quadb)
        qhat - 1
      EndIf
    EndIf
    If (qhat > 0)
      ; Vom Divident 'qhat*Divisor' subtrahieren
      ka = ia-*bdb\size
      ub = 0
      For k = 0 To *bdb\size-1
        quad = diva(ka) - divb(k) * qhat - ub
        If (quad < 0)
          double = Round((-quad) / #BDMaxInLong, #PB_Round_Up)
          ub = double
          quad + ub * #BDMaxInLong
        Else
          ub = 0
        EndIf
        diva(ka) = quad
        ka + 1
      Next
      If (ub > diva(ka))
        ; Ergebnis der Divisorn nochmal korrigieren, da bei
        ; der Subraktion eine negative Zahl rauskam
        diva(ka) - ub
        Repeat
          qhat - 1
          ; Addiere zum Divident einmal den Divisor
          ka = ia-*bdb\size
          ub = 0
          For k = 0 To *bdb\size-1
            diva(ka) + divb(k) + ub
            If (diva(ka) >= #BDMaxInLong)
              diva(ka) - #BDMaxInLong
              ub = 1
            Else: ub = 0
            EndIf
            ka + 1
          Next
          diva(ka) + ub
        Until (diva(ka) >= 0)
      EndIf
      ; Speichere Ergebnis der Division
      diva(ka) = 0
      help(i) = qhat
    EndIf
    ia - 1
  Next
  
  If (*modres <> #Null)
    modexp = *bda\exp
    modsgn = *bda\sgn
    ClearStructure(*modres, BigDecimal)
    Dim *modres\man(asize-1)
    ub = 0
    For i = asize-2 To 0 Step -1
      If (multiDigits < #BDDigitsInLong)
        *modres\man(i+1) = ub + diva(i) / BDMultiExp(#BDDigitsInLong-multiDigits)
        ub = (diva(i) % BDMultiExp(#BDDigitsInLong-multiDigits)) * BDMultiExp(multiDigits)
        ub = (diva(i) % BDMultiExp(#BDDigitsInLong-multiDigits)) * BDMultiExp(multiDigits)
      Else
        *modres\man(i+1) = diva(i)
      EndIf
    Next
    *modres\man(0) = ub
    *modres\exp = modexp
    *modres\sgn = modsgn
    *modres\size = asize
    _BDNorm(*modres, digits)
  EndIf
  
  If (*result <> #Null)
    ClearStructure(*result, BigDecimal)
    Dim *result\man(size-1)
    CopyArray(help(), *result\man())
    *result\exp = exp
    *result\sgn = sgn
    *result\size = size
    _BDNorm(*result, digits)
  EndIf
  ProcedureReturn *result
EndProcedure


; Berechnet das Ergebnis der Exponentialfunktion
; und speichert es in '*result'
Procedure BDExp(*bd.BigDecimal, *result.BigDecimal, digits)
  Protected.BigDecimal num, den, sum, bdi, div
  Protected i.i
  If (*bd\size = 0)
    Select *bd\exp
      Case #BDExpNaN
        BDCopy(*bd, *result)
      Case #BDExpInf
        If (*bd\sgn = 1)
          ; e^inf = inf
          BDCopy(*bd, *result)
        Else
          ; e^(-inf) = 0
          ClearStructure(*result, BigDecimal)
          *result\exp = #BDExpNull
        EndIf
      Case #BDExpNull
        ; e^0 = 1
        BDCopy(BDSpecValue(1), *result)
    EndSelect
    ProcedureReturn *result
  EndIf
  If (*bd\sgn < 0)
    ; e^(-a) = 1/e^a
    BDNegative(*bd, num)
    BDExp(num, den, digits)
    BDDiv(BDSpecValue(1), den, *result, #Null, digits)
    ProcedureReturn *result
  EndIf
  ; e^z = sum(z^k/k!, k=0..infinity)
  BDCopy(*bd, num)
  BDCopy(BDSpecValue(1), den)
  BDCopy(BDSpecValue(1), sum)
  i = 1
  Repeat
    BDDiv(num, den, div, #Null, digits)
    If (div\size = 0) And (div\exp = #BDExpNull)
      ; Die Summanten sind zu klein geworden
      Break
    EndIf
    BDAdd(sum, div, sum)
    i + 1
    BDMul(num, *bd, num)
    BDFromQuad(i, bdi)
    BDMul(den, bdi, den)
  ForEver
  ProcedureReturn BDCopy(sum, *result, digits)
EndProcedure


; Berechnet das Ergebnis der Logarithmusfunktion
; und speichert es in '*result'
Procedure BDLog(*bd.BigDecimal, *result.BigDecimal, digits)
  Protected.BigDecimal num, den, qnum, qden, div, mul, sum, sumb, bdi
  Protected long, multi, i, ub, bdsize, cmp
  If ((*bd\size = 0) And (*bd\exp = #BDExpNaN)) Or (*bd\sgn < 0)
    ; Zahl ist NaN oder negativ
    ClearStructure(*result, BigDecimal)
    *result\exp = #BDExpNaN
    ProcedureReturn *result
  EndIf
  If (*bd\size = 0)
    Select *bd\exp
      Case #BDExpInf
        ; ln(inf) = inf
        BDCopy(*bd, *result)
      Case #BDExpNull
        ; log(0) = -inf
        ClearStructure(*result, BigDecimal)
        *result\exp = #BDExpInf
        *result\sgn = -1
    EndSelect
    ProcedureReturn *result
  EndIf
  If (BDCompare(*bd, BDSpecValue(10)) > 0)
    ; Wenn die Zahl größer 10 ist
    ; log(a) = log(a/10^multi) + log(10)*multi
    long = *bd\man(*bd\size-1) / 10
    While (long <> 0)
      multi + 1
      long / 10
    Wend
    bdsize = *bd\size
    Dim num\man(bdsize)
    num\size = bdsize+1
    num\exp = 1
    num\sgn = 1
    For i = bdsize-1 To 0 Step -1
      If (multi = 0)
        num\man(i+1) = *bd\man(i)
      Else
        num\man(i+1) = *bd\man(i) / BDMultiExp(multi) + ub
        ub = (*bd\man(i) % BDMultiExp(multi)) * BDMultiExp(#BDDigitsInLong-multi)
      EndIf
    Next
    num\man(0) = ub
    _BDNorm(num)
    BDLog(num, sum, digits)
    multi + (*bd\exp-1) * #BDDigitsInLong
    BDFromQuad(multi, mul)
    BDLog(BDSpecValue(10), sumb, digits+multi/2)
    BDMul(mul, sumb, sumb)
    BDAdd(sum, sumb, *result, digits)
    ProcedureReturn *result
  ElseIf (BDCompare(*bd, BDSpecValue(2)) > 0)
    ; Wenn die Zahl größer 2 ist
    ; log(a) = log(a/2^multi) + log(2)*multi
    long = *bd\man(*bd\size-1)
    If (long >= 8)
      BDDiv(*bd, BDSpecValue(8), num, #Null, digits)
      BDLog(num, sum, digits)
      BDLog(BDSpecValue(2), sumb, digits)
      BDMul(BDSpecValue(3), sumb, sumb)
    ElseIf (long >= 4)
      BDDiv(*bd, BDSpecValue(4), num, #Null, digits)
      BDLog(num, sum, digits)
      BDLog(BDSpecValue(2), sumb, digits)
      BDMul(BDSpecValue(2), sumb, sumb)
    Else
      BDDiv(*bd, BDSpecValue(2), num, #Null, digits)
      BDLog(num, sum, digits)
      BDLog(BDSpecValue(2), sumb, digits)
    EndIf
    BDAdd(sum, sumb, *result, digits)
    ProcedureReturn *result
  EndIf
  cmp = BDCompare(*bd, BDSpecValue(1))
  If (cmp > 0)
    ; Wenn die Zahl größer 1 ist
    ; log(a) = sum((2/(2*k-1))*((a-1)/(a+1))^(2*i-1), i=1..infinity)
    BDCopy(BDSpecValue(0), sum)
    BDSub(*bd, BDSpecValue(1), num)
    BDAdd(*bd, BDSpecValue(1), den)
    BDMul(num, num, qnum)
    BDMul(den, den, qden)
    BDMul(num, BDSpecValue(2), num)
    i = 1
    Repeat
      BDFromQuad(i*2-1, bdi)
      BDDiv(num, den, div, #Null, digits)
      BDDiv(div, bdi, div, #Null, digits)
      If (div\size = 0) And (div\exp = #BDExpNull)
        ; Die Summanten sind zu klein geworden
        Break
      EndIf
      BDAdd(sum, div, sum)
      i + 1
      BDMul(num, qnum, num)
      BDMul(den, qden, den)
    ForEver
    ProcedureReturn BDCopy(sum, *result, digits)
  ElseIf (cmp = 0)
    ; log(1) = 0
    BDCopy(BDSpecValue(0), *result)
    ProcedureReturn *result
  Else
    ; Wenn die Zahl kleiner 1 ist
    ; log(a) = -log(1/a)
    BDDiv(BDSpecValue(1), *bd, div, #Null, digits)
    BDLog(div, num, digits)
    BDNegative(num, *result, digits)
    ProcedureReturn *result
  EndIf
EndProcedure


Procedure BDPow(*bda.BigDecimal, *bdb.BigDecimal, *result.BigDecimal, digits)
  Protected.BigDecimal log, mul, base, res
  Protected exponent
  
  If ((*bda\size = 0) And (*bda\exp = #BDExpNaN)) Or ((*bdb\size = 0) And (*bdb\exp = #BDExpNaN))
    ; Eine Zahl ist 'NaN'
    ClearStructure(*result, BigDecimal)
    *result\exp = #BDExpNaN
    ProcedureReturn *result
  EndIf
  
  If (*bda\size = 0) And (*bda\exp = #BDExpNull)
    If (*bdb\size = 0) And (*bdb\exp = #BDExpNull)
      ; 0^0 = NaN
      ClearStructure(*result, BigDecimal)
      *result\exp = #BDExpNaN
      ProcedureReturn *result
    EndIf
    ClearStructure(*result, BigDecimal)
    *result\exp = #BDExpNull
    ProcedureReturn *result
  ElseIf (*bdb\size = 0) And (*bdb\exp = #BDExpNull)
    BDCopy(BDSpecValue(1), *result)
    ProcedureReturn *result
  EndIf
  
  If (*bdb\exp-*bdb\size >= 0) And (*bdb\size = 1)
    exponent = *bdb\man(0)
    
    BDCopy(*bda, base)
    BDCopy(BDSpecValue(1), res)
    
    While (exponent <> 0)
      If (exponent % 2 = 1)
        If (*bdb\sgn > 0)
          BDMul(res, base, res)
        Else
          BDDiv(res, base, #Null, res)
        EndIf
      EndIf
      exponent >> 1
      If (exponent <> 0)
        BDMul(base, base, base)
      EndIf
    Wend
    BDCopy(res, *result, digits)
    
  Else
    BDLog(*bda, log, digits+5)
    BDMul(*bdb, log, mul)
    BDExp(mul, *result, digits)
  EndIf
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  Define.BigDecimal bda, bdb, result
  
  BDFromQuad(2947, bda)
  BDFromString("0.000000000000000001", bdb)
  BDAdd(bda, bdb, result)
  Debug BDStr(result)
  Debug BDStr(result, 10)
  
  BDFromString("10", bda)
  BDFromString("3", bdb)
  BDDiv(bda, bdb, result, #Null, 200)
  Debug BDStr(result)
  
  BDFromString("1", bda)
  BDExp(bda, result, 200)
  Debug BDStr(result)
  
  BDFromString("150", bda)
  BDLog(bda, result, 200)
  Debug BDStr(result)
  
  BDFromDouble(-Infinity(), bda)
  BDExp(bda, result, 20)
  Debug BDStr(result)
  
  BDFromString("12.74", bda)
  BDFromString("12.75", bdb)
  Debug BDStr(bda, 1)
  Debug BDStr(bdb, 1)
  
  BDRoundMode(#BDRoundHalfUp)
  
  BDFromString("12.74", bda)
  BDFromString("12.75", bdb)
  Debug BDStr(bda, 1)
  Debug BDStr(bdb, 1)
CompilerEndIf
