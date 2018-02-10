;{ #INFORMATIONEN - START# ================================================================================================================================

;{ --> #INDEX# ============================================================================================================================================
; Title 			: MultiGraph
; PureBasic Version : 5.11
; UDF Version	 	: 1.0.0.0
; Compile Count		: 1655
; Date of creation 	: 18.05.2013 (DD.MM.YYYY)
; UDF-Language		: German
; Description 		: create a dynamic line graph
; Author			: SBond
; Dll(s) 			: ---
;} ========================================================================================================================================================



;{ --> #AUTHOR INFORMATION# ===============================================================================================================================
; Author	: SBond
; E-Mail	: sbond.softwareinfo@gmail.com
; Language	: German  (Deutsch)
; Country	: Germany (Deutschland)
; Webside	: ---
;} ========================================================================================================================================================



;{ --> #UPDATES# ==========================================================================================================================================
;
; 18.05.2013	-	1.0.0.0	- erste Veröffentlichung
;
;} ========================================================================================================================================================



;{ --> #HINTS AND INFORMATION# ============================================================================================================================
;
; Allgemeine Informationen über diese UDF (User Defined Function)
; ----------------------------------------------------------------------
;
; Dies ist meine erste UDF. Sie entspricht nicht ganz dem UDF coding standard, aber ich hoffe mal dass ihr mit der Dokumentation klar kommt.
; Mit dieser UDF könnt ihr einen oder mehrere unabhängige Liniendiagramme (bzw. Graphen) erzeugen.
;
; In der Grundeinstellung, können 10 Graphen mit jeweils 10 Kanälen genutzt werden. Wer mehr benötigt, kann dies einfach in den Variablen einstellen.
; Die Nummerierung der Graphen und der Kanäle beginnt bei 1 und nicht bei 0. Dies ist wichtig, da auf dem Index 0 die Einstellungen der Graphen gespeichert werden.
;
; Zu den Begriffen.....   Es könnte eventuell etwas verwirren, aber wenn hier von "Plotten" geschrieben wird, z.B. "die Werte in den Graphen plotten", so meine ich nicht
; dass die Werte in der GUI dargestellt werden. Die Werte werden in den Zeichenbereich geplottet. Erst wenn alle Punkte eingezeichnet sind oder die Funktion "_MG_Graph_updaten"
; genutzt wird, wird die Darstellung in der GUI aktualisiert.
;
;
;
;
;
; kurze Aufschlüsselung der Abkürzungen in den Variablen
; ----------------------------------------------------------------------
;
; MG_aGraph [ Graphnummer ][ Kanalnummer ][ Kanaleinstellungen ]         wobei in der Kanalnummer 0 die ganzen Einstellungen des Graphen hinterlegt sind
;
; #_MG_a_			-> MultiGraph allgemeine Einstellungen
; #_MG_k_			-> MultiGraph Kanal-Einstellungen
; #_MG_L_			-> MultiGraph Hilfslinien-Einstellungen
;
; i					-> integer
; f					-> float
; d					-> double
; a					-> array
; s oder $			-> string
; h					-> handle
;
;} ========================================================================================================================================================



;{ --> #CURRENT# ==========================================================================================================================================
;
; Function								Parameter
; ----------------------------------------------------------------------
; _MG_Graph_erstellen 					(iGraph.i, iX_Pos.i, iY_Pos.i, iBreite.i, iHoehe.i)
; _MG_Graph_optionen_position 			(iGraph.i, iX_Pos.i = 10, iY_Pos.i = 10, iBreite.i = 400, iHoehe.i = 250)
; _MG_Graph_optionen_allgemein 			(iGraph.i, iAufloesung.i = -1, iY_min.i = -100, iY_max.i = 100, iHintergrundfarbe_RGB.i = -1)
; _MG_Graph_optionen_Rahmen 			(iGraph.i, iAnzeigen.i = #True, iRahmenfarbe_RGB.i = -1, iRahmenbreite.i = 1)
; _MG_Graph_optionen_Hauptgitterlinien 	(iGraph.i, iHauptgitter_aktiviert.i = #True, iHauptgitter_abstand_X.i = 50, iHauptgitter_abstand_Y.i = 50, iHauptgitter_breite.i = 1, iHauptgitter_farbe_RGBA.i = -1)
; _MG_Graph_optionen_Hilfsgitterlinien 	(iGraph.i, iHilfsgitter_aktiviert.i = #True, iHilfsgitter_abstand_X.i = 10, iHilfsgitter_abstand_Y.i = 10, iHilfsgitter_breite.i = 1, iHilfsgitter_farbe_RGBA.i = -1)
; _MG_Graph_optionen_Plottmodus 		(iGraph.i, iPlottmodus.i, iPlottfrequenz.i, iClearmodus.i, iInterpolation.i = #True)
; _MG_Graph_optionen_Bezugspunkte 		(iGraph.i, iY_Linien_farbe_RGBA.i = -1, iY_Linien_breite.i = 1, iX_Bezugs_position.i = 0, iX_Linien_farbe_RGBA.i = -1, iX_Linien_breite.i = 1)
; _MG_Kanal_optionen 					(iGraph.i, iKanal.i, iKanal_aktivieren.i = #True, iLinien_Breite.i = 1, iLinien_Farbe_RGBA.i = -1)
; _MG_Hilfslinien_optionen 				(iGraph.i, iHilfslinie.i, iHilfslinie_aktiviert.i = #True, iTyp.i = 0, iX_Pos.i = 0, iY_Pos.i = 0, iBreite.i = 2, iLaenge.i = -1, iLinien_farbe_RGBA.i = -1)
; _MG_Graph_plotte_Werte				(iGraph.i)
; _MG_Graph_Achse_links					(iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "%", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
; _MG_Graph_Achse_rechts				(iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "%", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
; _MG_Graph_Achse_unten					(iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "s", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
; _MG_Graph_GUI_updaten					(iGraph.i)
; _MG_Graph_initialisieren				(iGraph.i)
; _MG_Wert_setzen						(iGraph.i, iKanal.i, fWert.f)
; _MG_Graph_reset						(iGraph.i)
; _MG_Graph_entfernen 					(iGraph.i)
;
;} ========================================================================================================================================================



;{ --> #INTERNAL_USE_ONLY# ================================================================================================================================
;
; Function								Parameter
; ----------------------------------------------------------------------
; _MG_Graph_plotte_Element 				(iX1.i, iY1.i, iX2.i, iY2.i, iRGBA_Farbe.i, iBreite.i, iModus.i = 0)
; _MG_Graph_plotte_Hilfslinien 			(iGraph.i)
; _MG_Graph_plotte_Bezugslinien 		(iGraph.i)
; _MG_Graph_plotte_Hauptgitterlinien 	(iGraph.i, iModus.i = 0)
; _MG_Graph_plotte_Hilfsgitterlinien	(iGraph.i, iModus.i = 0)
;
;} ========================================================================================================================================================



;{ --> #FUNCTION-DESCRIPTION# =============================================================================================================================
;
; Function								kurze Beschreibung
; ----------------------------------------------------------------------
; _MG_Graph_erstellen 					erstellt einen Graphen
; _MG_Graph_optionen_position 			verschiebt einen Graphen in der GUI oder passt die Größe neu an
; _MG_Graph_optionen_allgemein 			ändert die allgemeinen Einstellungen des Graphen
; _MG_Graph_optionen_Rahmen 			ändert die Rahmen-Einstellungen des Graphen
; _MG_Graph_optionen_Hauptgitterlinien 	ändert die Einstellungen der Hauptgitterlinien im Graphen
; _MG_Graph_optionen_Hilfsgitterlinien 	ändert die Einstellungen der Hilfsgitterlinien im Graphen
; _MG_Graph_optionen_Plottmodus 		ändert die Plott-Einstellungen des Graphen
; _MG_Graph_optionen_Bezugspunkte 		ändert die Position der Bezugslinien (absoluter Nullpunkt des Graphen)
; _MG_Kanal_optionen 					ändert die Kanal-Einstellungen des Graphen
; _MG_Hilfslinien_optionen 				Einstellungen zum Zeichnen zusätzliche Hilfslinien in den Graphen
; _MG_Graph_plotte_Element 				diese Funktion führt in dem aktuellen Ausgabekanal die Zeichenoperationen durch
; _MG_Graph_plotte_Hilfslinien 			plottet die Hilfslinien in den Graphen
; _MG_Graph_plotte_Bezugslinien 		plottet die Bezugslinien in den Graphen
; _MG_Graph_plotte_Hauptgitterlinien 	zeichnet die Hauptgitterlinien in den Graphen ein
; _MG_Graph_plotte_Hilfsgitterlinien	zeichnet die Hilfsgitterlinien in den Graphen ein
; _MG_Graph_plotte_Werte				plottet die neuen Werte in den Graphen und aktualisiert ggf. die Darstellung in der GUI (je nach Einstellungen)
; _MG_Graph_Achse_links					erzeugt eine Achsbeschriftung auf der linken Seite (Y-Achse), die sich an den horizontalen Hauptgitterlinien richtet
; _MG_Graph_Achse_rechts				erzeugt eine Achsbeschriftung auf der rechten Seite (Y-Achse), die sich an den horizontalen Hauptgitterlinien richtet
; _MG_Graph_Achse_unten					erzeugt eine Achsbeschriftung auf der unteren Seite (X-Achse), die sich an den vertikalen Hauptgitterlinien richtet
; _MG_Graph_GUI_updaten					zeichnet den Graph in die GUI bzw. aktualisiert die Darstellung
; _MG_Graph_initialisieren				plottet den Graphen erstmalig in der GUI
; _MG_Wert_setzen						legt den neuen Wert für den nächsten Plottvorgang fest
; _MG_Graph_reset						löscht die aktuell geplotteten Werte
; _MG_Graph_entfernen 					löscht den Graphen aus der GUI
;
;} ========================================================================================================================================================

;} #INFORMATIONEN - END# ==================================================================================================================================


;{ #USER OPTIONS# =========================================================================================================================================
#_MG_max_Anzahl_Graphen		= 10		; max. Anzahl der Graphen
#_MG_max_Anzahl_Kanaele		= 10		; max. Anzahl der Kanäle pro Graph
#_MG_max_Anzahl_Hilfslinien	= 10		; max. Anzahl der Hilfslinien pro Graph
#_MG_max_Anzahl_Elemente	= 100		; max. Anzahl von Elementen (z.B. Beschriftungen und Einstellungen) --> Arraygröße: sollte nicht geändert werden
;} ========================================================================================================================================================



;{ #VARIABLES# ============================================================================================================================================

; Deklarieren der Funktionen
Declare _MG_Graph_erstellen 					(iGraph.i, iX_Pos.i, iY_Pos.i, iBreite.i, iHoehe.i)
Declare _MG_Graph_optionen_position 			(iGraph.i, iX_Pos.i = 10, iY_Pos.i = 10, iBreite.i = 400, iHoehe.i = 250)
Declare _MG_Graph_optionen_allgemein 			(iGraph.i, iAufloesung.i = -1, iY_min.i = -100, iY_max.i = 100, iHintergrundfarbe_RGB.i = -1)
Declare _MG_Graph_optionen_Rahmen 				(iGraph.i, iAnzeigen.i = #True, iRahmenfarbe_RGB.i = -1, iRahmenbreite.i = 1)
Declare _MG_Graph_optionen_Hauptgitterlinien 	(iGraph.i, iHauptgitter_aktiviert.i = #True, iHauptgitter_abstand_X.i = 50, iHauptgitter_abstand_Y.i = 50, iHauptgitter_breite.i = 1, iHauptgitter_farbe_RGBA.i = -1)
Declare _MG_Graph_optionen_Hilfsgitterlinien 	(iGraph.i, iHilfsgitter_aktiviert.i = #True, iHilfsgitter_abstand_X.i = 10, iHilfsgitter_abstand_Y.i = 10, iHilfsgitter_breite.i = 1, iHilfsgitter_farbe_RGBA.i = -1)
Declare _MG_Graph_optionen_Plottmodus 			(iGraph.i, iPlottmodus.i, iPlottfrequenz.i, iClearmodus.i, iInterpolation.i = #True)
Declare _MG_Graph_optionen_Bezugspunkte 		(iGraph.i, iY_Linien_farbe_RGBA.i = -1, iY_Linien_breite.i = 1, iX_Bezugs_position.i = 0, iX_Linien_farbe_RGBA.i = -1, iX_Linien_breite.i = 1)
Declare _MG_Kanal_optionen 						(iGraph.i, iKanal.i, iKanal_aktivieren.i = #True, iLinien_Breite.i = 1, iLinien_Farbe_RGBA.i = -1)
Declare _MG_Hilfslinien_optionen 				(iGraph.i, iHilfslinie.i, iHilfslinie_aktiviert.i = #True, iTyp.i = 0, iX_Pos.i = 0, iY_Pos.i = 0, iBreite.i = 2, iLaenge.i = -1, iLinien_farbe_RGBA.i = -1)
Declare _MG_Graph_plotte_Element 				(iX1.i, iY1.i, iX2.i, iY2.i, iRGBA_Farbe.i, iBreite.i, iModus.i = 0)
Declare _MG_Graph_plotte_Hilfslinien 			(iGraph.i)
Declare _MG_Graph_plotte_Bezugslinien 			(iGraph.i)
Declare _MG_Graph_plotte_Hauptgitterlinien 		(iGraph.i, iModus.i = 0)
Declare _MG_Graph_plotte_Hilfsgitterlinien		(iGraph.i, iModus.i = 0)
Declare _MG_Graph_plotte_Werte					(iGraph.i)
Declare _MG_Graph_Achse_links					(iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "%", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
Declare _MG_Graph_Achse_rechts					(iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "%", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
Declare _MG_Graph_Achse_unten					(iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "s", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
Declare _MG_Graph_GUI_updaten					(iGraph.i)
Declare _MG_Graph_initialisieren				(iGraph.i)
Declare _MG_Wert_setzen							(iGraph.i, iKanal.i, fWert.f)
Declare _MG_Graph_reset							(iGraph.i)
Declare _MG_Graph_entfernen 					(iGraph.i)



; feste Array-Bereiche erstellen
#_MG_Hilfslinien_start		= #_MG_max_Anzahl_Kanaele + 1

#_MG_b_links_Beschriftung	= #_MG_max_Anzahl_Kanaele + #_MG_max_Anzahl_Hilfslinien + 1
#_MG_b_links_Strich			= #_MG_max_Anzahl_Kanaele + #_MG_max_Anzahl_Hilfslinien + 2

#_MG_b_rechts_Beschriftung	= #_MG_max_Anzahl_Kanaele + #_MG_max_Anzahl_Hilfslinien + 3
#_MG_b_rechts_Strich		= #_MG_max_Anzahl_Kanaele + #_MG_max_Anzahl_Hilfslinien + 4

#_MG_b_unten_Beschriftung	= #_MG_max_Anzahl_Kanaele + #_MG_max_Anzahl_Hilfslinien + 5
#_MG_b_unten_Strich			= #_MG_max_Anzahl_Kanaele + #_MG_max_Anzahl_Hilfslinien + 6



; dynamische Array-Bereiche erstellen
Enumeration 
	#_MG_a_iGraph_aktiviert										; enthält die Information, ob dieser Graph verwendet wird
	#_MG_a_hGraph_Backbuffer									; das handle (GadgetID) zum Zeichenbereich, auf dem die Werte geplottet werden
	#_MG_a_hGraph_Verschiebung									; das handle (GadgetID) des kopierten Zeichenbereich, der beim Modus "bewegter Graph" verschoben wird 
	#_MG_a_hGraph_Frontbuffer									; das Image-Gadget, das in der GUI angezeigt wird ist
	#_MG_a_iZeichnung_aktiv										; markiert den aktuellen Ausgabekanal der Zeichenoperationen (kann immer nur bei einem Graphen aktiv sein)
	#_MG_a_iX_Pos												; X-Koordinate des Zeichenbereiches (linke, obere Ecke)
	#_MG_a_iY_Pos												; Y-Koordinate des Zeichenbereiches (linke, obere Ecke)
	#_MG_a_iBreite												; die Breite des Graphen
	#_MG_a_iHoehe												; die Höhe des Graphen
	#_MG_a_hRahmen												; das handle (GadgetID) des Rahmens
	#_MG_a_iRahmen												; aktiviert/deaktiviert den Rahmen für den Graphen
	#_MG_a_iRahmenfarbe_RGB										; die Rahmenfarbe
	#_MG_a_iRahmenbreite										; die Breite des Rahmens. (der Zeichenbereich des Graphen wird dabei nicht verschoben oder verändert)
	#_MG_a_iAufloesung											; Auflösung bzw. horizontale Skalierung: Ist die Anzahl der Werte, die dargestellt werden. (Wenn die Auflösung gleich die Breite des Graphen ist, dann wird pro Pixel ein Wert dargestellt.)
	#_MG_a_fInkrement_groesse									; der horizontale Pixelabstand zwischen zwei dargestellten Werten
	#_MG_a_iVerschiebung										; Anzahl der horizontalen Pixel, die im "Scroll-Modus" für jede neue Darstellung verschoben werden müssen.
	#_MG_a_iY_min												; der kleinste Wert, der im Graph dargestellt werden kann
	#_MG_a_iY_max												; der größte Wert, der im Graph dargestellt werden kann
	#_MG_a_iY_null_linie_pos									; Position der horizontalen Bezugslinie
	#_MG_a_iY_null_linie_farbe_RGBA								; die RGBA-Farbe der horizontalen Bezugslinie
	#_MG_a_iY_null_linie_breite									; die Breite der horizontalen Bezugslinie
	#_MG_a_iX_null_linie_pos									; Position der vertikalen Bezugslinie
	#_MG_a_iX_null_linie_farbe_RGBA								; die RGBA-Farbe der vertikalen Bezugslinie
	#_MG_a_iX_null_linie_breite									; die Breite der vertikalen Bezugslinie
	#_MG_a_iWertebereich										; Wertebereich des Graphen (Y-Achse)
	#_MG_a_fWertaufloesung										; Auflösung bzw. vertikale Skalierung: kleinster vertikaler Pixelabstand zwischen 2 Werten
	#_MG_a_iHintergrundfarbe_RGB								; die Hintergrundfarbe des Graphen	
	#_MG_a_iHauptgitter_aktiviert								; aktiviert/deaktiviert die Hauptgitterlinien
	#_MG_a_iHauptgitter_abstand_X								; der horizontale Abstand zwischen den Hauptgitterlinien
	#_MG_a_iHauptgitter_abstand_Y								; der vertikale Abstand zwischen den Hauptgitterlinien
	#_MG_a_iHauptgitter_farbe_RGBA								; die verwendete Farbe der Hauptgitterlinien
	#_MG_a_iHauptgitter_breite									; die Linienbreite der Hauptgitterlinien
	#_MG_a_iHauptgitter_Merker									; ein Merker zum Zwischenspeichern von Positionsinformationen
	#_MG_a_iHilfsgitter_aktiviert								; aktiviert/deaktiviert die Hilfsgitterlinien
	#_MG_a_iHilfsgitter_abstand_X								; der horizontale Abstand zwischen den Hilfsgitterlinien
	#_MG_a_iHilfsgitter_abstand_Y								; der vertikale Abstand zwischen den Hilfsgitterlinien
	#_MG_a_iHilfsgitter_farbe_RGBA								; die verwendete Farbe der Hilfsgitterlinien
	#_MG_a_iHilfsgitter_breite									; die Linienbreite der Hilfsgitterlinien
	#_MG_a_iHilfsgitter_Merker									; ein Merker zum Zwischenspeichern von Positionsinformationen
	#_MG_a_iPlottfrequenz										; ist die Anzahl der Plottvorgänge, bevor der Graph in der GUI aktualisiert wird. (je höher der Wert, desto mehr Werte können pro Sekunde dargestellt werden)
	#_MG_a_iPlottmodus											; Anzeigemodus des Graphen -> 0: stehender Graph: Werte werden von links nach rechts gezeichnet;  1: bewegter Graph: Graph "scrollt" kontinuierlich von rechts nach links
	#_MG_a_iClearmodus											; Löschmodus (nur wenn Plottmodus: 0) -> 0: alte Werte nicht löschen;  1: "aktualisieren" der alten Werte;  2: Graphinhalt nach kompletten durchlauf löschen
	#_MG_a_iInterpolation										; aktiviert/deaktiviert die Interpolation zwischen 2 Werten
	#_MG_a_iPlott_Counter										; allgemeiner Merker für den Plottvorgang (Zähler für die Plottfrequenz)
	#_MG_a_iPosition_aktuell									; aktuelle (horizontale) Position des zu plottenden Wertes im Zeichenbereich
	#_MG_a_iAchsbeschriftungen_rechts							; Anzahl der Beschriftungen der Y-Achse (rechte Seite)
	#_MG_a_iAchsbeschriftungen_rechts_intervall					; Multiplikator: Darstellungsfaktor zwischen den Hauptgitterlinien -> 1: jede Hauptgitterlinie;  2: jede zweite Hauptgitterlinie; ...usw...
	#_MG_a_iAchsbeschriftungen_links							; Anzahl der Beschriftungen der Y-Achse (linke Seite)
	#_MG_a_iAchsbeschriftungen_links_intervall					; Multiplikator: Darstellungsfaktor zwischen den Hauptgitterlinien -> 1: jede Hauptgitterlinie;  2: jede zweite Hauptgitterlinie; ...usw...
	#_MG_a_iAchsbeschriftungen_unten							; Anzahl der Beschriftungen der X-Achse
	#_MG_a_iAchsbeschriftungen_unten_intervall					; Multiplikator: Darstellungsfaktor zwischen den Hauptgitterlinien -> 1: jede Hauptgitterlinie;  2: jede zweite Hauptgitterlinie; ...usw...
EndEnumeration


Enumeration 
	#_MG_k_iKanal_aktivieren 									; aktiviert/deaktivert den jeweiligen Kanal eines Graphen
	#_MG_k_fY_aktueller_Wert 									; aktueller Wert
	#_MG_k_fY_letzter_Wert 										; letzter Wert
	#_MG_k_iLinien_Farbe_RGBA									; die RGBA-Farbe der Linie
	#_MG_k_iLinien_Breite										; die Linienbreite
EndEnumeration


Enumeration 	
	#_MG_L_iaktiviert											; aktiviert/deaktiviert die jeweilige Hilfslinie
	#_MG_L_iTyp													; Typ 0: vertikale Linie;   Typ 1: horizontale Linie;   Typ 2: beide Linien
	#_MG_L_iX_Pos												; X-Position der Hilfslinie
	#_MG_L_iY_Pos												; Y-Position der Hilfslinie
	#_MG_L_iBreite												; Breite der Hilfslinie(n)
	#_MG_L_iLaenge												; nur Typ 2: die Länger der Linie (bezogen auf den Schnittpunkt)
	#_MG_L_iRGBA_Farbe											; RGBA-Farbe der Hilfslinie(n)
EndEnumeration



; das Array erstellen, in dem die Einstellungen und Werte hinterlegt werden
Global Dim MG_aGraph.d (#_MG_max_Anzahl_Graphen, #_MG_max_Anzahl_Kanaele + #_MG_max_Anzahl_Hilfslinien + 6, #_MG_max_Anzahl_Elemente)
;} ========================================================================================================================================================



;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_erstellen
; Beschreibung ..: 	erstellt einen Graphen
; Syntax.........: 	_MG_Graph_erstellen (iGraph.i, iX_Pos.i, iY_Pos.i, iBreite.i, iHoehe.i)
;
; Parameter .....: 	iGraph.i    - Graph-Index das verwendet werden soll (beginnend mit 1)
;                  	iX_Pos.i	- X-Koordinate des Zeichenbereiches (linke, obere Ecke)
;                  	iY_Pos.i	- Y-Koordinate des Zeichenbereiches (linke, obere Ecke)
;                  	iBreite.i 	- die Breite des Graphen
;                  	iHoehe.i 	- die Höhe des Graphen
;
; Rückgabewerte .: 	Erfolg 		|  0
;
;                  	Fehler 		| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 		| -2 der Graph ist schon aktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...: 	Wichtig: der Graphindex beginnt bei '1'. Der Index 0 ist reserviert und darf nicht verwendet werden.
;
;} ========================================================================================================================================================
Procedure _MG_Graph_erstellen (iGraph.i, iX_Pos.i, iY_Pos.i, iBreite.i, iHoehe.i)

	; lokale Variablen deklarieren
	Protected i.i															; allgemeiner Zähler für Schleifen
	Protected iKanal.i														; Kanalnummer für Schleifen
	Protected iHilfslinie.i													; Hilfsliniennummer für Schleifen
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0)
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph schon aktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = 1) 
		ProcedureReturn (-2)
	EndIf
	

	; erzeugt den Graphen mit den Voreinstellungen
	MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert)							= #True	
	
	MG_aGraph(iGraph, 0, #_MG_a_iX_Pos)										= iX_Pos
	MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)										= iY_Pos
	MG_aGraph(iGraph, 0, #_MG_a_iBreite)									= iBreite
	MG_aGraph(iGraph, 0, #_MG_a_iHoehe)										= iHoehe	

	MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv)							= #False
	MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)							= CreateImage(#PB_Any, iBreite, iHoehe)
	MG_aGraph(iGraph, 0, #_MG_a_hGraph_Verschiebung)						= 0
	MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer)							= ImageGadget(#PB_Any, iX_Pos, iY_Pos, iBreite, iHoehe, ImageID(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))

	MG_aGraph(iGraph, 0, #_MG_a_iAufloesung)								= iBreite
	MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse)							= iBreite / MG_aGraph(iGraph, 0, #_MG_a_iAufloesung)
	MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung)								= Int(iBreite - MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse))
	MG_aGraph(iGraph, 0, #_MG_a_iY_min)										= 0
	MG_aGraph(iGraph, 0, #_MG_a_iY_max)										= 100
	MG_aGraph(iGraph, 0, #_MG_a_iWertebereich)								= Abs(MG_aGraph(iGraph, 0, #_MG_a_iY_max) - MG_aGraph(iGraph, 0, #_MG_a_iY_min))
	MG_aGraph(iGraph, 0, #_MG_a_fWertaufloesung)							= MG_aGraph(iGraph, 0, #_MG_a_iHoehe) / MG_aGraph(iGraph, 0, #_MG_a_iWertebereich)
	MG_aGraph(iGraph, 0, #_MG_a_iHintergrundfarbe_RGB)						= RGB (255, 255, 255)
	
	MG_aGraph(iGraph, 0, #_MG_a_iPlottfrequenz)								= 0
	MG_aGraph(iGraph, 0, #_MG_a_iPlottmodus)								= 0
	MG_aGraph(iGraph, 0, #_MG_a_iClearmodus)								= 2
	MG_aGraph(iGraph, 0, #_MG_a_iInterpolation)								= #True
	MG_aGraph(iGraph, 0, #_MG_a_iPlott_Counter)								= 0
	MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell)							= 0

	MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)							= 0
	MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_breite)						= 1
	MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_farbe_RGBA)					= RGBA(0, 0, 0, 255)
	
	MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)							= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) / MG_aGraph(iGraph, 0, #_MG_a_iWertebereich)) * MG_aGraph(iGraph, 0, #_MG_a_iY_max)
	MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_breite)						= 1
	MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_farbe_RGBA)					= RGBA(0, 0, 0, 255)	
	
	MG_aGraph(iGraph, 0, #_MG_a_iRahmen)									= #True
	MG_aGraph(iGraph, 0, #_MG_a_hRahmen)									= TextGadget (#PB_Any, iX_Pos - 1, iY_Pos - 1, iBreite + 2, iHoehe + 2, "")
	MG_aGraph(iGraph, 0, #_MG_a_iRahmenbreite)								= 1	
	MG_aGraph(iGraph, 0, #_MG_a_iRahmenfarbe_RGB)							= RGB (0, 0, 0)
	
	MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_aktiviert)						= #True
	MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X)						= 50
	MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)						= 50
	MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker)						= MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X) - 2
	MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_breite)						= 1
	MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_farbe_RGBA)					= RGBA(0, 0, 0, 85)

	MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_aktiviert)						= #True
	MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X)						= 10
	MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y)						= 10
	MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker)						= MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X) - 2
	MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_breite)						= 1
	MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_farbe_RGBA)					= RGBA(0, 0, 0, 45)

	MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_links)					= 0
	MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_links_intervall)		= 0
	
	MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_rechts)					= 0
	MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_rechts_intervall)		= 0
	
	MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_unten)					= 0
	MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_unten_intervall)		= 0
	
	
	
	; die Farbe des Rahmen übernehmen
	SetGadgetColor(MG_aGraph(iGraph, 0, #_MG_a_hRahmen), #PB_Gadget_BackColor, MG_aGraph(iGraph, 0, #_MG_a_iRahmenfarbe_RGB))
	

	; den Ausgabekanal für die aktuellen Zeichenoperationen setzen
	If (MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) <> #True)
		
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) = #True
		
		StopDrawing()
		StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		
	EndIf
	
	
	; den Zeichenbereich leeren
	DrawingMode(#PB_2DDrawing_Default)
	Box(0, 0, MG_aGraph(iGraph, 0, #_MG_a_iBreite), MG_aGraph(iGraph, 0, #_MG_a_iHoehe), MG_aGraph(iGraph, 0, #_MG_a_iHintergrundfarbe_RGB))
	StopDrawing()
	SetGadgetState(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer), ImageID(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
	StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
	
	
	; Grundeinstellung der einzelnen Kanäle
	For iKanal = 1 To #_MG_max_Anzahl_Kanaele Step 1

		MG_aGraph(iGraph, iKanal, #_MG_k_iKanal_aktivieren)					= #False
		MG_aGraph(iGraph, iKanal, #_MG_k_fY_aktueller_Wert)					= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)
		MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert)					= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)
		MG_aGraph(iGraph, iKanal, #_MG_k_iLinien_Breite)					= 1
		MG_aGraph(iGraph, iKanal, #_MG_k_iLinien_Farbe_RGBA)				= RGBA (0, 100, 255, 255)
	
	Next
	

	; Grundeinstellung der einzelnen Hilfslinien
	For iHilfslinie = #_MG_Hilfslinien_start To (#_MG_Hilfslinien_start + #_MG_max_Anzahl_Hilfslinien - 1) Step 1

		MG_aGraph(iGraph, iHilfslinie, #_MG_L_iaktiviert)					= #False
		MG_aGraph(iGraph, iHilfslinie, #_MG_L_iTyp)							= 0
		MG_aGraph(iGraph, iHilfslinie, #_MG_L_iX_Pos)						= 0
		MG_aGraph(iGraph, iHilfslinie, #_MG_L_iY_Pos)						= 0
		MG_aGraph(iGraph, iHilfslinie, #_MG_L_iBreite)						= 1
		MG_aGraph(iGraph, iHilfslinie, #_MG_L_iLaenge)						= 0
		MG_aGraph(iGraph, iHilfslinie, #_MG_L_iRGBA_Farbe)					= RGBA (0, 190, 0, 255)	
		
	Next	


	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)
	
	
EndProcedure	;==> _MG_Graph_erstellen




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_optionen_position
; Beschreibung ..: 	verschiebt einen Graphen in der GUI oder passt die Größe neu an
; Syntax.........: 	_MG_Graph_optionen_position (iGraph.i, iX_Pos.i = 10, iY_Pos.i = 10, iBreite.i = 400, iHoehe.i = 250)
;
; Parameter .....:  iGraph.i    - Graph-Index das verwendet werden soll (beginnend mit 1)
;                  	iX_Pos.i	- X-Koordinate des Zeichenbereiches (linke, obere Ecke)
;                  	iY_Pos.i	- Y-Koordinate des Zeichenbereiches (linke, obere Ecke)
;                  	iBreite.i 	- die Breite des Graphen
;                  	iHoehe.i 	- die Höhe des Graphen
;
; Rückgabewerte .: 	Erfolg 		|  0
;
;                  	Fehler 		| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 		| -2 der Graph wurde deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...:  Die Achsbeschriftungen müssen manuell aktualisiert werden, damit die neue Position übernommen wird
;
;} ========================================================================================================================================================
Procedure _MG_Graph_optionen_position (iGraph.i, iX_Pos.i = 10, iY_Pos.i = 10, iBreite.i = 400, iHoehe.i = 250)
	
	; lokale Variablen deklarieren
	Protected hRahmen.i														; handle zum Text-Gedget
	Protected iRahmen_X_Pos.i												; X-Koordinate des Zeichenbereiches (linke, obere Ecke)
	Protected iRahmen_Y_Pos.i												; Y-Koordinate des Zeichenbereiches (linke, obere Ecke)
	Protected iRahmen_Breite.i												; breite des Labels
	Protected iRahmen_Hoehe.i												; höhe des Labels
	Protected iRahmen_Dicke.i												; die verwendete Rahmendicke								
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	
	
	; minimale Breite garantieren
	If (iBreite < 1) 
		iBreite = 1
	EndIf
	
	
	; minimale Höhe garantieren
	If (iHoehe < 1) 
		iHoehe = 1
	EndIf
	
	
	; Einstellungen übernehmen und speichern
	MG_aGraph(iGraph, 0, #_MG_a_iX_Pos)										= iX_Pos
	MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)										= iY_Pos
	MG_aGraph(iGraph, 0, #_MG_a_iBreite)									= iBreite
	MG_aGraph(iGraph, 0, #_MG_a_iHoehe)										= iHoehe
	MG_aGraph(iGraph, 0, #_MG_a_iAufloesung)								= iBreite
	MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse)							= iBreite / MG_aGraph(iGraph, 0, #_MG_a_iAufloesung)
	MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung)								= Int(iBreite - MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse))
	MG_aGraph(iGraph, 0, #_MG_a_fWertaufloesung)							= MG_aGraph(iGraph, 0, #_MG_a_iHoehe) / MG_aGraph(iGraph, 0, #_MG_a_iWertebereich)
	
	
	; Skalierung der Zeichenfläche auf die neue Größe
	ResizeImage (MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer),iBreite, iHoehe, #PB_Image_Raw)
	ResizeGadget(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer),iX_Pos, iY_Pos, iBreite, iHoehe)

	
	; den Rahmen neu positionieren
	hRahmen				= MG_aGraph(iGraph, 0, #_MG_a_hRahmen)
	iRahmen_Dicke		= MG_aGraph(iGraph, 0, #_MG_a_iRahmenbreite)
	iRahmen_X_Pos 		= MG_aGraph(iGraph, 0, #_MG_a_iX_Pos)  - iRahmen_Dicke
	iRahmen_Y_Pos 		= MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)  - iRahmen_Dicke
	iRahmen_Breite 		= MG_aGraph(iGraph, 0, #_MG_a_iBreite) + (2 * iRahmen_Dicke)
	iRahmen_Hoehe 		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)  + (2 * iRahmen_Dicke)
	
	ResizeGadget(hRahmen, iRahmen_X_Pos, iRahmen_Y_Pos, iRahmen_Breite, iRahmen_Hoehe)
	
	
	; den Ausgabekanal für die aktuellen Zeichenoperationen setzen
	If (MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) <> #True)
		
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) = #True
		
		StopDrawing()
		StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		
	EndIf
	
	
	; den Zeichenbereich leeren	
	DrawingMode(#PB_2DDrawing_Default)
	Box(0, 0, MG_aGraph(iGraph, 0, #_MG_a_iBreite), MG_aGraph(iGraph, 0, #_MG_a_iHoehe), MG_aGraph(iGraph, 0, #_MG_a_iHintergrundfarbe_RGB))
	StopDrawing()
	SetGadgetState(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer), ImageID(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
	StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
	
	
	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_optionen_position




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_optionen_allgemein
; Beschreibung ..: 	ändert die allgemeinen Einstellungen des Graphen
; Syntax.........: 	_MG_Graph_optionen_allgemein (iGraph.i, iAufloesung.i = -1, iY_min.i = -100, iY_max.i = 100, iHintergrundfarbe_RGB.i = -1)
;
; Parameter .....: 	iGraph.i 				- Graph-Index, auf dem sich die Einstellungen beziehen
;                  	iAufloesung.i    		- Auflösung bzw. horizontale Skalierung: Ist die Anzahl der Werte, die dargestellt werden.
;										  	  Wenn die Auflösung gleich die Breite des Graphen ist, dann wird pro Pixel ein Wert dargestellt.
;											| -1 passt die Auflösung an die Graphbreite an (Skalierung auf 100%)
;											| >0 Anzahl der Werte die dargestellt werden
;
;                  	iY_min.i				- der kleinste Y-Wert, der im Graph dargestellt werden kann
;                  	iY_max.i				- der größte Y-Wert, der im Graph dargestellt werden kann
;                  	iHintergrundfarbe_RGB.i - die Hintergrundfarbe des Graphen (z.B. für Weiß: RGB(255, 255, 255))
;											| -1 verwendet die Standardfarbe (Weiß)
;											| >0 RGB()-Farbcode
;
; Rückgabewerte .: 	Erfolg 					|  0
;
;                  	Fehler 					| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 					| -2der Graph wurde deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...:	Folgendes muss bei der Auflösung beachtet werden: Wird der Plottmodus '1' (bewegter Graph) verwendet, so darf die Auflösung 
;					nicht größer als die Graphbreite sein. Sollte dies aber der Fall sein, so wird sich der Graph nicht bewegen.
;
;} ========================================================================================================================================================
Procedure _MG_Graph_optionen_allgemein (iGraph.i, iAufloesung.i = -1, iY_min.i = -100, iY_max.i = 100, iHintergrundfarbe_RGB.i = -1)
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf
	
	
	; Standardfarbe verwenden, wenn der Parameter auf '-1" gesetzt wurde
	If (iHintergrundfarbe_RGB = -1)
		iHintergrundfarbe_RGB = RGB(255, 255, 255)
	EndIf
	
	
	; die Auflösung an die Breite anpassen, wenn der Parameter auf '-1" gesetzt wurde
	If (iAufloesung = -1)
		iAufloesung = MG_aGraph(iGraph, 0, #_MG_a_iBreite)
	EndIf
	
	
	; garantiert, dass iY_max größer iY_min ist
	If (iY_min >= iY_max)
		iY_max = iY_min + 1
	EndIf

	
	; Einstellungen übernehmen und speichern
	MG_aGraph(iGraph, 0, #_MG_a_iAufloesung)								= iAufloesung
	MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse)							= MG_aGraph(iGraph, 0, #_MG_a_iBreite) / MG_aGraph(iGraph, 0, #_MG_a_iAufloesung)
	MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung)								= Int(MG_aGraph(iGraph, 0, #_MG_a_iBreite) - MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse))
	MG_aGraph(iGraph, 0, #_MG_a_iY_min)										= iY_min
	MG_aGraph(iGraph, 0, #_MG_a_iY_max)										= iY_max
	MG_aGraph(iGraph, 0, #_MG_a_iWertebereich)								= Abs(iY_max - iY_min)
	MG_aGraph(iGraph, 0, #_MG_a_fWertaufloesung)							= MG_aGraph(iGraph, 0, #_MG_a_iHoehe) / MG_aGraph(iGraph, 0, #_MG_a_iWertebereich)
	MG_aGraph(iGraph, 0, #_MG_a_iHintergrundfarbe_RGB)						= iHintergrundfarbe_RGB
	

	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_optionen_allgemein




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_optionen_Rahmen
; Beschreibung ..: 	ändert die Rahmen-Einstellungen des Graphen
; Syntax.........:  _MG_Graph_optionen_Rahmen (iGraph.i, iAnzeigen.i = #True, iRahmenfarbe_RGB.i = -1, iRahmenbreite.i = 1)
;
; Parameter .....: 	iGraph.i 				- Graph-Index, auf dem sich die Einstellungen beziehen
;                  	iAnzeigen.i	    		- aktiviert/deaktiviert den Rahmen
;											| #True		Rahmen anzeigen
;											| #False	Rahmen nicht anzeigen
;
;                  	iRahmenfarbe_RGB.i		- die Farbe des Rahmen in als RGB()-Code (z.B. für Schwarz: RGB(0, 0, 0))
;											| -1 verwendet die Standardfarbe (Schwarz)
;											| >0 RGB()-Farbcode
;
;                  	iRahmenbreite.i  		- die Breite des Rahmens (in Pixeln)
;
; Rückgabewerte .: 	Erfolg 					|  0
;
;                  	Fehler 					| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 					| -2 der Graph wurde deaktiviert
;
; Autor .........: 	SBond
; Bemerkungen ...:  Info: die Änderung der Rahmenbreite verschiebt oder ändert den Zeichenbereich nicht. Der Rahmen dehnt sich demnach nach außen aus.
;
;} ========================================================================================================================================================
Procedure _MG_Graph_optionen_Rahmen (iGraph.i, iAnzeigen.i = #True, iRahmenfarbe_RGB.i = -1, iRahmenbreite.i = 1)
	
	; lokale Variablen deklarieren
	Protected hRahmen.i														; handle zum Text-Gedget
	Protected iRahmen_X_Pos.i												; X-Koordinate des Zeichenbereiches (linke, obere Ecke)
	Protected iRahmen_Y_Pos.i												; Y-Koordinate des Zeichenbereiches (linke, obere Ecke)
	Protected iRahmen_Breite.i												; breite des Labels
	Protected iRahmen_Hoehe.i												; höhe des Labels
	Protected iRahmen_Dicke.i												; die verwendete Rahmendicke								
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	
	
	; Standardfarbe verwenden, wenn der Parameter auf '-1" gesetzt wurde
	If (iRahmenfarbe_RGB = -1)
		iRahmenfarbe_RGB = RGB(0, 0, 0)
	EndIf
	
	
	; Einstellungen übernehmen und speichern
	MG_aGraph(iGraph, 0, #_MG_a_iRahmen)									= iAnzeigen
	MG_aGraph(iGraph, 0, #_MG_a_iRahmenfarbe_RGB)							= iRahmenfarbe_RGB
	MG_aGraph(iGraph, 0, #_MG_a_iRahmenbreite)								= iRahmenbreite
	
	
	; verschiebt den Rahmen mittig zum Zeichenbereich
	If (iAnzeigen = 1)
		
		; den Rahmen neu positionieren
		hRahmen				= MG_aGraph(iGraph, 0, #_MG_a_hRahmen)
		iRahmen_Dicke		= MG_aGraph(iGraph, 0, #_MG_a_iRahmenbreite)
		iRahmen_X_Pos 		= MG_aGraph(iGraph, 0, #_MG_a_iX_Pos)  - iRahmen_Dicke
		iRahmen_Y_Pos 		= MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)  - iRahmen_Dicke
		iRahmen_Breite 		= MG_aGraph(iGraph, 0, #_MG_a_iBreite) + (2 * iRahmen_Dicke)
		iRahmen_Hoehe 		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)  + (2 * iRahmen_Dicke)
		
		ResizeGadget(hRahmen, iRahmen_X_Pos, iRahmen_Y_Pos, iRahmen_Breite, iRahmen_Hoehe)
		
		
		; Rahmenfarbe übernehmen
		SetGadgetColor(MG_aGraph(iGraph, 0, #_MG_a_hRahmen), #PB_Gadget_BackColor, MG_aGraph(iGraph, 0, #_MG_a_iRahmenfarbe_RGB))
		
		
		; Rahmen einblenden, wenn er aktiviert wird
		HideGadget(MG_aGraph(iGraph, 0, #_MG_a_hRahmen), 0)
		
	Else

		; Rahmen ausblenden, wenn er deaktiviert wird
		HideGadget(MG_aGraph(iGraph, 0, #_MG_a_hRahmen), 1)

	EndIf
	
	
	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_optionen_Rahmen




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_optionen_Hauptgitterlinien
; Beschreibung ..: 	ändert die Einstellungen der Hauptgitterlinien im Graphen
; Syntax.........: 	_MG_Graph_optionen_Hauptgitterlinien (iGraph.i, iHauptgitter_aktiviert.i = #True, iHauptgitter_abstand_X.i = 50, iHauptgitter_abstand_Y.i = 50, iHauptgitter_breite.i = 1, iHauptgitter_farbe_RGBA.i = -1)
;
; Parameter .....: 	iGraph.i 					- Graph-Index, auf dem sich die Einstellungen beziehen
;                  	iHauptgitter_aktiviert.i	- aktiviert/deaktiviert die Hauptgitterlinien
;												| #True		Hauptgitterlinien anzeigen
;												| #False	Hauptgitterlinien nicht anzeigen
;
;                  	iHauptgitter_abstand_X.i	- der horizontale Abstand zwischen den Hauptgitterlinien
;                  	iHauptgitter_abstand_Y.i	- der vertikale Abstand zwischen den Hauptgitterlinien
;                  	iHauptgitter_breite.i		- die Linienbreite des Gitters (in Pixeln)
;                  	iHauptgitter_farbe_RGBA.i	- die Farbe als RGBA()-Code (z.B. für Schwarz: RGBA(0, 0, 0, 255))
; 												| -1 verwendet die Standardfarbe (Schwarz)
; 												| >0 RGBA()-Farbcode
;
; Rückgabewerte .: 	Erfolg 						|  0
;
;                  	Fehler 						| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 						| -2 der Graph wurde deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...:
;
;} ========================================================================================================================================================
Procedure _MG_Graph_optionen_Hauptgitterlinien (iGraph.i, iHauptgitter_aktiviert.i = #True, iHauptgitter_abstand_X.i = 50, iHauptgitter_abstand_Y.i = 50, iHauptgitter_breite.i = 1, iHauptgitter_farbe_RGBA.i = -1)
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	

	; Standardfarbe verwenden, wenn der Parameter auf '-1" gesetzt wurde
	If (iHauptgitter_farbe_RGBA = -1)
		iHauptgitter_farbe_RGBA = RGBA(0, 0, 0, 85)
	EndIf
	
	
	; Einstellungen übernehmen und speichern
	MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_aktiviert)						= iHauptgitter_aktiviert
	MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X)						= iHauptgitter_abstand_X
	MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)						= iHauptgitter_abstand_Y
	MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_breite)						= iHauptgitter_breite
	MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_farbe_RGBA)					= iHauptgitter_farbe_RGBA


	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_optionen_Hauptgitterlinien




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_optionen_Hilfsgitterlinien
; Beschreibung ..: 	ändert die Einstellungen der Hilfsgitterlinien im Graphen
; Syntax.........: 	_MG_Graph_optionen_Hilfsgitterlinien (iGraph.i, iHilfsgitter_aktiviert.i = #True, iHilfsgitter_abstand_X.i = 10, iHilfsgitter_abstand_Y.i = 10, iHilfsgitter_breite.i = 1, iHilfsgitter_farbe_RGBA.i = -1)
;
; Parameter .....: 	iGraph.i 					- Graph-Index, auf dem sich die Einstellungen beziehen
;                  	iHilfsgitter_aktiviert.i	- aktiviert/deaktiviert die Hilfsgitterlinien
;												| #True		Hilfsgitterlinien anzeigen
;												| #False	Hilfsgitterlinien nicht anzeigen
;
;                  	iHilfsgitter_abstand_X.i	- der horizontale Abstand zwischen den Hilfsgitterlinien
;                  	iHilfsgitter_abstand_Y.i	- der vertikale Abstand zwischen den Hilfsgitterlinien
;                  	iHilfsgitter_breite.i		- die Linienbreite des Gitters (in Pixeln)
;                  	iHilfsgitter_farbe_RGBA.i	- die Farbe als RGBA()-Code (z.B. für Schwarz: RGBA(0, 0, 0, 255))
; 												| -1 verwendet die Standardfarbe (Schwarz)
; 												| >0 RGBA()-Farbcode
;
; Rückgabewerte .: 	Erfolg 						|  0
;
;                  	Fehler 						| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 						| -2 der Graph wurde deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...:
;
;} ========================================================================================================================================================
Procedure _MG_Graph_optionen_Hilfsgitterlinien (iGraph.i, iHilfsgitter_aktiviert.i = #True, iHilfsgitter_abstand_X.i = 10, iHilfsgitter_abstand_Y.i = 10, iHilfsgitter_breite.i = 1, iHilfsgitter_farbe_RGBA.i = -1)

	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	
	
	; Standardfarbe verwenden, wenn der Parameter auf '-1" gesetzt wurde
	If (iHilfsgitter_farbe_RGBA = -1)
		iHilfsgitter_farbe_RGBA = RGBA(0, 0, 0, 45)
	EndIf
	
	
	; Einstellungen übernehmen und speichern
	MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_aktiviert)						= iHilfsgitter_aktiviert
	MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X)						= iHilfsgitter_abstand_X
	MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y)						= iHilfsgitter_abstand_Y
	MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_breite)						= iHilfsgitter_breite
	MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_farbe_RGBA)					= iHilfsgitter_farbe_RGBA


	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_optionen_Hilfsgitterlinien




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_optionen_Plottmodus
; Beschreibung ..: 	ändert die Plott-Einstellungen des Graphen
; Syntax.........: 	_MG_Graph_optionen_Plottmodus (iGraph.i, iPlottmodus.i, iPlottfrequenz.i, iClearmodus.i, iInterpolation.i = #True)
;
; Parameter .....: 	iGraph.i 			- Graph-Index, auf dem sich die Einstellungen beziehen
;                  	iPlottmodus.i		- die grundsätzliche Darstellungsart, der zu plottenden Werte
;										|  0 stehender Graph:	Werte werden von links nach rechts gezeichnet
;										|  1 bewegter Graph:	der gesamte Graph "scrollt" kontinuierlich von rechts nach links
;
;                  	iPlottfrequenz.i	- ist die Anzahl der Plottvorgänge (einzelne Werte), bevor der Graph in der GUI aktualisiert wird.
;										|  0 der Graph wird erst aktualisiert, wenn der komplette Bildbereich geplottet wurde. (es werden so viele Werte geplottet, wie der Graph breit ist)
;										| >0 die Anzahl der Plottvorgänge, bevor der Graph in der GUI erneut aktualisiert wird
;
;                  	iClearmodus.i		- die "Reinigungsmethode" des Graphen. Diese Option wird nur angewendet, wenn der Plottmodus 0 ist.
;										|  0 keine Reinigung	 - nach einem kompletten Bilddurchlauf werden keine alten Werte gelöscht. (es wird dann einfach überzeichnet)
;										|  1 partielle Reinigung - nach einem kompletten Bilddurchlauf werden die alten (geplotteten) Werte durch neue überschrieben
;										|  2 komplette Reinigung - nach einem kompletten Bilddurchlauf wird der Graphinhalt gelöscht
;
;                  	iInterpolation.i	- aktiviert/deaktiviert die Interpolation der geplotteten Werte
;										| #True		Interpolation aktivieren
;										| #False	Interpolation deaktivieren
;
; Rückgabewerte .: 	Erfolg 				|  0
;
;                  	Fehler 				| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 				| -2 der Graph wurde deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...:	Die aktivierte Interpolation ermöglicht einen schnelleren Plottvorgang, da die gezeichnete Linie direkt von Punkt zu Punkt verbunden wird.
;					Wird die Interpolation deaktiviert, so werden nur horizontale und vertikale Linien gezeichnet. In diesem Fall werden meistens 2 Zeichenvorgänge
;					zwischen 2 Punkten benötigt.
;
;					Um möglichst viele Werte pro Sekunde zu plotten, sollte man den Plottmodus auf 0 und den Clearmodus auf 2 setzen.
;					Dadurch können sehr hohe FPS-Raten (100 bis 600) erreicht werden.
;
;} ========================================================================================================================================================
Procedure _MG_Graph_optionen_Plottmodus (iGraph.i, iPlottmodus.i, iPlottfrequenz.i, iClearmodus.i, iInterpolation.i = #True)

	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf
	

	; Einstellungen übernehmen und speichern
	MG_aGraph(iGraph, 0, #_MG_a_iPlottfrequenz)								= iPlottfrequenz
	MG_aGraph(iGraph, 0, #_MG_a_iPlottmodus)								= iPlottmodus
	MG_aGraph(iGraph, 0, #_MG_a_iClearmodus)								= iClearmodus
	MG_aGraph(iGraph, 0, #_MG_a_iInterpolation)								= iInterpolation
	

	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_optionen_Plottmodus




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_optionen_Bezugspunkte
; Beschreibung ..: 	ändert die Position der Bezugslinien (absoluter Nullpunkt des Graphen)
; Syntax.........: 	_MG_Graph_optionen_Bezugspunkte (iGraph.i, iY_Linien_farbe_RGBA.i = -1, iY_Linien_breite.i = 1, iX_Bezugs_position.i = 0, iX_Linien_farbe_RGBA.i = -1, iX_Linien_breite.i = 1)
;
; Parameter .....: 	iGraph.i 					- Graph-Index, auf dem sich die Einstellungen beziehen
;                  	iY_Linien_farbe_RGBA.i		- die Farbe als RGBA()-Code (z.B. für Schwarz: RGBA(0, 0, 0, 255))
; 												| -1 verwendet die Standardfarbe (Schwarz)
; 												| >0 RGBA()-Farbcode
;
;                  	iY_Linien_breite.i			- die Linienbreite der vertikalen Bezugslinie (in Pixeln)
;                  	iX_Bezugs_position.i		- die Position des horizontalen Nullpunktes. Der Abstand wird in Pixel angegeben und bezieht sich immer
;												  auf die linke Kante des Graphen. Der Wert kann sowohl positiv, als auch negativ sein.
;                  	iX_Linien_farbe_RGBA.i		- die Farbe als RGBA()-Code (z.B. für Schwarz: RGBA(0, 0, 0, 255))
; 												| -1 verwendet die Standardfarbe (Schwarz)
; 												| >0 RGBA()-Farbcode
;
;					iX_Linien_breite.i			- die Linienbreite der horizontalen Bezugslinie (in Pixeln)
;
; Rückgabewerte .: 	Erfolg 						|  0
;
;                  	Fehler 						| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 						| -2 der Graph wurde deaktiviert
;
; Autor .........: 	SBond
; Bemerkungen ...: 								Alle Werte und Gitterlinien beziehen sich auf die Position der Bezugspunkte.
;												Durch das ändern der Bezugspunkte, kann man also den Inhalt des Graphen verschieben. Die Position der
;												vertikalen Bezugslinie wird durch den angegebenen Wertebereich berechnet und stellt vertikalen Nullpunkt dar.
;												Demzufolge ist die Linie nur sichtbar, wenn im Graphen sowohl der positive, als auch der negative Bereich
;												sichtbar ist (vertikale Achse)
;
;} ========================================================================================================================================================
Procedure _MG_Graph_optionen_Bezugspunkte (iGraph.i, iY_Linien_farbe_RGBA.i = -1, iY_Linien_breite.i = 1, iX_Bezugs_position.i = 0, iX_Linien_farbe_RGBA.i = -1, iX_Linien_breite.i = 1)

	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	
	
	; Standardfarbe verwenden, wenn der Parameter auf '-1" gesetzt wurde
	If (iX_Linien_farbe_RGBA = -1)
		iX_Linien_farbe_RGBA = RGBA(0, 0, 0, 255)
	EndIf
	
	
	; Standardfarbe verwenden, wenn der Parameter auf '-1" gesetzt wurde
	If (iY_Linien_farbe_RGBA = -1)
		iY_Linien_farbe_RGBA = RGBA(0, 0, 0, 255)
	EndIf
	
	
	; Einstellungen übernehmen und speichern
	MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)							= iX_Bezugs_position
	MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_breite)						= iX_Linien_breite	
	MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_farbe_RGBA)					= iX_Linien_farbe_RGBA
	
	MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)							= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) / MG_aGraph(iGraph, 0, #_MG_a_iWertebereich)) * MG_aGraph(iGraph, 0, #_MG_a_iY_max)
	MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_breite)						= iY_Linien_breite
	MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_farbe_RGBA)					= iY_Linien_farbe_RGBA
	
	
	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_optionen_Bezugspunkte




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Kanal_optionen
; Beschreibung ..: 	ändert die Kanal-Einstellungen des Graphen
; Syntax.........: 	_MG_Kanal_optionen (iGraph.i, iKanal.i, iKanal_aktivieren.i = #True, iLinien_Breite.i = 1, iLinien_Farbe_RGBA.i = -1)
;
; Parameter .....: 	iGraph.i 				- Graph-Index, auf dem sich die Einstellungen beziehen
;                  	iKanal.i				- Kanal-Index, auf dem sich die Einstellungen beziehen
;                  	iKanal_aktivieren.i		- aktiviert/deaktiviert die Darstellung des Kanals im Graphen
;											| #True		Kanal aktivieren
;											| #False	Kanal deaktivieren
;
;                  	iLinien_Breite.i		- die Breite der geplotteten Linie (in Pixeln)
;                  	iLinien_Farbe_RGBA.i	- die Farbe als RGBA()-Code (z.B. für Schwarz: RGBA(0, 0, 0, 255))
; 											| -1 verwendet die Standardfarbe (Blau)
; 											| >0 RGBA()-Farbcode
;
; Rückgabewerte .: 	Erfolg 					|  0
;
;                  	Fehler 					| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;											| -2 der Graph wurde deaktiviert
;                  		 					| -3 der Kanal-Index liegt außerhalb des gültigen Bereichs
;
; Autor .........: 	SBond
;
; Bemerkungen ...:	
;
;} ========================================================================================================================================================
Procedure _MG_Kanal_optionen (iGraph.i, iKanal.i, iKanal_aktivieren.i = #True, iLinien_Breite.i = 1, iLinien_Farbe_RGBA.i = -1)

	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf
	
	
	; Fehler, wenn der Kanal-Index außerhalb des gültigen Bereichs liegt
	If (iKanal > #_MG_max_Anzahl_Kanaele) 
		ProcedureReturn (-3)
	EndIf


	; Standardfarbe verwenden, wenn der Parameter auf '-1" gesetzt wurde
	If (iLinien_Farbe_RGBA = -1)
		iLinien_Farbe_RGBA = RGBA (0, 100, 255, 255)
	EndIf
	
	
	; Einstellungen übernehmen und speichern
	MG_aGraph(iGraph, iKanal, #_MG_k_iKanal_aktivieren)						= iKanal_aktivieren
	MG_aGraph(iGraph, iKanal, #_MG_k_iLinien_Breite)						= iLinien_Breite
	MG_aGraph(iGraph, iKanal, #_MG_k_iLinien_Farbe_RGBA)					= iLinien_Farbe_RGBA
	

	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Kanal_optionen




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Hilfslinien_optionen
; Beschreibung ..: 	Einstellungen zum Zeichnen zusätzliche Hilfslinien in den Graphen
; Syntax.........: 	_MG_Hilfslinien_optionen (iGraph.i, iHilfslinie.i, iHilfslinie_aktiviert.i = #True, iTyp.i = 0, iX_Pos.i = 0, iY_Pos.i = 0, iBreite.i = 2, iLaenge.i = -1, iLinien_farbe_RGBA.i = -1)
;
; Parameter .....: 	iGraph.i 					- Graph-Index, auf dem sich die Einstellungen beziehen
;                  	iHilfslinie.i				- Hilfslinien-Index, auf dem sich die Einstellungen beziehen
;                  	iHilfslinie_aktiviert.i		- aktiviert/deaktiviert die Darstellung der Hilfslinie im Graphen
;												| #True		Hilfslinie aktivieren
;												| #False	Hilfslinie deaktivieren
;
;                  	iTyp.i						- die Ausrichtung der Linie
;												| 0  vertikale Linie
;												| 1  horizontale Linie
;   											| 2  beide Linien (erzeugt ein Kreuz)
;
;                  	iX_Pos.i					- die Position der vertikalen Linie auf der X-Achse. Der Abstand wird in Pixel angegeben und bezieht sich immer
;												  auf die linke Kante des Graphen. Die Position der Bezugspunkte hat keinen Einfluss auf die Darstellung.
;                  	iY_Pos.i					- die Position der horizontalen Linie auf der Y-Achse. Der Abstand wird in Pixel angegeben und bezieht sich immer
;												  auf die untere Kante des Graphen. Die Position der Bezugspunkte hat keinen Einfluss auf die Darstellung.
;
;					iBreite.i					- die Linienbreite (in Pixeln)
;					iLaenge.i					- nur bei Typ 2 wirksam: ist die Länge der beiden Linien. Die bezieht sich auf den Punkt, an dem sich beide Linien
;												  Kreuzen. Durch diese Einstellung, kann man die größe des "Kreuzes" festlegen
;												| -1 Standardlänge verwenden (Linienlänge 10 Pixel)
;												| >0 benutzerdefinierte Länge
;
;					iLinien_farbe_RGBA.i		- die Farbe als RGBA()-Code (z.B. für Schwarz: RGBA(0, 0, 0, 255))
; 												| -1 verwendet die Standardfarbe (Grün)
; 												| >0 RGBA()-Farbcode
;
; Rückgabewerte .: 	Erfolg 						|  0
;
;                  	Fehler 						| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 						| -2 der Graph wurde deaktiviert
;												| -3 der Hilfslinien-Index liegt außerhalb des gültigen Bereichs
;
; Autor .........: 	SBond
;
; Bemerkungen ...: 	
;
;} ========================================================================================================================================================
Procedure _MG_Hilfslinien_optionen (iGraph.i, iHilfslinie.i, iHilfslinie_aktiviert.i = #True, iTyp.i = 0, iX_Pos.i = 0, iY_Pos.i = 0, iBreite.i = 2, iLaenge.i = -1, iLinien_farbe_RGBA.i = -1)

	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf


	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	


	; Fehler, wenn der Hilfslinien-Index außerhalb des gültigen Bereichs liegt
	If (iHilfslinie > #_MG_max_Anzahl_Hilfslinien) Or (iHilfslinie < 1)
		ProcedureReturn (-3)
	EndIf
	
	
	; Standardfarbe verwenden, wenn der Parameter auf '-1" gesetzt wurde
	If (iLinien_farbe_RGBA = -1)
		iLinien_farbe_RGBA = RGBA (0, 190, 0, 255)
	EndIf
	
	
	; Standardlänge verwenden, wenn der Parameter auf '-1" gesetzt wurde
	If (iLaenge = -1)
		iLaenge = 10
	EndIf	
	
	
	; Hilfslinienindex berechnen
	iHilfslinie = iHilfslinie + #_MG_Hilfslinien_start - 1
	
	
	; Einstellungen übernehmen und speichern
	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iaktiviert)						= iHilfslinie_aktiviert
	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iTyp)								= iTyp
	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iX_Pos)							= iX_Pos
	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iY_Pos)							= MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - iY_Pos
	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iBreite)							= iBreite
	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iLaenge)							= iLaenge
	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iRGBA_Farbe)						= iLinien_farbe_RGBA	
	

	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Hilfslinien_optionen




;{ #INTERNAL_USE_ONLY# ;===================================================================================================================================
;
; Name...........:	_MG_Graph_plotte_Element
; Beschreibung ..: 	diese Funktion führt in dem aktuellen Ausgabekanal die Zeichenoperationen durch
; Syntax.........: 	_MG_Graph_plotte_Element (iX1.i, iY1.i, iX2.i, iY2.i, iRGBA_Farbe.i, iBreite.i, iModus.i = 0)
;
; Parameter .....: 	iX1.i 			- X-Koordinate (Startposition)
;                  	iY1.i			- Y-Koordinate (Startposition)
;                  	iX2.i			- X-Koordinate (Endposition)
;                  	iY2.i			- Y-Koordinate (Endposition)
;                  	iRGBA_Farbe.i	- die Farbe als RGBA()-Code (z.B. für Schwarz: RGBA(0, 0, 0, 255))
;                  	iBreite.i		- die Breite des Punktes bzw. der Linie
;					iModus.i		- nur wenn iBreite >1:ist Richtung,in der ein ein Punkt oder eine Linie breiter wird
;									|  0 die Breite wächst gleichmäßig in alle Richtungen
;									|  1 die Breite wächst gleichmäßig in vertikaler Richtung. Keine Anpassung in horizontaler Richtung
;									|  2 die Breite wächst gleichmäßig in horizontaler Richtung. Keine Anpassung in vertikaler Richtung
;									|  3 die Breite wächst in horizontaler Richtung nur nach Links hin und keine Anpassung in vertikaler Richtung
;									|  4 die Breite wächst in horizontaler Richtung nur nach Links hin und gleichmäßige Anpassung in vertikaler Richtung
;
; Rückgabewerte .: 	Erfolg 			|  0
;
; Autor .........: 	SBond
;
; Bemerkungen ...: 	 
;
;} ========================================================================================================================================================
Procedure _MG_Graph_plotte_Element (iX1.i, iY1.i, iX2.i, iY2.i, iRGBA_Farbe.i, iBreite.i, iModus.i = 0)
	
	; lokale Variablen deklarieren
	Protected i.i															; allgemeiner Zähler für Schleifen
	
	
	; Linienbreite anpassen, wenn der Parameter ungültig ist
	If (iBreite <= 0) 
		iBreite = 1
	EndIf
	
	
	; plottet die Linie im aktuellen Ausgabekanal mit der Breite: 1
	If (iBreite = 1)
		LineXY (iX1, iY1, iX2, iY2, iRGBA_Farbe)
		
		
	; die Breite wird vertikal und horizontal angepasst
	ElseIf (iBreite > 1) And (iModus = 0)
		
		; die Breite wird zentrisch der Koordinate angepasst
		For i = 1 To iBreite Step 1
			
			; i ist ungerade -> Linie überhalb und rechts der Linienmitte zeichnen
			If (i & 1) <> 0
				LineXY (iX1 + (i/2), iY1, iX2 + (i/2), iY2, iRGBA_Farbe)
				LineXY (iX1, iY1 + (i/2), iX2, iY2 + (i/2), iRGBA_Farbe)
				
			; i ist gerade -> Linie unterhalb und links der Linienmitte zeichnen
			Else
				LineXY (iX1 - (i/2), iY1, iX2 - (i/2), iY2, iRGBA_Farbe)
				LineXY (iX1, iY1 - (i/2), iX2, iY2 - (i/2), iRGBA_Farbe)
			EndIf
			
		Next
		
		
	; die Breite wird nur vertikal angepasst
	ElseIf (iBreite > 1) And (iModus = 1)
		
		; die Breite wird zentrisch der Koordinate angepasst
		For i = 1 To iBreite Step 1
			
			; i ist ungerade -> Linie überhalb der Linienmitte zeichnen
			If (i & 1) <> 0
				LineXY (iX1, iY1 + (i/2), iX2, iY2 + (i/2), iRGBA_Farbe)
				
			; i ist gerade -> Linie unterhalb der Linienmitte zeichnen
			Else
				LineXY (iX1, iY1 - (i/2), iX2, iY2 - (i/2), iRGBA_Farbe)
			EndIf
			
		Next
		
		
	; die Breite wird nur horizontal angepasst
	ElseIf (iBreite > 1) And (iModus = 2)
		
		; die Breite wird zentrisch der Koordinate angepasst
		For i = 1 To iBreite Step 1
			
			; i ist ungerade -> Linie rechts der Linienmitte zeichnen
			If (i & 1) <> 0
				LineXY (iX1 + (i/2), iY1, iX2 + (i/2), iY2, iRGBA_Farbe)
				
			; i ist gerade -> Linie links der Linienmitte zeichnen
			Else
				LineXY (iX1 - (i/2), iY1, iX2 - (i/2), iY2, iRGBA_Farbe)
			EndIf
			
		Next
		
		
	; die Breite wird nur horizontal angepasst
	ElseIf (iBreite > 1) And (iModus = 3)
		
		; die Breite wird nach links hin dicker gezeichnet
		For i = 1 To iBreite Step 1
			
			LineXY (iX1 - i, iY1, iX2 - i, iY2, iRGBA_Farbe)

		Next	
		
		
	; die Breite wird vertikal und horizontal angepasst
	ElseIf (iBreite > 1) And (iModus = 4)
		
		; die horizontale Breite nach links hin dicker gezeichnet und die vertikale Breite wird zentrisch der Koordinate angepasst
		For i = 1 To iBreite Step 1
			
			; i ist ungerade -> Linie überhalb der Linienmitte zeichnen
			If (i & 1) <> 0
				LineXY (iX1, iY1 + (i/2), iX2, iY2 + (i/2), iRGBA_Farbe)
				
			; i ist gerade -> Linie unterhalb der Linienmitte zeichnen
			Else
				LineXY (iX1, iY1 - (i/2), iX2, iY2 - (i/2), iRGBA_Farbe)
			EndIf
			
			LineXY (iX1 - i, iY1, iX2 - i, iY2, iRGBA_Farbe)
			
		Next
	EndIf
	
	
	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_plotte_Element




;{ #INTERNAL_USE_ONLY# ;===================================================================================================================================
;
; Name...........:	_MG_Graph_plotte_Hilfslinien
; Beschreibung ..: 	plottet die Hilfslinien in den Graphen
; Syntax.........: 	_MG_Graph_plotte_Hilfslinien (iGraph.i)
;
; Parameter .....: 	iGraph.i 		- Graph-Index, auf dem sich die Einstellungen beziehen
;
; Rückgabewerte .: 	Erfolg 			|  0
;
;                  	Fehler 			| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 			| -2 der Graph wurde deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...: 	
;
;} ========================================================================================================================================================
Procedure _MG_Graph_plotte_Hilfslinien (iGraph.i)
	
	; lokale Variablen deklarieren
	Protected iHilfslinie.i													; Index der verwendeten Hilfslinie
	Protected iHilfslinie_aktiviert.i										; Status, ob die jeweilige Hilfslinie aktiviert/deaktiviert ist
	Protected iTyp.i														; Typ 0: vertikale Linie;   Typ 1: horizontale Linie;   Typ 2: beide Linien (Kreuz)
	Protected iX_Pos.i														; X-Position der vertikalen Linie
	Protected iY_Pos.i														; Y-Position der horizontalen Linie
	Protected iBreite.i														; die Dicke der Hilfslinie
	Protected iLaenge.i														; nur bei Typ 2: die Länge der Linien (Kreuzgröße)
	Protected iRGBA_Farbe.i													; die Farbe der Hilfslinie (RGBA)

	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf
	
	
	; Variablen initialisieren
	For iHilfslinie = #_MG_Hilfslinien_start To (#_MG_Hilfslinien_start + #_MG_max_Anzahl_Hilfslinien - 1) Step 1

		iHilfslinie_aktiviert	=	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iaktiviert)
		iTyp					=	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iTyp)
		iX_Pos					=	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iX_Pos)
		iY_Pos					=	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iY_Pos)
		iBreite					=	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iBreite)
		iLaenge					=	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iLaenge)
		iRGBA_Farbe				=	MG_aGraph(iGraph, iHilfslinie, #_MG_L_iRGBA_Farbe)
		
		
		; Hilfslinie plotten
		If (iHilfslinie_aktiviert = #True)
			
			; Typ 0: vertikale Linie
			If (iTyp = 0)

				_MG_Graph_plotte_Element (iX_Pos, 0, iX_Pos, MG_aGraph(iGraph, 0, #_MG_a_iHoehe), iRGBA_Farbe, iBreite, 2)
				
				
			; Typ 1: horizontale Linie	
			ElseIf (iTyp = 1)
				
				_MG_Graph_plotte_Element (0, iY_Pos, MG_aGraph(iGraph, 0, #_MG_a_iBreite), iY_Pos, iRGBA_Farbe, iBreite, 1)
				
				
			; Typ 2: beide Linien	
			ElseIf (iTyp = 2)	
				
				_MG_Graph_plotte_Element (iX_Pos, iY_Pos - (iLaenge/2), iX_Pos, iY_Pos + (iLaenge/2), iRGBA_Farbe, iBreite, 2)
				_MG_Graph_plotte_Element (iX_Pos - (iLaenge/2), iY_Pos, iX_Pos + (iLaenge/2), iY_Pos, iRGBA_Farbe, iBreite, 1)
				
			EndIf
			
		EndIf
		
	Next

	
	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_plotte_Hilfslinien




;{ #INTERNAL_USE_ONLY# ;===================================================================================================================================
;
; Name...........:	_MG_Graph_plotte_Bezugslinien
; Beschreibung ..: 	plottet die Bezugslinien in den Graphen
; Syntax.........: 	_MG_Graph_plotte_Bezugslinien (iGraph.i)
;
; Parameter .....: 	iGraph.i 		- Graph-Index, auf dem sich die Einstellungen beziehen
;
; Rückgabewerte .: 	Erfolg 			|  0
;
;                  	Fehler 			| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 			| -2 der Graph wurde deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...: 	
;
;} ========================================================================================================================================================
Procedure _MG_Graph_plotte_Bezugslinien (iGraph.i)
	
	; lokale Variablen deklarieren
	Protected i.i															; allgemeiner Zähler für Schleifen										
	Protected X1.i															; X-Position (start)
	Protected Y1.i															; Y-Position (start)
	Protected X2.i															; X-Position (ende)
	Protected Y2.i															; Y-Position (ende)
	Protected Farbe.i														; RGBA-Farbe der jeweiligen Linie
	Protected Breite.i														; die Breite der Linie
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf
	
	
	; den Ausgabekanal für die aktuellen Zeichenoperationen setzen
	If (MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) <> #True)
		
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) = #True
		
		StopDrawing()
		StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		
	EndIf
	
	DrawingMode(#PB_2DDrawing_AlphaBlend)	
	
	
	
	; die hozizontale Bezugslinie plotten
	X1		= 0
	Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)
	X2		= MG_aGraph(iGraph, 0, #_MG_a_iBreite)
	Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)
	
	Farbe	= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_farbe_RGBA)
	Breite	= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_breite)
	
	_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)
	

	
	; die vertikale Bezugslinie plotten, sofern der Plottmodus: "stehender Graph" eingestellt ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iPlottmodus) <> 1)
		
		X1		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)
		Y1		= 0
		X2		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)
		Y2		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)
		
		Farbe	= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_farbe_RGBA)
		Breite	= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_breite)
		
		_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 2)
		
	EndIf
	

	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_plotte_Bezugslinien




;{ #INTERNAL_USE_ONLY# ;===================================================================================================================================
;
; Name...........:	_MG_Graph_plotte_Hauptgitterlinien
; Beschreibung ..:  zeichnet die Hauptgitterlinien in den Graphen ein
; Syntax.........:  _MG_Graph_plotte_Hauptgitterlinien (iGraph.i, iModus.i = 0)
;
; Parameter .....: 	iGraph.i 	- Graph-Index, auf dem sich die Einstellungen beziehen
;					iModus.i	- zeichnet die Hauptgitterlinien in bestimmten Bereichen ein
;								|  0 zeichnet die Hauptgitterlinien in den gesamten Zeichenbereich des Graphen
;								|  1 zeichnet die Hauptgitterlinien nur an der aktuellen Plottposition des Graphen
;								|  2 zeichnet die Hauptgitterlinien nur an der letzen Plottposition des Graphen (für den Modus: "bewegter Graph")
;
; Rückgabewerte .: 	Erfolg 		|  0
;
;                  	Fehler 		| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 		| -2 der Graph wurde deaktiviert
;                  		 		| -3 er horizontale Hauptgitterabstand wurde zu klein gewählt
;                  		 		| -4 er vertikale Hauptgitterabstand wurde zu klein gewählt
;                  		 		| -5 die Hauptgitterlinien wurden deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...:
;
;} ========================================================================================================================================================
Procedure _MG_Graph_plotte_Hauptgitterlinien (iGraph.i, iModus.i = 0)
	
	; lokale Variablen deklarieren
	Protected i.i															; allgemeiner Zähler für Schleifen
	Protected X1.i															; X-Position (start)
	Protected Y1.i															; Y-Position (start)
	Protected X2.i															; X-Position (ende)
	Protected Y2.i															; Y-Position (ende)
	Protected Farbe.i														; RGBA-Farbe der jeweiligen Hauptgitterlinie
	Protected Breite.i														; die Breite der Hauptgitterlinie
	Protected iLinien_ueber_x_null.i										; die Anzahl der Hauptgitterlinien über horizontal Null
	Protected iLinien_unter_x_null.i										; die Anzahl der Hauptgitterlinien unter horizontal Null
	Protected iLinien_ueber_y_null.i										; die Anzahl der Hauptgitterlinien über vertikal Null
	Protected iLinien_unter_y_null.i										; die Anzahl der Hauptgitterlinien unter vertikal Null
	
	Protected fmax_anzahl_vertikal_linien.f									; die max. Anzahl der sichtbaren Hilfsgitterlinien (vertikal)
	Protected fmax_anzahl_horizontal_linien.f								; die max. Anzahl der sichtbaren Hilfsgitterlinien (horizontal)
	Protected fPos_erste_Linie_ueber_x_null.f								; die berechnete Position der ersten horizontalen Hauptgitterlinie über Null
	Protected fPos_erste_Linie_unter_x_null.f								; die berechnete Position der ersten horizontalen Hauptgitterlinie unter Null
	Protected fPos_erste_Linie_ueber_y_null.f								; die berechnete Position der ersten vertikalen Hauptgitterlinie über Null
	Protected fPos_erste_Linie_unter_y_null.f								; die berechnete Position der ersten vertikalen Hauptgitterlinie unter Null
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	

	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	

	; Fehler, wenn der horizontale Hauptgitterabstand zu klein gewählt wurde
	If (MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X) < 1) 
		ProcedureReturn (-3)
	EndIf
	
	
	; Fehler, wenn der vertikale Hauptgitterabstand zu klein gewählt wurde
	If (MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y) < 1) 
		ProcedureReturn (-4)
	EndIf
	
	
	; Fehler, wenn die Hauptgitterlinien deaktiviert sind
	If (MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_aktiviert) = #False) 
		ProcedureReturn (-5)
	EndIf
	
	
	; den Ausgabekanal für die aktuellen Zeichenoperationen setzen
	If (MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) <> #True)
		
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) = #True
		
		StopDrawing()
		StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		
	EndIf
	
	DrawingMode(#PB_2DDrawing_AlphaBlend)
	
	
	; setzt die eingestellte Farbe und Linienbreite
	Farbe	= MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_farbe_RGBA)
	Breite	= MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_breite)
	
	; berechnet die Anzahl der vertikalen Linien
	iLinien_unter_x_null = Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X)))
	iLinien_ueber_x_null = Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)  - MG_aGraph(iGraph, 0, #_MG_a_iBreite)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X)))
	
	; berechnet die Anzahl der horizontalen Linien
	iLinien_ueber_y_null = Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)))
	iLinien_unter_y_null = Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)  - MG_aGraph(iGraph, 0, #_MG_a_iHoehe)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)))			
	
	; berechnet die Gesamtanzahl der Linien, die maximal dargestellt werden können
	fmax_anzahl_vertikal_linien		= MG_aGraph(iGraph, 0, #_MG_a_iBreite) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X)
	fmax_anzahl_horizontal_linien	= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)  / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)
	
	
	; Nulllinie ist rechts außerhalb des Graphen -> nur der negative X-Bereich ist sichtbar
	If (MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) > MG_aGraph(iGraph, 0, #_MG_a_iBreite)) 
		iLinien_ueber_x_null = 0	
		
	; Nulllinie ist links außerhalb des Graphen -> nur der positive X-Bereich ist sichtbar
	ElseIf (MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) < 0)
		iLinien_unter_x_null = 0
		
	EndIf
	
	
	; Nulllinie ist unterhalb des Graphen -> nur der positive Y-Bereich ist sichtbar
	If (MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) > MG_aGraph(iGraph, 0, #_MG_a_iHoehe)) 
		iLinien_unter_y_null = 0	
		
	; Nulllinie ist oberhalb des Graphen -> nur der negative Y-Bereich ist sichtbar
	ElseIf (MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) < 0)
		iLinien_ueber_y_null = 0
		
	EndIf
	
	
	; berechnet die Position der ersten vertikalen Linien
	fPos_erste_Linie_ueber_x_null = iLinien_ueber_x_null - fmax_anzahl_vertikal_linien + iLinien_unter_x_null + 1
	fPos_erste_Linie_unter_x_null = iLinien_unter_x_null - fmax_anzahl_vertikal_linien + iLinien_ueber_x_null + 1
	
	; berechnet die Position der ersten horizontalen Linien
	fPos_erste_Linie_ueber_y_null = iLinien_ueber_y_null - fmax_anzahl_horizontal_linien + iLinien_unter_y_null + 1
	fPos_erste_Linie_unter_y_null = iLinien_unter_y_null - fmax_anzahl_horizontal_linien + iLinien_ueber_y_null + 1

	
	
	
	;#################################################################################################################################################
	;#################################   zeichnet die Hauptgitterlinien in den gesamten Zeichenbereich des Graphen   #################################
	;#################################################################################################################################################
	If (iModus = 0) 

		; zeichnet die vertikalen Hauptgitterlinien über Null ein
		For i = fPos_erste_Linie_ueber_x_null To iLinien_ueber_x_null Step 1
			
			X1		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))	
			Y1		= 0
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)

			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 2)		
			
		Next
		
		
		; zeichnet die vertikalen Hauptgitterlinien unter Null ein
		For i = fPos_erste_Linie_unter_x_null To iLinien_unter_x_null Step 1

			X1		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))
			Y1		= 0
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)
			
			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 2)	

		Next


		; zeichnet die horizontalen Hauptgitterlinien über Null ein
		For i = fPos_erste_Linie_ueber_y_null To iLinien_ueber_y_null Step 1

			X1		= 0
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iBreite)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
		
			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	

		Next
		
		
		; zeichnet die horizontalen Hauptgitterlinien unter Null ein
		For i = fPos_erste_Linie_unter_y_null To iLinien_unter_y_null Step 1
			
			X1		= 0
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iBreite)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))

			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	

		Next
		
		
		
		
	;#################################################################################################################################################
	;###############################   zeichnet die Hauptgitterlinien nur an der aktuellen Plottposition des Graphen   ###############################
	;#################################################################################################################################################
	ElseIf (iModus = 1) 

		; zeichnet die vertikalen Hauptgitterlinien über Null ein
		For i = fPos_erste_Linie_ueber_x_null To iLinien_ueber_x_null Step 1
			
			X1		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))	
			Y1		= 0
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)
			
			; plotten, wenn die Linie im richtigen Bereich ist
			If (X1 >= MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker)) And (X1 < MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell))

				_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 2)	
				
			EndIf
			
		Next
		
		
		; zeichnet die vertikalen Hauptgitterlinien unter Null ein
		For i = fPos_erste_Linie_unter_x_null To iLinien_unter_x_null Step 1

			X1		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))
			Y1		= 0
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)
			
			; plotten, wenn die Linie im richtigen Bereich ist
			If (X1 >= MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker)) And (X1 < MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell))

				_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 2)	
				
			EndIf

		Next


		; zeichnet die horizontalen Hauptgitterlinien über Null ein
		For i = fPos_erste_Linie_ueber_y_null To iLinien_ueber_y_null Step 1

			X1		= MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker)
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
		
			; plotten, wenn die Linie im richtigen Bereich ist
			If (MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker) < MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell))

				_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	
				
			EndIf

		Next
		
		
		; zeichnet die horizontalen Hauptgitterlinien unter Null ein
		For i = fPos_erste_Linie_unter_y_null To iLinien_unter_y_null Step 1
			
			X1		= MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker)
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))

			; plotten, wenn die Linie im richtigen Bereich ist
			If (MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker) < MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell))

				_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	
				
			EndIf

		Next
	
		MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker) = MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell)
		
		
		
		
	;#################################################################################################################################################
	;###############   zeichnet die Hauptgitterlinien nur an der letzen Plottposition des Graphen (für den Modus: "bewegter Graph")   ################
	;#################################################################################################################################################
	ElseIf (iModus = 2) 

		; zeichnet die vertikalen Hauptgitterlinien ein
		While (MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker) >= MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))
			
			X1		= MG_aGraph(iGraph, 0, #_MG_a_iBreite) - (1 + MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker) - MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))
			Y1		= 0
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iBreite) - (1 + MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker) - MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)

			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 3)		
			
			MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker) - MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X)
			
		Wend
		
		MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_Merker) + MG_aGraph(iGraph, 0, #_MG_a_iBreite) - MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung)
		
		
		
		; zeichnet die horizontalen Hauptgitterlinien über Null ein
		For i = fPos_erste_Linie_ueber_y_null To iLinien_ueber_y_null Step 1

			X1		= MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung)
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iBreite)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
		
			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	

		Next
		
		
		; zeichnet die horizontalen Hauptgitterlinien unter Null ein
		For i = fPos_erste_Linie_unter_y_null To iLinien_unter_y_null Step 1
			
			X1		= MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung)
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iBreite)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))

			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	

		Next
	
	EndIf
	
	
	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_plotte_Hauptgitterlinien




;{ #INTERNAL_USE_ONLY# ;===================================================================================================================================
;
; Name...........:	_MG_Graph_plotte_Hilfsgitterlinien
; Beschreibung ..:  zeichnet die Hilfsgitterlinien in den Graphen ein
; Syntax.........:  _MG_Graph_plotte_Hilfsgitterlinien (iGraph.i, iModus.i = 0)
;
; Parameter .....: 	iGraph.i 	- Graph-Index, auf dem sich die Einstellungen beziehen
;					iModus.i	- zeichnet die Hilfsgitterlinien in bestimmten Bereichen ein
;								|  0	zeichnet die Hilfsgitterlinien in den gesamten Zeichenbereich des Graphen
;								|  1 zeichnet die Hilfsgitterlinien nur an der aktuellen Plottposition des Graphen
;								|  2 zeichnet die Hilfsgitterlinien nur an der letzen Plottposition des Graphen (für den Modus: "bewegter Graph")
;
; Rückgabewerte .: 	Erfolg 		|  0
;
;                  	Fehler 		| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;                  		 		| -2 der Graph wurde deaktiviert
;                  		 		| -3 er horizontale Hilfsgitterabstand wurde zu klein gewählt
;                  		 		| -4 er vertikale Hilfsgitterabstand wurde zu klein gewählt
;                  		 		| -5 die Hilfsgitterlinien wurden deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...:
;
;} ========================================================================================================================================================
Procedure _MG_Graph_plotte_Hilfsgitterlinien (iGraph.i, iModus.i = 0)
	
	; lokale Variablen deklarieren
	Protected i.i															; allgemeiner Zähler für Schleifen
	Protected X1.i															; X-Position (start)
	Protected Y1.i															; Y-Position (start)
	Protected X2.i															; X-Position (ende)
	Protected Y2.i															; Y-Position (ende)
	Protected Farbe.i														; RGBA-Farbe der jeweiligen Hilfsgitterlinie
	Protected Breite.i														; die Breite der Hilfsgitterlinie
	Protected iLinien_ueber_x_null.i										; die Anzahl der Hilfsgitterlinien über horizontal Null
	Protected iLinien_unter_x_null.i										; die Anzahl der Hilfsgitterlinien unter horizontal Null
	Protected iLinien_ueber_y_null.i										; die Anzahl der Hilfsgitterlinien über vertikal Null
	Protected iLinien_unter_y_null.i										; die Anzahl der Hilfsgitterlinien unter vertikal Null
	
	Protected fmax_anzahl_vertikal_linien.f									; die max. Anzahl der sichtbaren Hilfsgitterlinien (vertikal)
	Protected fmax_anzahl_horizontal_linien.f								; die max. Anzahl der sichtbaren Hilfsgitterlinien (horizontal)
	Protected fPos_erste_Linie_ueber_x_null.f								; die berechnete Position der ersten horizontalen Hilfsgitterlinie über Null
	Protected fPos_erste_Linie_unter_x_null.f								; die berechnete Position der ersten horizontalen Hilfsgitterlinie unter Null
	Protected fPos_erste_Linie_ueber_y_null.f								; die berechnete Position der ersten vertikalen Hilfsgitterlinie über Null
	Protected fPos_erste_Linie_unter_y_null.f								; die berechnete Position der ersten vertikalen Hilfsgitterlinie unter Null
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	

	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	

	; Fehler, wenn der horizontale Hilfsgitterabstand zu klein gewählt wurde
	If (MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X) < 1) 
		ProcedureReturn (-3)
	EndIf
	
	
	; Fehler, wenn der vertikale Hilfsgitterabstand zu klein gewählt wurde
	If (MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y) < 1) 
		ProcedureReturn (-4)
	EndIf
	
	
	; Fehler, wenn die Hilfsgitterlinien deaktiviert sind
	If (MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_aktiviert) = #False) 
		ProcedureReturn (-5)
	EndIf
	
	
	; den Ausgabekanal für die aktuellen Zeichenoperationen setzen
	If (MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) <> #True)
		
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) = #True
		
		StopDrawing()
		StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		
	EndIf
	
	DrawingMode(#PB_2DDrawing_AlphaBlend)
	
	
	; setzt die eingestellte Farbe und Linienbreite
	Farbe	= MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_farbe_RGBA)
	Breite	= MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_breite)
	
	; berechnet die Anzahl der vertikalen Linien
	iLinien_unter_x_null = Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)) / MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X)))
	iLinien_ueber_x_null = Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)  - MG_aGraph(iGraph, 0, #_MG_a_iBreite)) / MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X)))
	
	; berechnet die Anzahl der horizontalen Linien
	iLinien_ueber_y_null = Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) / MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y)))
	iLinien_unter_y_null = Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)  - MG_aGraph(iGraph, 0, #_MG_a_iHoehe)) / MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y)))			
	
	; berechnet die Gesamtanzahl der Linien, die maximal dargestellt werden können
	fmax_anzahl_vertikal_linien		= MG_aGraph(iGraph, 0, #_MG_a_iBreite) / MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X)
	fmax_anzahl_horizontal_linien	= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)  / MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y)
	
	
	; Nulllinie ist rechts außerhalb des Graphen -> nur der negative X-Bereich ist sichtbar
	If (MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) > MG_aGraph(iGraph, 0, #_MG_a_iBreite)) 
		iLinien_ueber_x_null = 0	
		
	; Nulllinie ist links außerhalb des Graphen -> nur der positive X-Bereich ist sichtbar
	ElseIf (MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) < 0)
		iLinien_unter_x_null = 0
		
	EndIf
	
	
	; Nulllinie ist unterhalb des Graphen -> nur der positive Y-Bereich ist sichtbar
	If (MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) > MG_aGraph(iGraph, 0, #_MG_a_iHoehe)) 
		iLinien_unter_y_null = 0	
		
	; Nulllinie ist oberhalb des Graphen -> nur der negative Y-Bereich ist sichtbar
	ElseIf (MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) < 0)
		iLinien_ueber_y_null = 0
		
	EndIf
	
	
	; berechnet die Position der ersten vertikalen Linien
	fPos_erste_Linie_ueber_x_null = iLinien_ueber_x_null - fmax_anzahl_vertikal_linien + iLinien_unter_x_null + 1
	fPos_erste_Linie_unter_x_null = iLinien_unter_x_null - fmax_anzahl_vertikal_linien + iLinien_ueber_x_null + 1
	
	; berechnet die Position der ersten horizontalen Linien
	fPos_erste_Linie_ueber_y_null = iLinien_ueber_y_null - fmax_anzahl_horizontal_linien + iLinien_unter_y_null + 1
	fPos_erste_Linie_unter_y_null = iLinien_unter_y_null - fmax_anzahl_horizontal_linien + iLinien_ueber_y_null + 1

	
	
	
	;#################################################################################################################################################
	;#################################   zeichnet die Hilfsgitterlinien in den gesamten Zeichenbereich des Graphen   #################################
	;#################################################################################################################################################
	If (iModus = 0) 

		; zeichnet die vertikalen Hilfsgitterlinien über Null ein
		For i = fPos_erste_Linie_ueber_x_null To iLinien_ueber_x_null Step 1
			
			X1		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X))	
			Y1		= 0
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X))
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)

			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 2)		
			
		Next
		
		
		; zeichnet die vertikalen Hilfsgitterlinien unter Null ein
		For i = fPos_erste_Linie_unter_x_null To iLinien_unter_x_null Step 1

			X1		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X))
			Y1		= 0
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X))
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)
			
			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 2)	

		Next


		; zeichnet die horizontalen Hilfsgitterlinien über Null ein
		For i = fPos_erste_Linie_ueber_y_null To iLinien_ueber_y_null Step 1

			X1		= 0
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iBreite)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))
		
			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	

		Next
		
		
		; zeichnet die horizontalen Hilfsgitterlinien unter Null ein
		For i = fPos_erste_Linie_unter_y_null To iLinien_unter_y_null Step 1
			
			X1		= 0
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iBreite)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))

			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	

		Next
		
		
		
		
	;#################################################################################################################################################
	;###############################   zeichnet die Hilfsgitterlinien nur an der aktuellen Plottposition des Graphen   ###############################
	;#################################################################################################################################################
	ElseIf (iModus = 1) 

		; zeichnet die vertikalen Hilfsgitterlinien über Null ein
		For i = fPos_erste_Linie_ueber_x_null To iLinien_ueber_x_null Step 1
			
			X1		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X))	
			Y1		= 0
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X))
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)
			
			; plotten, wenn die Linie im richtigen Bereich ist
			If (X1 >= MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker)) And (X1 < MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell))

				_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 2)	
				
			EndIf
			
		Next
		
		
		; zeichnet die vertikalen Hilfsgitterlinien unter Null ein
		For i = fPos_erste_Linie_unter_x_null To iLinien_unter_x_null Step 1

			X1		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X))
			Y1		= 0
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X))
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)
			
			; plotten, wenn die Linie im richtigen Bereich ist
			If (X1 >= MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker)) And (X1 < MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell))

				_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 2)	
				
			EndIf

		Next


		; zeichnet die horizontalen Hilfsgitterlinien über Null ein
		For i = fPos_erste_Linie_ueber_y_null To iLinien_ueber_y_null Step 1

			X1		= MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker)
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))
		
			; plotten, wenn die Linie im richtigen Bereich ist
			If (MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker) < MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell))

				_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	
				
			EndIf

		Next
		
		
		; zeichnet die horizontalen Hilfsgitterlinien unter Null ein
		For i = fPos_erste_Linie_unter_y_null To iLinien_unter_y_null Step 1
			
			X1		= MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker)
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))

			; plotten, wenn die Linie im richtigen Bereich ist
			If (MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker) < MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell))

				_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	
				
			EndIf

		Next
	
		MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker) = MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell)
		
		
		
		
	;#################################################################################################################################################
	;###############   zeichnet die Hilfsgitterlinien nur an der letzen Plottposition des Graphen (für den Modus: "bewegter Graph")   ################
	;#################################################################################################################################################
	ElseIf (iModus = 2) 

		; zeichnet die vertikalen Hilfsgitterlinien ein
		While (MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker) >= MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X))
			
			X1		= MG_aGraph(iGraph, 0, #_MG_a_iBreite) - (1 + MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker) - MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X))
			Y1		= 0
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iBreite) - (1 + MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker) - MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X))
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)

			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 3)		
			
			MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker) - MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_X)
			
		Wend
		
		MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_Merker) + MG_aGraph(iGraph, 0, #_MG_a_iBreite) - MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung)
		
		
		
		; zeichnet die horizontalen Hilfsgitterlinien über Null ein
		For i = fPos_erste_Linie_ueber_y_null To iLinien_ueber_y_null Step 1

			X1		= MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung)
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iBreite)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))
		
			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	

		Next
		
		
		; zeichnet die horizontalen Hilfsgitterlinien unter Null ein
		For i = fPos_erste_Linie_unter_y_null To iLinien_unter_y_null Step 1
			
			X1		= MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung)
			Y1		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))
			X2		= MG_aGraph(iGraph, 0, #_MG_a_iBreite)
			Y2		= MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) + (i * MG_aGraph(iGraph, 0, #_MG_a_iHilfsgitter_abstand_Y))

			_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 1)	

		Next
	
	EndIf
	
	
	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_plotte_Hilfsgitterlinien




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_plotte_Werte
; Beschreibung ..: 	plottet die neuen Werte in den Graphen und aktualisiert ggf. die Darstellung in der GUI (je nach Einstellungen)
; Syntax.........:  _MG_Graph_plotte_Werte (iGraph.i)
;
; Parameter .....: 	iGraph.i 	- Graph-Index, auf dem sich die Einstellungen beziehen
;
; Rückgabewerte .: 	Erfolg 		| >=0 gibt die aktuelle Plottposition zurück (max. Wert = Breite des Graphen)
;
;                  	Fehler 		| -1  der Graph-Index liegt außerhalb des gültigen Bereichs
;								| -2  der Graph ist deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...:
;
;} ========================================================================================================================================================
Procedure _MG_Graph_plotte_Werte (iGraph.i)
	
	; lokale Variablen deklarieren
	Protected i.i															; allgemeiner Zähler für Schleifen										
	Protected X1.i															; X-Position (start)
	Protected Y1.i															; Y-Position (start)
	Protected X2.i															; X-Position (ende)
	Protected Y2.i															; Y-Position (ende)
	Protected Farbe.i														; RGBA-Farbe der jeweiligen Linie
	Protected Breite.i														; die Breite der Linie	
	Protected iKanal.i														; Index des aktuellen Kanals, der geplottet wird
	Protected iClear_X_Pos.i												; Clear-Modus 1: X-Position der Bereichslöschung
	Protected iClear_breite.i												; Clear-Modus 1: Breite der Bereichslöschung
	
	Protected hQuelle.i														; handle des Quellbildes, das "bewegt" werden soll (kopiert einen Bereich in das Zielbild)
	Protected hZiel.i														; handle des Zielbildes, das "bewegt" werden soll
	Protected iX_Pos.i														; X-Koordinate des Kopierbereiches (linke, obere Ecke)
	Protected iY_Pos.i														; Y-Koordinate des Kopierbereiches (linke, obere Ecke)
	Protected dBreite.d														; Breite der Kopierbereiches
	Protected iHoehe.i														; Höhe der Kopierbereiches	
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf
	
	
	; den Ausgabekanal für die aktuellen Zeichenoperationen setzen
	If (MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) <> #True)

		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) = #True
		
		StopDrawing()
		StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		
	EndIf
	
	DrawingMode(#PB_2DDrawing_AlphaBlend)
	
	
	
	
	;#################################################################################################################################################
	;######################################################   Plottmodus 0: "stehender Graph"   ######################################################
	;#################################################################################################################################################
	If (MG_aGraph(iGraph, 0, #_MG_a_iPlottmodus) = 0)


		; Wenn Clearmodus = 1:  löscht an der aktuellen Plottposition die alten Werte aus dem Graphen, bevor die neuen Werte geplottet werden
		If (MG_aGraph(iGraph, 0, #_MG_a_iClearmodus) = 1)
			
			
			; den Löschbereich definieren
			iClear_X_Pos 		= MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) + 2
			iClear_breite 		= MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse) + 2


			; den Löschbereich neu definieren, wenn sich die aktuelle Plottposition am Anfang des Graphen befindet
			If (MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) <= 2)
				iClear_X_Pos 		= MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) - 1
				iClear_breite 		= MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse) + 4
			EndIf


			; löschen der alten geplotteten Werte im Löschbereich
			DrawingMode(#PB_2DDrawing_Default )
			Box(iClear_X_Pos, 0, iClear_breite, MG_aGraph(iGraph, 0, #_MG_a_iHoehe), MG_aGraph(iGraph, 0, #_MG_a_iHintergrundfarbe_RGB))
			
			
			; Gitterlinien im Löschbereich neu zeichnen
			DrawingMode(#PB_2DDrawing_AlphaBlend)
			_MG_Graph_plotte_Hauptgitterlinien(iGraph, 1)
			_MG_Graph_plotte_Hilfsgitterlinien(iGraph, 1)
			_MG_Graph_plotte_Bezugslinien(iGraph)
			_MG_Graph_plotte_Hilfslinien(iGraph)

		EndIf
		
		

		; die Werte der einzelnen Kanäle plotten
		For iKanal = 1 To #_MG_max_Anzahl_Kanaele Step 1


			; prüfen, welche Kanäle geplottet werden sollen
			If (MG_aGraph(iGraph, iKanal, #_MG_k_iKanal_aktivieren) = #True)
				
				
				; setzt die eingestellte Farbe und Linienbreite
				Breite	= MG_aGraph(iGraph, iKanal, #_MG_k_iLinien_Breite)
				Farbe	= MG_aGraph(iGraph, iKanal, #_MG_k_iLinien_Farbe_RGBA)
				
			
				; Werte plotten (interpoliert)
				If (MG_aGraph(iGraph, 0, #_MG_a_iInterpolation) = #True)
								
					; direkte Linie zwischen den Punkten zeichnen
					X1	= MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) - MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse)
					Y1	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert)
					X2	= MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell)
					Y2	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_aktueller_Wert)
					
					_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite)

					
				Else ; Werte plotten (nicht interpoliert)
					
					
					; die horizontale Linie zeichen
					X1	= MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) - MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse)
					Y1	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert)
					X2	= MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell)
					Y2	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert)

					_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite)


 					; die vertikale Linie zeichen
					X1	= MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell)
					Y1	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert)
					X2	= MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell)
					Y2	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_aktueller_Wert)

					_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite)

				EndIf
				
				; aktuellen Punkt für den nächsten Plottvorgang speichern
				MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert) = MG_aGraph(iGraph, iKanal, #_MG_k_fY_aktueller_Wert)

			EndIf

		Next


		; ggf. die geplotteten Werte in der GUI darstellen (Einstellung: Plottfrequenz)
		If (MG_aGraph(iGraph, 0, #_MG_a_iPlottfrequenz) > 0)
			
			If (MG_aGraph(iGraph, 0, #_MG_a_iPlott_Counter) >= MG_aGraph(iGraph, 0, #_MG_a_iPlottfrequenz))
			
				StopDrawing()
				SetGadgetState(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer), ImageID(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
				StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
				MG_aGraph(iGraph, 0, #_MG_a_iPlott_Counter) = 0

			Else

				MG_aGraph(iGraph, 0, #_MG_a_iPlott_Counter) + 1

			EndIf

		EndIf


		; die geplotteten Werte in der GUI darstellen und die Plottposition wieder auf Null setzen, sobald der Zeichenbereich komplett ist
		If (MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) > MG_aGraph(iGraph, 0, #_MG_a_iBreite))

			MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) = 0

				StopDrawing()
				SetGadgetState(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer), ImageID(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
				StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
					
			; Wenn Clearmodus = 2:  löscht alle geplotteten Werte aus dem Buffer
			If (MG_aGraph(iGraph, 0, #_MG_a_iClearmodus) = 2)
				
				; Zeichenbereich leeren
				DrawingMode(#PB_2DDrawing_Default )
				Box(0, 0, MG_aGraph(iGraph, 0, #_MG_a_iBreite), MG_aGraph(iGraph, 0, #_MG_a_iHoehe), MG_aGraph(iGraph, 0, #_MG_a_iHintergrundfarbe_RGB))	
				
				DrawingMode(#PB_2DDrawing_AlphaBlend)
				_MG_Graph_plotte_Hauptgitterlinien (iGraph, 0)
				_MG_Graph_plotte_Hilfsgitterlinien (iGraph, 0)
				_MG_Graph_plotte_Bezugslinien(iGraph)
				_MG_Graph_plotte_Hilfslinien(iGraph)

			EndIf
			
			
			; die alten Werte der Kanäle löschen
			For iKanal = 1 To #_MG_max_Anzahl_Kanaele Step 1

				; prüfen, welche Kanäle aktiviert sind
				If (MG_aGraph(iGraph, iKanal, #_MG_k_iKanal_aktivieren) = #True)
					MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert) = 0
				EndIf

			Next

			
			
		Else ; ...ansonsten die aktuelle Plottposition weiter verschieben

			MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) + MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse)

		EndIf
	
	
	
	
	;#################################################################################################################################################
	;######################################################   Plottmodus 1: "bewegter Graph"   #######################################################
	;#################################################################################################################################################
	ElseIf (MG_aGraph(iGraph, 0, #_MG_a_iPlottmodus) = 1)
	
		
		; alle Zeichenoperationen stoppen
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		StopDrawing()
		
		
		; alte Resourcen freigeben
		If (IsImage(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Verschiebung)) <> 0)	
			FreeImage(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Verschiebung))
		EndIf
		
		
		; den zu verschiebenen Teil des Graphen kopieren
		hQuelle	= MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)
		iX_Pos	= Int(MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse))
		iY_Pos	= 0
		dBreite	= MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung)
		iHoehe	= MG_aGraph(iGraph, 0, #_MG_a_iHoehe)
		hZiel	= GrabImage(hQuelle, #PB_Any, iX_Pos, iY_Pos, dBreite, iHoehe)
		
		
		; das neue Image-handle speichern
		MG_aGraph(iGraph, 0, #_MG_a_hGraph_Verschiebung) = hZiel
		
		
		; den Ausgabekanal für die aktuellen Zeichenoperationen setzen
		MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) = #True
		StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		
		
		; den Buffer komplett löschen
		DrawingMode(#PB_2DDrawing_Default)
		Box(0, 0, MG_aGraph(iGraph, 0, #_MG_a_iBreite), MG_aGraph(iGraph, 0, #_MG_a_iHoehe), MG_aGraph(iGraph, 0, #_MG_a_iHintergrundfarbe_RGB))
		
		
		; den kopierten Teil des Graphen in den Buffer schreiben
		DrawingMode(#PB_2DDrawing_AlphaBlend)
		DrawImage(ImageID(hZiel), 0, 0, dBreite, iHoehe) 
		
		
		; die Werte der einzelnen Kanäle plotten
		For iKanal = 1 To #_MG_max_Anzahl_Kanaele Step 1


			; prüfen, welche Kanäle geplottet werden sollen
			If (MG_aGraph(iGraph, iKanal, #_MG_k_iKanal_aktivieren) = #True)
				
				
			; setzt die eingestellte Farbe und Linienbreite
			Breite	= MG_aGraph(iGraph, iKanal, #_MG_k_iLinien_Breite)
			Farbe	= MG_aGraph(iGraph, iKanal, #_MG_k_iLinien_Farbe_RGBA)
			
			
				; Werte plotten (interpoliert)
				If (MG_aGraph(iGraph, 0, #_MG_a_iInterpolation) = #True)
					
					; direkte Linie zwischen den Punkten zeichnen
					X1	= MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung) - 1
					Y1	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert)
					X2	= MG_aGraph(iGraph, 0, #_MG_a_iBreite) - 1
					Y2	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_aktueller_Wert)

					_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 4)
					

				Else ; Werte plotten (nicht interpoliert)
					
					; die horizontale Linie zeichen
					X1	= MG_aGraph(iGraph, 0, #_MG_a_iVerschiebung) - 1
					Y1	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert)
					X2	= MG_aGraph(iGraph, 0, #_MG_a_iBreite) - 1
					Y2	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert)

					_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite)


 					; die vertikale Linie zeichen
					X1	= MG_aGraph(iGraph, 0, #_MG_a_iBreite) - 1
					Y1	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert)
					X2	= MG_aGraph(iGraph, 0, #_MG_a_iBreite) - 1
					Y2	= MG_aGraph(iGraph, iKanal, #_MG_k_fY_aktueller_Wert)

					_MG_Graph_plotte_Element (X1, Y1, X2, Y2, Farbe, Breite, 4)

				EndIf

				; aktuellen Punkt für den nächsten Plottvorgang speichern
				MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert) = MG_aGraph(iGraph, iKanal, #_MG_k_fY_aktueller_Wert)

			EndIf

		Next


		; die Gitterlinien zeichnen
		_MG_Graph_plotte_Hauptgitterlinien(iGraph, 2)
		_MG_Graph_plotte_Hilfsgitterlinien(iGraph, 2)
		_MG_Graph_plotte_Bezugslinien(iGraph)
		_MG_Graph_plotte_Hilfslinien(iGraph)


		; ggf. die geplotteten Werte in der GUI darstellen (Einstellung: Plottfrequenz)
		If (MG_aGraph(iGraph, 0, #_MG_a_iPlottfrequenz) > 0)

			If (MG_aGraph(iGraph, 0, #_MG_a_iPlott_Counter) >= MG_aGraph(iGraph, 0, #_MG_a_iPlottfrequenz))
			
				StopDrawing()
				SetGadgetState(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer), ImageID(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
				StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
				MG_aGraph(iGraph, 0, #_MG_a_iPlott_Counter) = 0

			Else

				MG_aGraph(iGraph, 0, #_MG_a_iPlott_Counter) + 1

			EndIf

		EndIf

		
		
		; die geplotteten Werte in der GUI darstellen und die Plottposition wieder auf Null setzen, sobald der Zeichenbereich komplett ist
		If (MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) > MG_aGraph(iGraph, 0, #_MG_a_iBreite))

			MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) = 1

				StopDrawing()
				SetGadgetState(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer), ImageID(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
				StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))

		Else ; ...ansonsten die aktuelle Plottposition weiter verschieben --> dient in diesem Fall nur als Counter, da sich die Plottposition immer am Ende des Zeichenbereiches befindet

			MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) + MG_aGraph(iGraph, 0, #_MG_a_fInkrement_groesse)

		EndIf



	EndIf


	; gibt die aktuelle Plottposition zurück
	ProcedureReturn (MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell))


EndProcedure	;==> _MG_Graph_plotte_Werte




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_Achse_links
; Beschreibung ..: 	erzeugt eine Achsbeschriftung auf der linken Seite (Y-Achse), die sich an den horizontalen Hauptgitterlinien richtet
; Syntax.........:  _MG_Graph_Achse_links (iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "%", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
;
; Parameter .....: 	iGraph.i 				- Graph-Index, auf dem sich die Einstellungen beziehen
;                  	iAchse_anzeigen.i		- aktiviert/deaktiviert die Beschriftung der linken Achse
;											| #True		Achsbeschriftung aktivieren
;											| #False	Achsbeschriftung deaktivieren
;
;					fWertebereich.f			- ist der dargestellte Wertebereich der Achse und bezieht sich auf die Höhe des Graphen und auf die Position der Bezugslinie
;											| -1  als Wertebereich wird die Höhe des Graphen verwendet
;											| >=1 benutzerdefinierter Wertebereich
;
;					iNachkommastellen.i		- die Anzahl der Nachkommastellen, die angezeigt werden sollen (Nachkommastellen werden gerundet)
;					sEinheit$				- die Einheit die angezeigt werden soll (z.B. " sek", " %", " KG", ...)
;					iSchriftfarbe_RGB.i		- die Schriftarbe als RGB()-Code (z.B. für Schwarz: RGB(0, 0, 0))
; 											| -1 verwendet die standardmäßige Systemfarbe
; 											| >0 RGB()-Farbcode
;
;					iHintergrundfarbe_RGB.i	- die Hintergrundfarbe als RGB()-Code (z.B. für Schwarz: RGB(0, 0, 0))
; 											| -1 verwendet die standardmäßige Systemfarbe
; 											| >0 RGB()-Farbcode
;
;					sSchriftart$			- die Schriftart, die verwendet werden soll (z.B. "Arial")
;					iSchriftgroesse.i		- die Schriftgröße, die verwendet werden soll
;					iLabelbreite.i			- die Breite, die für jede Beschriftungseinheit reserviert wird (50 bis 70 sollte in der Regel ausreichen)
;					dIntervall.d			- Faktor (mindestens >= 0.1): vertikaler Abstandsfaktor zwischen den Beschriftungen im Bezug auf die Hauptgitterlinien (siehe Bemerkungen)
;
; Rückgabewerte .: 	Erfolg 					| >0 gibt die Anzahl der Beschriftungen der linken Y-Achse zurück
;
;                  	Fehler 					| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;											| -2 der Graph ist deaktiviert
;											| -3 der Abstand der Hauptgitterlinien wurde zu klein gewählt
;
; Autor .........: 	SBond
;
; Bemerkungen ...: 	Beispiele für die Intervalle mit der Annahme, dass 5 vertikale Hauptgitterlinien im Graphen sichtbar sind:
;
;					Intervall = 1:	 neben jeder Hauptgitterlinie wird eine Beschriftung angezeigt 	(insgesamt 5)
;					Intervall = 2:	 neben jeder zweiten Hauptgitterlinie wird eine Beschriftung angezeigt 	(insgesamt 3)
;					Intervall = 0.5: neben jeder Hauptgitterlinie wird eine Beschriftung angezeigt und zwischen den Hauptgitterlinien wird eine Beschriftung	angezeigt	(insgesamt 10)
;
;} ========================================================================================================================================================
Procedure _MG_Graph_Achse_links (iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "%", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
	
	; lokale Variablen deklarieren
	Protected iLinien_ueber_null.i											; Anzahl der Hauptgitterlinien über Null
	Protected iLinie_null.i													; die Position Null-Linie (Bezugspunkt für die Beschriftungen)
	Protected iLinien_unter_null.i											; Anzahl der Hauptgitterlinien unter Null
	Protected iFontID.i														; Font ID für die Schriftart
	Protected iAbstand.i													; der Pixelabstand zwischen 2 Hauptgitterlinien								
	Protected iLabelhoehe.i													; die Höhe der Text-Gadgets
	Protected iGadget_Counter.i												; Gadget-Zähler für die Bestimmung der Position im 'MG_aGraph'-Array
	Protected iX_Pos_Strich.i												; berechnete X-Position für die Strichmarkierung an der Achse
	Protected iY_Pos_Strich.i												; berechnete Y-Position für die Strichmarkierung an der Achse
	Protected iX_Pos_Beschriftung.i											; berechnete X-Position für die Beschriftung an der Achse
	Protected iY_Pos_Beschriftung.i											; berechnete Y-Position für die Beschriftung an der Achse
	Protected iBezugspunkt_erste_Beschriftung.i								; berechnete Position: dient als Bezugspunkt für die angezeigten Beschriftungen
	Protected i.i															; allgemeiner Hilfs-Zähler für Schleifen als Ganzzahl
	
	Protected fWertabstand.f												; Abstand der Beschriftungs-Werte zwischen zwei Hauptgitterlinien
	Protected fmax_anzahl_linien.f											; Anzahl der Hauptgitterlinien, die maximal dargestellt werden können

	Protected dAnzahl_Gitterlinien.d										; Anzahl Hauptgitterlinien (bezogen auf die Null-Position)
	Protected d.d															; allgemeiner Hilfs-Zähler für Schleifen als Fließkomma-Zahl (doppelte Genauigkeit)


	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	
	
	; Fehler, wenn der Hauptgitterlinien-Abstand zu gering ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y) < 1) 
		ProcedureReturn (-3)
	EndIf
	
	
	; begrenzt den Intervall auf min. 0.1
	If (dIntervall < 0.1) 
		dIntervall = 0.1
	EndIf
	
	
	; der Wertebereich wird an die vertikale Auflösung angepasst, wenn der Parameter -1 ist
	If (fWertebereich = -1)
		fWertebereich = MG_aGraph(iGraph, 0, #_MG_a_iWertebereich)
	EndIf
	
	
	; ermittelt die Anzahl der vertikalen Hauptgitterlinien, die maximal dargestellt werden können
	fmax_anzahl_linien	= MG_aGraph(iGraph, 0, #_MG_a_iHoehe) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)
	
	
	; berechnet den Abstand der Beschriftungs-Werte zwischen zwei Hauptgitterlinien
	fWertabstand		= fWertebereich / fmax_anzahl_linien
	
	
	; Achsbeschriftungen erzeugen, wenn die Option aktiviert wurde
	If (iAchse_anzeigen = #True)
		
		; alle Zeichenoperationen stoppen (notwendig, wenn Schriftarten geladen werden)
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		StopDrawing()
		
		
		; Schriftart laden und Gadget-Counter auf Null setzen
		iFontID 				=  LoadFont(1, sSchriftart$, iSchriftgroesse)
		iLabelhoehe				=  iSchriftgroesse + 8
		iGadget_Counter 		=  0
		
		
		; allgemeine Vorberechnungen zur Bestimmung der Position und Werte
		iLinie_null				=  MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)
		iLinien_ueber_null 		=  Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)))
		iLinien_unter_null 		=  Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - MG_aGraph(iGraph, 0, #_MG_a_iHoehe)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)))

		iX_Pos_Beschriftung 	=  MG_aGraph(iGraph, 0, #_MG_a_iX_Pos) - (iLabelbreite + MG_aGraph(iGraph, 0, #_MG_a_iRahmenbreite) + 8)
		iX_Pos_Strich 			=  MG_aGraph(iGraph, 0, #_MG_a_iX_Pos) - MG_aGraph(iGraph, 0, #_MG_a_iRahmenbreite) - 8
	
		iAbstand 				=  MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)
		
		
		; wenn die Null-Position unterhalb des Graphen ist: nur positiven Graphbereich berücksichtigen
		If (MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) > MG_aGraph(iGraph, 0, #_MG_a_iHoehe)) 		
			iLinien_unter_null = 0	
	
		; wenn die Null-Position oberhalb des Graphen ist: nur negativen Graphbereich berücksichtigen	
		ElseIf (MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) < 0) 	
			iLinien_ueber_null = 0	
			
		EndIf

	
		; Berechnung der Position der ersten Beschriftung
		dAnzahl_Gitterlinien			= Abs(MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
		iBezugspunkt_erste_Beschriftung	= Int((dAnzahl_Gitterlinien - Int(fmax_anzahl_linien)) / dIntervall) 
		
		If (iBezugspunkt_erste_Beschriftung <= 0)
			iBezugspunkt_erste_Beschriftung = 0
		EndIf

		d =  (iBezugspunkt_erste_Beschriftung * dIntervall)

		
		
		; Beschriftung der der Positionen: >= 0
		While (d <= (MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y) And MG_aGraph(iGraph, 0, #_MG_a_iY_max) >= 0)
			
			
			; allgemeine Vorberechnungen zur Bestimmung der Position und Werte
			iY_Pos_Beschriftung 	= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) + MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) - (iLabelhoehe / 2) - iAbstand * d
			iY_Pos_Strich 			= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) + MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) - 12 - iAbstand * d			
			
			
			; Beschriftung abbrechen, wenn das Limit (die Array-Größe) überschritten wird
			If (iGadget_Counter > #_MG_max_Anzahl_Elemente)
				Break
				
				
			; Beschriftung der Achse, wenn kein Fehler vorliegt
			ElseIf (iY_Pos_Strich <= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - 12 + MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)))
				
				
				; eine alte Beschriftung neu positionieren (falls vorhanden)
				If (MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter) <> 0)
					
					; die Beschriftung anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter), iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe)
					
					; den Strich an der Achse anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_links_Strich, iGadget_Counter), iX_Pos_Strich, iY_Pos_Strich, 8, 14)					
					
					
				; eine neue Beschriftung erstellen, wenn keine vorhanden ist
				Else 
					
					; die Beschriftung anzeigen
					MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe, "", #PB_Text_Right)
					
					; den Strich an der Achse anzeigen
					MG_aGraph(iGraph, #_MG_b_links_Strich, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Strich, iY_Pos_Strich, 8, 14, "_", #PB_Text_Right)
					
				EndIf
			
				
				; Schriftfarbe übernehmen
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter), #PB_Gadget_BackColor,  iHintergrundfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_links_Strich, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				
				; Schriftart übernehmen
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter), iFontID)
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_links_Strich, iGadget_Counter), #PB_Default)
				
				; Beschriftungs-Text anzeigen
				SetGadgetText 	(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter), StrD(d * fWertabstand, iNachkommastellen) + sEinheit$)
		
				; Gadget-Counter und Merker hochzählen
				MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_links) + 1
				iGadget_Counter + 1
				
			EndIf
			
			; zur nächsten Position springen
			d + dIntervall
			
		Wend

		
		
		; Berechnung der Position der ersten Beschriftung
		dAnzahl_Gitterlinien			= Abs(MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
		iBezugspunkt_erste_Beschriftung	= Int((dAnzahl_Gitterlinien - Int(fmax_anzahl_linien)) / dIntervall) 
		
		If (iBezugspunkt_erste_Beschriftung <= 0)
			iBezugspunkt_erste_Beschriftung = 0
		EndIf

		d =  (iBezugspunkt_erste_Beschriftung * dIntervall) + dIntervall
		
		
		
		; Beschriftung der der Positionen: < 0
		While (d <= Abs((MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - MG_aGraph(iGraph, 0, #_MG_a_iHoehe)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)) And MG_aGraph(iGraph, 0, #_MG_a_iY_min) < 0)
			
			
			; allgemeine Vorberechnungen zur Bestimmung der Position und Werte
			iY_Pos_Beschriftung 	= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) + MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) - (iLabelhoehe / 2) + iAbstand * d
			iY_Pos_Strich 			= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) + MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) - 12 + iAbstand * d
			
			
			; Beschriftung abbrechen, wenn das Limit (die Array-Größe) überschritten wird
			If (iGadget_Counter > #_MG_max_Anzahl_Elemente)
				Break
				
				
			; Beschriftung der Achse, wenn kein Fehler vorliegt
			ElseIf (iY_Pos_Strich >= MG_aGraph(iGraph, 0, #_MG_a_iY_Pos) - 14)		
				
				
				; eine alte Beschriftung neu positionieren (falls vorhanden)
				If (MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter) <> 0)
					
					; die Beschriftung anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter), iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe)
					
					; den Strich an der Achse anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_links_Strich, iGadget_Counter), iX_Pos_Strich, iY_Pos_Strich, 8, 14)
					
					
				; eine neue Beschriftung erstellen, wenn keine vorhanden ist
				Else
					
					; die Beschriftung anzeigen
					MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe, "", #PB_Text_Right)
					
					; den Strich an der Achse anzeigen
					MG_aGraph(iGraph, #_MG_b_links_Strich, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Strich, iY_Pos_Strich, 8, 14, "_", #PB_Text_Right)
					
				EndIf
			
				
				; Schriftfarbe übernehmen
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter), #PB_Gadget_BackColor,  iHintergrundfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_links_Strich, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				
				; Schriftart übernehmen
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter), iFontID)
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_links_Strich, iGadget_Counter), #PB_Default)
				
				; Beschriftungs-Text anzeigen
				SetGadgetText 	(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, iGadget_Counter), "-" + StrD(d * fWertabstand, iNachkommastellen) + sEinheit$)
				
				; Gadget-Counter und Merker hochzählen
				MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_links) + 1
				iGadget_Counter + 1
				
			EndIf
			
			; zur nächsten Position springen
			d + dIntervall
		Wend
		
		
		; alte Achsenbeschriftungen löschen, sofern noch welche vorhanden sind
		For i = iGadget_Counter To #_MG_max_Anzahl_Elemente Step 1
			
			If (MG_aGraph(iGraph, #_MG_b_links_Beschriftung, i) <> 0)
				
				FreeGadget(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, i))
				FreeGadget(MG_aGraph(iGraph, #_MG_b_links_Strich, i))
				
				MG_aGraph(iGraph, #_MG_b_links_Beschriftung, i) = 0
				MG_aGraph(iGraph, #_MG_b_links_Strich, i) = 0

			EndIf
			
		Next
			
		; die Anzahl der Beschriftungen speichern
		MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_links)				= iGadget_Counter
		MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_links_intervall)	= dIntervall

	EndIf


	; Rückgabewert: gibt die Anzahl der Beschriftungen der linken Y-Achse zurück
	ProcedureReturn (MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_links))


EndProcedure	;==> _MG_Graph_Achse_links




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_Achse_rechts
; Beschreibung ..: 	erzeugt eine Achsbeschriftung auf der rechten Seite (Y-Achse), die sich an den horizontalen Hauptgitterlinien richtet
; Syntax.........:  _MG_Graph_Achse_rechts (iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "%", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
;
; Parameter .....: 	iGraph.i 				- Graph-Index, auf dem sich die Einstellungen beziehen
;                  	iAchse_anzeigen.i		- aktiviert/deaktiviert die Beschriftung der rechten Achse
;											| #True		Achsbeschriftung aktivieren
;											| #False	Achsbeschriftung deaktivieren
;
;					fWertebereich.f			- ist der dargestellte Wertebereich der Achse und bezieht sich auf die Höhe des Graphen und auf die Position der Bezugslinie
;											| -1  als Wertebereich wird die Höhe des Graphen verwendet
;											| >=1 benutzerdefinierter Wertebereich
;
;					iNachkommastellen.i		- die Anzahl der Nachkommastellen, die angezeigt werden sollen (Nachkommastellen werden gerundet)
;					sEinheit$				- die Einheit die angezeigt werden soll (z.B. " sek", " %", " KG", ...)
;					iSchriftfarbe_RGB.i		- die Schriftarbe als RGB()-Code (z.B. für Schwarz: RGB(0, 0, 0))
; 											| -1 verwendet die standardmäßige Systemfarbe
; 											| >0 RGB()-Farbcode
;
;					iHintergrundfarbe_RGB.i	- die Hintergrundfarbe als RGB()-Code (z.B. für Schwarz: RGB(0, 0, 0))
; 											| -1 verwendet die standardmäßige Systemfarbe
; 											| >0 RGB()-Farbcode
;
;					sSchriftart$			- die Schriftart, die verwendet werden soll (z.B. "Arial")
;					iSchriftgroesse.i		- die Schriftgröße, die verwendet werden soll
;					iLabelbreite.i			- die Breite, die für jede Beschriftungseinheit reserviert wird (50 bis 70 sollte in der Regel ausreichen)
;					dIntervall.d			- Faktor (mindestens >= 0.1): vertikaler Abstandsfaktor zwischen den Beschriftungen im Bezug auf die Hauptgitterlinien (siehe Bemerkungen)
;
; Rückgabewerte .: 	Erfolg 					| >0 gibt die Anzahl der Beschriftungen der rechten Y-Achse zurück
;
;                  	Fehler 					| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;											| -2 der Graph ist deaktiviert
;											| -3 der Abstand der Hauptgitterlinien wurde zu klein gewählt
;
; Autor .........: 	SBond
;
; Bemerkungen ...:	Beispiele für die Intervalle mit der Annahme, dass 5 vertikale Hauptgitterlinien im Graphen sichtbar sind:
;
;					Intervall = 1:	 neben jeder Hauptgitterlinie wird eine Beschriftung angezeigt 	(insgesamt 5)
;					Intervall = 2:	 neben jeder zweiten Hauptgitterlinie wird eine Beschriftung angezeigt 	(insgesamt 3)
;					Intervall = 0.5: neben jeder Hauptgitterlinie wird eine Beschriftung angezeigt und zwischen den Hauptgitterlinien wird eine Beschriftung	angezeigt	(insgesamt 10)
;
;} ========================================================================================================================================================
Procedure _MG_Graph_Achse_rechts (iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "%", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
	
	; lokale Variablen deklarieren
	Protected iLinien_ueber_null.i											; Anzahl der Hauptgitterlinien über Null
	Protected iLinie_null.i													; die Position Null-Linie (Bezugspunkt für die Beschriftungen)
	Protected iLinien_unter_null.i											; Anzahl der Hauptgitterlinien unter Null
	Protected iFontID.i														; Font ID für die Schriftart
	Protected iAbstand.i													; der Pixelabstand zwischen 2 Hauptgitterlinien								
	Protected iLabelhoehe.i													; die Höhe der Text-Gadgets
	Protected iGadget_Counter.i												; Gadget-Zähler für die Bestimmung der Position im 'MG_aGraph'-Array
	Protected iX_Pos_Strich.i												; berechnete X-Position für die Strichmarkierung an der Achse
	Protected iY_Pos_Strich.i												; berechnete Y-Position für die Strichmarkierung an der Achse
	Protected iX_Pos_Beschriftung.i											; berechnete X-Position für die Beschriftung an der Achse
	Protected iY_Pos_Beschriftung.i											; berechnete Y-Position für die Beschriftung an der Achse
	Protected iBezugspunkt_erste_Beschriftung.i								; berechnete Position: dient als Bezugspunkt für die angezeigten Beschriftungen
	Protected i.i															; allgemeiner Hilfs-Zähler für Schleifen als Ganzzahl
	
	Protected fWertabstand.f												; Abstand der Beschriftungs-Werte zwischen zwei Hauptgitterlinien
	Protected fmax_anzahl_linien.f											; Anzahl der Hauptgitterlinien, die maximal dargestellt werden können

	Protected dAnzahl_Gitterlinien.d										; Anzahl Hauptgitterlinien (bezogen auf die Null-Position)
	Protected d.d															; allgemeiner Hilfs-Zähler für Schleifen als Fließkomma-Zahl (doppelte Genauigkeit)


	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	

	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	

	; Fehler, wenn der Hauptgitterlinien-Abstand zu gering ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y) < 1) 
		ProcedureReturn (-3)
	EndIf
	
	
	; begrenzt den Intervall auf min. 0.1
	If (dIntervall < 0.1) 
		dIntervall = 0.1
	EndIf
	
	
	; der Wertebereich wird an die vertikale Auflösung angepasst, wenn der Parameter -1 ist
	If (fWertebereich = -1)
		fWertebereich = MG_aGraph(iGraph, 0, #_MG_a_iWertebereich)
	EndIf
	
	
	; ermittelt die Anzahl der vertikalen Hauptgitterlinien, die maximal dargestellt werden können
	fmax_anzahl_linien	= MG_aGraph(iGraph, 0, #_MG_a_iHoehe) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)
	
	
	; berechnet den Abstand der Beschriftungs-Werte zwischen zwei Hauptgitterlinien
	fWertabstand		= fWertebereich / fmax_anzahl_linien
	
	
	; Achsbeschriftungen erzeugen, wenn die Option aktiviert wurde
	If (iAchse_anzeigen = #True)
		
		
		; alle Zeichenoperationen stoppen (notwendig, wenn Schriftarten geladen werden)
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		StopDrawing()
		
		
		; Schriftart laden und Gadget-Counter auf Null setzen
		iFontID 				=  LoadFont(2, sSchriftart$, iSchriftgroesse)
		iLabelhoehe				=  iSchriftgroesse + 8
		iGadget_Counter 		=  0
		
		
		; allgemeine Vorberechnungen zur Bestimmung der Position und Werte
		iLinie_null				=  MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)
		iLinien_ueber_null 		=  Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)))
		iLinien_unter_null 		=  Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - MG_aGraph(iGraph, 0, #_MG_a_iHoehe)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)))

		iX_Pos_Beschriftung 	=  MG_aGraph(iGraph, 0, #_MG_a_iX_Pos) + MG_aGraph(iGraph, 0, #_MG_a_iBreite) + MG_aGraph(iGraph, 0, #_MG_a_iRahmenbreite) + 10		
		iX_Pos_Strich 			=  MG_aGraph(iGraph, 0, #_MG_a_iX_Pos) + MG_aGraph(iGraph, 0, #_MG_a_iBreite) + MG_aGraph(iGraph, 0, #_MG_a_iRahmenbreite)
	
		iAbstand 				=  MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)
		
		
		; wenn die Null-Position unterhalb des Graphen ist: nur positiven Graphbereich berücksichtigen
		If (MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) > MG_aGraph(iGraph, 0, #_MG_a_iHoehe)) 
			iLinien_unter_null = 0	
			
		; wenn die Null-Position oberhalb des Graphen ist: nur negativen Graphbereich berücksichtigen	
		ElseIf (MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) < 0) 
			iLinien_ueber_null = 0
			
		EndIf

	
		; Berechnung der Position der ersten Beschriftung
		dAnzahl_Gitterlinien			= Abs(MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
		iBezugspunkt_erste_Beschriftung	= Int((dAnzahl_Gitterlinien - Int(fmax_anzahl_linien)) / dIntervall) 
		
		If (iBezugspunkt_erste_Beschriftung <= 0)
			iBezugspunkt_erste_Beschriftung = 0
		EndIf

		d =  (iBezugspunkt_erste_Beschriftung * dIntervall)


		
		; Beschriftung der der Positionen: >= 0
		While (d <= (MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y) And MG_aGraph(iGraph, 0, #_MG_a_iY_max) >= 0)
			
			
			; allgemeine Vorberechnungen zur Bestimmung der Position und Werte
			iY_Pos_Beschriftung 	= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) + MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) - (iLabelhoehe / 2) - iAbstand * d
			iY_Pos_Strich 			= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) + MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) - 12 - iAbstand * d			
			
			
			; Beschriftung abbrechen, wenn das Limit (die Array-Größe) überschritten wird
			If (iGadget_Counter > #_MG_max_Anzahl_Elemente)
				Break
				
				
			; Beschriftung der Achse, wenn kein Fehler vorliegt
			ElseIf (iY_Pos_Strich <= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - 12 + MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)))
				
				
				; eine alte Beschriftung neu positionieren (falls vorhanden)
				If (MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter) <> 0)
					
					; die Beschriftung anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter), iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe)
					
					; den Strich an der Achse anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_rechts_Strich, iGadget_Counter), iX_Pos_Strich, iY_Pos_Strich, 8, 14)					
					
					
				; eine neue Beschriftung erstellen, wenn keine vorhanden ist
				Else 
					
					; die Beschriftung anzeigen
					MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe, "")
					
					; den Strich an der Achse anzeigen
					MG_aGraph(iGraph, #_MG_b_rechts_Strich, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Strich, iY_Pos_Strich, 8, 14, "_")
					
				EndIf
			
				
				; Schriftfarbe übernehmen
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter), #PB_Gadget_BackColor,  iHintergrundfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_rechts_Strich, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				
				; Schriftart übernehmen
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter), iFontID)
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_rechts_Strich, iGadget_Counter), #PB_Default)
				
				; Beschriftungs-Text anzeigen
				SetGadgetText 	(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter), StrD(d * fWertabstand, iNachkommastellen) + sEinheit$)
		
				; Gadget-Counter und Merker hochzählen
				MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_rechts) + 1
				iGadget_Counter + 1
				
			EndIf
			
			; zur nächsten Position springen
			d + dIntervall
			
		Wend

		
		
		; Berechnung der Position der ersten Beschriftung
		dAnzahl_Gitterlinien			= Abs(MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y))
		iBezugspunkt_erste_Beschriftung	= Int((dAnzahl_Gitterlinien - Int(fmax_anzahl_linien)) / dIntervall) 
		
		If (iBezugspunkt_erste_Beschriftung <= 0)
			iBezugspunkt_erste_Beschriftung = 0
		EndIf

		d =  (iBezugspunkt_erste_Beschriftung * dIntervall) + dIntervall
	
		
		
		; Beschriftung der der Positionen: < 0
		While (d <= Abs((MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos) - MG_aGraph(iGraph, 0, #_MG_a_iHoehe)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_Y)) And MG_aGraph(iGraph, 0, #_MG_a_iY_min) < 0)
			
			
			; allgemeine Vorberechnungen zur Bestimmung der Position und Werte
			iY_Pos_Beschriftung 	= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) + MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) - (iLabelhoehe / 2) + iAbstand * d
			iY_Pos_Strich 			= (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) + MG_aGraph(iGraph, 0, #_MG_a_iY_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - MG_aGraph(iGraph, 0, #_MG_a_iY_null_linie_pos)) - 12 + iAbstand * d
			
			
			; Beschriftung abbrechen, wenn das Limit (die Array-Größe) überschritten wird
			If (iGadget_Counter > #_MG_max_Anzahl_Elemente)
				Break
				
				
			; Beschriftung der Achse, wenn kein Fehler vorliegt
			ElseIf (iY_Pos_Strich >= MG_aGraph(iGraph, 0, #_MG_a_iY_Pos) - 14)		
				
				
				; eine alte Beschriftung neu positionieren (falls vorhanden)
				If (MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter) <> 0)
					
					; die Beschriftung anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter), iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe)
					
					; den Strich an der Achse anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_rechts_Strich, iGadget_Counter), iX_Pos_Strich, iY_Pos_Strich, 8, 14)
					
					
				; eine neue Beschriftung erstellen, wenn keine vorhanden ist
				Else
					
					; die Beschriftung anzeigen
					MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe, "")
					
					; den Strich an der Achse anzeigen
					MG_aGraph(iGraph, #_MG_b_rechts_Strich, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Strich, iY_Pos_Strich, 8, 14, "_")
					
				EndIf
			
				
				; Schriftfarbe übernehmen
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter), #PB_Gadget_BackColor,  iHintergrundfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_rechts_Strich, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				
				; Schriftart übernehmen
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter), iFontID)
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_rechts_Strich, iGadget_Counter), #PB_Default)
				
				; Beschriftungs-Text anzeigen
				SetGadgetText 	(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, iGadget_Counter), "-" + StrD(d * fWertabstand, iNachkommastellen) + sEinheit$)
				
				; Gadget-Counter und Merker hochzählen
				MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_rechts) + 1
				iGadget_Counter + 1
				
			EndIf
			
			; zur nächsten Position springen
			d + dIntervall
		Wend
		
		

		; alte Achsenbeschriftungen löschen, sofern noch welche vorhanden sind
		For i = iGadget_Counter To #_MG_max_Anzahl_Elemente Step 1
			
			If (MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, i) <> 0)
				
				FreeGadget(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, i))
				FreeGadget(MG_aGraph(iGraph, #_MG_b_rechts_Strich, i))
				
				MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, i) = 0
				MG_aGraph(iGraph, #_MG_b_rechts_Strich, i) = 0

			EndIf
			
		Next
		

		; die Anzahl der Beschriftungen speichern
		MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_rechts)				= iGadget_Counter
		MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_rechts_intervall)	= dIntervall

	EndIf


	; Rückgabewert: gibt die Anzahl der Beschriftungen der rechten Y-Achse zurück
	ProcedureReturn (MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_rechts))


