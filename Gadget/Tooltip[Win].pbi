;   Description: Show Custom Tooltip 
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27773&start=10#p323826
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

Procedure Tooltip (sText.s , sTitel.s = "", sSymbol.s = "kein", iX_Pos.i = #PB_Default, iY_Pos.i = #PB_Default, iMax_Breite.i = #PB_Default, bBallon.i = #False, bSchliessen.i = #False)
  
  #TTF_ABSOLUTE      = $0080
  #TTF_TRACK         = $0020
  #TTS_CLOSE         = $80
  #TTS_NOFADE         = $20
  
  Static      iTooltip_ID.i      = 0
  Static      iStyle_aktuell.i   = 0
  Static      iX_Pos_aktuell.i   = 0
  Static      iY_Pos_aktuell.i   = 0   
  Static      sText_aktuell.s      = ""
  Static      sTitel_aktuell.s   = ""
  Static      sSymbol_aktuell.s   = ""
  
  Protected    iUpdate_Inhalt.i   = #False
  Protected    iUpdate_Position.i   = #False
  Protected   iX_Pos_Offset.i      = 0
  Protected   iY_Pos_Offset.i      = 0
  
  Protected   iSymbol.i         = 0
  Protected   iStyle.i         = #WS_POPUP | #TTS_NOPREFIX | #TTS_ALWAYSTIP | #TTS_NOFADE
  Protected   iExStyle.i         = #WS_EX_TOPMOST
  Protected    lWindowID.l         = 0   ; experimentell: WindowID angeben, falls es Probleme mit der Darstellung gibt
  Protected   iInstanz.i         = GetModuleHandle_(0)
  Protected   lPosition.l         = 0
  
  Protected   stParameter.TOOLINFO
  Protected   stAbmessungen.RECT
  Static temp = 0
  
  ; Tooltip löschen, wenn kein Text angegeben wurde
  If sText = "" And iTooltip_ID <> 0
    DestroyWindow_(iTooltip_ID)
    iTooltip_ID    = 0
    iStyle_aktuell    = 0
    iX_Pos_aktuell   = 0
    iY_Pos_aktuell   = 0
    sText_aktuell    = ""
    sTitel_aktuell    = ""
    sSymbol_aktuell   = ""
    ProcedureReturn 1
    
  ElseIf sText = "" And iTooltip_ID = 0
    iTooltip_ID    = 0
    iStyle_aktuell    = 0
    iX_Pos_aktuell   = 0
    iY_Pos_aktuell   = 0
    sText_aktuell    = ""
    sTitel_aktuell    = ""
    sSymbol_aktuell   = ""
    ProcedureReturn -1
    
  EndIf
  
  
  ; darzustellendes Symbol
  If       sSymbol = "kein":         iSymbol = #TTI_NONE
  ElseIf    sSymbol = "Info":         iSymbol = #TTI_INFO
  ElseIf    sSymbol = "Warnung":      iSymbol = #TTI_WARNING
  ElseIf    sSymbol = "Fehler":         iSymbol = #TTI_ERROR
  ElseIf    sSymbol = "Info_groß":      iSymbol = #TTI_INFO_LARGE
  ElseIf    sSymbol = "Warnung_groß":   iSymbol = #TTI_WARNING_LARGE
  ElseIf    sSymbol = "Fehler_groß":   iSymbol = #TTI_ERROR_LARGE
  Else:                         iSymbol = #TTI_NONE
  EndIf
  
  
  ; X-Position bestimmen (Standard: aktuelle Mausposition)
  If (iX_Pos = #PB_Default) And (bBallon = #True)
    iX_Pos = DesktopMouseX()
    iX_Pos_Offset = 0
    
  ElseIf (iX_Pos = #PB_Default) And (bBallon = #False)
    iX_Pos    = DesktopMouseX()
    iX_Pos_Offset = 16
  EndIf
  
  
  ; Y-Position bestimmen (Standard: aktuelle Mausposition)
  If iY_Pos = #PB_Default
    iY_Pos = DesktopMouseY()
    iY_Pos_Offset = 0
    
  EndIf   
  
  
  ; maximale Breite festlegen
  If (iMax_Breite = #PB_Default) Or (iMax_Breite < 10)
    iMax_Breite = 400
    
  EndIf   
  
  
  ; ggf. Ballonform aktivieren
  If bBallon = #True
    iStyle | #TTS_BALLOON
  EndIf
  
  
  ; ggf. den Schließen-Button anzeigen (Ballonform muss aktiviert sein)
  If bSchliessen = #True
    iStyle | #TTS_CLOSE
  EndIf
  
  
  ; prüfen, ob schon ein Tooltip existiert
  If iTooltip_ID = 0
    iTooltip_ID = CreateWindowEx_(iExStyle, #TOOLTIPS_CLASS, #Null, iStyle, 0, 0, 0, 0, lWindowID, 0, iInstanz, 0)
  Else
    If iStyle_aktuell <> iStyle
      DestroyWindow_(iTooltip_ID)
      iTooltip_ID = CreateWindowEx_(iExStyle, #TOOLTIPS_CLASS, #Null, iStyle, 0, 0, 0, 0, lWindowID, 0, iInstanz, 0)
    EndIf
  EndIf
  
  
  ; Eigenschaften übernehmen und anzeigen
  stParameter.TOOLINFO\cbSize   = SizeOf(TOOLINFO)
  stParameter\uFlags         = #TTF_IDISHWND | #TTF_ABSOLUTE | #TTF_TRACK
  stParameter\hWnd         = lWindowID
  stParameter\uId            = lWindowID
  stParameter\lpszText      = @sText
  stParameter\hInst         = iInstanz
  
  
  ; prüfen, ob die Position oder der Inhalt geändert wurde
  If (sText <> sText_aktuell) Or (sTitel <> sTitel_aktuell) Or (sSymbol <> sSymbol_aktuell) Or (sText_aktuell = "")
    iUpdate_Inhalt      = #True
  Else
    iUpdate_Inhalt      = #False
  EndIf
  
  
  If (iX_Pos <> iX_Pos_aktuell) Or (iY_Pos <> iY_Pos_aktuell)
    iUpdate_Position   = #True
  Else
    iUpdate_Position   = #False
  EndIf
  
  
  ; aktuelle Daten speichern
  iStyle_aktuell   = iStyle
  sText_aktuell    = sText
  sTitel_aktuell    = sTitel
  sSymbol_aktuell = sSymbol
  iX_Pos_aktuell   = iX_Pos
  iY_Pos_aktuell   = iY_Pos
  
  
  ; Tooltip-Inhalt übernehmen und darstellen
  If iUpdate_Inhalt = #True
    
    SendMessage_   (iTooltip_ID,   #TTM_SETTIPTEXTCOLOR,   GetSysColor_(#COLOR_INFOTEXT),   0)
    SendMessage_   (iTooltip_ID,   #TTM_SETTIPBKCOLOR,      GetSysColor_(#COLOR_INFOBK),   0)
    SendMessage_   (iTooltip_ID,   #TTM_SETMAXTIPWIDTH,   0, iMax_Breite)   
    SendMessage_   (iTooltip_ID,   #TTM_SETTITLE,          iSymbol, @sTitel)
    
    GetWindowRect_   (lWindowID,    @stParameter\rect)
    SendMessage_   (iTooltip_ID,    #TTM_ADDTOOL,       0, @stParameter)
    SendMessage_   (iTooltip_ID,    #TTM_TRACKACTIVATE, 1, @stParameter)
    SendMessage_   (iTooltip_ID,   #TTM_UPDATETIPTEXT, 0, @stParameter)      
    
  EndIf
  
  
  If iUpdate_Position = #True
    
    ; die Position des Tooltips anpassen
    If (ExamineDesktops() <> 0)
      
      ; die Abmessung des Tooltips ermitteln
      GetWindowRect_   (iTooltip_ID, @stAbmessungen)
      
      If (iX_Pos + iX_Pos_Offset +(stAbmessungen\right - stAbmessungen\left) > DesktopWidth(0))
        iX_Pos = iX_Pos - iX_Pos_Offset - (stAbmessungen\right - stAbmessungen\left)
      Else
        iX_Pos = iX_Pos + iX_Pos_Offset
      EndIf
      
      If (iY_Pos + iY_Pos_Offset +(stAbmessungen\bottom - stAbmessungen\top) > DesktopHeight(0))
        iY_Pos = iY_Pos - (stAbmessungen\bottom - stAbmessungen\top)
      Else
        iY_Pos = iY_Pos + iY_Pos_Offset
      EndIf
      
    EndIf
    
    lPosition = (iX_Pos & $FFFF) | ((iY_Pos & $FFFF) << 16)
    SendMessage_   (iTooltip_ID,   #TTM_TRACKPOSITION,    0, lPosition)
    
  EndIf
  
  ProcedureReturn 0
  
EndProcedure





;-Example
CompilerIf #PB_Compiler_IsMainFile
  OpenWindow   (0, 0, 0, 40, 30, "Tooltip", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  
  Repeat
    
    Text$ = "CPU-Name:" + #TAB$ + #TAB$ + CPUName() + #CRLF$
    Text$ + "Computer-Name:" + #TAB$ + #TAB$ + ComputerName() + #CRLF$
    Text$ + "RAM verfügbar:" + #TAB$ + #TAB$ + StrF(MemoryStatus(#PB_System_FreePhysical)/1048576,1) + " MB"
    
    Tooltip(Text$, "aktuelle Daten", "Info_groß", -1, -1 ,600)
    
  Until WaitWindowEvent(15) =  #PB_Event_CloseWindow
  
CompilerEndIf
