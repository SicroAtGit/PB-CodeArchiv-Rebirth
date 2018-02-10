;   Description: Recolor a button gadget using a Core Image Filter
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=392371#p392371
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

If OpenWindow(0, 0, 0, 220, 200, "CIFilter example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  ButtonGadget(0, 10, 10, 200, 30, "Button")
  
  Filter  = CocoaMessage(0, 0, "CIFilter filterWithName:$", @"CIColorMonochrome") ; create a CIColorMonochrome filter
  CocoaMessage(0, Filter, "setDefaults")                                          ; set the default values for the filter
  Color = CocoaMessage(0, 0, "CIColor colorWithString:$", @"1.0 0.7 0.3 1.0")     ; create a CIColor object from a RGBA string
  CocoaMessage(0, Filter, "setValue:", Color, "forKey:$", @"inputColor")          ; assign the color to the filter
  FilterArray = CocoaMessage(0, 0, "NSArray arrayWithObject:", Filter)            ; create an array with only the filter
  
  Button = GadgetID(0)
  CocoaMessage(0, Button, "setWantsLayer:", #YES)                                 ; the gadget needs a layer for the filter to work
  CocoaMessage(0, Button, "setContentFilters:", FilterArray)                      ; set the filter Array
  
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
  
EndIf
