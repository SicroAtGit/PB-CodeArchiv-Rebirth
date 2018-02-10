;   Description: DebugLog - Module: save, show and manage logs
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28846
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 Imhotheb (Andreas Wenzl)
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

; ==================================================
;|                     DebugLog                     |
;|==================================================|
;| Version: V1.0                Created: 06.04.2015 |
;| Type: PB-Include (Module)                        |
;| Author: Imhotheb (Andreas Wenzl)                 |
;| Compiler: PB5.31 32/64 [Win/Lin]                 |
;| Description: save, show and manage logs          |
; ==================================================
;
; DebugLog - speichern, anzeigen und formatieren von Debug-Nachrichten V1.0
; -------------------------------------------------------------------------
;
; OpenConsole() wird für die Consolen-Ausgabe BENÖTIGT
;
;
; Übersicht der Funktionen/Proceduren:
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; * DebugLog(Msg.s, Level.a = 0, Flags.u = 0)
;   >>> speichert eine Nachricht und gibt diese mit Debug und/oder auf der Console aus wenn [DebugLevel <= Level] ist
; * SetDebugLevel(Level.a)
;   >>> setzt den "globalen" DebugLevel
; * SetDebugLogDateFormat(Format.s = "")
;   >>> setzt ein neues Format für das Datum ... Format entspricht einer Maske$ FormatDate()
;   >>> Standart = "[%dd.%mm.%yy]" ... kein Parameter setzt auf Standart zurück
; * SetDebugLogTimeFormat(Format.s = "")
;   >>> setzt ein neues Format für das Datum ... Format entspricht einer Maske$ FormatDate()
;   >>> Standart = "[%hh:%ii.%ss]" ... kein Parameter setzt auf Standart zurück
; * SetDebugLogFlags(Flags.u = 0)
;   >>> setzt Flags die immer benutzt werden wenn keine angegeben sind
; * ShowLastLog(Flags.u = 0)
;   >>> zeigt die letzte gespeicherte DebugLog-Nachricht an
; * GetDebugLog(Level.a = 0, Flags.u = 0)
;   >>> gibt einen formatierten String mit allen Einträgen, die [Level <= NachrichtenLevel] entsprechen, zurück
;   >>> Mehrere Einträge werden mit Chr(10) getrennt
; * GetDebugLogSorted(Sort.b, Order.b = #PB_Sort_Ascending, Level.a = 0, Flags.u = 0)
;   >>> gibt einen formatierten String mit sortierten Einträgen , die [Level <= NachrichtenLevel] entsprechen, zurück
;   >>> Sort kann #DebugLog_Sort_ID, #DebugLog_Sort_Date, #DebugLog_Sort_Level oder #DebugLog_Sort_Msg sein
;   >>> für Order kann #PB_Sort_* verwendet werden (#PB_Sort_Ascending, #PB_Sort_Descending, #PB_Sort_NoCase)
;   >>> Mehrere Einträge werden mit Chr(10) getrennt
; * GetDebugLevel()
;   >>> gibt den "globalen" DebugLevel zurück
; * GetLastLog(Flags.u = 0)
;   >>> gibt einen formatierten String mit dem letzten gespeicherten Eintrag zurück
;
;
; Folgende Flags können verwendet werden:
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; #NoDebugOutput    = Zeigt keine Nachricht mit Debug an
; #ShowConsole      = Zeigt die Nachricht auf der Console an (nur DebugLog und ShowLastlog)
; #ShowLogDate      = Zeigt das Datum zu einem Eintrag an
; #ShowLogTime      = Zeigt die Uhrzeit zu einem Eintrag an
; #ShowMsgID        = Zeigt die ID (laufende Nummer) zu einem Eintrag an
; #ShowDebugLevel   = Zeigt den DebugLevel für einen Eintrag an
; #NoSave           = verhindert das der Eintrag gespeichert wird
; #OnlyDebugLevel   = Nur Einträge anzeigen die gleich dem DebugLevel sind (DebugLevel = Level)
; #StandardFlags    = StandartFlags benutzen ... normalerweise werden die StandartFlags nur benutzt
;                     wenn keine Flags angegeben sind ... so können sie jedoch verknüpft werden
; #NoFlags          = keine Flags verwenden (auch keine StandartFlags)
;
; mehrere Flags können mit | verknüpft werden
;
;

DeclareModule DebugLog
	Enumeration AWLib_DebugLog_Flags
		#NoDebugOutput  = %0000000000000001   ; don't use "Debug" to Display Message
		#ShowConsole    = %0000000000000010		; show Message in Console, NEEDs OpenConsole()
		#ShowLogDate    = %0000000000000100		; add Date to Msg
		#ShowLogTime    = %0000000000001000		; add Time to Msg
		#ShowMsgID      = %0000000000010000		; add ID to Msg
		#ShowDebugLevel = %0000000000100000		; add DebugLevel to Msg
		#NoSave         = %0000000001000000		; don't Save Msg
		#OnlyDebugLevel = %0000000010000000		; only Show DebugLevel
		#StandardFlags  = %0100000000000000		; use Flags and StandardFlags
		#NoFlags        = %1000000000000000		; Dummy, don't use Standard-Flags (no Flags)
	EndEnumeration
	
	Enumeration AWLib_DebugLog_SortFlags
		#DebugLog_Sort_ID     ; sort by ID
		#DebugLog_Sort_Date		; sort by Date/Time
		#DebugLog_Sort_Time = #DebugLog_Sort_Date ; Date() is saved ... Date and Time are the same
		#DebugLog_Sort_Level											; sort by Level
		#DebugLog_Sort_Msg												; sort by Message
	EndEnumeration
	
	Declare DebugLog(Msg.s, Level.a = 0, Flags.u = 0)     ; Flags = AWLib_DebugLog_Flags ... show if MessageLevel >= GlobalLogLevel or use #OnlyDebugLevel
	Declare SetDebugLevel(Level.a)												; set "Global" DebugLevel
	Declare SetDebugLogDateFormat(Format.s = "")					; set DateFormat, Standard = "[%dd.%mm.%yy]"
	Declare SetDebugLogTimeFormat(Format.s = "")					; set TimeFormat, Standard = "[%hh:%mm:%ss]"
	Declare SetDebugLogFlags(Flags.u = 0)									; set Standard-Flags ... use () or (0) to delete
	Declare ShowLastLog(Flags.u = 0)											; show last Log-Entry
	Declare.s GetDebugLog(Level.a = 0, Flags.u = 0)				; get all Log-Entries
	Declare.s GetDebugLogSorted(Sort.b, Order.b = #PB_Sort_Ascending, Level.a = 0, Flags.u = 0)   ; get all Log-Entries, sorted by ID/Date/Level/Msg ... use #DebugLog_Sort_* and #PB_Sort_* for order
	Declare.a GetDebugLevel()																																			; get "Global" DebugLevel
	Declare.s GetLastLog(Flags.u = 0)
	
EndDeclareModule

Module DebugLog
	EnableExplicit
	
	Structure AWLib_Debug_MessageData
		ID.i
		Level.a
		Date.i
		Msg.s
	EndStructure
	
	Structure AWLib_Debug_Data
		Level.a
		AWLib_Msg_Level.a
		Separator.c
		Count.i
		StandardFlags.u
		TimeFormat.s
		DateFormat.s
		List MsgData.AWLib_Debug_MessageData()
	EndStructure
	
	Global DebugData.AWLib_Debug_Data
	
	Procedure AWLib_DebugLog_Internal_CheckFlags(*Flags.Unicode)
		; Check Flags & set New
		
		If *Flags\u & #NoFlags
			*Flags\u = 0
			ProcedureReturn
		EndIf
		If *Flags\u = 0   ; no Flags given
			*Flags\u = DebugData\StandardFlags
		ElseIf *Flags\u & #StandardFlags    ; if #StandardFlags is used
			*Flags\u | DebugData\StandardFlags
		EndIf
		
	EndProcedure
	Procedure AWLib_DebugLog_Internal_ShowLog(Msg.s, Flags.u)
		
		CompilerIf #PB_Compiler_Debugger    ; disable DebugOutput if no Debugger
			If Not Flags & #NoDebugOutput
				Debug Msg
			EndIf
		CompilerEndIf
		If Flags & #ShowConsole
			PrintN(Msg)
		EndIf       
		
		ProcedureReturn #True
	EndProcedure  
	Procedure AWLib_DebugLog_Internal_CreateMsg(*DebugLog_Message.AWLib_Debug_MessageData, Flags.u)
		;create DebugLog Message with Time/Date/ID and/or DebugLevel    
		
		If Flags & #ShowLogTime Or Flags & #ShowLogDate Or Flags & #ShowMsgID Or Flags & #ShowDebugLevel
			*DebugLog_Message\Msg = ": " + *DebugLog_Message\Msg
			If Flags & #ShowLogTime
				If DebugData\TimeFormat = ""
					DebugData\TimeFormat = "[%hh:%ii:%ss]"
				EndIf
				*DebugLog_Message\Msg = FormatDate(DebugData\TimeFormat, *DebugLog_Message\Date) + Space(1) + *DebugLog_Message\Msg
			EndIf
			If Flags & #ShowLogDate
				If DebugData\DateFormat = ""
					DebugData\DateFormat = "[%dd.%mm.%yy]"
				EndIf
				*DebugLog_Message\Msg = FormatDate(DebugData\DateFormat, *DebugLog_Message\Date) + Space(1) + *DebugLog_Message\Msg
			EndIf
			If Flags & #ShowMsgID
				*DebugLog_Message\Msg = "<ID:" + *DebugLog_Message\ID + ">" + Space(1) + *DebugLog_Message\Msg
			EndIf
			If Flags & #ShowDebugLevel
				*DebugLog_Message\Msg = "{LVL:" + *DebugLog_Message\Level + "}" + Space(1) + *DebugLog_Message\Msg
			EndIf    
		EndIf
		
		ProcedureReturn #True
	EndProcedure  
	
	Procedure DebugLog(Msg.s, Level.a = 0, Flags.u = 0)
		Protected MsgData.AWLib_Debug_MessageData  
		MsgData\ID = DebugData\Count + 1
		MsgData\Date = Date()
		MsgData\Msg = Msg
		MsgData\Level = Level
		
		AWLib_DebugLog_Internal_CheckFlags(@Flags)
		
		If Not Flags & #NoSave
			DebugData\Count + 1
			AddElement(DebugData\MsgData())
			DebugData\MsgData() = MsgData
		EndIf
		If Flags & #OnlyDebugLevel
			If DebugData\Level = Level
				AWLib_DebugLog_Internal_CreateMsg(@MsgData, Flags)
				AWLib_DebugLog_Internal_ShowLog(MsgData\Msg, Flags)
			EndIf
		ElseIf DebugData\Level <= Level
			AWLib_DebugLog_Internal_CreateMsg(@MsgData, Flags)
			AWLib_DebugLog_Internal_ShowLog(MsgData\Msg, Flags)
		EndIf      
		
		ProcedureReturn #True
	EndProcedure
	Procedure SetDebugLevel(Level.a)
		
		DebugData\Level = Level
		
		ProcedureReturn #True
	EndProcedure
	Procedure.a GetDebugLevel()
		
		ProcedureReturn DebugData\Level
	EndProcedure
	Procedure.s GetDebugLog(Level.a = 0, Flags.u = 0)
		Protected MsgData.AWLib_Debug_MessageData  
		Protected Msg.s
		
		AWLib_DebugLog_Internal_CheckFlags(@Flags)
		
		ForEach DebugData\MsgData()
			MsgData = DebugData\MsgData()
			If Flags & #OnlyDebugLevel
				If MsgData\Level = Level
					AWLib_DebugLog_Internal_CreateMsg(@MsgData, Flags)
					Msg + MsgData\Msg + Chr(10)
				EndIf
			ElseIf MsgData\Level >= Level
				AWLib_DebugLog_Internal_CreateMsg(@MsgData, Flags)
				Msg + MsgData\Msg + Chr(10)
			EndIf      
		Next
		
		ProcedureReturn Msg
	EndProcedure
	Procedure ShowLastLog(Flags.u = 0)
		Protected MsgData.AWLib_Debug_MessageData
		
		AWLib_DebugLog_Internal_CheckFlags(@Flags)
		
		MsgData = DebugData\MsgData()
		AWLib_DebugLog_Internal_CreateMsg(@MsgData, Flags)
		AWLib_DebugLog_Internal_ShowLog(MsgData\Msg, Flags)      
		
		ProcedureReturn #True
	EndProcedure
	Procedure SetDebugLogDateFormat(Format.s = "")
		
		If Format
			DebugData\DateFormat = Format
		Else
			DebugData\DateFormat = "[%dd.%mm.%yy]"
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	Procedure SetDebugLogTimeFormat(Format.s = "")
		
		If Format
			DebugData\TimeFormat = Format
		Else
			DebugData\TimeFormat = "[%hh:%mm:%ss]"
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	Procedure SetDebugLogFlags(Flags.u = 0)
		
		DebugData\StandardFlags = Flags
		
		ProcedureReturn #True
	EndProcedure
	Procedure.s GetDebugLogSorted(SortField.b, Order.b = #PB_Sort_Ascending, Level.a = 0, Flags.u = 0)
		Protected MsgData.AWLib_Debug_MessageData  
		Protected Msg.s, Offset, Type
		
		AWLib_DebugLog_Internal_CheckFlags(@Flags)
		
		Select SortField
			Case #DebugLog_Sort_Date
				Offset = OffsetOf(AWLib_Debug_MessageData\Date)
				Type = TypeOf(AWLib_Debug_MessageData\Date)
				
			Case #DebugLog_Sort_ID
				Offset = OffsetOf(AWLib_Debug_MessageData\ID)
				Type = TypeOf(AWLib_Debug_MessageData\ID)
				
			Case #DebugLog_Sort_Level
				Offset = OffsetOf(AWLib_Debug_MessageData\Level)
				Type = TypeOf(AWLib_Debug_MessageData\Level)
				
			Case #DebugLog_Sort_Msg
				Offset = OffsetOf(AWLib_Debug_MessageData\Msg)
				Type = TypeOf(AWLib_Debug_MessageData\Msg)  
		EndSelect
		
		NewList TempData.AWLib_Debug_MessageData()
		CopyList(DebugData\MsgData(), TempData())
		SortStructuredList(TempData(), Order, Offset, Type)
		
		ForEach TempData()
			MsgData = TempData()
			If Flags & #OnlyDebugLevel
				If MsgData\Level = Level
					AWLib_DebugLog_Internal_CreateMsg(@MsgData, Flags)
					Msg + MsgData\Msg + Chr(10)
				EndIf
			ElseIf MsgData\Level >= Level
				AWLib_DebugLog_Internal_CreateMsg(@MsgData, Flags)
				Msg + MsgData\Msg + Chr(10)
			EndIf      
		Next
		
		ProcedureReturn Msg
	EndProcedure
	Procedure.s GetLastLog(Flags.u = 0)
		Protected MsgData.AWLib_Debug_MessageData
		
		AWLib_DebugLog_Internal_CheckFlags(@Flags)
		
		MsgData = DebugData\MsgData()
		AWLib_DebugLog_Internal_CreateMsg(@MsgData, Flags)
		
		ProcedureReturn MsgData\Msg
	EndProcedure
	
EndModule

CompilerIf  #PB_Compiler_IsMainFile
	
	UseModule DebugLog
	
	;wird benötigt um DebugDaten auf der Console auszugeben
	OpenConsole("DebugLog Example")
	
	; Datum/Zeit/ID und Level standartmäßig anzeigen:
	SetDebugLogFlags(#ShowLogTime|#ShowMsgID|#ShowDebugLevel)
	
	; ein paar Einträge erzeugen mit Level 0 bis 2
	For i = 1 To 20
		DebugLog(Chr(117 - i) +"-Test " + Str(i), i % 3)  ; wird nur mit Debug ausgeben
		Delay(200)																				; kurze Wartezeit für verschiedene Zeiten
	Next
	
	; weitere Einträge ohne Debug aber mit Console ... außerdem wird nur die ID zusätzlich angezeigt
	For i = 21 To 25
		DebugLog("Mehr Tests: " + Str(i), 3, #ShowConsole|#ShowMsgID|#NoDebugOutput)
	Next
	
	; Einträge sortiert Ausgeben ... NUR DebugLevel 2 ... nur ID und DebugLevel anzeigen
	PrintN("----- Sortiert nach ID und nur LVL 2 -----")
	PrintN(GetDebugLogSorted(#DebugLog_Sort_ID, #PB_Sort_Ascending, 2, #OnlyDebugLevel|#ShowMsgID|#ShowDebugLevel))
	
	; weitere Beispiele:
	PrintN("----- DebugLevel 1 und höher anzeigen ... mit LvL und Zeit -----")
	PrintN(GetDebugLog(1, #ShowDebugLevel|#ShowLogTime))
	
	PrintN("----- ALLES anzeigen, sortiert nach Msg -----")
	PrintN(GetDebugLogSorted(#DebugLog_Sort_Msg, #PB_Sort_Ascending|#PB_Sort_NoCase, 0, #StandardFlags|#ShowLogDate))
	
	Debug "----- letzte Nachricht nochmal anzeigen nur Debug -----"
	ShowLastLog()
	
	PrintN("----- neues Format für Zeit/Datum) und letzte Nachricht anzeigen -----")
	SetDebugLogDateFormat("[Tag: %dd]")
	SetDebugLogTimeFormat("!Sek.%ss!Min.%ii!")
	PrintN(GetLastLog(#StandardFlags|#ShowLogDate))
	SetDebugLogDateFormat() ; Datum-Format zurücksetzen
	SetDebugLogTimeFormat()	; Zeit-Format zurücksetzen
	
	
	;warten auf Eingabe und Log speichern / Programm beenden
	
	Define File.s
	PrintN("Log speichern? ... J/N")    
	File = Input()            ; einfache Abfrage
	If File 
		If UCase(File) = "N"
			End
		EndIf
	Else
		End
	EndIf
	
	PrintN("----- Log speichern -----")
	File = ""
	File = SaveFileRequester("Log speichern", "Log.txt", "Text| *.txt", 0)
	If File
		CreateFile(0, File)
		WriteString(0, GetDebugLog(0, #ShowDebugLevel|#ShowLogDate|#ShowLogTime|#ShowMsgID))
		CloseFile(0)
		PrintN("Datei " + File + " gespeichert")
	Else
		PrintN("Speichern abgebrochen")
	EndIf
	
CompilerEndIf
