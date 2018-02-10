;   Description: Global keyboard tap
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=428417#p428417
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

EnableExplicit

#KeyDownMask      = 1 << 10
#FlagsChangedMask = 1 << 12

#kCGKeyboardEventKeycode = 9

ImportC ""
  CGEventTapCreate(tap, place, options, eventsOfInterest.q, callback, refcon)
  CGEventGetFlags.q(event)
  CGEventGetIntegerValueField.q(event, field)
EndImport

Define eventTap


Global SpeechSynthesizer = CocoaMessage(0, CocoaMessage(0, 0, "NSSpeechSynthesizer alloc"), "initWithVoice:", #nil)

ProcedureC eventTapFunction(proxy, type, event, refcon)
  Protected keyCode = CGEventGetIntegerValueField(event, #kCGKeyboardEventKeycode)
  Protected keyFlags = CGEventGetFlags(event) >> 16 & 255
  
  If keyCode = 53 And keyFlags & $80
    ; [fn] + [esc] pressed
    CocoaMessage(0, SpeechSynthesizer, "startSpeakingString:$", @"fn and esc pressed")
  EndIf
  
EndProcedure


If OpenWindow(0, 0, 0, 200, 30, "key tap", #PB_Window_SystemMenu | #PB_Window_Minimize | #PB_Window_NoActivate)
  
  eventTap = CGEventTapCreate(0, 0, 1, #KeyDownMask | #FlagsChangedMask, @eventTapFunction(), 0)
  If eventTap
    CocoaMessage(0, CocoaMessage(0, 0, "NSRunLoop currentRunLoop"), "addPort:", eventTap, "forMode:$", @"kCFRunLoopDefaultMode")
  EndIf
  
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf
