;   Description: Window with background image and transparent ListIconGadget
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=393352#p393352
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

UseJPEGImageDecoder()

OpenWindow(0, 200, 100, 430, 300, "Window with background image + transparent ListIcon")
ListIconGadget(0, 10, 100, WindowWidth(0) - 20, 75, "Name", 110)
AddGadgetColumn(0, 1, "Address", GadgetWidth(0) - GetGadgetItemAttribute(0, 0, #PB_ListIcon_ColumnWidth))
AddGadgetItem(0, -1, "Harry Rannit" + #LF$ + "12 Parliament Way, Battle Street, By the Bay")
AddGadgetItem(0, -1, "Ginger Brokeit"+ #LF$ + "130 PureBasic Road, BigTown, CodeCity")
AddGadgetItem(0, -1, "Didi Foundit"+ #LF$ + "321 Logo Drive, Mouse House, Downtown")

If LoadImage(0, #PB_Compiler_Home + "Examples/3D/Data/Textures/Clouds.jpg")
  ContentView = CocoaMessage(0, WindowID(0), "contentView")
  CocoaMessage(0, ContentView, "setWantsLayer:", #YES)
  Layer = CocoaMessage(0, ContentView, "layer")
  CocoaMessage(0, Layer, "setContents:", ImageID(0))
EndIf

CocoaMessage(0, GadgetID(0), "setBackgroundColor:", CocoaMessage(0, 0, "NSColor clearColor"))
CocoaMessage(0, CocoaMessage(0, GadgetID(0), "enclosingScrollView"), "setDrawsBackground:", #NO)

Repeat
Until WaitWindowEvent() = #PB_Event_CloseWindow
