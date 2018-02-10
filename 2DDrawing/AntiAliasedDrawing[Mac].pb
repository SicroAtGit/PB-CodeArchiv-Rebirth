;   Description: Anti-aliased drawing onto an image using the NSColor, NSGradient and NSBezierPath classes. (This also works on CanvasGadget when CanvasOutput(#Gadget) is used)
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=392072#p392072
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2012-2014 wilbert
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

; *** Create image and draw onto it ***

CreateImage(0, 300, 200, 32, #PB_Image_Transparent)

StartDrawing(ImageOutput(0))

Crayons = CocoaMessage(0, CocoaMessage(0, 0, "NSColorList colorListNamed:$", @"Crayons"), "retain")

ColorGreen = CocoaMessage(0, 0, "NSColor greenColor")
ColorBrown = CocoaMessage(0, 0, "NSColor brownColor")
ColorMocha = CocoaMessage(0, Crayons, "colorWithKey:$", @"Mocha")
CocoaMessage(0, ColorMocha, "setStroke"); set stroke color to Mocha

Gradient = CocoaMessage(0, 0, "NSGradient alloc"); create gradient from green to brown
CocoaMessage(@Gradient, Gradient, "initWithStartingColor:", ColorGreen, "endingColor:", ColorBrown)
CocoaMessage(0, Gradient, "autorelease")
GradientAngle.CGFloat = 315

Rect.NSRect
Rect\origin\x = 5
Rect\origin\y = 5
Rect\size\width = 290
Rect\size\height = 190

RadiusX.CGFloat = 20
RadiusY.CGFloat = 20

Path = CocoaMessage(0, 0, "NSBezierPath bezierPathWithRoundedRect:@", @Rect, "xRadius:@", @RadiusX, "yRadius:@", @RadiusY)
CocoaMessage(0, Gradient, "drawInBezierPath:", Path, "angle:@", @GradientAngle)
CocoaMessage(0, Path, "stroke")

StopDrawing()


; *** Show the result ***

If OpenWindow(0, 0, 0, 320, 220, "Drawing", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
 
  ImageGadget(0, 10, 10, 300, 200, ImageID(0))
 
  Repeat
    Event = WaitWindowEvent()
  Until Event = #PB_Event_CloseWindow
 
EndIf
