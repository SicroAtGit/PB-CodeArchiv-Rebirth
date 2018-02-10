;   Description: Simple Editable ListIconGadget
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=20818
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2009 hjbremer
; Copyright (c) 2014 ts-soft -- PB_Gadget_SendGadgetCommand() replaced with PostEvent()
; Copyright (c) 2015 GPI -- bugfix
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
; ListIconGadget Felder editieren
;
; Aufruf: im Hauptprogramm nur eine Zeile einfügen, direkt nach
;         event = WaitWindowEvent() kommt
;         event = LvEdit1(event)
;
; zusätzlicher Parameter selflag 0, 1 oder 2
;         event = WaitWindowEvent()
;         event = LvEdit1(event, 1)
;         0 = Cursor am Anfang, nur nötig wenn font angegeben
;         1 = Cursor ans Ende
;         2 = Cursor ans Ende + Feldinhalt wird markiert
;
; zusätzlicher Parameter font
;         event = WaitWindowEvent()
;         event = LvEdit1(event, 0, fontnr)
;         Die fontnr muß eine PbNr sein, keine ID
;         Wird ein Font angegeben sollte dieser auch geladen sein.
;         Ohne fontnr wird ein etwas kleinerer Font geladen
;         
; mit Doppelclick auf ein Feld wird Edit aktiviert
; mit ESC oder ein Klick auf ein Feld/Gadget/Window wird Edit beendet
;
; NUR mit Return werden Eingaben übernommen !
;
; zusätzlicher Spielkram
; wenn eine Zeile markiert und F2 gedrückt wird,
; wird Edit aktiviert und zwar das Feld in dem die Maus sich befindet.
; Nun mit Pfeiltasten oder Maus eine andere Zeile wählen, F2 drücken
; und nächstes Feld in der gleichen Spalte bearbeiten.
; Diesen "F2-Modus" mit Doppelclick auf ein Feld wieder ausschalten

EnableExplicit

