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


Procedure.s _Get_CPU_Name ()
	
  Protected sBuffer.s
  Protected Zeiger1.l, Zeiger2.l, Zeiger3.l, Zeiger4.l

  !MOV eax, $80000002
  !CPUID
  ; the CPU-Name is now stored in EAX-EBX-ECX-EDX
  !MOV [p.v_Zeiger1], EAX ; move eax to the buffer
  !MOV [p.v_Zeiger2], EBX ; move ebx to the buffer
  !MOV [p.v_Zeiger3], ECX ; move ecx to the buffer
  !MOV [p.v_Zeiger4], EDX ; move edx to the buffer

  ;Now move the content of Zeiger (4*4=16 Bytes to a string
  sBuffer = PeekS(@Zeiger1, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger2, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger3, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger4, 4, #PB_Ascii)

  ;Second Part of the Name
  !MOV eax, $80000003
  !CPUID
  ; the CPU-Name is now stored in EAX-EBX-ECX-EDX
  !MOV [p.v_Zeiger1], EAX ; move eax to the buffer
  !MOV [p.v_Zeiger2], EBX ; move ebx to the buffer
  !MOV [p.v_Zeiger3], ECX ; move ecx to the buffer
  !MOV [p.v_Zeiger4], EDX ; move edx to the buffer

  ;Now move the content of Zeiger (4*4=16 Bytes to a string
  sBuffer + PeekS(@Zeiger1, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger2, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger3, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger4, 4, #PB_Ascii)


  ;Third Part of the Name
  !MOV eax, $80000004
  !CPUID
  ; the CPU-Name is now stored in EAX-EBX-ECX-EDX
  !MOV [p.v_Zeiger1], EAX ; move eax to the buffer
  !MOV [p.v_Zeiger2], EBX ; move ebx to the buffer
  !MOV [p.v_Zeiger3], ECX ; move ecx to the buffer
  !MOV [p.v_Zeiger4], EDX ; move edx to the buffer

  ;Now move the content of Zeiger (4*4=16 Bytes to a string
  sBuffer + PeekS(@Zeiger1, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger2, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger3, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger4, 4, #PB_Ascii)

  ProcedureReturn sBuffer
  
EndProcedure

Procedure.w _Mouse_Wheel_Delta ()
		
	Protected x.w = ((EventwParam()>>16)&$FFFF)
	ProcedureReturn -(x / 120)

EndProcedure


OpenWindow(0, 0, 0, 800, 400, "MultiGraph - PureBasic - Beispiel 1 - x64", #PB_Window_ScreenCentered | #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget| #PB_Window_SizeGadget)

Global Graph_X_Pos.i 	= 0
Global Graph_Y_Pos.i 	= 0
Global Graph_Breite.i 	= 0
Global Graph_Hoehe.i 	= 0

Global Hilfslinie_X_Pos = 75
Global Hilfslinie_Y_Pos = 75

Global Mausrad			= 0

Global Bezugspunkt_X 	= 0
Global Wertebereich_min	= -100
Global Wertebereich_max	=  100

Global CPU$				= _Get_CPU_Name ()

Global Label_1			= TextGadget(#PB_Any, 5,  5, 300, 16, CPU$)
Global Label_2 			= TextGadget(#PB_Any, 5, 25, 300, 16, "")

Global Sin_Counter.d 	= 0
Global Plottwert.d		= 0

Global Plott_counter	= 0
Global Zeit_aktuell 	= ElapsedMilliseconds()
Global FPS_Rate.f 		= 0





Procedure _My_Graph (Modus.i = 0)
	
	If (Modus = 1)
		Graph_X_Pos 	= 80
		Graph_Y_Pos 	= 60
		Graph_Breite 	= WindowWidth	(0, #PB_Window_InnerCoordinate) - 250
		Graph_Hoehe		= WindowHeight	(0, #PB_Window_InnerCoordinate) - 150
		_MG_Graph_optionen_position 	(1, Graph_X_Pos, Graph_Y_Pos, Graph_Breite, Graph_Hoehe)
		Delay(10)
	EndIf
	
	_MG_Graph_optionen_allgemein 	(1, Graph_Breite, Wertebereich_min - Mausrad, Wertebereich_max + Mausrad, RGB(255,255,255)) 
	_MG_Graph_optionen_Bezugspunkte (1, RGBA(255,100,0,255), 2, Bezugspunkt_X, RGBA(255,0,0,255), 2)
	_MG_Graph_Achse_links 			(1, 1, -1, 0, " %", RGB(0,0,0), -1, "Calibri", 11, 60, 1)
	_MG_Graph_Achse_rechts 			(1, 1, 20, 1, " V", RGB(0,0,0), -1, "Calibri", 11, 60, 0.5)
	_MG_Graph_Achse_unten 			(1, 1, 5, 2, " ms", RGB(0,0,0), -1, "Calibri", 11, 80, 2)
	_MG_Hilfslinien_optionen		(1, 2, #True, 2, Hilfslinie_X_Pos, Hilfslinie_Y_Pos, 2, 16, -1)
	_MG_Graph_initialisieren		(1)	
	
EndProcedure




; erstellt den Graphen und setzt die Einstellungen
_MG_Graph_erstellen 					(1, 30, 30, 600, 300)
_MG_Graph_optionen_Plottmodus			(1, 0, 0, 2, 1)
_MG_Kanal_optionen						(1, 1, #True, 2, RGBA(0,70,200,255))
_MG_Graph_optionen_Hauptgitterlinien	(1, #True, 50, 50, 1 , -1)
_MG_Graph_optionen_Hilfsgitterlinien	(1, #True, 10, 10, 1 , -1)
_My_Graph(1)




Repeat

	
	; die FPS-Rate berechnen und anzeigen
	If (ElapsedMilliseconds() - Zeit_aktuell >= 1000)
		Zeit_aktuell = ElapsedMilliseconds()		
		FPS_Rate = Plott_counter / Graph_Breite
		SetGadgetText(Label_2, "Graph: " + StrU(Graph_Breite) + "x"+ StrU(Graph_Hoehe) + "          FPS: " + StrF(FPS_Rate, 2) + "          Werte/s: " + StrF(Graph_Breite * FPS_Rate,0))
		Plott_counter = 0
		
	Else
		Plott_counter + 1
		
	EndIf
	
	

	; einen Sinus-Verlauf generieren und plotten
	Sin_Counter + 0.0341478
	Plottwert 	= Sin(Sin_Counter) * 80 + Random(10,0) - Random(10,0)
	_MG_Wert_setzen (1, 1, Plottwert)
	_MG_Graph_plotte_Werte (1)

	
	
	; Graph-Interaktionen mit der Maus vorbereiten
	Maus_Pos_Y_zuletzt = Maus_Pos_Y_aktuell
	Maus_Pos_X_aktuell = WindowMouseX(0)
	Maus_Pos_Y_aktuell = WindowMouseY(0)
	Maus_Pos_Y_Delta = Maus_Pos_Y_aktuell - Maus_Pos_Y_zuletzt
	
	If (Maus_Pos_X_aktuell >= Graph_X_Pos) And (Maus_Pos_X_aktuell <= Graph_Breite + Graph_X_Pos) And (Maus_Pos_Y_aktuell >= Graph_Y_Pos) And (Maus_Pos_Y_aktuell <= Graph_Hoehe + Graph_Y_Pos)
		
		; den Graphen mit der Maus verschieben
		Maus_Pos_Y_Delta_zuletzt = 0
		Maus_Pos_X_Delta_zuletzt = 0
		While GetAsyncKeyState_(#VK_LBUTTON)
			
			Maus_Pos_X_zuletzt = Maus_Pos_X_aktuell
			Maus_Pos_Y_zuletzt = Maus_Pos_Y_aktuell
			
			Maus_Pos_X_aktuell = WindowMouseX(0)
			Maus_Pos_Y_aktuell = WindowMouseY(0)
			
			Maus_Pos_X_Delta = Maus_Pos_X_aktuell - Maus_Pos_X_zuletzt
			Maus_Pos_Y_Delta = Maus_Pos_Y_aktuell - Maus_Pos_Y_zuletzt
			

			Wertebereich_min + Maus_Pos_Y_Delta
			Wertebereich_max + Maus_Pos_Y_Delta

			Bezugspunkt_X + Maus_Pos_X_Delta
				
			If (Maus_Pos_Y_Delta_zuletzt <> Maus_Pos_Y_Delta) Or (Maus_Pos_X_Delta_zuletzt <> Maus_Pos_X_Delta)	
				_My_Graph()
			EndIf
			
			Maus_Pos_Y_Delta_zuletzt = Maus_Pos_Y_Delta
			Maus_Pos_X_Delta_zuletzt = Maus_Pos_X_Delta
			
		Wend
		
		
		; den Graphen mit dem Mausrad zoomen
		If (WindowEvent() = #WM_MOUSEWHEEL) 
			Mausrad - _Mouse_Wheel_Delta() * 10 
			_My_Graph()
		EndIf
		
		; das Hilfskreuz mit der rechten Maustaste setzen und verschieben
		If GetAsyncKeyState_(#VK_RBUTTON)
			Hilfslinie_X_Pos = Maus_Pos_X_aktuell - Graph_X_Pos
			Hilfslinie_Y_Pos = Graph_Hoehe - Maus_Pos_Y_aktuell - Graph_Y_Pos + 120
			_MG_Hilfslinien_optionen (1, 2, #True, 2, Hilfslinie_X_Pos, Hilfslinie_Y_Pos, 2, 16, -1)
		EndIf
		
	EndIf
	
	
	
	; GUI-Events
	Select WindowEvent()
		
	Case #PB_Event_CloseWindow ; Programm beenden, wenn das Fenster geschlossen wird
		End		
		
	Case #PB_Event_SizeWindow  ; Graph-Position und Größe bei Fensterveränderungen anpassen
		_My_Graph(1)

	EndSelect

ForEver
