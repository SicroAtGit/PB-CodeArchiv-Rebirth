;   Description: Tapping keyboard and mouse events using CGEvent
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=411225#p411225
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

#LeftMouseDownMask      = 1 << 1
#LeftMouseUpMask        = 1 << 2
#RightMouseDownMask     = 1 << 3
#RightMouseUpMask       = 1 << 4
#MouseMovedMask         = 1 << 5
#LeftMouseDraggedMask   = 1 << 6
#RightMouseDraggedMask  = 1 << 7
#KeyDownMask            = 1 << 10
#KeyUpMask              = 1 << 11
#FlagsChangedMask       = 1 << 12
#ScrollWheelMask        = 1 << 22
#OtherMouseDownMask     = 1 << 25
#OtherMouseUpMask       = 1 << 26
#OtherMouseDraggedMask  = 1 << 27

ImportC ""
  CFRunLoopAddCommonMode(rl, mode)
  CFRunLoopGetCurrent()
  CGEventTapCreateForPSN(*psn, place, options, eventsOfInterest.q, callback, refcon)
  GetCurrentProcess(*psn)
EndImport

DeclareC eventTapFunction(proxy, type, event, refcon)

CFRunLoopAddCommonMode(CFRunLoopGetCurrent(), CocoaMessage(0, 0, "NSString stringWithString:$", @"NSEventTrackingRunLoopMode"))
GetCurrentProcess(@psn.q)

mask = #LeftMouseDownMask | #LeftMouseUpMask
mask | #RightMouseDownMask | #RightMouseUpMask
mask | #LeftMouseDraggedMask | #RightMouseDraggedMask
mask | #KeyDownMask

eventTap = CGEventTapCreateForPSN(@psn, 0, 1, mask, @eventTapFunction(), 0)
If eventTap
  CocoaMessage(0, CocoaMessage(0, 0, "NSRunLoop currentRunLoop"), "addPort:", eventTap, "forMode:$", @"kCFRunLoopCommonModes")
EndIf

; callback function

ProcedureC eventTapFunction(proxy, type, event, refcon)
  Protected NSEvent, Window, View, Point.NSPoint
  Static dragObject
  If type > 0 And type < 29
    NSEvent = CocoaMessage(0, 0, "NSEvent eventWithCGEvent:", event)
    If NSEvent
      Window = CocoaMessage(0, NSEvent, "window")
      
      If Window
        CocoaMessage(@Point, NSEvent, "locationInWindow")
        View = CocoaMessage(0, CocoaMessage(0, Window, "contentView"), "hitTest:@", @Point)
        If type = 1
          dragObject = View
        ElseIf type = 2
          dragObject = 0
        EndIf
        Select View
            
          Case GadgetID(0)
            Debug "Gadget 0, event type :" + Str(type)         
            
          Case GadgetID(1)
            Debug "Gadget 1, event type :" + Str(type)         
            
          Case GadgetID(2)
            If dragObject = GadgetID(2) Or type = 2
              Debug "Gadget 2, value :" + Str(GetGadgetState(2))
            EndIf
            
        EndSelect
      Else
        If type = 10
          key.s = PeekS(CocoaMessage(0, CocoaMessage(0, NSEvent, "charactersIgnoringModifiers"), "UTF8String"), 1, #PB_UTF8)
          Debug "Key " + key + " pressed (key code : " + Str(CocoaMessage(0, NSEvent, "keyCode")) + ")"
        EndIf
      EndIf
      
    EndIf
  EndIf
EndProcedure


If OpenWindow(0, 0, 0, 220, 120, "ButtonGadgets", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  ButtonGadget(0, 10, 10, 200, 30, "Button 0")
  ButtonGadget(1, 10, 40, 200, 30, "Button 1")
  ScrollBarGadget(2, 10, 70, 200, 30, 0, 100, 1)
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf

CompilerIf #False ;second example
  EnableExplicit
  
  ImportC ""
    CGEventTapCreateForPSN(*psn, place, options, eventsOfInterest.q, callback, refcon)
    GetCurrentProcess(*psn)
  EndImport
  
  Define psn.q, eventTap
  DeclareC eventTapFunction(proxy, type, event, refcon)
  
  GetCurrentProcess(@psn)
  eventTap = CGEventTapCreateForPSN(@psn, 0, 1, 64, @eventTapFunction(), 0)
  If eventTap
    CocoaMessage(0, CocoaMessage(0, 0, "NSRunLoop currentRunLoop"), "addPort:", eventTap, "forMode:$", @"NSEventTrackingRunLoopMode")
  EndIf
  
  ; callback function
  
  ProcedureC eventTapFunction(proxy, type, event, refcon)
    Static Gadget0Value
    
    If GetGadgetState(0) <> Gadget0Value
      Gadget0Value = GetGadgetState(0)
      Debug "Gadget value :" + Str(Gadget0Value)
    EndIf
    
  EndProcedure
  
  
  ; *** test ***
  
  If OpenWindow(0, 0, 0, 220, 120, "ButtonGadgets", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    ScrollBarGadget(0, 10, 70, 200, 30, 0, 100, 1)
    Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
  EndIf
CompilerEndIf
