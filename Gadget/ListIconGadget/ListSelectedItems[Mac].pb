;   Description: Find all selected items 
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=391395#p391395
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

Procedure ListSelectedItems(ListViewID.i)
  
  Protected.i SelectedIndexes = CocoaMessage(0, GadgetID(ListViewID), "selectedRowIndexes")
  Protected.i RowIndex = CocoaMessage(0, SelectedIndexes, "firstIndex")
  
  If RowIndex = #NSNotFound
    Debug "No items are currently selected!"
  Else
    Repeat
      Debug GetGadgetItemText(ListViewID, RowIndex)
      RowIndex = CocoaMessage(0, SelectedIndexes, "indexGreaterThanIndex:", RowIndex)
    Until RowIndex = #NSNotFound
  EndIf
  Debug ""
  
EndProcedure

Define.i i

OpenWindow(0, 270, 100, 210, 284, "Multi-selection demo")
ListViewGadget(0, 10, 10, WindowWidth(0) - 20, WindowHeight(0) - 50, #PB_ListView_MultiSelect)
ButtonGadget(1, (WindowWidth(0) - 140) / 2, WindowHeight(0) - 31, 140, 20, "List selected items")

For i = 1 To 12
  AddGadgetItem (0, -1, "Item " + Str(i) )
Next

SetGadgetState(0, 6)

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_Gadget
      If EventGadget() = 1
        If EventType() = #PB_EventType_LeftClick
          ListSelectedItems(0)
        EndIf
      EndIf
  EndSelect
ForEver
