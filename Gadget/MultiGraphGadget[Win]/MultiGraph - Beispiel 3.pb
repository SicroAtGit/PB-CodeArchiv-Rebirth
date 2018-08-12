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
; _MG_Graph_plotte_Werte				plottet die neuen Werte in den Graphen und aktualisiert ggf. die Darstellung in der GUI (je nach Einstellungen)
; _MG_Graph_Achse_links					erzeugt eine Achsbeschriftung auf der linken Seite (Y-Achse), die sich an den horizontalen Hauptgitterlinien richtet
; _MG_Graph_Achse_rechts				erzeugt eine Achsbeschriftung auf der rechten Seite (Y-Achse), die sich an den horizontalen Hauptgitterlinien richtet
; _MG_Graph_Achse_unten					erzeugt eine Achsbeschriftung auf der unteren Seite (X-Achse), die sich an den vertikalen Hauptgitterlinien richtet
; _MG_Graph_GUI_updaten					zeichnet den Graph in die GUI bzw. aktualisiert die Darstellung
; _MG_Graph_initialisieren				plottet den Graphen erstmalig in der GUI
; _MG_Wert_setzen						legt den neuen Wert für den nächsten Plottvorgang fest
; _MG_Graph_reset						löscht die aktuell geplotteten Werte
; _MG_Graph_entfernen 					löscht den Graphen aus der GUI


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



XIncludeFile "MultiGraph.pbi"




OpenWindow(0, 0, 0, 800, 600, "MultiGraph - PureBasic - Beispiel 3 - x64", #PB_Window_ScreenCentered | #PB_Window_SystemMenu | #PB_Window_MinimizeGadget)

Global Sin_Counter.d 	= 0




_MG_Graph_erstellen 					(1, 100, 30, 600, 200)
_MG_Graph_optionen_allgemein 			(1, 8000, 0, 2000, RGB(155, 225, 250)) 
_MG_Graph_optionen_Bezugspunkte 		(1, RGBA(255,255,255,150), 0, 0, RGBA(255,255,255,255), 0)
_MG_Graph_optionen_Rahmen 				(1, #True, -1, 1)
_MG_Graph_optionen_Plottmodus			(1, 0, 1, 1, 1)
_MG_Graph_optionen_Hauptgitterlinien	(1, #True, 100, 50, 3 , RGBA(255,0,0,255))
_MG_Graph_optionen_Hilfsgitterlinien	(1, #True, 20, 5, 1 , RGBA(255, 0, 255, 255))
_MG_Graph_Achse_links 					(1, 1, -1, 0, " A", RGB(255,0,0), RGB(200,200,200), "Calibri", 15, 60, 1)
_MG_Graph_Achse_rechts 					(1, 1, 100, 0, " B", RGB(0,255,0), RGB(100,100,0), "Arial", 8, 60, 1/3)
_MG_Graph_Achse_unten 					(1, 1, -1, 0, " C", RGB(0,0,255), RGB(255,0,200), "Calvin", 16, 80, 2)
_MG_Kanal_optionen						(1, 1, #True, 5, RGBA(125,140,0, 255))
_MG_Kanal_optionen						(1, 2, #True, 1, RGBA(0,70,255,255))
_MG_Graph_initialisieren				(1)	




_MG_Graph_erstellen 					(2, 100, 310, 600, 200)
_MG_Graph_optionen_allgemein 			(2, 50, -100, 100, RGB(0, 0, 0)) 
_MG_Graph_optionen_Bezugspunkte 		(2, RGBA(255,255,255,150), 1, 1, RGBA(255,255,255,255), 1)
_MG_Graph_optionen_Rahmen 				(2, #True, -1, 1)
_MG_Graph_optionen_Plottmodus			(2, 0, 0, 2, 0)
_MG_Graph_optionen_Hauptgitterlinien	(2, #True, 50, 50, 1 , RGBA(255,255,255,50))
_MG_Graph_optionen_Hilfsgitterlinien	(2, #True, 10, 10, 1 , RGBA(255, 255, 255, 50))
_MG_Graph_Achse_links 					(2, 1, -1, 0, "", RGB(0,0,0), -1, "Calibri", 11, 60, 1)
_MG_Graph_Achse_rechts 					(2, 1, -1, 0, "", RGB(0,0,0), -1, "Calibri", 11, 60, 1)
_MG_Kanal_optionen						(2, 1, #True, 2, RGBA(0,70,200,255))
_MG_Kanal_optionen						(2, 2, #True, 2, RGBA(0,70,200,255))
_MG_Kanal_optionen						(2, 3, #True, 1, RGBA(0,255,0,110))
_MG_Graph_initialisieren				(2)	




Repeat
	
	; Graph 1 werte plotten
	_MG_Wert_setzen (1, 1, DesktopMouseX())
	_MG_Wert_setzen (1, 2, DesktopMouseY())
	_MG_Graph_plotte_Werte (1)

	
	; Graph 2 werte plotten
	Sin_Counter + 0.12088
	Plottwert_1.d 	= Sin(Sin_Counter) * 80
	Plottwert_2.d 	= Tan(Sin_Counter) * 80
	_MG_Wert_setzen (2, 1, Plottwert_1)
	_MG_Wert_setzen (2, 2, Plottwert_2)
	_MG_Wert_setzen (2, 3, Random(80,0))
	_MG_Graph_plotte_Werte (2)
	
	
	; GUI-Events
	Select WindowEvent()
		
	Case #PB_Event_CloseWindow ; Programm beenden, wenn das Fenster geschlossen wird
		End		
		
	EndSelect

ForEver
