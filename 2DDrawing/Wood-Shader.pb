;   Description: Wood-Shader
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=28207
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
#noiseSize = 199
Global Dim noise.d(#noiseSize, #noiseSize)
;generate Noise
Define x, y
For x = 0 To #noiseSize
  y = 0
  For y = 0 To #noiseSize
    noise(x, y) = Random(32768) / 32768.0
  Next
Next
; Mathematisch korrektes Modulo.
Macro ModI(a, b)
  (((b) + ((a) % (b))) % (b))
EndMacro

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

;Holz-Shader. Er nutzt den unterliegenden Rotkanal für Schattierungen
;und Offsetberechnungen.
Procedure MahagoniFilterCallback(xi.i, yi.i, sourceColor.i, targetColor.i)
  Protected c.d = Pow((Red(targetColor) / 255.0), 2.8)
  Protected offset.d = -(1-c) * 5
  Protected x.d = xi + 0*offset, y.d = yi + 0*offset
  Protected xyValue.d = x * #xPeriod / (#noiseSize + 1) +
                        y * #yPeriod / (#noiseSize + 1) +
                        #turbPower * turbulence(x, y, #turbSize) / 256.0
  Protected sineValue.d = 128.0 * Abs(Cos(xyValue * #PI-offset))
  c = 0.3 + c * 0.7
  Protected r.a = c * (80 + sineValue), g.a = c * (30 + sineValue), b.i = c * 30
  ProcedureReturn RGB(r, g, b)
EndProcedure

#w = 400
#h = 300
If OpenWindow(0, 0, 0, #w, #h, "Mahagoni-Shader")
  CanvasGadget(0, 0, 0, #w, #h)
  
  If StartDrawing(CanvasOutput(0))
    ; Erst eine weiße Box malen.
    DrawingMode(#PB_2DDrawing_Default)
    Box(0, 0, #w, #h, $ff)
    
    ; Dann Kreise mit Gradient malen
    ; Wenn man ohne Kreise testen möchte, einfach die nachfolgende
    ; Zeile entfernen oder gleich die ganze Schleife.
    DrawingMode(#PB_2DDrawing_Gradient)
    Define r.i = 20, x.i, y.i
    y = r
    While y < #h
      x = r
      While x < #w
        CircularGradient(x + r / 4, y + r / 4, r)
        FrontColor($ff)
        BackColor(0)
        Circle(x, y, r)
        x + 2 * r
      Wend
      y + 2 * r
    Wend
    
    ; Dann Filtercallback setzen und eine einfache Box malen.
    CustomFilterCallback(@MahagoniFilterCallback())
    DrawingMode(#PB_2DDrawing_CustomFilter)
    Define.i time = ElapsedMilliseconds()
    Box(0, 0, #w, #h)
    Debug (Str(ElapsedMilliseconds() - time))
    StopDrawing()
  EndIf
  Repeat
  Until WaitWindowEvent(20) = #PB_Event_CloseWindow
EndIf
