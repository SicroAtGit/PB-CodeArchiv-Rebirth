;   Description: Load / catch image (all OS X supported image types) & save image
;            OS: Mac
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=392073#p392073
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

Procedure LoadImageEx(Image, Filename.s)
  Protected.i Result, Rep, Width, Height
  Protected Size.NSSize, Point.NSPoint
  CocoaMessage(@Rep, 0, "NSImageRep imageRepWithContentsOfFile:$", @Filename)
  If Rep
    CocoaMessage(@Width, Rep, "pixelsWide")
    CocoaMessage(@Height, Rep, "pixelsHigh")
    If Width And Height
      Size\width = Width
      Size\height = Height
      CocoaMessage(0, Rep, "setSize:@", @Size)
      Result = CreateImage(Image, Width, Height, 32, #PB_Image_Transparent)
      If Result
        If Image = #PB_Any : Image = Result : EndIf
        CocoaMessage(0, ImageID(Image), "lockFocus")
        CocoaMessage(0, Rep, "drawAtPoint:@", @Point)
        CocoaMessage(0, ImageID(Image), "unlockFocus")
      EndIf
    EndIf 
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure CatchImageEx(Image, *MemoryAddress, MemorySize)
  Protected.i Result, DataObj, Class, Rep, Width, Height
  Protected Size.NSSize, Point.NSPoint
  CocoaMessage(@DataObj, 0, "NSData dataWithBytesNoCopy:", *MemoryAddress, "length:", MemorySize, "freeWhenDone:", #NO)
  CocoaMessage(@Class, 0, "NSImageRep imageRepClassForData:", DataObj)
  If Class
    CocoaMessage(@Rep, Class, "imageRepWithData:", DataObj)
    If Rep
      CocoaMessage(@Width, Rep, "pixelsWide")
      CocoaMessage(@Height, Rep, "pixelsHigh")
      If Width And Height
        Size\width = Width
        Size\height = Height
        CocoaMessage(0, Rep, "setSize:@", @Size)
        Result = CreateImage(Image, Width, Height, 32, #PB_Image_Transparent)
        If Result
          If Image = #PB_Any : Image = Result : EndIf
          CocoaMessage(0, ImageID(Image), "lockFocus")
          CocoaMessage(0, Rep, "drawAtPoint:@", @Point)
          CocoaMessage(0, ImageID(Image), "unlockFocus")
        EndIf
      EndIf 
    EndIf
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure SaveImageEx(Image, FileName.s, Type = #NSPNGFileType, Compression.f = 0.8)
  Protected c.i = CocoaMessage(0, 0, "NSNumber numberWithFloat:@", @Compression)
  Protected p.i = CocoaMessage(0, 0, "NSDictionary dictionaryWithObject:", c, "forKey:$", @"NSImageCompressionFactor")
  Protected imageReps.i = CocoaMessage(0, ImageID(Image), "representations")
  Protected imageData.i = CocoaMessage(0, 0, "NSBitmapImageRep representationOfImageRepsInArray:", imageReps, "usingType:", Type, "properties:", p)
  CocoaMessage(0, imageData, "writeToFile:$", @FileName, "atomically:", #NO)
EndProcedure
