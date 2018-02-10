;   Description: Hyphenation - Module (German)
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?p=329857#p329857
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 Kurzer
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

;*************************************************************************
;*
;* Silbentrennung
;*
;*************************************************************************
;*
;* Programname       : Silbentrennung
;* Filename          : mod_Silbentrennung.pbi
;* Filetype          : Module [App, Main, Includefile, Module, Datafile]
;* Programming lang. : Purebasic 5.20+
;* String-Format     : All [Ascii, Unicode]
;* Platform          : All [Windows, Mac, Linux]
;* Processor         : All [x86, x64]
;* Version           : 1.03
;* Date              : 04.05.2015
;* Autor             : Kurzer
;* -----------------------------------------------------------------------
;* BESCHREIBUNG:
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
;* Sonderfälle:
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
;* Wortendungen:
;* Am Ende des Moduls befindet sich eine Datasektion, in der u.a. Wortendungen hinterlegt werden können,
;* die nicht getrennt werden dürfen.
;*
;* Beispiel einer nicht zu trennenden Wortendung:
;*
;*   Ein|stel|lun|gen  <- "gen" würde ohne die Wortendungs-Regel in "ge|n" getrennt werden
;*
;* Die Wortendungsdaten sehen dazu so aus:
;*   Data.s "gen"
;*
;* -----------------------------------------------------------------------
;* Historie:
;* 1.03 - 04.05.15:
;*        add Trennung an Doppelkonsonanten und Mehrfachvokalen zugefügt
;* 1.02 - 04.05.15:
;*        add Wortendungsbehandlung zugefügt
;* 1.01 - 04.05.15:
;*        add Sonderfallbehandlung zugefügt
;*        opt Optimierungen bei Vokal- und Konsonantensuche
;*        opt Kommentare überarbeitet
;* 1.00 - 03.05.15:
;*        rel Erste Version
;*
;*************************************************************************

;*************************************************************************
;* Module-Deklaration
;*************************************************************************

DeclareModule Silbentrennung
	
	Declare.s Silbentrennung(sWort.s, sTrenner.s)
	
EndDeclareModule

;*************************************************************************
;* Module-Implementation
;*************************************************************************

Module Silbentrennung
	EnableExplicit
	
	Declare.s Vorsilbe(sWort.s)
	Declare.s ErsteSilbe(sWort.s)
	Declare.s Sonderfall(sWort.s)
	Declare.i PositionZweiterVokal(sWort.s)
	Declare.i PositionVorherigerKonsonant(sWort.s, iPosition.i)
	Declare.i DoppelKonsonant(sWort.s)
	Declare.i Wortendung(sWort.s)
	
	; Achtung: Alles klein geschrieben
	Global.s sVorsilben3 = "auf aus dau emp ent ein erd geo nau ini rös sau sym syn sys uhr ver vor"
	Global.s sVorsilben2 = "ab al an än ak be em en er ge hy in un um ur zu"
	Global.s sVokale2= "aa au äu ee ei eu ia ie ii io ou ua uu"
	Global.s sVokale1= "ä ü ö a e i o u"
	Global.s sKonsonanten4 = "schl schr"
	Global.s sKonsonanten3 = "sch spr"
	Global.s sKonsonanten2= "bl br ch ck fl gl pr sp st tr th"
	Global.s sKonsonanten1= "b c d f g h j k l m n p q r s t v w x y z"
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
		Protected.s sSilbe, sSilbenkette
		Protected.i iSilbenlaenge
		
		sWort = Trim(sWort, " ")
		
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
		Restore Sonderfaelle
		
		Repeat 
			Read.s sSonderfall
			Read.i iSilbenlaenge
			iPosition = FindString(Left(sLCWort, Len(sSonderfall)), sSonderfall)
			If iPosition > 0
				ProcedureReturn Left(sWort, iPosition + iSilbenlaenge - 1)
			EndIf
		Until sSonderfall = "*"
		
		; Wenn kein Sonderfall gefunden wurde, -1
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
		Protected.s sDoppelKonsonant
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
		; Sonderfälle der Silbenterennung. Alles klein schreiben.
		Sonderfaelle:
		Data.s "nungs"                  ; Tren-nungs-pro-blem
		Data.i 5
		Data.s "tion"                     ; In-stal-la-ti-ons-ein-stel-lun-gen
		Data.i 2
		Data.s "ons"                     ; In-stal-la-ti-ons-ein-stel-lun-gen
		Data.i 3
		Data.s "lungs"                  ; Ent-wick-lungs-um-ge-bung
		Data.i 5
		Data.s "tia"                     ; Ini-ti-a-li-sie-rung
		Data.i 2
		Data.s "alis"                     ; Ini-ti-a-li-sie-rung
		Data.i 1
		Data.s "tua"                     ; Ak-tu-a-li-sie-rung
		Data.i 2
		Data.s "brief"                  ; Brief-um-schlag
		Data.i 5
		Data.s "gui"                     ; Lin-gu-is-tik
		Data.i 2
		Data.s "isti"                     ; Lin-gu-is-tik
		Data.i 2
		Data.s "gens"                     ; Oran-gen-saft
		Data.i 3
		Data.s "genf"                     ; Grund-la-gen-for-schung
		Data.i 3
		Data.s "dels"                     ; Han-dels-platz
		Data.i 4
		Data.s "azi"                     ; Hy-a-zin-the
		Data.i 1
		Data.s "dea"                     ; Mel-de-amt
		Data.i 2
		Data.s "frei"                     ; Be-frei-ungs-schlag
		Data.i 4
		Data.s "ungs"                     ; Be-frei-ungs-schlag
		Data.i 4
		Data.s "bent"                     ; Sil-ben-tren-nung
		Data.i 3
		Data.s "bers"                     ; Zau-ber-schloss
		Data.i 3
		Data.s "geb"                     ; Er-geb-nis
		Data.i 3
		Data.s "*"                        ; Listenende
		Data.i 0
		
		; Wortendungen die nicht getrennt werden dürfen. Alles klein schreiben.
		Wortendungen:
		Data.s "gen"                     ; Ein-stel-lun-ge|n
		Data.s "ung"										 ; An-schau-ung
		Data.s "geld"										 ; Be-treu-ungs-geld
		Data.s "*"											 ; Listenende
		
	EndDataSection
