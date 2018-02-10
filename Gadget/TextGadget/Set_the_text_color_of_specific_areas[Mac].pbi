;   Description: Set the text color of specific areas
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=409758#p409758
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013, 2015 wilbert
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

Procedure SetTextColorABGR(TextGadget, Color, StartPosition, Length = -1, BackColor = #NO)
  Protected.CGFloat r,g,b,a
  Protected range.NSRange, MAString.i
  If StartPosition > 0
    
    MAString = CocoaMessage(0, CocoaMessage(0, 0, "NSMutableAttributedString alloc"), "initWithAttributedString:",
                            CocoaMessage(0, GadgetID(TextGadget), "attributedStringValue"))
    
    range\location = StartPosition - 1
    range\length = CocoaMessage(0, MAString, "length") - range\location
    If range\length > 0
      If Length >= 0 And Length < range\length
        range\length = Length
      EndIf
      r = Red(Color) / 255
      g = Green(Color) / 255
      b = Blue(Color) / 255
      a = Alpha(Color) / 255
      Color = CocoaMessage(0, 0, "NSColor colorWithDeviceRed:@", @r, "green:@", @g, "blue:@", @b, "alpha:@", @a)
      If BackColor
        CocoaMessage(0, MAString, "addAttribute:$", @"NSBackgroundColor", "value:", Color, "range:@", @range)
      Else
        CocoaMessage(0, MAString, "addAttribute:$", @"NSColor", "value:", Color, "range:@", @range)
      EndIf
    EndIf
    CocoaMessage(0, GadgetID(TextGadget), "setAttributedStringValue:", MAString)
  EndIf
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  
  If OpenWindow(0, 0, 0, 322, 150, "TextGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    TextGadget(0, 8, 8, 306, 133, "")
    SetGadgetText(0, "This is a test string to test if coloring" + #CRLF$ + "specific areas will work")
    
    SetTextColorABGR(0, $ff008000, 1); make entire text green
    SetTextColorABGR(0, $ff000080, 1, 7); make first seven characters red
    SetTextColorABGR(0, $ff00f0ff, 1, 4, #YES); set background color of first four characters
    
    Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
  EndIf
  
  
CompilerEndIf
