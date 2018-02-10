;   Description: Access the address book
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=414714
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013 wilbert
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

ImportC "/System/Library/Frameworks/AddressBook.framework/AddressBook" : EndImport
#kABPrefixMatchCaseInsensitive = 10


Global NewList vCard.s()

Procedure GetCards()
  Protected enum = CocoaMessage(0, CocoaMessage(0, CocoaMessage(0, 0, "ABAddressBook sharedAddressBook"), "people"), "objectEnumerator")
  Protected obj = CocoaMessage(0, enum, "nextObject")
  ClearList(vCard())
  While obj
    AddElement(vCard())
    vCard() = PeekS(CocoaMessage(0, CocoaMessage(0, obj, "vCardRepresentation"), "bytes"), -1, #PB_UTF8)
    obj = CocoaMessage(0, enum, "nextObject")
  Wend
EndProcedure


Procedure.s FindEmailAddress(PartialAddress.s)
  Protected results.s, find, records, recordCount, emails, emailCount, i, j
  
  AddressBook = CocoaMessage(0, 0, "ABAddressBook sharedAddressBook")
  find = CocoaMessage(0, 0, "ABPerson searchElementForProperty:$", @"Email", "label:", #nil, "key:", #nil, "value:$", @PartialAddress, "comparison:", #kABPrefixMatchCaseInsensitive)
  records = CocoaMessage(0, AddressBook, "recordsMatchingSearchElement:", find)
  recordCount = CocoaMessage(0, records, "count")
  
  For i = 1 To recordCount
    emails = CocoaMessage(0, CocoaMessage(0, records, "objectAtIndex:", i - 1), "valueForProperty:$", @"Email")
    emailCount = CocoaMessage(0, emails, "count")
    For j = 1 To emailCount
      results + PeekS(CocoaMessage(0, CocoaMessage(0, emails, "valueAtIndex:", j - 1), "UTF8String"), -1, #PB_UTF8) + #LF$
    Next
  Next
  
  ProcedureReturn results
EndProcedure


CompilerIf #PB_Compiler_IsMainFile
  ;- Example 1
  
  If OpenWindow(0, 0, 0, 600, 400, "AddressBook example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    StringGadget(0, 10, 10, 580, 20, "")
    EditorGadget(1, 10, 40, 580, 350)
    Repeat
      
      SetGadgetText(1, FindEmailAddress(GetGadgetText(0)))
      
    Until WaitWindowEvent() = #PB_Event_CloseWindow
  EndIf
  
  
  ;-Example 2
  If OpenWindow(0, 0, 0, 600, 400, "AddressBook example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    EditorGadget(0, 10, 10, 580, 380)
    
    GetCards(); Get all address book entries as vCards
    
    ForEach vCard()
      AddGadgetItem(0, -1, vCard())
    Next
    
    Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
    
  EndIf
CompilerEndIf
