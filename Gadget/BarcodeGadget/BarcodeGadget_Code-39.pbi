;   Description: Adds support to create simple Code-39 BarcodeGadget
;            OS: Windows, Linux, Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=12&t=68393
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
;   BarcodeGadget39() converts any given string (43-char max,
;   only upper case A-Z, space, 0-9, and + - / * $ % .) into
;   a valid Code39 barcode and displays it in an image gadget.
;   Compressing the widths of longer barcodes would severely
;   compromise the readability by barcode readers/scanners.
;
;   credit to Poshu for the Code-39 barcode algorithm.
;
;   Tested & working on Windows 8.1 & 10 and OSX Lion,
;   running PureBasic v5.60, v5.41, v5.40 respectively.
;
;   by TI-994A - free to use, improve, share...
;
;   27th April 2017
;==============================================================

;self-contained BarcodeGadget39() procedure
Procedure BarcodeGadget39(gadgetNo.i, x.i, y.i, bcWidth.i, bcHeight.i,
                          bcText.s, bcColor.i = 0, bcLabel = #True)
  Static gadgetInitialised, bcTextFont
  Protected gNo, i, ii, mf, *tb.byte
  Protected invalidChar, charWidth, bcCharAsc, bcTextChar.s
  Protected bcImage, bcTextLen, bcRawWidth, bcTextWidth, bcTextHeight

  bcText = UCase(bcText)
  For i = 1 To Len(bcText)
    bcCharAsc = Asc(Mid(bcText, i, 1))
    If bcCharAsc = 32 Or
       (bcCharAsc >= 36 And bcCharAsc <= 37) Or
       (bcCharAsc >= 42 And bcCharAsc <= 43) Or
       (bcCharAsc >= 48 And bcCharAsc <= 57) Or
       (bcCharAsc >= 45 And bcCharAsc <= 47) Or
       (bcCharAsc >= 65 And bcCharAsc <= 90)
      Continue
    Else
      invalidChar = #True
      Break
    EndIf
  Next

  If Not gadgetInitialised
    Protected asc, bin, asc$
    bcTextFont = LoadFont(#PB_Any, "Arial", 10)
    Static NewMap binDec.i()
    Restore ascBinData
    For i = 0 To 43
      Read asc
      Read bin
      asc$ = Chr(asc)
      binDec(asc$) = AllocateMemory(32)
      PokeL(binDec(asc$), bin)
    Next
    gadgetInitialised = #True
  EndIf

  charWidth = 19
  bcTextLen = Len(bcText) + 1
  bcText = "*" + bcText + "*"
  bcRawWidth = bcTextLen * charWidth + 18
  bcImage = CreateImage(#PB_Any, bcRawWidth, bcHeight, 32, #White)

  If bcImage
    StartDrawing(ImageOutput(bcImage))
      If invalidChar
        DrawText(10, 10, "> INVALID CHARACTER IN BARCODE <", #White, #Red)
      Else
        For i = 0 To bcTextLen
          bcTextChar = Mid(bcText, i + 1, 1)
          For ii = 0 To 18
            mf = (ii % 8)
            *tb = binDec(bcTextChar) + (ii >> 3)
            If (*tb\b & (1 << mf)) >> mf
              Line(i * charWidth + ii, 0, 1, bcHeight, bcColor)
            EndIf
          Next
        Next
        If bcLabel
          bcTextChar = ""
          For i = 1 To Len(bcText)
            bcTextChar + Mid(bcText, i, 1) + " "
          Next i
          bcText = "  " + bcTextChar + " "
          DrawingFont(FontID(bcTextFont))
          bcTextWidth = TextWidth(bcText)
          bcTextHeight = TextHeight(bcText)
          DrawText((bcRawWidth - bcTextWidth) / 2, bcHeight - bcTextHeight,
                   bcText, bcColor, RGB(255, 255, 255))
        EndIf
      EndIf
    StopDrawing()
  EndIf

  ;compressing the widths of longer barcodes corrupts scanner-readability
  ;uncomment this line to size the barcode according to the gadget width
  ;ResizeImage(bcImage, bcWidth, bcHeight)

  gNo = ImageGadget(gadgetNo, x, y, bcWidth, bcHeight, ImageID(bcImage))
  If gadgetNo = #PB_Any
    gadgetNo = gNo
  EndIf

  ProcedureReturn gadgetNo

  ;the data block is included within the procedure for portability - can be positioned anywhere in the code
  DataSection
  ascBinData:
    Data.i 65, 250031, 66, 250045, 67, 181743, 68, 250341, 69, 182191, 70, 182205, 71, 252965, 72, 159919
    Data.i 73, 159933, 74, 192997, 75, 246959, 76, 246973, 77, 136687, 78, 247269, 79, 137135, 80, 137149
    Data.i 81, 247717, 82, 138415, 83, 138429, 84, 138725, 85, 251023, 86, 251361, 87, 186255, 88, 251809
    Data.i 89, 155279, 90, 188385, 48, 194437, 49, 250927, 50, 250941, 51, 184815, 52, 251781, 53, 187951
    Data.i 54, 187965, 55, 253061, 56, 193583, 57, 193597, 32, 194017, 36, 181281, 37, 135301, 42, 194465
    Data.i 43, 135329, 45, 253089, 46, 160911, 47, 136225
  EndDataSection

EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  wFlags = #PB_Window_SystemMenu | #PB_Window_ScreenCentered
  win = OpenWindow(#PB_Any, #PB_Ignore, #PB_Ignore, 950, 450,
                   "Simple Code-39 Barcode Gadget", wFlags)
  
  ;default options - black barcode with barcode number overlaid
  bcg = BarcodeGadget39(#PB_Any, 50, 50, 500, 50, "code39 barcode generator")
  
  ;blue barcode without barcode number overlaid
  BarcodeGadget39(0, 50, 150, 600, 50, "code39 barcode generator", #Blue, #False)
  
  ;green barcode with barcode number overlaid
  BarcodeGadget39(1, 50, 250, 300, 50, "short descriptor", RGB(00, 99, 33))
  
  ;very long 43-char barcode in red with number overlaid
  BarcodeGadget39(2, 50, 350, 800, 50, "up to 43 chars long but proportionate width", #Red)
  
  While WaitWindowEvent() ! #PB_Event_CloseWindow : Wend
  
CompilerEndIf