Procedure LvFontHoehe(pbnr)
  Protected lg.LOGFONT
  Protected fontid = GetGadgetFont(pbnr)
  Protected pixely = GetDeviceCaps_(GetDC_(0), #LOGPIXELSY)
  Protected retvalue = GetObject_(fontid, SizeOf(LOGFONT), lg)
  Protected fonthoehe = -MulDiv_(lg\lfHeight, 72, pixely)   
  
  ProcedureReturn fonthoehe
EndProcedure

Procedure LvMausclick(lvid,*p.Point)
  Protected lvhit.LVHITTESTINFO
  
  GetCursorPos_(*p)  ;wo ist Maus
  MapWindowPoints_(0, lvid, *p, 1)
  
  lvhit\pt\x = *p\x
  lvhit\pt\y = *p\y
  SendMessage_(lvid, #LVM_SUBITEMHITTEST, 0, lvhit)               
  
  *p\y = lvhit\iItem      ;row ab 0
  *p\x = lvhit\iSubItem   ;col ab 0
  
EndProcedure

Procedure LvEdit1(event, selflag = 0, font = -1)
  Protected flag, x, y, br, hh, nix, iitem$
  Protected rect.RECT
  Protected point.POINT
  
  Static lvid, lvnr, lvhd, lvrow, lvcol, editfeld, editfont, f2flag
  
  If editfeld
    
    Select event
        
      Case 161 ;Scrollbalken Keyup
               ;Edit beeenden
        flag = 3
        
      Case #WM_KEYDOWN
        ;Edit beeenden wenn ESC oder Return
        If EventwParam() = #VK_RETURN: flag = 2: EndIf
        If EventwParam() = #VK_ESCAPE: flag = 1: EndIf
        
      Case #PB_Event_Gadget
        ;Edit beeenden wenn LostFocus
        If EventGadget() = editfeld
          If EventType() = #PB_EventType_LostFocus
            flag = 1
          EndIf
        Else  ;oder irgendein anderes Gadget angeclickt
          flag = 1
        EndIf
        
      Case #PB_Event_Menu, #PB_Event_SysTray  ;bei Bedarf mehr Events
        flag = 1                              ;Edit beeenden
        
    EndSelect
    
    ;Header angeclickt ? wenn ja Edit Ende
    If GetCapture_() = lvhd: flag = 1: EndIf
    
    If flag  ;Edit beenden
      
      SetGadgetState(lvnr,lvrow)
      
      ;Return gedrückt
      If flag = 2
        iitem$ = GetGadgetText(editfeld)
        SetGadgetItemText(lvnr, lvrow, iitem$, lvcol)
      EndIf
      
      ;neu zeichnen falls Liste verschoben
      If flag = 3
        SendMessage_(lvid, #WM_SETREDRAW, #True, 0)
        InvalidateRect_(lvid, 0, #True)           
      EndIf
      
      FreeGadget(editfeld): editfeld = 0
      If font = -1: FreeFont(editfont): EndIf
      
    EndIf
    
  ElseIf event = #PB_Event_Gadget
    
    lvnr = EventGadget()
    If IsGadget(lvnr) = 0: ProcedureReturn -1: EndIf
    
    If GadgetType(lvnr) = #PB_GadgetType_ListIcon
      
      If EventType() = #PB_EventType_LeftDoubleClick
        
        lvid = GadgetID(lvnr)
        lvhd = SendMessage_(lvid, #LVM_GETHEADER, 0, 0)
        
        LvMausclick(lvid, point)           
        If f2flag = 0
          lvcol = point\x
          lvrow = point\y
        Else
          lvrow = GetGadgetState(lvnr)   
        EndIf           
        If lvrow = -1: ProcedureReturn -1: EndIf
        
        rect\top = lvcol
        rect\left = #LVIR_LABEL
        SendMessage_(lvid, #LVM_GETSUBITEMRECT , lvrow, rect)
        
        InflateRect_(rect,1,1)  ;rect um 1 vergrößern   
        
        x  = rect\left + 1
        y  = rect\top
        br = rect\right - rect\left
        hh = rect\bottom - rect\top
        
        iitem$ =GetGadgetItemText(lvnr, lvrow, lvcol)
        editfeld = StringGadget(#PB_Any, x, y, br, hh,"")
        SetGadgetText(editfeld,iitem$)
        
        If font = -1
          editfont = LoadFont(#PB_Any, "Arial", LvFontHoehe(lvnr) - 1)
        Else
          editfont = font
        EndIf
        If IsFont(editfont): SetGadgetFont(editfeld,FontID(editfont)): EndIf
        
        If selflag = 1      ;ans Ende
          SendMessage_(GadgetID(editfeld), #EM_SETSEL, Len(iitem$), -1)               
        ElseIf selflag = 2  ;ans Ende + alles markieren
          SendMessage_(GadgetID(editfeld), #EM_SETSEL, 0, -1)
        EndIf
        
        ;sieht besser aus finde ich
        SetWindowTheme_(GadgetID(editfeld), @nix, @nix)
        
        SetParent_(GadgetID(editfeld), lvid)  ;sehr wichtig
        SetActiveGadget(editfeld)
        
      EndIf
    EndIf     
    
  ElseIf event = #WM_KEYDOWN  ;etwas Spielkram
    
    If EventwParam() = #VK_F2
      lvnr = GetActiveGadget()
      If IsGadget(lvnr)
        If GadgetType(lvnr) = #PB_GadgetType_ListIcon
          f2flag = 1
          PostEvent(#PB_EventType_LeftDoubleClick, -1, GadgetID(lvnr))
        EndIf
      EndIf       
    EndIf
    
  ElseIf event = #WM_LBUTTONDBLCLK  ;beim nächsten Doubleclick auf null
    f2flag = 0   
  EndIf
  
  ProcedureReturn event
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  DisableExplicit
  ;XIncludeFile "\Bremer\PureBasic430_Pbi\LvEdit1.pbi"
  
  Enumeration
    #but1
    #lvg1
    #lvg2
    #lvg3
    #win1
    #font
    #font1
  EndEnumeration
  
  LoadFont(#font, "Arial", 10)
  LoadFont(#font1, "Arial", 8)
  
  OpenWindow(#win1,0,0,800,480,"ListIcon Gadget",#PB_Window_SystemMenu|1)
  
  ButtonGadget(#but1,10,440,80,25,"Tue nix")
  
  lvflags = #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#PB_ListIcon_CheckBoxes ;|#LVS_NOCOLUMNHEADER)
  ListIconGadget(#lvg1,10,10,280,400,"Spalte 0",140,lvflags)
  AddGadgetColumn(#lvg1,1,"Spalte 1",55)
  AddGadgetColumn(#lvg1,2,"Spalte 2",55)
  SetGadgetFont(#lvg1,FontID(#font))
  SetGadgetColor(#lvg1, #PB_Gadget_BackColor, #Yellow)
  
  lvflags = #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#LVS_NOCOLUMNHEADER
  ListIconGadget(#lvg2,300,10,220,400,"Spalte 0",140,lvflags)
  AddGadgetColumn(#lvg2,1,"Spalte 1",55)
  SetGadgetFont(#lvg2,FontID(#font))
  
  lvflags = #PB_ListIcon_GridLines
  ListIconGadget(#lvg3,530,10,220,400,"Spalte 0",140,lvflags)
  AddGadgetColumn(#lvg3,1,"Spalte 1",55)
  SetGadgetFont(#lvg3,FontID(#font))
  
  For i = 0 To 16
    nr$ = LSet(Str(i),3," ")
    txt$ = "Text in Zeile "+nr$+" in Spalte 0" + #LF$ + Str(Random(111))
    AddGadgetItem(#lvg1, -1, txt$)           
    AddGadgetItem(#lvg2, -1, txt$)           
    AddGadgetItem(#lvg3, -1, txt$)           
  Next
  
  ;=====================================================
  
  Repeat
    
    event = WaitWindowEvent(1)
    event = LvEdit1(event, 2)
    
    If Event = #PB_Event_Gadget Or Event = #PB_Event_Menu
      
      welcherButton = EventGadget()
      
      Select welcherButton
          
        Case #but1: Debug "Button 1 gedrückt"
          Case #lvg1: If EventType() = #PB_EventType_LeftClick
            ;LvMausclick kann auch separat benutzt werden
            LvMausclick(GadgetID(#lvg1),p.Point)
            Debug "lv1 " + Str(p\x) + " " + Str(p\y)
          EndIf                             
      EndSelect
      
    EndIf
    
  Until event = #PB_Event_CloseWindow
  
  End
CompilerEndIf
