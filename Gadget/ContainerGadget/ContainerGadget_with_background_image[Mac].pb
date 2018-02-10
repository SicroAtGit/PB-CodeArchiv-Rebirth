;   Description: ContainerGadget with background image
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=436415#p436415
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 Shardik
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

#NSBoxCustom = 4
#NSLineBorder = 1

UseJPEGImageDecoder()

If LoadImage(0, #PB_Compiler_Home + "Examples/3D/Data/Textures/Clouds.jpg")
  OpenWindow(0, 270, 100, 300, 300, "Container with background image")
  ContainerGadget(0, 10, 10, 280, 280)
  
  ; ----- When setting a background image for an NSBox (ContainerGadget) the
  ;       BoxType has to be #NSBoxCustom and the BorderType #NSLineBorder !
  CocoaMessage(0, GadgetID(0), "setBoxType:", #NSBoxCustom)
  CocoaMessage(0, GadgetID(0), "setBorderType:", #NSLineBorder)
  ; ----- Set image as background image of ContainerGadget
  CocoaMessage(0, GadgetID(0), "setFillColor:",
               CocoaMessage(0, 0, "NSColor colorWithPatternImage:", ImageID(0)))
  
  Repeat
  Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf
