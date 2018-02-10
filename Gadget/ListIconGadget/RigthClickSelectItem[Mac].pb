;   Description: Select item using right-click
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=397000#p397000
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012 wilbert
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

Define AllowMultipleSelection = #YES

Define CursorLocation.NSPoint
Define ListIconGadgetID.i, SelectedRow.i, IndexSet.i

OpenWindow(0, 200, 100, 430, 125, "ListIcon Example")
ListIconGadget(0, 10, 10, WindowWidth(0) - 20, WindowHeight(0) - 50, "Name", 110)
AddGadgetColumn(0, 1, "Address", GadgetWidth(0) - GetGadgetItemAttribute(0, 0, #PB_ListIcon_ColumnWidth) - 8)
AddGadgetItem(0, -1, "Harry Rannit" + #LF$ + "12 Parliament Way, Battle Street, By the Bay")
AddGadgetItem(0, -1, "Ginger Brokeit" + #LF$ + "130 PureBasic Road, BigTown, CodeCity")
AddGadgetItem(0, -1, "Didi Foundit" + #LF$ + "321 Logo Drive, Mouse House, Downtown")

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_Gadget
      If EventGadget() = 0 And EventType() = #PB_EventType_RightClick
        CursorLocation\x = WindowMouseX(0)
        CursorLocation\y = WindowHeight(0) - WindowMouseY(0)
        ListIconGadgetID = GadgetID(0)
        CocoaMessage(@CursorLocation, ListIconGadgetID, "convertPoint:@", @CursorLocation, "fromView:", #nil)
        CocoaMessage(@SelectedRow, ListIconGadgetID, "rowAtPoint:@", @CursorLocation)
        
        SetGadgetState(0, SelectedRow)
        ;or this two lines:
        ;CocoaMessage(@IndexSet, 0, "NSIndexSet indexSetWithIndex:", SelectedRow)
        ;CocoaMessage(0, ListIconGadgetID, "selectRowIndexes:", IndexSet, "byExtendingSelection:", AllowMultipleSelection)
      EndIf
  EndSelect
ForEver
