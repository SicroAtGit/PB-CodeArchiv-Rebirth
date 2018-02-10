;   Description: Mahagoni-Shader
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28207#p324148
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014 NicTheQuick
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

EnableExplicit
#noiseSize = 500
Global Dim noise.d(#noiseSize, #noiseSize)
;generate Noise
Define x, y
For x = 0 To #noiseSize
  For y = 0 To #noiseSize
    noise(x, y) = Random(32768) / 32768.0
  Next
Next
; Mathematisch korrektes Modulo.
Procedure.i ModI(a.i, b.i)
  ;(((b) + ((a) % (b))) % (b))
  If (a < 0)
    ProcedureReturn b + (a % b)
  EndIf
  ProcedureReturn a % b
EndProcedure

; Interpolieren von noise
Procedure.d smoothNoise(x.d, y.d)
  Protected fractX.d = x - Int(x), fractY.d = y - Int(y)
  Protected x1.i = ModI(Int(x), #noiseSize + 1)
  Protected y1.i = ModI(Int(y), #noiseSize + 1)
  Protected x2.i = ModI(Int(x) - 1, #noiseSize + 1)
  Protected y2.i = ModI(Int(y) - 1, #noiseSize + 1)
  Protected value.d = 0.0
  value + fractX       *      fractY  * noise(x1, y1)
  value + fractX       * (1 - fractY) * noise(x1, y2)
  value + (1 - fractX) *      fractY  * noise(x2, y1)
  value + (1 - fractX) * (1 - fractY) * noise(x2, y2)
  
  ProcedureReturn value
EndProcedure

;Turbulenz berechnen
Procedure.d turbulence(x.d, y.d, size.d)
  Protected value.d = 0.0, initialSize.d = size
  
  While (size >= 1.0)
    value + smoothNoise(x / size, y / size) * size
    size / 2.0
  Wend
  
  ProcedureReturn (128.0 * value / initialSize)
EndProcedure

;Parameter für die Holzstruktur
#xPeriod = 5.0
#yPeriod = 10.0
#turbPower = 5.0
#turbSize = 64.0

Global Dim turb.d(0), turbWidth.i, turbHeight.i
Procedure precalculateTurbulence(width.i, height.i, turbSize.d)
  ReDim turb(width * height - 1)
  turbWidth = width
  turbHeight = height
  Protected x.i, y.i
  For x = 0 To width - 1
    For y = 0 To height - 1
      turb(x * height + y) = turbulence(x, y, turbSize)
    Next
  Next
EndProcedure

Procedure.d getTurbulence(x.i, y.i)
  x = ModI(x, turbWidth)
  y = ModI(y, turbHeight)
  ProcedureReturn turb(x * turbHeight + y)
EndProcedure

;Holz-Shader. Er nutzt den unterliegenden Rotkanal für Schattierungen
;und Offsetberechnungen.
Procedure MahagoniFilterCallback(x.i, y.i, sourceColor.i, targetColor.i)
  Protected c.d = (Red(targetColor) / 255.0)
  Protected xyValue.d = x * #xPeriod / (#noiseSize + 1) +
                        y * #yPeriod / (#noiseSize + 1) +
                        #turbPower * getTurbulence(x, y) / 256.0 +
                        c
  Protected sineValue.d = 128.0 * Abs(Cos(xyValue * #PI))
  Protected r.a = 80 + sineValue, g.a = 30 + sineValue, b.i = 30
  ProcedureReturn RGB(r, g, b)
EndProcedure

#w = 800
#h = 600

precalculateTurbulence(#w, #h, #turbSize)

Define avg_time.i = 0, avg_time_count.i = 0

If OpenWindow(0, 0, 0, #w, #h, "Mahagoni-Shader", #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
  CanvasGadget(0, 0, 0, #w, #h)
  
  Define offset.a = 0
  AddWindowTimer(0, 0, 20)
  Define x.i, y.i, r.i = 50
  
  Repeat
    Define event.i = WaitWindowEvent()
    
    Select event
      Case #PB_Event_Gadget
        If EventGadget() = 0
          Select EventType()
            Case #PB_EventType_MouseMove
              x = GetGadgetAttribute(0, #PB_Canvas_MouseX)
              y = GetGadgetAttribute(0, #PB_Canvas_MouseY)
            Case #PB_EventType_MouseWheel
              r + 5 * GetGadgetAttribute(0, #PB_Canvas_WheelDelta)
              If (r < 1) : r = 0 : EndIf
              If (r * r > #w * #w + #h * #h) : r = Sqr(#w * #w + #h * #h) : EndIf
          EndSelect
        EndIf
      Case #PB_Event_Timer
        If EventTimer() = 0
          If StartDrawing(CanvasOutput(0))
            Define.i time = ElapsedMilliseconds()
            ; Erst eine weiße Box malen.
            DrawingMode(#PB_2DDrawing_Default)
            Box(0, 0, #w, #h, 0)
            
            DrawingMode(#PB_2DDrawing_Gradient)
            FrontColor(0)
            BackColor(255)
            CircularGradient(x, y, r)
            Circle(x, y, r)
            
            ; Dann Filtercallback setzen und eine einfache Box malen.
            CustomFilterCallback(@MahagoniFilterCallback())
            DrawingMode(#PB_2DDrawing_CustomFilter)
            
            Box(0, 0, #w, #h)
            
            offset + 5
            time = ElapsedMilliseconds() - time
            avg_time + time
            avg_time_count + 1
            Debug time
            StopDrawing()
          EndIf
        EndIf
    EndSelect
  Until event = #PB_Event_CloseWindow
  
  MessageRequester("Time - CustomFilterCallback", "Average processing time: " + Str(avg_time / avg_time_count) + " ms")
EndIf
