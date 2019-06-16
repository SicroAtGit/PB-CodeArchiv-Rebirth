;   Description: It uses the 2D-Drawing-Lib and draws text boxes
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27954
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014-2019 mk-soft
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

; -----------------------------------------------------------------------------------

; Kommentar     : DrawTextBox
; Author        : mk-soft
; Second Author :
; Original      : DrawTextBox.pbi
; Version       : 1.06r2
; Erstellt      : 20.04.2014
; Geändert      : 03.06.2019

; -----------------------------------------------------------------------------------

EnableExplicit

; -----------------------------------------------------------------------------------

EnumerationBinary TextBox
  #TEXT_Right
  #TEXT_HCenter
  #TEXT_VCenter
  #TEXT_Bottom
EndEnumeration

; -----------------------------------------------------------------------------------

Procedure DrawTextBox(x, y, dx, dy, text.s, flags = 0)

  Protected is_right, is_hcenter, is_vcenter, is_bottom
  Protected text_height
  Protected text_x, text_y, break_y
  Protected text2.s, rows, row, row_text.s, row_text1.s, out_text.s, start, count

  ; Flags
  is_right = flags & #TEXT_Right
  is_hcenter = flags & #TEXT_HCenter
  is_vcenter = flags & #TEXT_VCenter
  is_bottom = flags & #TEXT_Bottom

  ; Übersetze Zeilenumbrüche
  text = ReplaceString(text, #LFCR$, #LF$)
  text = ReplaceString(text, #CRLF$, #LF$)
  text = ReplaceString(text, #CR$, #LF$)

  ; Erforderliche Zeilenumbrüche setzen
  rows = CountString(text, #LF$)
  For row = 1 To rows + 1
    text2 = StringField(text, row, #LF$)
    If text2 = ""
      out_text + #LF$
      Continue
    EndIf
    start = 1
    count = CountString(text2, " ") + 1
    Repeat
      row_text = StringField(text2, start, " ") + " "
      Repeat
        start + 1
        row_text1 = StringField(text2, start, " ")
        If TextWidth(row_text + row_text1) < dx - 12
          row_text + row_text1 + " "
        Else
          Break
        EndIf
      Until start > count
      out_text + RTrim(row_text) + #LF$
    Until start > count
  Next

  ; Berechne Y-Position
  text_height = TextHeight("X")
  rows = CountString(out_text, #LF$)
  If is_vcenter
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      text_y = (dy / 2 - text_height / 2) - (text_height / 2 * (rows-1)) - 2
    CompilerElse
      text_y = (dy / 2 - text_height / 2) - (text_height / 2 * (rows-1))
    CompilerEndIf
  ElseIf is_bottom
    text_y = dy - (text_height * rows) - 2
  Else
    text_y = 2
  EndIf

  ; Korrigiere Y-Position
  While text_y < 2
    text_y = 2;+ text_height
  Wend

  break_y = dy - text_height / 2

  ; Text ausgeben
  For row = 1 To rows
    row_text = StringField(out_text, row, #LF$)
    If is_hcenter
      text_x = dx / 2 - TextWidth(row_text) / 2
    ElseIf is_right
      text_x = dx - TextWidth(row_text) - 4
    Else
      text_x = 4
    EndIf
    DrawText(x + text_x, y + text_y, row_text)
    text_y + text_height
    If text_y > break_y
      Break
    EndIf
  Next

  ProcedureReturn rows

EndProcedure

; -------------------------------------------------------------------------------------

Procedure.s WrapText(Width, Text.s, FontID = 0)
  Protected text2.s, rows, row, row_text.s, row_text1.s, out_text.s, start, count
  Static image
 
  If Not image
    image = CreateImage(#PB_Any, 16, 16)
  EndIf
 
  ; Übersetze Zeilenumbrüche
  text = ReplaceString(text, #LFCR$, #LF$)
  text = ReplaceString(text, #CRLF$, #LF$)
  text = ReplaceString(text, #CR$, #LF$)
 
  If StartDrawing(ImageOutput(image))
    If FontID
      DrawingFont(FontID)
    EndIf
    ; Erforderliche Zeilenumbrüche setzen
    rows = CountString(text, #LF$)
    For row = 1 To rows + 1
      text2 = StringField(text, row, #LF$)
      If text2 = ""
        out_text + #LF$
        Continue
      EndIf
      start = 1
      count = CountString(text2, " ") + 1
      Repeat
        row_text = StringField(text2, start, " ") + " "
        Repeat
          start + 1
          row_text1 = StringField(text2, start, " ")
          If TextWidth(row_text + row_text1) < Width - 12
            row_text + row_text1 + " "
          Else
            Break
          EndIf
        Until start > count
        out_text + RTrim(row_text) + #LF$
      Until start > count
    Next
    out_text = RTrim(out_text, #LF$)
    StopDrawing()
  EndIf
 
  ProcedureReturn out_text
 
EndProcedure

; *************************************************************************************

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
    #Canvas
  EndEnumeration

  ; *************************************************************************************
 
  Procedure.s GetDataSectionText(Addr)
    Protected result.s, temp.s
    While PeekC(Addr)
      temp = PeekS(Addr)
      Addr + StringByteLength(temp) + SizeOf(Character)
      result + temp
    Wend
    ProcedureReturn result
  EndProcedure
 
  ; -------------------------------------------------------------------------------------

  Procedure Draw(output, text.s)

    Define hfont = LoadFont(0, "Arial", 12);, #PB_Font_Bold)

    If  StartDrawing(output)
      DrawingFont(hfont)
      DrawingMode(#PB_2DDrawing_Transparent)

      Box(10, 10, 400, 200, $FF901E)
      DrawTextBox(10, 10, 400, 200, text)

      Box(10, 220, 400, 200,$E16941)
      DrawTextBox(10, 220, 400, 200, text, #TEXT_VCenter)

      Box(10, 430, 400, 200,$FF0000)
      DrawTextBox(10, 430, 400, 200, text, #TEXT_Bottom)

      Box(420, 10, 200, 200, $0045FF)
      DrawTextBox(420, 10, 200, 200, text, #TEXT_HCenter)

      Box(420, 220, 200, 200, $00008B)
      DrawTextBox(420, 220, 200, 200, text, #TEXT_HCenter | #TEXT_VCenter)

      Box(420, 430, 200, 200, $20A5DA)
      DrawTextBox(420, 430, 200, 200, text, #TEXT_HCenter | #TEXT_Bottom)

      Box(630, 10, 400, 200, $238E6B)
      DrawTextBox(630, 10, 400, 200, text, #TEXT_Right)

      Box(630, 220, 400, 200, $006400)
      DrawTextBox(630, 220, 400, 200, text, #TEXT_Right | #TEXT_VCenter)

      Box(630, 430, 400, 200, $32CD32)
      DrawTextBox(630, 430, 400, 200, text, #TEXT_Right | #TEXT_Bottom)

      StopDrawing()
    EndIf

  EndProcedure
 
  ; -------------------------------------------------------------------------------------

  ;- Globale Variablen
  Global exit = 0

  ;- Fenster
  Define style = #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget
  If OpenWindow(#Window, #PB_Ignore, #PB_Ignore, 1200, 800, "DrawTextBox", style)
    ; Menu
    If CreateMenu(#Menu, WindowID(#Window))
      MenuTitle("&File")
        MenuItem(#Menu_Exit, "&Exit")
    EndIf
    ; Statusbar
    CreateStatusBar(#Statusbar, WindowID(#Window))
    AddStatusBarField(#PB_Ignore)
    StatusBarText(#Statusbar, 0, "Example DrawTextbox")

    ; Gadgets
    CanvasGadget(#Canvas, 0, 0, WindowWidth(#Window), WindowHeight(#Window) - MenuHeight() - StatusBarHeight(#Statusbar))

    Define t1.s = GetDataSectionText(?Text1)

    Draw(CanvasOutput(#Canvas), t1)
   
    MessageRequester("WrapText",  WrapText(250, t1))
   
    ;-- Hauptschleife
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_Menu                       ; ein Menü wurde ausgewählt
          Select EventMenu()
            Case #Menu_Exit
              Exit = 1
            CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
            Case #PB_Menu_Quit
              Exit = 1
            CompilerEndIf
          EndSelect
        Case #PB_Event_CloseWindow                ; das Schließgadget vom Fenster wurde gedrückt
          Exit = 1

      EndSelect

    Until Exit
  EndIf
 
  DataSection
    Text1:
    Data.s "PureBasic is a native 32-bit and 64-bit programming language based on established BASIC rules."
    Data.s "The key features of PureBasic are portability (Windows, Linux And MacOS X are currently supported),"
    Data.s "the production of very fast And highly optimized executables And, of course, the very simple BASIC syntax."
    Data.i 0
    Text2:
    Data.s "PureBasic has been created For the beginner And expert alike."
    Data.s "We have put a lot of effort into its realization To produce a fast, reliable system friendly language."
    Data.s "In spite of its beginner-friendly syntax, the possibilities are endless With PureBasic's advanced "
    Data.s "features such As pointers, structures, procedures, dynamically linked lists And much more."
    Data.s "Experienced coders will have no problem gaining access To any of the legal OS structures"
    Data.s "Or API objects And PureBasic even allows inline ASM."
    Data.i 0
  EndDataSection

CompilerEndIf
