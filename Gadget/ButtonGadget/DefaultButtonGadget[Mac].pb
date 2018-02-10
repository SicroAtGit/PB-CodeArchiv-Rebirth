;   Description: Default Button
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=390031#p390031
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012-2013 wilbert
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

#NSRoundedBezelStyle = 1 ; for default button
#NSRightTextAlignment = 1 ; for right align string gadget

If OpenWindow(0, 0, 0, 270, 260, "ListViewGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
 
  ListViewGadget(0, 10, 10, 250, 180)
 
  For a = 1 To 12
    AddGadgetItem (0, -1, "Item " + Str(a) + " of the Listview")
  Next
 
  ButtonGadget(1, 10, 200, 80, 30, "Button")
 
  StringGadget(2, 10,230,120,22,"String gadget")
 
   ; alternating colors
   CocoaMessage(0,GadgetID(0),"setUsesAlternatingRowBackgroundColors:",#True)
 
   ; enable/disable scrollers
   ScrollView = CocoaMessage(0,GadgetID(0),"enclosingScrollView")
   CocoaMessage(0,ScrollView,"setHasVerticalScroller:", #False) ; "setHasHorizontalScroller:"

    ; set default button cell
    ButtonCell = CocoaMessage(0,GadgetID(1),"cell")
    CocoaMessage(0,GadgetID(1),"setBezelStyle:", #NSRoundedBezelStyle)
    CocoaMessage(0,WindowID(0),"setDefaultButtonCell:", ButtonCell)
   
   ;set string gadget to right-justified
    CocoaMessage(0,GadgetID(2),"setAlignment:", #NSRightTextAlignment)

  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
 
EndIf
