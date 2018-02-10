;   Description: Find out the what class is behind a gadget
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=391571#p391571
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

Procedure.s ObjectInheritance(Object)
  
  Protected.i Result
  Protected.i MutableArray = CocoaMessage(0, 0, "NSMutableArray arrayWithCapacity:", 10)
  
  Repeat
    CocoaMessage(0, MutableArray, "addObject:", CocoaMessage(0, Object, "className"))
    CocoaMessage(@Object, Object, "superclass")
  Until Object = 0
  
  CocoaMessage(@Result, MutableArray, "componentsJoinedByString:$", @"  -->  ")
  CocoaMessage(@Result, Result, "UTF8String")
  
  ProcedureReturn PeekS(Result, -1, #PB_UTF8)
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  If OpenWindow(0, 0, 0, 220, 200, "Object Inheritance", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    
    ButtonGadget(0, 10, 10, 200, 20, "Button")
    
    Debug ObjectInheritance(GadgetID(0))
    
    Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
    
  EndIf
  
CompilerEndIf
