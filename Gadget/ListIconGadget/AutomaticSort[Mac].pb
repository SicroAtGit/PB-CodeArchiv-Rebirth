;   Description: Sorting data by clicking a column header
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=411680#p411680
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

ImportC ""
  sel_registerName(*MethodName)
  class_addMethod(Class.I, Selector.I, Implementation.I, *Types)
EndImport

Structure TableEntry
  Name.S
  Address.S
EndStructure

Enumeration #PB_Event_FirstCustomValue
  #PB_Event_ListIcon_SortAscending
  #PB_Event_ListIcon_SortDescending
EndEnumeration

Define AppDelegate.I
Define AscendingArrow.I
Define ColumnArray.I
Define DelegateClass.I
Define DescendingArrow.I
Define i.I
Define LastSortColumn.I
Define MethodName.S = "tableView:didClickTableColumn:"
Define *MethodNameBuffer
Define SortColumn.I
Define SortIsAscending.I
Define Types.S = "v@:@@"
Define *TypesBuffer

NewList Table.TableEntry()

ProcedureC LeftClickOnHeaderCellCallback(Object.I, Selector.I, View.I, Column.I)
  Shared AscendingArrow.I
  Shared DescendingArrow.I
  Shared SortColumn.I
  Shared SortIsAscending.I
  
  SortColumn = Column
  
  If SortIsAscending
    PostEvent(#PB_Event_ListIcon_SortDescending)
  Else
    PostEvent(#PB_Event_ListIcon_SortAscending)
  EndIf
  
  SortIsAscending ! 1
EndProcedure

Procedure SortListIcon(ListIconID.I, SortColumn.I)
  Shared Table()
  Shared SortIsAscending.I
  
  Protected ColumnIndex.I
  
  ColumnIndex = Val(PeekS(CocoaMessage(0, CocoaMessage(0, SortColumn, "identifier"), "UTF8String"), -1, #PB_UTF8))
  
  If SortIsAscending
    If ColumnIndex = 0
      SortStructuredList(Table(), #PB_Sort_Ascending, OffsetOf(TableEntry\Name), #PB_String)
    Else
      SortStructuredList(Table(), #PB_Sort_Ascending, OffsetOf(TableEntry\Address), #PB_String)
    EndIf
  Else
    If ColumnIndex = 0
      SortStructuredList(Table(), #PB_Sort_Descending, OffsetOf(TableEntry\Name), #PB_String)
    Else
      SortStructuredList(Table(), #PB_Sort_Descending, OffsetOf(TableEntry\Address), #PB_String)
    EndIf
  EndIf
  
  ClearGadgetItems(ListIconID)
  
  ForEach Table()
    AddGadgetItem(ListIconID, -1, Table()\Name + #LF$ + Table()\Address)
  Next
EndProcedure

*MethodNameBuffer = AllocateMemory(StringByteLength(MethodName, #PB_Ascii) + 1)
PokeS(*MethodNameBuffer, MethodName, -1, #PB_Ascii)
*TypesBuffer = AllocateMemory(StringByteLength(Types, #PB_Ascii) + 1)
PokeS(*TypesBuffer, Types, -1, #PB_Ascii)
AppDelegate = CocoaMessage(0, CocoaMessage(0, 0, "NSApplication sharedApplication"), "delegate")
DelegateClass = CocoaMessage(0, AppDelegate, "class")
class_addMethod(DelegateClass, sel_registerName(*MethodNameBuffer),  @LeftClickOnHeaderCellCallback(), *TypesBuffer)
FreeMemory(*MethodNameBuffer)
FreeMemory(*TypesBuffer)
OpenWindow(0, 200, 100, 430, 95, "Sort ListIcon with column click")

ListIconGadget(0, 10, 10, WindowWidth(0) - 20, WindowHeight(0) - 20, "Name", 110)
AddGadgetColumn(0, 1, "Address", GadgetWidth(0) - GetGadgetItemAttribute(0, 0, #PB_ListIcon_ColumnWidth) - 8)

For i = 1 To 3
  AddElement(Table())
  Read.S Table()\Name
  Read.S Table()\Address
Next i

ForEach Table()
  AddGadgetItem(0, -1, Table()\Name + #LF$ + Table()\Address)
Next

AscendingArrow = CocoaMessage(0, CocoaMessage(0, 0, "NSImage imageNamed:$", @"NSAscendingSortIndicator"), "retain")
DescendingArrow = CocoaMessage(0, CocoaMessage(0, 0, "NSImage imageNamed:$", @"NSDescendingSortIndicator"), "retain")

CocoaMessage(@ColumnArray, GadgetID(0), "tableColumns")
CocoaMessage(@SortColumn, ColumnArray, "objectAtIndex:", 0)
LastSortColumn = SortColumn
SortIsAscending = #True
SortListIcon(0, SortColumn)
CocoaMessage(0, GadgetID(0), "setIndicatorImage:", AscendingArrow, "inTableColumn:", SortColumn)
CocoaMessage(0, GadgetID(0), "setDelegate:", AppDelegate)

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_ListIcon_SortAscending
      If SortColumn <> LastSortColumn
        CocoaMessage(0, GadgetID(0), "setIndicatorImage:", 0, "inTableColumn:", LastSortColumn)
        LastSortColumn = SortColumn
      EndIf
      SortListIcon(0, SortColumn)
      CocoaMessage(0, GadgetID(0), "setIndicatorImage:", AscendingArrow, "inTableColumn:", SortColumn)
    Case #PB_Event_ListIcon_SortDescending
      If SortColumn <> LastSortColumn
        CocoaMessage(0, GadgetID(0), "setIndicatorImage:", 0, "inTableColumn:", LastSortColumn)
        LastSortColumn = SortColumn
      EndIf
      
      SortListIcon(0, SortColumn)
      CocoaMessage(0, GadgetID(0), "setIndicatorImage:", DescendingArrow, "inTableColumn:", SortColumn)
  EndSelect
ForEver

End

DataSection
  Data.S "Harry Rannit"
  Data.S "12 Parliament Way, Battle Street, By the Bay"
  Data.S "Ginger Brokeit"
  Data.S "330 PureBasic Road, BigTown, CodeCity"
  Data.S "Didi Foundit"
  Data.S "231 Logo Drive, Mouse House, Downtown"
EndDataSection