EndModule

; IncludeFile "mod_Silbentrennung.pbi"

CompilerIf #PB_Compiler_IsMainFile = 1
	
	Debug Silbentrennung::Silbentrennung("Auskommen", "|")
	Debug Silbentrennung::Silbentrennung("Überschallflugzeug", "|")
	Debug Silbentrennung::Silbentrennung("Erdbeersaft", "|")
	Debug Silbentrennung::Silbentrennung("Vorschule", "|")
	Debug Silbentrennung::Silbentrennung("Knäckebrottestzentrum", "|")
	Debug Silbentrennung::Silbentrennung("Ösenflanschgerät", "|")
	Debug Silbentrennung::Silbentrennung("Desktoplautsprecherset", "|")
	Debug Silbentrennung::Silbentrennung("Vielfachmessgerät", "|")
	Debug Silbentrennung::Silbentrennung("Zauberschloss", "|")
	Debug Silbentrennung::Silbentrennung("Schuhgeschäft", "|")
	Debug Silbentrennung::Silbentrennung("verschleppt", "|")
	Debug Silbentrennung::Silbentrennung("verschleppung", "|")
	Debug Silbentrennung::Silbentrennung("bitte", "|")
	Debug Silbentrennung::Silbentrennung("verschenkt", "|")
	Debug Silbentrennung::Silbentrennung("verschenken", "|")
	Debug Silbentrennung::Silbentrennung("Trennungsproblem", "|")
	Debug Silbentrennung::Silbentrennung("Jungspunt", "|")
	Debug Silbentrennung::Silbentrennung("Mundspülungsbecher", "|")
	Debug Silbentrennung::Silbentrennung("Mundwasser", "|")
	Debug Silbentrennung::Silbentrennung("wunderhaftes", "|")
	Debug Silbentrennung::Silbentrennung("Installationseinstellungen", "|")
	Debug Silbentrennung::Silbentrennung("Silbentrennung", "|")
	Debug Silbentrennung::Silbentrennung("Entwicklungsumgebung", "|")
	Debug Silbentrennung::Silbentrennung("Initialisierung", "|")
	Debug Silbentrennung::Silbentrennung("Aktualisierung", "|")
	Debug Silbentrennung::Silbentrennung("Trinkflasche", "|")
	Debug Silbentrennung::Silbentrennung("Uhrzeit", "|")
	Debug Silbentrennung::Silbentrennung("Änderung", "|")
	Debug Silbentrennung::Silbentrennung("empfangen", "|")
	Debug Silbentrennung::Silbentrennung("Briefumschlag", "|")
	Debug Silbentrennung::Silbentrennung("Erkennung", "|")
	Debug Silbentrennung::Silbentrennung("Aufwand", "|")
	Debug Silbentrennung::Silbentrennung("synchron", "|")
	Debug Silbentrennung::Silbentrennung("Linguistik", "|")
	Debug Silbentrennung::Silbentrennung("System", "|")
	Debug Silbentrennung::Silbentrennung("Urkunde", "|")
	
CompilerEndIf
