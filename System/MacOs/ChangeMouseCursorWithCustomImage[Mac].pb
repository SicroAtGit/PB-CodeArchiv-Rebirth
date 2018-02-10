;   Description: Change mouse cursor
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=395785#p395785
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012 Shardik
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

Define Hotspot.NSPoint

OpenWindow(0, 200, 100, 290, 100, "Display custom cursor")
ButtonGadget(0, WindowWidth(0) / 2 - 120, 40, 240, 25, "Change cursor to custom image")

UsePNGImageDecoder()

If LoadImage(0, #PB_Compiler_Home + "Examples/Sources/Data/World.png")
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow
        Break
      Case #PB_Event_Gadget
        If EventGadget() = 0 And EventType() = #PB_EventType_LeftClick
          Hotspot\x = 4
          Hotspot\y = 4
          NewCursor = CocoaMessage(0, 0, "NSCursor alloc")
          CocoaMessage(0, NewCursor, "initWithImage:", ImageID(0), "hotSpot:@", @Hotspot)
          CocoaMessage(0, NewCursor, "set")
        EndIf
    EndSelect
  ForEver
EndIf
