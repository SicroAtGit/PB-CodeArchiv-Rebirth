;   Description: Programmatically scroll row or column into visible part of ListIconGadget
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=393730#p393730
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012 Shardik
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

#NumberOfColumns = 10
#NumberOfRows    = 10

Define ColumnIndex.I
Define RowIndex.I
Define RowText.S
Define SelectedGadget.I

OpenWindow(0, 200, 100, 346, 200, "ListIcon Example")
ListIconGadget(0, 10, 10, WindowWidth(0) - 20, 90, "Column 1", 100, #PB_ListIcon_GridLines)

For ColumnIndex = 2 To #NumberOfColumns
  AddGadgetColumn(0, ColumnIndex - 1, "Column " + Str(ColumnIndex), 100)
Next ColumnIndex

For RowIndex = 1 To #NumberOfRows
  RowText = ""
  
  For ColumnIndex = 1 To #NumberOfColumns
    RowText + "Row " + Str(RowIndex) + ", Col " + Str(ColumnIndex)
    
    If ColumnIndex < #NumberOfColumns
      RowText + #LF$
    EndIf
  Next ColumnIndex
  
  AddGadgetItem(0, -1, RowText)
Next RowIndex

SetGadgetState(0, -1)

SpinGadget(1, 80, GadgetY(0) + GadgetHeight(0) + 60, 45, 20, 1, #NumberOfRows, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
SetGadgetState(1, 1)
SpinGadget(2, 220, GadgetY(0) + GadgetHeight(0) + 60, 45, 20, 1, #NumberOfColumns, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
SetGadgetState(2, 1)
TextGadget(3, 30, GadgetY(0) + GadgetHeight(0) + 20, 130, 40, "Scroll row into visible area:", #PB_Text_Center)
TextGadget(4, 170, GadgetY(0) + GadgetHeight(0) + 20, 140, 40, "Scroll column into visible area:", #PB_Text_Center)
Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_Gadget
      Select EventGadget()
        Case 1
          CocoaMessage(0, GadgetID(0), "scrollRowToVisible:", GetGadgetState(1) - 1)
        Case 2
          CocoaMessage(0, GadgetID(0), "scrollColumnToVisible:", GetGadgetState(2) - 1)
      EndSelect
  EndSelect
ForEver
