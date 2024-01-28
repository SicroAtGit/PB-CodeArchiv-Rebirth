;   Description: Hyphenation - Module (German)
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: https://www.purebasic.fr/german/viewtopic.php?f=8&t=28885
; -----------------------------------------------------------------------------

;*************************************************************************
;* Silbentrennung (c) Kurzer
;*************************************************************************
;*
;* Modulname         : Silbentrennung
;* Filename          : mod_Silbentrennung.pbi
;* Filetype          : Module [MainApp, Formular, Include, Module, Data]
;* Programming lang. : Purebasic 5.20+
;* String-Format     : All [Ascii, Unicode, All]
;* Platform          : All [Windows, Mac, Linux, All]
;* Processor         : All [x86, x64, All]
;* Compileroptions   : -
;* Version           : 1.05
;* Date              : 03.06.2019
;* Author             : Kurzer
;* Dependencies      : -
;* -----------------------------------------------------------------------
;* Description:
;*
;* Silbentrennung(sWort.s, sTrenner.s)
;* Das deutsche Wort in Parameter "sWort" wird in seine Silben zerlegt
;* Zurückgegeben wird ein aufbereiteter String, bei dem die Silben durch das Zeichen in Parameter "sTrenner" getrennt sind.
;*
;* Beispiel:
;*   Silbentrennung("Unverwüstlich", "|")
;*   Gibt zurück: "Un|ver|wüst|lich"
;*
;* Anmerkung:
;* Da eine algorithmische Silbentrennung ohne Nutzung einer Wörtbuchdatenbank niemals absolut fehlerfreie Ergebnisse liefern
;* kann, sind die Ergebnisse dieser Prozedur ggf. nicht immer völlig korrekt.
;*
;* -----------------------------------------------------------------------
;* ALGORITHMUS:
;*
;* Ein Wort besteht ggf. aus einer Vorsilbe und einer oder mehrerer nachfolgender Silben.
;*
;* Definition einer Vorsilbe:
;* Vorsilben sind reguläre Silben (s.u.), deren Beginn sich durch den Wortanfang definieren. Eine Silbe, die einer Vorsilbe
;* folgt, kann ausnahmsweise mit einem Vokal beginnen. Bei allen anderen Silben ist dies nicht so, denn sie beginnen immer
;* mit einem Konsonanten.
;*
;* Beispiele: Ge-spräch, ver-ein-zelt, ab-schrei-ben
;* Programmtechnisch sind die Vorsilben hartkodiert als Strings hinterlegt: vor, ver, ge, an, un, ...
;*
;* Definition einer Silbe:
;* Jeder Vokal (a, e, i, o, u) ist Kern einer Silbe. Dabei zählen die Diphtonge (eu, au, ei) und die Umlaute (ä, ü, ö) ebenfalls als Vokal.
;* Ausgehend vom Kern (Vokal) einer Silbe reicht diese nach rechts bis zum letzten Konsonanten vor dem nächsten Vokal, wobei der letzte
;* Konsonant bereits zur nächsten Silbe gehört. Der Beginn einer Silbe definiert sich durch das Ende der vorherigen Silbe bzw. der Vorsilbe.
;* 
;* Beispiel: ver-lau-fen
;*            |   |  ||
;*            |   |  |nächste Silbe
;*            |   |  |
;*            |   |  letzter Konsonant
;*            |   |  
;*            |   Silbe
;*            Vorsilbe
;*
;* Besonderheiten:
;* Konsonantengruppen, die einen einzigen Laut bezeichnen, werden wie ein einzelner Konsonant behandelt: ch, sch, ck.
;* Beispiel: ver-su-chung
;*            |   | | |
;*            |   | | nächste Silbe
;*            |   | |
;*            |   | letzter Konsonant (ch)
;*            |   |  
;*            |   Silbe
;*            Vorsilbe
;*
;* Besteht der erste Buchstabe des Wortes bereits aus einem Vokal, dann ist dieser Vokal nicht Kern der Silbe.
;* Beispiel: Über-schall
;*           | |     |
;*           | |     nächste Silbe
;*           | Silbe
;*           Nicht Kern der Silbe!
;*
;* Da es Ausnahmen gibt, sollten diese über die hartkodierten Vorsilben abgedeckt werden.
;* Beispiel: Erd-beer-saft
;*           |    |    |
;*           |    |    nächste Silbe
;*           |    nächste Silbe
;*           Silbe
;*
;* Doppelkonsonanten:
;* Befindet sich in einer Silbe ein Doppelkonsonanten, dann word dort aufgetrennt (klap-pt, Flot-te)
;* Ausnahme: Doppelkonsonanten am Ende eines Wortes werden nicht getrennt (z.B. Schloss)
;*
;* Mehrfachvokale:
;* Befindet sich in einem Wortteil ein Mehfachvokal, dann word dort aufgetrennt (An-schau-ung)
;* Hier liegen die Vokale "au" und "u" direkt beieinander.
;*
;* Sonderfälle für Silben:
;* Am Ende des Moduls befindet sich eine Datasektion, in der u.a. Sonderfälle hinterlegt werden können, die durch
;* die algorithmische Bearbeitung nicht korrekt getrennt werden. Hierzu ist jeweils der Silbenteil hinterlegt,
;* der nicht korrekt getrennt wird sowie die Position der Trennstelle innerhalb des Silbenteils.
;*
;* Beispiel eines Sonderfalls:
;*
;* Die algorithmische Trennung liegt falsch:
;*   Tren|nung|spro|blem
;*
;* Die Sonderfalldaten sehen dazu so aus:
;*   Data.s "nungsp"
;*   Data.i 5       ; Bedeutet, dass die Trennung nach dem 5. Buchstaben erfolgt
;*
;* Die Sonderfalltrennung trennt dann richtig:
;*   Tren|nungs|pro|blem
;*
;* Sonderfälle für ganze Wörter:
;* Weiterhin gibt es eine Datasektion für die Sonderbehandlung ganzer Wörter, die nicht algorithmisch getrennt
;* werden können. Hierzu ist jeweils das gesamte Wort sowie die getrennte Schreibweise des Worts hinterlegt.
;*
;* Beispiel eines Wort-Sonderfalls:
;*
;* Die algorithmische Trennung liegt hier falsch bzw. trennt die vermeindlichen Worte "Silbe" und "reisen":
;*   Sil|be|rei|sen
;*
;* Die Sonderfalldaten sehen dazu so aus:
;*   Data.s "silbereisen", "sil|ber|ei|sen"
;*
;* Wortendungen:
;* Eine weitere Datasektion enthält Wortendungen die nicht getrennt werden dürfen.
;*
;* Beispiel einer nicht zu trennenden Wortendung:
;*
;*   Ein|stel|lun|gen  <- "gen" würde ohne die Wortendungs-Regel in "ge|n" getrennt werden
;*
;* Die Wortendungsdaten sehen dazu so aus:
;*   Data.s "gen"
;*
;* -----------------------------------------------------------------------
;* Changelog:
;* 1.05 - rel 03.06.2019:
;*        fix - Sicros Anpassungen für Prozedure AskDuden() eingebaut (www.duden.de hat seine Webseite verändert).
;*              Vielen Dank Sicro.
;* 1.04 - rel 14.04.2019:
;*        fix - Nicht benutzte Variable entfernt und Trennungsgenauigkeit verbessert (Datenbasis erweitert)
;*        add - SonderfallGanzesWort() hinzugefügt für nicht algorithmisch trennbare Wortkombinationen
;*              z.B. für Sil|ber|ei|sen statt falsch Sil|be|rei|sen (Silbe & Reisen)
;*        add - Im Beispielcode des Modules wurden Funktionen zugefügt, die die Korrektheit der Trennung online
;*              bei www.duden.de überprüfen.
;* 1.03 - rel 04.05.2015:
;*        add - Trennung an Doppelkonsonanten und Mehrfachvokalen zugefügt
;* 1.02 - rel 04.05.2015:
;*        add - Wortendungsbehandlung zugefügt
;* 1.01 - rel 04.05.2015:
;*        add - Sonderfallbehandlung zugefügt
;*        opt - Optimierungen bei Vokal- und Konsonantensuche
;*        opt - Kommentare überarbeitet
;* 1.00 - rel 03.05.2015:
;*        add - Erste Version
;* -----------------------------------------------------------------------
;* English-Forum     :
;* French-Forum      :
;* German-Forum      : http://www.purebasic.fr/german/viewtopic.php?p=329857#p329857
;* -----------------------------------------------------------------------
;* License: MIT License
;*
;* Copyright (c) 2015/19 Kurzer
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

