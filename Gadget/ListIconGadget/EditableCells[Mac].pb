;   Description: Editable cells
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=448525#p448525
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 Shardik
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
  sel_registerName(MethodName.S)
  class_addMethod(Class.I, Selector.I, Implementation.I, Types.S)
EndImport

Procedure.S ConvertToUTF8(String.S)
  Protected UTF8String.S = Space(StringByteLength(String))
  PokeS(@UTF8String, String, -1, #PB_UTF8)
  ProcedureReturn UTF8String
EndProcedure

ProcedureC EditingFinishedCallback(Object.I, Selector.I, Notification.I)
  Protected EditedCell.I
  Protected EditedColumn.I = CocoaMessage(0, GadgetID(0), "editedColumn")
  Protected EditedRow.I = CocoaMessage(0, GadgetID(0), "editedRow")
  Protected EditedText.S
  
  EditedCell = CocoaMessage(0, Notification, "object")
  EditedText = PeekS(CocoaMessage(0, CocoaMessage(0, EditedCell, "stringValue"),
                                  "UTF8String"), -1, #PB_UTF8)
  SetGadgetItemText(0, EditedRow, EditedText, EditedColumn)
EndProcedure

Define CursorLocation.NSPoint
Define AppDelegate.I = CocoaMessage(0, CocoaMessage(0, 0,
                                                    "NSApplication sharedApplication"), "delegate")
Define DelegateClass.I = CocoaMessage(0, AppDelegate, "class")
Define NotificationCenter.I = CocoaMessage(0, 0,
                                           "NSNotificationCenter defaultCenter")
Define SelectedColumn.I
Define Selector.I = sel_registerName(ConvertToUTF8("textDidEndEditing:"))

OpenWindow(0, 200, 100, 430, 95, "Editable ListIconGadget demo")
ListIconGadget(0, 10, 10, WindowWidth(0) - 20, WindowHeight(0) - 20, "Name", 110)
AddGadgetColumn(0, 1, "Address", 292)
AddGadgetItem(0, -1, "Harry Rannit" + #LF$ + "12 Parliament Way, Battle Street, By the Bay")
AddGadgetItem(0, -1, "Ginger Brokeit" + #LF$ + "130 PureBasic Road, BigTown, CodeCity")
AddGadgetItem(0, -1, "Didi Foundit" + #LF$ + "321 Logo Drive, Mouse House, Downtown")
CocoaMessage(0, GadgetID(0), "setSelectionHighlightStyle:", -1)
class_addMethod(DelegateClass, Selector, @EditingFinishedCallback(), "v@:@")
CocoaMessage(0, NotificationCenter,
             "addObserver:", AppDelegate,
             "selector:", Selector,
             "name:$", @"NSControlTextDidEndEditingNotification",
             "object:", GadgetID(0))

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      Break
    Case #PB_Event_Gadget
      If EventGadget() = 0 And EventType() = #PB_EventType_LeftClick
        CursorLocation\x = WindowMouseX(0)
        CursorLocation\y = WindowHeight(0) - WindowMouseY(0)
        CocoaMessage(@CursorLocation, GadgetID(0),
                     "convertPoint:@", @CursorLocation, "fromView:", 0)
        SelectedColumn = CocoaMessage(0, GadgetID(0),
                                      "columnAtPoint:@", @CursorLocation)
        CocoaMessage(0, GadgetID(0),
                     "editColumn:", SelectedColumn,
                     "row:", GetGadgetState(0),
                     "withEvent:", 0,
                     "select:", #YES)
      EndIf
  EndSelect
ForEver
