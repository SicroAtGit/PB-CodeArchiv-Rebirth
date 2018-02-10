;   Description: Get the geographic coordinates from a adresse
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29821
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016 Kurzer
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

EnableExplicit

InitNetwork()

Global.i *Buffer
Global.s sTemp, sAdresse, sBreitengrad, sLaengengrad, sKorrAdresse

#URL = "http://maps.google.com/maps/api/geocode/xml?sensor=false&address="

;sAdresse = "Autohaus, Radegaster Strasse 50a, 06369 Görzig"
sAdresse = "Schopperstr. 83, 07937 Zeulenroda"
;sAdresse = "556 Main Street New York"

Procedure.s GetXMLElement(sString.s, sElementname.s)
   Protected.i iPos1, iPos2

   iPos1 = FindString(sString, "<" + sElementname + ">") + Len(sElementname) + 2
   iPos2 = FindString(sString, "</" + sElementname + ">")
   If iPos2 > iPos1
      ProcedureReturn Mid(sString, iPos1, iPos2 - iPos1)
   EndIf
   ProcedureReturn ""
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  ; Anfrage an Google senden. Die Adresse ist in die URL eingebunden, Umlaute müssen nicht umgewandelt werden
  ; Google korrigiert ggf. fehlerhaft geschriebene Straßennamen, Orte und PLZ und gibt diese zusammen mit der Geo-Koordinate zurück.
  *Buffer = ReceiveHTTPMemory(#URL+URLEncoder(sAdresse, #PB_UTF8))
  If *Buffer
     sTemp = PeekS(*Buffer, MemorySize(*Buffer), #PB_UTF8)
     FreeMemory(*Buffer)
  
     If GetXMLElement(sTemp, "status") = "OK"
        sKorrAdresse = GetXMLElement(sTemp, "formatted_address")
        sLaengengrad = GetXMLElement(sTemp, "lat")
        sBreitengrad = GetXMLElement(sTemp, "lng")
     Else
        Debug "Fehler"
     EndIf
  
  Else
     Debug "Fehler"
  EndIf
  
  Debug sTemp
  Debug "Korrigierte Adresse: " + sKorrAdresse
  Debug "Breitengrad:         " + sBreitengrad
  Debug "Längengrad:          " + sLaengengrad
CompilerEndIf
