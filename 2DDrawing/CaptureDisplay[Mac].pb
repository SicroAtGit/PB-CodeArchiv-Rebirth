;   Description: Capture the main display into an image
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=402758#p402758
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013-2017 wilbert
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

ImportC ""
  CGDisplayCreateImage(displayID)
  CGImageGetHeight(image)
  CGImageGetWidth(image)
  CGImageRelease(image)
  CGMainDisplayID()
EndImport

Define CGImage, NSImage, ImageSize.NSSize

CGImage = CGDisplayCreateImage(CGMainDisplayID()); get CGImage from main display
ImageSize\width = CGImageGetWidth(CGImage)
ImageSize\height = CGImageGetHeight(CGImage)
NSImage = CocoaMessage(0, CocoaMessage(0, 0, "NSImage alloc"), "initWithCGImage:", CGImage, "size:@", @ImageSize); convert CGImage into NSImage
CGImageRelease(CGImage)

CreateImage(0, ImageSize\width, ImageSize\height); Create a PureBasic image
StartDrawing(ImageOutput(0))
DrawImage(NSImage, 0, 0); draw the NSImage object
StopDrawing()

CocoaMessage(0, NSImage, "release"); release the NSImage

If OpenWindow(0, 0, 0, 320, 220, "Image from display", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  ImageGadget(0,  10, 10, 300, 200, ImageID(0))
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf
