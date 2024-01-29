;   Description: Get the geographic coordinates from an address
;            OS: Windows, Linux, Mac
; English-Forum: https://www.purebasic.fr/english/viewtopic.php?f=27&t=66616
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29821
; -----------------------------------------------------------------------------

;*************************************************************************
;* AddressToGeo
;*************************************************************************
;*
;* Modulname         : AddressToGeo
;* Filename          : mod_AddressToGeo.pbi
;* Filetype          : Module [MainApp, Formular, Include, Module, Data]
;* Programming lang. : Purebasic 5.62+
;* String-Format     : Unicode [Ascii, Unicode, All]
;* Platform          : All [Windows, Mac, Linux, All]
;* Processor         : All [x86, x64, All]
;* Compileroptions   : -
;* Version           : 1.01
;* Date              : 17.04.2019
;* Author            : Kurzer
;* Dependencies      :
;* -----------------------------------------------------------------------
;* Description:
;*
;* Get the geographic coordinates from an address
;* -----------------------------------------------------------------------
;* Changelog:
;* 1.01 - add 17.04.2019: The primary coding is now done via the JSON
;*                        interface of Open Streetmap. Only if this encoding
;*                        fails there is a fallback to Google Maps.
;* 1.00 - rel 15.04.2019: First release
;* -----------------------------------------------------------------------
;* English-Forum     : https://www.purebasic.fr/english/viewtopic.php?f=27&t=66616
;* French-Forum      :
;* German-Forum      : https://www.purebasic.fr/german/viewtopic.php?f=8&t=29821
;* -----------------------------------------------------------------------
;* License: MIT License
;*
;* Copyright (c) 2016/19 Kurzer
;*
;* Permission is hereby granted, free of charge, to any person obtaining a copy
;* of this software and associated documentation files (the "Software"), to deal
;* in the Software without restriction, including without limitation the rights
;* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;* copies of the Software, and to permit persons to whom the Software is
;* furnished to do so, subject to the following conditions:
;*
;* The above copyright notice and this permission notice shall be included in all
;* copies or substantial portions of the Software.
;*
;* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;* SOFTWARE.
;*
;* ---------------- German translation of the MIT License ----------------
;*
;* MIT Lizenz:
;*
;* Hiermit wird unentgeltlich jeder Person, die eine Kopie der Software und der
;* zugehörigen Dokumentationen (die "Software") erhält, die Erlaubnis erteilt,
;* sie uneingeschränkt zu nutzen, inklusive und ohne Ausnahme mit dem Recht, sie
;* zu verwenden, zu kopieren, zu verändern, zusammenzufügen, zu veröffentlichen,
;* zu verbreiten, zu unterlizenzieren und/oder zu verkaufen, und Personen, denen
;* diese Software überlassen wird, diese Rechte zu verschaffen, unter den folgenden
;* Bedingungen:
;*
;* Der obige Urheberrechtsvermerk und dieser Erlaubnisvermerk sind in allen Kopien
;* oder Teilkopien der Software beizulegen.
;*
;* DIE SOFTWARE WIRD OHNE JEDE AUSDRÜCKLICHE ODER IMPLIZIERTE GARANTIE BEREITGESTELLT,
;* EINSCHLIEßLICH DER GARANTIE ZUR BENUTZUNG FÜR DEN VORGESEHENEN ODER EINEM BESTIMMTEN
;* ZWECK SOWIE JEGLICHER RECHTSVERLETZUNG, JEDOCH NICHT DARAUF BESCHRÄNKT. IN KEINEM
;* FALL SIND DIE AUTOREN ODER COPYRIGHTINHABER FÜR JEGLICHEN SCHADEN ODER SONSTIGE
;* ANSPRÜCHE HAFTBAR ZU MACHEN, OB INFOLGE DER ERFÜLLUNG EINES VERTRAGES, EINES DELIKTES
;* ODER ANDERS IM ZUSAMMENHANG MIT DER SOFTWARE ODER SONSTIGER VERWENDUNG DER SOFTWARE
;* ENTSTANDEN.
;*************************************************************************

DeclareModule AddressToGeo
   ;- --- [Module declaration / public elements] ------------------------------------------
   ;-
   
   ;*************************************************************************
   ;- Compiler directives
   ;*************************************************************************
   EnableExplicit
   
   ;*************************************************************************
   ;- Constants
   ;*************************************************************************
   #FORCE_NOTHING                        = 0
   #FORCE_GOOGLE                         = 1
   #FORCE_OSM                            = 2
   
   ;*************************************************************************
   ;- Structures
   ;*************************************************************************
   Structure geolocation
      sLatitude.s
      sLongitude.s
      sAddress.s
   EndStructure
   
   ;*************************************************************************
   ;- Public Procedures (dec)
   ;*************************************************************************
   Declare.i AddressToGeo(sAddress.s, *stOutGeolocation.geolocation, iForceService.i = 0)
   
EndDeclareModule

Module AddressToGeo
   ;-
   ;- --- [Module implementation / private elements] -----------------------------------------
   ;-
   
   ;*************************************************************************
   ;- Constants
   ;*************************************************************************
   #OSM_URL                        = "https://nominatim.openstreetmap.org/search?q=#ADR#&format=json"
   #GOOGLE_URL                     = "https://www.google.de/maps/place/#ADR#"
   #GOOGLE_ADR_STARTDELIMITER      = ~"\\\"https://www.google.de/maps/preview/place/"
   #GOOGLE_ADR_ENDDELIMITER        = "/@"
   #GOOGLE_GEO_STARTDELIMITER      = ~"\",null,[null,null,"
   #GOOGLE_GEO_ENDDELIMITER        = "]"
   
   ;*************************************************************************
   ;- Private Procedures (imp)
   ;*************************************************************************
   Procedure.s GetStringPart(sString.s, sStartDelimiter.s, sEndDelimiter.s, iPartLength=0)
      ; +-----------------------------------------------------------------
      ; |Description  : Extrahiert aus einem String ein Teilstück, welches durch sStartDelimiter und sEndDelimiter eingeschlossen ist
      ; |Arguments    : sString        : String aus dem der Teilstring extrahiert werden soll
      ; |             : sStartDelimiter: Linker Begrenzungsstring
      ; |             : sEndDelimiter  : Rechter Begrenzungsstring
      ; |             : iPartLength    : Wenn > 0, dann wird sEndDelimiter ignoriert und ein Teilstring mit der Länge iPartLength zurückgegeben
      ; |Results      : Ermittelter Teilstring bzw. "", wenn sStartDelimiter nicht vorhanden ist oder Fehler auftraten
      ; |Remarks      : Kommen die Delimiter mehrfach vor, dann wird nur das erste Auftreten gefunden!
      ; +-----------------------------------------------------------------
      Protected.i iPos1, iPos2
      
      iPos1 = FindString(sString, sStartDelimiter) + Len(sStartDelimiter)
      If iPos1 > 0
         If iPartLength = 0
            iPos2 = FindString(sString, sEndDelimiter, iPos1)
         Else
            iPos2 = iPos1 + iPartLength
         EndIf
         If iPos2 > iPos1
            ProcedureReturn Mid(sString, iPos1, iPos2 - iPos1)
         Else
            ProcedureReturn ""
         EndIf
      Else
         ProcedureReturn ""
      EndIf
   EndProcedure
   Procedure.s AskOSM(sAddress.s)
      ; +-----------------------------------------------------------------
      ; |Description  : Versucht per Open Streetmap die Längen- und Breitengrade zu sAddress zu ermitteln
      ; |Arguments    : sAddress: Adresse als Freitext (z.B. "Hauptstraße 5, 10827 Berlin"
      ; |Results      : "", wenn die Abfrage nicht möglich war oder Fehler aufgetreten sind,
      ; |               andernfalls ein String nach folgendem Format Latitude#Longitude#Adresse
      ; |Remarks      : Die zurückgegebene Adresse ist die von Open Streetmap korrigierte Adresse
      ; +-----------------------------------------------------------------
      Protected *Buffer
      Protected.s sURL, sResponse
      
      ; Geokodierungsanfrage an Open Streetmap senden
      sURL = ReplaceString(#OSM_URL, "#ADR#", URLEncoder(sAddress, #PB_UTF8))
      *Buffer = ReceiveHTTPMemory(sURL)
      
      If *Buffer
         sResponse = PeekS(*Buffer, MemorySize(*Buffer), #PB_UTF8|#PB_ByteLength)
         FreeMemory(*Buffer)
         
         ; JSON Daten extrahieren
         If ParseJSON(0, sResponse)
            If JSONArraySize(JSONValue(0)) > 0
               sResponse = GetJSONString(GetJSONMember(GetJSONElement(JSONValue(0), 0), "lat")) + "#"
               sResponse + GetJSONString(GetJSONMember(GetJSONElement(JSONValue(0), 0), "lon")) + "#"
               sResponse + GetJSONString(GetJSONMember(GetJSONElement(JSONValue(0), 0), "display_name"))
               FreeJSON(0)
               ProcedureReturn sResponse
            EndIf
            FreeJSON(0)
         EndIf
      EndIf
      
      ProcedureReturn ""
   EndProcedure
   Procedure.s AskGoogle(sAddress.s)
      ; +-----------------------------------------------------------------
      ; |Description  : Versucht per Google Maps die Längen- und Breitengrade zu sAddress zu ermitteln
      ; |Arguments    : sAddress: Adresse als Freitext (z.B. "Hauptstraße 5, 10827 Berlin"
      ; |Results      : "", wenn die Abfrage nicht möglich war oder Fehler aufgetreten sind,
      ; |               andernfalls ein String nach folgendem Format Latitude#Longitude#Adresse
      ; |Remarks      : Die zurückgegebene Adresse ist die von Google korrigierte Adresse
      ; +-----------------------------------------------------------------
      Protected *Buffer
      Protected.s sURL, sResponse, sGoogleAddress
      
      ; Geokodierungsanfrage an Google senden
      sURL = ReplaceString(#GOOGLE_URL, "#ADR#", URLEncoder(sAddress, #PB_UTF8))
      *Buffer = ReceiveHTTPMemory(sURL)
      
      If *Buffer
         sResponse = PeekS(*Buffer, MemorySize(*Buffer), #PB_UTF8|#PB_ByteLength)
         FreeMemory(*Buffer)
         If FindString(sResponse, #GOOGLE_ADR_STARTDELIMITER)
            sGoogleAddress = URLDecoder(GetStringPart(sResponse, #GOOGLE_ADR_STARTDELIMITER, #GOOGLE_ADR_ENDDELIMITER))
            If sGoogleAddress <> ""
               sResponse = GetStringPart(sResponse, sAddress + #GOOGLE_GEO_STARTDELIMITER, #GOOGLE_GEO_ENDDELIMITER)
               ProcedureReturn ReplaceString(sResponse, ",", "#") + "#" + sGoogleAddress
            EndIf
         EndIf   
      EndIf
      
      ProcedureReturn ""
   EndProcedure
   
   ;*************************************************************************
   ;- Public Procedures (imp)
   ;*************************************************************************
   Procedure.i AddressToGeo(sAddress.s, *stOutGeolocation.geolocation, iForceService.i = 0)
      ; +-----------------------------------------------------------------
      ; |Description  : Kodiert mittels Open Streetmap (OSM) bzw. Google Maps eine Adresse in Längen- und Breitengrad
      ; |Arguments    : sAddress         : Die zu kodierende Adresse als Freitext (z.B. "Hauptstraße 5, 10827 Berlin")
      ; |             : *stOutGeolocation: Struktur vom Typ geolocation, welche die Koordinaten und die von OSM bzw.
      ; |                                  Google Maps korrigierte Adresse erhält
      ; |             : iForceService    : Über die Konstanten #FORCE_OSM und #FORCE_GOOGLE kann die ausschließliche
      ; |                                  Kodierung über Open Streetmap bzw. Google Maps erzwungen werden. Wird der
      ; |                                  Parameter weggelassen oder #FORCE_NOTHING angegeben, dann wird zuerst
      ; |                                  versucht über OSM zu kodieren und im Fehelrfall dann über Google Maps.
      ; |Results      : 1, wenn die Abfrage erfolgreich war, 0 bei Fehlern
      ; |Remarks      : Die zurückgegebene Adresse ist die von OSM bzw. Google korrigierte Adresse
      ; |               Bitte beachten, dass der Aufbau der Adresse bei beiden unterschiedlich ist!
      ; +-----------------------------------------------------------------
      Protected.s sLat, sLng, sGeoString
      
      Select iForceService
         Case #FORCE_OSM
            ; Geokodierungsanfrage nur an Open Streetmap senden
            sGeoString = AskOSM(sAddress.s)
         Case #FORCE_GOOGLE
            ; Geokodierungsanfrage nur an Google Maps senden
            sGeoString = AskGoogle(sAddress.s)
         Default
            ; Geokodierungsanfrage an Open Streetmap bzw. bei Fehlern an Google Maps senden
            sGeoString = AskOSM(sAddress.s)
            If sGeoString = ""
               sGeoString = AskGoogle(sAddress.s)
            EndIf
      EndSelect
      
      If sGeoString <> ""
         sLat = StringField(sGeoString, 1, "#")
         sLng = StringField(sGeoString, 2, "#")
         sAddress = StringField(sGeoString, 3, "#")
         
         If sLat <> "0.0" And sLng <> "0.0"
            *stOutGeolocation\sLatitude = sLat
            *stOutGeolocation\sLongitude = sLng
            *stOutGeolocation\sAddress = sAddress
            ProcedureReturn 1
         EndIf
      EndIf
      
      ProcedureReturn 0
   EndProcedure
EndModule

;-------------------------------------------------------------------------------
;- Main
CompilerIf #PB_Compiler_IsMainFile
   EnableExplicit
   
   Procedure Main()
      UseModule AddressToGeo
      Protected stGeoLoc.geolocation
      Protected sAddress.s, iForceService
      
      InitNetwork()
      
      iForceService = #FORCE_NOTHING
      ;iForceService = #FORCE_GOOGLE
      ;iForceService = #FORCE_OSM
      sAddress = "Hauptstrasse 4, 10827 Berlin Deutschland"
      ;sAddress = "Turmstrasse 11, 4020 Linz, Österreich"
      ;sAddress = "505 Foothill Blvd, Claremont, CA 91711, USA"
      If AddressToGeo(sAddress, stGeoLoc, iForceService)
         Debug stGeoLoc\sAddress + ": " + stGeoLoc\sLatitude + ", " + stGeoLoc\sLongitude
      Else
         Debug "Geocoding failed!"
      EndIf
      
      UnuseModule AddressToGeo
   EndProcedure
   
   Main()
CompilerEndIf
