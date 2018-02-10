;   Description: Drawing a polygon using Cocoa
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=417520#p417520
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

Procedure DrawPolygon(Array Points.NSPoint(1), x.CGFloat, y.CGFloat, LineColor.l, LineWidth.CGFloat = 1.0, FillColor.l = 0)
  
  Protected.CGFloat R,G,B,A, M = 1 / 255, SX = 1, SY = -1
  Protected Path, Transform
  
  R = Red(LineColor)*M : G = Green(LineColor)*M : B = Blue(LineColor)*M : A = Alpha(LineColor)*M
  CocoaMessage(0, CocoaMessage(0, 0, "NSColor colorWithDeviceRed:@", @R, "green:@", @G, "blue:@", @B, "alpha:@", @A), "setStroke")
  R = Red(FillColor)*M : G = Green(FillColor)*M : B = Blue(FillColor)*M : A = Alpha(FillColor)*M
  CocoaMessage(0, CocoaMessage(0, 0, "NSColor colorWithDeviceRed:@", @R, "green:@", @G, "blue:@", @B, "alpha:@", @A), "setFill")
  
  y - OutputHeight()
  Transform = CocoaMessage(0, 0, "NSAffineTransform transform")
  CocoaMessage(0, Transform, "scaleXBy:@", @SX, "yBy:@", @SY)
  CocoaMessage(0, Transform, "translateXBy:@", @x, "yBy:@", @y)
  
  Path = CocoaMessage(0, 0, "NSBezierPath bezierPath")
  CocoaMessage(0, Path, "appendBezierPathWithPoints:", @Points(), "count:", ArraySize(Points()) + 1)
  CocoaMessage(0, Path, "closePath")
  CocoaMessage(0, Path, "transformUsingAffineTransform:", Transform)
  CocoaMessage(0, Path, "setLineWidth:@", @LineWidth)
  CocoaMessage(0, Path, "fill")
  CocoaMessage(0, Path, "stroke")
  
EndProcedure




;-Example
CompilerIf #PB_Compiler_IsMainFile
  Dim PP.NSPoint(2)
  PP(0)\x = 20 : PP(0)\y = 10
  PP(1)\x = 30 : PP(1)\y = 30
  PP(2)\x = 10 : PP(2)\y = 30
  
  If OpenWindow(0, 0, 0, 200, 200, "Polygon Drawing Example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    If CreateImage(0, 200, 200) And StartDrawing(ImageOutput(0))
      DrawPolygon(PP(), 10, 10, 0, 0, $ff0000ff)
      DrawPolygon(PP(), 20, 20, $ff00ff00, 2.0, $ff00ffff)
      StopDrawing()
      ImageGadget(0, 0, 0, 200, 200, ImageID(0))
    EndIf
    
    Repeat
      Event = WaitWindowEvent()
    Until Event = #PB_Event_CloseWindow
  EndIf
  
CompilerEndIf
