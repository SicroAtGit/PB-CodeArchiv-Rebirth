;   Description: Custom status bar
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27886
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 SBond
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

CompilerIf #PB_Compiler_OS<>#PB_OS_Windows
  CompilerError "Windows Only!"
CompilerEndIf


EnableExplicit
; 
;- ################### HELP / INFO ########################
;-
; 
;{ #MODUL-INFO# ;===
;
; Modulname..........:	CustomStatusBar
; Version............:	1.0.0.1
; Sprache............:	Deutsch
; PureBasic-Version..:	5.22 LST
; Copyright..........:	Martin Langer (alias SBond)
; 
; Autor..............:	SBond
; Datum..............:	02.04.2014
; E-Mail.............:	SBond.Softwareinfo@gmail.com
;
; Unterstütze OS.....:	Windows (Linux und Mac nicht getestet)
; Architekture.......:	x86, x64
; Zeichensatz........:	ASCII, Unicode
; 
; Wichtige Hinweise..:	Ja, siehe Hilfe ("Einschränkungen und Konflikte")
; 
;} ========



;{ #VERSIONS-GESCHICHTE# ;===
; 
; 1.0.0.1	- 02.04.2014 - Repariert: fehlerhafte Größenanpassung des Fensters (durch die SizeBox)
;						 - Repariert: Tooltips und Ballon-Tipps flackern
;
; 1.0.0.0	- 01.04.2014 - Fertigstellung der Version 1.0
; 0.0.0.0	- 12.02.2014 - Start der Programmierung
; 
;} ========



;{ #STATISTIKEN# ;==
; 
; Compile Count..................:	3855
; Dateigröße.....................:	500,6 KB
; Programmiert unter.............:	Windows 7 Ultimate x64
; 
; Programmzeilen.................:	10484
; Codezeilen.....................:	3786
; Code mit Inline Kommentar......:	596
; Kommentarzeilen................:	3127
; Leerzeilen.....................:	2975
; Kommentar/Code-Verhältnis......:	0,826
; 
; Anzahl der Prozeduren..........:	71
; Public-Prozeduren..............:	55
; Private-Prozeduren.............:	16

;} ========



;{ #HILFE UND HINWEISE# ;====
; 
; Einleitung
; ---------------------------------------------------------------------------
; 
; Wer ein größeres Programm entwickelt und bestimmte Zustände anzeigen möchte, der greift höchstwahrscheinlich zu der StatusBar, die in PureBasic standardgemäß zur
; Verfügung steht. Diese bietet einige Grundfunktionen, um Texte, Symbole und Fortschrittsanzeigen darzustellen. Wer darüber hinaus mehr Funktionen nutzen möchte,
; steht vor einigen Problemen. Schon das Hinzufügen eines Buttons ist nicht so trivial wie es den anschein hat. Wurde dieser erfolgreich über SetParent_() eingebunden,
; so stellt man fest, dass von diesem Button keine Events über WindowEvent() empfangen werden. Auch das Ändern einer Fieldbreite oder das Entfernen eines Fieldes gestaltet
; sich als schwierig.
; 
; Aus diesem Grund wollte ich mir eine eigene Statusleiste programmieren, die ein wenig mehr Spielraum bietet. Herausgekommen ist allerdings die "CustomStatusBar", die wesentlich
; mehr Funktionen bietet, als eigentlich geplant war. Zugegeben.... der Name "CustomStatusBar" ist nicht sehr kreativ, aber sie eignet sich eben nicht nur als klassische
; Statusleiste. Welche Funktionen und Eigenschaften diese "CustomStatusBar" hat, werde ich in den Unterkapiteln näher erläutern.
; 
; 
;
; 
; Definition der Begriffe "CustomStatusBar, Elemente und Fielder"
; ---------------------------------------------------------------------------
; 
; Zunächst möchte ich hier die Begriffe erläutern, die in der Hilfe und im Quellcode immer wieder erwähnt werden. Die wichtigsten drei Begriffe sind: "Elemente", "Fielder"
; und "CustomStatusBar". Nun, die CustomStatusBar ist prinzipiell eine Leiste, wie die StatusBar in PureBasic. Sie unterteilt sich in Fielder, auf denen verschiedene "Elemente"
; dargestellt werden können. Die Anzahl der Fielder ist dabei frei definierbar und kann beliebig angepasst werden. Die Breite eines Fieldes und sein Verhalten wird jedoch
; nicht direkt angegeben (so wie es in der StatusBar der Fall ist), sondern richtet sich nach den "Elementen" die darauf angezeigt werden. Ein Element ist in der CustomStatusBar
; eine Art Gadget, das in einem Field der CustomStatusBar dargestellt werden kann. Die Anzahl der verwendeten Elemente ist dabei unbegrenzt. Jede CustomStatusBar kann zudem mehr
; Elemente verwalten, als angezeigt werden können. Ein Field in der CustomStatusBar kann immer einem Element zugeordnet werden, wobei ein Element auch mehrfach dargestellt werden kann.
; Alle Elemente können ähnlich wie Gadgets erstellt, angepasst und entfernt werden. Dies ist unabhängig davon, ob diese in der CustomStatusBar angezeigt werden oder nicht.
; Die Element-Zuweisung eines Fieldes in der CustomStatusBar geht allerdings nicht nur über explizite Prozeduraufrufe, sondern auch über das Kontextmenü.
; ....ja, jede CustomStatusBar besitzt ein Kontextmenü, mit dessen Hilfe die Fielder leicht angepasst werden können ;)
; 
; 
; 
; 
; Einsatzgebiet der CustomStatusBar und Funktionsumfang
; ---------------------------------------------------------------------------
; 
; Ich denke in diesem Bereich ist es sinnvoll die wichtigsten Funktionen der CustomStatusBar stichpunktartig zu erläutern:
; 
; - jede GUI kann beliebig viele CustomStatusBarn besitzen
; - es können mehrere CustomStatusBarn auf mehreren Fenstern gleichzeitig verwaltet werden
; - die CustomStatusBar kann frei plaziert werden und bietet verschiedene Optionen, sowie Autoresize-Einstellungen
; - CustomStatusBarn können ausgeblendet werden
; - jede CustomStatusBar kann beliebig viele Fielder verwalten
; - jede CustomStatusBar kann beliebig viele Elemente verwalten
; - die SizeBox der CustomStatusBar kann optional ein- und ausgeschaltet werden
; - jede CustomStatusBar besitzt ihre eigenen Elemente
; - die CustomStatusBar, die Elemente und die Fielder werden automatisch synchronisiert
; - das Aktualisierungsintervall kann angepasst werden (siehe Standard-Einstellungen im Modul)
; - alle Elemente generieren Eventinformationen (auch TextFielder)
; - jede CustomStatusBar verfügt über ein eigenes Kontextmenü, das optional auch deaktiviert werden kann
; - das Kontextmenü wird alphabetisch sortiert und unterstützt Symbole, sowie Haupt- und Nebenkategorien
; - jedes Element kann Tooltips und Ballon-Tipps anzeigen
; - Tooltips und Ballon-Tipps können neben dem Text auch einen Titel und ein Symbol anzeigen
; - Tooltips können "live" aktualisiert werden
; - die Parameter und Einstellungen der Element-Typen sind vollkompatibel mit den Gadgets in PureBasic
;
; 
; - unterstützte Element-Typen in der CustomStatusBar:
; ------------------------------------------------
;   ButtonGadget
;   ButtonImageGadget
;   CanvasGadget
;   CheckBoxGadget
;   ComboBoxGadget
;   DateGadget
;   ExplorerComboGadget
;   HyperLinkGadget
;   IPAddressGadget
;   ProgressBarGadget
;   ScrollBarGadget
;   ShortcutGadget
;   SpinGadget
;   StringGadget
;   TextGadget
;   TrackBarGadget
; 
; 
; 
; 
; Einschränkungen und Konflikte
; ---------------------------------------------------------------------------
; 
; Dieses Modul hat leider einige Konfliktpunkte, die ich hier noch erwähnen möchte.
; 
; 1. Kontextmenü-Konflikt:
; -------------------------
; Sobald ein Rechtsklick auf der CustomStatusBar durchgeführt wird, erscheint ein Kontextmenü, das unmittelbar zuvor generiert wurde. Um anschließend die angeklickten
; Menüpunkte auswerten zu können, ist es nötig jedem Menüeintrag eine MenuID zu geben. Diese sind allerdings global im ganzen Programm verfügbar und können im Konflikt
; mit anderen Menüleisten und Popup-Menüs stehen. Um dies zu verhindern, werden die MenuIDs in der CustomStatusBar >= 20000 sein.
; Für den unwahrscheinlichen Fall, dass dies zu einem Konflikt wird, kann der Wert in den Standard-Einstellungen des Moduls angepasst werden.
; 
; 
; 
; 2. OS-Konflikt:
; -------------------------
; Diese CustomStatusBar wurde zur Zeit nur auf Windows getestet. 
; Die Einschränkung auf Linux und Mac richtet sich nur bei den Tooltips (bzw. Ballon-Tipps), da die Prozedur "_Tooltip (...)" WinAPIs verwendet.
; Wird diese deaktiviert, so sollte der Rest auch auf anderen Betriebssystemen laufen
; 
; 
; 
; 
; Programmierstruktur
; ---------------------------------------------------------------------------
; 
; Ich denke es wird vielen sofort auffallen, dass die Namen der Prozeduren und Variablen auf Deutsch sind und eine andere Form aufweisen als üblich.
; Ich habe also statt "MyNewProcedure()" folgende Bezeichnung angewendet: "Meine_neue_Prozedur ()". Der Grund dafür ist ganz einfach: neugier. Ich programmiere erst seit
; knapp 2 Jahren mit verschiedenen Sprachen, wobei ich PureBasic knapp 10 Monate kenne. Mit der deutsch Bezeichnung habe ich mir etwas mehr Übersicht erhofft. Naja, der
; Effekt ist zumindest kleiner als erwartet. Wem es stört, kann ja einfach mit suchen/ersetzen die Namen ändern ;)
; 
; Ich habe mir wirklich Mühe gegeben, den Quellcode so optimal wie möglich zu gestallten und zu dokumentieren. Ich denke es steckt noch Optimierungspotential drin,
; aber von meinem aktuellen Wissensstand sollte es ok sein. Die Dokumentation selber beläuft sich einmal als Inline-Kommentare und als Prozedur-Beschreibung. Letzteres
; findet man immer direkt über der jeweiligen Prozedur.
;
; 
; Variablen:
; -------------------------
; Alle Variablen sind nach außen hin gekapselt und können nicht verändert werden. Die Namen der Variablen habe ich immer mit einem Präfix versehen, um den Datentyp
; kenntlich zu machen:
;
; iVariable.i	-> Integer (verwendet für Ganzzahlen, handles und boolsche Ausdrücke)
; fVariable.f	-> Float
; sVariable.s	-> String
; bVariable.b	-> Byte
;
; 
; ...achja für den Fall, dass die Darstellung verschoben sein sollte: meine Tab-Länge in der PureBasic IDE ist 4 (echter Tab)
; 
; 
; 
; 
; Haftung / Lizenz
; ---------------------------------------------------------------------------
; Dieser Quellcode wird in einem Zustand zu Verfügung gestellt, wie er ist. Die Fehlerfreiheit des Quellcodes wird nicht garantiert und ich übernehme keine
; Verantwortung für Schäden, die diesem Quellcode zugeschrieben werden. Die freie Verwendung, Anpassung und kostenlose Weitergabe, sowie die Anwendung im
; Kommerziellen Bereich sind gestattet, sofern der Bezug des Quellcodes zu dem Autor (SBond) nicht verloren geht.  
; 
;} ========



;{ #DANKE# ;========
; 
; An dieser Stelle möchte ich mich bei jenen bedanken, die mich bei der Entwicklung unterstützt haben. Besonderen Dank gilt:
;
; NicTheQuick
; STARGÅTE
; ts-soft
; RSBasic
; Danilo
; Chimorin
; 
; Die oben genannten User (siehe PureBasic-Forum: http://www.purebasic.fr/german/) haben mir bei Fragen immer zur Seite gestanden und mir wertvolle Tipps gegeben. Natürlich
; bedanke ich mich auch an den Rest der PureBasic-Community und das PureBasic-Entwicklerteam. :)
;
; Zuletzt bedanke ich mich bei meinem Asus-Laptop N70S, der trotz fehlerhafter Sektoren, Abstürze und seiner grotten-schlechten Leistung, mein programmier-gefriemel wohlwollend
; duldete und erstaunlich wenig kurrupte Dateien erzeugte. ...und das trotz des Bügeleisen-Unfalls xD
;  
;} ========



;{ #PROZEDUREN - BESCHREIBUNG# ;======
; 
; ############################################################## PUBLIC ##############################################################
; 
; CustomStatusBar allgemein
; ----------------------------------------
; Create 						erzeugt eine CustomStatusBar, in der Elemente verwaltet werden können
; Remove 						entfernt die angegebene CustomStatusBar und gibt die verwendeten Ressourcen wieder frei
; Hide 					blendet die CustomStatusBar aus oder zeigt diese wieder an
; 	
; ChangeOptions				ändert allgemeine Einstellungen der CustomStatusBar
; ChangeAutoResizeOptions				ermöglicht die automatische Größenanpassung der CustomStatusBar
; 	
; GetElementEvent 						ermittelt, ob das aktuelle Event von einem Element ausgelöst wurde
; 	
; 	
; 	
; Verwalten von Elementen
; ----------------------------------------
; ButtonElement			erstellt ein neues ButtonGadget-Element in der CustomStatusBar
; ButtonImageElement		erstellt ein neues ButtonImageGadget-Element in der CustomStatusBar
; CanvasElement			erstellt ein neues CanvasGadget-Element in der CustomStatusBar
; CheckBoxElement			erstellt ein neues CheckBoxGadget-Element in der CustomStatusBar
; ComboBoxElement			erstellt ein neues ComboBoxGadget-Element in der CustomStatusBar
; DateElement				erstellt ein neues DateGadget-Element in der CustomStatusBar
; ExplorerComboElement 	erstellt ein neues ExplorerComboGadget-Element in der CustomStatusBar
; HyperLinkeElement 		erstellt ein neues HyperLinkGadget-Element in der CustomStatusBar
; IPAddressElement 		erstellt ein neues IPAddressGadget-Element in der CustomStatusBar
; ProgressBarElement 		erstellt ein neues ProgressBarGadget-Element in der CustomStatusBar
; ScrollBarElement 		erstellt ein neues ScrollBarGadget-Element in der CustomStatusBar
; ShortcutElement 			erstellt ein neues ShortcutGadget-Element in der CustomStatusBar
; SpinElement 				erstellt ein neues SpinGadget-Element in der CustomStatusBar
; StringElement			erstellt ein neues StringGadget-Element in der CustomStatusBar
; TextElement				erstellt ein neues TextGadget-Element in der CustomStatusBar
; TrackBarElement 			erstellt ein neues TrackBarGadget-Element in der CustomStatusBar
; 
; GetElementAttribute					gibt einen Attribut-Wert des angegebenen Elements zurück
; GetElementColor						gibt die Farbe des angegebenen Elements im RGB-Format zurück
; GetElementInformation 				gibt allgemeine Informationen über ein Element
; GetElementStatus						gibt den aktuellen Status des angegebenen Elements zurück
; GetElementText						gibt den Textinhalt des angegebenen Elements zurück
; 	
; SetElementAttribute					ändert einen Attribut-Wert des angegebenen Elements
; SetElementWidth						ändert die Abmessung der angegebenen Elemente
; SetElementColor						ändert die Farbe des angegebenen Elements
; SetElementFont					weist dem angegebenen Element eine Schriftart zu
; SetElementStatus						ändert den aktuellen Status des angegebenen Elements
; SetElementText						ändert den Text-Inhalt des angegebenen Elements
; 	
; RemoveElement 						entfernt ein Element vollständig aus der CustomStatusBar
; 	
; 	
; 	
; Verwalten von Element-Items
; ----------------------------------------
; AddElementItem					fügt einem Element ein Item hinzu
; 	
; CountElementItem					gibt die Anzahl der Items eines Elements zurück
; GetElementItemData					gibt den Wert zurück, welcher zuvor für diesen Element-Eintrag mittels SetElementItemData() gespeichert wurde. Dies ermöglicht das Verknüpfen eines individuellen Werts mit den Einträgen eines Element. 
; GetElementItemText					gibt den Textinhalt des angegebenen Eintrags vom angegebenen Element zurück
; 	
; SetElementItemData					speichert den angegebenen Wert mit dem angegebenen Element-Eintrag. Dies ermöglicht das Verknüpfen eines individuellen Werts mit den Einträgen eines Element. 
; SetElementItemImage					ändert das Bild des angegebenen Element-Eintrags
; SetElementItemText					ändert den Text des angegebenen Element-Eintrags
; 	
; ClearElementItems				entfernt alle Items eines Elements
; RemoveElementItem					entfernt ein Item eines Elements
; 
; 	
;
; Fielder der Informationsleiste
; ----------------------------------------
; SetField 								weist einem Field in der CustomStatusBar ein Element zu, erstellt neue Fielder oder entfernt diese
; RemoveField							entfernt das angegebene Field aus der CustomStatusBar
; 	
; 	
; 	
; Kontextmenü der Informationsleiste
; ----------------------------------------
; SetContextMenuOptions				ändert allgemeine Einstellungen des Kontextmenüs einer CustomStatusBar
; SetContextMenuItem 				fügt einem Element ein Kontextmenü-Eintrag hinzu
; RemoveContextMenuItem 			entfernt den Kontextmenü-Eintrag eines Elements
; 	
; 	
; 	
; Tooltip der Informationsleiste
; ----------------------------------------
; SetToolTipOptions 					ändert allgemeine Einstellungen der Tooltips
; SetToolTip 							fügt einem Element ein Tooltip hinzu, ändert dieses oder entfernt es
; RemoveToolTip 						entfernt das Tooltip eines Elements
; 	
; 	
; 	
; Ballon-Tipps der Informationsleiste
; ----------------------------------------
; SetBallonTip 						fügt einem Element ein Ballon-Tipp hinzu, ändert dieses oder entfernt es
; ShowBallonTip 						zeigt ein Ballon-Tipp in der CustomStatusBar an
; HideBallonTip 					blendet ein aktuell angezeigtes Ballon-Tipp aus
; RemoveBallonTip 					entfernt das Ballon-Tipp eines Elements
; 	
; 	
; 	
; ############################################################## PRIVATE ##############################################################	
; 	
; überprüfen der Mausparameter
; ----------------------------------------
; _pruefe_Mausaktion 						gibt die Fieldnummer zurück, über der sich die Maus befindet
; _pruefe_Mausposition 						gibt die Fieldnummer zurück, über der sich die Maus befindet
; 	
;
; 	
; Größenanpassung der CustomStatusBar
; ----------------------------------------
; _CustomStatusBar_groesse_automatisch_anpassen	berechnet anhand der GUI-Abmessung und des gewählten Modus die neuen Maße der CustomStatusBar
; _CustomStatusBar_groesse_anpassen 				ändert die Position und Abmessung der CustomStatusBar und passt die darauf enthaltenen Fielder an
; 	
; 	
; 	
; Verwaltung der Fielder
; ----------------------------------------
; _berechne_Element_Fielder 					berechnet anhand der Abmessung der CustomStatusBar die Positionen und Abmessungen der einzelnen Fielder
; _Fielder_aktualisieren						aktualisiert alle Fielder in der CustomStatusBar und synchonisiert so die Gadgets mit den Element-Einstellungen
; _Fielder_sortieren 						nummeriert die Fielder in der CustomStatusBar neu
; _gebe_Field_des_Elements 					sucht das angegebene Element in den Fieldern der CustomStatusBar und gibt dessen Position zurück
; 	
; 	
; 	
; sonstige Prozeduren
; ----------------------------------------
; _erneuere_CustomStatusBar 						erneuert die Fielder in der CustomStatusBar und tauscht diese ggf. aus
; _gebe_Anzahl_der_Elemente 				zählt die vorhandenen Elemente in der CustomStatusBar (nicht die Fielder)
; _Tooltip 									erzeugt ein Tooltip oder ein Ballon-Tipp
; _zeige_Kontextmenue 						öffnet das Kontextmenü der CustomStatusBar
; 	
; 	
; 	
; BindEvents
; ----------------------------------------
; _Autoresize								BindEvent: ermöglicht die automatische Anpassung der CustomStatusBar bei einer Größenveränderung der GUI
; _Element_Aktualisierung					BindEvent: prüft, ob ein Gadget im Field der CustomStatusBar geändert wurde und synchronisiert anschließEnd die Elemente der CustomStatusBar
; _Menue_Event								BindEvent: prüft, ob ein Eintrag im Kontextmenü ausgewählt wurde und führt diesen anschließEnd aus
; _Timer_Event								BindEvent: aktualisiert periodisch die Tooltips und das Kontextmenü

; 
;} ========



;{ #ZUKÜNFTIGE FUNKTIONEN# ;=
; 
; - mehrere CustomStatusBarn nutzen ein Element-Array
; - Deaktivierung von Elementen (DisableGadget())
; - Flackern der Tooltips unterbinden
; 
;} ========



DeclareModule CustomStatusBar
  
  ;  ############################################################################################################################################################################################
  ;  ######################################################################################     BASIC     #######################################################################################
  ;  ############################################################################################################################################################################################
  
  ;- ################### BASIC ########################
  ;-
  
  EnableExplicit
  
  ;- öffentliche Funktionen deklarieren (PUBLIC)
  ;{ öffentliche Funktionen deklarieren (PUBLIC)
  
  ; CustomStatusBar allgemein
  Declare.i Create 						(iWindow.i, iMax_Elements_visible.i = 10, iX_Pos.i = #PB_Default, iY_Pos.i = #PB_Default, iWidth.i = #PB_Default, iHeight.i = #PB_Default, iY_Pos_Offset.i = 0)
  Declare.i Remove 						(iCustomStatusBar_ID.i)
  Declare.i Hide 					(iCustomStatusBar_ID.i, iStatus.i = #True)
  
  Declare.i ChangeOptions				(iCustomStatusBar_ID.i, iBackgroundColor.i = #PB_Default, iBorder_hide.i = #False, iSizeBox_hide.i = #False, iSeparator_hide.i = #False, iRefreshRate.i = #PB_Default)
  Declare.i ChangeAutoResizeOptions				(iCustomStatusBar_ID.i, iActive.i = #True, iMode.i = 1)
  
  Declare.i GetElementEvent 						(iCustomStatusBar_ID.i, iWindowEvent.i)
  
  
  
  ; Verwalten von Elementen
  Declare.i ButtonElement			(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iFlags.i = 0)
  Declare.i ButtonImageElement		(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iImage_ID.i = 0, iFlags.i = 0)
  Declare.i CanvasElement			(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iImage.i = 0, iFlags.i = 0, iAuto_scaling.i = #False)
  Declare.i CheckBoxElement			(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iFlags.i = 0)
  Declare.i ComboBoxElement			(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iFlags.i = 0)
  Declare.i DateElement				(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sMaske.s = "", iDate.i = 0, iFlags.i = 0)
  Declare.i ExplorerComboElement 	(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sDirectory.s = "", iFlags.i = 0)
  Declare.i HyperLinkeElement 		(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iColor.i = #PB_Default, iFlags.i = 0)
  Declare.i IPAddressElement 		(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore)	
  Declare.i ProgressBarElement 		(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iFlags.i = 0)
  Declare.i ScrollBarElement 		(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iPageSize.i = 20, iFlags.i = 0)
  Declare.i ShortcutElement 			(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iShortcutKey.i = 0)
  Declare.i SpinElement 				(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iFlags.i = 0)
  Declare.i StringElement			(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sValue.s = "", iFlags.i = 0)
  Declare.i TextElement				(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iFlags.i = 0)
  Declare.i TrackBarElement 			(iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iFlags.i = 0)
  
  Declare.i GetElementAttribute					(iCustomStatusBar_ID.i, iElement_ID.i, iAttribute.i)
  Declare.i GetElementColor						(iCustomStatusBar_ID.i, iElement_ID.i, iColor_Typ.i)
  Declare.s GetElementInformation 				(iCustomStatusBar_ID.i, iElement_ID.i, sInformation.s = "Field")
  Declare.i GetElementStatus						(iCustomStatusBar_ID.i, iElement_ID.i)
  Declare.s GetElementText						(iCustomStatusBar_ID.i, iElement_ID.i)
  
  Declare.i SetElementAttribute					(iCustomStatusBar_ID.i, iElement_ID.i, iAttribute.i, iValue.i)	
  Declare.i SetElementWidth						(iCustomStatusBar_ID.i, iElement_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Default)
  Declare.i SetElementColor						(iCustomStatusBar_ID.i, iElement_ID.i, iColor_Typ.i, iColor.i)	
  Declare.i SetElementFont					(iCustomStatusBar_ID.i, iElement_ID.i, sFontName.s = "", iHeight.i = #PB_Default, iFlags.i = #PB_Default)
  Declare.i SetElementStatus						(iCustomStatusBar_ID.i, iElement_ID.i, iStatus.i)
  Declare.i SetElementText						(iCustomStatusBar_ID.i, iElement_ID.i, sText.s)
  
  Declare.i RemoveElement 						(iCustomStatusBar_ID.i, iElement_ID.i)
  
  
  
  ; Verwalten von Element-Items
  Declare.i AddElementItem					(iCustomStatusBar_ID.i, iElement_ID.i, iPosition.i, sText.s, iImage_ID.i = 0)
  
  Declare.i CountElementItem					(iCustomStatusBar_ID.i, iElement_ID.i)
  Declare.i GetElementItemData					(iCustomStatusBar_ID.i, iElement_ID.i, iItem.i)
  Declare.s GetElementItemText					(iCustomStatusBar_ID.i, iElement_ID.i, iItem.i)
  
  Declare.i SetElementItemData					(iCustomStatusBar_ID.i, iElement_ID.i, iItem.i, iValue.i)
  Declare.i SetElementItemImage					(iCustomStatusBar_ID.i, iElement_ID.i, iItem.i, iImage_ID.i)
  Declare.i SetElementItemText					(iCustomStatusBar_ID.i, iElement_ID.i, iItem.i, sText.s)
  
  Declare.i ClearElementItems				(iCustomStatusBar_ID.i, iElement_ID.i)
  Declare.i RemoveElementItem					(iCustomStatusBar_ID.i, iElement_ID.i, iPosition.i)
  
  
  
  ; Fielder der Informationsleiste
  Declare.i SetField 								(iCustomStatusBar_ID.i, iField.i, iElement_ID.i = #PB_Default)
  Declare.i RemoveField							(iCustomStatusBar_ID.i, iField.i)
  
  
  
  ; Kontextmenü der Informationsleiste
  Declare.i SetContextMenuOptions				(iCustomStatusBar_ID.i, iContextMenu_activ.i = #True, iHeadline.i = #True, sEntry_add.s = "Add entry", sEntry_remove.s = "Remove entry", iEntry_add_Image.i = #PB_Default, iEntry_remove_Image.i = #PB_Default)
  Declare.i SetContextMenuItem 				(iCustomStatusBar_ID.i, iElement_ID.i, sMenu_Item.s, sMainCategory.s = "", sSubCategory.s = "", iIcon.i = #PB_Ignore)
  Declare.i RemoveContextMenuItem 			(iCustomStatusBar_ID.i, iElement_ID.i)
  
  
  
  ; Tooltip der Informationsleiste
  Declare.i SetToolTipOptions 					(iCustomStatusBar_ID.i, iTollTip_activ.i = #True, iRefreshRate.i = #PB_Default, iToolTip_Delay.i = #PB_Default)
  Declare.i SetToolTip 							(iCustomStatusBar_ID.i, iElement_ID.i, sText.s, sTitle.s = "", sIcon.s = "none")
  Declare.i RemoveToolTip 						(iCustomStatusBar_ID.i, iElement_ID.i)
  
  
  
  ; Ballon-Tipps der Informationsleiste
  Declare.i SetBallonTip 						(iCustomStatusBar_ID.i, iElement_ID.i, sText.s, sTitle.s = "", sIcon.s = "none", iDisplayTime.i = #PB_Default, iClose_Button.i = #True)
  Declare.i ShowBallonTip 						(iCustomStatusBar_ID.i, iElement_ID.i, iReset.i = #True)
  Declare.i HideBallonTip 					(iCustomStatusBar_ID.i)
  Declare.i RemoveBallonTip 					(iCustomStatusBar_ID.i, iElement_ID.i)
  
  ;} öffentliche Funktionen deklarieren (PUBLIC)
  
EndDeclareModule




Module CustomStatusBar
  
  ;- interne Funktionen deklarieren (PRIVATE)
  ;{ interne Funktionen deklarieren (PRIVATE)
  
  ; überprüfen der Mausparameter
  Declare.s _pruefe_Mausaktion 						()
  Declare.i _pruefe_Mausposition 						(iCustomStatusBar_ID.i)
  
  
  
  ; Größenanpassung der CustomStatusBar
  Declare.i _CustomStatusBar_groesse_automatisch_anpassen	(iCustomStatusBar_ID.i)
  Declare.i _CustomStatusBar_groesse_anpassen 				(iCustomStatusBar_ID.i, iX_Pos.i, iY_Pos.i, iWidth.i, iHeight.i)
  
  
  
  ; Verwaltung der Fielder
  Declare.i _berechne_Element_Fielder 					(iCustomStatusBar_ID.i)
  Declare.i _Fielder_aktualisieren						(iCustomStatusBar_ID.i)	
  Declare.i _Fielder_sortieren 						(iCustomStatusBar_ID.i)
  Declare.i _gebe_Field_des_Elements 					(iCustomStatusBar_ID.i, iElement_ID.i, iFund.i = 1)	
  
  
  
  ; sonstige Prozeduren
  Declare.i _erneuere_CustomStatusBar 						(iCustomStatusBar_ID.i)
  Declare.i _gebe_Anzahl_der_Elemente 				(iCustomStatusBar_ID.i)
  Declare.i _Tooltip 									(iCustomStatusBar_ID.i, sText.s , sTitle.s = "", sIcon.s = "none", iX_Pos.i = #PB_Default, iY_Pos.i = #PB_Default, iMax_Width.i = #PB_Default, iBallon.i = #False, iSchliessen.i = #False)	
  Declare.i _zeige_Kontextmenue 						(iCustomStatusBar_ID.i)
  
  
  
  ; BindEvents
  Declare.i _Autoresize								()
  Declare.i _Element_Aktualisierung					()
  Declare.i _Menue_Event								()	
  Declare.i _Timer_Event								()
  
  ;} interne Funktionen deklarieren (PRIVATE)
  
  
  ; BindEvent-Verknüpfungen
  BindEvent(#PB_Event_Timer, 							@_Timer_Event())
  BindEvent(#PB_Event_SizeWindow,						@_Autoresize())
  BindEvent(#PB_Event_Gadget,							@_Element_Aktualisierung())
  BindEvent(#PB_Event_Menu,							@_Menue_Event())
  
  
  ;- Modul-Strukturen deklarieren
  ;{ Modul-Strukturen deklarieren
  
  Enumeration
    ; Gadget-Nummerierung (für die Standardeinstellungen)
    #ButtonGadget
    #ButtonImageGadget
    #CanvasGadget
    #CheckBoxGadget
    #ComboBoxGadget
    #DateGadget
    #ExplorerComboGadget
    #HyperLinkGadget
    #IPAddressGadget
    #ProgressBarGadget
    #ScrollBarGadget
    #ShortcutGadget
    #SpinGadget
    #StringGadget
    #TextGadget
    #TrackBarGadget
    
    ; letzter Eintrag (entspricht die Arraygröße)
    #Gadget_Anzahl
  EndEnumeration
  
  
  ; allgemeine Gadgets-Einstellungen
  Structure Gadget_Standard_Einstellungen
    _iMin_Width.i									; Standardwert für die minimale Elementbreite in der CustomStatusBar
    _iY_Pos_Offset.i                ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  EndStructure
  
  
  ; allgemeine Einstellungen der CustomStatusBar
  Structure standard_Einstellungen__Allgemein
    _iAutoresize_Aktiviert.i						; Bool: aktiviert bei #True die automatische Größenanpassung der CustomStatusBar und der darauf befindlichen Gadgets
    _iAutoresize_Modus.i                ; definiert die Art der Größenveränderung bei aktiviertem Autoresize (siehe Prozedur: _CustomStatusBar_groesse_automatisch_anpassen())
    _iSizeBox_Aktiviert.i               ; Bool: aktiviert bei #True die Darstellung einer SizeBox in der rechten unteren Ecke der CustomStatusBar, um die Größe des Fensters leicher anpassen zu können
    
    _iStandard_Hoehe.i								; die vordefinierte Standardhöhe der CustomStatusBar
    _iHintergrundfabe.i               ; die vordefinierte Hintergrundfarbe der CustomStatusBar
    
    _iMin_Abstand_der_Elemente.i					; der minimale Abstand (in Pixel) zwischen zwei dargestellten Elementen in der CustomStatusBar
    _iGadget_Bereich_Offset_Breite.i      ; der horizontale Mindestabstand zwichen den Rahmen der CustomStatusBar und den Elementen
    _iGadget_Bereich_Offset_Hoehe.i       ; der vertikale Mindestabstand zwichen den Rahmen der CustomStatusBar und den Elementen
    
    _iBorder_hide.i							; Bool: blendet bei #True den Rahmen der CustomStatusBar aus
    _iSeparator_hide.i          ; Bool: blendet bei #True die Separatoren zwischen den Elementen in der CustomStatusBar aus
    
    _iCustomStatusBar_Timer_Intervall.i					; Aktualisierungsintervall der CustomStatusBar (in Millisekunden)
    _iCustomStatusBar_Timer_Start_ID.i           ; die Startnummer (Offset) für die erstellten Timer-IDs
    _iCustomStatusBar_Timer_Reserve.i            ; reservierte Timer-IDs pro CustomStatusBar
  EndStructure
  
  
  ; allgemeine Einstellungen des Kontextmenüs
  Structure standard_Einstellungen__Kontextmenue
    _iKontextmenue_Aktiviert.i						; Bool: ermöglicht bei #True die Darstellung des Kontextmenüs
    _iKontextmenue_Timer_Intervall.i      ; Aktualisierungsintervall in Millisekunden (Abfrage des Kontextmenüs)
    
    _iHeadline_anzeigen.i						; Bool: zeigt bei #True eine Überschrift im Kontextmenü an, die dem Kontextmenü-Eintrags des aktuellen Elements entspricht
    _iHeadline_Symbol_erlauben.i    ; Bool: erlaubt bei #True die Darstellung eines Symbols in der Überschrift
    _sEintrag_Fielder_erstellen_Text.s   ; Text, für das Hinzufügen neuer Elemente in der CustomStatusBar (oder "" um den Kontextmenü-Eintrag zu löschen)
    _sEintrag_Fielder_entfernen_Text.s   ; Text, für das Entfernen des markierten Elements in der CustomStatusBar (oder "" um den Kontextmenü-Eintrag zu löschen)
    _iItem_Field_erstellen_Symbol.i   ; handle zu einem Image, das im Kontextmenüeintrag "Eintrag hinzufügen" angezeigt werden soll
    _iItem_Field_entfernen_Symbol.i   ; handle zu einem Image, das im Kontextmenüeintrag "diesen Eintrag entfernen" angezeigt werden soll
    
    _iMenueItem_Start.i								; Start-ID für die Kontextmenüeinträge (Offset)
    _iMenueItem_Reserviert.i          ; reservierte Menü-IDs pro CustomStatusBar
    _iMenueItem_Reserviert_erweitert.i; zusätzlicher Offset für weiter Kontextmenüeinträge
  EndStructure
  
  
  ; Eigenschaften der Tooltips und Ballon-Tipps
  Structure standard_Einstellungen__Tooltips
    _iTooltip_Aktiviert.i							; Bool: ermöglicht bei #True die Darstellung von Tooltips
    _iToolTip_Delay.i          ; Zeit die der Mauszeiger über ein Field in der CustomStatusBar verbleiben muss, um ein Tooltip anzuzeigen (in Millisekunden)
    _iTooltip_Timer_Intervall.i       ; Aktualisierungsintervall der dargestellten Tooltips (in Millisekunden)
    _iBallon_Info_Anzeigedauer.i      ; maximale Anzeigedauer eines Ballon-Tipps (in Millisekunden)
  EndStructure	
  
  
  ; Struktur für die Standardeinstellungen erzeugen
  Structure standard_Einstellungen
    Allgemein.standard_Einstellungen__Allgemein
    Kontextmenue.standard_Einstellungen__Kontextmenue
    Tooltips.standard_Einstellungen__Tooltips
    Array Gadgets.Gadget_Standard_Einstellungen(#Gadget_Anzahl)
  EndStructure
  
  Global standard_Einstellungen.standard_Einstellungen
  
  
  
  
  
  ; Eigenschaften eines Kontextmenüeintrags
  Structure Element_Kontextmenue
    _iKontext_Menue_ID.i							; die ID-Nummer des Kontextmenü-Eintrags
    _sKontext_Menue_Eintrag.s         ; der dargestellte Text im Kontextmenü-Eintrag
    _iKontext_Menue_Eintrag_Symbol.i  ; handle zum Image: optionales Symbol für den Kontextmenü-Eintrag
    _sKontext_Menue_Hauptkategorie.s  ; die Hauptkategorie (Sub-Menü) im Kontextmenü
    _sKontext_Menue_Nebenkategorie.s  ; die Nebenkategorie (Sub-Sub-Menü) im Kontextmenü
  EndStructure
  
  
  
  ; Eigenschaften der Tooltips
  Structure Element_Tooltip
    _sText.s										; der darzustellende Text im Tooltip
    _sTitle.s                   ; der Text des optionalen Titels im Tooltip
    _sIcon.s                  ; das optional darzustellende Symbol "none", "Info", "Warning", "Error"
  EndStructure
  
  
  ; Eigenschaften der Ballon-Tipps
  Structure Element_Ballon_Info
    _sText.s										; der darzustellende Text im Ballon-Tipp
    _sTitle.s                   ; der Text des optionalen Titels im Ballon-Tipp
    _sIcon.s                  ; das optional darzustellende Symbol "none", "Info", "Warning", "Error"
    _iDisplayTime.i            ; die Anzeigedauer des Ballon-Tipp, bevor es automatisch ausgeblendet wird
    _iClose_Button.i            ; Bool: fügt bei #True dem Ballon-Tipp einen Schließen-Button hinzu. Dies ermöglicht die manuelle Ausblendung
  EndStructure
  
  
  ; Eigenschaften eines ButtonGadget-Elements
  Structure Element_ButtonGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _sFontName_Name.s             ; Name der verwendeten Schriftart
    _iSchriftart_Hoehe.i            ; Höhe der verwendeten Schriftart
    _iSchriftart_Flags.i            ; zusätzliche Flags der verwendeten Schriftart
    _iSchriftart_ID.i               ; die ID der erzeugten Schriftart (#Font-Nummer)
    _iSchriftart_Update.i           ; Bool: aktualisiert bei #True die Schriftart des Elements
    _sText.s                        ; der darzustellende Text
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _iStatus.i                      ; aktueller Status des Elements (nur beim Flag: #PB_Button_Toggle --> 1: gedrückt   0: nicht gedrückt)
  EndStructure
  
  
  ; Eigenschaften eines ButtonImageGadget-Elements
  Structure Element_ButtonImageGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _iImage_ID_normal.i             ; handle zum Image, dass in angezeigt werden soll (Button normal)
    _iImage_ID_gedrueckt.i          ; handle zum Image, dass in angezeigt werden soll (Button gedrückt)
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _iStatus.i                      ; aktueller Status des Elements (nur beim Flag: #PB_Button_Toggle --> 1: gedrückt   0: nicht gedrückt)
  EndStructure
  
  
  ; Eigenschaften eines CanvasGadget-Elements
  Structure Element_CanvasGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _iImage.i                       ; handle zum Image, das angezeigt werden soll
    _iAutoanpassung.i               ; Bool: skaliert bei #True das Image auf die Höhe der CustomStatusBar
  EndStructure
  
  
  ; Eigenschaften eines CheckBoxGadget-Elements
  Structure Element_CheckBoxGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _sFontName_Name.s             ; Name der verwendeten Schriftart
    _iSchriftart_Hoehe.i            ; Höhe der verwendeten Schriftart
    _iSchriftart_Flags.i            ; zusätzliche Flags der verwendeten Schriftart
    _iSchriftart_ID.i               ; die ID der erzeugten Schriftart (#Font-Nummer)
    _iSchriftart_Update.i           ; Bool: aktualisiert bei #True die Schriftart des Elements
    _sText.s                        ; der darzustellende Text
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _iStatus.i                      ; aktueller Status des Elements (siehe PureBasic-Hilfe: GetGadgetState())
  EndStructure
  
  
  ; Eigenschaften eines ComboBoxGadget-Elements
  Structure Element_ComboBoxGadget_Item
    _iBelegt.i										; Bool: dieser Eintrag im ComboBoxGadget-Array wird mit #True als belegt markiert
    _sText.s                      ; der darzustellende Text im ComboBox-Eintrag
    _iImage_ID.i                  ; handle zum Image, das angezeigt werden soll
    _iValue.i                      ; zusätlich gespeicherter Wert, der an diesem Eintrag gebunden ist
    _iPosition.i                  ; aktuelle Position in der ComboBox-Liste
  EndStructure
  
  
  ; Eigenschaften eines ComboBoxGadget-Elements
  Structure Element_ComboBoxGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _sFontName_Name.s             ; Name der verwendeten Schriftart
    _iSchriftart_Hoehe.i            ; Höhe der verwendeten Schriftart
    _iSchriftart_Flags.i            ; zusätzliche Flags der verwendeten Schriftart
    _iSchriftart_ID.i               ; die ID der erzeugten Schriftart (#Font-Nummer)
    _iSchriftart_Update.i           ; Bool: aktualisiert bei #True die Schriftart des Elements
    _iUpdate_Text.i                 ; Bool: aktualisiert bei #True den Text, der in der ComboBox angezeigt werden soll
    _iUpdate_Status.i               ; Bool: aktualisiert bei #True den markierten Eintrag in der ComboBox
    _iStatus.i                      ; aktueller Status des Elements (siehe PureBasic-Hilfe: GetGadgetState())
    _sText.s                        ; der darzustellende Text
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    Array Item.Element_ComboBoxGadget_Item(1)		; Array mit den Items, die an dieses Element gebunden werden
  EndStructure
  
  
  ; Eigenschaften eines DateGadget-Elements
  Structure Element_DateGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _sFontName_Name.s             ; Name der verwendeten Schriftart
    _iSchriftart_Hoehe.i            ; Höhe der verwendeten Schriftart
    _iSchriftart_Flags.i            ; zusätzliche Flags der verwendeten Schriftart
    _iSchriftart_ID.i               ; die ID der erzeugten Schriftart (#Font-Nummer)
    _iSchriftart_Update.i           ; Bool: aktualisiert bei #True die Schriftart des Elements
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _sMaske.s                       ; das Format, in welchem das Datum eingegeben werden kann
    _iDate.i                       ; das anfänglich anzuzeigende Datum 
    _iMin_Datum.i                   ; legt das kleinste Datum fest, welches eingegeben werden kann
    _iMax_Datum.i                   ; legt das größte Datum fest, welches eingegeben werden kann
    _iBackgroundColor.i            ; verwendete Hintergrundfarbe
    _iVordergrundfarbe.i            ; Textfarbe für angezeigte Tage
    _iTitel_Hintergrundfarbe.i      ; Hintergrundfarbe für den MonatsTitle
    _iTitel_Vordergrundfarbe.i      ; Textfarbe für den MonatsTitle
    _iAusgegraute_Farbe.i           ; Textfarbe für Tage, welche nicht im aktuellen Monat liegen
  EndStructure
  
  
  ; Eigenschaften eines ExplorerComboGadget-Elements
  Structure Element_ExplorerComboGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _sFontName_Name.s             ; Name der verwendeten Schriftart
    _iSchriftart_Hoehe.i            ; Höhe der verwendeten Schriftart
    _iSchriftart_Flags.i            ; zusätzliche Flags der verwendeten Schriftart
    _iSchriftart_ID.i               ; die ID der erzeugten Schriftart (#Font-Nummer)
    _iSchriftart_Update.i           ; Bool: aktualisiert bei #True die Schriftart des Elements
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _sDirectory.s                 ; das aktuell angezeigte Verzeichnis
  EndStructure
  
  
  ; Eigenschaften eines yperLinkGadget-Elements
  Structure Element_HyperLinkGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _sFontName_Name.s             ; Name der verwendeten Schriftart
    _iSchriftart_Hoehe.i            ; Höhe der verwendeten Schriftart
    _iSchriftart_Flags.i            ; zusätzliche Flags der verwendeten Schriftart
    _iSchriftart_ID.i               ; die ID der erzeugten Schriftart (#Font-Nummer)
    _iSchriftart_Update.i           ; Bool: aktualisiert bei #True die Schriftart des Elements
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _sText.s                        ; der darzustellende Text
    _iSchriftfarbe.i                ; die Schriftfarbe des Textes
    _iHover_farbe.i                 ; die hervorgehobene Schriftfarbe des Textes
    _iBackgroundColor.i            ; die Hintergrundfarbe des Textes
  EndStructure
  
  
  ; Eigenschaften eines IPAddressGadget-Elements
  Structure Element_IPAddressGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _sFontName_Name.s             ; Name der verwendeten Schriftart
    _iSchriftart_Hoehe.i            ; Höhe der verwendeten Schriftart
    _iSchriftart_Flags.i            ; zusätzliche Flags der verwendeten Schriftart
    _iSchriftart_ID.i               ; die ID der erzeugten Schriftart (#Font-Nummer)
    _iSchriftart_Update.i           ; Bool: aktualisiert bei #True die Schriftart des Elements
    _iIP_Field_1.i                   ; die IP-Nummer des ersten Fieldes (0-255)
    _iIP_Field_2.i                   ; die IP-Nummer des zweiten Fieldes (0-255)
    _iIP_Field_3.i                   ; die IP-Nummer des dritten Fieldes (0-255)
    _iIP_Field_4.i                   ; die IP-Nummer des vierten Fieldes (0-255)
  EndStructure		
  
  
  ; Eigenschaften eines ProgressBarGadget-Elements
  Structure Element_ProgressBarGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _iValue.i                        ; aktueller Wert
    _iMinimum.i                     ; der minimale Wert
    _iMaximum.i                     ; der maximale Wert
  EndStructure	
  
  
  ; Eigenschaften eines ScrollBarGadget-Elements
  Structure Element_ScrollBarGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _iValue.i                        ; aktueller Wert
    _iMinimum.i                     ; der minimale Wert
    _iMaximum.i                     ; der maximale Wert
    _iPageSize.i                ; der Bereich, welcher Bestandteil der aktuell angezeigten "Seite" ist
  EndStructure
  
  
  ; Eigenschaften eines ShortcutGadget-Elements
  Structure Element_ShortcutGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _sFontName_Name.s             ; Name der verwendeten Schriftart
    _iSchriftart_Hoehe.i            ; Höhe der verwendeten Schriftart
    _iSchriftart_Flags.i            ; zusätzliche Flags der verwendeten Schriftart
    _iSchriftart_ID.i               ; die ID der erzeugten Schriftart (#Font-Nummer)
    _iSchriftart_Update.i           ; Bool: aktualisiert bei #True die Schriftart des Elements
    _iShortcutKey.i               ; das aktuell anzuzeigende Tastenkürzel
  EndStructure		
  
  
  ; Eigenschaften eines SpinGadget-Elements
  Structure Element_SpinGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _sFontName_Name.s             ; Name der verwendeten Schriftart
    _iSchriftart_Hoehe.i            ; Höhe der verwendeten Schriftart
    _iSchriftart_Flags.i            ; zusätzliche Flags der verwendeten Schriftart
    _iSchriftart_ID.i               ; die ID der erzeugten Schriftart (#Font-Nummer)
    _iSchriftart_Update.i           ; Bool: aktualisiert bei #True die Schriftart des Elements
    _iEvent_Typ.i                   ; die Art der letzten Aktualisierung:  #PB_EventType_Change   #PB_EventType_Up   #PB_EventType_Down
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _iValue.i                        ; der aktuelle Wert, der dargestellt wird
    _sText.s                        ; der darzustellende Text
    _iSchriftfarbe.i                ; die Schriftfarbe des Textes
    _iBackgroundColor.i            ; die Hintergrundfarbe des Textes
    _iMinimum.i                     ; der minimale Wert
    _iMaximum.i                     ; der maximale Wert
  EndStructure	
  
  
  ; Eigenschaften eines StringGadget-Elements
  Structure Element_StringGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _sFontName_Name.s             ; Name der verwendeten Schriftart
    _iSchriftart_Hoehe.i            ; Höhe der verwendeten Schriftart
    _iSchriftart_Flags.i            ; zusätzliche Flags der verwendeten Schriftart
    _iSchriftart_ID.i               ; die ID der erzeugten Schriftart (#Font-Nummer)
    _iSchriftart_Update.i           ; Bool: aktualisiert bei #True die Schriftart des Elements
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _iMaximum.i                     ; die maximale Stringlänge
    _iSchriftfarbe.i                ; die Schriftfarbe des Textes
    _iBackgroundColor.i            ; die Hintergrundfarbe des Textes
    _sValue.s                      ; der darzustellende Text
  EndStructure	
  
  
  ; Eigenschaften eines TextGadget-Elements
  Structure Element_TextGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _sFontName_Name.s             ; Name der verwendeten Schriftart
    _iSchriftart_Hoehe.i            ; Höhe der verwendeten Schriftart
    _iSchriftart_Flags.i            ; zusätzliche Flags der verwendeten Schriftart
    _iSchriftart_ID.i               ; die ID der erzeugten Schriftart (#Font-Nummer)
    _iSchriftart_Update.i           ; Bool: aktualisiert bei #True die Schriftart des Elements
    _sStatustext.s                  ; der darzustellende Text
    _iSchriftfarbe.i                ; die Schriftfarbe des Textes
    _iBackgroundColor.i            ; die Hintergrundfarbe des Textes
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
  EndStructure
  
  
  ; Eigenschaften eines TrackBarGadget-Elements
  Structure Element_TrackBarGadget
    _iUpdate_Flag.i									; Bool: sorgt bei #True für die Aktualisierung dieses Elements in den Fieldern der CustomStatusBar
    _iFlags.i                       ; zusätzliche Flags des verwendeten Elements
    _iValue.i                        ; der aktuelle Wert, der dargestellt wird
    _iMinimum.i                     ; der minimale Wert
    _iMaximum.i                     ; der maximale Wert
  EndStructure	
  
  
  ; Element-Eigenschaften
  Structure Element
    _iBelegt.i										; Bool: dieser Eintrag im Element-Array wird mit #True als belegt markiert
    _sElement_Typ.s                ; Typ des Gadgets in diesem Element. Entspricht den Namen der PureBasic-Gadgets (z.B. "TextElement", "CanvasElement", ...)
    _iMin_Width.i                ; minimale Breite des Elements in der CustomStatusBar
    _iMax_Width.i                ; maximale Breite des Elements in der CustomStatusBar (#PB_Ignore für unbegrenzte Breite)
    
    Kontextmenue.Element_Kontextmenue
    
    Ballon_Info.Element_Ballon_Info
    Tooltip.Element_Tooltip
    
    ButtonGadget.Element_ButtonGadget
    ButtonImageGadget.Element_ButtonImageGadget
    CanvasGadget.Element_CanvasGadget
    CheckBoxGadget.Element_CheckBoxGadget
    ComboBoxGadget.Element_ComboBoxGadget
    DateGadget.Element_DateGadget
    ExplorerComboGadget.Element_ExplorerComboGadget
    HyperLinkGadget.Element_HyperLinkGadget
    IPAddressGadget.Element_IPAddressGadget
    ProgressBarGadget.Element_ProgressBarGadget
    ScrollBarGadget.Element_ScrollBarGadget
    ShortcutGadget.Element_ShortcutGadget
    SpinGadget.Element_SpinGadget
    StringGadget.Element_StringGadget
    TextGadget.Element_TextGadget
    TrackBarGadget.Element_TrackBarGadget
  EndStructure
  
  
  ; allgemeine Eigenschaften der CustomStatusBar
  Structure CustomStatusBar_Allgemein
    _iBelegt.i										; Bool: dieser Eintrag im CustomStatusBarn-Array wird mit #True als belegt markiert
    
    _iVersteckt.i									; Bool: versteckt bei #True die komplette CustomStatusBar (Tooltips und Kontextmenü werden deaktiviert)
    _iBorder_hide.i         ; Bool: blendet bei #True den Rahmen der CustomStatusBar aus
    _iSeparator_hide.i      ; Bool: blendet bei #True die Separatoren zwischen den Elementen in der CustomStatusBar aus
    
    _iAutoresize_Aktiviert.i						; Bool: aktiviert bei #True die automatische Größenanpassung der CustomStatusBar und der darauf befindlichen Gadgets
    _iAutoresize_Modus.i                ; definiert die Art der Größenveränderung bei aktiviertem Autoresize (siehe Prozedur: _CustomStatusBar_groesse_automatisch_anpassen())
    
    _iSizeBox_Aktiviert.i							; Bool: aktiviert bei #True die Darstellung einer SizeBox in der rechten unteren Ecke der CustomStatusBar, um die Größe des Fensters leicher anpassen zu können
    _iSizeBox_Maus_X.i                ; Delta-Mausposition (X-Koordinate) um die neue Fenstergröße berechnen zu können
    _iSizeBox_Maus_Y.i                ; Delta-Mausposition (Y-Koordinate) um die neue Fenstergröße berechnen zu können
    
    _iID_Container_CustomStatusBar.i						; Gadget-Nummer des ContainerGadgets (die CustomStatusBar --> beinhaltet Rahmen, SizeBox und Elemente)
    _iID_Container_Gadget_Bereich.i       ; Gadget-Nummer des ContainerGadgets (die Elemente --> beinhaltet die einzelnen Gadgets der Elemente)
    _iID_SizeBox.i                        ; Gadget-Nummer der SizeBox
    _iID_Rahmen.i                         ; Gadget-Nummer des Rahmens
    
    _iWindow.i										; Fensternummer, auf dem die CustomStatusBar erzeugt wurde (#Window)
    _iFenster_Breite.i            ; die aktuelle Breite des Fensters (ohne Fensterrahmen)
    _iFenster_Hoehe.i             ; die aktuelle Höhe des Fensters (ohne Fensterrahmen)
    
    _iY_Pos.i										; die vertikale Startkoordinate der CustomStatusBar
    _iX_Pos.i                   ; die vertikale Startkoordinate der CustomStatusBar
    _iHeight.i                   ; die aktuelle Höhe der CustomStatusBar
    _iWidth.i                  ; die aktuelle Breite der CustomStatusBar
    
    _iGadget_Bereich_Offset_Breite.i				; der horizontale Mindestabstand zwichen den Rahmen der CustomStatusBar und den Elementen
    _iGadget_Bereich_Offset_Hoehe.i         ; der vertikale Mindestabstand zwichen den Rahmen der CustomStatusBar und den Elementen
    
    _iMax_Elements_visible.i							; die maximale Anzahl der Elemente, die in der CustomStatusBar gleichzeitig angezeigt werden können
    _iMin_Abstand_der_Elemente.i        ; der minimale Abstand (in Pixel) zwischen zwei dargestellten Elementen in der CustomStatusBar
    
    _iHintergrundfabe.i								; Hintergrundfarbe der CustomStatusBar
    _iMerker_letztes_Field.i           ; speichert die Nummer des Fieldes, auf dem die Maus zuletzt war (MouseOver)
    _iMerker_letzter_Klick.i          ; speichert die Nummer des Fieldes, auf dem die Maus zuletzt geklickt hat (rechtsklick)
    
    _iCustomStatusBar_Timer_Intervall.i					; Aktualisierungsintervall der CustomStatusBar (in Millisekunden)
    _iCustomStatusBar_Timer_ID.i                 ; die aktuelle Timer-ID
    _iCustomStatusBar_Timer_Start_ID.i           ; die Startnummer (Offset) für die erstellten Timer-IDs
    _iCustomStatusBar_Timer_Reserve.i            ; reservierte Timer-IDs pro CustomStatusBar
  EndStructure
  
  
  ; Eigenschaften des Kontextmenüs
  Structure CustomStatusBar_Kontextmenue
    _iKontextmenue_Aktiviert.i						; Bool: ermöglicht bei #True die Darstellung des Kontextmenüs
    _iKontextmenue_Timer_Intervall.i      ; Aktualisierungsintervall in Millisekunden (Abfrage des Kontextmenüs)
    _iKontextmenue_Timer_ID.i             ; die aktuelle Timer-ID
    
    _iHeadline_anzeigen.i						; Bool: zeigt bei #True eine Überschrift im Kontextmenü an, die dem Kontextmenü-Eintrags des aktuellen Elements entspricht
    _iHeadline_Symbol_erlauben.i    ; Bool: erlaubt bei #True die Darstellung eines Symbols in der Überschrift
    _sEintrag_Fielder_erstellen_Text.s   ; Text, für das Hinzufügen neuer Elemente in der CustomStatusBar (oder "" um den Kontextmenü-Eintrag zu löschen)
    _sEintrag_Fielder_entfernen_Text.s   ; Text, für das Entfernen des markierten Elements in der CustomStatusBar (oder "" um den Kontextmenü-Eintrag zu löschen)
    _iItem_Field_erstellen_Symbol.i   ; handle zu einem Image, das im Kontextmenüeintrag "Eintrag hinzufügen" angezeigt werden soll
    _iItem_Field_entfernen_Symbol.i   ; handle zu einem Image, das im Kontextmenüeintrag "diesen Eintrag entfernen" angezeigt werden soll
    
    _iMenueItem_Start.i								; Start-ID für die Kontextmenüeinträge (Offset)
    _iMenueItem_Reserviert.i          ; reservierte Menü-IDs pro CustomStatusBar
    _iMenueItem_Reserviert_erweitert.i; zusätzlicher Offset für weiter Kontextmenüeinträge
    
    _iHeadline_Menue_ID.i						; aktuelle Menü-ID: Überschrift
    _iItem_Field_erstellen_Menue_ID.i ; aktuelle Menü-ID: "Eintrag hinzufügen"
    _iItem_Field_entfernen_Menue_ID.i ; aktuelle Menü-ID: "diesen Eintrag entfernen"
  EndStructure
  
  
  ; Eigenschaften der Tooltips und Ballon-Tipps
  Structure CustomStatusBar_Tooltips
    _iTooltip_Aktiviert.i							; Bool: ermöglicht bei #True die Darstellung von Tooltips
    _iTooltip_ID.i                    ; die aktuelle Tooltip-ID
    _iTooltip_Style.i                 ; der aktuelle Tooltip-Style
    _iTooltip_Timer_Intervall.i       ; Aktualisierungsintervall der dargestellten Tooltips (in Millisekunden)
    _iTooltip_Timer_ID.i              ; die aktuelle Timer-ID
    _iToolTip_Delay.i          ; Zeit die der Mauszeiger über ein Field in der CustomStatusBar verbleiben muss, um ein Tooltip anzuzeigen (in Millisekunden)
    _iTooltip_Timer_merker.i          ; Merker: aktuell verstrichene Zeit (Verbindung mit _iToolTip_Delay)	
    _sTooltip_letzter_Text.s
    _sTooltip_letzter_Titel.s
    _sTooltip_letztes_Symbol.s
    _iTooltip_letzte_X_Pos.i
    _iTooltip_letzte_Y_Pos.i
    
    _iBallon_Info_ID.i								; die aktuelle Ballon-Tipp-ID
    _iBallon_Info_Style.i             ; der aktuelle Ballon-Tipp-Style
    _iBallon_Info_Anzeigedauer.i      ; maximale Anzeigedauer eines Ballon-Tipps (in Millisekunden)
    _iBallon_Info_Timer_merker.i      ; die aktuell verstrichene Anzeigedauer eines Ballon-Tipps
    _iBallon_Info_auf_Field.i          ; das aktuelle Field, auf der gerade ein Ballon-Tipp angezeigt wird (oder 0, wenn zur Zeit nichts angezeigt wird)
    _sBallon_Info_letzter_Text.s
    _sBallon_Info_letzter_Titel.s
    _sBallon_Info_letztes_Symbol.s
    _iBallon_Info_letzte_X_Pos.i
    _iBallon_Info_letzte_Y_Pos.i
  EndStructure	
  
  
  ; grundlegende Fieldeigenschaften
  Structure Field
    _iBelegt.i										; Bool: dieser Eintrag im Field-Array wird mit #True als belegt markiert
    _iElement_ID.i                ; die Element-ID, die auf diesem Field hinterlegt wurde. Die Elemet-ID ist dabei der Index des Element-Arrays.
    _iGadget_ID.i                 ; die Gadget-Nummer, des erstellten Gadgets in diesem Field
    _iSeparator_ID.i              ; die Gadget-Nummer, des erstellten Separators in diesem Field
    _iX_Pos.i                     ; die horizontale Startkoordinate des belegten Fieldes
    _iY_Pos.i                     ; die vertikale Startkoordinate des belegten Fieldes
    _iWidth.i                    ; die aktuelle Breite des belegten Fieldes (Fieldbreite)
    _iHeight.i                     ; die aktuelle Höhe des belegten Fieldes (Fieldhöhe)
  EndStructure
  
  
  ; Struktur der CustomStatusBar
  Structure CustomStatusBar
    Allgemein.CustomStatusBar_Allgemein
    Kontextmenue.CustomStatusBar_Kontextmenue
    Tooltips.CustomStatusBar_Tooltips
    Array Gadget_Standard_Einstellungen.Gadget_Standard_Einstellungen(#Gadget_Anzahl)
    Array Element.Element(1)
    Array Field.Field(1)
  EndStructure
  
  
  Global Dim CustomStatusBar.CustomStatusBar(1)
  ;} Modul-Strukturen deklarieren
  
  
  
  
  ;- Standard-Einstellungen festlegen
  ;{ Standard-Einstellungen festlegen
  ; Allgemein
  standard_Einstellungen\Allgemein\_iAutoresize_Aktiviert						= #True									; Bool: aktiviert bei #True die automatische Größenanpassung der CustomStatusBar und der darauf befindlichen Gadgets
  standard_Einstellungen\Allgemein\_iAutoresize_Modus							= 1                       ; definiert die Art der Größenveränderung bei aktiviertem Autoresize (siehe Prozedur: _CustomStatusBar_groesse_automatisch_anpassen())
  standard_Einstellungen\Allgemein\_iSizeBox_Aktiviert						= #True                   ; Bool: aktiviert bei #True die Darstellung einer SizeBox in der rechten unteren Ecke der CustomStatusBar, um die Größe des Fensters leicher anpassen zu können
  
  standard_Einstellungen\Allgemein\_iBorder_hide						= #False 								; Bool: blendet bei #True den Rahmen der CustomStatusBar aus
  standard_Einstellungen\Allgemein\_iSeparator_hide						= #False              ; Bool: blendet bei #True die Separatoren zwischen den Elementen in der CustomStatusBar aus
  
  standard_Einstellungen\Allgemein\_iStandard_Hoehe							= 25									; Standardhöhe der CustomStatusBar
  standard_Einstellungen\Allgemein\_iMin_Abstand_der_Elemente 				= 10            ; der minimale Abstand (in Pixel) zwischen zwei dargestellten Elementen in der CustomStatusBar	
  standard_Einstellungen\Allgemein\_iHintergrundfabe							= RGB(241,237,237)  ; Hintergrundfarbe der CustomStatusBar
  
  standard_Einstellungen\Allgemein\_iGadget_Bereich_Offset_Breite				= 2										; der horizontale Mindestabstand zwichen den Rahmen der CustomStatusBar und den Elementen
  standard_Einstellungen\Allgemein\_iGadget_Bereich_Offset_Hoehe				= 2                   ; der vertikale Mindestabstand zwichen den Rahmen der CustomStatusBar und den Elementen
  
  standard_Einstellungen\Allgemein\_iCustomStatusBar_Timer_Intervall				= 25									; Aktualisierungsintervall der CustomStatusBar (in Millisekunden)
  standard_Einstellungen\Allgemein\_iCustomStatusBar_Timer_Start_ID				= 20000               ; die Startnummer (Offset) für die erstellten Timer-IDs
  standard_Einstellungen\Allgemein\_iCustomStatusBar_Timer_Reserve					= 10                  ; reservierte Timer-IDs pro CustomStatusBar
  
  
  ; Tooltips und Ballon-Tipps
  standard_Einstellungen\Tooltips\_iTooltip_Aktiviert							= #True									; Bool: ermöglicht bei #True die Darstellung von Tooltips
  standard_Einstellungen\Tooltips\_iTooltip_Timer_Intervall					= 20                  ; Aktualisierungsintervall der dargestellten Tooltips und Ballon-Tipps (in Millisekunden)
  standard_Einstellungen\Tooltips\_iToolTip_Delay						= 500                 ; Zeit die der Mauszeiger über ein Field in der CustomStatusBar verbleiben muss, um ein Tooltip anzuzeigen (in Millisekunden)
  
  standard_Einstellungen\Tooltips\_iBallon_Info_Anzeigedauer					= 5000 									; maximale Anzeigedauer eines Ballon-Tipps (in Millisekunden)
  
  
  ; Kontextmenü
  standard_Einstellungen\Kontextmenue\_iKontextmenue_Aktiviert				= #True									; Bool: ermöglicht bei #True die Darstellung des Kontextmenüs
  standard_Einstellungen\Kontextmenue\_iHeadline_anzeigen					= #True                 ; Bool: zeigt bei #True eine Überschrift im Kontextmenü an, die dem Kontextmenü-Eintrags des aktuellen Elements entspricht
  standard_Einstellungen\Kontextmenue\_iHeadline_Symbol_erlauben			= #True             ; Bool: erlaubt bei #True die Darstellung eines Symbols in der Überschrift
  
  standard_Einstellungen\Kontextmenue\_iKontextmenue_Timer_Intervall			= 100									; Aktualisierungsintervall in Millisekunden (Abfrage des Kontextmenüs)
  
  standard_Einstellungen\Kontextmenue\_iMenueItem_Start						= 20000 								; Start-ID für die Kontextmenüeinträge (Offset)
  standard_Einstellungen\Kontextmenue\_iMenueItem_Reserviert					= 500               ; reservierte Menü-IDs pro CustomStatusBar
  standard_Einstellungen\Kontextmenue\_iMenueItem_Reserviert_erweitert		= 10            ; zusätzlicher Offset für weiter Kontextmenüeinträge
  
  standard_Einstellungen\Kontextmenue\_sEintrag_Fielder_erstellen_Text			= "Eintrag hinzufügen"					; Text, für das Hinzufügen neuer Elemente in der CustomStatusBar (oder "" um den Kontextmenü-Eintrag zu löschen)
  standard_Einstellungen\Kontextmenue\_sEintrag_Fielder_entfernen_Text			= "diesen Eintrag entfernen"    ; Text, für das Entfernen des markierten Elements in der CustomStatusBar (oder "" um den Kontextmenü-Eintrag zu löschen)
  
  standard_Einstellungen\Kontextmenue\_iItem_Field_erstellen_Symbol			= CatchImage(#PB_Any, ?Icon_neu)		; handle zu einem Image, das im Kontextmenüeintrag "Eintrag hinzufügen" angezeigt werden soll
  standard_Einstellungen\Kontextmenue\_iItem_Field_entfernen_Symbol			= CatchImage(#PB_Any, ?Icon_entfernen)	; handle zu einem Image, das im Kontextmenüeintrag "diesen Eintrag entfernen" angezeigt werden soll
  
  
  ; Elemente
  standard_Einstellungen\Gadgets(#ButtonGadget)\_iMin_Width					= 60									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#ButtonGadget)\_iY_Pos_Offset				= 1                   ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#ButtonImageGadget)\_iMin_Width				= 60									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#ButtonImageGadget)\_iY_Pos_Offset			= 1                   ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#CanvasGadget)\_iMin_Width					= 16									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#CanvasGadget)\_iY_Pos_Offset				= 0                   ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#CheckBoxGadget)\_iMin_Width				= 70									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#CheckBoxGadget)\_iY_Pos_Offset				= 3                 ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#ComboBoxGadget)\_iMin_Width				= 100									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#ComboBoxGadget)\_iY_Pos_Offset				= 2                 ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#DateGadget)\_iMin_Width					= 80									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#DateGadget)\_iY_Pos_Offset					= 1                 ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#ExplorerComboGadget)\_iMin_Width			= 160									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#ExplorerComboGadget)\_iY_Pos_Offset			= 2                 ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#HyperLinkGadget)\_iMin_Width				= 140									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#HyperLinkGadget)\_iY_Pos_Offset				= 3                 ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#IPAddressGadget)\_iMin_Width				= 90									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#IPAddressGadget)\_iY_Pos_Offset				= 1                 ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#ProgressBarGadget)\_iMin_Width				= 80									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#ProgressBarGadget)\_iY_Pos_Offset			= 2                   ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#ScrollBarGadget)\_iMin_Width				= 80									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#ScrollBarGadget)\_iY_Pos_Offset				= 2                 ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#ShortcutGadget)\_iMin_Width				= 140									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#ShortcutGadget)\_iY_Pos_Offset				= 1                 ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#SpinGadget)\_iMin_Width					= 50									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#SpinGadget)\_iY_Pos_Offset					= 1                 ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#StringGadget)\_iMin_Width					= 120									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#StringGadget)\_iY_Pos_Offset				= 1                   ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#TextGadget)\_iMin_Width					= 100									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#TextGadget)\_iY_Pos_Offset					= 1                 ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
  
  standard_Einstellungen\Gadgets(#TrackBarGadget)\_iMin_Width				= 80									; Standardwert für die minimale Elementbreite in der CustomStatusBar
  standard_Einstellungen\Gadgets(#TrackBarGadget)\_iY_Pos_Offset				= 0                 ; vertikaler Mindestabstand zwischen Element und Ober-/Unterkannte der CustomStatusBar
                                                                                            ;} Standard-Einstellungen festlegen
  
  
  ;  ############################################################################################################################################################################################
  ;  ######################################################################################     PUBLIC     ######################################################################################
  ;  ############################################################################################################################################################################################
  ;-
  ;-
  ;-
  ;- ################### PUBLIC ######################
  ;-
  ;- CustomStatusBar allgemein
  ;- -------------------------------------------------------------
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	Create
  ;
  ; Beschreibung ..: 	erzeugt eine CustomStatusBar, in der Elemente verwaltet werden können
  ;
  ; Syntax.........:  Create (iWindow.i, iMax_Elements_visible.i = 10, iX_Pos.i = #PB_Default, iY_Pos.i = #PB_Default, iWidth.i = #PB_Default, iHeight.i = #PB_Default, iY_Pos_Offset.i = 0), iSchriftgroesse.i = 10, iLabelbreite.i = 60, dIntervall.d = 1.0)
  ;
  ; Parameter .....: 	iWindow.i 					- das Fenster (#Window), auf dem die CustomStatusBar erzeugt werden soll
  ;                  	iMax_Elements_visible.i		- die maximale Anzahl der Elemente, die gleichzeitig in der CustomStatusBar angezeigt werden können
  ;					iX_Pos.i 					- die X-Position der CustomStatusBar
  ;												| #PB_Default: positioniert die CustomStatusBar am linken Fensterrand
  ;
  ;					iY_Pos.i 					- die Y-Position der CustomStatusBar
  ;												| #PB_Default: positioniert die CustomStatusBar am unteren Fensterrand
  ;
  ;					iWidth.i 					- die Breite der CustomStatusBar
  ;												| #PB_Default: verlängert die Breite bis zum rechten Fensterrand
  ;
  ;					iHeight.i 					- die Höhe der CustomStatusBar
  ;												| #PB_Default: verwendet die Standardhöhe (in der Regel: 25 Pixel)
  ;
  ;					iY_Pos_Offset.i 			- Offset, um den die CustomStatusBar vertikal verschoben werden soll (wird nur benötigt, wenn im angegebenen Fenster ein Menü verwendet wird)
  ;												| MenuHeight(): verschiebt die CustomStatusBar um die Höhe einer erstellten Menüleiste
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID der CustomStatusBar zurück, die erstellt wurde
  ;
  ;                  	Fehler 						| -1: das angegebene #Window ist ungültig
  ;												| -2: die CustomStatusBar konnte nicht erstellt werden
  ;
  ; Bemerkungen ...:	Unabhängig von der maximalen Anzahl der Elemente, die gleichzeitig in der CustomStatusBar angezeigt werden können, unterstützt die CustomStatusBar unbegrenzt viele Elemente.
  ;
  ;} ========
  Procedure.i Create (iWindow.i, iMax_Elements_visible.i = 10, iX_Pos.i = #PB_Default, iY_Pos.i = #PB_Default, iWidth.i = #PB_Default, iHeight.i = #PB_Default, iY_Pos_Offset.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If IsWindow (iWindow) = 0:	ProcedureReturn -1:		EndIf	; Abbrechen, wenn das angegebene Fenster nicht initialisiert wurde
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iFenster_Breite.i						= WindowWidth (iWindow, #PB_Window_InnerCoordinate)
    Protected iFenster_Hoehe.i						= WindowHeight (iWindow, #PB_Window_InnerCoordinate)	
    
    Protected iGadget_Bereich_Offset_Breite.i		= standard_Einstellungen\Allgemein\_iGadget_Bereich_Offset_Breite
    Protected iGadget_Bereich_Offset_Hoehe.i		= standard_Einstellungen\Allgemein\_iGadget_Bereich_Offset_Hoehe
    
    Protected iCounter.i							= 0
    Protected iCustomStatusBar_ID.i						= 0
    
    Protected iTimer_ID_Start.i						= 0
    Protected iTimer_ID_Reserve.i					= 0
    Protected iTimer_ID_CustomStatusBar.i				= 0
    Protected iTimer_ID_Tooltip.i					= 0
    Protected iTimer_ID_Kontextmenue.i				= 0
    
    Protected iX_Pos_SizeBox.i						= 0
    Protected iY_Pos_SizeBox.i						= 0
    
    
    ; den Parameter überprüfen: iX_Pos
    If (iX_Pos <= 1) Or (iX_Pos = #PB_Default)
      iX_Pos = -2
    EndIf
    
    
    ; den Parameter überprüfen: iWidth
    If (iWidth < 10) Or (iWidth = #PB_Default)
      iWidth = iFenster_Breite + 4
      
      If iX_Pos > 0
        iWidth - iX_Pos
      EndIf
      
    EndIf
    
    
    ; den Parameter überprüfen: iHeight
    If (iHeight < 4) Or (iHeight = #PB_Default)
      iHeight = standard_Einstellungen\Allgemein\_iStandard_Hoehe
    EndIf
    
    
    ; den Parameter überprüfen: iMax_Elements_visible
    If (iMax_Elements_visible < 1) Or (iHeight = #PB_Default)
      iMax_Elements_visible = 10
    EndIf
    
    
    ; die vertikale Field der CustomStatusBar wird festgelegt
    If iY_Pos = #PB_Default
      iY_Pos = iFenster_Hoehe - iHeight - iY_Pos_Offset + iGadget_Bereich_Offset_Hoehe
    Else
      iY_Pos = iY_Pos - iY_Pos_Offset
    EndIf
    
    
    ; einen freien Eintrag im CustomStatusBarn-Array suchen 
    For iCounter = 1 To ArraySize(CustomStatusBar())
      If CustomStatusBar(iCounter)\Allgemein\_iBelegt = #False
        iCustomStatusBar_ID = iCounter
        Break
      Else
        iCustomStatusBar_ID = 0
      EndIf
    Next		
    
    
    ; einen neuen Eintrag im CustomStatusBarn-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iCustomStatusBar_ID = 0
      iCustomStatusBar_ID = ArraySize(CustomStatusBar()) + 1
      ReDim CustomStatusBar(iCustomStatusBar_ID)
    EndIf
    
    
    ; CustomStatusBar erstellen
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_CustomStatusBar				= ContainerGadget	(#PB_Any,  iX_Pos, iY_Pos, iWidth, iHeight)
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich			= ContainerGadget	(#PB_Any,  iGadget_Bereich_Offset_Breite, iGadget_Bereich_Offset_Hoehe, iWidth - (iGadget_Bereich_Offset_Breite*2), iHeight - (iGadget_Bereich_Offset_Hoehe*2))
    CloseGadgetList() ; Gadget_Bereich
    
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_SizeBox							= CanvasGadget		(#PB_Any,  0, 0, 20, 20)
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Rahmen							= TextGadget		(#PB_Any,  0, 0, iWidth, iHeight, "", #SS_ETCHEDFRAME)
    DisableGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Rahmen, #True)
    CloseGadgetList() ; CustomStatusBar
    
    
    ; die Erstellung der CustomStatusBar überprüfen und ggf. die Prozedur abbrechen
    If (IsGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_CustomStatusBar) = 0) Or (IsGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0)
      CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iBelegt = #False
      ProcedureReturn -2
    EndIf
    
    
    ; Einstellungen und Parameter speichern
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iBelegt								= #True
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMax_Elements_visible					= iMax_Elements_visible
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow								= iWindow
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iFenster_Breite				  		= iFenster_Breite
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iFenster_Hoehe				  		= iFenster_Hoehe
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iX_Pos								= iX_Pos
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iY_Pos								= iY_Pos		
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWidth								= iWidth		
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHeight 								= iHeight		
    
    
    ; Standard-Einstellungen übernehmen
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iAutoresize_Aktiviert					= standard_Einstellungen\Allgemein\_iAutoresize_Aktiviert
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iAutoresize_Modus						= standard_Einstellungen\Allgemein\_iAutoresize_Modus
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSizeBox_Aktiviert					= standard_Einstellungen\Allgemein\_iSizeBox_Aktiviert
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente				= standard_Einstellungen\Allgemein\_iMin_Abstand_der_Elemente
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHintergrundfabe   					= standard_Einstellungen\Allgemein\_iHintergrundfabe
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide  				= standard_Einstellungen\Allgemein\_iSeparator_hide
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iBorder_hide  					= standard_Einstellungen\Allgemein\_iBorder_hide
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iGadget_Bereich_Offset_Breite			= standard_Einstellungen\Allgemein\_iGadget_Bereich_Offset_Breite
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iGadget_Bereich_Offset_Hoehe  		= standard_Einstellungen\Allgemein\_iGadget_Bereich_Offset_Hoehe
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_Intervall			= standard_Einstellungen\Allgemein\_iCustomStatusBar_Timer_Intervall
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_Start_ID			= standard_Einstellungen\Allgemein\_iCustomStatusBar_Timer_Start_ID
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_Reserve				= standard_Einstellungen\Allgemein\_iCustomStatusBar_Timer_Reserve
    
    CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Aktiviert  					= standard_Einstellungen\Tooltips\_iTooltip_Aktiviert
    CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Timer_Intervall  				= standard_Einstellungen\Tooltips\_iTooltip_Timer_Intervall
    CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iToolTip_Delay  				= standard_Einstellungen\Tooltips\_iToolTip_Delay
    CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_Anzeigedauer  			= standard_Einstellungen\Tooltips\_iBallon_Info_Anzeigedauer	
    
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iKontextmenue_Aktiviert			= standard_Einstellungen\Kontextmenue\_iKontextmenue_Aktiviert
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iKontextmenue_Timer_Intervall		= standard_Einstellungen\Kontextmenue\_iKontextmenue_Timer_Intervall
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iHeadline_anzeigen				= standard_Einstellungen\Kontextmenue\_iHeadline_anzeigen
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iHeadline_Symbol_erlauben		= standard_Einstellungen\Kontextmenue\_iHeadline_Symbol_erlauben
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iMenueItem_Start					= standard_Einstellungen\Kontextmenue\_iMenueItem_Start
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iMenueItem_Reserviert				= standard_Einstellungen\Kontextmenue\_iMenueItem_Reserviert
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iMenueItem_Reserviert_erweitert	= standard_Einstellungen\Kontextmenue\_iMenueItem_Reserviert_erweitert
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_sEintrag_Fielder_erstellen_Text		= standard_Einstellungen\Kontextmenue\_sEintrag_Fielder_erstellen_Text
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iItem_Field_erstellen_Symbol		= standard_Einstellungen\Kontextmenue\_iItem_Field_erstellen_Symbol
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_sEintrag_Fielder_entfernen_Text		= standard_Einstellungen\Kontextmenue\_sEintrag_Fielder_entfernen_Text
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iItem_Field_entfernen_Symbol		= standard_Einstellungen\Kontextmenue\_iItem_Field_entfernen_Symbol
    
    
    ; die SizeBox zeichnen
    SetGadgetAttribute(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_SizeBox, #PB_Canvas_Cursor, #PB_Cursor_LeftUpRightDown)
    
    If StartDrawing(CanvasOutput(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_SizeBox))
      
      Box(0, 0, 20, 20, CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHintergrundfabe)
      
      For iX_Pos_SizeBox = 10 To 16 Step 3
        For iY_Pos_SizeBox = 10 To 16 Step 3
          
          If (iX_Pos_SizeBox = 10 And iY_Pos_SizeBox < 16) Or (iX_Pos_SizeBox = 13 And iY_Pos_SizeBox < 13)
            Continue
          EndIf
          
          Plot (iX_Pos_SizeBox, 		iY_Pos_SizeBox,		RGB(255, 255, 255))
          Plot (iX_Pos_SizeBox + 1, 	iY_Pos_SizeBox,		RGB(207, 207, 207))
          Plot (iX_Pos_SizeBox,		iY_Pos_SizeBox + 1,	RGB(231, 231, 231))
          Plot (iX_Pos_SizeBox + 1,	iY_Pos_SizeBox + 1,	RGB(175, 175, 175))
          
        Next
      Next
      
      StopDrawing()
    EndIf
    
    
    ; Standard-Einstellungen der Elemente (Gadgets) übernehmen
    For iCounter = 0 To ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen())
      CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(iCounter)\_iMin_Width		= standard_Einstellungen\Gadgets(iCounter)\_iMin_Width
      CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(iCounter)\_iY_Pos_Offset	= standard_Einstellungen\Gadgets(iCounter)\_iY_Pos_Offset	
    Next
    
    
    ; den Rahmen ausblenden, wenn dies in den Standard-Einstellungen festgelegt wurde
    If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iBorder_hide = #True
      HideGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Rahmen, #True)
    EndIf
    
    
    ; die SizeBox ausblenden, wenn dies in den Standard-Einstellungen festgelegt wurde
    If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSizeBox_Aktiviert = #False
      HideGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_SizeBox, #True)
    EndIf
    
    
    
    ; die Hintergrundfarbe der CustomStatusBar anpassen
    SetGadgetColor	(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_CustomStatusBar,   		#PB_Gadget_BackColor, CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHintergrundfabe)
    SetGadgetColor	(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich,	#PB_Gadget_BackColor, CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHintergrundfabe)
    
    
    ; das Array für die verfügbaren Fielder neu dimensionieren
    If ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Field()) <> iMax_Elements_visible
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Field(iMax_Elements_visible)
    EndIf
    
    
    ; erstellt das erste Element in der CustomStatusBar: Dies wird immer dann angezeigt, wenn im Kontextmenü "Eintrag hinzufügen" gewählt wurde
    CanvasElement(iCustomStatusBar_ID, #PB_Default, #PB_Default, CatchImage(#PB_Any, ?Icon_neu))
    
    
    ; erstellt die Timer-IDs für die aktuelle CustomStatusBar
    iTimer_ID_Start			= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_Start_ID
    iTimer_ID_Reserve		= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_Reserve
    
    iTimer_ID_CustomStatusBar 	= iTimer_ID_Start + (iCustomStatusBar_ID * iTimer_ID_Reserve) + 1
    iTimer_ID_Tooltip		= iTimer_ID_Start + (iCustomStatusBar_ID * iTimer_ID_Reserve) + 2
    iTimer_ID_Kontextmenue	= iTimer_ID_Start + (iCustomStatusBar_ID * iTimer_ID_Reserve) + 3
    
    
    ; prüft die Parameter für den Timeout und korrigiert diese gegebenenfalls
    If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_Intervall <= 0
      CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_Intervall = 1
    EndIf
    
    If CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Timer_Intervall <= 0
      CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Timer_Intervall = 1
    EndIf
    
    If CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iKontextmenue_Timer_Intervall <= 0
      CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iKontextmenue_Timer_Intervall = 1
    EndIf
    
    
    ; speichert die Timer-IDs
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_ID 			= iTimer_ID_CustomStatusBar
    CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Timer_ID 				= iTimer_ID_Tooltip
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iKontextmenue_Timer_ID 	= iTimer_ID_Kontextmenue
    
    
    ; Timer erzeugen
    AddWindowTimer(iWindow, iTimer_ID_CustomStatusBar, 	CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_Intervall)
    AddWindowTimer(iWindow, iTimer_ID_Tooltip, 		CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Timer_Intervall)
    AddWindowTimer(iWindow, iTimer_ID_Kontextmenue, CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iKontextmenue_Timer_Intervall)
    
    
    ; die Größe neu anpassen (nötig für SizeBox)
    _CustomStatusBar_groesse_anpassen (iCustomStatusBar_ID, iX_Pos, iY_Pos, iWidth, iHeight)
    
    
    ; die ID der CustomStatusBar zurückgeben
    ProcedureReturn iCustomStatusBar_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	Remove
  ;
  ; Beschreibung ..: 	entfernt die angegebene CustomStatusBar und gibt die verwendeten Ressourcen wieder frei
  ;
  ; Syntax.........:  Remove (iCustomStatusBar_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, die entfernt werden soll
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID der CustomStatusBar zurück, die entfernt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:
  ;
  ;} ========	
  Procedure.i Remove (iCustomStatusBar_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren	
    Protected iMax_Anzahl_Fielder.i			= ArraySize 	(CustomStatusBar(iCustomStatusBar_ID)\Field())
    Protected iMax_Anzahl_Elemente.i		= ArraySize 	(CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iCounter.i					= 0
    Protected iGadget.i						= 0
    
    
    ; laufende Timer stoppen
    RemoveWindowTimer(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow, CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_ID)
    RemoveWindowTimer(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow, CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Timer_ID)
    RemoveWindowTimer(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow, CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iKontextmenue_Timer_ID)
    
    
    ; Tooltips und Ballon-Tipps löschen
    _Tooltip(iCustomStatusBar_ID, "", "", "", 0, 0, 0, #False)		; alle Tooltips löschen
    _Tooltip(iCustomStatusBar_ID, "", "", "", 0, 0, 0, #True)    ; alle Ballon-Tipps löschen
    
    
    ; alle Gadgets auf der CustomStatusBar löschen
    For iCounter = 1 To iMax_Anzahl_Fielder Step 1
      
      If IsGadget(CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID) <> 0
        FreeGadget(CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID)
        CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #False
      EndIf
      
    Next
    
    
    ; den Gadget-Bereich der CustomStatusBar löschen
    If IsGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) <> 0
      FreeGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich)
    EndIf		
    
    
    ; den Rahmen der CustomStatusBar löschen
    If IsGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Rahmen) <> 0
      FreeGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Rahmen)
    EndIf		
    
    
    ; die CustomStatusBar löschen
    If IsGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_CustomStatusBar) <> 0
      FreeGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_CustomStatusBar)
      CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iBelegt = #False
    EndIf		
    
    
    ; alle Array-Ressourcen freigeben
    FreeArray(CustomStatusBar(iCustomStatusBar_ID)\Element())
    FreeArray(CustomStatusBar(iCustomStatusBar_ID)\Field())
    
    
    ; die ID der gelöschen CustomStatusBar zurückgeben
    ProcedureReturn iCustomStatusBar_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	Hide
  ;
  ; Beschreibung ..: 	blendet die CustomStatusBar aus oder zeigt diese wieder an
  ;
  ; Syntax.........:  Hide (iCustomStatusBar_ID.i, iStatus.i = #True)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iStatus.i					- der neue Status der CustomStatusBar
  ;												| #True:  die CustomStatusBar wird ausgeblendet
  ;												| #False: die CustomStatusBar wird angezeigt
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i Hide (iCustomStatusBar_ID.i, iStatus.i = #True)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; die CustomStatusBar ausblenden und den Zustand speichern
    HideGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_CustomStatusBar, iStatus)
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iVersteckt = iStatus
    
    
    ; Tooltips und Ballon-Tipps ausblenden
    _Tooltip(iCustomStatusBar_ID, "", "", "", 0, 0, 0, #False)		; Tooltips
    _Tooltip(iCustomStatusBar_ID, "", "", "", 0, 0, 0, #True)    ; Ballon-Tipps
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;-
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	ChangeOptions
  ;
  ; Beschreibung ..: 	ändert allgemeine Einstellungen der CustomStatusBar
  ;
  ; Syntax.........:  ChangeOptions (iCustomStatusBar_ID.i, iBackgroundColor.i = #PB_Default, iBorder_hide.i = #False, iSizeBox_hide.i = #False, iSeparator_hide.i = #False, iRefreshRate.i = #PB_Default)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iBackgroundColor.i			- die Hintergrundfarbe der CustomStatusBar im RGB()-Format. #PB_Default kann verwendet werden, um die Standardfarbe zu verwenden
  ;					iBorder_hide.i		- Bool: blendet bei #True den Rahmen aus
  ;					iSizeBox_hide.i		- Bool: blendet bei #True die SizeBox aus
  ;					iSeparator_hide.i		- Bool: blendet bei #True die Separatoren zwischen den Fieldern aus
  ;					iRefreshRate.i		- das Intervall in Millisekunden, in dem Ereignisse (z.B. Kontextmenü aufrufen) abgefragt werden. #PB_Default kann verwendet werden, um die Standardzeit zu verwenden.
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	Die 'iRefreshRate' ist nicht die Aktualisierung der Fielder in der CustomStatusBar, sondern die Ereignisabfrage. Es wird also periodisch geprüft, ob in der CustomStatusBar irgendetwas
  ;					verändert wurde, um die Inhalte synchron zu halten oder um das Kontextmenü zu öffnen.
  ;
  ;} ========
  Procedure.i ChangeOptions (iCustomStatusBar_ID.i, iBackgroundColor.i = #PB_Default, iBorder_hide.i = #False, iSizeBox_hide.i = #False, iSeparator_hide.i = #False, iRefreshRate.i = #PB_Default)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iTimer_ID.i 		= 0
    Protected iX_Pos_SizeBox.i 	= 0
    Protected iY_Pos_SizeBox.i 	= 0
    
    
    ; Rahmen gegebenenfalls ausblenden
    If iBorder_hide = #True
      HideGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Rahmen, #True)
    Else
      HideGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Rahmen, #False)
    EndIf
    
    
    ; Hintergrundfarbe speichern
    If iBackgroundColor = #PB_Default
      iBackgroundColor = standard_Einstellungen\Allgemein\_iHintergrundfabe
    EndIf
    
    
    ; die SizeBox zeichnen
    SetGadgetAttribute(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_SizeBox, #PB_Canvas_Cursor, #PB_Cursor_LeftUpRightDown)
    
    If StartDrawing(CanvasOutput(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_SizeBox))
      
      Box(0, 0, 20, 20, iBackgroundColor)
      
      For iX_Pos_SizeBox = 10 To 16 Step 3
        For iY_Pos_SizeBox = 10 To 16 Step 3
          
          If (iX_Pos_SizeBox = 10 And iY_Pos_SizeBox < 16) Or (iX_Pos_SizeBox = 13 And iY_Pos_SizeBox < 13)
            Continue
          EndIf
          
          Plot (iX_Pos_SizeBox, 		iY_Pos_SizeBox,		RGB(255, 255, 255))
          Plot (iX_Pos_SizeBox + 1, 	iY_Pos_SizeBox,		RGB(207, 207, 207))
          Plot (iX_Pos_SizeBox,		iY_Pos_SizeBox + 1,	RGB(231, 231, 231))
          Plot (iX_Pos_SizeBox + 1,	iY_Pos_SizeBox + 1,	RGB(175, 175, 175))
          
        Next
      Next
      
      StopDrawing()
    EndIf
    
    
    ; die SizeBox ausblenden, wenn dies in den Standard-Einstellungen festgelegt wurde
    If iSizeBox_hide = #True
      CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSizeBox_Aktiviert 	= #False
      HideGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_SizeBox, #True)
    Else
      CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSizeBox_Aktiviert 	= #True
      HideGadget(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_SizeBox, #False)		
    EndIf
    
    
    ; die Aktualisierungsrate speichern
    If iRefreshRate = #PB_Default
      iRefreshRate = standard_Einstellungen\Allgemein\_iCustomStatusBar_Timer_Intervall
    ElseIf iRefreshRate <= 0
      iRefreshRate = 1
    EndIf
    
    
    ; die Hintergrundfarbe übernehmen
    SetGadgetColor	(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_CustomStatusBar,	 #PB_Gadget_BackColor, iBackgroundColor)
    SetGadgetColor	(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich, #PB_Gadget_BackColor, iBackgroundColor)
    
    
    ; die Aktualisierungsrate übernehmen
    RemoveWindowTimer	(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow, CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_ID)
    AddWindowTimer		(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow, CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_ID, iRefreshRate)
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide 		= iSeparator_hide
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iBorder_hide 			= iBorder_hide
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHintergrundfabe 				= iBackgroundColor
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_Intervall 	= iRefreshRate
    
    
    ; die CustomStatusBar aktualisieren
    _CustomStatusBar_groesse_automatisch_anpassen (iCustomStatusBar_ID)
    _erneuere_CustomStatusBar(iCustomStatusBar_ID)
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	ChangeAutoResizeOptions
  ;
  ; Beschreibung ..: 	ermöglicht die automatische Größenanpassung der CustomStatusBar
  ;
  ; Syntax.........:  ChangeAutoResizeOptions (iCustomStatusBar_ID.i, iActive.i = #True, iMode.i = 1)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iActive.i				- Bool: aktiviert bei #True die automatische Größenanpassung der CustomStatusBar und der darauf befindlichen Gadgets
  ;					iMode.i					- >0: definiert die Art der Größenveränderung bei aktiviertem Autoresize (siehe Prozedur: _CustomStatusBar_groesse_automatisch_anpassen())
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i ChangeAutoResizeOptions (iCustomStatusBar_ID.i, iActive.i = #True, iMode.i = 1)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iAutoresize_Aktiviert		= iActive
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iAutoresize_Modus			= iMode
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;-
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	GetElementEvent
  ;
  ; Beschreibung ..: 	ermittelt, ob das aktuelle Event von einem Element ausgelöst wurde
  ;
  ; Syntax.........:  GetElementEvent (iCustomStatusBar_ID.i, iWindowEvent.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iWindowEvent.i				- das aktuelle Event (nutzen die WindowEvent(), um das aktuelle Event zu erhalten)
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die Element-ID zurück, welches das Event ausgelost hat
  ;												|  0: das aktuelle Event wurde von keinem Element ausgelöst
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i GetElementEvent (iCustomStatusBar_ID.i, iWindowEvent.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iMax_Anzahl_Fielder.i		= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Field())
    Protected iGadget_Event.i 			= 0
    Protected iElement.i 				= 0
    Protected iCounter.i				= 0
    
    
    ; prüfen, ob ein Gadget-Event stattgefunden hat
    If iWindowEvent = #PB_Event_Gadget
      
      iGadget_Event = EventGadget()
      
      ; prüfen der einzelnen Fielder in der CustomStatusBar auf Events
      For iCounter = 0 To iMax_Anzahl_Fielder Step 1
        
        If (CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True) And (iGadget_Event = CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID)
          iElement = CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iElement_ID
          Break
        Else
          iElement = 0
        EndIf
        
      Next
      
    EndIf
    
    
    ; die Elementnummer zurückgeben
    ProcedureReturn iElement
    
  EndProcedure
  
  
  
  ;-
  ;-
  ;-
  ;- Verwalten von Elementen
  ;- -------------------------------------------------------------
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	ButtonElement
  ;
  ; Beschreibung ..: 	erstellt ein neues ButtonGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  ButtonElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					sText.s						- der auf dem Schalter darzustellende Text
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_Button_Right: rechtsbündige Darstellung des Schalter-Textes (nicht unterstützt auf Mac OSX)
  ;												| #PB_Button_Left      : linksbündige Darstellung des Schalter-Textes (nicht unterstützt auf Mac OSX)
  ;												| #PB_Button_Default   : legt das definierte Aussehen des Schalters als Standard-Schalter für das Fenster fest (auf OS X muss die Höhe des Schalters 25 sein)
  ;												| #PB_Button_MultiLine : Ist der Text zu lang, wird er über mehrere Zeilen dargestellt (nicht unterstützt auf Mac OSX)
  ;												| #PB_Button_Toggle    : erstellt einen 'Toggle'-Schalter: Ein Klick und der Schalter bleibt gedrückt, ein weiterer Klick gibt ihn wieder frei.
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'ButtonGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========	
  Procedure.i ButtonElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ButtonGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 					= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 				= "ButtonElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width				= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width				= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_sText			= sText
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iFlags		= iFlags
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	ButtonImageElement
  ;
  ; Beschreibung ..: 	erstellt ein neues ButtonImageGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  ButtonImageElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iImage_ID.i = 0, iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					iImage_ID.i					- das zu verwendende Bild (verwenden Sie die Funktion ImageID(), um diese ID von einem Bild zu erhalten)
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_Button_Toggle    : erstellt einen 'Toggle'-Schalter: Ein Klick und der Schalter bleibt gedrückt, ein weiterer Klick gibt ihn wieder frei.
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'ButtonImageGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========		
  Procedure.i ButtonImageElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iImage_ID.i = 0, iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ButtonImageGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 									= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 								= "ButtonImageElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width								= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width								= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iImage_ID_normal			= iImage_ID
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iFlags					= iFlags
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	CanvasElement
  ;
  ; Beschreibung ..: 	erstellt ein neues CanvasGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  CanvasElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iImage.i = 0, iFlags.i = 0, iAuto_scaling.i = #False)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					iImage_ID.i					- das zu verwendende Bild (verwenden Sie die Funktion ImageID(), um diese ID von einem Bild zu erhalten)
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_Canvas_Border: 	Zeichnet einen Rand rund um das Gadget.
  ;												| #PB_Canvas_ClipMouse: Begrenzt die Maus auf das Gadget während eine Maus-Taste gedrückt ist. (Nicht auf MacOS unterstützt)
  ;												| #PB_Canvas_Keyboard: 	Ermöglicht dem Gadget den "Keyboard-Fokus" und Tastatur-Ereignisse zu erhalten.
  ;												| #PB_Canvas_DrawFocus: Zeichnet ein Fokus-Rechteck auf das Gadget, wenn es den "Keyboard-Fokus" hat.
  ;
  ;					iAuto_scaling.i			- erlaubt die vertikale Skalierung des Bildes, um es so auf die Höhe der CustomStatusBar anzupassen
  ;												| #True:  skaliert das Bild
  ;												| #False: die Abmessungen des Bildes werden nicht angepasst
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'CanvasGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========
  Procedure.i CanvasElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iImage.i = 0, iFlags.i = 0, iAuto_scaling.i = #False)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#CanvasGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)	
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 							= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 						= "CanvasElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width						= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width						= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iImage				= iImage
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iFlags				= iFlags
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iAutoanpassung		= iAuto_scaling
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	CheckBoxElement
  ;
  ; Beschreibung ..: 	erstellt ein neues CheckBoxGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  CheckBoxElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					sText.s						- der neben dem Checkbox-Gadget darzustellende Text
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_CheckBox_Right: 		rechtsbündige Darstellung des Textes
  ;												| #PB_CheckBox_Center: 		zentrierte Darstellung des Textes
  ;												| #PB_CheckBox_ThreeState: 	Erstellt eine Checkbox, die einen dritten "dazwischen" Status haben kann.
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'CheckBoxGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========
  Procedure.i CheckBoxElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#CheckBoxGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 					= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 				= "CheckBoxElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width				= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width				= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_sText		= sText
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iFlags		= iFlags
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	ComboBoxElement
  ;
  ; Beschreibung ..: 	erstellt ein neues ComboBoxGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  ComboBoxElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_ComboBox_Editable: 	Macht die ComboBox editierbar
  ;												| #PB_ComboBox_LowerCase: 	Der gesamte in der ComboBox eingegebene Text wird in Kleinbuchstaben konvertiert.
  ;												| #PB_ComboBox_UpperCase: 	Der gesamte in der ComboBox eingegebene Text wird in Großbuchstaben konvertiert.
  ;												| #PB_ComboBox_Image:		Aktiviert die Unterstützung für Bilder in Einträgen (nicht unterstützt bei editierbaren ComboBoxen auf OSX).
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'ComboBoxGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========
  Procedure.i ComboBoxElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ComboBoxGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 					= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 				= "ComboBoxElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width				= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width				= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iFlags		= iFlags
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	DateElement
  ;
  ; Beschreibung ..: 	erstellt ein neues DateGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  DateElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sMaske.s = "", iDate.i = 0, iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					sMaske.s					- Das Format, in welchem das Datum eingegeben werden kann. Siehe FormatDate() für das Format dieser Maske. Das Gadget unterstützt nicht die Anzeige von Sekunden, 
  ;												  wenn Sie also "%ss" im 'Maske$' Parameter angeben, wird dies einfach ignoriert! 
  ;					iDate.i					- Das anfänglich anzuzeigende Datum für das Gadget. Ohne diesen Parameter oder die Angabe einer 0 wird das aktuelle Datum verwendet.
  ;
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_Date_UpDown: 	 versieht das Element mit einem Hoch/Runter-Schalter, mit welchem der Anwender den aktuell ausgewählten Teil des Elements verändern kann. Diese Option ist nur auf Windows verfügbar.
  ;												| #PB_Date_CheckBox: das Element bekommt eine Häkchen-Box, mit der der Anwender das Element auf "kein Datum" setzen kann
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'DateGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========
  Procedure.i DateElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sMaske.s = "", iDate.i = 0, iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#DateGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 					= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 				= "DateElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width				= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width				= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iFlags			= iFlags
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_sMaske			= sMaske
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iDate			= iDate
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	ExplorerComboElement
  ;
  ; Beschreibung ..: 	erstellt ein neues ExplorerComboGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  ExplorerComboElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sDirectory.s = "", iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					sDirectory.s				- Das anfänglich angezeigte Verzeichnis (muss als vollständiger Pfad angegeben werden). Ein leerer String spezifiziert das Stammverzeichnis (Root). 
  ;
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_Explorer_DrivesOnly: 		Das Gadget zeigt nur Laufwerke zur Auswahl an.
  ;												| #PB_Explorer_Editable: 		Das Gadget ist editierbar mit einem "Autocomplete" (automatisches Vervollständigen) Feature. Mit diesem Flag gesetzt, verhält sich das Gadget exakt so wie das im Windows-Explorer.
  ;												| #PB_Explorer_NoMyDocuments: 	Das 'Eigene Dateien' Verzeichnis wird nicht als separater Eintrag angezeigt
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'ExplorerComboGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========	
  Procedure.i ExplorerComboElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sDirectory.s = "", iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ExplorerComboGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 							= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 						= "ExplorerComboElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width						= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width						= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iFlags			= iFlags
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_sDirectory	= sDirectory
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	HyperLinkeElement
  ;
  ; Beschreibung ..: 	erstellt ein neues HyperLinkGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  HyperLinkeElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iColor.i = #PB_Default, iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					sText.s						- der Text, welcher als Link dargestellt werden soll
  ;
  ;					iColor.i					- die Farbe des Textes, wenn sich die Maus über das Element befindet
  ;
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_Hyperlink_Underline: Zeichnet eine Linie unter den Text, ohne die Notwendigkeit für einen unterstrichenen Zeichensatz
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'HyperLinkGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========
  Procedure.i HyperLinkeElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iColor.i = #PB_Default, iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#HyperLinkGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 							= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 						= "HyperLinkElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width						= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width						= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iFlags				= iFlags
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_sText				= sText
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iHover_farbe		= iColor
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iBackgroundColor	= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHintergrundfabe
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftfarbe		= 0
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	IPAddressElement
  ;
  ; Beschreibung ..: 	erstellt ein neues IPAddressGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  IPAddressElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'IPAddressGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========	
  Procedure.i IPAddressElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#IPAddressGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 					= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 				= "IPAddressElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width				= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width				= iMax_Width
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	ProgressBarElement
  ;
  ; Beschreibung ..: 	erstellt ein neues ProgressBarGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  ProgressBarElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					iMinimum.i					- der Minimalwert, den die Fortschrittsanzeige annehmen kann
  ;					iMaximum.i					- der Maximalwert, den die Fortschrittsanzeige annehmen kann
  ;
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_ProgressBar_Smooth: 	Die Fortschrittsanzeige erfolgt stufenlos anstelle der Benutzung von Blöcken. (Hinweis: Auf Windows XP mit eingeschalteten Skins und auf OS X hat dieses Flag keinen Effekt.)
  ;												| #PB_ProgressBar_Vertical: Die Fortschrittsanzeige erfolgt im vertikalen Modus.
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'ProgressBarGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========
  Procedure.i ProgressBarElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ProgressBarGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 							= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 						= "ProgressBarElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width						= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width						= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iFlags			= iFlags
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iMinimum			= iMinimum
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iMaximum			= iMaximum
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	ScrollBarElement
  ;
  ; Beschreibung ..: 	erstellt ein neues ScrollBarGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  ScrollBarElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iPageSize.i = 20, iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					iMinimum.i					- der Minimalwert, den der Schiebebalken annehmen kann
  ;					iMaximum.i					- der Maximalwert, den der Schiebebalken annehmen kann
  ;					iPageSize.i				- der Bereich, welcher Bestandteil der aktuell angezeigten "Seite" ist
  ;
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_ScrollBar_Vertical: Der Schiebebalken ist vertikal (anstelle von horizontal, was der Standard ist)
  
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'ScrollBarGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========
  Procedure.i ScrollBarElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iPageSize.i = 20, iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ScrollBarGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 							= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 						= "ScrollBarElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width						= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width						= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iFlags				= iFlags
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iMinimum			= iMinimum
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iMaximum			= iMaximum
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iPageSize		= iPageSize
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	ShortcutElement
  ;
  ; Beschreibung ..: 	erstellt ein neues ShortcutGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  ShortcutElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iShortcutKey.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					iShortcutKey.i			- Das anfänglich anzuzeigende Tastenkürzel. Die möglichen Werte sind die gleichen, wie bei der AddKeyboardShortcut() Funktion. 
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'ShortcutGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========
  Procedure.i ShortcutElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iShortcutKey.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ShortcutGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 							= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 						= "ShortcutElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width						= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width						= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iShortcutKey		= iShortcutKey
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SpinElement
  ;
  ; Beschreibung ..: 	erstellt ein neues SpinGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  SpinElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					iMinimum.i					- der Minimalwert, den das SpinGadget annehmen kann
  ;					iMaximum.i					- der Maximalwert, den das SpinGadget annehmen kann
  ;
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_Spin_ReadOnly:	Das StringGadget ist nicht editierbar, die Nummer ist nur über die Pfeile änderbar.
  ;												| #PB_Spin_Numeric: 	Das SpinGadget wird den Text automatisch mit dem aktuellen Wert des SpinGadgets-Status aktualisieren, womit SetGadgetText() nicht benötigt wird.
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'SpinGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========
  Procedure.i SpinElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#SpinGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 							= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 						= "SpinElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width						= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width						= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iFlags					= iFlags
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iMinimum				= iMinimum
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iMaximum				= iMaximum
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iValue					= iMinimum
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_sText					= Str(iMinimum)
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iBackgroundColor		= #PB_Default
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftfarbe			= #PB_Default
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	StringElement
  ;
  ; Beschreibung ..: 	erstellt ein neues StringGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  StringElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sValue.s = "", iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					sValue.s					- der anfängliche Inhalt dieses Elements
  ;
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_String_Numeric: 		Nur (positive) Ganzzahlen werden akzeptiert.
  ;												| #PB_String_Password: 		Passwort-Modus, es werden nur '*' anstelle normaler Zeichen angezeigt.
  ;												| #PB_String_ReadOnly: 		'Read only' bzw. Lese-Modus. Es kann kein Text eingegeben werden.
  ;												| #PB_String_LowerCase: 	Alle Zeichen werden automatisch in Kleinbuchstaben umgewandelt.
  ;												| #PB_String_UpperCase: 	Alle Zeichen werden automatisch in Großbuchstaben umgewandelt.
  ;												| #PB_String_BorderLess:	Es werden keine Ränder rings um das Gadget gezeichnet.
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'StringGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========
  Procedure.i StringElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sValue.s = "", iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#StringGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 							= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 						= "StringElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width						= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width						= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iFlags				= iFlags
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_sValue				= sValue
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iBackgroundColor		= #PB_Default
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftfarbe			= #PB_Default
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iMaximum				= 100000
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	TextElement
  ;
  ; Beschreibung ..: 	erstellt ein neues TextGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  TextElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					sText.s						- der anzuzeigende Text
  ;
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_Text_Center: 	Der Text wird im Element zentriert dargestellt.
  ;												| #PB_Text_Right: 	Der Text wird rechtsbündig dargestellt.
  ;												| #PB_Text_Border: 	Ein vertiefter Rand wird rings um das Element gezeichnet.
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	Die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'TextGadget'. Des Weiteren erzeugt dieses Element ein Event, wenn auf dieses geklickt wird.
  ;					Dies kann mit Hilfe der GetElementEvent() Funktion ermittelt werden.
  ;
  ;} ========
  Procedure.i TextElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, sText.s = "", iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#TextGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 							= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 						= "TextElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width						= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width						= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftfarbe			= #PB_Default
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iBackgroundColor		= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHintergrundfabe
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_sStatustext				= sText
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iFlags					= #SS_NOTIFY | #SS_CENTERIMAGE
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	TrackBarElement
  ;
  ; Beschreibung ..: 	erstellt ein neues TrackBarGadget-Element in der CustomStatusBar
  ;
  ; Syntax.........:  TrackBarElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iFlags.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar, auf der ein neues Element hinzugefügt werden soll
  ;					iMin_Width.i				- die minimale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;
  ;					iMax_Width.i				- die maximale Beite, mit der das Element in der CustomStatusBar angezeigt wird
  ;												| #PB_Default: verwendet die Standardbreite
  ;												| #PB_Ignore:  nutzt die verfügbare Breite der CustomStatusBar. (nutzen mehrere Elemente diesen Parameter, so wird die verfügbare Breite aufgeteilt)
  ;
  ;					iMinimum.i					- der Minimalwert, den die TrackBar annehmen kann
  ;					iMaximum.i					- der Maximalwert, den die TrackBar annehmen kann
  ;
  ;					iFlags.i					- zum Verändern des Element-Verhaltens. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_TrackBar_Ticks: 		Stellt einen 'Tick' Marker an jedem Schritt dar.
  ;												| #PB_TrackBar_Vertical: 	Das TrackBar ist jetzt vertikal (anstelle von horizontal, was der Standard ist).
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die ID des Elements zurück, das erstellt wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die Parameter dieses Elements sind voll kompatibel mit den Parametern des 'TrackBarGadget'. Gleiches gilt für die Events, die ausgelöst werden. (siehe PureBasic-Hilfe)
  ;
  ;} ========
  Procedure.i TrackBarElement (iCustomStatusBar_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Ignore, iMinimum.i = 0, iMaximum.i = 100, iFlags.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iElement_Array_groesse.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGadget_Min_Width.i			= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#TrackBarGadget)\_iMin_Width
    Protected iCounter.i					= 0
    Protected iElement_ID.i					= 0
    
    
    ; einen freien Eintrag im Element-Array suchen 
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #False
        iElement_ID = iCounter
        Break
      Else
        iElement_ID = 0
      EndIf
      
    Next
    
    
    ; einen neuen Eintrag im Element-Array erstellen, wenn keine freien Einträge gefunden wurden
    If iElement_ID = 0
      iElement_Array_groesse + 1
      iElement_ID = iElement_Array_groesse
      ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_Array_groesse)
    EndIf		
    
    
    ; Parameter überprüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 1)
      iMin_Width = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente + iGadget_Min_Width
      
    Else
      iMin_Width + CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
      
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width <> #PB_Ignore) And (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    ElseIf (iMax_Width <> #PB_Ignore) And ((iMax_Width = #PB_Default) Or (iMax_Width < 1))
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Array-Eintrag belegen und Basis-Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt 							= #True
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ 						= "TrackBarElement"
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width						= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width						= iMax_Width
    
    
    ; Gadget-spezifische Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iFlags				= iFlags
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iMinimum			= iMinimum
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iMaximum			= iMaximum
    
    
    ; Element-ID bei Erfolg zurückgeben
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;-
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	GetElementAttribute
  ;
  ; Beschreibung ..: 	gibt einen Attribut-Wert des angegebenen Elements zurück
  ;
  ; Syntax.........:  GetElementAttribute (iCustomStatusBar_ID.i, iElement_ID.i, iAttribute.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iAttribute.i					- das zu ermittelnde Attribut
  ;
  ; Rückgabewerte .:	Erfolg 						- gibt einen Attribut-Wert des angegebenen Elements zurück
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;												| -6: das angegebene Attribut wurde nicht gefunden
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit GetGadgetAttribute().
  ;				
  ;} ========
  Procedure.i GetElementAttribute (iCustomStatusBar_ID.i, iElement_ID.i, iAttribute.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected sElement_Typ.s		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iStatus.i			= 0
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ButtonImageElement"
        
        If iAttribute = #PB_Button_Image
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iImage_ID_normal
          
        ElseIf iAttribute = #PB_Button_PressedImage
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iImage_ID_gedrueckt
          
        Else
          iStatus = -6
          
        EndIf
        
        
      Case "CanvasElement"
        
        If iAttribute = #PB_Canvas_Image 
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iImage
          
        Else
          iStatus = -6
          
        EndIf
        
        
      Case "DateElement"
        
        If iAttribute = #PB_Date_Minimum 
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iMin_Datum
          
        ElseIf iAttribute = #PB_Date_Maximum
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iMax_Datum
          
        Else
          iStatus = -6
          
        EndIf
        
        
      Case "ProgressBarElement"
        
        If iAttribute = #PB_ProgressBar_Minimum 
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iMinimum
          
        ElseIf iAttribute = #PB_ProgressBar_Maximum
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iMaximum
          
        Else
          iStatus = -6
          
        EndIf
        
        
      Case "ScrollBarElement"
        
        If iAttribute = #PB_ScrollBar_Minimum 
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iMinimum
          
        ElseIf iAttribute = #PB_ScrollBar_Maximum
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iMaximum
          
        ElseIf iAttribute = #PB_ScrollBar_PageLength
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iPageSize
          
        Else
          iStatus = -6
          
        EndIf
        
        
      Case "SpinElement"
        
        If iAttribute = #PB_Spin_Minimum 
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iMinimum
          
        ElseIf iAttribute = #PB_Spin_Maximum
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iMaximum
          
        Else
          iStatus = -6
          
        EndIf
        
        
      Case "StringElement"
        
        If iAttribute = #PB_String_MaximumLength 
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iMaximum
          
        Else
          iStatus = -6
          
        EndIf
        
        
      Case "TrackBarElement"
        
        If iAttribute = #PB_TrackBar_Minimum 
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iMinimum
          
        ElseIf iAttribute = #PB_TrackBar_Maximum
          iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iMaximum
          
        Else
          iStatus = -6
          
        EndIf
        
        
    EndSelect
    
    
    ; gibt den Attributwert zurück
    ProcedureReturn iStatus
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	GetElementColor
  ;
  ; Beschreibung ..: 	gibt die Farbe des angegebenen Elements im RGB-Format zurück
  ;
  ; Syntax.........:  GetElementColor (iCustomStatusBar_ID.i, iElement_ID.i, iColor_Typ.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iColor_Typ.i					- die zu ermittelnde Einstellung. Dies kann einer der folgenden Werte sein: 
  ;												| #PB_Gadget_FrontColor     : Textfarbe des Gadget
  ;												| #PB_Gadget_BackColor      : Hintergrundfarbe des Gadget
  ;												| #PB_Gadget_LineColor      : Farbe für Gitterlinien
  ;												| #PB_Gadget_TitleFrontColor: Textfarbe im Titel         (für DateGadget_Element)
  ;												| #PB_Gadget_TitleBackColor : Hintergrundfarbe im Titel  (für DateGadget_Element)
  ;												| #PB_Gadget_GrayTextColor  : Farbe für "ergrauten" Text (bei DateGadget_Element)
  ;												
  ; Rückgabewerte .:	Erfolg 						- gibt die Farbe des angegebenen Elements im RGB-Format zurück
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;												| -6: der angegebene Farb-Typ wurde nicht gefunden
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit GetGadgetColor().
  ;				
  ;} ========
  Procedure.i GetElementColor (iCustomStatusBar_ID.i, iElement_ID.i, iColor_Typ.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected sElement_Typ.s		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iColor.i			= 0
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "DateElement"
        
        If iColor_Typ = #PB_Gadget_BackColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iBackgroundColor
          
        ElseIf iColor_Typ = #PB_Gadget_FrontColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iVordergrundfarbe
          
        ElseIf iColor_Typ = #PB_Gadget_TitleBackColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iTitel_Hintergrundfarbe
          
        ElseIf iColor_Typ = #PB_Gadget_TitleFrontColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iTitel_Vordergrundfarbe
          
        ElseIf iColor_Typ = #PB_Gadget_GrayTextColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iAusgegraute_Farbe
          
        Else
          iColor = -6
          
        EndIf
        
        
      Case "HyperLinkElement"
        
        If iColor_Typ = #PB_Gadget_FrontColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftfarbe
          
        ElseIf iColor_Typ = #PB_Gadget_BackColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iBackgroundColor
          
        Else
          iColor = -6
          
        EndIf
        
        
      Case "SpinElement"
        
        If iColor_Typ = #PB_Gadget_FrontColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftfarbe
          
        ElseIf iColor_Typ = #PB_Gadget_BackColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iBackgroundColor
          
        Else
          iColor = -6
          
        EndIf					
        
        
      Case "StringElement"
        
        If iColor_Typ = #PB_Gadget_FrontColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftfarbe
          
        ElseIf iColor_Typ = #PB_Gadget_BackColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iBackgroundColor
          
        Else
          iColor = -6
          
        EndIf				
        
        
      Case "TextElement"
        
        If iColor_Typ = #PB_Gadget_FrontColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftfarbe
          
        ElseIf iColor_Typ = #PB_Gadget_BackColor 
          iColor = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iBackgroundColor
          
        Else
          iColor = -6
          
        EndIf				
        
        
    EndSelect
    
    
    ; gibt die Farbe (RGB) zurück
    ProcedureReturn iColor
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	GetElementInformation
  ;
  ; Beschreibung ..: 	gibt allgemeine Informationen über ein Element
  ;
  ; Syntax.........:  GetElementInformation (iCustomStatusBar_ID.i, iElement_ID.i, sInformation.s = "Field")
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die ID des Elements, auf dem Bezug genommen wird
  ;					sInformation.s				- der neue Status der CustomStatusBar
  ;												| "Min_Width": gibt die minimale Beite des Elements zurück
  ;												| "Max_Width": gibt die maximale Beite des Elements zurück
  ;												| "Element_Typ": gibt den Typ des Elements zurück
  ;												| "Field": 		gibt die Field-Position des Elements in der CustomStatusBar zurück
  ;												| "Mouseinfo": 	gibt Mouseinformationen zurück
  ;
  ; Rückgabewerte .: 	Erfolg 						|  Parameter "Min_Width"
  ;													| >=0
  ;
  ;												|  Parameter "Max_Width"
  ;													| >=0
  ;
  ;												|  Parameter "Element_Typ"
  ;													| z.B. "ButtonElement", "TextElement", ...
  ;
  ;												|  Parameter "Field"
  ;													| >0: 	die Field-Position, in der sich das Element in der CustomStatusBar befindet (nur der erste Treffer, falls ein Element mehrfach dargestellt wird)
  ;													| =0: 	wenn dieses Element nicht in der CustomStatusBar angezeigt wird
  ;
  ;												|  Parameter "Mouseinfo"
  ;													| "0":		Maus befindet sich nicht über dem Element
  ;													| "1": 		Maus befindet sich über dem Element in der CustomStatusBar (das Element wird also in einem Field der CustomStatusBar dargestellt)
  ;													| "links": 	Maus befindet sich über dem Element in der CustomStatusBar und drückt die linke Maustaste
  ;													| "rechts": Maus befindet sich über dem Element in der CustomStatusBar und drückt die rechte Maustaste
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: das Element ist ungültig (die ID ist <= 0)
  ;												| -4: das Element ist ungültig
  ;												| -5: das Element wurde als 'nicht Belegt' markiert
  ;												| -6: der Parameter 'sInformation.s' ist ungültig
  ;
  ; Bemerkungen ...:	diese Funktion gibt sämtliche Werte als String zurück
  ;
  ;} ========
  Procedure.s GetElementInformation (iCustomStatusBar_ID.i, iElement_ID.i, sInformation.s = "Field")
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn Str(-1):		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn Str(-2):		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn Str(-3):		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn Str(-4):		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn Str(-5):		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iMax_Anzahl_Fielder.i		= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMax_Elements_visible
    Protected iElement_Field.i			= 0
    Protected iField_Nummer.i			= 0
    Protected iCounter.i 				= 0
    Protected iMaus_Field.i				= 0
    Protected sMaus_Klick.s				= ""
    
    
    ; die aktuelle Information selektieren
    Select sInformation
        
        
      Case "Min_Width"
        ProcedureReturn Str(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width)
        
        
      Case "Max_Width"
        ProcedureReturn Str(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width)
        
        
      Case "Element_Typ"
        ProcedureReturn CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
        
        
      Case "Field" 
        ; sucht nur nach dem ersten Treffer in der CustomStatusBar
        iElement_Field = _gebe_Field_des_Elements (iCustomStatusBar_ID, iElement_ID)			
        ProcedureReturn Str(iElement_Field)
        
        
      Case "Mouseinfo"
        iMaus_Field		= _pruefe_Mausposition(iCustomStatusBar_ID)	; prüft auf welchem Field sich die Maus in der CustomStatusBar befindet
        sMaus_Klick		= _pruefe_Mausaktion ()                 ; prüft, ob gerade eine Maustaste gedrückt wird 
        
        
        If sMaus_Klick = ""		; die Maus führt gerade keinen Klick aus
          sMaus_Klick = "1"   ; Maus über Field mit Element
        EndIf
        
        
        For iField_Nummer = 1 To iMax_Anzahl_Fielder
          
          iElement_Field = _gebe_Field_des_Elements (iCustomStatusBar_ID, iElement_ID, iField_Nummer)
          
          ; Maus auf dem Field mit dem ausgewählten Element
          If (iElement_Field > 0) And (iElement_Field = iMaus_Field) 
            ProcedureReturn sMaus_Klick
            Break
            
            
            ; das Element wird der CustomStatusBar dargestellt, aber die Maus befindet sich auf einem anderen Field --> Suche fortsetzen
          ElseIf (iElement_Field > 0) And (iElement_Field <> iMaus_Field)
            Continue
            
            
            ; das Element wird nicht der CustomStatusBar dargestellt
          ElseIf iElement_Field = 0
            ProcedureReturn "0"
            
          EndIf
          
        Next
        
        
      Default
        
        ; der Parameter ist ungültig
        ProcedureReturn Str(-6)
        
    EndSelect
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	GetElementStatus
  ;
  ; Beschreibung ..: 	gibt den aktuellen Status des angegebenen Elements zurück
  ;
  ; Syntax.........:  GetElementStatus (iCustomStatusBar_ID.i, iElement_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;
  ; Rückgabewerte .:	Erfolg 						- gibt den aktuellen Status des angegebenen Elements zurück
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit GetGadgetState().
  ;
  ; 					ButtonImageGadget(): 		- ändert den aktuellen Status eines #PB_Button_Toggle Schalters (1 = gedrückt, 0 = normal). 
  ; 					ButtonGadget(): 			- ändert den aktuellen Status eines #PB_Button_Toggle Schalters (1 = gedrückt, 0 = normal). 
  ; 					CheckBoxGadget(): 			- ändert den Status der Checkbox. Die folgenden Werte sind möglich: 
  ; 												| #PB_Checkbox_Checked: 	Setzt das Häkchen.
  ; 												| #PB_Checkbox_Unchecked: 	Entfernt das Häkchen.
  ; 												| #PB_Checkbox_Inbetween: 	Setzt den "Dazwischen"-Status. (Nur für #PB_CheckBox_ThreeState Checkboxen)
  ;
  ; 					ComboBoxGadget(): 			- ändert den aktuell selektierten Eintrag. 
  ; 					DateGadget(): 				- ändert das bzw. die aktuell angezeigte Datum/Zeit. Wenn #PB_Date_CheckBox verwendet wurde, setzen Sie 'Status' auf 0, um das Häkchen zu entfernen. 
  ; 					IPAddressGadget(): 			- ändert die aktuelle IP-Adresse. 
  ; 					ProgressBarGadget(): 		- ändert den Status der Fortschrittsanzeige. 
  ; 					ScrollBarGadget(): 			- ändert die aktuelle Position des Schiebebalkens. 
  ; 					ShortcutGadget(): 			- ändert das aktuelle Tastenkürzel. 
  ; 					SpinGadget(): 				- ändert den aktuellen Wert des SpinGadgets. 
  ; 					TrackBarGadget(): 			- ändert die aktuelle Regler-Position. 
  ;				
  ;} ========
  Procedure.i GetElementStatus (iCustomStatusBar_ID.i, iElement_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected sElement_Typ.s		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iIP_Field_1.i		= 0
    Protected iIP_Field_2.i		= 0
    Protected iIP_Field_3.i		= 0
    Protected iIP_Field_4.i		= 0
    Protected iStatus.i			= 0
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ButtonElement"
        iStatus	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iStatus
        
        
      Case "ButtonImageElement"
        iStatus	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iStatus
        
        
      Case "CheckBoxElement"
        iStatus	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iStatus
        
        
      Case "ComboBoxElement"
        iStatus	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iStatus
        
        
      Case "DateElement"
        iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iDate
        
        
      Case "IPAddressElement"	
        iIP_Field_1 = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_1
        iIP_Field_2 = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_2
        iIP_Field_3 = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_3
        iIP_Field_4 = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_4
        
        iStatus	= MakeIPAddress(iIP_Field_1, iIP_Field_2, iIP_Field_3, iIP_Field_4)
        
        
      Case "ProgressBarElement"
        iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iValue		
        
        
      Case "ScrollBarElement"
        iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iValue	
        
        
      Case "ShortcutElement"
        iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iShortcutKey
        
        
      Case "SpinElement"
        iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iValue		
        
        
      Case "TrackBarElement"
        iStatus = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iValue
        
        
    EndSelect
    
    
    ; den Status zurückgeben
    ProcedureReturn iStatus
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	GetElementText
  ;
  ; Beschreibung ..: 	gibt den Textinhalt des angegebenen Elements zurück
  ;
  ; Syntax.........:  GetElementText (iCustomStatusBar_ID.i, iElement_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;
  ; Rückgabewerte .:	Erfolg 						- gibt den Text des Elements zurück
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit GetGadgetText(). 
  ;					Wichtig: alle Rückgabewerte sind im Stringformat (einschließlich der Fehlercodes)
  ;				
  ;} ========
  Procedure.s GetElementText (iCustomStatusBar_ID.i, iElement_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn Str(-1):		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn Str(-2):		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn Str(-3):		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn Str(-4):		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn Str(-5):		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected sElement_Typ.s		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected sIP_Field_1.s		= ""
    Protected sIP_Field_2.s		= ""
    Protected sIP_Field_3.s		= ""
    Protected sIP_Field_4.s		= ""		
    Protected sText.s			= ""
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ButtonElement"
        sText = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_sText
        
        
      Case "CheckBoxElement"
        sText = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_sText
        
        
      Case "ComboBoxElement"
        sText = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_sText
        
        
      Case "DateElement"
        sText = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_sMaske		
        
        
      Case "ExplorerComboElement"
        sText = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_sDirectory
        
        
      Case "HyperLinkElement"
        sText = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_sText			
        
        
      Case "IPAddressElement"
        
        sIP_Field_1	= Str(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_1)
        sIP_Field_2	= Str(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_2)
        sIP_Field_3	= Str(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_3)
        sIP_Field_4	= Str(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_4)
        
        sText		= sIP_Field_1 + "." + sIP_Field_2 + "." + sIP_Field_3 + "." + sIP_Field_4
        
        
      Case "SpinElement"
        sText = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_sText
        
        
      Case "StringElement"
        sText = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_sValue		
        
        
      Case "TextElement"
        sText = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_sStatustext		
        
        
    EndSelect
    
    
    ; Text zurückgeben
    ProcedureReturn sText
    
  EndProcedure
  
  
  
  ;-
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetElementAttribute
  ;
  ; Beschreibung ..: 	ändert einen Attribut-Wert des angegebenen Elements
  ;
  ; Syntax.........:  SetElementAttribute (iCustomStatusBar_ID.i, iElement_ID.i, iAttribute.i, iValue.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iAttribute.i					- das zu setzende Attribut. Siehe die PureBasic-Dokumentation eines jeden Gadgets für die unterstützten Attribute und ihre Bedeutung. 
  ;					iValue.i						- der für das Attribut zu setzende Wert
  ;
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit SetGadgetAttribute().
  ;				
  ;} ========
  Procedure.i SetElementAttribute (iCustomStatusBar_ID.i, iElement_ID.i, iAttribute.i, iValue.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected sElement_Typ.s = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ButtonImageElement"
        
        If iAttribute = #PB_Button_Image
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iImage_ID_normal		= iValue
          
        ElseIf iAttribute = #PB_Button_PressedImage
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iImage_ID_gedrueckt	= iValue
          
        EndIf
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iUpdate_Flag				= #True
        
        
      Case "CanvasElement"
        
        If iAttribute = #PB_Canvas_Image 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iImage					= iValue
          
        EndIf			
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iUpdate_Flag					= #True
        
        
      Case "DateElement"
        
        If iAttribute = #PB_Date_Minimum 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iMin_Datum					= iValue
          
        ElseIf iAttribute = #PB_Date_Maximum
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iMax_Datum					= iValue
          
        EndIf					
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iUpdate_Flag					= #True
        
        
      Case "ProgressBarElement"
        
        If iAttribute = #PB_ProgressBar_Minimum 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iMinimum				= iValue
          
        ElseIf iAttribute = #PB_ProgressBar_Maximum
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iMaximum				= iValue
          
        EndIf					
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iUpdate_Flag				= #True
        
        
      Case "ScrollBarElement"
        
        If iAttribute = #PB_ScrollBar_Minimum 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iMinimum				= iValue
          
        ElseIf iAttribute = #PB_ScrollBar_Maximum
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iMaximum				= iValue
          
        ElseIf iAttribute = #PB_ScrollBar_PageLength
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iPageSize			= iValue
          
        EndIf					
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iUpdate_Flag				= #True
        
        
      Case "SpinElement"
        
        If iAttribute = #PB_Spin_Minimum 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iMinimum					= iValue
          
        ElseIf iAttribute = #PB_Spin_Maximum
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iMaximum					= iValue
          
        EndIf					
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iUpdate_Flag					= #True	
        
        
      Case "StringElement"
        
        If iAttribute = #PB_String_MaximumLength 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iMaximum					= iValue
          
        EndIf					
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iUpdate_Flag					= #True	
        
        
      Case "TrackBarElement"
        
        If iAttribute = #PB_TrackBar_Minimum 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iMinimum				= iValue
          
        ElseIf iAttribute = #PB_TrackBar_Maximum
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iMaximum				= iValue
          
        EndIf					
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iUpdate_Flag				= #True	
        
        
    EndSelect
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetElementWidth
  ;
  ; Beschreibung ..: 	ändert die Abmessung der angegebenen Elemente
  ;
  ; Syntax.........:  SetElementWidth (iCustomStatusBar_ID.i, iElement_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Default)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iMin_Width.i				- die Mindestbreite des Elements
  ;												| #PB_Default: verwendet die Standardbeite
  ;												| <=0: verwendet die Standardbeite
  ;												| >=1: Breite in Pixel
  ;
  ;					iMax_Width.i				- die Maximalbreite des Elements
  ;												| #PB_Default: verwendet die Standardbeite
  ;												| #PB_Ignore: es gibt kein Limit (nutzt die Breite, die zur Verfügung steht)
  ;												| <=0: verwendet die Standardbeite
  ;												| >=1: Breite in Pixel
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i SetElementWidth (iCustomStatusBar_ID.i, iElement_ID.i, iMin_Width.i = #PB_Default, iMax_Width.i = #PB_Default)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected sElement_Typ.s				= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iStandard_Min_Width.i	= 0
    
    
    ; den Gadget-Typ selektieren und die Mindestbreite ermitteln (Standardwert)
    Select sElement_Typ
      Case "ButtonElement":		iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ButtonGadget)\_iMin_Width
      Case "ButtonImageElement":	iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ButtonImageGadget)\_iMin_Width
      Case "CanvasElement":		iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#CanvasGadget)\_iMin_Width
      Case "CheckBoxElement":		iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#CheckBoxGadget)\_iMin_Width
      Case "ComboBoxElement":		iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ComboBoxGadget)\_iMin_Width
      Case "DateElement":			iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#DateGadget)\_iMin_Width
      Case "ExplorerComboElement":	iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ExplorerComboGadget)\_iMin_Width
      Case "HyperLinkElement":		iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#HyperLinkGadget)\_iMin_Width
      Case "IPAddressElement":		iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#IPAddressGadget)\_iMin_Width
      Case "ProgressBarElement":	iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ProgressBarGadget)\_iMin_Width
      Case "ScrollBarElement":		iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ScrollBarGadget)\_iMin_Width
      Case "ShortcutElement":		iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ShortcutGadget)\_iMin_Width
      Case "SpinElement":			iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#SpinGadget)\_iMin_Width
      Case "StringElement":		iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#StringGadget)\_iMin_Width
      Case "TextElement":			iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#TextGadget)\_iMin_Width
      Case "TrackBarElement":		iStandard_Min_Width = CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#TrackBarGadget)\_iMin_Width
      Default:					iStandard_Min_Width = 80
    EndSelect
    
    
    ; die Parameter prüfen und ggf. korrigieren (Min-Breite)
    If (iMin_Width = #PB_Default) Or (iMin_Width < 0)
      iMin_Width = iStandard_Min_Width
      
    EndIf
    
    
    ; die Parameter prüfen und ggf. korrigieren (Max-Breite)
    If (iMax_Width = #PB_Default)
      iMax_Width = iStandard_Min_Width
      
    ElseIf (iMax_Width = #PB_Ignore)
      iMax_Width = #PB_Ignore
      
    ElseIf (iMax_Width < iMin_Width)
      iMax_Width = iMin_Width
      
    EndIf
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width	= iMin_Width
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width	= iMax_Width
    
    
    ; CustomStatusBar aktualisieren, wenn das Element in der CustomStatusBar dargestellt wird
    If (_gebe_Field_des_Elements (iCustomStatusBar_ID, iElement_ID) > 0)
      _erneuere_CustomStatusBar(iCustomStatusBar_ID)
    EndIf
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetElementColor
  ;
  ; Beschreibung ..: 	ändert die Farbe des angegebenen Elements
  ;
  ; Syntax.........:  SetElementColor (iCustomStatusBar_ID.i, iElement_ID.i, iColor_Typ.i, iColor.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iColor_Typ.i					- die Art des zu ändernden Farb-Attributs. Dies kann einer der folgenden Werte sein:
  ;												| #PB_Gadget_FrontColor     : Textfarbe des Gadget
  ;												| #PB_Gadget_BackColor      : Hintergrundfarbe des Gadget
  ;												| #PB_Gadget_LineColor      : Farbe für Gitterlinien
  ;												| #PB_Gadget_TitleFrontColor: Textfarbe im Titel         (für DateGadget_Element)
  ;												| #PB_Gadget_TitleBackColor : Hintergrundfarbe im Titel  (für DateGadget_Element)
  ;												| #PB_Gadget_GrayTextColor  : Farbe für "ergrauten" Text (bei DateGadget_Element)
  ;
  ;					iColor.i					- der für das Attribut zu setzende Wert
  ;												| #PB_Default:	verwendet die Hintergrundfarbe der CustomStatusBar
  ;												| #PB_Ignore:	verwendet die Hintergrundfarbe der CustomStatusBar
  ;												| RGB()-Wert:	benutzerdefinierter Farbcode (im RGB-Format)
  ;												| -1:			verwendet die Standard-Systemfarbe
  ;												
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit SetGadgetColor().
  ;				
  ;} ========
  Procedure.i SetElementColor (iCustomStatusBar_ID.i, iElement_ID.i, iColor_Typ.i, iColor.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected sElement_Typ.s = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    
    
    ; Parameter überprüfen und ggf. korrigieren (iColor)
    If (iColor = #PB_Default) Or (iColor = #PB_Ignore)
      iColor = CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHintergrundfabe
    EndIf
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "DateElement"
        
        If iColor_Typ = #PB_Gadget_BackColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iBackgroundColor			= iColor
          
        ElseIf iColor_Typ = #PB_Gadget_FrontColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iVordergrundfarbe			= iColor
          
        ElseIf iColor_Typ = #PB_Gadget_TitleBackColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iTitel_Hintergrundfarbe		= iColor
          
        ElseIf iColor_Typ = #PB_Gadget_TitleFrontColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iTitel_Vordergrundfarbe		= iColor
          
        ElseIf iColor_Typ = #PB_Gadget_GrayTextColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iAusgegraute_Farbe			= iColor
          
        EndIf					
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iUpdate_Flag					= #True
        
        
      Case "HyperLinkElement"
        
        If iColor_Typ = #PB_Gadget_FrontColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftfarbe			= iColor
          
        ElseIf iColor_Typ = #PB_Gadget_BackColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iBackgroundColor		= iColor
          
        EndIf
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iUpdate_Flag				= #True	
        
        
      Case "SpinElement"
        
        If iColor_Typ = #PB_Gadget_FrontColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftfarbe				= iColor
          
        ElseIf iColor_Typ = #PB_Gadget_BackColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iBackgroundColor			= iColor
          
        EndIf					
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iUpdate_Flag					= #True	
        
        
      Case "StringElement"
        
        If iColor_Typ = #PB_Gadget_FrontColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftfarbe				= iColor
          
        ElseIf iColor_Typ = #PB_Gadget_BackColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iBackgroundColor			= iColor
          
        EndIf					
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iUpdate_Flag					= #True	
        
        
      Case "TextElement"
        
        If iColor_Typ = #PB_Gadget_FrontColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftfarbe				= iColor
          
        ElseIf iColor_Typ = #PB_Gadget_BackColor 
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iBackgroundColor			= iColor
          
        EndIf					
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iUpdate_Flag					= #True			
        
        
    EndSelect
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetElementFont
  ;
  ; Beschreibung ..: 	weist dem angegebenen Element eine Schriftart zu
  ;
  ; Syntax.........:  SetElementFont (iCustomStatusBar_ID.i, iElement_ID.i, sFontName.s = "", iHeight.i = #PB_Default, iFlags.i = #PB_Default)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					sFontName.s				- der Name des zu ladenden Zeichensatzes
  ;					iHeight.i					- die vertikale Größe des Zeichensatzes in Punkten
  ;												| #PB_Default:	Standardgröße verwenden (Größe 12)
  ;												| >0:			benutzerdefinierte Schriftgröße
  ;
  ;					iFlags.i					- optionale Varianten des zu ladenden Zeichensatzes. Dies kann eine Kombination (verknüpft mit dem bitweisen '|' OR-Operator) der folgenden Konstanten sein:
  ;												| #PB_Default:			Normalschrift
  ;												| #PB_Font_Bold:		Fettschrift
  ;												| #PB_Font_Italic:		Kursiv (Schrägschrift)
  ;												| #PB_Font_Underline:	Unterstrichen (nur auf Windows)
  ;												| #PB_Font_StrikeOut:	Durchgestrichen (nur auf Windows)
  ;												| #PB_Font_HighQuality:	Zeichensatz mit höchster Qualität laden (langsamer) (nur auf Windows)
  ;
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit LoadFont(). 
  ;				
  ;} ========
  Procedure.i SetElementFont (iCustomStatusBar_ID.i, iElement_ID.i, sFontName.s = "", iHeight.i = #PB_Default, iFlags.i = #PB_Default)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected sElement_Typ.s		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iSchriftart_ID.i 	= 0
    
    
    ; Parameter überprüfen und ggf. korrigieren (iHeight)
    If (iHeight = #PB_Default) Or (iHeight <= 0)
      iHeight = 12
    EndIf
    
    
    ; Parameter überprüfen und ggf. korrigieren (iFlags)
    If iFlags = #PB_Default
      iFlags = 0
    EndIf
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ButtonElement"
        
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_ID
        
        ; alte Schriftart löschen
        If IsFont(iSchriftart_ID) <> 0
          FreeFont(iSchriftart_ID)
        EndIf							
        
        
        ; neue Schriftart laden
        If sFontName = ""
          iSchriftart_ID = #PB_Default
        Else
          iSchriftart_ID = LoadFont(#PB_Any, sFontName, iHeight, iFlags)
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_ID 				= iSchriftart_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_sFontName_Name				= sFontName
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_Hoehe				= iHeight
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_Flags				= iFlags
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iUpdate_Flag					= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_Update			= #True
        
        
      Case "CheckBoxElement"
        
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_ID
        
        ; alte Schriftart löschen
        If IsFont(iSchriftart_ID) <> 0
          FreeFont(iSchriftart_ID)
        EndIf							
        
        
        ; neue Schriftart laden
        If sFontName = ""
          iSchriftart_ID = #PB_Default
        Else
          iSchriftart_ID = LoadFont(#PB_Any, sFontName, iHeight, iFlags)
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_ID 				= iSchriftart_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_sFontName_Name			= sFontName
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_Hoehe			= iHeight
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_Flags			= iFlags
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iUpdate_Flag				= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_Update			= #True
        
        
      Case "ComboBoxElement"
        
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_ID
        
        ; alte Schriftart löschen
        If IsFont(iSchriftart_ID) <> 0
          FreeFont(iSchriftart_ID)
        EndIf							
        
        
        ; neue Schriftart laden
        If sFontName = ""
          iSchriftart_ID = #PB_Default
        Else
          iSchriftart_ID = LoadFont(#PB_Any, sFontName, iHeight, iFlags)
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_ID 				= iSchriftart_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_sFontName_Name			= sFontName
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_Hoehe			= iHeight
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_Flags			= iFlags
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag				= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_Update			= #True
        
        
      Case "DateElement"
        
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_ID
        
        ; alte Schriftart löschen
        If IsFont(iSchriftart_ID) <> 0
          FreeFont(iSchriftart_ID)
        EndIf							
        
        
        ; neue Schriftart laden
        If sFontName = ""
          iSchriftart_ID = #PB_Default
        Else
          iSchriftart_ID = LoadFont(#PB_Any, sFontName, iHeight, iFlags)
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_ID 					= iSchriftart_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_sFontName_Name				= sFontName
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_Hoehe				= iHeight
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_Flags				= iFlags
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iUpdate_Flag					= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_Update				= #True
        
        
      Case "ExplorerComboElement"
        
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_ID
        
        ; alte Schriftart löschen
        If IsFont(iSchriftart_ID) <> 0
          FreeFont(iSchriftart_ID)
        EndIf							
        
        
        ; neue Schriftart laden
        If sFontName = ""
          iSchriftart_ID = #PB_Default
        Else
          iSchriftart_ID = LoadFont(#PB_Any, sFontName, iHeight, iFlags)
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_ID 		= iSchriftart_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_sFontName_Name		= sFontName
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_Hoehe		= iHeight
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_Flags		= iFlags
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iUpdate_Flag			= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_Update		= #True
        
        
      Case "HyperLinkElement"
        
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_ID
        
        ; alte Schriftart löschen
        If IsFont(iSchriftart_ID) <> 0
          FreeFont(iSchriftart_ID)
        EndIf							
        
        
        ; neue Schriftart laden
        If sFontName = ""
          iSchriftart_ID = #PB_Default
        Else
          iSchriftart_ID = LoadFont(#PB_Any, sFontName, iHeight, iFlags)
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_ID 			= iSchriftart_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_sFontName_Name			= sFontName
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_Hoehe			= iHeight
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_Flags			= iFlags
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iUpdate_Flag				= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_Update			= #True
        
        
      Case "IPAddressElement"
        
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_ID
        
        ; alte Schriftart löschen
        If IsFont(iSchriftart_ID) <> 0
          FreeFont(iSchriftart_ID)
        EndIf							
        
        
        ; neue Schriftart laden
        If sFontName = ""
          iSchriftart_ID = #PB_Default
        Else
          iSchriftart_ID = LoadFont(#PB_Any, sFontName, iHeight, iFlags)
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_ID 			= iSchriftart_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_sFontName_Name			= sFontName
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_Hoehe			= iHeight
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_Flags			= iFlags
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iUpdate_Flag				= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_Update			= #True
        
        
      Case "ShortcutElement"
        
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_ID
        
        ; alte Schriftart löschen
        If IsFont(iSchriftart_ID) <> 0
          FreeFont(iSchriftart_ID)
        EndIf							
        
        
        ; neue Schriftart laden
        If sFontName = ""
          iSchriftart_ID = #PB_Default
        Else
          iSchriftart_ID = LoadFont(#PB_Any, sFontName, iHeight, iFlags)
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_ID 				= iSchriftart_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_sFontName_Name			= sFontName
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_Hoehe			= iHeight
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_Flags			= iFlags
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iUpdate_Flag				= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_Update			= #True
        
        
      Case "SpinElement"
        
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_ID
        
        ; alte Schriftart löschen
        If IsFont(iSchriftart_ID) <> 0
          FreeFont(iSchriftart_ID)
        EndIf							
        
        
        ; neue Schriftart laden
        If sFontName = ""
          iSchriftart_ID = #PB_Default
        Else
          iSchriftart_ID = LoadFont(#PB_Any, sFontName, iHeight, iFlags)
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_ID 					= iSchriftart_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_sFontName_Name				= sFontName
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_Hoehe				= iHeight
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_Flags				= iFlags
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iUpdate_Flag					= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_Update				= #True
        
        
      Case "StringElement"
        
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_ID
        
        ; alte Schriftart löschen
        If IsFont(iSchriftart_ID) <> 0
          FreeFont(iSchriftart_ID)
        EndIf							
        
        
        ; neue Schriftart laden
        If sFontName = ""
          iSchriftart_ID = #PB_Default
        Else
          iSchriftart_ID = LoadFont(#PB_Any, sFontName, iHeight, iFlags)
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_ID 				= iSchriftart_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_sFontName_Name				= sFontName
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_Hoehe				= iHeight
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_Flags				= iFlags
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iUpdate_Flag					= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_Update			= #True
        
        
      Case "TextElement"
        
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_ID
        
        ; alte Schriftart löschen
        If IsFont(iSchriftart_ID) <> 0
          FreeFont(iSchriftart_ID)
        EndIf							
        
        
        ; neue Schriftart laden
        If sFontName = ""
          iSchriftart_ID = #PB_Default
        Else
          iSchriftart_ID = LoadFont(#PB_Any, sFontName, iHeight, iFlags)
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_ID 					= iSchriftart_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_sFontName_Name				= sFontName
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_Hoehe				= iHeight
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_Flags				= iFlags
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iUpdate_Flag					= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_Update				= #True
        
    EndSelect
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetElementStatus
  ;
  ; Beschreibung ..: 	ändert den aktuellen Status des angegebenen Elements
  ;
  ; Syntax.........:  SetElementStatus (iCustomStatusBar_ID.i, iElement_ID.i, iStatus.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iStatus.i					- der neue Status des Elements
  ;
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit SetGadgetState().
  ;
  ; 					ButtonImageGadget(): 		- ändert den aktuellen Status eines #PB_Button_Toggle Schalters (1 = gedrückt, 0 = normal). 
  ; 					ButtonGadget(): 			- ändert den aktuellen Status eines #PB_Button_Toggle Schalters (1 = gedrückt, 0 = normal). 
  ; 					CheckBoxGadget(): 			- ändert den Status der Checkbox. Die folgenden Werte sind möglich: 
  ; 												| #PB_Checkbox_Checked: 	Setzt das Häkchen.
  ; 												| #PB_Checkbox_Unchecked: 	Entfernt das Häkchen.
  ; 												| #PB_Checkbox_Inbetween: 	Setzt den "Dazwischen"-Status. (Nur für #PB_CheckBox_ThreeState Checkboxen)
  ;
  ; 					ComboBoxGadget(): 			- ändert den aktuell selektierten Eintrag. 
  ; 					DateGadget(): 				- ändert das bzw. die aktuell angezeigte Datum/Zeit. Wenn #PB_Date_CheckBox verwendet wurde, setzen Sie 'Status' auf 0, um das Häkchen zu entfernen. 
  ; 					IPAddressGadget(): 			- ändert die aktuelle IP-Adresse. 
  ; 					ProgressBarGadget(): 		- ändert den Status der Fortschrittsanzeige. 
  ; 					ScrollBarGadget(): 			- ändert die aktuelle Position des Schiebebalkens. 
  ; 					ShortcutGadget(): 			- ändert das aktuelle Tastenkürzel. 
  ; 					SpinGadget(): 				- ändert den aktuellen Wert des SpinGadgets. 
  ; 					TrackBarGadget(): 			- ändert die aktuelle Regler-Position. 
  ;				
  ;} ========
  Procedure.i SetElementStatus (iCustomStatusBar_ID.i, iElement_ID.i, iStatus.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected sElement_Typ.s = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ButtonElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iStatus				= iStatus
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iUpdate_Flag			= #True
        
        
      Case "ButtonImageElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iStatus			= iStatus
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iUpdate_Flag		= #True
        
        
      Case "CheckBoxElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iStatus				= iStatus
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iUpdate_Flag		= #True
        
        
      Case "ComboBoxElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iStatus				= iStatus
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag		= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Status		= #True
        
        
      Case "DateElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iDate					= iStatus
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iUpdate_Flag			= #True
        
        
      Case "IPAddressElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_1			= IPAddressField(iStatus, 0)
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_2			= IPAddressField(iStatus, 1)
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_3			= IPAddressField(iStatus, 2)
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_4			= IPAddressField(iStatus, 3)
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iUpdate_Flag		= #True			
        
        
      Case "ProgressBarElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iValue			= iStatus
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iUpdate_Flag		= #True			
        
        
      Case "ScrollBarElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iValue				= iStatus
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iUpdate_Flag		= #True		
        
        
      Case "ShortcutElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iShortcutKey		= iStatus
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iUpdate_Flag		= #True			
        
        
      Case "SpinElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iValue					= iStatus
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iUpdate_Flag			= #True				
        
        
      Case "TrackBarElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iValue				= iStatus
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iUpdate_Flag		= #True				
        
        
    EndSelect
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetElementText
  ;
  ; Beschreibung ..: 	ändert den Text-Inhalt des angegebenen Elements
  ;
  ; Syntax.........:  SetElementText (iCustomStatusBar_ID.i, iElement_ID.i, sText.s)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					sText.s						- der zu setzende neue Text
  ;
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit SetGadgetText(). 
  ;				
  ;} ========
  Procedure.i SetElementText (iCustomStatusBar_ID.i, iElement_ID.i, sText.s)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected sElement_Typ.s	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ButtonElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_sText					= sText
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iUpdate_Flag			= #True
        
        
      Case "CheckBoxElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_sText				= sText
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iUpdate_Flag		= #True
        
        
      Case "ComboBoxElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_sText				= sText
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag		= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Text		= #True
        
        
      Case "DateElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_sMaske					= sText
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iUpdate_Flag			= #True
        
        
      Case "ExplorerComboElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_sDirectory	= sText
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iUpdate_Flag	= #True			
        
        
      Case "HyperLinkElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_sText				= sText
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iUpdate_Flag		= #True						
        
        
      Case "IPAddressElement"
        
        If sText = ""
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_1		= 0
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_2		= 0
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_3		= 0
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_4		= 0
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iUpdate_Flag	= #True	
        EndIf
        
        
      Case "SpinElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_sText					= sText
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iUpdate_Flag			= #True						
        
        
      Case "StringElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_sValue				= sText
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iUpdate_Flag			= #True							
        
        
      Case "TextElement"
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_sStatustext				= sText
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iUpdate_Flag			= #True			
        
        
    EndSelect
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;-
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	RemoveElement
  ;
  ; Beschreibung ..: 	entfernt ein Element vollständig aus der CustomStatusBar
  ;
  ; Syntax.........:  RemoveElement (iCustomStatusBar_ID.i, iElement_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die ID des Elements, welches entfernt werden soll
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	befindet sich das Element zu diesem Zeitpunkt in einem Field der CustomStatusBar, so wird das Field ebenfalls gelöscht
  ;
  ;} ========
  Procedure.i RemoveElement (iCustomStatusBar_ID.i, iElement_ID.i)
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected sElement_Typ.s			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iSchriftart_ID.i 		= 0
    Protected iCounter.i			= 0
    Protected iAnzahl_Items.i		= 0
    
    
    ; Tooltips und Kontextmenü-Eintrag entfernen
    RemoveToolTip				(iCustomStatusBar_ID.i, iElement_ID.i)
    RemoveBallonTip			(iCustomStatusBar_ID.i, iElement_ID.i)
    RemoveContextMenuItem	(iCustomStatusBar_ID.i, iElement_ID.i)
    
    
    ; Basisinformationen entfernen
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt		= #False
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width	= 0
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width	= 0
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ	= ""
    
    
    ; Gadget-Typ selektieren und Element-Informationen entfernen
    Select sElement_Typ
        
        
      Case "ButtonElement"
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_ID
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_sFontName_Name					= ""
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_Hoehe					= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_Flags					= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iUpdate_Flag						= #False
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_Update				= #False
        
        
      Case "CheckBoxElement"
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_ID
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_sFontName_Name				= ""
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_Hoehe				= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_Flags				= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iUpdate_Flag					= #False
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_Update				= #False
        
        
      Case "ComboBoxElement"
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_ID
        iAnzahl_Items  = ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item())
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_sFontName_Name				= ""
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_Hoehe				= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_Flags				= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag					= #False
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_Update				= #False
        
        
        ; Items entfernen
        For iCounter = 0 To iAnzahl_Items Step 1
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_sText 		= ""
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iImage_ID 	= 0
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iValue 		= 0
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iPosition 	= 0
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt 		= #False
        Next			
        
        
      Case "DateElement"
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_ID
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_sFontName_Name					= ""
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_Hoehe					= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_Flags					= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iUpdate_Flag						= #False
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_Update					= #False
        
        
      Case "ExplorerComboElement"
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_ID
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_sFontName_Name			= ""
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_Hoehe			= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_Flags			= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iUpdate_Flag				= #False
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_Update			= #False
        
        
      Case "HyperLinkElement"
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_ID
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_sFontName_Name				= ""
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_Hoehe				= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_Flags				= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iUpdate_Flag					= #False
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_Update				= #False
        
        
      Case "IPAddressElement"
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_ID
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_sFontName_Name				= ""
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_Hoehe				= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_Flags				= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iUpdate_Flag					= #False
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_Update				= #False
        
        
      Case "ShortcutElement"
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_ID
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_sFontName_Name				= ""
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_Hoehe				= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_Flags				= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iUpdate_Flag					= #False
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_Update				= #False
        
        
        
      Case "SpinElement"
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_ID
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_sFontName_Name					= ""
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_Hoehe					= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_Flags					= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iUpdate_Flag						= #False
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_Update					= #False
        
        
      Case "StringElement"
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_ID
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_sFontName_Name					= ""
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_Hoehe					= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_Flags					= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iUpdate_Flag						= #False
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_Update				= #False
        
        
      Case "TextElement"
        iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_ID
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_sFontName_Name					= ""
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_Hoehe					= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_Flags					= 0
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iUpdate_Flag						= #False
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_Update					= #False
        
    EndSelect
    
    
    ; Schriftart entfernen
    If IsFont(iSchriftart_ID) <> 0
      FreeFont(iSchriftart_ID)
    EndIf	
    
    
    ; die CustomStatusBar aktualisieren
    _erneuere_CustomStatusBar (iCustomStatusBar_ID.i)
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;-
  ;-
  ;-
  ;- Verwalten von Element-Items
  ;- -------------------------------------------------------------
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	AddElementItem
  ;
  ; Beschreibung ..: 	fügt einem Element ein Item hinzu
  ;
  ; Syntax.........:  AddElementItem (iCustomStatusBar_ID.i, iElement_ID.i, iPosition.i, sText.s, iImage_ID.i = 0)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iPosition.i					- der Eintrag-Index, wo der neue Eintrag eingefügt werden soll. 
  ;												|  0: diesen Eintrag am Anfang einzufügen
  ;												| -1: diesen Eintrag am Ende der aktuellen Eintrag-Liste hinzuzufügen
  ;
  ;					sText.s						- der Text für den neuen Eintrag. 
  ;					iImage_ID.i					- ein optionales Bild, welches für Einträge in Elemente verwendet werden kann, die dies unterstützen. Verwenden Sie den ImageID() Befehl, um die ID für diesen Parameter zu erhalten. 
  ;
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit AddGadgetItem(). 
  ;					Zur Zeit unterstützt das ComboBoxGadget-Element die Verwendung von Items.
  ;				
  ;} ========
  Procedure.i AddElementItem (iCustomStatusBar_ID.i, iElement_ID.i, iPosition.i, sText.s, iImage_ID.i = 0)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iItem_Anzahl.i		= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item())
    Protected sElement_Typ.s			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iPosition_Offset.i	= OffsetOf(Element_ComboBoxGadget_Item\_iPosition)
    Protected iPosition_Typ.i		= TypeOf(Element_ComboBoxGadget_Item\_iPosition)
    Protected iItem_Nummer.i 		= 0
    Protected iCounter.i			= 0
    Protected iItem_ID.i			= 0
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ComboBoxElement"
        
        
        ; einen freien Eintrag im Item-Array suchen 
        For iCounter = 1 To iItem_Anzahl Step 1
          If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt = #False
            iItem_ID = iCounter
            Break
          Else
            iItem_ID = 0
          EndIf
        Next		
        
        
        ; einen neuen Eintrag im Item-Array erstellen, wenn keine freien Einträge gefunden wurden
        If iItem_ID = 0
          iItem_ID = iItem_Anzahl + 1
          ReDim CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iItem_ID)
          iItem_Anzahl = ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item())
        EndIf
        
        
        ; ggf. die Positionsangabe anpassen, um die korrekte Sortierung zu gewährleisten
        If (iPosition >= 0) And (iPosition <= iItem_Anzahl)
          
          If iPosition = 0
            iPosition = -1
          EndIf
          
        ElseIf (iPosition <= -1) Or (iPosition > iItem_Anzahl)
          iPosition = iItem_ID
        EndIf
        
        
        ; Einstellungen speichern
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag 				= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iItem_ID)\_iBelegt 		= #True
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iItem_ID)\_iPosition	= iPosition
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iItem_ID)\_iImage_ID	= iImage_ID
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iItem_ID)\_sText		= sText
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iItem_ID)\_iValue		= 0
        
        
        ; Item-Positionen sortieren
        SortStructuredArray(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(), #PB_Sort_Ascending, iPosition_Offset, iPosition_Typ)
        
        
        ; das Item-Array neu nummerieren
        For iCounter = 0 To iItem_Anzahl Step 1
          
          If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt 		= #True
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iPosition	= iItem_Nummer
            iItem_Nummer + 1
          EndIf
          
        Next
        
        
    EndSelect
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;-
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	CountElementItem
  ;
  ; Beschreibung ..: 	gibt die Anzahl der Items eines Elements zurück
  ;
  ; Syntax.........:  CountElementItem (iCustomStatusBar_ID.i, iElement_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;
  ; Rückgabewerte .:	Erfolg 						| >=0: gibt die Anzahl der Items eines Elements zurück
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	
  ;				
  ;} ========
  Procedure.i CountElementItem (iCustomStatusBar_ID.i, iElement_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iItem_Anzahl.i		= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item())		
    Protected sElement_Typ.s			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iCounter.i			= 0
    Protected iItems_gefunden.i		= 0
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ComboBoxElement"
        
        ; zähle die Items
        For iCounter = 1 To iItem_Anzahl Step 1
          If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt = #True
            iItems_gefunden + 1
          EndIf
        Next		
        
    EndSelect
    
    
    ; die Anzahl der Items zurückgeben
    ProcedureReturn iItems_gefunden
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	GetElementItemData
  ;
  ; Beschreibung ..: 	gibt den Wert zurück, welcher zuvor für diesen Element-Eintrag mittels SetElementItemData() gespeichert wurde. Dies ermöglicht das Verknüpfen eines individuellen Werts mit den Einträgen eines Element. 
  ;
  ; Syntax.........:  GetElementItemData (iCustomStatusBar_ID.i, iElement_ID.i, iItem.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iItem.i					- der zu entfernende Eintrag. Der erste Eintrag hat den Index 0.
  ;
  ; Rückgabewerte .:	Erfolg 						- gibt die gespeicherten Daten zurück. Wenn für den Eintrag noch kein Wert gespeichert wurde, wird der Rückgabewert gleich 0 sein. 
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;												| -6: der angegebene Eintrag wurde nicht gefunden
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit GetGadgetItemData(). 
  ;				
  ;} ========
  Procedure.i GetElementItemData (iCustomStatusBar_ID.i, iElement_ID.i, iItem.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iItem_Anzahl.i	= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item())		
    Protected sElement_Typ.s		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iCounter.i		= 0
    Protected iValue.i			= 0
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ComboBoxElement"
        
        For iCounter = 0 To iItem_Anzahl Step 1
          
          If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt = #True)
            
            ; die Daten des Items auslesen
            If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iPosition = iItem)
              
              iValue = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iValue
              Break 
              
            EndIf
            
          Else
            ; setzt ein Fehlerwert, wenn die Position nicht gefunden wurde
            iValue = -6
          EndIf
          
        Next
        
    EndSelect
    
    
    ; die Daten des Items zurückgeben
    ProcedureReturn iValue
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	GetElementItemText
  ;
  ; Beschreibung ..: 	gibt den Textinhalt des angegebenen Eintrags vom angegebenen Element zurück
  ;
  ; Syntax.........:  GetElementItemText (iCustomStatusBar_ID.i, iElement_ID.i, iItem.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iItem.i					- der Eintrag, von dem der Text ermittelt werden soll. (der erste Eintrag im Element hat den Index 0)
  ;
  ; Rückgabewerte .:	Erfolg 						- gibt den Text des Items zurück
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit GetGadgetItemText(). 
  ;					Wichtig: alle Rückgabewerte sind im Stringformat (einschließlich der Fehlercodes)
  ;				
  ;} ========
  Procedure.s GetElementItemText (iCustomStatusBar_ID.i, iElement_ID.i, iItem.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn Str(-1):		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn Str(-2):		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn Str(-3):		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn Str(-4):		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn Str(-5):		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iItem_Anzahl.i	= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item())		
    Protected sElement_Typ.s		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iCounter.i		= 0
    Protected sText.s			= ""
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ComboBoxElement"
        
        For iCounter = 0 To iItem_Anzahl Step 1
          
          
          ; Itemtext auslesen
          If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt = #True)
            
            If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iPosition = iItem)
              sText = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iItem)\_sText
              Break 
            EndIf
            
          Else
            sText = ""
          EndIf
          
        Next
        
    EndSelect
    
    
    ; Itemtext zurückgeben
    ProcedureReturn sText
    
  EndProcedure
  
  
  
  ;-
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetElementItemData
  ;
  ; Beschreibung ..: 	speichert den angegebenen Wert mit dem angegebenen Element-Eintrag. Dies ermöglicht das Verknüpfen eines individuellen Werts mit den Einträgen eines Element. 
  ;
  ; Syntax.........:  SetElementItemData (iCustomStatusBar_ID.i, iElement_ID.i, iItem.i, iValue.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iItem.i					- der zu entfernende Eintrag. Der erste Eintrag hat den Index 0.
  ;					iValue.i						- der zu setzende Wert
  ;
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;												| -6: der angegebene Eintrag wurde nicht gefunden
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit SetGadgetItemData(). 
  ;				
  ;} ========
  Procedure.i SetElementItemData (iCustomStatusBar_ID.i, iElement_ID.i, iItem.i, iValue.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iItem_Anzahl.i	= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item())
    Protected sElement_Typ.s		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iCounter.i		= 0
    Protected iStatus.i			= 0
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ComboBoxElement"
        
        For iCounter = 0 To iItem_Anzahl Step 1
          
          ; speichert die neuen Daten des Items
          If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt = #True)
            
            If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iPosition = iItem)
              
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iValue	= iValue
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag			= #True	
              iStatus = 0
              Break 
              
            EndIf
            
          Else
            ; setzt ein Fehlerwert, wenn die Position nicht gefunden wurde
            iStatus = -6
          EndIf
          
        Next
        
    EndSelect
    
    
    ; die Position des geänderten Items zurückgeben
    ProcedureReturn iStatus
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetElementItemImage
  ;
  ; Beschreibung ..: 	ändert das Bild des angegebenen Element-Eintrags
  ;
  ; Syntax.........:  SetElementItemImage (iCustomStatusBar_ID.i, iElement_ID.i, iItem.i, iImage_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iItem.i					- der zu entfernende Eintrag. Der erste Eintrag hat den Index 0.
  ;					iImage_ID.i					- das neue Bild, welches für den Element-Eintrag verwendet werden soll. Verwenden Sie den ImageID() Befehl, um die ID für diesen Parameter zu ermitteln. 
  ;
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;												| -6: der angegebene Eintrag wurde nicht gefunden
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit SetGadgetItemImage(). 
  ;				
  ;} ========
  Procedure.i SetElementItemImage (iCustomStatusBar_ID.i, iElement_ID.i, iItem.i, iImage_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iItem_Anzahl.i	= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item())
    Protected sElement_Typ.s		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iCounter.i		= 0
    Protected iStatus.i			= 0
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ComboBoxElement"
        
        For iCounter = 0 To iItem_Anzahl Step 1
          
          ; speichert das neue Image des Items
          If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt = #True)
            
            If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iPosition = iItem)
              
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iImage_ID	= iImage_ID
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag				= #True	
              iStatus = 0
              Break 
              
            EndIf
            
          Else
            ; setzt ein Fehlerwert, wenn die Position nicht gefunden wurde
            iStatus = -6
          EndIf
          
        Next
        
    EndSelect
    
    
    ; die Position des geänderten Items zurückgeben
    ProcedureReturn iStatus
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetElementItemText
  ;
  ; Beschreibung ..: 	ändert den Text des angegebenen Element-Eintrags
  ;
  ; Syntax.........:  SetElementItemText (iCustomStatusBar_ID.i, iElement_ID.i, iItem.i, sText.s)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iItem.i					- der zu entfernende Eintrag. Der erste Eintrag hat den Index 0.
  ;					sText.s						- der zu setzende neue Text
  ;
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;												| -6: der angegebene Eintrag wurde nicht gefunden
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit SetGadgetItemText(). 
  ;				
  ;} ========
  Procedure.i SetElementItemText (iCustomStatusBar_ID.i, iElement_ID.i, iItem.i, sText.s)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iItem_Anzahl.i	= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item())		
    Protected sElement_Typ.s		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iCounter.i		= 0
    Protected iStatus.i			= 0
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ComboBoxElement"
        
        For iCounter = 0 To iItem_Anzahl Step 1
          
          
          ; speichert den neuen Textinhalt des Items
          If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt = #True)
            
            If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iPosition = iItem)
              
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_sText	= sText
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag			= #True	
              iStatus = 0
              Break 
              
            EndIf
            
          Else
            ; setzt ein Fehlerwert, wenn die Position nicht gefunden wurde
            iStatus = -6
          EndIf
          
        Next
        
    EndSelect
    
    
    ; die Position des geänderten Items zurückgeben
    ProcedureReturn iStatus
    
  EndProcedure
  
  
  
  ;-
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	ClearElementItems
  ;
  ; Beschreibung ..: 	entfernt alle Items eines Elements
  ;
  ; Syntax.........:  ClearElementItems (iCustomStatusBar_ID.i, iElement_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	
  ;				
  ;} ========
  Procedure.i ClearElementItems (iCustomStatusBar_ID.i, iElement_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iItem_Anzahl.i	= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item())		
    Protected sElement_Typ.s		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iCounter.i		= 0
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ComboBoxElement"
        
        
        ; alle Items löschen
        For iCounter = 0 To iItem_Anzahl Step 1
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt 		= #False
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iImage_ID 	= 0
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iPosition 	= 0
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iValue 		= 0
          CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_sText 		= ""
        Next
        
        CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag					= #True
        
    EndSelect
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	RemoveElementItem
  ;
  ; Beschreibung ..: 	entfernt ein Item eines Elements
  ;
  ; Syntax.........:  RemoveElementItem (iCustomStatusBar_ID.i, iElement_ID.i, iPosition.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iPosition.i					- der zu entfernende Eintrag. Der erste Eintrag hat den Index 0. 
  ;
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Die Parameter sind voll kompatibel mit RemoveGadgetItem(). 
  ;					Hinweis: Nach dem Löschen eines Items werden die Einträge neu nummeriert, um Lücken in der Itemliste zu vermeiden.
  ;					Wird also aus einer Itemliste (0, 1, 2, 3, 4, 5) das Item 3 gelöscht, so rücken die Items 4 und 5 nach links auf und werden neu nummeriert: (0, 1, 2, , 4, 5) -> (0, 1, 2, 3, 4)
  ;				
  ;} ========
  Procedure.i RemoveElementItem (iCustomStatusBar_ID.i, iElement_ID.i, iPosition.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iItem_Anzahl.i		= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item())		
    Protected sElement_Typ.s			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
    Protected iPosition_Offset.i	= OffsetOf(Element_ComboBoxGadget_Item\_iPosition)
    Protected iPosition_Typ.i		= TypeOf(Element_ComboBoxGadget_Item\_iPosition)
    Protected iItem_Nummer.i 		= 0
    Protected iCounter.i			= 0
    
    
    ; Gadget-Typ selektieren
    Select sElement_Typ
        
        
      Case "ComboBoxElement"
        
        ; das Item suchen und entfernen
        For iCounter = 0 To iItem_Anzahl Step 1
          
          If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt = #True)
            
            If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iPosition = iPosition)
              
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag				= #True
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt 		= #False
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iImage_ID 	= 0
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iPosition 	= 0
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iValue 		= 0
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_sText 		= ""						
              Break
              
            EndIf
            
          EndIf
          
        Next
        
        
        ; Item-Positionen sortieren
        SortStructuredArray(CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(), #PB_Sort_Ascending, iPosition_Offset, iPosition_Typ)
        
        
        ; das Item-Array neu nummerieren
        For iCounter = 0 To iItem_Anzahl Step 1
          
          If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iBelegt 		= #True
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\Item(iCounter)\_iPosition	= iItem_Nummer
            iItem_Nummer + 1
          EndIf
          
        Next
        
    EndSelect
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;-
  ;-
  ;-
  ;- Fielder der Informationsleiste
  ;- -------------------------------------------------------------
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetField
  ;
  ; Beschreibung ..: 	weist einem Field in der CustomStatusBar ein Element zu, erstellt neue Fielder oder entfernt diese
  ;
  ; Syntax.........:  SetField (iCustomStatusBar_ID.i, iField.i, iElement_ID.i = #PB_Default)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iField.i						- die Fieldnummer in der CustomStatusBar (beginnend bei 1)
  ;												|   0: neues Field hinzufügen (der iElement_ID-Parameter wird ignoriert)
  ;												| >=1: Fieldnummer, auf die sich bezogen wird
  ;
  ;					iElement_ID.i				- die ID des Elements
  ;												; #PB_Default: löscht das angegebene Field aus der CustomStatusBar
  ;												; <=0: löscht das angegebene Field aus der CustomStatusBar
  ;												; >=1: weist dem angegebenen Field das Element zu (Field wird erstellt, wenn es nicht existiert)
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: die Fieldnummer, die angepasst, erstellt oder gelöscht wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig
  ;												| -4: die Fieldnummer ist ungültig (Fieldnummer ist <0)
  ;												| -5: die Fieldnummer ist ungültig (Fieldnummer ist größer als die Gesamtzahl der existierenden Fielder)
  ;												| -6: das Element ist als "nicht Belegt" markiert
  ;												| -7: das Field kann nicht erstellt werden, da die maximale Anzahl an Fieldern erreicht wurde
  ;												| -8: die Parameter sind ungültig
  ;
  ; Bemerkungen ...:	Werden Fielder aus der CustomStatusBar entfernt, so bleiben die Elemente weiterhin vorhanden und können wieder einem Field zugewiesen werden.
  ; 					Hinweis: Die Fieldnummern werden immer neu nummeriert, wenn über das Kontextmenü eine Änderung in der CustomStatusBar durchgeführt wird.
  ;
  ;					Beispiele für eine Parametrierung:	iField = 0		iElement = 0		-> erstellt ein neues Field
  ;														iField = 0		iElement = 123		-> erstellt ein neues Field (iElement wird ignoriert)
  ;														iField = 3		iElement = 0		-> löscht das angegebene Field
  ;														iField = 6		iElement = 20		-> weist Field 6 das Element mit der ID 20 zu
  ;
  ;} ========	
  Procedure.i SetField (iCustomStatusBar_ID.i, iField.i, iElement_ID.i = #PB_Default)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -3:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If iField < 0:																			ProcedureReturn -4:		EndIf                                     ; Abbrechen, wenn die Fieldangabe ungültig ist
    If iField > CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMax_Elements_visible:					ProcedureReturn -5:		EndIf       ; Abbrechen, wenn die Fieldangabe ungültig ist		
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iMax_Anzahl_Fielder.i		= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMax_Elements_visible
    Protected iCounter.i				= 0
    
    
    ; Element <= 0 und Field >= 1	--> Field löschen
    If ((iElement_ID = #PB_Default) Or (iElement_ID <= 0)) And (iField >= 1)
      
      ; Einstellungen speichern
      CustomStatusBar(iCustomStatusBar_ID)\Field(iField)\_iBelegt 			= #False
      
      
      
      ; Element >= 1 und Field >=1		--> das Field einem Element zuweisen
    ElseIf (iElement_ID >= 1) And (iField >= 1)
      
      ; Prozedur bei einem Fehler abbrechen
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:				ProcedureReturn -6:		EndIf	; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
      
      
      ; Einstellungen speichern
      CustomStatusBar(iCustomStatusBar_ID)\Field(iField)\_iBelegt 			= #True
      CustomStatusBar(iCustomStatusBar_ID)\Field(iField)\_iElement_ID 		= iElement_ID
      
      
      
      ; Field = 0		-->	   ; ein neues Field in der CustomStatusBar hinzufügen
    ElseIf (iField = 0)	
      
      
      ; prüfen, ob noch freie Plätze verfügbar sind
      For iCounter = 1 To iMax_Anzahl_Fielder Step 1
        
        If CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #False
          
          ; Prozedur bei einem Fehler abbrechen
          If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:		ProcedureReturn -6:		EndIf	; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
          
          
          ; der Field ein neues Element zuweisen
          CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt 			= #True
          CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iElement_ID 		= iElement_ID
          iField = iCounter
          Break
          
          
        Else
          iField = -7 ; kein freier Platz verfügbar
          
        EndIf
        
      Next
      
    Else
      iField = -8 ; die angegebenen Parameter sind ungültig
      
    EndIf
    
    
    ; die CustomStatusBar aktualisieren
    _erneuere_CustomStatusBar (iCustomStatusBar_ID.i)
    
    
    ; die Field-Nummer zurückgeben
    ProcedureReturn iField
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	RemoveField
  ;
  ; Beschreibung ..: 	entfernt das angegebene Field aus der CustomStatusBar
  ;
  ; Syntax.........:  RemoveField (iCustomStatusBar_ID.i, iField.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iField.i						- die Nummer des Fieldes, das entfernt werden soll
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Fieldnummer ist ungültig (Fieldnummer ist <0)
  ;												| -4: die Fieldnummer ist ungültig (Fieldnummer ist größer als die Gesamtzahl der existierenden Fielder)
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i RemoveField (iCustomStatusBar_ID.i, iField.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iField < 0:																			ProcedureReturn -3:		EndIf                                     ; Abbrechen, wenn die Fieldangabe ungültig ist
    If iField > CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMax_Elements_visible:					ProcedureReturn -4:		EndIf       ; Abbrechen, wenn die Fieldangabe ungültig ist		
    
    
    ; angegebenes Field aus der CustomStatusBar entfernen
    SetField (iCustomStatusBar_ID, iField, -1)
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;-
  ;-
  ;-
  ;- Kontextmenü der Informationsleiste
  ;- -------------------------------------------------------------
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetContextMenuOptions
  ;
  ; Beschreibung ..: 	ändert allgemeine Einstellungen des Kontextmenüs einer CustomStatusBar
  ;
  ; Syntax.........:  SetContextMenuOptions (iCustomStatusBar_ID.i, iContextMenu_activ.i = #True, iHeadline.i = #True, sEntry_add.s = "Eintrag hinzufügen", sEntry_remove.s = "diesen Eintrag entfernen", iEntry_add_Image.i = #PB_Default, iEntry_remove_Image.i = #PB_Default)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 				- die ID der CustomStatusBar
  ;					iContextMenu_activ.i		- Bool: aktiviert bei #True das Kontextmenü der CustomStatusBar und erlaubt somit das einfache Ändern der Fieldinhalte
  ;					iHeadline.i					- Bool: zeigt bei #True eine Überschrift im Kontextmenü an, die den Namen des Elements im Field der CustomStatusBar trägt
  ;					sEntry_add.s			- der anzuzeigende Text im Kontextmenü, zum Hinzufügen neuer Fielder (oder "" um diesen Kontextmenü-Eintrag auszublenden)
  ;					sEntry_remove.s			- der anzuzeigende Text im Kontextmenü, zum Entfernen von Fieldern (oder "" um diesen Kontextmenü-Eintrag auszublenden)
  ;					iEntry_add_Image.i	- das #Image, das bei Menüeintrag "Eintrag hinzufügen" angezeigt werden soll (oder 0, um kein Bild zu verwenden)
  ;					iEntry_remove_Image.i		- das #Image, das bei Menüeintrag "diesen Eintrag entfernen" angezeigt werden soll (oder 0, um kein Bild zu verwenden)
  ;
  ; Rückgabewerte .: 	Erfolg 							|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 							| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;													| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i SetContextMenuOptions (iCustomStatusBar_ID.i, iContextMenu_activ.i = #True, iHeadline.i = #True, sEntry_add.s = "Add entry", sEntry_remove.s = "Remove entry", iEntry_add_Image.i = #PB_Default, iEntry_remove_Image.i = #PB_Default)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; Parameter überprüfen (Image: Element hinzufügen)
    If iEntry_add_Image = #PB_Default
      iEntry_add_Image = standard_Einstellungen\Kontextmenue\_iItem_Field_erstellen_Symbol
    EndIf
    
    
    ; Parameter überprüfen (Image: Element entfernen)
    If iEntry_remove_Image = #PB_Default
      iEntry_remove_Image = standard_Einstellungen\Kontextmenue\_iItem_Field_entfernen_Symbol
    EndIf		
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iKontextmenue_Aktiviert 			= iContextMenu_activ
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iHeadline_anzeigen 			= iHeadline
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_sEintrag_Fielder_erstellen_Text 	= sEntry_add
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_sEintrag_Fielder_entfernen_Text 	= sEntry_remove
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iItem_Field_erstellen_Symbol 	= iEntry_add_Image
    CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iItem_Field_entfernen_Symbol 	= iEntry_remove_Image
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetContextMenuItem 
  ;
  ; Beschreibung ..: 	fügt einem Element ein Kontextmenü-Eintrag hinzu
  ;
  ; Syntax.........:  SetContextMenuItem (iCustomStatusBar_ID.i, iElement_ID.i, sMenu_Item.s, sMainCategory.s = "", sSubCategory.s = "", iIcon.i = #PB_Ignore)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					sMenu_Item.s			- der Menüeintrag der angezeigt werden soll (oder "" um den aktuellen Eintrag zu entfernen)
  ;					sMainCategory.s			- die Hauptkategorie, in der dieser Eintrag angezeigt wird (oder "" um keine Kategorie zu verwenden)
  ;					sSubCategory.s			- die Nebenkategorie, in der dieser Eintrag angezeigt wird (oder "" um keine Kategorie zu verwenden)
  ;					iIcon.i					- das Symbol (#Image) das angezeigt werden soll (oder #PB_Ignore um kein Symbol zu verwenden)
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die Element-ID zurück, auf dem die Änderungen durchgeführt wurden
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	alternativ kann auch SetBallonTip() verwendet werden
  ;
  ;} ========
  Procedure.i SetContextMenuItem (iCustomStatusBar_ID.i, iElement_ID.i, sMenu_Item.s, sMainCategory.s = "", sSubCategory.s = "", iIcon.i = #PB_Ignore)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; lokale Variablen deklarieren und initialisieren	
    Protected iElement_Array_groesse.i					= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iKontextmenu_ID_Start.i					= CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iMenueItem_Start
    Protected iKontextmenu_ID_Reserviert.i				= CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iMenueItem_Reserviert
    Protected iKontextmenu_ID_Reserviert_erweitert.i	= CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iMenueItem_Reserviert_erweitert
    Protected iKontextmenu_ID.i							= 0		
    
    
    ; die Kontextmenü-ID berechnen
    iKontextmenu_ID = iKontextmenu_ID_Start + iElement_ID + ((iKontextmenu_ID_Reserviert_erweitert + iKontextmenu_ID_Reserviert) * iCustomStatusBar_ID)
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_iKontext_Menue_ID					= iKontextmenu_ID
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_sKontext_Menue_Eintrag			= sMenu_Item
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_iKontext_Menue_Eintrag_Symbol		= iIcon
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_sKontext_Menue_Hauptkategorie		= sMainCategory
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_sKontext_Menue_Nebenkategorie		= sSubCategory
    
    
    ; gibt die Element ID zurück
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	RemoveContextMenuItem
  ;
  ; Beschreibung ..: 	entfernt den Kontextmenü-Eintrag eines Elements
  ;
  ; Syntax.........:  RemoveContextMenuItem (iCustomStatusBar_ID.i, iElement_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;
  ; Rückgabewerte .: 	Erfolg 						| >0: gibt die Element-ID zurück, auf dem die Änderungen durchgeführt wurden
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	alternativ kann auch SetContextMenuItem() verwendet werden
  ;
  ;} ========
  Procedure.i RemoveContextMenuItem (iCustomStatusBar_ID.i, iElement_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_iKontext_Menue_ID					= 0
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_sKontext_Menue_Eintrag			= ""
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_iKontext_Menue_Eintrag_Symbol		= 0
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_sKontext_Menue_Hauptkategorie		= ""
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_sKontext_Menue_Nebenkategorie		= ""
    
    
    ; gibt die Element ID zurück
    ProcedureReturn iElement_ID
    
  EndProcedure
  
  
  
  ;-
  ;-
  ;-
  ;- Tooltip der Informationsleiste
  ;- -----------------------------------------------------------------------------
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetToolTipOptions
  ;
  ; Beschreibung ..: 	ändert allgemeine Einstellungen der Tooltips
  ;
  ; Syntax.........:  SetToolTipOptions (iCustomStatusBar_ID.i, iTollTip_activ.i = #True, iRefreshRate.i = #PB_Default, iToolTip_Delay.i = #PB_Default)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iTollTip_activ.i		- Bool: ermöglicht bei #True die allgemeine Darstellung von Tooltips
  ;					iRefreshRate.i		- Aktualisierungsintervall der dargestellten Tooltips und Ballon-Tipps (in Millisekunden). #PB_Default kann verwendet werden, um den Standardwert zu verwenden.
  ;					iToolTip_Delay.i		- Zeit die der Mauszeiger über ein Field in der CustomStatusBar verbleiben muss, um ein Tooltip anzuzeigen (in Millisekunden). #PB_Default kann verwendet werden, um den Standardwert zu verwenden.
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i SetToolTipOptions (iCustomStatusBar_ID.i, iTollTip_activ.i = #True, iRefreshRate.i = #PB_Default, iToolTip_Delay.i = #PB_Default)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; Parameter überprüfen (Aktualisierungsrate)
    If iRefreshRate = #PB_Default
      iRefreshRate = standard_Einstellungen\Tooltips\_iTooltip_Timer_Intervall
    ElseIf iRefreshRate <= 0
      iRefreshRate  = 1
    EndIf
    
    
    ; Parameter überprüfen (Tooltip Verzögerung)
    If iToolTip_Delay = #PB_Default
      iToolTip_Delay = standard_Einstellungen\Tooltips\_iToolTip_Delay
    ElseIf iToolTip_Delay <= 0
      iToolTip_Delay  = 0
    EndIf
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Timer_Intervall 	= iRefreshRate
    CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Aktiviert 		= iTollTip_activ
    CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iToolTip_Delay 		= iToolTip_Delay
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetToolTip
  ;
  ; Beschreibung ..: 	fügt einem Element ein Tooltip hinzu, ändert dieses oder entfernt es
  ;
  ; Syntax.........:  SetToolTip (iCustomStatusBar_ID.i, iElement_ID.i, sText.s, sTitle.s = "", sIcon.s = "none")
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					sText.s						- der anzuzeigende Text oder "", um das Tooltip zu entfernen 
  ;					sTitle.s					- der anzuzeigende Titel oder "", wenn kein Titel angezeigt werden soll
  ;					sIcon.s					- zur Darstellung eines Symbols
  ;												| "":		 zeigt kein Symbol an
  ;												| "none":	 zeigt kein Symbol an
  ;												| "Info":	 zeigt ein InformationsIcon an
  ;												| "Warning": zeigt ein WarnungsIcon an 
  ;												| "Error":	 zeigt ein Fehlersymbol an
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Tooltips werden angezeigt, wenn sich das jeweilige Element in einem Field der CustomStatusBar befindet, die Maus über diesem Field ist und Tooltips global aktiviert wurden (SetToolTipOptions()).
  ;
  ;} ========
  Procedure.i SetToolTip (iCustomStatusBar_ID.i, iElement_ID.i, sText.s, sTitle.s = "", sIcon.s = "none")
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Tooltip\_sText		= sText
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Tooltip\_sTitle		= sTitle
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Tooltip\_sIcon	= sIcon
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	RemoveToolTip
  ;
  ; Beschreibung ..: 	entfernt das Tooltip eines Elements
  ;
  ; Syntax.........:  RemoveToolTip (iCustomStatusBar_ID.i, iElement_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	alternativ kann auch SetToolTip() verwendet werden
  ;
  ;} ========
  Procedure.i RemoveToolTip (iCustomStatusBar_ID.i, iElement_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Tooltip\_sText		= ""
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Tooltip\_sTitle		= ""
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Tooltip\_sIcon	= ""
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;-
  ;-
  ;-
  ;- Ballon-Tipps der Informationsleiste
  ;- -----------------------------------------------------------------------------
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	SetBallonTip
  ;
  ; Beschreibung ..: 	fügt einem Element ein Ballon-Tipp hinzu, ändert dieses oder entfernt es
  ;
  ; Syntax.........:  SetBallonTip (iCustomStatusBar_ID.i, iElement_ID.i, sText.s, sTitle.s = "", sIcon.s = "none", iDisplayTime.i = #PB_Default, iClose_Button.i = #True)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					sText.s						- der anzuzeigende Text oder "", um das Ballon-Tipp zu entfernen 
  ;					sTitle.s					- der anzuzeigende Titel oder "", wenn kein Titel angezeigt werden soll
  ;					sIcon.s					- zur Darstellung eines Symbols
  ;												| "":		 zeigt kein Symbol an
  ;												| "none":	 zeigt kein Symbol an
  ;												| "Info":	 zeigt ein InformationsIcon an
  ;												| "Warning": zeigt ein WarnungsIcon an 
  ;												| "Error":	 zeigt ein Fehlersymbol an
  ;
  ;					iDisplayTime.i				- die maximale Anzeigedauer eines Ballon-Tipps (in Millisekunden). #PB_Default kann verwendet werden, um den Standardwert zu verwenden.
  ;					iClose_Button.i				- fügt bei #True dem Ballon-Tipp ein Schließen-Button hinzu, um dieses vor Ablauf der Anzeigedauer auszublenden
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i SetBallonTip (iCustomStatusBar_ID.i, iElement_ID.i, sText.s, sTitle.s = "", sIcon.s = "none", iDisplayTime.i = #PB_Default, iClose_Button.i = #True)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; Parameter überprüfen (Anzeigedauer)
    If (iDisplayTime = #PB_Default) Or (iDisplayTime <= 0)
      iDisplayTime = CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_Anzeigedauer
    EndIf
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_sText				= sText
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_sTitle				= sTitle
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_sIcon			= sIcon
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_iDisplayTime		= iDisplayTime
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_iClose_Button		= iClose_Button
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	ShowBallonTip
  ;
  ; Beschreibung ..: 	zeigt ein Ballon-Tipp in der CustomStatusBar an
  ;
  ; Syntax.........:  ShowBallonTip (iCustomStatusBar_ID.i, iElement_ID.i, iReset.i = #True)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iReset.i					- resettet bei #True die Ballon-Tipp anzeige (nötig, wenn vor Ablauf der Anzeigedauer das Ballon-Tipp geschlossen wurde)
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;												| -6: die CustomStatusBar ist versteckt
  ;
  ; Bemerkungen ...:	Damit ein Ballon-Tipp angezeigt werden kann, muss dieses zuvor mit SetBallonTip() erstellt wurden sein. Des Weiteren mus sich dieses Element in einem Field der CustomStatusBar befinden.
  ;
  ;} ========
  Procedure.i ShowBallonTip (iCustomStatusBar_ID.i, iElement_ID.i, iReset.i = #True)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iVersteckt = #True: 							ProcedureReturn -6:		EndIf             ; Abbrechen, wenn die CustomStatusBar ausgeblendet ist
    
    
    ; lokale Variablen deklarieren und initialisieren	
    Protected iField.i				= _gebe_Field_des_Elements(iCustomStatusBar_ID, iElement_ID)
    
    Protected iField_X_Pos.i			= CustomStatusBar(iCustomStatusBar_ID)\Field(iField)\_iX_Pos
    Protected iField_Y_Pos.i			= CustomStatusBar(iCustomStatusBar_ID)\Field(iField)\_iY_Pos
    Protected iField_Breite.i		= CustomStatusBar(iCustomStatusBar_ID)\Field(iField)\_iWidth
    Protected iField_Hoehe.i			= CustomStatusBar(iCustomStatusBar_ID)\Field(iField)\_iHeight
    
    Protected iCustomStatusBar_X_Pos.i	= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iX_Pos
    Protected iCustomStatusBar_Y_Pos.i	= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iY_Pos
    
    Protected iFenster_X_Pos.i		= WindowX (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow, #PB_Window_InnerCoordinate)
    Protected iFenster_Y_Pos.i		= WindowY (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow, #PB_Window_InnerCoordinate)
    
    Protected sText.s				= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_sText
    Protected sTitle.s				= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_sTitle
    Protected Symbol.s				= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_sIcon
    Protected iDisplayTime.i		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_iDisplayTime
    Protected iClose_Button.i		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_iClose_Button
    
    Protected iX_Pos.i				= 0
    Protected iY_Pos.i				= 0
    
    
    ; das Field in der CustomStatusBar bestimmen
    If iField > 0
      
      ; die Position berechnen (Fieldmitte)
      iX_Pos	= iFenster_X_Pos + iCustomStatusBar_X_Pos + iField_X_Pos + (iField_Breite / 2)
      iY_Pos	= iFenster_Y_Pos + iCustomStatusBar_Y_Pos + iField_Y_Pos + (iField_Hoehe / 2)
      
      
      ; Fieldposition speichern
      CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_auf_Field = iField
      
      
      ; Ballon-Tipp schließen, falls dieser über den schließen-Button ausgeblendet wurde (ermöglicht ein neues Ballon-Tipp vor Ablauf der Anzeigedauer)
      If iReset = #True
        _Tooltip(iCustomStatusBar_ID, "", "", "", 0, 0, 0, #True)
      EndIf
      
      _Tooltip (iCustomStatusBar_ID, sText, sTitle, Symbol, iX_Pos, iY_Pos, #PB_Default, #True, iClose_Button)
      
    EndIf
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	HideBallonTip
  ;
  ; Beschreibung ..: 	blendet ein aktuell angezeigtes Ballon-Tipp aus
  ;
  ; Syntax.........:  HideBallonTip (iCustomStatusBar_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i HideBallonTip (iCustomStatusBar_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; Ballon-Tipp ausblenden, sofern gerade einer angezeigt wird
    _Tooltip (iCustomStatusBar_ID, "", "", "none", #PB_Default, #PB_Default, #PB_Default, #True, #True)
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	RemoveBallonTip
  ;
  ; Beschreibung ..: 	entfernt das Ballon-Tipp eines Elements
  ;
  ; Syntax.........:  RemoveBallonTip (iCustomStatusBar_ID.i, iElement_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;
  ; Rückgabewerte .: 	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	alternativ kann auch SetBallonTip() verwendet werden
  ;
  ;} ========
  Procedure.i RemoveBallonTip (iCustomStatusBar_ID.i, iElement_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_sText				= ""
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_sTitle				= ""
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_sIcon			= ""
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_iClose_Button		= 0
    CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_iDisplayTime		= 0
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;  ############################################################################################################################################################################################
  ;  #####################################################################################     PRIVATE     ######################################################################################
  ;  ############################################################################################################################################################################################
  ;-
  ;-
  ;-
  ;- ################### PRIVATE ########################
  ;-
  ;- überprüfen der Mausparameter
  ;- -----------------------------------------------------------------------------
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_pruefe_Mausaktion
  ;
  ; Beschreibung ..:  gibt die Fieldnummer zurück, über der sich die Maus befindet
  ;
  ; Syntax.........:  _pruefe_Mausaktion ()
  ;
  ; Parameter .....: 	
  ;												
  ; Rückgabewerte .:	Erfolg 						| "links":	die linke Maustaste wird gerade gedrückt
  ;												| "rechts":	die rechts Maustaste wird gerade gedrückt
  ;												| "mitte":	die mittlere Maustaste wird gerade gedrückt
  ;												| "":		nicht definiert
  ;
  ;                  	Fehler 
  ;
  ; Bemerkungen ...:	Rückgabewert ist ein String
  ;
  ;} ========	
  Procedure.s _pruefe_Mausaktion ()
    
    ; den Status der Maustasten abfragen und zurückgeben
    If GetAsyncKeyState_(#VK_LBUTTON) <> 0
      ProcedureReturn "links"
      
    ElseIf GetAsyncKeyState_(#VK_RBUTTON) <> 0
      ProcedureReturn "rechts"
      
    ElseIf GetAsyncKeyState_(#VK_MBUTTON) <> 0
      ProcedureReturn "mitte"
      
    Else
      ProcedureReturn ""
      
    EndIf
    
  EndProcedure
  
  
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_pruefe_Mausposition
  ;
  ; Beschreibung ..:  gibt die Fieldnummer zurück, über der sich die Maus befindet
  ;
  ; Syntax.........:  _pruefe_Mausposition (iCustomStatusBar_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;												
  ; Rückgabewerte .:	Erfolg 						|  0: die Maus befindet sich in der CustomStatusBar, aber an dieser Position existiert kein Field
  ;												| >0: die Fieldnummer, über der sich die Maus befindet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die CustomStatusBar ist ausgeblendet
  ;												| -4: die X-Koordinate der Maus befindet sich außerhalb der GUI
  ;												| -5: die Y-Koordinate der Maus befindet sich außerhalb der GUI
  ;												| -6: die Maus befindet sich nicht in der CustomStatusBar
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i _pruefe_Mausposition (iCustomStatusBar_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iVersteckt = #True: 							ProcedureReturn -3:		EndIf             ; Abbrechen, wenn die CustomStatusBar ausgeblendet wurde
    
    
    ; lokale Variablen deklarieren und initialisieren			
    Protected iMaus_Pos_X.i				= WindowMouseX(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow)
    Protected iMaus_Pos_Y.i				= WindowMouseY(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow)
    Protected iMax_Anzahl_Fielder.i		= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Field())
    
    Protected iCustomStatusBar_X_Pos.i		= GadgetX(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich, #PB_Gadget_WindowCoordinate)
    Protected iCustomStatusBar_Y_Pos.i		= GadgetY(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich, #PB_Gadget_WindowCoordinate)
    Protected iCustomStatusBar_Breite.i		= GadgetWidth(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich)
    Protected iCustomStatusBar_Hoehe.i		= GadgetHeight(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich)
    
    Protected iField.i					= 0
    Protected iCounter.i				= 0
    
    Protected iElement_X_Start.i		= 0
    Protected iElement_X_Ende.i			= 0
    Protected iElement_Y_Start.i		= 0
    Protected iElement_Y_Ende.i			= 0
    
    Protected iX_Start.i				= 0
    Protected iX_Ende.i					= 0
    Protected iY_Start.i				= 0
    Protected iY_Ende.i					= 0
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iMaus_Pos_X < 0:		ProcedureReturn -4:		EndIf	; Abbrechen, wenn sich die Maus nicht im Programmfenster befindet
    If iMaus_Pos_Y < 0:		ProcedureReturn -5:		EndIf ; Abbrechen, wenn sich die Maus nicht im Programmfenster befindet
    
    
    ; Prüfen, auf welchem Field in der CustomStatusBar geklickt wurde
    For iCounter = 1 To iMax_Anzahl_Fielder Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True
        
        iElement_X_Start	= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iX_Pos
        iElement_X_Ende		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iX_Pos + CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iWidth
        iElement_Y_Start	= 0
        iElement_Y_Ende		= iCustomStatusBar_Hoehe
        
        iX_Start			= iCustomStatusBar_X_Pos + iElement_X_Start
        iX_Ende				= iCustomStatusBar_X_Pos + iElement_X_Ende
        iY_Start			= iCustomStatusBar_Y_Pos + iElement_Y_Start
        iY_Ende				= iCustomStatusBar_Y_Pos + iElement_Y_Ende
        
        If (iMaus_Pos_X >= iX_Start) And (iMaus_Pos_X <= iX_Ende) And (iMaus_Pos_Y >= iY_Start) And (iMaus_Pos_Y <= iY_Ende) And (iMaus_Pos_X <= (iCustomStatusBar_X_Pos + iCustomStatusBar_Breite))
          iField = iCounter	
          Break
        Else
          iField = 0
        EndIf
        
      EndIf
      
    Next
    
    
    ; Prüfen, ob sich die Maus innerhalb der CustomStatusBar befindet (wenn sie sich auf keinem gültigen Field befindet)
    If iField = 0
      
      With CustomStatusBar(iCustomStatusBar_ID)\Allgemein
        iX_Start			= \_iX_Pos + \_iGadget_Bereich_Offset_Breite
        iX_Ende				= \_iX_Pos + \_iWidth - (\_iGadget_Bereich_Offset_Breite * 2)
        iY_Start			= \_iY_Pos + \_iGadget_Bereich_Offset_Hoehe
        iY_Ende				= \_iY_Pos + \_iHeight - (\_iGadget_Bereich_Offset_Hoehe * 2)
      EndWith
      
      If (iMaus_Pos_X >= iX_Start) And (iMaus_Pos_X <= iX_Ende) And (iMaus_Pos_Y >= iY_Start) And (iMaus_Pos_Y <= iY_Ende)
        iField = 0	
      Else
        iField = -6 ; Maus befindet sich nicht in der CustomStatusBar
      EndIf
      
    EndIf
    
    
    ; gibt die Nummer des Fieldes zurück, auf dem geklickt wurde oder Null, wenn an dieser Position noch kein Field existiert
    ProcedureReturn iField
    
  EndProcedure
  
  
  
  ;-
  ;-
  ;-
  ;- Größenanpassung der CustomStatusBar
  ;- -----------------------------------------------------------------------------
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_CustomStatusBar_groesse_automatisch_anpassen
  ;
  ; Beschreibung ..:  berechnet anhand der GUI-Abmessung und des gewählten Modus die neuen Maße der CustomStatusBar
  ;
  ; Syntax.........:  _CustomStatusBar_groesse_automatisch_anpassen (iCustomStatusBar_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;												
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i _CustomStatusBar_groesse_automatisch_anpassen (iCustomStatusBar_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren			
    Protected iMode.i						= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iAutoresize_Modus
    
    Protected iX_Pos_alt.i					= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iX_Pos
    Protected iY_Pos_alt.i					= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iY_Pos
    Protected iWidth_alt.i					= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWidth
    Protected iHeight_alt.i					= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHeight
    Protected iFenster_Breite_alt			= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iFenster_Breite
    Protected iFenster_Hoehe_alt			= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iFenster_Hoehe
    
    Protected iFenster_Breite.i				= WindowWidth	(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow, #PB_Window_InnerCoordinate)
    Protected iFenster_Hoehe.i				= WindowHeight	(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow, #PB_Window_InnerCoordinate)	
    
    Protected iDelta_Breite.i				= iFenster_Breite - iFenster_Breite_alt
    Protected iDelta_Hoehe.i				= iFenster_Hoehe - iFenster_Hoehe_alt		
    
    Protected iX_Pos.i						= 0
    Protected iY_Pos.i						= 0
    Protected iWidth.i						= 0
    Protected iHeight.i						= 0		
    
    
    ; Modus selektieren
    Select iMode
        
      Case 1 ; als Statusleiste
        iX_Pos	= iX_Pos_alt
        iY_Pos	= iY_Pos_alt + iDelta_Hoehe
        iWidth	= iWidth_alt + iDelta_Breite
        iHeight	= iHeight_alt
        
        
      Case 2 ; als Toolbar
        iX_Pos	= iX_Pos_alt
        iY_Pos	= iY_Pos_alt
        iWidth	= iWidth_alt + iDelta_Breite
        iHeight	= iHeight_alt
        
        
      Case 3 ; Position und Abmessungen nicht ändern
        iX_Pos	= iX_Pos_alt
        iY_Pos	= iY_Pos_alt
        iWidth	= iWidth_alt
        iHeight	= iHeight_alt
        
        
      Case 4 ; nur horizontal verschieben (Abmessungen nicht ändern)
        iX_Pos	= iX_Pos_alt + iDelta_Breite
        iY_Pos	= iY_Pos_alt
        iWidth	= iWidth_alt
        iHeight	= iHeight_alt
        
        
      Case 5 ; horizontal/vertikal verschieben (Abmessungen nicht ändern)
        iX_Pos	= iX_Pos_alt + iDelta_Breite
        iY_Pos	= iY_Pos_alt + iDelta_Hoehe
        iWidth	= iWidth_alt
        iHeight	= iHeight_alt
        
        
      Default ; nur vertikal verschieben und Breite anpassen
        iX_Pos	= iX_Pos_alt
        iY_Pos	= iY_Pos_alt + iDelta_Hoehe
        iWidth	= iWidth_alt + iDelta_Breite
        iHeight	= iHeight_alt
        
    EndSelect
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iFenster_Breite 	= iFenster_Breite
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iFenster_Hoehe 	= iFenster_Hoehe		
    
    
    ; die CustomStatusBar neu aufbauen
    _CustomStatusBar_groesse_anpassen (iCustomStatusBar_ID, iX_Pos, iY_Pos, iWidth, iHeight)
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_CustomStatusBar_groesse_anpassen
  ;
  ; Beschreibung ..:  ändert die Position und Abmessung der CustomStatusBar und passt die darauf enthaltenen Fielder an
  ;
  ; Syntax.........:  _CustomStatusBar_groesse_anpassen (iCustomStatusBar_ID.i, iX_Pos.i, iY_Pos.i, iWidth.i, iHeight.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iX_Pos.i					- neue X-Position der CustomStatusBar
  ;					iY_Pos.i					- neue Y-Position der CustomStatusBar
  ;					iWidth.i					- neue Breite der CustomStatusBar
  ;					iHeight.i					- neue Höhe der CustomStatusBar
  ;												
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i _CustomStatusBar_groesse_anpassen (iCustomStatusBar_ID.i, iX_Pos.i, iY_Pos.i, iWidth.i, iHeight.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren			
    Protected iGadget_Bereich_Offset_Breite.i	= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iGadget_Bereich_Offset_Breite
    Protected iGadget_Bereich_Offset_Hoehe.i	= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iGadget_Bereich_Offset_Hoehe		
    
    Protected iMax_Anzahl_Fielder.i				= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Field())	
    Protected iMin_Abstand_der_Elemente.i		= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
    
    Protected iWidth_SizeBox.i					= GadgetWidth(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_SizeBox)
    Protected iHeight_SizeBox.i					= GadgetHeight(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_SizeBox)
    
    Protected iSeparator_ID.i					= 0
    Protected iElement_ID.i						= 0		
    Protected iGadget_ID.i						= 0
    
    Protected iCounter.i						= 0
    Protected iY_Pos_Offset.i					= 0
    
    Protected iGadget.i							= 0
    Protected iImage.i							= 0
    
    
    ; die Parameter überprüfen und ggf. korrigieren
    If iWidth	< 0: iWidth	= 0:	EndIf
    If iHeight	< 0: iHeight		= 0:	EndIf
    
    ; die Größe der CustomStatusBar anpassen (Container)
    iGadget 	= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_CustomStatusBar
    ResizeGadget (iGadget, iX_Pos, iY_Pos, iWidth, iHeight)
    
    
    ; die Größe der CustomStatusBar anpassen (Gadget-Bereich)
    iGadget		= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich
    If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSizeBox_Aktiviert = #True
      ResizeGadget (iGadget, iGadget_Bereich_Offset_Breite, iGadget_Bereich_Offset_Hoehe, iWidth - (iGadget_Bereich_Offset_Breite * 2) - iWidth_SizeBox, iHeight - (iGadget_Bereich_Offset_Hoehe * 2))
    Else
      ResizeGadget (iGadget, iGadget_Bereich_Offset_Breite, iGadget_Bereich_Offset_Hoehe, iWidth - (iGadget_Bereich_Offset_Breite * 2), iHeight - (iGadget_Bereich_Offset_Hoehe * 2))
    EndIf
    
    
    ; die Größe der SizeBox anpassen
    iGadget		= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_SizeBox
    If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSizeBox_Aktiviert = #True
      ResizeGadget (iGadget, iWidth - iGadget_Bereich_Offset_Breite - iWidth_SizeBox, iHeight - iGadget_Bereich_Offset_Hoehe - iHeight_SizeBox, #PB_Ignore, #PB_Ignore)
    EndIf
    
    
    ; die Größe der CustomStatusBar anpassen (Rahmen)
    iGadget		= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Rahmen
    ResizeGadget (iGadget, 0, 0, iWidth, iHeight)
    
    
    ; Einstellungen speichern
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iX_Pos	= iX_Pos
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iY_Pos	= iY_Pos
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHeight	= iHeight
    CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWidth	= iWidth				
    
    
    ; die Positionen der Fielder neu berechnen
    _berechne_Element_Fielder (iCustomStatusBar_ID.i)
    
    
    ; Gadgets erstellen
    For iCounter = 1 To iMax_Anzahl_Fielder Step 1
      
      
      ; vorhandene Parameter auslesen
      iGadget_ID		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID
      iSeparator_ID	= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID
      iElement_ID		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iElement_ID
      
      
      ; Field überspringen, wenn es kein gültiges Gadget enthält
      If IsGadget(iGadget_ID) = 0
        Continue
      EndIf
      
      
      If CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True
        
        ; Field-Parameter laden und Position berechnen
        iX_Pos		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iX_Pos + (iMin_Abstand_der_Elemente / 2)
        iY_Pos		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iY_Pos
        iWidth		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iWidth - (iMin_Abstand_der_Elemente)
        iHeight		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight
        
        
        ; den Offset-Parameter des Gadgets laden
        Select CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
          Case "ButtonElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ButtonGadget)\_iY_Pos_Offset
          Case "ButtonImageElement":	iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ButtonImageGadget)\_iY_Pos_Offset	
          Case "CanvasElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#CanvasGadget)\_iY_Pos_Offset
          Case "CheckBoxElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#CheckBoxGadget)\_iY_Pos_Offset
          Case "ComboBoxElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ComboBoxGadget)\_iY_Pos_Offset
          Case "DateElement":			iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#DateGadget)\_iY_Pos_Offset
          Case "ExplorerComboElement":	iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ExplorerComboGadget)\_iY_Pos_Offset
          Case "HyperLinkElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#HyperLinkGadget)\_iY_Pos_Offset
          Case "IPAddressElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#IPAddressGadget)\_iY_Pos_Offset
          Case "ProgressBarElement":	iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ProgressBarGadget)\_iY_Pos_Offset
          Case "ScrollBarElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ScrollBarGadget)\_iY_Pos_Offset
          Case "ShortcutElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ShortcutGadget)\_iY_Pos_Offset
          Case "SpinElement":			iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#SpinGadget)\_iY_Pos_Offset
          Case "StringElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#StringGadget)\_iY_Pos_Offset
          Case "TextElement":			iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#TextGadget)\_iY_Pos_Offset
          Case "TrackBarElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#TrackBarGadget)\_iY_Pos_Offset
        EndSelect
        
        
        ; die Gadget-Position korrigieren
        iY_Pos = iY_Pos + iY_Pos_Offset
        iHeight = iHeight - (2 * iY_Pos_Offset)
        If iWidth	< 0: iWidth	= 0:	EndIf
        If iHeight	< 0: iHeight		= 0:	EndIf
        
        
        ; den aktuellen Gadget-Typ selektieren
        Select CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
            
            
          Case "ButtonElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iUpdate_Flag = #True					
            
            
          Case "ButtonImageElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iUpdate_Flag = #True					
            
            
          Case "CanvasElement"
            
            ; Element-Einstellungen laden
            iImage = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iImage
            
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iUpdate_Flag = #True					
            
            
          Case "CheckBoxElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iUpdate_Flag = #True					
            
            
          Case "ComboBoxElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag = #True					
            
            
          Case "DateElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iUpdate_Flag = #True				
            
            
          Case "ExplorerComboElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iUpdate_Flag = #True
            
            
          Case "HyperLinkElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iUpdate_Flag = #True			
            
            
          Case "IPAddressElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iUpdate_Flag	= #True
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_Update			= #True  ;nur bei diesem Gadget
            
            
          Case "ProgressBarElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iUpdate_Flag = #True					
            
            
          Case "ScrollBarElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iUpdate_Flag = #True					
            
            
          Case "ShortcutElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iUpdate_Flag = #True					
            
            
          Case "SpinElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iUpdate_Flag = #True				
            
            
          Case "StringElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iUpdate_Flag = #True					
            
            
          Case "TextElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iUpdate_Flag = #True					
            
            
          Case "TrackBarElement"
            
            ; die Gadget- und Separatorgröße anpassen
            ResizeGadget(iGadget_ID, iX_Pos, iY_Pos, iWidth, iHeight)
            ResizeGadget(iSeparator_ID, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1)
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iUpdate_Flag = #True					
            
        EndSelect			
        
      EndIf
      
    Next		
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;-
  ;-
  ;-
  ;- Verwaltung der Fielder
  ;- -----------------------------------------------------------------------------
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_berechne_Element_Fielder
  ;
  ; Beschreibung ..:  berechnet anhand der Abmessung der CustomStatusBar die Positionen und Abmessungen der einzelnen Fielder
  ;
  ; Syntax.........:  _berechne_Element_Fielder (iCustomStatusBar_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;												
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	die berechneten Werte werden direkt im Field-Array gespeichert
  ;
  ;} ========
  Procedure.i _berechne_Element_Fielder (iCustomStatusBar_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren	
    Protected iVerfuegbare_Breite.i		= GadgetWidth 	(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich)
    Protected iVerfuegbare_Hoehe.i		= GadgetHeight 	(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich)
    Protected iMax_Anzahl_Fielder.i		= ArraySize 	(CustomStatusBar(iCustomStatusBar_ID)\Field())
    
    Protected iCounter.i				= 0
    Protected iElement_ID.i				= 0	
    
    Protected iAnzupassende_Fielder.i	= 0
    Protected iX_Field_Aktuell.i			= 0
    
    Protected iAktuelle_Breite.i		= 0
    Protected iMin_Width.i				= 0
    Protected iMax_Width.i				= 0
    
    
    ; die aktuelle Breite aller verwendeten Fielder auf Null setzen
    For iCounter = 1 To iMax_Anzahl_Fielder Step 1
      If CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True
        CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iWidth = 0
      EndIf
    Next
    
    
    ; die Breite der Fielder berechnen
    Repeat
      
      iAnzupassende_Fielder = 0
      
      For iCounter = 1 To iMax_Anzahl_Fielder Step 1
        
        If CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True
          
          ; Parameter laden
          iElement_ID			= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iElement_ID
          iAktuelle_Breite	= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iWidth
          iMin_Width			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMin_Width
          iMax_Width			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iMax_Width
          
          
          ; jedes Field erhält seine Mindestbreite (immer!)
          If iAktuelle_Breite < iMin_Width
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iWidth = iMin_Width
            iVerfuegbare_Breite - iMin_Width
            iAnzupassende_Fielder + 1
            
            
            ; die Fielder werden bis zu ihrer Maximalbreite vergrößert, sofern "verfügbare Pixel" zur Verfügung stehen 
          ElseIf (iMax_Width <> #PB_Ignore) And (iAktuelle_Breite < iMax_Width) And (iVerfuegbare_Breite > 0)
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iWidth + 1
            iAnzupassende_Fielder + 1
            iVerfuegbare_Breite - 1
            
            
            ; Fielder ohne Breitenbeschränkung werden solange vergrößtert, bis keine "verfügbaren Pixel" zur Verfügung stehen 
          ElseIf (iMax_Width = #PB_Ignore) And (iVerfuegbare_Breite > 0)
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iWidth + 1
            iAnzupassende_Fielder + 1
            iVerfuegbare_Breite - 1					
            
            
            ; Schleife abbrechen, wenn keine "verfügbaren Pixel" mehr zur Verfügung stehen
          ElseIf iVerfuegbare_Breite <= 0
            Break
            
          EndIf
          
        EndIf
        
      Next
      
    Until (iVerfuegbare_Breite <= 0) Or (iAnzupassende_Fielder = 0)
    
    
    ; die restlichen Parameter bestimmen (X-Pos, Y-Pos, Höhe)
    iX_Field_Aktuell = 0
    
    For iCounter = 1 To iMax_Anzahl_Fielder Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True
        
        CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iX_Pos = iX_Field_Aktuell
        CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iY_Pos = 0
        CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight = iVerfuegbare_Hoehe
        
        iX_Field_Aktuell + CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iWidth
        
      EndIf
      
    Next
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PUBLIC# ;=======
  ;
  ; Name...........:	_Fielder_aktualisieren
  ;
  ; Beschreibung ..: 	aktualisiert alle Fielder in der CustomStatusBar und synchonisiert so die Gadgets mit den Element-Einstellungen
  ;
  ; Syntax.........:  _Fielder_aktualisieren (iCustomStatusBar_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;												
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	Prinzipiell werden nur die Fielder aktualisiert, bei denen das Update-Flag gesetzt wurde. Dieses Flag wird gesetzt, wenn eine Element-Einstellung geändert wurde
  ;					oder wenn der Benutzer ein Gadget in der CustomStatusBar verändert hat.
  ;				
  ;} ========
  Procedure.i _Fielder_aktualisieren (iCustomStatusBar_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren		
    Protected iMin_Abstand_der_Elemente.i	= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
    Protected iMax_Anzahl_Elemente.i 		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iMax_Anzahl_Fielder.i			= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Field())
    
    Protected iCounter.i					= 0
    Protected iSub_Counter.i				= 0		
    
    Protected iElement_ID.i					= 0
    Protected iGadget_ID.i 					= 0
    Protected sElement_Typ.s 				= ""		
    
    Protected iX_Pos.i						= 0
    Protected iY_Pos.i						= 0
    Protected iWidth.i						= 0
    Protected iHeight.i						= 0		
    
    Protected iSchriftart_ID.i				= 0
    Protected iElement_Image.i				= 0
    Protected iStatus.i						= 0
    
    Protected iIP_Field_1.i					= 0
    Protected iIP_Field_2.i					= 0
    Protected iIP_Field_3.i					= 0
    Protected iIP_Field_4.i					= 0
    
    
    ; die Gadgets in der CustomStatusBar Aktualisieren
    For iCounter = 1 To iMax_Anzahl_Fielder Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True
        
        ; neue Position berechnen und Element auswählen
        iX_Pos				= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iX_Pos + (iMin_Abstand_der_Elemente / 2)
        iY_Pos				= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iY_Pos
        iWidth				= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iWidth - (iMin_Abstand_der_Elemente)
        iHeight				= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight		
        
        iElement_ID			= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iElement_ID
        iGadget_ID			= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID
        sElement_Typ			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
        
        
        ; die Aktualisierung des aktuellen Fieldes überspringen, wenn das Element als freigegeben markiert wurde oder das Gadget nicht existiert
        If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False) Or (IsGadget(iGadget_ID) = 0)
          Continue
        EndIf
        
        
        ; Gadget-Typ selektieren
        Select sElement_Typ
            
            
          Case "ButtonElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iUpdate_Flag = #True
              
              ; Schriftart aktualisieren
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_Update = #True
                
                iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_ID
                
                If (iSchriftart_ID = #PB_Default) Or (IsFont(iSchriftart_ID) = 0)
                  SetGadgetFont(iGadget_ID, #PB_Default) 
                Else
                  SetGadgetFont(iGadget_ID, FontID(iSchriftart_ID)) 
                EndIf
                
              EndIf
              
              ; Element-Einstellungen übernehmen
              SetGadgetText (iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_sText)
              SetGadgetState(iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iStatus)
              
            EndIf
            
            
          Case "ButtonImageElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iUpdate_Flag = #True
              
              ; Element-Einstellungen übernehmen
              SetGadgetState		(iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iStatus)
              SetGadgetAttribute	(iGadget_ID, #PB_Button_Image,			CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iImage_ID_normal)
              SetGadgetAttribute	(iGadget_ID, #PB_Button_PressedImage,	CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iImage_ID_gedrueckt)
              
            EndIf
            
            
          Case "CanvasElement"
            
            iElement_Image	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iImage
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iUpdate_Flag = #True
              
              ; die Grafik neu in das CanvasGadget zeichnen
              If StartDrawing(CanvasOutput(iGadget_ID))
                
                ; den Zeichenbereich mit der Hintergrunfarbe füllen
                Box(0 ,0 , iWidth, iHeight, CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHintergrundfabe)
                
                ; das Bild einzeichnen (sofern dies existent ist)
                If IsImage(iElement_Image) <> 0
                  
                  If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iAutoanpassung = #True
                    DrawImage(ImageID(iElement_Image), 0,0, ImageWidth(iElement_Image), iHeight ) 
                  Else
                    DrawImage(ImageID(iElement_Image), ((iWidth)/2) - ((ImageWidth(iElement_Image))/2), ((iHeight)/2) - ((ImageHeight(iElement_Image))/2)) 
                  EndIf
                  
                EndIf
                
                StopDrawing()
                
              EndIf
              
            EndIf
            
            
          Case "CheckBoxElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iUpdate_Flag = #True
              
              ; Schriftart aktualisieren
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_Update = #True
                
                iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_ID
                
                If (iSchriftart_ID = #PB_Default) Or (IsFont(iSchriftart_ID) = 0)
                  SetGadgetFont(iGadget_ID, #PB_Default) 
                Else
                  SetGadgetFont(iGadget_ID, FontID(iSchriftart_ID)) 
                EndIf
                
              EndIf
              
              ; Element-Einstellungen übernehmen
              SetGadgetText (iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_sText)
              SetGadgetState(iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iStatus)
              
            EndIf
            
            
          Case "ComboBoxElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag = #True
              
              ; Schriftart aktualisieren
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_Update = #True
                
                iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_ID
                
                If (iSchriftart_ID = #PB_Default) Or (IsFont(iSchriftart_ID) = 0)
                  SetGadgetFont(iGadget_ID, #PB_Default) 
                Else
                  SetGadgetFont(iGadget_ID, FontID(iSchriftart_ID)) 
                EndIf
                
              EndIf
              
              
              ; verhindert, dass das aktuell editierte Field aktualisiert wird
              If (GetActiveGadget() <> iGadget_ID)	
                
                With CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget
                  
                  ; alle Items löschen
                  ClearGadgetItems(iGadget_ID)
                  
                  
                  ; neue Items suchen und hinzufügen
                  For iSub_Counter = 0 To ArraySize(\Item()) Step 1
                    
                    If \Item(iSub_Counter)\_iBelegt = #True
                      AddGadgetItem(iGadget_ID, \Item(iSub_Counter)\_iPosition, \Item(iSub_Counter)\_sText, \Item(iSub_Counter)\_iImage_ID)
                    EndIf
                    
                  Next
                  
                  
                  ; Element-Einstellungen übernehmen
                  If \_iUpdate_Status = #True
                    SetGadgetState (iGadget_ID, \_iStatus)
                    \_sText = GetGadgetText(iGadget_ID)
                    
                  ElseIf \_iUpdate_Text = #True
                    SetGadgetText (iGadget_ID, \_sText)
                    \_iStatus = GetGadgetState(iGadget_ID)
                    
                  Else
                    SetGadgetState (iGadget_ID, \_iStatus)
                    \_sText = GetGadgetText(iGadget_ID)
                    
                  EndIf							
                  
                EndWith
                
              EndIf
              
            EndIf		
            
            
          Case "DateElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iUpdate_Flag = #True
              
              ; Schriftart aktualisieren
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_Update = #True
                
                iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_ID
                
                If (iSchriftart_ID = #PB_Default) Or (IsFont(iSchriftart_ID) = 0)
                  SetGadgetFont(iGadget_ID, #PB_Default) 
                Else
                  SetGadgetFont(iGadget_ID, FontID(iSchriftart_ID)) 
                EndIf
                
              EndIf
              
              
              ; Element-Einstellungen übernehmen
              SetGadgetText 		(iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_sMaske)
              SetGadgetState		(iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iDate)
              
              SetGadgetAttribute	(iGadget_ID, #PB_Calendar_Minimum, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iMin_Datum)
              SetGadgetAttribute	(iGadget_ID, #PB_Calendar_Maximum, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iMax_Datum)
              
              SetGadgetColor		(iGadget_ID, #PB_Gadget_BackColor, 			CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iBackgroundColor)
              SetGadgetColor		(iGadget_ID, #PB_Gadget_FrontColor, 		CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iVordergrundfarbe)
              SetGadgetColor		(iGadget_ID, #PB_Gadget_TitleBackColor,		CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iTitel_Hintergrundfarbe)
              SetGadgetColor		(iGadget_ID, #PB_Gadget_TitleFrontColor,	CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iTitel_Vordergrundfarbe)
              SetGadgetColor		(iGadget_ID, #PB_Gadget_GrayTextColor,		CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iAusgegraute_Farbe)
              
            EndIf
            
            
          Case "ExplorerComboElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iUpdate_Flag = #True
              
              
              ; Schriftart aktualisieren
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_Update = #True
                
                iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_ID
                
                If (iSchriftart_ID = #PB_Default) Or (IsFont(iSchriftart_ID) = 0)
                  SetGadgetFont(iGadget_ID, #PB_Default) 
                Else
                  SetGadgetFont(iGadget_ID, FontID(iSchriftart_ID)) 
                EndIf
                
                ; die Größe der Gadgets neu anpassen (Aufgrund fehlerhafter Darstellung beim ExplorerComboGadget)
                _CustomStatusBar_groesse_automatisch_anpassen (iCustomStatusBar_ID)
                
              EndIf
              
              ; verhindert, dass das aktuell editierte Field aktualisiert wird
              If (GetActiveGadget() <> iGadget_ID)
                
                ; Element-Einstellungen übernehmen
                SetGadgetText (iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_sDirectory)
                
              EndIf
              
            EndIf
            
            
          Case "HyperLinkElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iUpdate_Flag = #True
              
              ; Schriftart aktualisieren
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_Update = #True
                
                iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_ID
                
                If (iSchriftart_ID = #PB_Default) Or (IsFont(iSchriftart_ID) = 0)
                  SetGadgetFont(iGadget_ID, #PB_Default) 
                Else
                  SetGadgetFont(iGadget_ID, FontID(iSchriftart_ID)) 
                EndIf
                
              EndIf
              
              
              ; Element-Einstellungen übernehmen
              SetGadgetText (iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_sText)					
              SetGadgetColor(iGadget_ID, #PB_Gadget_FrontColor,	CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftfarbe)
              SetGadgetColor(iGadget_ID, #PB_Gadget_BackColor,	CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iBackgroundColor)
              
            EndIf
            
            
          Case "IPAddressElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iUpdate_Flag = #True
              
              ; Schriftart aktualisieren
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_Update = #True
                
                iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_ID
                
                If (iSchriftart_ID = #PB_Default) Or (IsFont(iSchriftart_ID) = 0)
                  SetGadgetFont(iGadget_ID, #PB_Default) 
                Else
                  SetGadgetFont(iGadget_ID, FontID(iSchriftart_ID)) 
                EndIf
                
              EndIf
              
              
              ; verhindert, dass das aktuell editierte Field aktualisiert wird
              If (GetActiveGadget() <> iGadget_ID)
                
                iIP_Field_1 = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_1
                iIP_Field_2 = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_2
                iIP_Field_3 = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_3
                iIP_Field_4 = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_4
                
                iStatus = MakeIPAddress(iIP_Field_1, iIP_Field_2, iIP_Field_3, iIP_Field_4)
                
                ; Element-Einstellungen übernehmen
                SetGadgetState (iGadget_ID, iStatus)
                
              EndIf
              
            EndIf
            
            
          Case "ProgressBarElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iUpdate_Flag = #True
              
              ; Element-Einstellungen übernehmen
              SetGadgetAttribute(iGadget_ID, #PB_ProgressBar_Minimum, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iMinimum)
              SetGadgetAttribute(iGadget_ID, #PB_ProgressBar_Maximum, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iMaximum)
              SetGadgetState(iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iValue)
              
            EndIf
            
            
          Case "ScrollBarElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iUpdate_Flag = #True
              
              ; Element-Einstellungen übernehmen
              SetGadgetState(iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iValue)
              SetGadgetAttribute(iGadget_ID, #PB_ScrollBar_Minimum, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iMinimum)
              SetGadgetAttribute(iGadget_ID, #PB_ScrollBar_Maximum, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iMaximum)
              SetGadgetAttribute(iGadget_ID, #PB_ScrollBar_PageLength, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iPageSize)
              
            EndIf
            
            
          Case "ShortcutElement"
            
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iUpdate_Flag = #True
              
              ; Schriftart aktualisieren
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_Update = #True
                
                iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_ID
                
                If (iSchriftart_ID = #PB_Default) Or (IsFont(iSchriftart_ID) = 0)
                  SetGadgetFont(iGadget_ID, #PB_Default) 
                Else
                  SetGadgetFont(iGadget_ID, FontID(iSchriftart_ID)) 
                EndIf
                
              EndIf
              
              ; Element-Einstellungen übernehmen
              SetGadgetState(iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iShortcutKey)
              
            EndIf					
            
            
          Case "SpinElement"
            
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iUpdate_Flag = #True
              
              ; Schriftart aktualisieren
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_Update = #True
                
                iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_ID
                
                If (iSchriftart_ID = #PB_Default) Or (IsFont(iSchriftart_ID) = 0)
                  SetGadgetFont(iGadget_ID, #PB_Default) 
                Else
                  SetGadgetFont(iGadget_ID, FontID(iSchriftart_ID)) 
                EndIf
                
              EndIf
              
              
              ; Element-Einstellungen übernehmen
              With CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget
                
                ; prüfen, ob der Wert die Min/Max-Grenze erreicht hat
                If \_iValue > \_iMaximum
                  \_iValue = \_iMaximum
                  
                ElseIf \_iValue < \_iMinimum
                  \_iValue = \_iMinimum
                  
                EndIf
                
                
                ; nur den Status übernehmen, wenn im aktuellen Element eine Eingabe erfolgte
                If (GetActiveGadget() = iGadget_ID) And (\_iEvent_Typ = #PB_EventType_Change)
                  SetGadgetState(iGadget_ID, \_iValue)
                  
                  ; Status und Text übernehmen, wenn die Pfeiltasten gedrückt wurden
                ElseIf \_iEvent_Typ = #PB_EventType_Change
                  SetGadgetText(iGadget_ID, \_sText)
                  SetGadgetState(iGadget_ID, \_iValue)	
                  
                  ; Status und Text übernehmen, wenn die Art der Eingabe nicht bestimmt werden konnte
                Else
                  \_sText = Str(\_iValue)
                  SetGadgetText(iGadget_ID, \_sText)
                  SetGadgetState(iGadget_ID, \_iValue)	
                  
                EndIf
                
                ; Farben und Attribute übernehmen
                SetGadgetColor		(iGadget_ID, #PB_Gadget_BackColor,	\_iBackgroundColor)
                SetGadgetColor		(iGadget_ID, #PB_Gadget_FrontColor,	\_iSchriftfarbe)
                SetGadgetAttribute	(iGadget_ID, #PB_Spin_Minimum,		\_iMinimum)
                SetGadgetAttribute	(iGadget_ID, #PB_Spin_Maximum,		\_iMaximum)
                
              EndWith
              
            EndIf					
            
            
          Case "StringElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iUpdate_Flag = #True
              
              ; Schriftart aktualisieren
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_Update = #True
                
                iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_ID
                
                If (iSchriftart_ID = #PB_Default) Or (IsFont(iSchriftart_ID) = 0)
                  SetGadgetFont(iGadget_ID, #PB_Default) 
                Else
                  SetGadgetFont(iGadget_ID, FontID(iSchriftart_ID)) 
                EndIf
                
              EndIf
              
              
              ; Element-Einstellungen übernehmen (außer in dem Gadget, in dem gerade die Eingabe erfolgte)
              If (GetActiveGadget() <> iGadget_ID)
                SetGadgetText(iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_sValue)
                SetGadgetColor(iGadget_ID, #PB_Gadget_BackColor, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iBackgroundColor)
                SetGadgetColor(iGadget_ID, #PB_Gadget_FrontColor, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftfarbe)
                SetGadgetAttribute(iGadget_ID, #PB_String_MaximumLength, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iMaximum)
              EndIf
              
            EndIf
            
            
          Case "TextElement"
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iUpdate_Flag = #True
              
              ; Schriftart aktualisieren
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_Update = #True
                
                iSchriftart_ID = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_ID
                
                If (iSchriftart_ID = #PB_Default) Or (IsFont(iSchriftart_ID) = 0)
                  SetGadgetFont(iGadget_ID, #PB_Default) 
                Else
                  SetGadgetFont(iGadget_ID, FontID(iSchriftart_ID)) 
                EndIf
                
              EndIf
              
              
              ; Element-Einstellungen übernehmen
              SetGadgetText(iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_sStatustext)
              SetGadgetColor(iGadget_ID, #PB_Gadget_BackColor, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iBackgroundColor)
              SetGadgetColor(iGadget_ID, #PB_Gadget_FrontColor, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftfarbe)
              
            EndIf
            
            
          Case "TrackBarElement"
            
            
            If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iUpdate_Flag = #True
              
              ; Element-Einstellungen übernehmen
              SetGadgetAttribute(iGadget_ID, #PB_TrackBar_Minimum, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iMinimum)
              SetGadgetAttribute(iGadget_ID, #PB_TrackBar_Maximum, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iMaximum)
              SetGadgetState(iGadget_ID, CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iValue)
              
            EndIf
            
        EndSelect				
        
      EndIf
      
    Next
    
    
    ; die Update-Flags bei allen Elementen zurücksetzen
    For iCounter = 1 To iMax_Anzahl_Fielder Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True
        
        iElement_ID	= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iElement_ID
        iGadget_ID	= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID
        sElement_Typ	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
        
        
        ; die Aktualisierung der aktuellen Field überspringen, wenn das Element als Freigegeben markiert wurde oder das Gadget nicht existiert
        If (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False) Or (IsGadget(iGadget_ID) = 0)
          Continue
        EndIf
        
        
        ; die Gadgets aktualisieren
        Select sElement_Typ
            
          Case "ButtonElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iUpdate_Flag					= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_Update			= #False
            
            
          Case "ButtonImageElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iUpdate_Flag				= #False
            
            
          Case "CanvasElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iUpdate_Flag					= #False
            
            
          Case "CheckBoxElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iUpdate_Flag				= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_Update			= #False
            
            
          Case "ComboBoxElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag				= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Status				= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Text				= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_Update			= #False
            
            
          Case "DateElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iUpdate_Flag					= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_Update				= #False
            
            
          Case "ExplorerComboElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iUpdate_Flag			= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_Update		= #False
            
            
          Case "HyperLinkElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iUpdate_Flag				= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_Update			= #False
            
            
          Case "IPAddressElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iUpdate_Flag				= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_Update			= #False
            
            
          Case "ProgressBarElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iUpdate_Flag				= #False
            
            
          Case "ScrollBarElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iUpdate_Flag				= #False
            
            
          Case "ShortcutElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iUpdate_Flag				= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_Update			= #False
            
            
          Case "SpinElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iUpdate_Flag					= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_Update				= #False
            
            
          Case "StringElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iUpdate_Flag					= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_Update			= #False
            
            
          Case "TextElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iUpdate_Flag					= #False
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_Update				= #False
            
            
          Case "TrackBarElement"
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iUpdate_Flag				= #False
            
            
        EndSelect				
        
      EndIf
      
    Next
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_Fielder_sortieren
  ;
  ; Beschreibung ..: 	nummeriert die Fielder in der CustomStatusBar neu
  ;
  ; Syntax.........:  _Fielder_sortieren (iCustomStatusBar_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;												
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	Werden Fielder in der CustomStatusBar gelöscht, so existiert ein leerer Indexeintrag. Damit beim Hinzufügen neuer Fielder über das Kontextmenü die Elemente auch am Ende
  ;					der CustomStatusBar plaziert werden und nicht die entstandenen Lücken füllen, ist es nötig die Fielder neu zu nummerieren. Dadurch werden diese "Lücken" geschlossen und
  ;					neue Fielder werden am Ende der CustomStatusBar eingefügt.
  ;				
  ;} ========
  Procedure.i _Fielder_sortieren (iCustomStatusBar_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iMax_Anzahl_Elemente.i 	= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iMax_Anzahl_Fielder.i		= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Field())
    Protected iElement_ID.i				= 0
    Protected iCounter_1.i				= 0
    Protected iCounter_2.i				= 0
    Protected iQuelle.i					= 0
    Protected iZiel.i					= 0
    
    
    ; die Fielder neu sortieren
    For iCounter_1 = 1 To iMax_Anzahl_Fielder Step 1
      
      iQuelle = 0
      iZiel	= 0
      
      
      ; die Zielposition suchen
      For iCounter_2 = 1 To iMax_Anzahl_Fielder Step 1
        
        If CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter_2)\_iBelegt = #False
          iZiel = iCounter_2
          Break
        Else
          iZiel = -1
        EndIf
        
      Next
      
      
      ; Abbrechen, wenn keine freien Fielder zur Verfügung stehen
      If iZiel = -1 
        Break
      EndIf
      
      
      ; die Quellposition suchen
      For iCounter_2 = iZiel + 1 To iMax_Anzahl_Fielder Step 1
        
        If CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter_2)\_iBelegt = #True
          iQuelle = iCounter_2
          Break
        Else
          iQuelle = -1
        EndIf
        
      Next			
      
      ; Abbrechen, wenn es keine verfügbare Quelle mehr gibt
      If iQuelle = -1 
        Break
      EndIf
      
      
      ; QuellField in das ZielField verschieben
      iElement_ID = CustomStatusBar(iCustomStatusBar_ID)\Field(iQuelle)\_iElement_ID
      
      CustomStatusBar(iCustomStatusBar_ID)\Field(iQuelle)\_iBelegt 		= #False
      CustomStatusBar(iCustomStatusBar_ID)\Field(iQuelle)\_iElement_ID 	= 0
      CustomStatusBar(iCustomStatusBar_ID)\Field(iZiel)\_iBelegt 		= #True
      CustomStatusBar(iCustomStatusBar_ID)\Field(iZiel)\_iElement_ID 	= iElement_ID
      
    Next
    
    
    ; CustomStatusBar neu aufbauen
    _erneuere_CustomStatusBar (iCustomStatusBar_ID)
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_gebe_Field_des_Elements
  ;
  ; Beschreibung ..:  sucht das angegebene Element in den Fieldern der CustomStatusBar und gibt dessen Position zurück
  ;
  ; Syntax.........:  _gebe_Field_des_Elements (iCustomStatusBar_ID.i, iElement_ID.i, iFund.i = 1)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					iElement_ID.i				- die Element-ID, auf der sich bezogen wird
  ;					iFund.i						- der Treffer, der für die Rückgabe relevant ist
  ;												
  ; Rückgabewerte .:	Erfolg 						|  0: das angegebene Element wurde in keinem Field gefunden
  ;												| >0: die Fieldnummer, in der das angegebene Element gefunden wurde
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: die Element-ID ist ungültig (Element-ID ist <0)
  ;												| -4: die Element-ID ist ungültig (Element-ID ist größer als die Gesamtzahl der existierenden Elemente)
  ;												| -5: das Element ist als "nicht Belegt" markiert
  ;
  ; Bemerkungen ...:	Der Parameter "iFund.i" wird nur benötigt, wenn ein Element öffters in der CustomStatusBar vertreten ist (also zwei oder mehrere Fielder benutzt).
  ;					Ist der Parameter 1, so werden die Fielder der CustomStatusBar von links nach rechts abgesucht und die Position des ersten treffers zurückgegeben.
  ;					Wird der Parameter z.B. auf 2 gesetzt, so wird der erste gefundene Treffer übersprungen und weiter gesucht. Wird ein zweiter Treffer gefunden, so wird
  ;					diese Position zurückgegeben. Ist dies nicht der Fall, so wird 0 als Rückgabewert verwendet.
  ;
  ;} ========
  Procedure.i _gebe_Field_des_Elements (iCustomStatusBar_ID.i, iElement_ID.i, iFund.i = 1)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If iElement_ID <= 0:																	ProcedureReturn -3:		EndIf                                 ; Abbrechen, wenn die Element ID ungültig ist
    If iElement_ID > ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()):						ProcedureReturn -4:		EndIf         ; Abbrechen, wenn die Element ID ungültig ist
    If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #False:					ProcedureReturn -5:		EndIf         ; Abbrechen, wenn der Element-Array-Eintrag als frei markiert ist		
    
    
    ; lokale Variablen deklarieren und initialisieren		
    Protected iMax_Anzahl_Fielder.i		= ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Field())
    Protected iField.i					= 0
    Protected iCounter.i				= 0
    Protected iTreffer.i				= 0
    
    
    ; prüft, ob sich das angegebene Element in einem Field der CustomStatusBar befindet
    For iCounter = 1 To iMax_Anzahl_Fielder Step 1
      
      If (CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True) And (CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iElement_ID = iElement_ID)
        
        iTreffer + 1
        
        If iTreffer = iFund
          iField = iCounter
          Break
        Else
          iField = 0
        EndIf
        
      Else
        iField = 0
      EndIf
      
    Next
    
    
    ; gibt die Nummer des Fieldes zurück, in der das Element gefunden wurde (oder Null, wenn es nicht gefunden wurde)
    ProcedureReturn iField
    
  EndProcedure
  
  
  
  ;-
  ;-
  ;-
  ;- sonstige Prozeduren
  ;- -----------------------------------------------------------------------------
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_erneuere_CustomStatusBar
  ;
  ; Beschreibung ..: 	erneuert die Fielder in der CustomStatusBar und tauscht diese ggf. aus
  ;
  ; Syntax.........:  _erneuere_CustomStatusBar (iCustomStatusBar_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;												
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	Wird ein Element in der CustomStatusBar hinzugefügt, ausgetauscht oder gelöscht, so wird die komplette CustomStatusBar neu aufgebaut. Dabei werden zunächst alle
  ;					Fielder (also auch die Gadgets) gelöscht. Anschließend werden neue Fielder erstellt, in dennen die ausgewählten Elemente eingebettet werden. Je nach Element
  ;					werden so neue Gadgets erstellt und an den Einstellungen der Elemente angepasst. 
  ;				
  ;} ========
  Procedure.i _erneuere_CustomStatusBar (iCustomStatusBar_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren		
    Protected iMin_Abstand_der_Elemente.i	= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMin_Abstand_der_Elemente
    Protected iMax_Anzahl_Fielder.i			= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMax_Elements_visible
    Protected iWindow.i 					= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow
    Protected iHeight_CustomStatusBar.i 			= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHeight
    
    Protected iElement_ID.i					= 0
    Protected iGadget_ID.i					= 0
    Protected iSeparator_ID.i				= 0
    
    Protected iCounter.i					= 0
    
    Protected iX_Pos.i						= 0
    Protected iY_Pos.i						= 0
    Protected iWidth.i						= 0
    Protected iHeight.i						= 0
    Protected iY_Pos_Offset.i				= 0
    
    Protected iFlags.i 						= 0
    Protected iImage.i 						= 0
    Protected iDate.i						= 0
    Protected iColor.i						= 0
    Protected iMinimum.i					= 0
    Protected iMaximum.i					= 0
    Protected iShortcutKey.i				= 0
    Protected iPageSize.i				= 0
    Protected sDirectory.s				= ""
    Protected sDatum_Maske.s				= ""			
    Protected sText.s 						= ""
    
    
    ; die Fieldparameter der darzustellenden Elemente berechnen (X-Position, Y-Position, Breite und Höhe)
    _berechne_Element_Fielder (iCustomStatusBar_ID)	
    
    
    ; die Gadget-Liste der CustomStatusBar öffnen
    OpenGadgetList(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich)
    
    
    ; Gadgets aktualisieren
    For iCounter = 1 To iMax_Anzahl_Fielder Step 1
      
      
      ; vorhandene Parameter auslesen
      iElement_ID 	= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iElement_ID
      iGadget_ID		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID
      iSeparator_ID	= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID
      
      
      ; vorhandenes Gadget löschen
      If IsGadget(iGadget_ID) <> 0
        FreeGadget(iGadget_ID)
        CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID		= -1
      EndIf
      
      
      ; vorhandenen Separator löschen
      If IsGadget(iSeparator_ID) <> 0
        FreeGadget(iSeparator_ID)
        CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= -1
      EndIf
      
      
      ; Field als frei markieren, wenn kein Element darauf enthalten ist
      If (CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True)  And (CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iElement_ID = #False)
        CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #False
      EndIf
      
      
      ; neues Gadget erstellen
      If (CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True)  And (CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_iBelegt = #True)
        
        ; Field-Parameter laden und Abmessungen berechnen
        iX_Pos		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iX_Pos + (iMin_Abstand_der_Elemente / 2)
        iY_Pos		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iY_Pos
        iWidth		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iWidth - (iMin_Abstand_der_Elemente)
        iHeight		= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight
        
        
        ; den Offset-Parameter des Gadgets laden
        Select CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
          Case "ButtonElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ButtonGadget)\_iY_Pos_Offset
          Case "ButtonImageElement":	iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ButtonImageGadget)\_iY_Pos_Offset	
          Case "CanvasElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#CanvasGadget)\_iY_Pos_Offset
          Case "CheckBoxElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#CheckBoxGadget)\_iY_Pos_Offset
          Case "ComboBoxElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ComboBoxGadget)\_iY_Pos_Offset
          Case "DateElement":			iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#DateGadget)\_iY_Pos_Offset
          Case "ExplorerComboElement":	iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ExplorerComboGadget)\_iY_Pos_Offset
          Case "HyperLinkElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#HyperLinkGadget)\_iY_Pos_Offset
          Case "IPAddressElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#IPAddressGadget)\_iY_Pos_Offset
          Case "ProgressBarElement":	iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ProgressBarGadget)\_iY_Pos_Offset
          Case "ScrollBarElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ScrollBarGadget)\_iY_Pos_Offset
          Case "ShortcutElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#ShortcutGadget)\_iY_Pos_Offset
          Case "SpinElement":			iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#SpinGadget)\_iY_Pos_Offset
          Case "StringElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#StringGadget)\_iY_Pos_Offset
          Case "TextElement":			iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#TextGadget)\_iY_Pos_Offset
          Case "TrackBarElement":		iY_Pos_Offset	= CustomStatusBar(iCustomStatusBar_ID)\Gadget_Standard_Einstellungen(#TrackBarGadget)\_iY_Pos_Offset
        EndSelect
        
        
        ; die Gadget-Position korrigieren
        iY_Pos = iY_Pos + iY_Pos_Offset
        iHeight = iHeight - (2 * iY_Pos_Offset)
        If iWidth	< 0: iWidth	= 0:	EndIf
        If iHeight	< 0: iHeight		= 0:	EndIf
        
        
        ; den aktuellen Gadget-Typ selektieren
        Select CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
            
            
          Case "ButtonElement"
            
            ; Element-Einstellungen laden
            iFlags			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iFlags
            sText			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_sText
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= ButtonGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, sText, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iUpdate_Flag 			= #True
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iSchriftart_Update 	= #True
            
            
          Case "ButtonImageElement"
            
            ; Element-Einstellungen laden
            iFlags 			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iFlags
            iImage			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iImage_ID_normal
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= ButtonImageGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, iImage, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)	
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iUpdate_Flag = #True					
            
            
          Case "CanvasElement"
            
            ; Element-Einstellungen laden
            iFlags 			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iFlags
            iImage 			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iImage
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= CanvasGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor,	$CCCCCC)
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; die Grafik einzeichnen
            If StartDrawing(CanvasOutput(iGadget_ID))
              
              ; den Zeichenbereich mit der Hintergrunfarbe füllen
              Box(0 ,0 , iWidth, iHeight, CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iHintergrundfabe)
              
              ; das Bild einzeichnen (sofern dies existent ist)
              If IsImage(iImage) <> 0
                
                If CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iAutoanpassung = #True
                  DrawImage(ImageID(iImage), 0, 0, ImageWidth(iImage), iHeight ) 
                Else
                  DrawImage(ImageID(iImage), ((iWidth)/2) - ((ImageWidth(iImage))/2), ((iHeight)/2) - ((ImageHeight(iImage))/2)) 
                EndIf
                
              EndIf
              
              StopDrawing()
              
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CanvasGadget\_iUpdate_Flag = #True
            
            
          Case "CheckBoxElement"
            
            ; Element-Einstellungen laden
            iFlags	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iFlags
            sText	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_sText
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= CheckBoxGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, sText, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iSchriftart_Update = #True
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iUpdate_Flag = #True					
            
            
          Case "ComboBoxElement"
            
            ; Element-Einstellungen laden
            iFlags			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iFlags
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= ComboBoxGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag 		= #True					
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iSchriftart_Update 	= #True
            
            
          Case "DateElement"
            
            ; Element-Einstellungen laden
            iFlags			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iFlags
            sDatum_Maske	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_sMaske
            iDate			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iDate
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= DateGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, sDatum_Maske, iDate, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)		
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf	
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iUpdate_Flag		= #True					
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iSchriftart_Update	= #True
            
            
          Case "ExplorerComboElement"
            
            ; Element-Einstellungen laden
            iFlags			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iFlags
            sDirectory	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_sDirectory
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= ExplorerComboGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, sDirectory, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)		
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iUpdate_Flag		= #True					
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iSchriftart_Update = #True
            
            
          Case "HyperLinkElement"
            
            ; Element-Einstellungen laden
            iFlags			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iFlags
            sText			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_sText
            iColor			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iHover_farbe
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= HyperLinkGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, sText, iColor, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)					
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf	
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iUpdate_Flag 		= #True					
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\HyperLinkGadget\_iSchriftart_Update = #True
            
            
          Case "IPAddressElement"
            
            ; Gadget und Separator erstellen
            iGadget_ID		= IPAddressGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor,	$CCCCCC)
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iUpdate_Flag 		= #True				
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iSchriftart_Update = #True
            
            
          Case "ProgressBarElement"
            
            ; Element-Einstellungen laden
            iFlags			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iFlags
            iMinimum		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iMinimum
            iMaximum		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iMaximum
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= ProgressBarGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, iMinimum, iMaximum, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ProgressBarGadget\_iUpdate_Flag = #True					
            
            
          Case "ScrollBarElement"
            
            ; Element-Einstellungen laden
            iFlags			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iFlags
            iMinimum		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iMinimum
            iMaximum		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iMaximum
            iPageSize	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iPageSize
            
            ; Gadget und Separator erstellen
            iGadget_ID		= ScrollBarGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, iMinimum, iMaximum, iPageSize, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iUpdate_Flag = #True					
            
            
          Case "ShortcutElement"
            
            ; Element-Einstellungen laden
            iShortcutKey	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iShortcutKey
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= ShortcutGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, iShortcutKey)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)		
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iUpdate_Flag 		= #True
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iSchriftart_Update	= #True
            
            
            
          Case "SpinElement"
            
            ; Element-Einstellungen laden
            iFlags			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iFlags
            iMinimum		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iMinimum
            iMaximum		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iMaximum
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= SpinGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, iMinimum, iMaximum, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iUpdate_Flag		= #True					
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iSchriftart_Update 	= #True
            
            
          Case "StringElement"
            
            ; Element-Einstellungen laden
            iFlags			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iFlags
            sText			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_sValue
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= StringGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, sText, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iUpdate_Flag 			= #True					
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iSchriftart_Update 	= #True
            
            
          Case "TextElement"
            
            ; Element-Einstellungen laden
            iFlags 			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iFlags
            sText			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_sStatustext
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= TextGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, sText, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor,	$CCCCCC)
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iUpdate_Flag 		= #True					
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TextGadget\_iSchriftart_Update	= #True
            
            
          Case "TrackBarElement"
            
            ; Element-Einstellungen laden
            iFlags			= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iFlags
            iMinimum		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iMinimum
            iMaximum		= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iMaximum
            
            
            ; Gadget und Separator erstellen
            iGadget_ID		= TrackBarGadget(#PB_Any, iX_Pos, iY_Pos, iWidth , iHeight, iMinimum, iMaximum, iFlags)
            iSeparator_ID	= TextGadget(#PB_Any, iX_Pos + iWidth + (iMin_Abstand_der_Elemente / 2), iY_Pos - iY_Pos_Offset, 1, CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iHeight - 1, "")
            
            
            ; Gadget und Separatornummer speichern
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID 		= iGadget_ID
            CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iSeparator_ID	= iSeparator_ID
            
            
            ; Einstellungen anpassen
            SetGadgetColor	(iSeparator_ID,	#PB_Gadget_BackColor, $CCCCCC)	
            
            If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iSeparator_hide = #True
              HideGadget(iSeparator_ID, #True)
            Else
              HideGadget(iSeparator_ID, #False)
            EndIf
            
            
            ; Aktualisierung aktivieren
            CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iUpdate_Flag = #True					
            
            
        EndSelect
        
      EndIf
      
    Next
    
    
    ; die Gadget-Liste der CustomStatusBar schließen
    CloseGadgetList()
    
    
    ; Prozedur erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_gebe_Anzahl_der_Elemente
  ;
  ; Beschreibung ..:  zählt die vorhandenen Elemente in der CustomStatusBar (nicht die Fielder)
  ;
  ; Syntax.........:  _gebe_Anzahl_der_Elemente (iCustomStatusBar_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;												
  ; Rückgabewerte .:	Erfolg 						- gibt die Anzahl der gefundenen Elemente zurück
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i _gebe_Anzahl_der_Elemente (iCustomStatusBar_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    
    
    ; lokale Variablen deklarieren und initialisieren	
    Protected iElement_Array_groesse.i	= ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element())
    Protected iGefundene_Elemente.i		= 0
    Protected iCounter.i				= 0
    
    
    ; die Anzahl der Elemente ermitteln
    For iCounter = 1 To iElement_Array_groesse Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #True
        iGefundene_Elemente + 1
      EndIf
      
    Next
    
    
    ; gibt die Anzahl der gefundenen Elemente zurück
    ProcedureReturn iGefundene_Elemente
    
  EndProcedure
  
  
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_Tooltip
  ;
  ; Beschreibung ..:  erzeugt ein Tooltip oder ein Ballon-Tipp
  ;
  ; Syntax.........:  _Tooltip (iCustomStatusBar_ID.i, sText.s , sTitle.s = "", sIcon.s = "none", iX_Pos.i = #PB_Default, iY_Pos.i = #PB_Default, iMax_Width.i = #PB_Default, iBallon.i = #False, iSchliessen.i = #False)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;					sText.s						- der anzuzeigende Text (oder "", um das Tooltip zu löschen)
  ;					sTitle.s					- der anzuzeigende Titel (optional)
  ;					sIcon.s					- das Symbol, das angezeigt werden soll
  ;												| "none":		zeigt kein Symbol an
  ;												| "Info":		zeigt ein Infosymbol
  ;												| "Warning":	zeigt ein Warnsymbol	
  ;												| "Error":		zeigt ein Fehlersymbol
  ;
  ;					iX_Pos.i					- die X-Koordinate des Tooltips (absolute Koordinate; bezogen auf dem Desktop)
  ;												| #PB_Default:	positioniert das Tooltip neben dem Mauszeiger
  ;
  ;					iY_Pos.i					- die Y-Koordinate des Tooltips (absolute Koordinate; bezogen auf dem Desktop)
  ;												| #PB_Default:	positioniert das Tooltip neben dem Mauszeiger
  ;
  ;					iMax_Width.i				- die Breite, die das Tooltip maximal haben darf
  ;												| #PB_Default: 	Standardbreite = 400 Pixel
  ;
  ;					iBallon.i					- Bool: zeigt bei #True einen Ballon-Tipp anstatt eines Tooltips an
  ;					iSchliessen.i				- Bool: zeigt bei #True einen Schließen-Button an (nur, wenn iBallon = #True)
  ;												
  ; Rückgabewerte .:	Erfolg 						|  gibt die ID des Tooltips zurück
  ;
  ;                  	Fehler 						| -1: das angegebene Tooltip existiert nicht
  ;												|  1: das aktuelle Tooltip wurde gelöscht
  
  ;
  ; Bemerkungen ...:	diese Prozedur lädt und speichert die Tooltip-IDs automatisch. Erhält eine Tooltip-ID einen leeren String als Text, so wird das Tooltip gelöscht.
  ;					Ansonsten bleibt es bis zum Programmende bestehen.
  ;
  ;} ========
  Procedure.i _Tooltip (iCustomStatusBar_ID.i, sText.s , sTitle.s = "", sIcon.s = "none", iX_Pos.i = #PB_Default, iY_Pos.i = #PB_Default, iMax_Width.i = #PB_Default, iBallon.i = #False, iSchliessen.i = #False)
    
    ; Konstanten festlegen (siehe MSDN)
    #TTF_ABSOLUTE 	= $0080
    #TTF_TRACK 		= $0020
    #TTS_CLOSE 		= $80
    #TTS_NOFADE		= $20
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected 	iTooltip_ID.i			= 0
    Protected	iStyle_aktuell			= 0
    Protected 	iIcon.i				= 0
    Protected 	iStyle.i				= #WS_POPUP | #TTS_NOPREFIX | #TTS_ALWAYSTIP | #TTS_NOFADE
    Protected 	iExStyle.i				= 0	; #WS_EX_TOPMOST; immer im Vordergrund
    Protected	iInstanz.i				= GetModuleHandle_(0)
    Protected	lPosition.l				= 0
    
    Protected 	iWindowID.i				= 0	; experimentell: WindowID angeben, falls es Probleme mit der Darstellung gibt
    Protected 	Parameter.TOOLINFO
    
    Protected 	iUpdate_Inhalt.i		= 0
    Protected 	iUpdate_Position.i		= 0
    
    ; Parameter laden
    If iBallon = #False
      iTooltip_ID 	= CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_ID
      iStyle_aktuell 	= CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Style
    Else
      iTooltip_ID 	= CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_ID
      iStyle_aktuell 	= CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_Style
    EndIf
    
    
    ; Tooltip löschen, wenn kein Text angegeben wurde
    If sText = "" And iTooltip_ID <> 0
      DestroyWindow_(iTooltip_ID)
      
      If iBallon = #False
        CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_ID 		= 0
        CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Style		= 0
      Else
        CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_ID 	= 0
        CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_Style	= 0
      EndIf
      
      ProcedureReturn 1
      
      
      ; Parameter zurücksetzten wenn kein Tooltip existiert
    ElseIf sText = "" And iTooltip_ID = 0
      
      If iBallon = #False
        CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_ID 		= 0
        CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Style		= 0
      Else
        CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_ID 	= 0
        CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_Style	= 0
      EndIf
      
      ProcedureReturn -1
      
    EndIf
    
    
    ; darzustellendes Symbol
    If sIcon = "none"
      iIcon = #TOOLTIP_NO_ICON
      
    ElseIf sIcon = "Info"
      iIcon = #TOOLTIP_INFO_ICON
      
    ElseIf sIcon = "Warning"
      iIcon = #TOOLTIP_WARNING_ICON
      
    ElseIf sIcon = "Error"
      iIcon = #TOOLTIP_ERROR_ICON
      
    Else
      iIcon = #TOOLTIP_NO_ICON
      
    EndIf
    
    
    ; X-Position bestimmen (Standard: aktuelle Mauspositon)
    If (iX_Pos = #PB_Default) And (iBallon = #True)
      
      iX_Pos = DesktopMouseX()
      
    ElseIf (iX_Pos = #PB_Default) And (iBallon = #False)
      
      iX_Pos = DesktopMouseX() +16
      
    EndIf
    
    
    ; Y-Position bestimmen (Standard: aktuelle Mauspositon)
    If iY_Pos = #PB_Default
      
      iY_Pos = DesktopMouseY()
      
    EndIf	
    
    
    ; maximale Breite festlegen
    If (iMax_Width = #PB_Default) Or (iMax_Width < 10)
      
      iMax_Width = 400
      
    EndIf	
    
    
    ; ggf. Ballonform aktivieren
    If iBallon = #True
      iStyle | #TTS_BALLOON
    EndIf
    
    
    ; ggf. den Schließen-Button anzeigen (Ballonform muss aktiviert sein, damit der Effekt sichtbar wird)
    If iSchliessen = #True
      iStyle | #TTS_CLOSE
    EndIf
    
    
    ; Tooltip erstellen
    If iTooltip_ID = 0
      iTooltip_ID = CreateWindowEx_(iExStyle, #TOOLTIPS_CLASS, #Null, iStyle, 0, 0, 0, 0, iWindowID, 0, iInstanz, 0)
    Else
      If iStyle_aktuell <> iStyle
        DestroyWindow_(iTooltip_ID)
        iTooltip_ID = CreateWindowEx_(iExStyle, #TOOLTIPS_CLASS, #Null, iStyle, 0, 0, 0, 0, iWindowID, 0, iInstanz, 0)
      EndIf
      
    EndIf
    
    
    ; Parameter speichern
    If iBallon = #False
      CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_ID 		= iTooltip_ID
      CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Style		= iStyle
    Else
      CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_ID 	= iTooltip_ID
      CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_Style	= iStyle
    EndIf
    
    
    ; Eigenschaften übernehmen und anzeigen
    Parameter.TOOLINFO\cbSize		= SizeOf(TOOLINFO)
    Parameter\uFlags				= #TTF_IDISHWND | #TTF_ABSOLUTE | #TTF_TRACK
    Parameter\hWnd					= iWindowID
    Parameter\uId					= iWindowID
    Parameter\lpszText				= @sText
    Parameter\hInst 				= iInstanz
    lPosition						= (iX_Pos & $FFFF) | ((iY_Pos & $FFFF) << 16)
    
    
    
    
    With CustomStatusBar(iCustomStatusBar_ID)\Tooltips
      
      If iBallon = #False
        
        ; prüfen, ob die Position oder der Inhalt geändert wurde
        If (sText <> \_sTooltip_letzter_Text) Or (sTitle <> \_sTooltip_letzter_Titel) Or (sIcon <> \_sTooltip_letztes_Symbol)
          iUpdate_Inhalt		= #True
          iUpdate_Position	= #True
        Else
          
          iUpdate_Inhalt		= #False
          
          If (iX_Pos <> \_iTooltip_letzte_X_Pos) Or (iY_Pos <> \_iTooltip_letzte_Y_Pos)
            iUpdate_Position	= #True
          Else
            iUpdate_Position	= #False
          EndIf
          
        EndIf
        
        ; aktuelle Daten speichern
        \_sTooltip_letzter_Text 	= sText
        \_sTooltip_letzter_Titel 	= sTitle
        \_sTooltip_letztes_Symbol 	= sIcon
        \_iTooltip_letzte_X_Pos.i	= iX_Pos
        \_iTooltip_letzte_Y_Pos.i	= iY_Pos
        
      Else
        
        ; prüfen, ob die Position oder der Inhalt geändert wurde
        If (sText <> \_sBallon_Info_letzter_Text) Or (sTitle <> \_sBallon_Info_letzter_Titel) Or (sIcon <> \_sBallon_Info_letztes_Symbol)
          iUpdate_Inhalt		= #True
          iUpdate_Position	= #True
        Else
          
          iUpdate_Inhalt		= #False
          
          If (iX_Pos <> \_iBallon_Info_letzte_X_Pos) Or (iY_Pos <> \_iBallon_Info_letzte_Y_Pos)
            iUpdate_Position	= #True
          Else
            iUpdate_Position	= #False
          EndIf
          
        EndIf
        
        ; aktuelle Daten speichern
        \_sBallon_Info_letzter_Text 	= sText
        \_sBallon_Info_letzter_Titel 	= sTitle
        \_sBallon_Info_letztes_Symbol 	= sIcon
        \_iBallon_Info_letzte_X_Pos.i	= iX_Pos
        \_iBallon_Info_letzte_Y_Pos.i	= iY_Pos
        
      EndIf
      
    EndWith
    
    
    ; Tooltip-Inhalt übernehmen
    If iUpdate_Inhalt = #True
      
      SendMessage_	(iTooltip_ID,	#TTM_SETTIPTEXTCOLOR,	GetSysColor_(#COLOR_INFOTEXT),	0)
      SendMessage_	(iTooltip_ID,	#TTM_SETTIPBKCOLOR,		GetSysColor_(#COLOR_INFOBK),	0)
      SendMessage_	(iTooltip_ID,	#TTM_SETMAXTIPWIDTH,	0, iMax_Width)	
      SendMessage_	(iTooltip_ID,	#TTM_SETTITLE, 			iIcon, @sTitle)
      
      GetWindowRect_	(iWindowID, 	@Parameter\rect)
      SendMessage_	(iTooltip_ID, 	#TTM_ADDTOOL, 		0, @Parameter)
      SendMessage_	(iTooltip_ID, 	#TTM_TRACKACTIVATE, 1, @Parameter)
      SendMessage_	(iTooltip_ID,	#TTM_UPDATETIPTEXT, 0, @Parameter)		
      
    EndIf
    
    
    If iUpdate_Position = #True
      SendMessage_	(iTooltip_ID,	#TTM_TRACKPOSITION, 	0, lPosition)
    EndIf
    
    
    ; die Tooltip-ID zurückgeben
    ProcedureReturn iTooltip_ID
    
  EndProcedure
  
  
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_zeige_Kontextmenue
  ;
  ; Beschreibung ..:  öffnet das Kontextmenü der CustomStatusBar
  ;
  ; Syntax.........:  _zeige_Kontextmenue (iCustomStatusBar_ID.i)
  ;
  ; Parameter .....: 	iCustomStatusBar_ID.i 			- die ID der CustomStatusBar
  ;												
  ; Rückgabewerte .:	Erfolg 						|  0: Prozedur erfolgreich beendet
  ;
  ;                  	Fehler 						| -1: die CustomStatusBar existiert nicht (die ID ist ungültig)
  ;												| -2: die CustomStatusBar existiert nicht (die CustomStatusBar wurde nicht gefunden)
  ;												| -3: das Kontextmenü wurde deaktiviert
  ;												| -4: das Kontextmenü konnte nicht erstellt werden
  ;
  ; Bemerkungen ...:	die Prozedur sammelt die Kontextmenü-Parameter aller Elemente der CustomStatusBar. Diese werden anschließend in Haupt- und Nebenkategorien gruppiert
  ;					und anschließend sortiert. Danach wird das Kontextmenü angezeigt, in dem der Anwender einen Menüpunkt auswählen kann. Dieses löst anschließend ein Event
  ;					aus, das weiter verarbeitet werden kann.
  ;
  ;					Wichtig: Während das Kontextmenü angezeigt wird, pausiert die Prozedur. Sie wird fortgesetzt, sobald das Kontextmenü geschlossen wurde.
  ;
  ;} ========
  Procedure.i _zeige_Kontextmenue (iCustomStatusBar_ID.i)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iCustomStatusBar_ID > ArraySize (CustomStatusBar()):											ProcedureReturn -1:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If IsGadget (CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iID_Container_Gadget_Bereich) = 0:	ProcedureReturn -2:		EndIf	; Abbrechen, wenn die CustomStatusBar nicht existiert
    If CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iKontextmenue_Aktiviert = #False:			ProcedureReturn -3:		EndIf     ; Abbrechen, wenn das Kontextmenü deaktiviert ist
    
    
    ; lokale Variablen deklarieren und initialisieren	
    Structure Eintrag											; Struktur für die dynamischen Listen, um die Sortierung zu vereinfachen
      iElement_ID.i                       ; Element ID, auf die beim Erstellen eines Eintrags im Kontextmenü referenziert wird
      sMenu_Item.s                    ; der Text-Eintrag des gewählten Elements
      sMenue_Hauptkategorie.s             ; die Hauptkategorie des gewählten Elements
      sMenue_Nebenkategorie.s             ; die Nebenkategorie des gewählten Elements
    EndStructure
    
    Protected NewList Hauptkategorie.Eintrag()					; erste Liste: zum Sortieren der Hauptkategorien
    Protected NewList Nebenkategorie.Eintrag()          ; zweite Liste: zum Sortieren der Nebenkategorien
    Protected NewList Eintraege.Eintrag()               ; dritte Liste: zum Sortieren der Einträge
    
    Protected iCounter.i								= 0		; allgemeiner Zähler für Schleifen
    Protected iPopup_Menue_ID.i							= 0		; Gadget-Nummer des Kontextmenüs
    
    Protected iMenue_ID.i								= 0		; zugewiesene ID des aktuellen Eintrags im Kontextmenü (MenuItem-ID)
    Protected iMenue_Symbol.i							= 0 ; Image: darzustellendes Symbol für den Menüeintrag
    Protected sMenu_Item.s							= ""	; Text des Menüeintrags
    Protected sMenue_Hauptkategorie.s					= ""; die Hauptkategorie des Menüeintrags
    Protected sMenue_Nebenkategorie.s					= ""; die Nebenkategorie des Menüeintrags
    
    Protected sAktuelle_Hauptkategorie.s				= ""	; aktuelle Hauptkategorie, die in den Listen verarbeitet wird
    Protected sAktuelle_Nebenkategorie.s				= ""  ; aktuelle Nebenkategorie, die in den Listen verarbeitet wird
    
    Protected iKontextmenue_Element_ID.i				= 0		; Element ID, auf die beim Erstellen eines Eintrags im Kontextmenü referenziert wird
    
    Protected iField.i									= _pruefe_Mausposition (iCustomStatusBar_ID)
    Protected iMax_Anzahl_Fielder.i						= CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMax_Elements_visible
    Protected iKontextmenu_ID_Start.i					= CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iMenueItem_Start
    Protected iKontextmenu_ID_Reserviert.i				= CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iMenueItem_Reserviert
    Protected iKontextmenu_ID_Reserviert_erweitert.i	= CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iMenueItem_Reserviert_erweitert
    
    Protected iAnzahl_belegte_Fielder.i					= 0
    Protected iElement_ID.i								= 0
    
    Protected iMerker_MenuBar.i							= 0
    
    
    ; Popup-Menü erstellen
    iPopup_Menue_ID = CreatePopupImageMenu(#PB_Any)
    
    
    ; Prozedur bei einem Fehler abbrechen
    If iPopup_Menue_ID = 0:	ProcedureReturn -4:		EndIf	; Abbrechen, das Menü nicht erstellt werden konnte
    
    
    ; die Überschrift zum Kontextmenü hinzufügen
    If CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iHeadline_anzeigen	= #True
      
      ; die Menü-ID berechnen
      iMenue_ID = iKontextmenu_ID_Start + 1 + ((iKontextmenu_ID_Reserviert_erweitert + iKontextmenu_ID_Reserviert) * iCustomStatusBar_ID) - iKontextmenu_ID_Reserviert_erweitert
      
      
      ; nur die Überschrift hinzufügen, wenn das aktuelle Field existiert
      If iField > 0
        
        
        ; Parameter laden
        iElement_ID		= CustomStatusBar(iCustomStatusBar_ID)\Field(iField)\_iElement_ID
        sMenu_Item	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_sKontext_Menue_Eintrag
        iMenue_Symbol	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Kontextmenue\_iKontext_Menue_Eintrag_Symbol
        
        
        ; prüfen, ob ein Symbol angezeigt werden darf
        If CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iHeadline_Symbol_erlauben = #False
          iMenue_Symbol = 0
        EndIf
        
        
        ; Eintrag hinzufügen, sofern auch einer angegeben wurde
        If sMenu_Item <> ""
          
          CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iHeadline_Menue_ID = iMenue_ID
          
          If IsImage(iMenue_Symbol) <> 0
            MenuItem(iMenue_ID, sMenu_Item, ImageID(iMenue_Symbol))
            MenuBar()
          Else
            MenuItem(iMenue_ID, sMenu_Item)
            MenuBar()			
          EndIf
          
        EndIf
        
      EndIf
      
    EndIf
    
    
    ; die Erstellung eines Separators verhindern (notwendig für die korrekte Darstellung, wenn noch keine Einträge vorhanden sind)
    iMerker_MenuBar = 1
    
    
    ; Alle Einträge für das Kontextmenü sammeln und in die erste Liste hinzufügen
    For iCounter = 1 To ArraySize (CustomStatusBar(iCustomStatusBar_ID)\Element()) Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\_iBelegt = #True
        
        AddElement (Hauptkategorie())
        
        Hauptkategorie()\iElement_ID			= iCounter
        Hauptkategorie()\sMenu_Item			= CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\Kontextmenue\_sKontext_Menue_Eintrag
        Hauptkategorie()\sMenue_Hauptkategorie	= CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\Kontextmenue\_sKontext_Menue_Hauptkategorie
        Hauptkategorie()\sMenue_Nebenkategorie	= CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\Kontextmenue\_sKontext_Menue_Nebenkategorie
        
      EndIf
      
    Next
    
    
    ; die erste Liste nach Namen aufsteigend sortieren (Hauptkategorie)
    SortStructuredList (Hauptkategorie(), #PB_Sort_NoCase, OffsetOf(Eintrag\sMenue_Hauptkategorie), TypeOf(Eintrag\sMenue_Hauptkategorie))
    
    
    ; die Schleife so oft wiederholen, bis alle Einträge in der ersten Liste verarbeitet wurden sind
    While ListSize(Hauptkategorie()) > 0
      
      
      ; Wählt eine Hauptkategorie aus, die als nächstes verarbeitet wird. Einträge ohne Hauptkategorie werden übersprungen und zuletzt verarbeitet.
      ForEach Hauptkategorie()	
        If Hauptkategorie()\sMenue_Hauptkategorie <> ""
          sAktuelle_Hauptkategorie = Hauptkategorie()\sMenue_Hauptkategorie
          OpenSubMenu(sAktuelle_Hauptkategorie)	; erstellt im Kontextmenü ein Sub-Menü für die Hauptkategorie
          Break
        Else
          sAktuelle_Hauptkategorie = ""
        EndIf
      Next 
      
      
      ; verschiebt alle Einträge in die zweite Liste, die sich in der aktuell ausgewählten Hauptkategorie befinden
      ForEach Hauptkategorie()
        If Hauptkategorie()\sMenue_Hauptkategorie = sAktuelle_Hauptkategorie
          AddElement(Nebenkategorie())
          Nebenkategorie() = Hauptkategorie()
          DeleteElement(Hauptkategorie())
        EndIf
      Next
      
      
      ; die zweite Liste nach Namen aufsteigend sortieren (Nebenkategorie)
      SortStructuredList (Nebenkategorie(), #PB_Sort_NoCase, OffsetOf(Eintrag\sMenue_Nebenkategorie), TypeOf(Eintrag\sMenue_Nebenkategorie))
      
      
      ; die Schleife so oft wiederholen, bis alle Einträge in der zweiten Liste verarbeitet wurden sind
      While ListSize(Nebenkategorie()) > 0
        
        
        ; Wählt eine Nebenkategorie aus, die als nächstes verarbeitet wird. Einträge ohne Nebenkategorie werden übersprungen und zuletzt verarbeitet.
        ForEach Nebenkategorie()
          If Nebenkategorie()\sMenue_Nebenkategorie <> ""
            sAktuelle_Nebenkategorie = Nebenkategorie()\sMenue_Nebenkategorie
            OpenSubMenu(sAktuelle_Nebenkategorie)	; erstellt im Kontextmenü ein weiteres Sub-Menü für die Nebenkategorie
            Break
          Else
            sAktuelle_Nebenkategorie = ""
          EndIf
        Next 
        
        
        ; verschiebt alle Einträge in die dritte Liste, die sich in der aktuell ausgewählten Nebenkategorie befinden
        ForEach Nebenkategorie()
          If Nebenkategorie()\sMenue_Nebenkategorie = sAktuelle_Nebenkategorie
            AddElement(Eintraege())
            Eintraege() = Nebenkategorie()
            DeleteElement(Nebenkategorie())
          EndIf
        Next
        
        
        ; die dritte Liste nach Namen aufsteigend sortieren (Menüeinträge)
        SortStructuredList (Eintraege(), #PB_Sort_NoCase, OffsetOf(Eintrag\sMenu_Item), TypeOf(Eintrag\sMenu_Item))
        
        
        ; die Schleife so oft wiederholen, bis alle Einträge in der dritten Liste verarbeitet wurden sind
        While ListSize(Eintraege()) > 0
          
          
          ; fügt die Einträge in das aktuelle Kontextmenü hinzu
          ForEach Eintraege()
            
            
            ; Parameter laden
            iKontextmenue_Element_ID	= Eintraege()\iElement_ID
            
            iMenue_ID					= CustomStatusBar(iCustomStatusBar_ID)\Element(iKontextmenue_Element_ID)\Kontextmenue\_iKontext_Menue_ID
            iMenue_Symbol				= CustomStatusBar(iCustomStatusBar_ID)\Element(iKontextmenue_Element_ID)\Kontextmenue\_iKontext_Menue_Eintrag_Symbol
            sMenu_Item				= CustomStatusBar(iCustomStatusBar_ID)\Element(iKontextmenue_Element_ID)\Kontextmenue\_sKontext_Menue_Eintrag
            sMenue_Hauptkategorie		= CustomStatusBar(iCustomStatusBar_ID)\Element(iKontextmenue_Element_ID)\Kontextmenue\_sKontext_Menue_Hauptkategorie
            sMenue_Nebenkategorie		= CustomStatusBar(iCustomStatusBar_ID)\Element(iKontextmenue_Element_ID)\Kontextmenue\_sKontext_Menue_Nebenkategorie
            
            
            ; Eintrag hinzufügen, sofern auch einer angegeben wurde
            If sMenu_Item <> ""
              
              If IsImage(iMenue_Symbol) <> 0
                MenuItem(iMenue_ID, sMenu_Item, ImageID(iMenue_Symbol))
              Else
                MenuItem(iMenue_ID, sMenu_Item)
              EndIf
              
              ; die Erstellung eines Separators erlauben
              iMerker_MenuBar = 0
              
            EndIf
            
            
            ; den verarbeiteten Eintrag aus der dritten Liste löschen
            DeleteElement(Eintraege())
            
          Next
          
        Wend	; Ende der Verarbeitung der dritten Liste 
        
        
        ; das SubSub-Menü im Kontextmenü schließen, sofern eines geöffnet wurde
        If sAktuelle_Nebenkategorie <> "" 
          CloseSubMenu()
        EndIf
        
        
      Wend	; Ende der Verarbeitung der zweiten Liste
      
      
      ; das Sub-Menü im Kontextmenü schließen, sofern eines geöffnet wurde
      If sAktuelle_Hauptkategorie <> "" 
        CloseSubMenu()
      EndIf
      
      
    Wend	; Ende der Verarbeitung der ersten Liste
    
    
    ; die Anzahl der belegten Fielder ermitteln
    iAnzahl_belegte_Fielder = 0
    
    For iCounter = 1 To iMax_Anzahl_Fielder Step 1
      
      If CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #True
        iAnzahl_belegte_Fielder + 1
      EndIf
      
    Next
    
    
    ; Kontextmenüeintrag "Eintrag hinzufügen" hinzufügen
    If CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_sEintrag_Fielder_erstellen_Text <> ""
      
      ; Parameter laden und Menü-ID berechnen
      iMenue_ID			= iKontextmenu_ID_Start + 2 + ((iKontextmenu_ID_Reserviert_erweitert + iKontextmenu_ID_Reserviert) * iCustomStatusBar_ID) - iKontextmenu_ID_Reserviert_erweitert
      sMenu_Item		= CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_sEintrag_Fielder_erstellen_Text
      iMenue_Symbol		= CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iItem_Field_erstellen_Symbol
      
      
      ; prüfen, ob ein Separator erstellt werden soll
      If iMerker_MenuBar = 0
        MenuBar()
        iMerker_MenuBar = 1
      EndIf
      
      
      ; Einstellungen speichern
      CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iItem_Field_erstellen_Menue_ID = iMenue_ID
      
      
      ; Eintrag hinzufügen (ggf. mit Symbol)
      If IsImage(iMenue_Symbol) <> 0
        MenuItem(iMenue_ID, sMenu_Item, ImageID(iMenue_Symbol))
      Else
        MenuItem(iMenue_ID, sMenu_Item)
      EndIf
      
      
      ; Menüeintrag deaktivieren, wenn die Grenze der maximalen Fielder erreicht wurde
      If iAnzahl_belegte_Fielder >= iMax_Anzahl_Fielder
        DisableMenuItem(iPopup_Menue_ID, iMenue_ID, #True)
      Else
        DisableMenuItem(iPopup_Menue_ID, iMenue_ID, #False)
      EndIf
      
    EndIf
    
    
    ; Kontextmenüeintrag: "diesen Eintrag entfernen"
    If CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_sEintrag_Fielder_entfernen_Text <> ""
      
      ; Parameter laden und Menü-ID berechnen
      iMenue_ID			= iKontextmenu_ID_Start + 3 + ((iKontextmenu_ID_Reserviert_erweitert + iKontextmenu_ID_Reserviert) * iCustomStatusBar_ID) - iKontextmenu_ID_Reserviert_erweitert
      sMenu_Item		= CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_sEintrag_Fielder_entfernen_Text
      iMenue_Symbol		= CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iItem_Field_entfernen_Symbol
      
      
      ; prüfen, ob ein Separator erstellt werden soll
      If iMerker_MenuBar = 0
        MenuBar()
        iMerker_MenuBar = 1
      EndIf
      
      
      ; Einstellungen speichern
      CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iItem_Field_entfernen_Menue_ID = iMenue_ID
      
      
      ; Eintrag hinzufügen (ggf. mit Symbol)
      If IsImage(iMenue_Symbol) <> 0
        MenuItem(iMenue_ID, sMenu_Item, ImageID(iMenue_Symbol))
      Else
        MenuItem(iMenue_ID, sMenu_Item)
      EndIf
      
      
      ; Menüeintrag deaktivieren, wenn die Grenze der maximalen Fielder erreicht wurde
      If (iAnzahl_belegte_Fielder) <= 0 Or (iField <= 0)
        DisableMenuItem(iPopup_Menue_ID, iMenue_ID, #True)
      Else
        DisableMenuItem(iPopup_Menue_ID, iMenue_ID, #False)
      EndIf
      
    EndIf
    
    
    ; Kontextmenü darstellen (erzeugt ein Menu-Event, wenn ein Eintrag gewählt wurde)
    DisplayPopupMenu(iPopup_Menue_ID, WindowID(CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iWindow))
    
    
    ; Ressourcen wieder freigeben
    FreeMenu(iPopup_Menue_ID)
    FreeList(Hauptkategorie())
    FreeList(Nebenkategorie())
    FreeList(Eintraege())
    
    
    ; Funktion erfolgreich beendet
    ProcedureReturn 0
    
  EndProcedure
  
  
  
  ;-
  ;-
  ;-
  ;- BindEvents
  ;- -----------------------------------------------------------------------------
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_Autoresize
  ;
  ; Beschreibung ..:  BindEvent: ermöglicht die automatische Anpassung der CustomStatusBar bei einer Größenveränderung der GUI
  ;
  ; Syntax.........:  _Autoresize()
  ;
  ; Parameter .....: 	
  ;												
  ; Rückgabewerte .:	
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i _Autoresize()
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iCustomStatusBar_ID.i = 0
    
    
    ; CustomStatusBarn aktualisieren
    For iCustomStatusBar_ID = 1 To ArraySize(CustomStatusBar())
      
      If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iAutoresize_Aktiviert = #True 
        
        _CustomStatusBar_groesse_automatisch_anpassen (iCustomStatusBar_ID)
        
      EndIf
      
    Next
    
  EndProcedure
  
  
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_Element_Aktualisierung
  ;
  ; Beschreibung ..:  BindEvent: prüft, ob ein Gadget im Field der CustomStatusBar geändert wurde und synchronisiert anschließend die Elemente der CustomStatusBar
  ;
  ; Syntax.........:  _Element_Aktualisierung()
  ;
  ; Parameter .....: 	
  ;												
  ; Rückgabewerte .:	
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i _Element_Aktualisierung()
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iEventGadget.i 		= EventGadget()
    Protected iCustomStatusBar_ID.i		= 0
    Protected iGadget_ID.i 			= 0	
    Protected iIP_Adresse.i 		= 0
    Protected iEvent_Typ.i			= 0
    Protected iCounter.i			= 0
    Protected iElement_ID.i			= 0
    Protected sElement_Typ.s 		= ""
    
    Protected iMaus_X_Pos.i 		= 0
    Protected iMaus_Y_Pos.i			= 0
    Protected iMaus_X_Richtung.i	= 0
    Protected iMaus_Y_Richtung.i	= 0
    
    Protected iFenster_X_Pos.i		= 0
    Protected iFenster_Y_Pos.i		= 0	
    Protected iFenster_Breite.i		= 0
    Protected iFenster_Hoehe.i		= 0
    
    Protected iFenster_Breite_neu.i	= 0
    Protected iFenster_Hoehe_neu.i	= 0
    
    
    ; alle CustomStatusBarn verarbeiten
    For iCustomStatusBar_ID = 1 To ArraySize(CustomStatusBar())
      
      
      ; Fenstergröße über SizeBox anpassen
      With CustomStatusBar(iCustomStatusBar_ID)\Allgemein
        
        If EventGadget() = \_iID_SizeBox
          
          If GetGadgetAttribute(\_iID_SizeBox, #PB_Canvas_Buttons) = #PB_Canvas_LeftButton
            
            ; Fensterparameter bestimmen
            iFenster_X_Pos	= WindowX (\_iWindow)
            iFenster_Y_Pos	= WindowY (\_iWindow)
            iFenster_Breite	= WindowWidth	(\_iWindow, #PB_Window_InnerCoordinate)
            iFenster_Hoehe	= WindowHeight	(\_iWindow, #PB_Window_InnerCoordinate)
            iMaus_X_Pos		= DesktopMouseX()
            iMaus_Y_Pos		= DesktopMouseY()
            
            ; neue Fenster-Abmessungen berechnen
            iFenster_Breite_neu	= iFenster_Breite	+ iMaus_X_Pos - \_iSizeBox_Maus_X
            iFenster_Hoehe_neu	= iFenster_Hoehe	+ iMaus_Y_Pos - \_iSizeBox_Maus_Y
            
            ; ermitteln, in welche Richtung die Maus bewegt wurde
            iMaus_X_Richtung = iMaus_X_Pos - \_iSizeBox_Maus_X
            iMaus_Y_Richtung = iMaus_Y_Pos - \_iSizeBox_Maus_Y
            
            ; Mausposition speichern
            \_iSizeBox_Maus_X  = iMaus_X_Pos
            \_iSizeBox_Maus_Y  = iMaus_Y_Pos
            
            ; Fenstergröße anpassen
            If EventType() = #PB_EventType_MouseMove
              
              
              If (iMaus_X_Pos < (iFenster_X_Pos + iFenster_Breite)) And (iMaus_X_Richtung > 0)
                iFenster_Breite_neu = #PB_Ignore
              EndIf
              
              If (iMaus_Y_Pos < (iFenster_Y_Pos + iFenster_Hoehe)) And (iMaus_Y_Richtung > 0)
                iFenster_Hoehe_neu = #PB_Ignore
              EndIf
              
              ResizeWindow(\_iWindow, #PB_Ignore, #PB_Ignore, iFenster_Breite_neu, iFenster_Hoehe_neu)
              
            EndIf
            
          EndIf
        EndIf
        
      EndWith
      
      
      ; alle Fielder einlesen und die Parameter speichern
      For iCounter = 1 To CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMax_Elements_visible Step 1
        
        ; Parameter laden
        iGadget_ID 	= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iGadget_ID
        iElement_ID	= CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iElement_ID
        sElement_Typ = CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\_sElement_Typ
        iEvent_Typ	= EventType()
        
        
        ; aktuelles Field abbrechen, wenn das Gasget ungültig ist
        If IsGadget(iGadget_ID) = 0 Or CustomStatusBar(iCustomStatusBar_ID)\Field(iCounter)\_iBelegt = #False
          Break
        EndIf
        
        
        ; das Gadget suchen, das ein Event ausgelöst hat
        If iEventGadget = iGadget_ID
          
          
          ; Gadget-Typ selektieren
          Select sElement_Typ
              
            Case "ButtonElement"
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iStatus 				= GetGadgetState(iGadget_ID)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonGadget\_iUpdate_Flag			= #True
              
              
            Case "ButtonImageElement"
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iStatus 			= GetGadgetState(iGadget_ID)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ButtonImageGadget\_iUpdate_Flag		= #True
              
              
            Case "CanvasElement"
              ; nichts zum Einlesen
              
              
            Case "CheckBoxElement"
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iStatus 			= GetGadgetState(iGadget_ID)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\CheckBoxGadget\_iUpdate_Flag		= #True
              
              
            Case "ComboBoxElement"
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iStatus 			= GetGadgetState(iGadget_ID)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_sText 				= GetGadgetText(iGadget_ID)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Flag		= #True						
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ComboBoxGadget\_iUpdate_Text		= #True						
              
              
            Case "DateElement"
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iDate 					= GetGadgetState(iGadget_ID)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\DateGadget\_iUpdate_Flag			= #True
              
              
            Case "ExplorerComboElement"
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_sDirectory 	= GetGadgetText(iGadget_ID)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ExplorerComboGadget\_iUpdate_Flag	= #True
              
              
            Case "HyperLinkElement"
              ; nichts zum Einlesen
              
              
            Case "IPAddressElement"
              iIP_Adresse = GetGadgetState(iGadget_ID) 
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_1			= IPAddressField(iIP_Adresse, 0)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_2			= IPAddressField(iIP_Adresse, 1)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_3			= IPAddressField(iIP_Adresse, 2)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iIP_Field_4			= IPAddressField(iIP_Adresse, 3)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\IPAddressGadget\_iUpdate_Flag		= #True
              
              
            Case "ProgressBarElement"
              ; nichts zum Einlesen
              
              
            Case "ScrollBarElement"
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iValue 				= GetGadgetState(iGadget_ID)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ScrollBarGadget\_iUpdate_Flag		= #True
              
              
            Case "ShortcutElement"
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iShortcutKey 		= GetGadgetState(iGadget_ID)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\ShortcutGadget\_iUpdate_Flag		= #True
              
            Case "SpinElement"
              
              If (iEvent_Typ = #PB_EventType_Up)
                CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iValue + 1
                
              ElseIf (iEvent_Typ = #PB_EventType_Down)
                CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iValue - 1	
                
              ElseIf iEvent_Typ = #PB_EventType_Change 
                CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iValue 				= Val(GetGadgetText(iGadget_ID))
                CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_sText 				= GetGadgetText(iGadget_ID)
                
              EndIf
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iUpdate_Flag		= #True
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\SpinGadget\_iEvent_Typ			= iEvent_Typ							
              
              
            Case "StringElement"
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_sValue 				= GetGadgetText(iGadget_ID)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\StringGadget\_iUpdate_Flag			= #True
              
              
            Case "TextElement"
              ; nichts zum Einlesen
              
              
            Case "TrackBarElement"
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iValue 				= GetGadgetState(iGadget_ID)
              CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\TrackBarGadget\_iUpdate_Flag		= #True						
              
          EndSelect
          
        EndIf
        
      Next
      
    Next
    
  EndProcedure
  
  
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_Menue_Event
  ;
  ; Beschreibung ..:  BindEvent: prüft, ob ein Eintrag im Kontextmenü ausgewählt wurde und führt diesen anschließend aus
  ;
  ; Syntax.........:  _Menue_Event()
  ;
  ; Parameter .....: 	
  ;												
  ; Rückgabewerte .:	
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i _Menue_Event()
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iMenueEvent.i				= EventMenu()
    Protected iMax_Anzahl_Elemente.i 	= 0
    Protected iCustomStatusBar_ID.i			= 0
    Protected iCounter.i				= 0
    
    
    ; prüfen, welcher Menüeintrag im Kontextmenü ausgewählt wurde
    For iCustomStatusBar_ID = 1 To ArraySize(CustomStatusBar())
      
      iMax_Anzahl_Elemente = ArraySize(CustomStatusBar(iCustomStatusBar_ID)\Element())
      
      
      Select iMenueEvent
          
          ; Eintrag: "Eintrag hinzufügen"
        Case CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iItem_Field_erstellen_Menue_ID
          
          SetField (iCustomStatusBar_ID, 0, 1)
          _Fielder_sortieren (iCustomStatusBar_ID)
          
          
          ; Eintrag: "diesen Eintrag entfernen"
        Case CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iItem_Field_entfernen_Menue_ID    
          
          SetField (iCustomStatusBar_ID, CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMerker_letzter_Klick, -1)
          _Fielder_sortieren (iCustomStatusBar_ID)
          
          CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMerker_letzter_Klick = 0
          
          
          ; sonstiger Menüeintrag
        Default
          
          If iMenueEvent >= (CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iMenueItem_Start + CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iMenueItem_Reserviert_erweitert)
            
            For iCounter = 1 To iMax_Anzahl_Elemente Step 1
              
              If CustomStatusBar(iCustomStatusBar_ID)\Element(iCounter)\Kontextmenue\_iKontext_Menue_ID = EventMenu()
                _Fielder_sortieren (iCustomStatusBar_ID)
                SetField (iCustomStatusBar_ID, CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMerker_letzter_Klick, iCounter)
                Break
              EndIf
              
            Next
            
          EndIf
          
      EndSelect
      
    Next
    
  EndProcedure
  
  
  
  ;{ #PRIVATE# ;======
  ;
  ; Name...........:	_Timer_Event
  ;
  ; Beschreibung ..:  BindEvent: aktualisiert periodisch die Tooltips und das Kontextmenü
  ;
  ; Syntax.........:  _Timer_Event()
  ;
  ; Parameter .....: 	
  ;												
  ; Rückgabewerte .:	
  ;
  ; Bemerkungen ...:	
  ;
  ;} ========
  Procedure.i _Timer_Event()
    
    
    ; lokale Variablen deklarieren und initialisieren
    Protected iEvent_Timer.i			= EventTimer()
    Protected iCustomStatusBar_ID.i			= 0
    
    Protected iBallon_Field.i			= 0
    Protected iElement_ID.i				= 0
    Protected iBallon_Anzeigedauer.i	= 0
    
    Protected iField.i 					= 0
    Protected sKlick.s					= ""
    
    Protected sTooltip_Text.s			= ""
    Protected sTooltip_Titel.s			= ""
    Protected sTooltip_Symbol.s			= ""
    
    
    ; prüfen, auf welcher CustomStatusBar ein Timer-Event stattgefunden hat
    For iCustomStatusBar_ID = 1 To ArraySize(CustomStatusBar())
      
      iField 	= _pruefe_Mausposition (iCustomStatusBar_ID)		
      sKlick 	= _pruefe_Mausaktion()
      
      Select iEvent_Timer
          
          
          ; Timer: Fielder in der CustomStatusBar aktualisieren
        Case CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iCustomStatusBar_Timer_ID
          
          _Fielder_aktualisieren(iCustomStatusBar_ID)
          
          
          ; Timer: Tooltips und Ballon-Tipps aktualisieren
        Case CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Timer_ID
          
          
          ; wenn der Ballon-Tipp gerade angezeigt wird...
          If CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_auf_Field <> 0
            
            iBallon_Field 			= CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_auf_Field
            iElement_ID				= CustomStatusBar(iCustomStatusBar_ID)\Field(iBallon_Field)\_iElement_ID
            iBallon_Anzeigedauer	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Ballon_Info\_iDisplayTime
            
            
            ; einmalig einen Zeitstempel setzen
            If CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_Timer_merker = 0
              CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_Timer_merker = ElapsedMilliseconds()
            EndIf
            
            
            ; Ballon-Tipp schließen, wenn die max. Anzeigedauer überschritten wurde
            If (ElapsedMilliseconds() - CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_Timer_merker) >= iBallon_Anzeigedauer
              CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_auf_Field 	= 0
              CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_Timer_merker	= 0
              _Tooltip(iCustomStatusBar_ID, "", "", "none", #PB_Default, #PB_Default, #PB_Default, #True, #True)
            Else
              ShowBallonTip(iCustomStatusBar_ID, iElement_ID, #False)
            EndIf
            
          Else
            CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iBallon_Info_Timer_merker = 0
          EndIf
          
          
          ; wenn gerade ein Tooltip angezeigt wird...
          If iField >= 0
            
            ; ggf. ein Tooltip anzeigen oder aktualisieren
            If (ElapsedMilliseconds() - CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Timer_merker) >= CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iToolTip_Delay And CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Aktiviert = #True 
              
              iElement_ID		= CustomStatusBar(iCustomStatusBar_ID)\Field(iField)\_iElement_ID
              sTooltip_Text	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Tooltip\_sText
              sTooltip_Titel	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Tooltip\_sTitle
              sTooltip_Symbol	= CustomStatusBar(iCustomStatusBar_ID)\Element(iElement_ID)\Tooltip\_sIcon
              
              _Tooltip(iCustomStatusBar_ID, sTooltip_Text, sTooltip_Titel, sTooltip_Symbol)
              
            Else
              
              ; Timer zurücksetzen, wenn die Maus nicht min. 500ms über eine Field verweilt
              If CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMerker_letztes_Field <> iField
                CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMerker_letztes_Field = iField
                CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Timer_merker = ElapsedMilliseconds()
              EndIf
              
            EndIf
            
          Else
            CustomStatusBar(iCustomStatusBar_ID)\Tooltips\_iTooltip_Timer_merker = ElapsedMilliseconds()
            _Tooltip(iCustomStatusBar_ID, "")
          EndIf
          
          
          ; Timer: prüfen, ob das Kontextmenü geöffnet werden soll
        Case CustomStatusBar(iCustomStatusBar_ID)\Kontextmenue\_iKontextmenue_Timer_ID
          
          ; bei einem Rechtsklick das Kontextmenü öffnen
          If (iField >= 0) And (sKlick = "rechts")
            CustomStatusBar(iCustomStatusBar_ID)\Allgemein\_iMerker_letzter_Klick = iField
            _Tooltip(iCustomStatusBar_ID, "")
            _zeige_Kontextmenue (iCustomStatusBar_ID)
            
          EndIf
          
      EndSelect
      
    Next
    
  EndProcedure
  
  
  
  ;  ############################################################################################################################################################################################
  ;  #######################################################################################     MISC     #######################################################################################
  ;  ############################################################################################################################################################################################
  ;-
  ;-
  ;-
  ;- ################### MISC ########################
  ;-
  ;- Binärdaten inkludieren
  ;- -----------------------------------------------------------------------------
  
  
  DataSection
    
    Icon_neu:			; 16x16 - Symbol (.ico): "Eintrag hinzufügen"
    Data.b $00, $00, $01, $00, $01, $00, $10, $10, $00, $00, $01, $00, $20, $00, $68, $04, $00, $00, $16, $00, $00, $00, $28, $00, $00, $00, $10, $00, $00, $00
    Data.b $20, $00, $00, $00, $01, $00, $20, $00, $00, $00, $00, $00, $40, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $13, $13, $13, $10, $64, $64, $63, $75
    Data.b $83, $82, $82, $95, $83, $83, $82, $95, $68, $68, $67, $79, $18, $18, $18, $14, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0C, $0C, $0C, $01, $A9, $A8, $A8, $BC
    Data.b $B7, $D0, $C3, $FF, $90, $BD, $A7, $FF, $90, $BD, $A7, $FF, $B3, $CE, $C0, $FF, $B5, $B4, $B3, $C8, $13, $13, $13, $02, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $0E
    Data.b $E8, $E8, $E7, $FD, $2D, $92, $63, $FF, $26, $8F, $5D, $FF, $26, $8F, $5D, $FF, $28, $90, $5F, $FF, $E4, $E6, $E4, $FE, $31, $31, $31, $1A, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $2B, $2B, $2B, $13, $E9, $EA, $E8, $FF, $27, $97, $63, $FF, $26, $96, $62, $FF, $26, $96, $62, $FF, $25, $96, $62, $FF, $E1, $E6, $E3, $FF, $3D, $3D
    Data.b $3C, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $04, $04, $01, $04, $04, $04, $08
    Data.b $05, $05, $05, $09, $22, $22, $22, $1B, $EB, $EB, $EA, $FF, $27, $9E, $69, $FF, $26, $9E, $68, $FF, $26, $9E, $68, $FF, $25, $9E, $67, $FF, $E2, $E8
    Data.b $E4, $FF, $32, $32, $32, $28, $05, $05, $05, $09, $04, $04, $04, $08, $05, $05, $05, $01, $00, $00, $00, $00, $19, $19, $19, $12, $9B, $9B, $9B, $AF
    Data.b $D7, $D6, $D6, $EA, $DA, $DA, $D9, $ED, $DB, $DB, $DA, $EE, $ED, $ED, $EC, $FF, $27, $A6, $6E, $FF, $26, $A6, $6D, $FF, $26, $A6, $6D, $FF, $25, $A5
    Data.b $6D, $FF, $E4, $EA, $E6, $FF, $DC, $DC, $DB, $EE, $DA, $DA, $D9, $ED, $D8, $D7, $D6, $EA, $A1, $A1, $A0, $B6, $23, $23, $22, $18, $8C, $8C, $8B, $88
    Data.b $B5, $DC, $CB, $FF, $48, $B9, $87, $FF, $45, $B8, $85, $FF, $45, $B8, $85, $FF, $44, $B8, $85, $FF, $26, $AD, $72, $FF, $26, $AD, $72, $FF, $26, $AD
    Data.b $72, $FF, $25, $AD, $72, $FF, $43, $B7, $84, $FF, $45, $B8, $85, $FF, $45, $B8, $85, $FF, $47, $B8, $87, $FF, $AD, $DA, $C6, $FF, $99, $98, $98, $94
    Data.b $C3, $C3, $C2, $B4, $76, $CD, $A7, $FF, $26, $B5, $77, $FF, $26, $B5, $77, $FF, $26, $B5, $77, $FF, $26, $B5, $77, $FF, $26, $B5, $77, $FF, $26, $B5
    Data.b $77, $FF, $26, $B5, $77, $FF, $26, $B5, $77, $FF, $26, $B5, $77, $FF, $26, $B5, $77, $FF, $26, $B5, $77, $FF, $26, $B5, $77, $FF, $6D, $CA, $A2, $FF
    Data.b $B4, $B3, $B3, $B6, $C7, $C6, $C6, $B5, $76, $D2, $AB, $FF, $25, $BC, $7D, $FF, $25, $BC, $7D, $FF, $25, $BC, $7D, $FF, $25, $BC, $7D, $FF, $25, $BC
    Data.b $7D, $FF, $25, $BC, $7D, $FF, $25, $BC, $7D, $FF, $25, $BC, $7D, $FF, $25, $BC, $7D, $FF, $25, $BC, $7D, $FF, $25, $BC, $7D, $FF, $25, $BC, $7D, $FF
    Data.b $6D, $CF, $A6, $FF, $B5, $B5, $B5, $B6, $BC, $BC, $BC, $9F, $8C, $DA, $BB, $FF, $23, $BF, $81, $FF, $23, $BF, $81, $FF, $23, $BF, $81, $FF, $23, $BF
    Data.b $81, $FF, $23, $BF, $81, $FF, $23, $BF, $81, $FF, $23, $BF, $81, $FF, $23, $BF, $81, $FF, $23, $BF, $81, $FF, $23, $BF, $81, $FF, $23, $BF, $81, $FF
    Data.b $23, $BF, $81, $FF, $81, $D7, $B5, $FF, $BD, $BD, $BD, $A8, $86, $85, $85, $30, $EE, $EF, $EE, $EE, $CE, $ED, $E1, $FF, $CA, $EC, $DF, $FF, $CA, $EC
    Data.b $DF, $FF, $C9, $EB, $DE, $FF, $20, $C1, $86, $FF, $1F, $C1, $86, $FF, $1F, $C1, $86, $FF, $1F, $C1, $86, $FF, $C1, $EA, $DA, $FF, $CA, $EC, $DF, $FF
    Data.b $CA, $EC, $DF, $FF, $CD, $EC, $E0, $FF, $ED, $F0, $EF, $F2, $9F, $9E, $9E, $3A, $00, $00, $00, $00, $82, $82, $81, $10, $B9, $B9, $B8, $40, $C1, $C1
    Data.b $C1, $43, $A4, $A4, $A4, $52, $F7, $F9, $F8, $FF, $1D, $C4, $8B, $FF, $1C, $C3, $8B, $FF, $1C, $C3, $8B, $FF, $1B, $C3, $8A, $FF, $ED, $F6, $F3, $FF
    Data.b $A6, $A6, $A5, $5B, $C1, $C1, $C1, $43, $BA, $BA, $B9, $41, $8B, $8B, $8A, $12, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $2E, $2E, $2E, $13, $F8, $FA, $F9, $FF, $19, $C6, $90, $FF, $18, $C6, $8F, $FF, $18, $C6, $8F, $FF, $17, $C6, $8F, $FF
    Data.b $EF, $F8, $F5, $FF, $41, $41, $41, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2D, $2D, $2D, $12, $FA, $FC, $FB, $FF, $16, $C9, $95, $FF, $14, $C8, $94, $FF, $14, $C8, $94, $FF
    Data.b $14, $C8, $94, $FF, $F1, $FA, $F7, $FF, $41, $41, $41, $1F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2B, $2B, $2B, $02, $E9, $E9, $E9, $E1, $74, $E0, $C2, $FF, $3F, $D4, $AC, $FF
    Data.b $3F, $D4, $AC, $FF, $6A, $DD, $BE, $FF, $F0, $F0, $F0, $EB, $3E, $3E, $3E, $05, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $A8, $A8, $A8, $37, $F0, $F0, $F0, $C1
    Data.b $F9, $F9, $F9, $D9, $F9, $F9, $F9, $D9, $F2, $F2, $F2, $C5, $BC, $BC, $BC, $3E, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $F8, $1F, $00, $00, $F0, $0F, $00, $00, $F0, $0F, $00, $00, $F0, $0F, $00, $00, $80, $01, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $01, $00, $00, $F0, $0F, $00, $00, $F0, $0F
    Data.b $00, $00, $F0, $0F, $00, $00, $F8, $1F, $00, $00
    
    
    Icon_entfernen:		; 16x16 - Symbol (.ico): "diesen Eintrag entfernen"
    Data.b $00, $00, $01, $00, $01, $00, $10, $10, $00, $00, $01, $00, $20, $00, $68, $04, $00, $00, $16, $00, $00, $00, $28, $00, $00, $00, $10, $00, $00, $00
    Data.b $20, $00, $00, $00, $01, $00, $20, $00, $00, $00, $00, $00, $40, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $04, $04, $01, $04, $04, $04, $08
    Data.b $05, $05, $05, $09, $05, $05, $05, $09, $05, $05, $05, $09, $05, $05, $05, $09, $05, $05, $05, $09, $05, $05, $05, $09, $05, $05, $05, $09, $05, $05
    Data.b $05, $09, $05, $05, $05, $09, $05, $05, $05, $09, $04, $04, $04, $08, $05, $05, $05, $01, $00, $00, $00, $00, $19, $19, $19, $12, $9B, $9B, $9B, $AF
    Data.b $D7, $D6, $D6, $EA, $DA, $DA, $D9, $ED, $DA, $DA, $D9, $ED, $DA, $DA, $D9, $ED, $DA, $DA, $D9, $ED, $DA, $DA, $D9, $ED, $DA, $DA, $D9, $ED, $DA, $DA
    Data.b $D9, $ED, $DA, $DA, $D9, $ED, $DA, $DA, $D9, $ED, $DA, $DA, $D9, $ED, $D8, $D7, $D6, $EA, $A1, $A1, $A0, $B6, $23, $23, $22, $18, $8C, $8C, $8B, $88
    Data.b $B5, $B4, $DC, $FF, $48, $48, $B9, $FF, $45, $45, $B8, $FF, $45, $45, $B8, $FF, $45, $45, $B8, $FF, $45, $45, $B8, $FF, $45, $45, $B8, $FF, $45, $45
    Data.b $B8, $FF, $45, $45, $B8, $FF, $45, $45, $B8, $FF, $45, $45, $B8, $FF, $45, $45, $B8, $FF, $47, $47, $B8, $FF, $AD, $AC, $DA, $FF, $99, $98, $98, $94
    Data.b $C3, $C3, $C2, $B4, $76, $75, $CD, $FF, $26, $26, $B5, $FF, $26, $26, $B5, $FF, $26, $26, $B5, $FF, $26, $26, $B5, $FF, $26, $26, $B5, $FF, $26, $26
    Data.b $B5, $FF, $26, $26, $B5, $FF, $26, $26, $B5, $FF, $26, $26, $B5, $FF, $26, $26, $B5, $FF, $26, $26, $B5, $FF, $26, $26, $B5, $FF, $6D, $6C, $CA, $FF
    Data.b $B4, $B3, $B3, $B6, $C7, $C6, $C6, $B5, $77, $76, $D2, $FF, $27, $25, $BC, $FF, $27, $25, $BC, $FF, $27, $25, $BC, $FF, $27, $25, $BC, $FF, $27, $25
    Data.b $BC, $FF, $27, $25, $BC, $FF, $27, $25, $BC, $FF, $27, $25, $BC, $FF, $27, $25, $BC, $FF, $27, $25, $BC, $FF, $27, $25, $BC, $FF, $27, $25, $BC, $FF
    Data.b $6E, $6D, $CF, $FF, $B5, $B5, $B5, $B6, $BC, $BC, $BC, $9F, $8E, $8B, $DA, $FF, $29, $23, $BF, $FF, $29, $23, $BF, $FF, $29, $23, $BF, $FF, $29, $23
    Data.b $BF, $FF, $29, $23, $BF, $FF, $29, $23, $BF, $FF, $29, $23, $BF, $FF, $29, $23, $BF, $FF, $29, $23, $BF, $FF, $29, $23, $BF, $FF, $29, $23, $BF, $FF
    Data.b $29, $23, $BF, $FF, $84, $81, $D7, $FF, $BD, $BD, $BD, $A8, $86, $85, $85, $30, $EE, $ED, $EF, $EE, $CF, $CD, $ED, $FF, $CC, $CA, $EC, $FF, $CC, $CA
    Data.b $EC, $FF, $CC, $CA, $EC, $FF, $CC, $CA, $EC, $FF, $CC, $CA, $EC, $FF, $CC, $CA, $EC, $FF, $CC, $CA, $EC, $FF, $CC, $CA, $EC, $FF, $CC, $CA, $EC, $FF
    Data.b $CC, $CA, $EC, $FF, $CE, $CC, $EC, $FF, $ED, $ED, $F0, $F2, $9F, $9E, $9E, $3A, $00, $00, $00, $00, $82, $82, $81, $10, $B9, $B9, $B8, $40, $C1, $C1
    Data.b $C1, $43, $C1, $C1, $C1, $43, $C1, $C1, $C1, $43, $C1, $C1, $C1, $43, $C1, $C1, $C1, $43, $C1, $C1, $C1, $43, $C1, $C1, $C1, $43, $C1, $C1, $C1, $43
    Data.b $C1, $C1, $C1, $43, $C1, $C1, $C1, $43, $BA, $BA, $B9, $41, $8B, $8B, $8A, $12, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $FF, $FF, $00, $00, $FF, $FF, $00, $00, $FF, $FF, $00, $00, $FF, $FF, $00, $00, $80, $01, $00, $00, $00, $00, $00, $00
    Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $01, $00, $00, $FF, $FF, $00, $00, $FF, $FF
    Data.b $00, $00, $FF, $FF, $00, $00, $FF, $FF, $00, $00
  EndDataSection
  
  
EndModule


;-
;-
;- ################### END OF FILE ########################

;-Example
CompilerIf #PB_Compiler_IsMainFile
  Enumeration
    #GUI
    #Symbol_Akku_0
    #Symbol_Akku_25
    #Symbol_Akku_50
    #Symbol_Akku_75
    #Symbol_Akku_100
  EndEnumeration
  
  ; Symbole laden
  CatchImage(#Symbol_Akku_0,?Data_Akku_0_ico)
  CatchImage(#Symbol_Akku_25,?Data_Akku_25_ico)
  CatchImage(#Symbol_Akku_50,?Data_Akku_50_ico)
  CatchImage(#Symbol_Akku_75,?Data_Akku_75_ico)
  CatchImage(#Symbol_Akku_100,?Data_Akku_100_ico)
  
  
  OpenWindow(#GUI, 0, 0, 400, 100, "CustomStatusBar - Beispiel 2", #PB_Window_ScreenCentered | #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget| #PB_Window_SizeGadget)
  
  
  
  ; die CustomStatusBar erstellen
  Global CustomStatusBar = CustomStatusBar::Create(#GUI)
  
  
  ; ################## Elemente einbinden ##################
  
  ; Akkuanzeige
  Global Element_01 = CustomStatusBar::CanvasElement			(CustomStatusBar, #PB_Default, #PB_Default, #Symbol_Akku_100)
  CustomStatusBar::SetContextMenuItem				(CustomStatusBar, Element_01, "Ladezustand des Akkus", "Hardware", "", #Symbol_Akku_100)
  CustomStatusBar::SetField								(CustomStatusBar, 0, Element_01)
  
  ; CPU-Auslastung: Kern 1
  Global Element_02 = CustomStatusBar::TextElement			(CustomStatusBar, 80, 80)
  CustomStatusBar::SetContextMenuItem				(CustomStatusBar, Element_02, "CPU-Auslastung: Kern 1", "Hardware", "CPU")				
  
  ; CPU-Auslastung: Kern 2					
  Global Element_03 = CustomStatusBar::TextElement			(CustomStatusBar, 80, 80)
  CustomStatusBar::SetContextMenuItem				(CustomStatusBar, Element_03, "CPU-Auslastung: Kern 2", "Hardware", "CPU")
  
  ; CPU-Auslastung: Kern 3					
  Global Element_04 = CustomStatusBar::TextElement			(CustomStatusBar, 80, 80)
  CustomStatusBar::SetContextMenuItem				(CustomStatusBar, Element_04, "CPU-Auslastung: Kern 3", "Hardware", "CPU")
  
  ; CPU-Auslastung: Kern 4					
  Global Element_05 = CustomStatusBar::TextElement			(CustomStatusBar, 80, 80)
  CustomStatusBar::SetContextMenuItem				(CustomStatusBar, Element_05, "CPU-Auslastung: Kern 4", "Hardware", "CPU")	
  
  ; CPU-Auslastung: Gesamt					
  Global Element_06 = CustomStatusBar::TextElement			(CustomStatusBar, 80, 80)
  CustomStatusBar::SetContextMenuItem				(CustomStatusBar, Element_06, "CPU-Auslastung: Gesamtlast", "Hardware", "CPU")
  CustomStatusBar::SetField								(CustomStatusBar, 0, Element_06)							
  
  
  ; Statustext				
  Global Element_07 = CustomStatusBar::TextElement			(CustomStatusBar, #PB_Default, #PB_Ignore, "Bereit...")
  CustomStatusBar::SetContextMenuItem				(CustomStatusBar, Element_07, "Statustext", "", "")
  CustomStatusBar::SetElementColor 					(CustomStatusBar, Element_07, #PB_Gadget_FrontColor, RGB(0,150,0))
  CustomStatusBar::SetElementFont 				(CustomStatusBar, Element_07, "Calibri", 11, #PB_Font_Bold)
  CustomStatusBar::SetField								(CustomStatusBar, 0, Element_07)		
  
  
  Global Element_08 = CustomStatusBar::ProgressBarElement		(CustomStatusBar, #PB_Default, #PB_Default)
  CustomStatusBar::SetContextMenuItem				(CustomStatusBar, Element_08, "RAM belegt", "Betriebssystem")
  CustomStatusBar::SetField								(CustomStatusBar, 0, Element_08)
  
  
  
  
  ; Simuiert mit Hilfe einer Zeitfunktion den Lade/Entladevorgang eines Akkus
  Procedure _Pseudo_Akku_Ladezustand ()
    
    Static dFkt_e_Funktion_Amplitude.d			= 1
    Static iFkt_e_Funktion_Zeit.i				= 0
    Static iFkt_e_Funktion_Zeit_merker.i		= 0
    Static iFkt_e_Funktion_Tau.i				= 10000
    Static dFkt_e_Funktion_Startwert.d			= 0
    Static iAufladen.i							= 1
    Static sTitle.s								= ""
    
    Static iZeit_merker.i						= 0	
    Static iZeit_Dauer.i						= 1000	
    
    Protected iZeit.i 							= ElapsedMilliseconds()
    Protected dAkkuladung.d 					= 0
    
    
    ; intervall generieren
    If iZeit > iZeit_merker + iZeit_Dauer
      
      iZeit_Dauer = Random(20000,2000)
      
      iZeit_merker = iZeit + iZeit_Dauer
      dFkt_e_Funktion_Startwert = dFkt_e_Funktion_Amplitude
      iFkt_e_Funktion_Zeit_merker = iZeit
      
      If iAufladen = 1
        iAufladen = 0
        sTitle = "Akku wird entladen..."
      Else
        iAufladen = 1
        sTitle = "Akku wird geladen..."
      EndIf
      
    EndIf
    
    
    ; e-Funktion		
    iFkt_e_Funktion_Zeit = iZeit - iFkt_e_Funktion_Zeit_merker
    
    If iAufladen = 1
      dFkt_e_Funktion_Amplitude = 1-(1-dFkt_e_Funktion_Startwert)*Exp(-iFkt_e_Funktion_Zeit/iFkt_e_Funktion_Tau) ; Aufladen
    Else
      dFkt_e_Funktion_Amplitude = dFkt_e_Funktion_Startwert * Exp(-iFkt_e_Funktion_Zeit/iFkt_e_Funktion_Tau) ; Entladen
    EndIf
    
    
    dAkkuladung = dFkt_e_Funktion_Amplitude * 100
    
    If dAkkuladung > 90
      CustomStatusBar::SetElementAttribute (CustomStatusBar, Element_01, #PB_Canvas_Image , #Symbol_Akku_100)
    ElseIf dAkkuladung > 75
      CustomStatusBar::SetElementAttribute (CustomStatusBar, Element_01, #PB_Canvas_Image , #Symbol_Akku_75)
    ElseIf dAkkuladung > 50
      CustomStatusBar::SetElementAttribute (CustomStatusBar, Element_01, #PB_Canvas_Image , #Symbol_Akku_50)
    ElseIf dAkkuladung > 25
      CustomStatusBar::SetElementAttribute (CustomStatusBar, Element_01, #PB_Canvas_Image , #Symbol_Akku_25)
    ElseIf dAkkuladung > 0
      CustomStatusBar::SetElementAttribute (CustomStatusBar, Element_01, #PB_Canvas_Image , #Symbol_Akku_0)
    EndIf
    
    CustomStatusBar::SetToolTip (CustomStatusBar, Element_01, "Ladezustand: " + StrD(dAkkuladung,1) + "%", sTitle, "Info")
    
  EndProcedure
  
  
  ; Simuliert mit Hilfe einer Sinusfunktion die Last von 4 CPU-Kerne
  Procedure _Pseudo_CPU_Last ()
    Protected dFkt_e_Funktion_Startwert
    Protected dFkt_e_Funktion_Amplitude
    Protected iFkt_e_Funktion_Zeit_merker
    Static iFkt_Rechteck_Wechsel.i				= 100	; ms
    Static iFkt_Rechteck_Zeit_merker.i			= 0 ; ms
    Static iFkt_Rechteck_Amplitude.i			= 0   ; Rückgabewert: {0, 1}
    
    Static dFkt_Sinus_Schrittweite.d			= 0.0003
    Static iFkt_Sinus_Flanke.i					= 0		; Rückgabewert: -1: Fallend; 1: Steigend
    Static dFkt_Sinus_Amplitude.d				= 0   ; Rückgabewert: 0 <= x <= 1
    Static dFkt_Sinus_Amplitude_merker.d		= 0
    Static iCPU_1_Last.i						= 0
    Static iCPU_2_Last.i						= 0
    Static iCPU_3_Last.i						= 0
    Static iCPU_4_Last.i						= 0
    Static iCPU_Gesamt_Last.i					= 0
    
    Protected iZeit.i 							= ElapsedMilliseconds()
    Protected sTooltip_text.s					= ""
    
    
    iZeit = ElapsedMilliseconds()
    
    ; Rechtecksignal
    If iZeit > iFkt_Rechteck_Zeit_merker + iFkt_Rechteck_Wechsel
      
      iFkt_Rechteck_Zeit_merker = iZeit + iFkt_Rechteck_Wechsel
      dFkt_e_Funktion_Startwert = dFkt_e_Funktion_Amplitude
      iFkt_e_Funktion_Zeit_merker = iZeit
      
      If iFkt_Rechteck_Amplitude = 0
        iFkt_Rechteck_Amplitude = 1
      Else
        iFkt_Rechteck_Amplitude = 0
      EndIf
      
      iCPU_1_Last	 		= dFkt_Sinus_Amplitude * Random (100,98)
      iCPU_2_Last			= dFkt_Sinus_Amplitude * Random (90,60)
      iCPU_3_Last	 		= dFkt_Sinus_Amplitude * Random (100,70)
      iCPU_4_Last	 		= dFkt_Sinus_Amplitude * Random (100,50)
      iCPU_Gesamt_Last	= (iCPU_1_Last + iCPU_2_Last + iCPU_3_Last + iCPU_4_Last) /4
    EndIf
    
    
    
    ; Sinussignal
    dFkt_Sinus_Amplitude = Sin(iZeit * dFkt_Sinus_Schrittweite) * 0.5 + 0.5
    
    If dFkt_Sinus_Amplitude >= dFkt_Sinus_Amplitude_merker
      iFkt_Sinus_Flanke = 1
    Else
      iFkt_Sinus_Flanke = -1
    EndIf		
    dFkt_Sinus_Amplitude_merker = dFkt_Sinus_Amplitude
    
    
    sTooltip_text = "CPU 1:  " + Str(iCPU_1_Last) + "%" + #CRLF$
    sTooltip_text + "CPU 2:  " + Str(iCPU_2_Last) + "%" + #CRLF$
    sTooltip_text + "CPU 3:  " + Str(iCPU_3_Last) + "%" + #CRLF$
    sTooltip_text + "CPU 4:  " + Str(iCPU_4_Last) + "%" + #CRLF$
    sTooltip_text + "--------------------" + #CRLF$
    sTooltip_text + "Gesamtlast:  " + Str(iCPU_Gesamt_Last) + "%" + #CRLF$
    
    
    CustomStatusBar::SetElementText (CustomStatusBar, Element_02, "CPU #1:  " + Str(iCPU_1_Last) + "%")
    CustomStatusBar::SetElementText (CustomStatusBar, Element_03, "CPU #2:  " + Str(iCPU_2_Last) + "%")
    CustomStatusBar::SetElementText (CustomStatusBar, Element_04, "CPU #3:  " + Str(iCPU_3_Last) + "%")
    CustomStatusBar::SetElementText (CustomStatusBar, Element_05, "CPU #4:  " + Str(iCPU_4_Last) + "%")
    CustomStatusBar::SetElementText (CustomStatusBar, Element_06, "CPU:  " + Str(iCPU_Gesamt_Last) + "%")
    
    CustomStatusBar::SetToolTip (CustomStatusBar, Element_02, sTooltip_text, "CPU-Auslastung", "Info")
    CustomStatusBar::SetToolTip (CustomStatusBar, Element_03, sTooltip_text, "CPU-Auslastung", "Info")
    CustomStatusBar::SetToolTip (CustomStatusBar, Element_04, sTooltip_text, "CPU-Auslastung", "Info")
    CustomStatusBar::SetToolTip (CustomStatusBar, Element_05, sTooltip_text, "CPU-Auslastung", "Info")
    CustomStatusBar::SetToolTip (CustomStatusBar, Element_06, sTooltip_text, "CPU-Auslastung", "Info")
  EndProcedure
  
  
  ; Thread zur Berechnung von irgendwelchen Werten ;)
  Procedure _Pseudo_Werte (Parameter)
    
    Protected dRAM_Gesamt.d
    Protected dRAM_Frei.d
    Protected dRAM_Belegt.d
    Protected dRAM_belegt_prozent.d
    Protected sTooltip_text.s
    
    Repeat
      
      dRAM_Gesamt 		=  MemoryStatus(#PB_System_TotalPhysical) / 1048576
      dRAM_Frei 			=  MemoryStatus(#PB_System_FreePhysical) / 1048576
      dRAM_Belegt 		=  dRAM_Gesamt - dRAM_Frei
      dRAM_belegt_prozent	= (100 / dRAM_Gesamt) * dRAM_Belegt
      
      sTooltip_text = "RAM Gesamt:  " + StrD(dRAM_Gesamt,3) + " MB" + #CRLF$
      sTooltip_text + "RAM frei:    " + StrD(dRAM_Frei,3) + " MB" + #CRLF$
      sTooltip_text + "RAM belegt:  " + StrD(dRAM_Belegt,3) + " MB" + #CRLF$
      sTooltip_text + "--------------------" + #CRLF$
      sTooltip_text + "RAM-Auslastung:  " + StrD(dRAM_belegt_prozent,2) + "%"
      
      CustomStatusBar::SetElementStatus (CustomStatusBar, Element_08, dRAM_belegt_prozent)
      CustomStatusBar::SetToolTip (CustomStatusBar, Element_08, sTooltip_text, "RAM-Auslastung", "Info")
      
      
      _Pseudo_Akku_Ladezustand ()
      _Pseudo_CPU_Last ()
      
      Delay (2)
      
    ForEver
    
  EndProcedure
  
  
  Define iWindowEvent
  Define Parameter
  
  CreateThread(@_Pseudo_Werte(), Parameter)
  
  
  Repeat
    
    iWindowEvent = WaitWindowEvent(10)
    
    
    Select CustomStatusBar::GetElementEvent (CustomStatusBar, iWindowEvent)
        
      Case Element_01
        Debug "CanvasEvent: mehr Details mit EventType()"
        
      Case Element_02
        Debug "Element 2 gedrückt"
        
      Case Element_03
        Debug "Element 3 gedrückt"
        
      Case Element_04
        Debug "Element 4 gedrückt"
        
      Case Element_05
        Debug "Element 5 gedrückt"
        
      Case Element_06
        Debug "Element 6 gedrückt"
        
      Case Element_07
        Debug "Element 7 gedrückt"		
    EndSelect
    
  Until iWindowEvent = #PB_Event_CloseWindow
  
  DataSection
    Data_Akku_0_ico_len:
    Data.i 1150
    Data_Akku_0_ico:
    Data.q $1010000100010000,$468002000010000,$28000000160000,$20000000100000,$2000010000
    Data.q 71303168,0,0,0,0,$6868BFC19A9A0000,$4949FF794444FF91,$B3B3FF9E7A7AFF7C,49108
    Data.q 0,0,0,$61613FD18B8B0000,$7878FFB86767FF9D,$7272FFC27373FFC7,$4343FFC16C6CFFC2
    Data.q $8080BF984848FF95,16335,0,0,$7C7C7FA455550000,$9A9AFFF1CACAFFC7,$7D7DFFF87272FFF6
    Data.q $9292FFF4A1A1FFF7,$4444FFC37373FFE4,32667,0,0,$50507FA751510000,$6363FFFFACACFFF4
    Data.q $4C4CFFFF3F3FFFFF,$5252FFFF7272FFFF,$3E3EFFF35757FFFF,32651,0,0,$58587FA550500000
    Data.q $3E3EFFE89292FFBE,$1F1FFFE81616FFF2,$3F3FFFEE4949FFF0,$3D3DFFB64949FFD5,32649
    Data.q 0,0,$60607FA650500000,$8383FFD39C9CFFB8,$5F5FFFB55E5EFFC7,$5D5DFFBE6F6FFFB6
    Data.q $3C3CFFB25353FFB5,32649,0,0,$60607FA64F4F0000,$8383FFD39C9CFFB8,$5F5FFFB55E5EFFC7
    Data.q $5D5DFFBE6F6FFFB6,$3A3AFFB25353FFB5,32649,0,0,$60607FA44E4E0000,$8383FFD39C9CFFB8
    Data.q $5F5FFFB55E5EFFC7,$5D5DFFBE6F6FFFB6,$3838FFB25353FFB5,32646,0,0,$61617FA14F4F0000
    Data.q $8383FFD39C9CFFB9,$5F5FFFB55E5EFFC7,$5D5DFFBE6F6FFFB6,$3939FFB25353FFB5,32642
    Data.q 0,0,$61617FA050500000,$8383FFD39C9CFFB9,$5F5FFFB55E5EFFC7,$5D5DFFBE6F6FFFB6
    Data.q $3A3AFFB25353FFB5,32640,0,0,$61617FA153530000,$8383FFD39C9CFFB9,$5F5FFFB55E5EFFC7
    Data.q $5D5DFFBE6F6FFFB6,$3B3CFFB25353FFB5,32638,0,0,$63637FA055560000,$8181FFD29B9BFFBA
    Data.q $5E5EFFB45C5CFFC6,$5D5DFFBD6F6FFFB5,$3C3EFFB25353FFB5,32635,0,0,$61617F9F56570000
    Data.q $7373FFC88989FFB9,$5C5CFFB05E5EFFBC,$5657FFA05F60FFAA,$3D3FFFB14F4FFFA2,32633
    Data.q 0,0,$60607F9D57580000,$E0E0FFDFC4C4FFB9,$8A96FFCDBCC5FFEC,$7A80FFB8A0A8FFA4
    Data.q $3E41FF824649FF9C,32635,0,0,$727B7FC1989A0000,$D0D8FFACA8B6FF88,$859BFFCDCAD4FFD2
    Data.q $667AFF4B4460FF8B,$6468FF83696FFF68,16279,0,0,0,$86977F9079880000,$788EFF9895A6FF88
    Data.q $979DFF6D6C7BFF7D,32683,0,$1FF8000000000000,$7E0000007E00000,$7E0000007E00000
    Data.q $7E0000007E00000,$7E0000007E00000,$7E0000007E00000,$7E0000007E00000,$7E0000007E00000
    Data.q 536346624
    
    Data_Akku_25_ico_len:
    Data.i 1150
    Data_Akku_25_ico:
    Data.q $1010000100010000,$468002000010000,$28000000160000,$20000000100000,$2000010000
    Data.q 71303168,0,0,0,0,$6E5E7F87834D0000,$513CFF4E4D36FF6F,$9667FF807F70FF53,32664
    Data.q 0,0,0,$6A4E3FA9A34E0000,$7E0BFF807911FF6C,$6B08FF706A07FF85,$4D0EFF77710CFF71
    Data.q $974FBF5B582AFF51,16283,0,0,$710B7F6E691F0000,$AA01FFCFC401FF77,$8001FF857D01FFB4
    Data.q $7D01FF9D9401FF88,$5818FF635E0CFF84,32605,0,0,$7A077F6A651B0000,$B92EFFD2C813FF81
    Data.q $9C3BFFA29B3CFFC2,$820EFFACA52AFFA3,$5116FF65600AFF8A,32596,0,0,$A2287F69641D0000
    Data.q $C60CFFEEE741FFA8,$B103FFB3A901FFD0,$B72AFFD4CA14FFBB,$5018FF959031FFBF,32595
    Data.q 0,0,$8D077F6A651E0000,$9F01FFE4D804FF95,$8D01FF8B8301FFA9,$9201FFB5AB01FF96
    Data.q $5018FF9A9208FF9B,32595,0,0,$78407F6A66200000,$7D15FFC2BA32FF7C,$640CFF605B0BFF83
    Data.q $702AFF8A8316FF6A,$501AFF6F6C40FF74,32595,0,0,$7A487F6A65250000,$A058FFBDB866FF7E
    Data.q $7B4CFF7C794BFFA4,$784BFF8F8B51FF7E,$501EFF6F6D45FF7B,32595,0,0,$7C487F6864280000
    Data.q $A058FFBDB866FF7F,$7B4CFF7C794BFFA4,$784BFF8F8B51FF7E,$4E20FF6F6D45FF7B,32593
    Data.q 0,0,$7C487F65622B0000,$A058FFBDB866FF7F,$7B4CFF7C794BFFA4,$784BFF8F8B51FF7E
    Data.q $4B24FF6F6D45FF7B,32589,0,0,$7C487F6763340000,$A058FFBDB866FF7F,$7B4CFF7C794BFFA4
    Data.q $784BFF8F8B51FF7E,$4A2AFF6F6D45FF7B,32588,0,0,$7D487F68653A0000,$9D57FFBCB765FF80
    Data.q $794BFF7A774AFFA1,$784BFF8E8A51FF7C,$4B2FFF6F6D45FF7B,32589,0,0,$7C487F68653C0000
    Data.q $8E53FFAAA55BFF7F,$754BFF7A784BFF91,$6E49FF75754DFF76,$4B31FF6A6840FF6E,32589
    Data.q 0,0,$79447F69663F0000,$E6D3FFD0CEB4FF7B,$9389FFC6C3B7FFE6,$8479FFAAA99DFF97
    Data.q $4C32FF505540FF82,32590,0,0,$75737FA4A28A0000,$D0D6FFACA9B4FF76,$859AFFCDCAD3FFD2
    Data.q $6678FF4A445FFF8A,$9182FF6D6D66FF67,32658,0,0,0,$86977F83807F0000,$788EFF9895A6FF88
    Data.q $9E99FF6D6C7BFF7D,$3F99988C7F9E,0,$1FF8000000000000,$7E0000007E00000,$7E0000007E00000
    Data.q $7E0000007E00000,$7E0000007E00000,$7E0000007E00000,$7E0000007E00000,$7E0000007E00000
    Data.q $FF80000
    
    Data_Akku_50_ico_len:
    Data.i 1150
    Data_Akku_50_ico:
    Data.q $1010000100010000,$468002000010000,$28000000160000,$20000000100000,$2000010000
    Data.q 71303168,0,0,0,0,$7B60BF93AA8B0000,$5E3FFF3F5939FF66,$9D71FF788A73FF45,32637
    Data.q 0,0,0,$7B513F83B1700000,$9633FF589B3DFF5C,$731CFF336F1BFF50,$5E19FF418525FF35
    Data.q $965ABF426437FF2C,16234,0,0,$83257F527F410000,$C959FF9DE97AFF40,$8921FF3E8620FF7B
    Data.q $8320FF59A739FF3F,$622DFF2E601BFF3D,32571,0,0,$87257F517F410000,$CA57FF9DEA7AFF41
    Data.q $891FFF3D861EFF79,$831FFF58A738FF3E,$5F28FF2B6016FF3B,32566,0,0,$87247F4F7E3F0000
    Data.q $CB56FF9DEB78FF40,$8A1EFF3C871DFF79,$831DFF57A836FF3D,$6026FF2A6015FF3B,32564
    Data.q 0,0,$87247F4F7F3F0000,$D474FFA3EC81FF40,$A451FF69A351FF91,$8928FF72B657FF69
    Data.q $5F25FF2A6015FF44,32563,0,0,$A0627F507E410000,$D975FFC5EFB4FF73,$C658FF67BF4FFF8C
    Data.q $C071FF90D97AFF6F,$5E27FF6D8862FF83,32564,0,0,$AB307F527D440000,$BD3DFF8BF070FF46
    Data.q $AC2CFF3EA323FF58,$B12FFF63C748FF48,$5E29FF4BAF31FF4A,32566,0,0,$80507F537C460000
    Data.q $9E2EFF8DD877FF5C,$8315FF1D7910FF40,$7E2FFF45A22CFF23,$5D2CFF4B6741FF3C,32567
    Data.q 0,0,$7F5A7F547A490000,$B088FFB5D3A9FF64,$7852FF5B7651FF93,$7350FF75916AFF5D
    Data.q $5C2FFF4F6446FF5A,32569,0,0,$7F5A7F577A4D0000,$B088FFB5D3A9FF65,$7852FF5B7651FF93
    Data.q $7350FF75916AFF5D,$5B32FF4F6446FF5A,32570,0,0,$805B7F5978510000,$AC84FFB4D2A8FF65
    Data.q $7651FF59734FFF90,$734FFF749068FF5B,$5633FF4F6446FF5A,32569,0,0,$7E5A7F5C77550000
    Data.q $9670FF9DB792FF64,$7250FF5C7553FF7B,$684BFF5D7757FF58,$5336FF506747FF50,32571
    Data.q 0,0,$7F5C7F60765A0000,$EAE7FFCBD3C8FF66,$959FFFC7C7CFFFE7,$827FFFA5A9ADFF94
    Data.q $533CFF435647FF78,32575,0,0,$7B7E7F9EAB9C0000,$D1D9FFACA9B7FF76,$869CFFCDCBD5FFD2
    Data.q $667AFF4A4560FF8B,$7264FF6D7372FF67,16227,0,0,0,$86977F7E82880000,$788EFF9895A6FF88
    Data.q $817CFF6D6C7BFF7D,16247,0,$1FF8000000000000,$7E0000007E00000,$7E0000007E00000
    Data.q $7E0000007E00000,$7E0000007E00000,$7E0000007E00000,$7E0000007E00000,$7E0000007E00000
    Data.q 536346624
    
    Data_Akku_75_ico_len:
    Data.i 1150
    Data_Akku_75_ico:
    Data.q $1010000100010000,$468002000010000,$28000000160000,$20000000100000,$2000010000
    Data.q 71303168,0,0,0,0,$7B60BF93AA8B0000,$5E3FFF3F5939FF66,$9D71FF788A73FF45,32637
    Data.q 0,0,0,$7B513F83B1700000,$9633FF589B3DFF5C,$731CFF336F1BFF50,$5E19FF418525FF35
    Data.q $965ABF426437FF2C,16234,0,0,$83257F517E3F0000,$C959FF9DE97AFF40,$8921FF3E8620FF7B
    Data.q $8320FF59A739FF3F,$612AFF2E601BFF3D,32568,0,0,$87257F4F7D3D0000,$CA57FF9DEA7AFF41
    Data.q $891FFF3D861EFF79,$831FFF58A738FF3E,$5A21FF2B6016FF3B,32560,0,0,$87247F4D7D3C0000
    Data.q $CB56FF9DEB78FF40,$8A1EFF3C871DFF79,$831DFF57A836FF3D,$5920FF2A6015FF3B,32558
    Data.q 0,0,$87247F4E7F3C0000,$CB56FF9DEB78FF40,$8A1EFF3C871DFF79,$831DFF57A836FF3D
    Data.q $5B1FFF2A6015FF3B,32559,0,0,$87247F50813E0000,$CB56FF9DEB78FF40,$8A1EFF3C871DFF79
    Data.q $831DFF57A836FF3D,$5E21FF2A6015FF3B,32560,0,0,$87247F4E813D0000,$CB56FF9DEB78FF40
    Data.q $8A1EFF3C871DFF79,$831DFF57A836FF3D,$6022FF2A6015FF3B,32561,0,0,$87247F4E803E0000
    Data.q $D474FFA3EC81FF40,$A451FF69A351FF91,$8928FF72B657FF69,$5F23FF2A6015FF44,32561
    Data.q 0,0,$A7547F4F7E400000,$DD6DFFBDF7A5FF6B,$C853FF64C04AFF88,$C660FF8BDD72FF6C
    Data.q $5E26FF5E8B4EFF78,32563,0,0,$AB2E7F537E460000,$BD3DFF8BF070FF45,$AC2CFF3EA323FF58
    Data.q $B12FFF63C748FF48,$5E2BFF49AF2FFF4A,32566,0,0,$81517F577D4B0000,$9D2DFF8DD777FF5D
    Data.q $8315FF1C790FFF3F,$7E2EFF45A12BFF23,$5D30FF4B6741FF3C,32569,0,0,$7E5A7F587D4E0000
    Data.q $9670FF9DB792FF64,$7250FF5C7553FF7B,$684BFF5D7757FF58,$5D34FF506747FF50,32571
    Data.q 0,0,$7F5C7F597A510000,$EAE7FFCBD3C8FF66,$959FFFC7C7CFFFE7,$827FFFA5A9ADFF94
    Data.q $5D38FF435647FF78,32574,0,0,$7B7E7F97AC940000,$D1D9FFACA9B7FF76,$869CFFCDCBD5FFD2
    Data.q $667AFF4A4560FF8B,$7A5DFF6D7372FF67,16223,0,0,0,$86977F7B82850000,$788EFF9895A6FF88
    Data.q $9D9AFF6D6C7BFF7D,32661,0,$1FF8000000000000,$7E0000007E00000,$7E0000007E00000
    Data.q $7E0000007E00000,$7E0000007E00000,$7E0000007E00000,$7E0000007E00000,$7E0000007E00000
    Data.q 536346624
    
    Data_Akku_100_ico_len:
    Data.i 1150
    Data_Akku_100_ico:
    Data.q $1010000100010000,$468002000010000,$28000000160000,$20000000100000,$2000010000
    Data.q 71303168,0,0,0,0,$7B60BF93AA8B0000,$5E3FFF3F5939FF66,$9D71FF788A73FF45,32637
    Data.q 0,0,0,$7B513F83B1700000,$9633FF589B3DFF5C,$731CFF336F1BFF50,$5E19FF418525FF35
    Data.q $965ABF426437FF2C,16234,0,0,$83257F517E3F0000,$C959FF9DE97AFF40,$8921FF3E8620FF7B
    Data.q $8320FF59A739FF3F,$612AFF2E601BFF3D,32568,0,0,$87257F4F7D3D0000,$CA57FF9DEA7AFF41
    Data.q $891FFF3D861EFF79,$831FFF58A738FF3E,$5A21FF2B6016FF3B,32560,0,0,$87247F4D7D3C0000
    Data.q $CB56FF9DEB78FF40,$8A1EFF3C871DFF79,$831DFF57A836FF3D,$5920FF2A6015FF3B,32558
    Data.q 0,0,$87247F4D7F3B0000,$CB56FF9DEB78FF40,$8A1EFF3C871DFF79,$831DFF57A836FF3D
    Data.q $5A1EFF2A6015FF3B,32557,0,0,$87247F4E803B0000,$CB56FF9DEB78FF40,$8A1EFF3C871DFF79
    Data.q $831DFF57A836FF3D,$5A1CFF2A6015FF3B,32556,0,0,$87247F4E803B0000,$CB56FF9DEB78FF40
    Data.q $8A1EFF3C871DFF79,$831DFF57A836FF3D,$5A1CFF2A6015FF3B,32556,0,0,$87247F4E803B0000
    Data.q $CB56FF9DEB78FF40,$8A1EFF3C871DFF79,$831DFF57A836FF3D,$5A1CFF2A6015FF3B,32556
    Data.q 0,0,$87247F4E7E3C0000,$CB56FF9DEB78FF40,$8A1EFF3C871DFF79,$831DFF57A836FF3D
    Data.q $581EFF2A6015FF3B,32557,0,0,$87247F527F410000,$CB56FF9DEB78FF40,$8A1EFF3C871DFF79
    Data.q $831DFF57A836FF3D,$5823FF2A6015FF3B,32560,0,0,$87247F557E470000,$CB56FF9DEB78FF40
    Data.q $8A1EFF3C871DFF79,$831DFF57A836FF3D,$5728FF2A6015FF3B,32563,0,0,$87247F567D490000
    Data.q $AC60FF93D576FF40,$7E38FF51853DFF76,$7429FF518541FF4A,$572BFF2A6015FF3C,32565
    Data.q 0,0,$7E4F7F597C4D0000,$EAE7FFCBD3C8FF5C,$959FFFC7C7CFFFE7,$827FFFA5A9ADFF94
    Data.q $5831FF3A513EFF78,32569,0,0,$7B7E7F98AF910000,$D1D9FFACA9B7FF76,$869CFFCDCBD5FFD2
    Data.q $667AFF4A4560FF8B,$7856FF6D7372FF67,16220,0,0,0,$86977F7A85810000,$788EFF9895A6FF88
    Data.q $A096FF6D6C7BFF7D,$3F879A857F94,0,$1FF8000000000000,$7E0000007E00000,$7E0000007E00000
    Data.q $7E0000007E00000,$7E0000007E00000,$7E0000007E00000,$7E0000007E00000,$7E0000007E00000
    Data.q $FF80000
    
  EndDataSection
  
  
CompilerEndIf