DeclareModule Silbentrennung
   ;- --- [Module declaration / public elements] ------------------------------------------
   ;-
   
   Declare.s Silbentrennung(sWort.s, sTrenner.s)
   
EndDeclareModule

Module Silbentrennung
   ;-
   ;- --- [Module implementation / private elements] -----------------------------------------
   ;-
   
   EnableExplicit
   
   Declare.s Vorsilbe(sWort.s)
   Declare.s ErsteSilbe(sWort.s)
   Declare.s Sonderfall(sWort.s)
   Declare.s SonderfallGanzesWort(sWort.s, sTrenner.s)
   Declare.i PositionZweiterVokal(sWort.s)
   Declare.i PositionVorherigerKonsonant(sWort.s, iPosition.i)
   Declare.i DoppelKonsonant(sWort.s)
   Declare.i Wortendung(sWort.s)
   
   ;*************************************************************************
   ;* Global Variables
   ;*************************************************************************
   
   ; Achtung: Alles klein geschrieben
   Global.s sVorsilben3        = "all auf aus ägä ähn dau emp ent ein erd geo ini nau rös sau sym syn sys uhr ver vor"
   Global.s sVorsilben2        = "ab al an än äl ak be em en er ei ge hy in un um ur zu"
   Global.s sVokale2           = "aa au äu ee ei eu ia ie ii io ou ua uu"
   Global.s sVokale1           = "ä ü ö a e i o u"
   Global.s sKonsonanten4      = "schl schr"
   Global.s sKonsonanten3      = "sch spr"
   Global.s sKonsonanten2      = "bl br ch ck fl gl ph pr sp st tr"
   Global.s sKonsonanten1      = "b c d f g h j k l m n p q r s t v w x y z"
   Global.s sDoppelKonsonanten = "bb cc dd ff gg hh jj kk ll mm nn pp qq rr ss tt vv ww xx yy zz"
   
   ;*************************************************************************
   ;* Public Procedures
   ;*************************************************************************
   
   Procedure.s Silbentrennung(sWort.s, sTrenner.s)
      ; +-----------------------------------------------------------------
      ; |Description  : Teilt sWort in seine Silben auf, geteilt durch sTrenner
      ; |Arguments    : sWort.s : Das in Silben aufzutrennende Wort
      ; |             : sWort.s : Trennzeichen zwischen den Silben
      ; |Results      : Result.s: String bestehend aus Silben und Trennzeichen
      ; |Remarks      : Aus "unverschämt" wird "un|ver|schämt", wenn sTrenner = "|"
      ; +-----------------------------------------------------------------
      Protected.s sSilbe, sSilbenkette, sSonderfall
      Protected.i iSilbenlaenge
      
      sWort = Trim(sWort, " ")
      
      ; Prüfen, ob das gesamte Wort ein Sonderfall ist
      sSonderfall = SonderfallGanzesWort(sWort, sTrenner)
      If sSonderfall <> ""
         ProcedureReturn sSonderfall
      EndIf
      
      Repeat
         sSilbe = ErsteSilbe(sWort)
         If sSilbe <> ""
            sSilbenkette + sTrenner + sSilbe
            iSilbenlaenge = Len(sSilbe)
            sWort = Mid(sWort, iSilbenlaenge + 1, Len(sWort) - iSilbenlaenge)
         Else
            sSilbenkette + sWort
         EndIf
      Until sSilbe = ""
      
      If Left(sSilbenkette, 1) = sTrenner
         sSilbenkette = Right(sSilbenkette, Len(sSilbenkette) - 1)
      EndIf
      ProcedureReturn sSilbenkette
   EndProcedure
   
   ;*************************************************************************
   ;* Privat Procedures
   ;*************************************************************************
   
   Procedure.s ErsteSilbe(sWort.s)
      ; +-----------------------------------------------------------------
      ; |Description  : Ermittelt die erste Silbe in sWort
      ; |Arguments    : sWort.s : zu prüfendes Wort
      ; |Results      : Result.s: Die ermittelte Silbe
      ; |Remarks      : Wurde keine Silbe ermittelt, wird "" zurückgegeben
      ; +-----------------------------------------------------------------
      Protected.s sVorsilbe, sSonderfall
      Protected.i iPosition, iPositionDK
      
      ; Prüfen, ob es sich um eine nicht zu trennende Wortendung handelt
      If Wortendung(sWort.s) = #True
         ProcedureReturn sWort
      EndIf 
      
      ; Vorsilbe ermitteln, wenn vorhanden
      sVorsilbe = Vorsilbe(sWort)
      If sVorsilbe <> "" And Sonderfall(sWort) = ""
         ProcedureReturn sVorsilbe
      EndIf
      
      ; Silbe ermitteln, wenn es keine Vorsilbe gab
      iPosition = PositionZweiterVokal(sWort)
      
      ; Erst einen evtl. Sonderfall ermitteln
      If iPosition > 0
         sSonderfall = Sonderfall(Left(sWort, iPosition))
      Else
         sSonderfall = Sonderfall(sWort)
      EndIf
      If sSonderfall <> ""
         ProcedureReturn sSonderfall
      EndIf
      
      ; Wenn kein Sonderfall vorhanden ist, dann die Silbe regulär ermitteln
      If iPosition > 0
         iPosition = PositionVorherigerKonsonant(sWort, iPosition - 1)
         If iPosition > 0
            ProcedureReturn Left(sWort, iPosition - 1)
         EndIf
      EndIf
      
      ; Wenn die Silbe bis zum Wortende reicht, dann prüfen wir auf einen
      ; Doppelkonsonanten. Kommt einer vor, dann trennen wir dort
      iPositionDK = DoppelKonsonant(sWort)
      If iPositionDK > 0
         ProcedureReturn Left(sWort, iPositionDK)
      EndIf
      
      ProcedureReturn sWort
   EndProcedure
   Procedure.s Vorsilbe(sWort.s)
      ; +-----------------------------------------------------------------
      ; |Description  : Ermittelt die Vorsilbe in sWort
      ; |Arguments    : sWort.s : zu prüfendes Wort
      ; |Results      : Result.s: Die ermittelte Vorsilbe
      ; |Remarks      : Ist keine Vorsilbe enthalten, wird "" zurückgegeben
      ; +-----------------------------------------------------------------
      Protected.s sLCWort
      
      sWort = Left(sWort, 3)
      sLCWort = LCase(sWort)
      If FindString(sVorsilben3, sLCWort)
         ProcedureReturn sWort
      EndIf
      
      sWort = Left(sWort, 2)
      sLCWort = LCase(sWort)
      If FindString(sVorsilben2, sLCWort)
         ProcedureReturn sWort
      EndIf
      
      ProcedureReturn ""
   EndProcedure
   Procedure.s Sonderfall(sWort.s)
      ; +-----------------------------------------------------------------
      ; |Description  : Prüft, ob es für das Wort in "sWort" einen Sonderfall gibt
      ; |Arguments    : sWort.s     : Zu prüfendes Wort
      ; |Results      : Result.s    : Die korrekte Silbe dieses Sonderfalls
      ; |Remarks      : Wird kein Sonderfall gefunden, wird "" zurückgegeben
      ; +-----------------------------------------------------------------
      Protected.s sLCWort, sSonderfall
      Protected.i iSilbenlaenge, iPosition
      
      sLCWort = LCase(sWort)
      Restore SonderfaelleSilben
      
      Repeat 
         Read.s sSonderfall
         Read.i iSilbenlaenge
         
         iPosition = FindString(Left(sLCWort, Len(sSonderfall)), sSonderfall)
         If iPosition > 0
            ProcedureReturn Left(sWort, iPosition + iSilbenlaenge - 1)
         EndIf
      Until sSonderfall = "*"
      
      ; Wenn kein Sonderfall gefunden wurde
      ProcedureReturn ""
   EndProcedure      
   Procedure.s SonderfallGanzesWort(sWort.s, sTrenner.s)
      ; +-----------------------------------------------------------------
      ; |Description  : Prüft, ob es für das Wort in "sWort" einen Sonderfall gibt
      ; |Arguments    : sWort.s     : Zu prüfendes Wort
      ; |             : sTrenner.s  : Trennungsmarker
      ; |Results      : Result.s    : Die komplette Trennungsschreibweise des Wortes. Getrennt mit sTrenner.
      ; |Remarks      : Wird kein Sonderfall gefunden, wird "" zurückgegeben
      ; +-----------------------------------------------------------------
      Protected.s sLCWort, sSonderfall, sErsetzungswort
      
      sLCWort = LCase(sWort)
      Restore SonderfaelleWorte
      
      Repeat 
         Read.s sSonderfall
         Read.s sErsetzungswort
         
         If sLCWort = sSonderfall
            sErsetzungswort = ReplaceString(sErsetzungswort, "|", sTrenner)
            ProcedureReturn sErsetzungswort
         EndIf
      Until sSonderfall = "*"
      
      ; Wenn kein Sonderfall gefunden wurde
      ProcedureReturn ""
   EndProcedure      
   Procedure.i PositionZweiterVokal(sWort.s)
      ; +-----------------------------------------------------------------
      ; |Description  : Ermittelt die Position des zweiten Vokals in sWort
      ; |Arguments    : sWort.s     : Zu prüfendes Wort
      ; |Results      : Result.i    : Zeichenposition des zweitens Vokals in Anzahl Zeichen
      ; |Remarks      : Wird kein zweiter Vokal gefunden, dann wird -1 zurückgegeben
      ; |               Bei Vokalen mit 2 Buchstaben wird die Position des ersten Buchstabens zurückgegeben
      ; |               
      ; |               Beispiel: sWort = "Schuhgeschäft"
      ; |               Die Prozedur wird 7 zurückgeben, das "e" von "geschäft". Der erste Vokal ist das "u" in "Schuh"
      ; +-----------------------------------------------------------------
      Protected.s sVokal
      Protected.i i, j, iOffset, iPosition, iAltePosition
      
      sWort = LCase(sWort)
      iPosition = 1
      iOffset = 0
      
      ; Wenn das Wort bereits mit einem Vokal beginnt, muss dieser ignoriert werden
      If FindString(sVokale2, Left(sWort, 2))
         iPosition = 3
      ElseIf FindString(sVokale1, Left(sWort, 1))
         iPosition = 2
      EndIf
      
      For j = 1 To 2
         For i = iPosition + iOffset To Len(sWort)
            ; 2er Vokal suchen
            sVokal = Mid(sWort, i, 2)
            If FindString(sVokale2, sVokal)
               iPosition = i
               iOffset = 2
               If j = 1 : iAltePosition = iPosition: EndIf
               Break
            EndIf
            
            ; 1er Vokal suchen
            sVokal = Mid(sWort, i, 1)
            If FindString(sVokale1, sVokal)
               iPosition = i
               iOffset = 1
               If j = 1 : iAltePosition = iPosition: EndIf
               Break
            EndIf
         Next i
      Next j
      
      If iAltePosition = iPosition
         ProcedureReturn -1
      Else
         ProcedureReturn iPosition
      EndIf
   EndProcedure      
   Procedure.i PositionVorherigerKonsonant(sWort.s, iPosition.i)
      ; +-----------------------------------------------------------------
      ; |Description  : Ermittelt die Position des direkten vorherigen Konsonanten in sWort an Stelle iPosition
      ; |Arguments    : sWort.s     : Zu prüfendes Wort
      ; |             : iStartpos.i : Startposition für die Rückwärtssuche in Anzahl Zeichen
      ; |Results      : Result.i    : Position des gefundenen Konsonanten in Anzahl Zeichen
      ; |Remarks      : Wird kein Konsonant gefunden, dann wird geprüft, ob sich am Ende des Wortes
      ; |               ein Vokal befindet. In dem Fall handelt es sich um einen Mehrfachvokal.
      ; |               An dieser Stelle wird dann getrennt. Es wird also die Position nach
      ; |               dem gefundenen Vokal zurückgegeben.
      ; |               
      ; |               Bei Konsonanten mit 4, 3 bzw. 2 Buchstaben wird die Position des ersten Buchstabens zurückgegeben
      ; |               
      ; |               Beispiel: sWort = "verschenkt", iPosition = 6
      ; |               Hier wird am Zeichen Nr. 6 (das "h" vom "sch") von links gehend nach einem Konsonsanten gesucht
      ; |               Da das "sch" als ein Konsonant gilt, wird die Prozedur die Position 4 zurückgeben, also das erste
      ; |               Zeichen des "sch".
      ; |               
      ; |               Beispiel: sWort = "verpennt", iPosition = 4
      ; |               Die Prozedur wird 4 zurückgeben, da vor dem Umlaut "e" weder ein 3er Konsonant noch ein 2er Konsonant
      ; |               steht, sondern das p als 1er-Konsonant.
      ; +-----------------------------------------------------------------
      Protected.s sWortMV
      
      ; Wenn die Satrtposition ungültig ist, -1
      If iPosition > Len(sWort)
         ProcedureReturn -1
      EndIf
      
      If iPosition < 4
         sWort = Space(4 - iPosition) + sWort
      EndIf
      
      ; 4er Konsonaten prüfen
      sWort = Mid(LCase(sWort), iPosition - 3, 4)
      sWortMV = Right(sWort, 2)
      
      If FindString(sKonsonanten4, sWort)
         ProcedureReturn iPosition - 3
      EndIf
      
      ; 3er Konsonaten prüfen
      sWort = Right(sWort, 3)
      If FindString(sKonsonanten3, sWort)
         ProcedureReturn iPosition - 2
      EndIf
      
      ; 2er Konsonaten prüfen
      sWort = Right(sWort, 2)
      If FindString(sKonsonanten2, sWort)
         ProcedureReturn iPosition - 1
      EndIf
      
      ; 1er Konsonaten prüfen
      sWort = Right(sWort, 1)
      If FindString(sKonsonanten1, sWort)
         ProcedureReturn iPosition
      EndIf
      
      ; Wenn kein Konsonant gefunden wurde, dann prüfen, ob ein Mehrfachvokal vorliegt
      If FindString(sVokale2, sWortMV)
         ProcedureReturn iPosition + 1
      EndIf
      sWortMV = Right(sWortMV, 1)
      If FindString(sVokale1, sWortMV)
         ProcedureReturn iPosition
      EndIf
      
      ProcedureReturn -1
   EndProcedure      
   Procedure.i DoppelKonsonant(sWort.s)
      ; +-----------------------------------------------------------------
      ; |Description  : Prüft, ob das Wort in "sWort" einen Doppelkonsonanten enthält
      ; |Arguments    : sWort.s  : Zu prüfendes Wort
      ; |Results      : Result.i : Position des gefundenen Doppelkonsonanten in Anzahl Zeichen
      ; |Remarks      : Es wird die Position des ersetn Zeichens des Doppelkonsonanten zurückgegeben
      ; |               Wird kein Doppelkonsonant gefunden, dann wird -1 zurückgegeben
      ; |               Doppelkonsonanten am Ende des wortes werden ignoriert, z.B. Schloss
      ; +-----------------------------------------------------------------
      Protected.i i, iPosition
      
      sWort = LCase(sWort)
      If Len(sWort) < 3 : sWort = "   " + sWort : EndIf
      
      For i = 1 To Len(sWort) - 2
         iPosition = FindString(sDoppelKonsonanten, Mid(sWort, i, 2))
         If iPosition > 0
            ProcedureReturn i
         EndIf
      Next i
      
      ProcedureReturn -1
   EndProcedure
   Procedure.i Wortendung(sWort.s)
      ; +-----------------------------------------------------------------
      ; |Description  : Prüft, ob das Wort in "sWort" eine Wortendung ist
      ; |Arguments    : sWort.s  : Zu prüfendes Wort
      ; |Results      : Result.i : #True, wenn ja / #False, wenn nein
      ; |Remarks      : 
      ; +-----------------------------------------------------------------
      Protected.s sLCWort, sWortendung
      
      sLCWort = LCase(sWort)
      Restore Wortendungen
      
      Repeat 
         Read.s sWortendung
         If sWort = sWortendung
            ProcedureReturn #True
         EndIf
      Until sWortendung = "*"
      
      ; Wenn es keine Wortendung ist, dann #False
      ProcedureReturn #False
   EndProcedure      
   
   DataSection
      ; Sonderfälle bei der Trennung von Silben. Alles klein schreiben.
      SonderfaelleSilben:
      Data.s "ängs"                                ; Ängs-ti-gen
      Data.i 4
      Data.s "äqui"                                ; Äqui-va-lent
      Data.i 4
      Data.s "alis"                                ; In-i-ti-a-li-sie-rung
      Data.i 1
      Data.s "azi"                                 ; Hy-a-zin-the
      Data.i 1
      
      Data.s "beer"                                ; Erd-beer-saft
      Data.i 4
      Data.s "bent"                                ; Sil-ben-tren-nung
      Data.i 3
      Data.s "berw"                                ; Le-ber-wurst
      Data.i 3
      Data.s "bers"                                ; Zau-ber-schloss
      Data.i 3
      Data.s "brief"                               ; Brief-um-schlag
      Data.i 5
      
      Data.s "dea"                                 ; Mel-de-amt
      Data.i 2
      Data.s "dels"                                ; Han-dels-platz
      Data.i 4
      
      Data.s "frei"                                ; Be-frei-ungs-schlag
      Data.i 4
      Data.s "fenste"                              ; Schau-fens-ter
      Data.i 4
      
      Data.s "geb"                                 ; Er-geb-nis
      Data.i 3
      Data.s "genf"                                ; Grund-la-gen-for-schung
      Data.i 3
      Data.s "gens"                                ; Oran-gen-saft
      Data.i 3
      Data.s "gui"                                 ; Lin-gu-is-tik
      Data.i 2
      
      Data.s "haupt"                               ; Haupt-ent-schei-dung
      Data.i 5
      
      Data.s "isbe"                                ; Ägä-is-be-reich
      Data.i 2
      Data.s "isti"                                ; Lin-gu-is-tik
      Data.i 2
      Data.s "iti"                                 ; In-i-ti-a-li-sie-rung
      Data.i 1
      
      Data.s "lungs"                               ; Ent-wick-lungs-um-ge-bung
      Data.i 5
      
      Data.s "nungs"                               ; Tren-nungs-pro-blem
      Data.i 5
      
      Data.s "ons"                                 ; In-stal-la-ti-ons-ein-stel-lun-gen
      Data.i 3
      
      Data.s "satz"                                ; Grund-satz-ent-schei-dung
      Data.i 4
      Data.s "sea"                                 ; Kä-se-auf-lauf
      Data.i 2
      
      Data.s "tia"                                 ; In-i-ti-a-li-sie-rung
      Data.i 2
      Data.s "tion"                                ; In-stal-la-ti-ons-ein-stel-lun-gen
      Data.i 2
      Data.s "tua"                                 ; Ak-tu-a-li-sie-rung
      Data.i 2
      
      Data.s "ungs"                                ; Be-frei-ungs-schlag
      Data.i 4
      Data.s "berei"                               ; Be-frei-ungs-schlag
      Data.i 2
      Data.s "*"                                   ; Listenende
      Data.i 0
      
      ; Sonderfälle ganze Wörter. "gesuchtesWort" , "Wort mit Trennungsmarker (|)". Alles klein schreiben.
      SonderfaelleWorte:
      Data.s "silbereisen", "sil|ber|ei|sen"
      Data.s "*","*"                             ; Listenende
      
      ; Wortendungen die nicht getrennt werden dürfen. Alles klein schreiben.
      Wortendungen:
      Data.s "ber"                                 ; Sil-ber
      Data.s "geld"                                ; Be-treu-ungs-geld
      Data.s "gen"                                 ; Ein-stel-lun-gen
      Data.s "on"                                  ; Funk-ti-on
      Data.s "reich"                               ; Be-reich
      Data.s "ung"                                 ; An-schau-ung
      Data.s "*"                                   ; Listenende
      
   EndDataSection
