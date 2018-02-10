;   Description: Adds support for reading and writing tiff image files via libTIFF
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=29522
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2016 Sicro
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

DeclareModule TIFF
  EnableExplicit

  Declare.i Init(LibraryPath$)
  Declare.s GetLIBVersion()
  Declare.i ReadImage(ImagePath$)
  Declare.i WriteImage(Image.i, ImagePath$, UseAlpha.i=#True, UseDeflateCompression.i=#True)
  Declare   Free()
EndDeclareModule

Module TIFF
  Enumeration 256
    #TIFFTAG_IMAGEWIDTH
    #TIFFTAG_IMAGELENGTH
    #TIFFTAG_BITSPERSAMPLE
    #TIFFTAG_COMPRESSION
    #TIFFTAG_PHOTOMETRIC     = 262
    #TIFFTAG_ORIENTATION     = 274
    #TIFFTAG_SAMPLESPERPIXEL = 277
    #TIFFTAG_ROWSPERSTRIP
    #TIFFTAG_PLANARCONFIG    = 284
  EndEnumeration

  #PHOTOMETRIC_RGB     = 2
  #ORIENTATION_TOPLEFT = 1
  #PLANARCONFIG_CONTIG = 1
  #COMPRESSION_DEFLATE = 32946

  Structure LongArray
    l.l[0]
  EndStructure

  Structure ByteArray
    b.b[0]
  EndStructure

  PrototypeC.i TIFFGetVersion()
  PrototypeC.i TIFFOpen(FilePath.p-ascii, Mode.p-ascii)
  PrototypeC   TIFFClose(*Handle)
  PrototypeC.i TIFFGetField(*Handle, Tag.l, *Value)
  PrototypeC.i TIFFSetField(*Handle, Tag.l, *Value)
  PrototypeC.i TIFFReadRGBAImage(*Handle, Width.l, Height.l, Raster.i, i.i)
  PrototypeC.i TIFFScanlineSize(*Handle)
  PrototypeC.i TIFFDefaultStripSize(*Handle, Request.i)
  PrototypeC.i TIFFWriteScanline(*Handle, *Data, Row.l, Sample.w)
  PrototypeC.i TIFFmalloc(Size.i)
  PrototypeC   TIFFfree(*Handle)

  Global.TIFFGetVersion        TIFFGetVersion
  Global.TIFFOpen              TIFFOpen
  Global.TIFFClose             TIFFClose
  Global.TIFFGetField          TIFFGetField
  Global.TIFFSetField          TIFFSetField
  Global.TIFFReadRGBAImage     TIFFReadRGBAImage
  Global.TIFFScanlineSize      TIFFScanlineSize
  Global.TIFFDefaultStripSize  TIFFDefaultStripSize
  Global.TIFFWriteScanline     TIFFWriteScanline
  Global.TIFFmalloc            TIFFmalloc
  Global.TIFFfree              TIFFfree

  Global.i Library

  Procedure.i Init(LibraryPath$)
    Library = OpenLibrary(#PB_Any, LibraryPath$)
    If Library
      TIFFGetVersion        = GetFunction(Library, "TIFFGetVersion")
      TIFFOpen              = GetFunction(Library, "TIFFOpen")
      TIFFClose             = GetFunction(Library, "TIFFClose")
      TIFFGetField          = GetFunction(Library, "TIFFGetField")
      TIFFSetField          = GetFunction(Library, "TIFFSetField")
      TIFFReadRGBAImage     = GetFunction(Library, "TIFFReadRGBAImage")
      TIFFScanlineSize      = GetFunction(Library, "TIFFScanlineSize")
      TIFFDefaultStripSize  = GetFunction(Library, "TIFFDefaultStripSize")
      TIFFWriteScanline     = GetFunction(Library, "TIFFWriteScanline")
      TIFFmalloc            = GetFunction(Library, "_TIFFmalloc")
      TIFFfree              = GetFunction(Library, "_TIFFfree")
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

  Procedure.s GetLIBVersion()
    ProcedureReturn PeekS(TIFFGetVersion(), -1, #PB_Ascii)
  EndProcedure

  Procedure.i ReadImage(ImagePath$)
    Protected           *tiff
    Protected.LongArray *Raster
    Protected.i         CountOfPixels, Width, Height, Image, y, x, Color, Error = #True

    *tiff = TIFFOpen(ImagePath$, "r")
    If *tiff = 0 : Goto CleanUp : EndIf

    TIFFGetField(*tiff, #TIFFTAG_IMAGEWIDTH, @Width)
    TIFFGetField(*tiff, #TIFFTAG_IMAGELENGTH, @Height)
    CountOfPixels = Width * Height

    *Raster = TIFFmalloc(CountOfPixels * SizeOf(LONG))
    If *Raster = 0 : Goto CleanUp : EndIf

    If Not TIFFReadRGBAImage(*tiff, Width, Height, *Raster, 0)
      Goto CleanUp
    EndIf

    Image = CreateImage(#PB_Any, Width, Height, 32)
    If Not Image : Goto CleanUp : EndIf

    If Not StartDrawing(ImageOutput(Image))
      Goto CleanUp
    EndIf

    For y = Height - 1 To 0 Step -1
      For x = Width - 1 To 0 Step -1
        Color = *Raster\l[y * Width + x]
        Plot(x, Height - 1 - y, Color) ; Bild steht im *Raster auf dem Kopf
      Next
    Next

    StopDrawing()

    Error = #False

    CleanUp:
    If Error And Image : FreeImage(Image)    : EndIf
    If *Raster         : TIFFfree(*Raster) : EndIf
    If *tiff           : TIFFClose(*tiff)    : EndIf

    If Not Error
      ProcedureReturn Image
    EndIf
  EndProcedure

  Procedure.i WriteImage(Image.i, ImagePath$, UseAlpha.i=#True, UseDeflateCompression.i=#True)
    Protected           *tiff
    Protected.ByteArray *LineBuffer
    Protected.i          Width, Height, CountOfPixels, SamplesPerPixel, LineBytes
    Protected.i          Pixel, x, y, Offset, ReadedLineBytes, Row, Error =  #True

    If Not IsImage(Image) : Goto CleanUp : EndIf

    Width  = ImageWidth(Image)
    Height = ImageHeight(Image)

    SamplesPerPixel = 3 + UseAlpha ; Samples: 1. Byte=Rot, 2. Byte=Grün, 3. Byte=Blau, 4. Byte=Alpha

    *tiff = TIFFOpen(ImagePath$, "w")
    If *tiff = 0 : Goto CleanUp : EndIf

    TIFFSetField(*tiff, #TIFFTAG_IMAGEWIDTH, Width)
    TIFFSetField(*tiff, #TIFFTAG_IMAGELENGTH, Height)
    TIFFSetField(*tiff, #TIFFTAG_SAMPLESPERPIXEL, SamplesPerPixel)
    TIFFSetField(*tiff, #TIFFTAG_BITSPERSAMPLE, 8) ; 8 Bit = 1 Byte
    TIFFSetField(*tiff, #TIFFTAG_ORIENTATION, #ORIENTATION_TOPLEFT)
    TIFFSetField(*tiff, #TIFFTAG_PLANARCONFIG, #PLANARCONFIG_CONTIG)
    TIFFSetField(*tiff, #TIFFTAG_PHOTOMETRIC, #PHOTOMETRIC_RGB)

    If UseDeflateCompression
      TIFFSetField(*tiff, #TIFFTAG_COMPRESSION, #COMPRESSION_DEFLATE)
    EndIf

    LineBytes = SamplesPerPixel * Width

    If TIFFScanlineSize(*tiff) = LineBytes
      *LineBuffer = TIFFmalloc(LineBytes)
    Else
      *LineBuffer = TIFFmalloc(TIFFScanlineSize(*tiff))
    EndIf
    If *LineBuffer = 0 : Goto CleanUp : EndIf

    TIFFSetField(*tiff, #TIFFTAG_ROWSPERSTRIP, TIFFDefaultStripSize(*tiff, Width * SamplesPerPixel))

    If Not StartDrawing(ImageOutput(Image)) : Goto CleanUp : EndIf

    If UseAlpha : DrawingMode(#PB_2DDrawing_AlphaBlend) : EndIf

    Row = -1
    For y = 0 To Height - 1
      For x = 0 To Width - 1
        Pixel = Point(x, y)
        *LineBuffer\b[Offset] = Red(Pixel)   : Offset + 1
        *LineBuffer\b[Offset] = Green(Pixel) : Offset + 1
        *LineBuffer\b[Offset] = Blue(Pixel)  : Offset + 1
        ReadedLineBytes + 3
        If UseAlpha
          *LineBuffer\b[Offset] = Alpha(Pixel)
          ReadedLineBytes + 1
          Offset + 1
        EndIf

        If ReadedLineBytes = LineBytes
          ReadedLineBytes = 0
          Offset = 0
          Row + 1
          If TIFFWriteScanline(*tiff, *LineBuffer, Row, 0) < 0
            Break
          EndIf
        EndIf
      Next
    Next

    StopDrawing()

    Error = #False

    CleanUp:
    If *LineBuffer : TIFFfree(*LineBuffer) : EndIf
    If *tiff       : TIFFClose(*tiff)      : EndIf

    ProcedureReturn Bool(Not Error)
  EndProcedure

  Procedure Free()
    CloseLibrary(Library)
  EndProcedure
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
    Define ImagePath$
    Define.i Image
  
    If Not TIFF::Init("libTIFF.dll")
      Debug "TIFF::Init(): Fehler"
      End
    EndIf
    Debug "TIFF::Init(): OK"
  
    Debug ""
    Debug TIFF::GetLIBVersion()
    Debug ""
  
    ImagePath$ = OpenFileRequester("TIFF-Datei öffnen", "", "TIFF-Dateien (*.tif, *.tiff) | *.tif;*.tiff", 0)
  
    Image = TIFF::ReadImage(ImagePath$)
    If Image = 0
      Debug "TIFF::ReadImage(): Fehler"
      Goto CleanUp
    EndIf
    Debug "TIFF::ReadImage(): OK"
    Debug ""
  
    ; Normal speichern
    If Not TIFF::WriteImage(Image, GetPathPart(ImagePath$)+"Test_normal.tiff", #True, #False)
      Debug "TIFF::WriteImage(Normal): Fehler"
      Goto CleanUp
    EndIf
    Debug "TIFF::WriteImage(Normal): OK"
    Debug ""
  
    ; Mit Komprimierung "Deflate" speichern
    If Not TIFF::WriteImage(Image, GetPathPart(ImagePath$)+"Test_deflate.tiff", #True)
      Debug "TIFF::WriteImage(Deflate): Fehler"
      Goto CleanUp
    EndIf
    Debug "TIFF::WriteImage(Deflate): OK"
    Debug ""
    Debug "Fertig"
  
    CleanUp:
    If Image : FreeImage(Image) : EndIf
    TIFF::Free()
CompilerEndIf
