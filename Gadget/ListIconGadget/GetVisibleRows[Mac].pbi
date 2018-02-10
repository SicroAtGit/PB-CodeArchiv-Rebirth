;   Description: Get the number of currently visible rows
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=420719#p420719
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013 Shardik
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

CompilerIf #PB_Compiler_OS<>#PB_OS_MacOS
  CompilerError "MacOs only!"
CompilerEndIf

EnableExplicit

Procedure.I GetVisibleRows(ListIconID.I)
  Protected ContentView.I
  Protected EnclosingScrollView.I
  Protected VisibleRange.NSRange
  Protected VisibleRect.NSRect
  
  ; ----- Get scroll view inside of ListIconGadget
  EnclosingScrollView = CocoaMessage(0, GadgetID(ListIconID), "enclosingScrollView")
  
  If EnclosingScrollView
    ContentView = CocoaMessage(0, EnclosingScrollView, "contentView")
    ; ----- Get visible area
    ;       (automatically subtract horizontal scrollbar if shown)
    CocoaMessage(@VisibleRect, ContentView, "documentVisibleRect")
    ; ----- Subtract border width
    If CocoaMessage(0, EnclosingScrollView, "borderType") > 0
      VisibleRect\size\height - 5
    EndIf
    ; ----- Get number of rows visible
    CocoaMessage(@VisibleRange, GadgetID(ListIconID), "rowsInRect:@", @VisibleRect)
    ProcedureReturn Int(VisibleRange\length)
  EndIf
EndProcedure



;-Example
CompilerIf #PB_Compiler_IsMainFile
  Define i.I
  
  OpenWindow(0, 200, 100, 300, 95, "Get visible rows", #PB_Window_SystemMenu | #PB_Window_SizeGadget)
  WindowBounds(0, WindowWidth(0), WindowHeight(0), WindowWidth(0) + 4, 500)
  ListIconGadget(0, 10, 10, WindowWidth(0) - 20, WindowHeight(0) - 20, "Column 1", 130)
  AddGadgetColumn(0, 1, "Column 2", 130)
  
  For i = 1 To 20
    AddGadgetItem(0, -1, "Row " + Str(i) + ", Column 1" + #LF$ + "Row " + Str(i) + ", Column 2")
  Next i
  
  ; -----Wait until ListIconGadget is initialized
  While WindowEvent() : Wend
  
  SetWindowTitle(0, "Visible rows: " + Str(GetVisibleRows(0)))
  
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow
        Break
      Case #PB_Event_SizeWindow
        ResizeGadget(0, #PB_Ignore, #PB_Ignore, WindowWidth(0) - 20, WindowHeight(0) - 20)
        SetWindowTitle(0, "Visible rows: " + Str(GetVisibleRows(0)))
    EndSelect
  ForEver
CompilerEndIf