EndProcedure	;==> _MG_Graph_Achse_rechts




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_Achse_unten
; Beschreibung ..: 	erzeugt eine Achsbeschriftung auf der unteren Seite (X-Achse), die sich an den vertikalen Hauptgitterlinien richtet
; Syntax.........:  _MG_Graph_Achse_unten (iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "%", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
;
; Parameter .....: 	iGraph.i 				- Graph-Index, auf dem sich die Einstellungen beziehen
;                  	iAchse_anzeigen.i		- aktiviert/deaktiviert die Beschriftung der unteren Achse
;											| #True		Achsbeschriftung aktivieren
;											| #False	Achsbeschriftung deaktivieren
;
;					fWertebereich.f			- ist der dargestellte Wertebereich der Achse und bezieht sich auf die Breite des Graphen und auf die Position der Bezugslinie
;											| -1  als Wertebereich wird die Breite des Graphen verwendet
;											| >=1 benutzerdefinierter Wertebereich
;
;					iNachkommastellen.i		- die Anzahl der Nachkommastellen, die angezeigt werden sollen (Nachkommastellen werden gerundet)
;					sEinheit$				- die Einheit die angezeigt werden soll (z.B. " sek", " %", " KG", ...)
;					iSchriftfarbe_RGB.i		- die Schriftarbe als RGB()-Code (z.B. für Schwarz: RGB(0, 0, 0))
; 											| -1 verwendet die standardmäßige Systemfarbe
; 											| >0 RGB()-Farbcode
;
;					iHintergrundfarbe_RGB.i	- die Hintergrundfarbe als RGB()-Code (z.B. für Schwarz: RGB(0, 0, 0))
; 											| -1 verwendet die standardmäßige Systemfarbe
; 											| >0 RGB()-Farbcode
;
;					sSchriftart$			- die Schriftart, die verwendet werden soll (z.B. "Arial")
;					iSchriftgroesse.i		- die Schriftgröße, die verwendet werden soll
;					iLabelbreite.i			- die Breite, die für jede Beschriftungseinheit reserviert wird (50 bis 70 sollte in der Regel ausreichen)
;					dIntervall.d			- Faktor (mindestens >= 0.1): horizontaler Abstandsfaktor zwischen den Beschriftungen im Bezug auf die Hauptgitterlinien (siehe Bemerkungen)
;
; Rückgabewerte .: 	Erfolg 					| >0 gibt die Anzahl der Beschriftungen der unteren Y-Achse zurück
;
;                  	Fehler 					| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;											| -2 der Graph ist deaktiviert
;											| -3 der Abstand der Hauptgitterlinien wurde zu klein gewählt
;
; Autor .........: 	SBond
;
; Bemerkungen ...:	Beispiele für die Intervalle mit der Annahme, dass 5 horizontale Hauptgitterlinien im Graphen sichtbar sind:
;
;					Intervall = 1:	 neben jeder Hauptgitterlinie wird eine Beschriftung angezeigt 	(insgesamt 5)
;					Intervall = 2:	 neben jeder zweiten Hauptgitterlinie wird eine Beschriftung angezeigt 	(insgesamt 3)
;					Intervall = 0.5: neben jeder Hauptgitterlinie wird eine Beschriftung angezeigt und zwischen den Hauptgitterlinien wird eine Beschriftung	angezeigt	(insgesamt 10)
;
;} ========================================================================================================================================================
Procedure _MG_Graph_Achse_unten (iGraph.i, iAchse_anzeigen.i = #True, fWertebereich.f = -1, iNachkommastellen.i = 1, sEinheit$ = "s", iSchriftfarbe_RGB.i = -1, iHintergrundfarbe_RGB.i = -1, sSchriftart$ = "Arial", iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
	
	; lokale Variablen deklarieren
	Protected iLinien_ueber_null.i											; Anzahl der Hauptgitterlinien über Null
	Protected iLinie_null.i													; die Position Null-Linie (Bezugspunkt für die Beschriftungen)
	Protected iLinien_unter_null.i											; Anzahl der Hauptgitterlinien unter Null
	Protected iFontID.i														; Font ID für die Schriftart
	Protected iAbstand.i													; der Pixelabstand zwischen 2 Hauptgitterlinien								
	Protected iLabelhoehe.i													; die Höhe der Text-Gadgets
	Protected iGadget_Counter.i												; Gadget-Zähler für die Bestimmung der Position im 'MG_aGraph'-Array
	Protected iX_Pos_Strich.i												; berechnete X-Position für die Strichmarkierung an der Achse
	Protected iY_Pos_Strich.i												; berechnete Y-Position für die Strichmarkierung an der Achse
	Protected iX_Pos_Beschriftung.i											; berechnete X-Position für die Beschriftung an der Achse
	Protected iY_Pos_Beschriftung.i											; berechnete Y-Position für die Beschriftung an der Achse
	Protected iBezugspunkt_erste_Beschriftung.i								; berechnete Position: dient als Bezugspunkt für die angezeigten Beschriftungen
	Protected i.i															; allgemeiner Hilfs-Zähler für Schleifen als Ganzzahl
	
	Protected fWertabstand.f												; Abstand der Beschriftungs-Werte zwischen zwei Hauptgitterlinien
	Protected fmax_anzahl_linien.f											; Anzahl der Hauptgitterlinien, die maximal dargestellt werden können

	Protected dAnzahl_Gitterlinien.d										; Anzahl Hauptgitterlinien (bezogen auf die Null-Position)
	Protected d.d															; allgemeiner Hilfs-Zähler für Schleifen als Fließkomma-Zahl (doppelte Genauigkeit)


	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	

	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	

	; Fehler, wenn der Hauptgitterlinien-Abstand zu gering ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X) < 1) 
		ProcedureReturn (-3)
	EndIf
	
	
	; begrenzt den Intervall auf min. 0.1
	If (dIntervall < 0.1) 
		dIntervall = 0.1
	EndIf
	
	
	; der Wertebereich wird an die horizontale Auflösung angepasst, wenn der Parameter -1 ist
	If (fWertebereich = -1)
		fWertebereich = MG_aGraph(iGraph, 0, #_MG_a_iAufloesung)
	EndIf
	
	
	; ermittelt die Anzahl der horizontalen Hauptgitterlinien, die maximal dargestellt werden können
	fmax_anzahl_linien	= MG_aGraph(iGraph, 0, #_MG_a_iBreite) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X)
	
	
	; berechnet den Abstand der Beschriftungs-Werte zwischen zwei Hauptgitterlinien
	fWertabstand		= fWertebereich / fmax_anzahl_linien
	
	
	; Achsbeschriftungen erzeugen, wenn die Option aktiviert wurde
	If (iAchse_anzeigen = #True)
		
		
		; alle Zeichenoperationen stoppen (notwendig, wenn Schriftarten geladen werden)
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
	
		StopDrawing()
		
		
		; Schriftart laden und Gadget-Counter auf Null setzen
		iFontID 				=  LoadFont(3, sSchriftart$, iSchriftgroesse)
		iLabelhoehe				=  iSchriftgroesse + 8
		iGadget_Counter 		=  0
		
		
		; allgemeine Vorberechnungen zur Bestimmung der Position und Werte
		iLinie_null				=  MG_aGraph(iGraph, 0, #_MG_a_iBreite) - MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)
		iLinien_ueber_null 		=  Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X)))
		iLinien_unter_null 		=  Abs(Int((MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) - MG_aGraph(iGraph, 0, #_MG_a_iBreite)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X)))

		iY_Pos_Beschriftung 	=  MG_aGraph(iGraph, 0, #_MG_a_iY_Pos) + MG_aGraph(iGraph, 0, #_MG_a_iHoehe) + MG_aGraph(iGraph, 0, #_MG_a_iRahmenbreite) +(iLabelhoehe / 2) + 3
		iY_Pos_Strich 			=  MG_aGraph(iGraph, 0, #_MG_a_iY_Pos) + MG_aGraph(iGraph, 0, #_MG_a_iHoehe) + MG_aGraph(iGraph, 0, #_MG_a_iRahmenbreite)
		
		iAbstand 				=  MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X)
		
		
		; wenn die Null-Position unterhalb des Graphen ist: nur positiven Graphbereich berücksichtigen
		If (MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) > MG_aGraph(iGraph, 0, #_MG_a_iBreite)) 
			iLinien_unter_null = 0	
				
		; wenn die Null-Position oberhalb des Graphen ist: nur negativen Graphbereich berücksichtigen	
		ElseIf (MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) < 0) 
			iLinien_ueber_null = 0
			
		EndIf

	
		; Berechnung der Position der ersten Beschriftung
		dAnzahl_Gitterlinien			= Abs(MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))
		iBezugspunkt_erste_Beschriftung	= Int((dAnzahl_Gitterlinien - Int(fmax_anzahl_linien)) / dIntervall) 
		
		If (iBezugspunkt_erste_Beschriftung <= 0)
			iBezugspunkt_erste_Beschriftung = 0
		EndIf

		d = (iBezugspunkt_erste_Beschriftung * dIntervall) + dIntervall

		

		; Beschriftung der der Positionen: < 0
		While (d <= (MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X) And (MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) >= MG_aGraph(iGraph, 0, #_MG_a_iX_Pos)))
			
			
			; allgemeine Vorberechnungen zur Bestimmung der Position und Werte
			iX_Pos_Beschriftung 	= (MG_aGraph(iGraph, 0, #_MG_a_iBreite) + MG_aGraph(iGraph, 0, #_MG_a_iX_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iBreite) - MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)) - (iLabelbreite / 2) - iAbstand * d
			iX_Pos_Strich 			= (MG_aGraph(iGraph, 0, #_MG_a_iBreite) + MG_aGraph(iGraph, 0, #_MG_a_iX_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iBreite) - MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)) - iAbstand * d			
			
			
			; Beschriftung abbrechen, wenn das Limit (die Array-Größe) überschritten wird
			If (iGadget_Counter > #_MG_max_Anzahl_Elemente)
				Break
				
				
			; Beschriftung der Achse, wenn kein Fehler vorliegt
			ElseIf (iX_Pos_Strich <= (MG_aGraph(iGraph, 0, #_MG_a_iBreite) + MG_aGraph(iGraph, 0, #_MG_a_iX_Pos)))
				
				
				; eine alte Beschriftung neu positionieren (falls vorhanden)
				If (MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter) <> 0)
					
					; die Beschriftung anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter), iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe)
					
					; den Strich an der Achse anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_unten_Strich, iGadget_Counter), iX_Pos_Strich, iY_Pos_Strich, 3, 10)					
					
					
				; eine neue Beschriftung erstellen, wenn keine vorhanden ist
				Else 
					
					; die Beschriftung anzeigen
					MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe, "", #PB_Text_Center)
					
					; den Strich an der Achse anzeigen
					MG_aGraph(iGraph, #_MG_b_unten_Strich, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Strich, iY_Pos_Strich, 3, 10, "|", #PB_Text_Center)
					
				EndIf
			
				
				; Schriftfarbe übernehmen
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter), #PB_Gadget_BackColor,  iHintergrundfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_unten_Strich, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				
				; Schriftart übernehmen
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter), iFontID)
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_unten_Strich, iGadget_Counter), #PB_Default)
				
				; Beschriftungs-Text anzeigen
				SetGadgetText 	(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter), "-" + StrD(d * fWertabstand, iNachkommastellen) + sEinheit$)
		
				; Gadget-Counter und Merker hochzählen
				MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_unten) + 1
				iGadget_Counter + 1
				
			EndIf
			
			; zur nächsten Position springen
			d + dIntervall
			
		Wend


	
		; Berechnung der Position der ersten Beschriftung
		dAnzahl_Gitterlinien			= MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X)
		iBezugspunkt_erste_Beschriftung	= Abs(Int((dAnzahl_Gitterlinien) / dIntervall))

		
		If (dAnzahl_Gitterlinien < 0)
			d =  (iBezugspunkt_erste_Beschriftung * dIntervall) + dIntervall

		Else
			d = 0

		EndIf
		
		
		
		; Beschriftung der der Positionen: >= 0
		While (d <= Abs((MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) - MG_aGraph(iGraph, 0, #_MG_a_iBreite)) / MG_aGraph(iGraph, 0, #_MG_a_iHauptgitter_abstand_X))) And (MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos) <= MG_aGraph(iGraph, 0, #_MG_a_iBreite))

			
			; allgemeine Vorberechnungen zur Bestimmung der Position und Werte
			iX_Pos_Beschriftung 	= (MG_aGraph(iGraph, 0, #_MG_a_iBreite) + MG_aGraph(iGraph, 0, #_MG_a_iX_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iBreite) - MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)) - (iLabelbreite / 2) + iAbstand * d
			iX_Pos_Strich 			= (MG_aGraph(iGraph, 0, #_MG_a_iBreite) + MG_aGraph(iGraph, 0, #_MG_a_iX_Pos)) - (MG_aGraph(iGraph, 0, #_MG_a_iBreite) - MG_aGraph(iGraph, 0, #_MG_a_iX_null_linie_pos)) + iAbstand * d

			
			; Beschriftung abbrechen, wenn das Limit (die Array-Größe) überschritten wird
			If (iGadget_Counter > #_MG_max_Anzahl_Elemente)
				Break
				
				
			; Beschriftung der Achse, wenn kein Fehler vorliegt
			ElseIf (iX_Pos_Strich <= (MG_aGraph(iGraph, 0, #_MG_a_iBreite) + MG_aGraph(iGraph, 0, #_MG_a_iX_Pos)))
				
				
				; eine alte Beschriftung neu positionieren (falls vorhanden)
				If (MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter) <> 0)
					
					; die Beschriftung anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter), iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe)
					
					; den Strich an der Achse anzeigen
					ResizeGadget(MG_aGraph(iGraph, #_MG_b_unten_Strich, iGadget_Counter), iX_Pos_Strich, iY_Pos_Strich, 3, 10)					
					
					
				; eine neue Beschriftung erstellen, wenn keine vorhanden ist
				Else 
					
					; die Beschriftung anzeigen
					MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Beschriftung, iY_Pos_Beschriftung, iLabelbreite, iLabelhoehe, "", #PB_Text_Center)
					
					; den Strich an der Achse anzeigen
					MG_aGraph(iGraph, #_MG_b_unten_Strich, iGadget_Counter) = TextGadget(#PB_Any, iX_Pos_Strich, iY_Pos_Strich, 3, 10, "|", #PB_Text_Center)
					
				EndIf
			
				
				; Schriftfarbe übernehmen
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter), #PB_Gadget_BackColor,  iHintergrundfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				SetGadgetColor	(MG_aGraph(iGraph, #_MG_b_unten_Strich, iGadget_Counter), #PB_Gadget_FrontColor, iSchriftfarbe_RGB)
				
				; Schriftart übernehmen
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter), iFontID)
				SetGadgetFont	(MG_aGraph(iGraph, #_MG_b_unten_Strich, iGadget_Counter), #PB_Default)
				
				; Beschriftungs-Text anzeigen
				SetGadgetText 	(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, iGadget_Counter), StrD(d * fWertabstand, iNachkommastellen) + sEinheit$)
		
				; Gadget-Counter und Merker hochzählen
				MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_unten) + 1
				iGadget_Counter + 1
				
			EndIf
			
			; zur nächsten Position springen
			d + dIntervall
			
		Wend
		
		

		; alte Achsenbeschriftungen löschen, sofern noch welche vorhanden sind
		For i = iGadget_Counter To #_MG_max_Anzahl_Elemente Step 1
			
			If (MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, i) <> 0)
				
				FreeGadget(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, i))
				FreeGadget(MG_aGraph(iGraph, #_MG_b_unten_Strich, i))
				
				MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, i) = 0
				MG_aGraph(iGraph, #_MG_b_unten_Strich, i) = 0

			EndIf
			
		Next
		
		
		; die Anzahl der Beschriftungen speichern
		MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_unten)				= iGadget_Counter
		MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_unten_intervall)	= dIntervall

	EndIf


	; Rückgabewert: gibt die Anzahl der Beschriftungen der X-Achse zurück
	ProcedureReturn (MG_aGraph(iGraph, 0, #_MG_a_iAchsbeschriftungen_unten))


EndProcedure	;==> _MG_Graph_Achse_unten




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_GUI_updaten
; Beschreibung ..: 	zeichnet den Graph in die GUI bzw. aktualisiert die Darstellung
; Syntax.........: 	_MG_Graph_GUI_updaten (iGraph.i)
;
; Parameter .....: 	iGraph.i 	- Graph-Index, auf dem sich die Einstellungen beziehen
;
; Rückgabewerte .: 	Erfolg 		|  0
;
;                  	Fehler 		| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;								| -2 der Graph ist deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...:	Es werden keine Werte geplottet. Es wird lediglich die Darstellung in der GUI aktualisiert.
;
;} ========================================================================================================================================================
Procedure _MG_Graph_GUI_updaten (iGraph.i)
	
	; lokale Variablen deklarieren
	Protected i.i															; allgemeiner Zähler für Schleifen
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	

	; den Ausgabekanal für die aktuellen Zeichenoperationen setzen und den Graph in die GUI zeichnen
	If (MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) <> #True)
		
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) = #True
		
		StopDrawing()
		SetGadgetState(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer), ImageID(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		
	Else
		
		StopDrawing()
		SetGadgetState(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer), ImageID(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))		
		
	EndIf

	
	
	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_updaten




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_initialisieren
; Beschreibung ..: 	plottet den Graphen erstmalig in der GUI
; Syntax.........: 	_MG_Graph_initialisieren (iGraph.i)
;
; Parameter .....: 	iGraph.i 	- Graph-Index, auf dem sich die Einstellungen beziehen
;
; Rückgabewerte .: 	Erfolg 		|  0
;
;                  	Fehler 		| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;								| -2 der Graph ist deaktiviert
;
; Autor .........: 	SBond
; Bemerkungen ...:	Diese Funktion sollte verwendet werden, nachdem der Graph erstellt und konfiguriert wurde. Es dient nur zur sauberen Darstellung
;					und muss daher nicht zwangsweise verwendet werden. Wird diese Funktion nicht verwendet, so wird der Graph erst sichtbar, wenn mit dem
;					Plottvorgang begonnen wurde. (ggf. kann es sein, das solange nur der Rahmen sichtbar ist)
;
;} ========================================================================================================================================================
Procedure _MG_Graph_initialisieren (iGraph.i)
	
	; lokale Variablen deklarieren
	Protected i.i															; allgemeiner Zähler für Schleifen
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	

	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	
	
	; den Ausgabekanal für die aktuellen Zeichenoperationen setzen
	If (MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) <> #True)
		
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) = #True
		
		StopDrawing()
		StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		
	EndIf
	
	
	; den Zeichenbereich leeren
	DrawingMode(#PB_2DDrawing_Default)
	Box(0, 0, MG_aGraph(iGraph, 0, #_MG_a_iBreite), MG_aGraph(iGraph, 0, #_MG_a_iHoehe), MG_aGraph(iGraph, 0, #_MG_a_iHintergrundfarbe_RGB))	
	
	
	; Gitterlinien und Hilfslinien einzeichnen
	_MG_Graph_plotte_Hauptgitterlinien (iGraph, 0)
	_MG_Graph_plotte_Hilfsgitterlinien (iGraph, 0)
	_MG_Graph_plotte_Bezugslinien(iGraph)
	_MG_Graph_plotte_Hilfslinien(iGraph)
	
	
	; den Graph in die GUI zeichnen
	_MG_Graph_GUI_updaten(iGraph)


	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_initialisieren




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Wert_setzen
; Beschreibung ..: 	legt den neuen Wert für den nächsten Plottvorgang fest
; Syntax.........: 	_MG_Wert_setzen (iGraph.i, iKanal.i, fWert.f)
;
; Parameter .....: 	iGraph.i 	- Graph-Index, auf dem sich die Einstellungen beziehen
;					iKanal.i 	- Kanal-Index, auf dem sich die Einstellungen beziehen
;					fWert.f 	- der Wert, der beim nächsten Plottvorgang dargestellt werden soll
;
; Rückgabewerte .: 	Erfolg 		|  0
;
;                  	Fehler 		| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;								| -2 der Graph ist deaktiviert
;								| -3 der Kanal-Index liegt außerhalb des gültigen Bereichs
;
; Autor .........: 	SBond
;
; Bemerkungen ...:
;
;} ========================================================================================================================================================
Procedure _MG_Wert_setzen (iGraph.i, iKanal.i, fWert.f)
	
	; lokale Variablen deklarieren
	Protected fWert_neu.f													; berechnete Position des neuen Wertes
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	
	
	; Fehler, wenn der Kanal-Index außerhalb des gültigen Bereichs liegt
	If (iKanal > #_MG_max_Anzahl_Kanaele) Or (iGraph <= 0) 
		ProcedureReturn (-3)
	EndIf


	; Berechnung der vertikalen Position des Wertes
	fWert_neu.f = MG_aGraph(iGraph, 0, #_MG_a_iHoehe) - ((fWert - MG_aGraph(iGraph, 0, #_MG_a_iY_min)) * MG_aGraph(iGraph, 0, #_MG_a_fWertaufloesung))


	; den neuen Wert übernehmen
	If (MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) = 0) 
		MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert)	= fWert_neu
	EndIf
	
	MG_aGraph(iGraph, iKanal, #_MG_k_fY_aktueller_Wert)		= fWert_neu


	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Wert_setzen




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_reset
; Beschreibung ..: 	löscht die aktuell geplotteten Werte
; Syntax.........: 	_MG_Graph_reset (iGraph.i)
;
; Parameter .....: 	iGraph.i 	- Graph-Index, auf dem sich die Einstellungen beziehen
;
; Rückgabewerte .: 	Erfolg 		|  0
;
;                  	Fehler 		| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;								| -2 der Graph ist deaktiviert
;
; Autor .........: 	SBond
;
; Bemerkungen ...:	Es werden dabei keine Einstellungen am Graphen verändert
;
;} ========================================================================================================================================================
Procedure _MG_Graph_reset (iGraph.i)
	
	; lokale Variablen deklarieren
	Protected i.i															; allgemeiner Zähler für Schleifen
	Protected iKanal.i														; Index des aktuellen Kanals, der geplottet wird
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	
	
	; Fehler, wenn der Graph deaktiviert ist
	If (MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert) = #False)
		ProcedureReturn (-2)
	EndIf	
	
	
	; die aktuelle Position auf Null setzen
	MG_aGraph(iGraph, 0, #_MG_a_iPosition_aktuell) = 0
	
	
	; den Ausgabekanal für die aktuellen Zeichenoperationen setzen
	If (MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) <> #True)
		
		For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
			MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) = #False			
		Next
		
		MG_aGraph(iGraph, 0, #_MG_a_iZeichnung_aktiv) = #True
		
		StopDrawing()
		StartDrawing(ImageOutput(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)))
		
	EndIf
	
	
	; den Zeichenbereich leeren
	DrawingMode(#PB_2DDrawing_Default)
	Box(0, 0, MG_aGraph(iGraph, 0, #_MG_a_iBreite), MG_aGraph(iGraph, 0, #_MG_a_iHoehe), MG_aGraph(iGraph, 0, #_MG_a_iHintergrundfarbe_RGB))	
	
	
	; Gitterlinien und Hilfslinien einzeichnen
	_MG_Graph_plotte_Hauptgitterlinien (iGraph, 0)
	_MG_Graph_plotte_Hilfsgitterlinien (iGraph, 0)
	_MG_Graph_plotte_Bezugslinien(iGraph)
	_MG_Graph_plotte_Hilfslinien(iGraph)


	; die Werte der einzelnen Kanäle zurücksetzen
	For iKanal = 1 To #_MG_max_Anzahl_Kanaele Step 1

		MG_aGraph(iGraph, iKanal, #_MG_k_fY_aktueller_Wert)	= 0
		MG_aGraph(iGraph, iKanal, #_MG_k_fY_letzter_Wert)	= 0

	Next
	
	
	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_reset




;{ #FUNCTION# ;============================================================================================================================================
;
; Name...........:	_MG_Graph_entfernen
; Beschreibung ..: 	löscht den Graphen aus der GUI
; Syntax.........: 	_MG_Graph_entfernen (iGraph.i)
;
; Parameter .....: 	iGraph.i 	- Graph-Index, auf dem sich die Einstellungen beziehen
;
; Rückgabewerte .: 	Erfolg 		|  0
;
;                  	Fehler 		| -1 der Graph-Index liegt außerhalb des gültigen Bereichs
;
; Autor .........: 	SBond
;
; Bemerkungen ...:  Wichtig: der Graphindex beginnt bei 1. Der Index 0 ist reserviert und darf nicht verwendet werden.
;
;} ========================================================================================================================================================
Procedure _MG_Graph_entfernen (iGraph.i)
	
	; lokale Variablen deklarieren
	Protected i.i															; allgemeiner Zähler für Schleifen
	
	
	; Fehler, wenn der Graph-Index außerhalb des gültigen Bereichs liegt
	If (iGraph > #_MG_max_Anzahl_Graphen) Or (iGraph <= 0) 
		ProcedureReturn (-1)
	EndIf
	

	; alle Zeichenoperationen stoppen (notwendig, wenn Schriftarten geladen werden)
	For i = 1 To #_MG_max_Anzahl_Graphen Step 1			
		MG_aGraph(i, 0, #_MG_a_iZeichnung_aktiv) 	= #False			
	Next
	
	StopDrawing()
	
	
	; den Graphen als deaktiviert markieren
	MG_aGraph(iGraph, 0, #_MG_a_iGraph_aktiviert)	= #False
	

	; Achsenbeschriftungen löschen
	For i = 0 To #_MG_max_Anzahl_Elemente Step 1
		
		; linke Seite (Y-Achse)
		If (IsGadget(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, i)) <> 0)
			
			FreeGadget(MG_aGraph(iGraph, #_MG_b_links_Beschriftung, i))
			FreeGadget(MG_aGraph(iGraph, #_MG_b_links_Strich, i))
			
			MG_aGraph(iGraph, #_MG_b_links_Beschriftung, i) = 0
			MG_aGraph(iGraph, #_MG_b_links_Strich, i) = 0

		EndIf
		
		
		; rechte Seite (Y-Achse)
		If (IsGadget(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, i)) <> 0)
			
			FreeGadget(MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, i))
			FreeGadget(MG_aGraph(iGraph, #_MG_b_rechts_Strich, i))
			
			MG_aGraph(iGraph, #_MG_b_rechts_Beschriftung, i) = 0
			MG_aGraph(iGraph, #_MG_b_rechts_Strich, i) = 0

		EndIf
		
		
		; X-Achse
		If (IsGadget(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, i)) <> 0)
			
			FreeGadget(MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, i))
			FreeGadget(MG_aGraph(iGraph, #_MG_b_unten_Strich, i))
			
			MG_aGraph(iGraph, #_MG_b_unten_Beschriftung, i) = 0
			MG_aGraph(iGraph, #_MG_b_unten_Strich, i) = 0

		EndIf

	Next
	
	
	; Rahmen löschen
	If (IsGadget(MG_aGraph(iGraph, 0, #_MG_a_hRahmen)) <> 0)
		FreeGadget(MG_aGraph(iGraph, 0, #_MG_a_hRahmen))
	EndIf
	
	
	; Frontbuffer löschen
	If (IsGadget(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer)) <> 0)
		FreeGadget(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Frontbuffer))
	EndIf
	
	
	; Backbuffer löschen
	If (IsImage(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer)) <> 0)
		FreeImage(MG_aGraph(iGraph, 0, #_MG_a_hGraph_Backbuffer))
	EndIf
	
	
	; Rückgabewert: Erfolgreich
	ProcedureReturn (0)


EndProcedure	;==> _MG_Graph_entfernen
