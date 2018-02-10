;   Description: Working with NSBlock
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=473875#p473875
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2015 wilbert
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

; Original Code: http://www.purebasic.fr/english/viewtopic.php?p=429632#p429632

CompilerIf #PB_Compiler_OS<>#PB_OS_MacOS
  CompilerError "MacOs only!"
CompilerEndIf

; *** NSBlock alternative module ***

; last update Okt 7, 2015

DeclareModule NSBlock
  
  Structure NSBlock
    *isa
    flags.l
    reserved.l
    *invoke
    *descriptor
  EndStructure
  
  Declare Block(*Invoke)
  
EndDeclareModule

Module NSBlock
  
  Structure NSBlockWithPtr
    *block.NSBlock
    _block.NSBlock
  EndStructure
  
  DataSection
    NSBlockPtr:
    !extern __NSConcreteStackBlock
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      !dq 0, __NSConcreteStackBlock, 0x20000000, 0
    CompilerElse
      !dd 0, __NSConcreteStackBlock, 0x20000000, 0, 0
    CompilerEndIf
    Data.i ?NSBlockDescriptor
    NSBlockDescriptor:
    Data.i 0, SizeOf(NSBlock), 0, 0
  EndDataSection
  
  Procedure Block(*Invoke)
    Protected *Block.NSBlockWithPtr = CocoaMessage(0, CocoaMessage(0, 0, "NSData dataWithBytes:", ?NSBlockPtr, "length:", SizeOf(NSBlockWithPtr)), "bytes")
    *Block\block = @*Block\_block
    *Block\_block\invoke = *Invoke
    ProcedureReturn *Block
  EndProcedure
  
EndModule

; *** End of NSBlock alternative module ***

;-Example
CompilerIf #PB_Compiler_IsMainFile
  UseModule NSBlock
  
  ProcedureC EventMonitor(*Block.NSBlock, Event)
    AddGadgetItem(0, -1, "test")
    ProcedureReturn Event
  EndProcedure
  
  ProcedureC BlockEnumeration(*Block.NSBlock, id, idx, *stop.Byte)
    Debug PeekS(CocoaMessage(0, id, "UTF8String"), -1, #PB_UTF8)
    If idx = 2
      *stop\b = #True; stop after index 2 (string 3)
    EndIf
  EndProcedure
  
  NSMutableArray = CocoaMessage(0, 0, "NSMutableArray arrayWithCapacity:", 3)
  CocoaMessage(0, NSMutableArray, "addObject:$", @"String 1")
  CocoaMessage(0, NSMutableArray, "addObject:$", @"String 2")
  CocoaMessage(0, NSMutableArray, "addObject:$", @"String 3")
  CocoaMessage(0, NSMutableArray, "addObject:$", @"String 4")
  CocoaMessage(0, NSMutableArray, "addObject:$", @"String 5")
  CocoaMessage(0, NSMutableArray, "enumerateObjectsUsingBlock:@", Block(@BlockEnumeration()))
  
  CocoaMessage(0, 0, "NSEvent addLocalMonitorForEventsMatchingMask:", 2, "handler:@", Block(@EventMonitor()))
  
  ; *** Main code ***
  
  If OpenWindow(0, 100, 200, 195, 260, "PureBasic Window", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget)
    EditorGadget(0, 10, 10, 175, 240)
    
    Repeat
    Until WaitWindowEvent() = #PB_Event_CloseWindow
    
  EndIf
CompilerEndIf
