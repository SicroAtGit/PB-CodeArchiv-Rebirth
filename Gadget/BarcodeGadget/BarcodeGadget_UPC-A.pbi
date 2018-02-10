;   Description: Adds support to create simple UPC-A BarcodeGadget
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=68390
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017 TI-994A
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

;==============================================================
;   BarcodeGadget() converts a given 6-11 digit number into
;   a valid UPC-A barcode including the computed check digit
;   and displays it in a size/color configurable image gadget.
;
;   credit to Num3 for the foundational UPC barcode algorithm.
;
;   Tested & working on Windows 8.1 & 10 and OSX Lion,
;   running PureBasic v5.60, v5.41, v5.40 respectively.
;
;   by TI-994A - free to use, improve, share...
;
;   26th April 2017
;==============================================================

;self-contained BarcodeGadget() procedure
Procedure BarcodeGadget(gadgetNo.i, x.i, y.i, bcWidth.i, bcHeight.i,
                        bcText.s, bcColor.i = 0, bcLabel = #True)

  Protected.i i, unit, width, height, modulo1, modulo2, chksum, gNo
  Protected.i color, bcImage, bcTextFont, bcTextWidth, bcTextHeight
  Protected.s barCode, modulo, digits, left_Digits, right_Digits

  Dim left_Binary.s(10)
  left_Binary(0) = "0001101"
  left_Binary(1) = "0011001"
  left_Binary(2) = "0010011"
  left_Binary(3) = "0111101"
  left_Binary(4) = "0100011"
  left_Binary(5) = "0110001"
  left_Binary(6) = "0101111"
  left_Binary(7) = "0111011"
  left_Binary(8) = "0110111"
  left_Binary(9) = "0001011"

  Dim right_Binary.s(10)
  right_Binary(0) = "1110010"
  right_Binary(1) = "1100110"
  right_Binary(2) = "1101100"
  right_Binary(3) = "1000010"
  right_Binary(4) = "1011100"
  right_Binary(5) = "1001110"
  right_Binary(6) = "1010000"
  right_Binary(7) = "1000100"
  right_Binary(8) = "1001000"
  right_Binary(9) = "1110100"

  digits = bcText
  digits = RSet(digits, 11, "0")
  left_Digits = Left(digits, 6)
  right_Digits = Right(digits, 5)
  modulo.s = left_Digits + right_Digits
  For i = 1 To Len(modulo) Step 2
    modulo1 + Val(Mid(modulo, i, 1))
  Next i
  For i = 2 To Len(modulo) Step 2
    modulo2 + Val(Mid(modulo, i, 1))
  Next i
  chksum = (modulo1 * 3) + modulo2
  If Mod(chksum, 10)
    chksum = 10 - (Mod(chksum, 10))
  Else
    chksum = 0
  EndIf
  digits + Str(chksum)
  barCode = "101"
  For i = 1 To Len(left_Digits)
    barCode + left_Binary(Val(Mid(left_Digits, i, 1)))
  Next i
  barCode + "01010"
  For i = 1 To Len(right_Digits)
    barCode + right_Binary(Val(Mid(right_Digits, i, 1)))
  Next i
  barCode + right_Binary(chksum)
  barCode + "101"

  unit = 2
  width = Len(barCode) * unit
  height = bcHeight
  bcImage = CreateImage(#PB_Any, width, height, 32)
  bcTextFont = LoadFont(#PB_Any, "Arial", 10)

  If StartDrawing(ImageOutput(bcImage))
      Box(0, 0, width, height, RGB(255, 255, 255))
      For i = 1 To Len(barCode)
        If Mid(barCode, i, 1) = "0"
          color = RGB(255, 255, 255)
        ElseIf Mid(barCode, i, 1) = "1"
          color = bcColor
        EndIf
        Box(unit * (i - 1), 0, unit, height, color)
      Next
      If bcLabel
        bcText = ""
        For i = 1 To Len(digits)
          bcText + Mid(digits, i, 1) + " "
        Next i
        bcText = "  " + bcText + " "
        DrawingFont(FontID(bcTextFont))
        bcTextWidth = TextWidth(bcText)
        bcTextHeight = TextHeight(bcText)
        DrawText((width - bcTextWidth) / 2, height - bcTextHeight,
                 bcText, bcColor, RGB(255, 255, 255))
      EndIf
    StopDrawing()
  EndIf

  ResizeImage(bcImage, bcWidth, bcHeight)
  gNo = ImageGadget(gadgetNo, x, y, bcWidth, bcHeight, ImageID(bcImage))
  If gadgetNo = #PB_Any
    gadgetNo = gNo
  EndIf

  ProcedureReturn gadgetNo
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  wFlags = #PB_Window_SystemMenu | #PB_Window_ScreenCentered
  win = OpenWindow(#PB_Any, #PB_Ignore, #PB_Ignore, 400, 350,
                   "Simple UPC-A Barcode Gadget", wFlags)
  
  ;default options - black barcode with barcode number overlaid
  bcg = BarcodeGadget(#PB_Any, 150, 20, 100, 50, "12234567899")
  
  ;red barcode without barcode number overlaid
  BarcodeGadget(0, 100, 120, 200, 60, "456789", #Red, #False)
  
  ;blue barcode with barcode number overlaid
  BarcodeGadget(1, 50, 230, 300, 75, "987654321", #Blue)
  
  While WaitWindowEvent() ! #PB_Event_CloseWindow : Wend
  
CompilerEndIf
