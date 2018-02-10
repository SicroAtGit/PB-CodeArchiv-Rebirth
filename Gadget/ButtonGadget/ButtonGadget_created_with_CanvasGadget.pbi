;   Description: Button-Gadget created with CanvasGadget
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28903
;-----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 mk-soft
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

;-TOP
; Kommentar     : Modul MyGadgets
; Author        : mk-soft
; Second Author :
; Datei         : *.pb
; Version       : 1.03
; Erstellt      : 17.05.2015
; Geändert      : 17.05.2015
;
; Compilermode  : ASCII, Unicode
; OS            : All
;
; ***************************************************************************************

;- Modul Public

DeclareModule MyGadgets
  
  Declare ButtonColorGadget(id, x, y, dx, dy, text.s, flags = #PB_Button_Default)
  
  Interface iGadget
    GetID()
    GetHandle()
    GetType()
    FreeGadget()
    GetGadgetState()
    SetGadgetState(State)
    GetGadgetText.s()
    SetGadgetText(Text.s)
    GetGadgetColor(ColorType)
    SetGadgetColor(ColorType, Color)
    GetGadgetFont()
    SetGadgetFont(hFont)
    ResizeGadget(x, y, dx, dy)
  EndInterface
  
EndDeclareModule

; -------------------------------------------------------------------------------------

;- Modul Private

Module MyGadgets
  EnableExplicit
  
  ;-- Interne Konstanten
  #ButtonColorStateDefault = 0
  #ButtonColorStateOver = 1
  #ButtonColorStateDown = 2
  
  ;-- Interne Struktur
  Structure sGadget
    ; Basis
    *vt.iGadget ; Virtuelle Funktionstabelle. Nicht Verschieben!
    id.i        ; Gadget PB_ID
    type.i      ; Gadget Type
                ; Daten
    x.i
    y.i
    dx.i
    dy.i
    text.s
    flags.i
    state.i
    cstate.i
    style.i
    hFont.i
    frontcolor.i
    backcolor.i
    bordercolor.i
  EndStructure
  
  ;-- Interne Daten (Speicher)
  Global NewMap MyGadgetData.sGadget()
  
  ;-- Declare Interne Basisfunktionen
  Declare NewData(id)
  Declare FreeData(id)
  
  ;-- Declare Interne Funktionen
  Declare DrawButton(*sGadget)
  
  ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  ;-- Interface Funktionen
  
  Procedure MyGetID(*this.sGadget)
    
    Protected result
    
    With *this
      result = \id
    EndWith
    ProcedureReturn result
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure MyGetHandle(*this.sGadget)
    
    Protected result
    
    With *this
      If \type
        result = GadgetID(\id)
      EndIf
    EndWith
    ProcedureReturn result
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure MyGetType(*this.sGadget)
    
    Protected result
    
    With *this
      result = \type
    EndWith
    ProcedureReturn result
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure MyFreeGadget(*this.sGadget)
    
    Protected result
    
    With *this
      If \type
        If IsGadget(\id)
          FreeGadget(\id)
        EndIf
        result = FreeData(\id)
      EndIf
    EndWith
    ProcedureReturn result
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure MyGetGadgetState(*this.sGadget)
    
    Protected result
    
    With *this
      result = \state
    EndWith
    
    ProcedureReturn result
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure MySetGadgetState(*this.sGadget, State)
    
    Protected result
    
    With *this
      If \type
        \state = State
        Select \type
          Case #PB_GadgetType_Button : DrawButton(*this)
            
        EndSelect
      EndIf
    EndWith
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure.s MyGetGadgetText(*this.sGadget)
    
    Protected result.s
    
    With *this
      result = \text
    EndWith
    
    ProcedureReturn result
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure MySetGadgetText(*this.sGadget, Text.s)
    
    With *this
      If \type
        \text = Text
        Select \type
          Case #PB_GadgetType_Button : DrawButton(*this)
            
        EndSelect
      EndIf
    EndWith
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure MyGetGadgetColor(*this.sGadget, ColorType)
    
    Protected result
    
    With *this
      ; Code
      Select ColorType
        Case #PB_Gadget_BackColor
          result = \backcolor
        Case #PB_Gadget_FrontColor
          result = \frontcolor
        Case #PB_Gadget_LineColor
          result = \bordercolor
          
      EndSelect
      
    EndWith
    ProcedureReturn result
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure MySetGadgetColor(*this.sGadget, ColorType, Color)
    
    With *this
      If \type
        Select ColorType
          Case #PB_Gadget_BackColor
            \backcolor = Color
          Case #PB_Gadget_FrontColor
            \frontcolor = Color
          Case #PB_Gadget_LineColor
            \bordercolor = Color
            
        EndSelect
        Select \type
          Case #PB_GadgetType_Button : DrawButton(*this)
            
        EndSelect
      EndIf
    EndWith
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure MyGetGadgetFont(*this.sGadget)
    
    Protected result
    
    With *this
      result = \hFont
    EndWith
    ProcedureReturn result
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure MySetGadgetFont(*this.sGadget, hFont)
    
    With *this
      If \type
        If hFont
          \hFont = hFont
        Else
          \hFont = #PB_Default
        EndIf
        Select \type
          Case #PB_GadgetType_Button : DrawButton(*this)
            
        EndSelect
      EndIf
    EndWith
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure MyResizeGadget(*this.sGadget, x.i, y.i, width.i, height.i)
    
    With *this
      If \type
        If x <> #PB_Ignore
          \x = x
        EndIf
        If y <> #PB_Ignore
          \y = y
        EndIf
        If width <> #PB_Ignore
          \dx = width
        EndIf
        If height <> #PB_Ignore
          \dy = height
        EndIf
        Select \type
          Case #PB_GadgetType_Button
            ResizeGadget(\id, \x, \y, \dx, \dy)
            DrawButton(*this)
            
        EndSelect
      EndIf
    EndWith
    
  EndProcedure
  
  ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  ;-- Datenverwaltung
  
  DataSection
    vtGadget:
    Data.i @MyGetID()
    Data.i @MyGetHandle()
    Data.i @MyGetType()
    Data.i @MyFreeGadget()
    Data.i @MyGetGadgetState()
    Data.i @MySetGadgetState()
    Data.i @MyGetGadgetText()
    Data.i @MySetGadgetText()
    Data.i @MyGetGadgetColor()
    Data.i @MySetGadgetColor()
    Data.i @MyGetGadgetFont()
    Data.i @MySetGadgetFont()
    Data.i @MyResizeGadget()
  EndDataSection
  
  ; Init Nothing
  Global Nothing.sGadget
  With Nothing
    \vt = ?vtGadget
    \id = -1
  EndWith
  
  
  ; -------------------------------------------------------------------------------------
  
  Procedure NewData(id)
    
    Protected *new.sGadget, key.s
    
    key = "ID-" + Str(id)
    *new = AddMapElement(MyGadgetData(), key)
    If *new
      *new\vt = ?vtGadget
    EndIf
    
    ProcedureReturn *new
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure FreeData(id)
    
    Protected result, key.s
    
    key = "ID-" + Str(id)
    If FindMapElement(MyGadgetData(), key)
      DeleteMapElement(MyGadgetData())
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
    
  EndProcedure
  
  ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  ;-- Interne Funktionen
  
  Procedure DrawTextBox(x, y, dx, dy, text.s, flags)
    
    Protected is_multiline, is_left, is_right
    Protected text_width, text_height
    Protected text_x, text_y
    Protected rows , row_text.s, row_text1.s, start, count
    
    is_multiline = flags & #PB_Button_MultiLine
    is_left = flags & #PB_Button_Left
    is_right = flags & #PB_Button_Right
    
    text_width = TextWidth(text)
    text_height = TextHeight(text)
    
    If Not is_multiline
      If is_left
        text_x = 6
        text_y = dy / 2 - text_height / 2
      ElseIf is_right
        text_x = dx - text_width - 6
        text_y = dy / 2 - text_height / 2
      Else
        text_x = dx / 2 - text_width / 2
        text_y = dy / 2 - text_height / 2
      EndIf
      DrawText(x + text_x, y + text_y, text)
      ProcedureReturn 1
    EndIf
    
    rows = text_width / dx
    start = 1
    text_y = (dy / 2 - text_height / 2) - (text_height / 2 * rows)
    count = CountString(text, " ") + 1
    Repeat
      row_text = StringField(text, start, " ") + " "
      Repeat
        start + 1
        row_text1 = StringField(text, start, " ")
        If TextWidth(row_text + row_text1) < dx - 12
          row_text + row_text1 + " "
        Else
          Break
        EndIf
      Until start > count
      row_text = Trim(row_text)
      If is_left
        text_x = 6
      ElseIf is_right
        text_x = dx - TextWidth(row_text) - 6
      Else
        text_x = dx / 2 - TextWidth(row_text) / 2
      EndIf
      DrawText(x + text_x, y + text_y, row_text)
      text_y + text_height
    Until start > count
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure DrawButton(*this.sGadget)
    
    Protected backcolor, backcolor2, bordercolor2
    Protected dx, dy
    Protected text_width, text_height
    Protected text_x, text_y
    
    With *this
      
      If \cstate = #ButtonColorStateDown Or \state = 1
        backcolor = RGB(Red(\backcolor) * 85 / 100, Green(\backcolor) * 85 / 100, Blue(\backcolor) * 85 / 100)
        bordercolor2 = $00C0C0C0
      ElseIf \cstate = #ButtonColorStateOver
        backcolor = RGB(Red(\backcolor) * 95 / 100, Green(\backcolor) * 95 / 100, Blue(\backcolor) * 95 / 100)
        bordercolor2 = $00FFFFFF
      Else
        backcolor = \backcolor
        bordercolor2 = $00FFFFFF
      EndIf
      StartDrawing(CanvasOutput(\id))
      If \dx > 2 And \dy > 2
        If \style
          ; Style Windows 8
          Box(0, 0, \dx, \dy, \bordercolor)
          Box(1, 1, \dx - 2, \dy - 2, backColor)
        Else
          ; Style Windows 7
          backcolor2 = RGB(Red(backcolor) * 95 / 100, Green(backcolor) * 95 / 100, Blue(backcolor) * 95 / 100)
          Box(0, 0, \dx, \dy, \bordercolor)
          Box(1, 1, \dx - 2, \dy - 2, bordercolor2)
          dx = \dx - 4
          dy = (\dy - 4) / 2
          Box(2, 2, dx, dy, backColor)
          Box(2, 2 + dy, dx, dy, backcolor2)
          Plot(0, 0, $00FFFFFF) : Plot(\dx - 1, 0, $00FFFFFF) : Plot(0 ,\dy - 1, $00FFFFFF) : Plot(\dx - 1,\dy - 1, $00FFFFFF)
          Plot(1, 1, \bordercolor) : Plot(\dx - 2, 1, \bordercolor) : Plot(1 ,\dy - 2, \bordercolor) : Plot(\dx - 2,\dy - 2, \bordercolor)
          Plot(2, 2, bordercolor2) : Plot(\dx - 3, 2, bordercolor2) : Plot(2 ,\dy - 3, bordercolor2) : Plot(\dx - 3,\dy - 3, bordercolor2)
        EndIf
        If \hFont
          DrawingFont(\hFont)
        EndIf
        DrawingMode(#PB_2DDrawing_Transparent)
        FrontColor(\frontcolor)
        DrawTextBox(0, 0, \dx, \dy, \text, \flags)
      Else
        Box(0, 0, \dx, \dy, $00808080)
      EndIf
      StopDrawing() 
      
    EndWith
    
  EndProcedure
  
  ; -------------------------------------------------------------------------------------
  
  Procedure EventHandler_Button()
    
    Protected id, *this.sGadget, key.s
    
    id = EventGadget()
    If Not IsGadget(id)
      ProcedureReturn 0
    EndIf
    key = "ID-" + Str(id)
    *this = FindMapElement(MyGadgetData(), key)
    If *this
      With *this
        Select EventType()
          Case #PB_EventType_MouseEnter
            \cstate = #ButtonColorStateOver
            DrawButton(*this)
          Case #PB_EventType_MouseLeave
            \cstate = #ButtonColorStateDefault
            DrawButton(*this)
          Case #PB_EventType_LeftButtonDown
            \cstate = #ButtonColorStateDown
            DrawButton(*this)
          Case #PB_EventType_LeftButtonUp
            If \cstate = #ButtonColorStateDown
              \cstate = #ButtonColorStateOver
            Else
              \cstate = #ButtonColorStateDefault
            EndIf
            DrawButton(*this)
          Case #PB_EventType_LeftClick
            If \flags & #PB_Button_Toggle = #PB_Button_Toggle
              If \state
                \state = 0
              Else
                \state = 1
              EndIf
              DrawButton(*this)
            EndIf
            
        EndSelect
        
      EndWith
    EndIf
    
  EndProcedure
  
  ; *************************************************************************************
  
  ;-- Public Funktionen
  
  Procedure ButtonColorGadget(id, x, y, dx, dy, text.s, flags = #PB_Button_Default)
    
    Protected result, nr, *this.sGadget
    
    Repeat
      ; Gadget anlegen
      result = CanvasGadget(id, x, y , dx, dy)
      If result = 0
        *this = @Nothing
        Break
      EndIf
      If id = #PB_Any
        nr = result
      Else
        nr = id
      EndIf
      ; Eigene Daten anlegen
      *this = NewData(nr)
      If Not *this
        FreeGadget(nr)
        *this = @Nothing
        Break
      EndIf
      ; Eigene Daten zuweisen
      With *this
        \id = nr
        \type = #PB_GadgetType_Button
        \x = x
        \y = y
        \dx = dx
        \dy = dy
        \text = text
        \flags = flags
        \state = 0
        \cstate = #ButtonColorStateDefault
        \hFont = GetGadgetFont(#PB_Default)
        \frontcolor = $00000000
        \backcolor = $00F0F0F0
        \bordercolor = $00808080
        If OSVersion() >= #PB_OS_Windows_8 And OSVersion() <= #PB_OS_Windows_Future
          \style = 1
        Else
          \style = 0
        EndIf
      EndWith
      ; Zeichnen
      DrawButton(*this)
      ; Eventhandler setzen
      BindGadgetEvent(nr, @EventHandler_Button(), #PB_All)
    Until #True
    
    ProcedureReturn *this
    
  EndProcedure
  
  
EndModule

;- Modul Ende

; ***************************************************************************************

;- Example

CompilerIf #PB_Compiler_IsMainFile
  
  ;- Konstanten
  Enumeration ; Window ID
    #Window
  EndEnumeration
  
  Enumeration ; Menu ID
    #Menu
  EndEnumeration
  
  Enumeration ; MenuItem ID
    #Menu_Exit
  EndEnumeration
  
  Enumeration ; Statusbar ID
    #Statusbar
  EndEnumeration
  
  Enumeration ; Gadget ID
    
  EndEnumeration
  
  ; ***************************************************************************************
  
  ;- Globale Variablen
  
  UseModule MyGadgets
  
  Global exit = 0
  Global.iGadget *btn0, *btn1, *btn2
  
  ;- Fenster
  style = #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
  If OpenWindow(#Window, #PB_Ignore, #PB_Ignore, 500, 400, "Fenster", style)
    ; Menu
    If CreateMenu(#Menu, WindowID(#Window))
      MenuTitle("&Datei")
      MenuItem(#Menu_Exit, "Be&enden")
    EndIf
    ; Statusbar
    CreateStatusBar(#Statusbar, WindowID(#Window))
    ; Gadgets
    
    LoadFont(0, "Arial", 16)
    
    *btn0 = ButtonColorGadget(0, 10 ,10, 200, 40, "Button 1", #PB_Button_Left)
    
    *btn1 = ButtonColorGadget(1, 10 ,60, 200, 40, "Button 2", #PB_Button_MultiLine)
    *btn1\SetGadgetColor(#PB_Gadget_BackColor, $00FF4040)
    *btn1\SetGadgetColor(#PB_Gadget_FrontColor, $00FFFFFF)
    
    *btn1\SetGadgetFont(FontID(0))
    
    *btn2 = ButtonColorGadget(2, 10, 180, 200, 40, "Button 3", #PB_Button_Toggle | #PB_Button_Right)
    *btn2\SetGadgetColor(#PB_Gadget_BackColor, $008080FF)
    
    *btn1\ResizeGadget(10, 80, 200, 80)
    *btn1\SetGadgetText("Hello World! Button with multiline")
    
    Debug "Button 0"
    Debug *btn0\GetID()
    Debug *btn0\GetHandle()
    Debug *btn0\GetGadgetText()
    Debug "--------------------"
    
    Debug "Button 1"
    Debug *btn1\GetID()
    Debug *btn1\GetHandle()
    Debug *btn1\GetGadgetText()
    Debug "--------------------"
    
    Debug "Button 2"
    Debug *btn2\GetID()
    Debug *btn2\GetHandle()
    Debug *btn2\GetGadgetText()
    Debug "--------------------"
    
    ;-- Hauptschleife
    Repeat
      event   = WaitWindowEvent()
      Select event
        Case #PB_Event_Menu
          Select menu
            Case #Menu_Exit
              Exit = 1
          EndSelect
        Case #PB_Event_Gadget
          Select EventGadget()
            Case 0
              Select EventType()
                Case #PB_EventType_LeftClick
                  Debug "Button 1 Click"
                Case #PB_EventType_LeftButtonDown
                  Debug "Button 1 Down"
                Case #PB_EventType_LeftButtonUp
                  Debug "Button 1 Up"
              EndSelect
              
            Case 1
              If EventType() = #PB_EventType_LeftClick
                Debug "Button 2"
              EndIf
            Case 2
              If EventType() = #PB_EventType_LeftClick
                Debug "Button 3 State " + Str(*btn2\GetGadgetState())
              EndIf
              
          EndSelect
          
          
        Case #PB_Event_CloseWindow
          Exit = 1
          
      EndSelect
      
    Until Exit
  EndIf
  
  CloseWindow(#Window)
  
CompilerEndIf
