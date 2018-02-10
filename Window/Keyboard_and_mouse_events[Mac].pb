;   Description: Handling keyboard and mouse events
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=394079#p394079
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

#NSLeftMouseUp        = 2
#NSRightMouseUp       = 4
#NSMouseMoved         = 5
#NSKeyDown            = 10
#NSKeyUp              = 11
#NSScrollWheel        = 22

#NSAlphaShiftKeyMask = 1 << 16
#NSShiftKeyMask      = 1 << 17
#NSControlKeyMask    = 1 << 18
#NSAlternateKeyMask  = 1 << 19
#NSCommandKeyMask    = 1 << 20

EnableExplicit

Global sharedApplication = CocoaMessage(0, 0, "NSApplication sharedApplication")
Define currentEvent, type, modifierFlags, keyCode
Define clickCount, location.NSPoint, deltaX.CGFloat, deltaY.CGFloat
Define Event

If OpenWindow(0, 0, 0, 320, 170, "Events example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  EditorGadget(0, 10, 10, 300, 100, #PB_Editor_ReadOnly)
  
  Repeat
    
    Event = WaitWindowEvent()
    currentEvent = CocoaMessage(0, sharedApplication, "currentEvent")
    If currentEvent
      type = CocoaMessage(0, currentEvent, "type")
      modifierFlags = CocoaMessage(0, currentEvent, "modifierFlags")
      
      ClearGadgetItems(0)
      
      ; mouse events
      
      If type = #NSLeftMouseUp
        clickCount = CocoaMessage(0, currentEvent, "clickCount")
        SetGadgetText(0, "Left mouse " + Str(clickCount) + "x clicked")
      EndIf
      
      If type = #NSRightMouseUp
        clickCount = CocoaMessage(0, currentEvent, "clickCount")
        SetGadgetText(0, "Right mouse " + Str(clickCount) + "x clicked")
      EndIf
      
      If type = #NSMouseMoved
        CocoaMessage(@location, currentEvent, "locationInWindow")
        SetGadgetText(0, "Mouse moved to (" + StrF(location\x, 1) + "," + StrF(WindowHeight(0)-location\y, 1) + ")"); use WindowHeight() to flip y coordinate
      EndIf
      
      If type = #NSScrollWheel
        CocoaMessage(@deltaX, currentEvent, "deltaX")
        CocoaMessage(@deltaY, currentEvent, "deltaY")
        SetGadgetText(0, "Mouse wheel delta (" + StrF(deltaX, 1) + "," + StrF(deltaY, 1) + ")")
      EndIf
      
      ; keyboard events
      
      If type = #NSKeyDown
        keyCode = CocoaMessage(0, currentEvent, "keyCode")
        SetGadgetText(0, "Key down with code : " + Str(keyCode))
      EndIf
      
      If type = #NSKeyUp
        keyCode = CocoaMessage(0, currentEvent, "keyCode")
        SetGadgetText(0, "Key up with code : " + Str(keyCode))
      EndIf
      
      ; key modifiers
      
      If modifierFlags & #NSAlphaShiftKeyMask 
        AddGadgetItem(0, -1, "Caps lock is on")
      Else
        AddGadgetItem(0, -1, "Caps lock is off")
      EndIf
      If modifierFlags & #NSShiftKeyMask
        AddGadgetItem(0, -1, "Shift key is pressed")
      EndIf
      If modifierFlags & #NSControlKeyMask
        AddGadgetItem(0, -1, "Ctrl key is pressed")
      EndIf
      If modifierFlags & #NSAlternateKeyMask
        AddGadgetItem(0, -1, "Alt key is pressed")
      EndIf
      If modifierFlags & #NSCommandKeyMask
        AddGadgetItem(0, -1, "Cmd key is pressed")
      EndIf
      
    EndIf
    
  Until Event = #PB_Event_CloseWindow
EndIf