EndModule

CompilerIf #PB_Compiler_IsMainFile = 1
   
   Procedure.s GetStringPart(sString.s, sStartDelimiter.s, sEndDelimiter.s, iPartLength=0)
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
   Procedure.s AskDuden(sWord.s)
      Protected *Buffer
      Protected.s sUrl, sResponse
      
      sWord = ReplaceString(sWord, "ä", "ae")
      sWord = ReplaceString(sWord, "ö", "oe")
      sWord = ReplaceString(sWord, "ü", "ue")
      sWord = ReplaceString(sWord, "Ä", "Ae")
      sWord = ReplaceString(sWord, "Ö", "Oe")
      sWord = ReplaceString(sWord, "Ü", "Ue")
      sWord = ReplaceString(sWord, "ß", "sz")
      
      sURL = "http://www.duden.de/rechtschreibung/" + sWord
      
      ; Anfrage an duden.de senden
      *Buffer = ReceiveHTTPMemory(URLEncoder(sURL, #PB_UTF8))
      If *Buffer
         sResponse = PeekS(*Buffer, MemorySize(*Buffer), #PB_UTF8|#PB_ByteLength)
         FreeMemory(*Buffer)
         
         ; HTML-Umlaute nach UTF8 wandeln
         sResponse = ReplaceString(sResponse, "&Auml;", "Ä")
         sResponse = ReplaceString(sResponse, "&Ouml;", "Ö")
         sResponse = ReplaceString(sResponse, "&Uuml;", "Ü")
         sResponse = ReplaceString(sResponse, "&auml;", "ä")
         sResponse = ReplaceString(sResponse, "&ouml;", "ö")
         sResponse = ReplaceString(sResponse, "&uuml;", "ü")
         sResponse = ReplaceString(sResponse, "&szlig;", "ß")
         
         ; Status prüfen und die korrekte Trennungsschreibweise aus der duden.de webseite extrahieren und übergeben
         If FindString(sResponse, "Es ist leider ein Fehler aufgetreten") = 0
            If FindString(sResponse, "Von Duden empfohlene Trennung") > 0
               sResponse = GetStringPart(sResponse, ~"Von Duden empfohlene Trennung</dt>\n        <dd class=\"tuple__val\">", "</dd>")
            Else
               sResponse = GetStringPart(sResponse, ~"Worttrennung</dt>\n        <dd class=\"tuple__val\">", "</dd>")
            EndIf
            ProcedureReturn sResponse
         EndIf
      EndIf
      
      ProcedureReturn ""
   EndProcedure
   Procedure Check(sWord.s)
      Protected.s sDuden
      sDuden = AskDuden(sWord)
      sWord = Silbentrennung::Silbentrennung(sWord, "|")
      If sDuden = ""
         Debug sWord + Space(10) + "ist nicht im Duden vorhanden"
      ElseIf sWord <> sDuden
         Debug sWord + Space(10) + "muss lt. Duden heissen:   " + sDuden
      Else
         Debug sWord + Space(10) + "Korrekt!"
      EndIf
   EndProcedure
   
   Check("Kommentar")
   Check("Überschallflugzeug")
   Check("Erdbeersaft")
   Check("Vorschule")
   Check("Fußmarsch")
   Check("Knäckebrot")
   Check("Desktop")
   Check("Lautsprecher")
   Check("Vielfachmessgerät")
   Check("Zauberschloss")
   Check("Schuhgeschäft")
   Check("Verschleppung")
   Check("Bitte")
   Check("verschenken")
   Check("Trennung")
   Check("Jungspund")
   Check("Mundwasser")
   Check("Installation")
   Check("Einstellung")
   Check("Silbentrennung")
   Check("Entwicklung")
   Check("Initialisierung")
   Check("Aktualisierung")
   Check("Trinkflasche")
   Check("Uhrzeit")
   Check("Änderung")
   Check("empfangen")
   Check("Briefumschlag")
   Check("Erkennung")
   Check("Aufwand")
   Check("synchron")
   Check("Linguistik")
   Check("System")
   Check("Urkunde")
   Check("Mondphase")
   Check("Grundsatzentscheidung")
   Check("Bereich")
   Check("Silber")
   Check("Haupthaus")
   Check("Leberwurst")
   Check("Schaufenster")
   
CompilerEndIf
