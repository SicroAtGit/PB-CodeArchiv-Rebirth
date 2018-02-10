;   Description: Adds support for loading of zipped image files
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=26773
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2013 Bisonte
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

; ==============================================================================
; - Program         : CatchPackImage
; - Author          : Bisonte
; - Date            : May 14, 2013
; - Compiler        : PureBasic 5.11 (Windows - x86)
; - Target OS       : Windows, Linux, MacOS
; - Version         : 1.0
; ==============================================================================
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
CompilerEndIf
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  ; ==============================================================================
  ; - Program         : CatchImageEx.pbi
  ; - Author          : Stefan (german forum) - modifiziert von Bisonte
  ; - Link            : http://www.purebasic.fr/german/viewtopic.php?p=141213#p141213
  ; - Date            : Feb 27, 2007
  ; - Compiler        : PureBasic 5.11 (Windows - x86)
  ; - Target OS       : Windows
  ; ==============================================================================
  CompilerIf Not Defined(nIDXSurfaceFactory, #PB_Interface)
    Interface nIDXSurfaceFactory
      QueryInterface(a, b)
      AddRef()
      Release()
      CreateSurface(a, b, c, d, e, f, g, h)
      CreateFromDDSurface(a, b, c, d, e, f)
      LoadImage(a.p-bstr, b, c, d, e, f)
      LoadImageFromStream(a, b, c, d, e, f)
      CopySurfaceToNewFormat(a, b, c, d, e)
      CreateD3DRMTexture(a, b, c, d, e)
      BitBlt(a, b, c, d, e)
    EndInterface
  CompilerEndIf
  ;
  CompilerIf Not Defined(DXLOCKF_READ, #PB_Constant)
    #DXLOCKF_READ         = 0
  CompilerEndIf
  CompilerIf Not Defined(CLSCTX_INPROC_SERVER, #PB_Constant)
    #CLSCTX_INPROC_SERVER = 1
  CompilerEndIf
  ;
  Procedure CreateStreamFromMem_intern(Address, Size)
    
    Protected mem = GlobalAlloc_(#GMEM_MOVEABLE, Size)
    Protected *ptr, Stream.IStream
    
    If mem
      
      *ptr = GlobalLock_(mem)
      
      If *ptr
        CopyMemory(Address, *ptr, Size)
        CreateStreamOnHGlobal_(mem, #True, @Stream.IStream)
        GlobalUnlock_(mem)
      EndIf
      
      If Stream = 0
        GlobalFree_(mem)
      EndIf
      
    EndIf
    
    ProcedureReturn Stream
    
  EndProcedure
  Procedure CatchImageEX(Image, Adress, Size, Flags = 32)
    
    If Size <=0 : ProcedureReturn #False : EndIf
    
    Protected result = CoInitialize_(0)
    Protected dxtf.IDXTransformFactory, dxsf.nIDXSurfaceFactory, Stream.IStream
    Protected surf.IDXSurface, lock.IDXDCLock, DC, re.RECT, DestDC, Success
    
    If result = #S_FALSE Or result = #S_OK
      CoCreateInstance_(?CLSID_DXTransformFactory, 0, #CLSCTX_INPROC_SERVER, ?IID_IDXTransformFactory, @dxtf.IDXTransformFactory)
      If dxtf
        dxtf\QueryService(?IID_IDXSurfaceFactory, ?IID_IDXSurfaceFactory, @dxsf.nIDXSurfaceFactory)
        If dxsf
          Stream.IStream = CreateStreamFromMem_intern(Adress, Size)
          If Stream
            dxsf\LoadImageFromStream(Stream, 0, 0, 0, ?IID_IDXSurface, @surf.IDXSurface)
            If surf
              surf\LockSurfaceDC(0, #INFINITE,#DXLOCKF_READ, @lock.IDXDCLock)
              If lock
                DC = lock\GetDC()
                If DC
                  GetClipBox_(DC, @re.rect)
                  result = CreateImage(Image, re\right, re\bottom, Flags)
                  If Image = #PB_Any : Image = result : EndIf
                  If result
                    DestDC = StartDrawing(ImageOutput(Image))
                    If DestDC
                      Success = BitBlt_(DestDC,0,0,re\right,re\bottom,DC,0,0,#SRCCOPY)
                      StopDrawing()
                    EndIf
                    If Success = #False : FreeImage(Image) : EndIf
                  EndIf
                EndIf
                Lock\Release()
              EndIf
              surf\Release()
            EndIf
            dxsf\Release()
          EndIf
          Stream\Release()
        EndIf
        dxtf\Release()
      EndIf
      ;CoUninitialize_() ; dosn't work with this ?!?
    EndIf
    
    If Success : ProcedureReturn result : EndIf
    ProcedureReturn #False
    
  EndProcedure
  ;
  DataSection
    CompilerIf Not Defined(CLSID_DXTransformFactory, #PB_Label)
      CLSID_DXTransformFactory:
      Data.l $D1FE6762
      Data.w $FC48,$11D0
      Data.b $88,$3A,$3C,$8B,$00,$C1,$00,$00
    CompilerEndIf
    CompilerIf Not Defined(IID_IDXTransformFactory, #PB_Label)
      IID_IDXTransformFactory:
      Data.l $6A950B2B
      Data.w $A971,$11D1
      Data.b $81,$C8,$00,$00,$F8,$75,$57,$DB
    CompilerEndIf
    CompilerIf Not Defined(IID_IDXSurfaceFactory, #PB_Label)
      IID_IDXSurfaceFactory:
      Data.l $144946F5
      Data.w $C4D4,$11D1
      Data.b $81,$D1,$00,$00,$F8,$75,$57,$DB
    CompilerEndIf
    CompilerIf Not Defined(IID_IDXSurface, #PB_Label)
      IID_IDXSurface:
      Data.l $B39FD73F
      Data.w $E139,$11D1
      Data.b $90,$65,$00,$C0,$4F,$D9,$18,$9D
    CompilerEndIf
  EndDataSection
CompilerEndIf
CompilerIf Not Defined(CatchPackImage, #PB_Procedure) ; << Catch one Imagefile from a Packfile. PackerPlugin like UseZipPacker() needed
  Procedure CatchPackImage(Image, PackFile.s, FileName.s, Plugin = #PB_PackerPlugin_Zip)
    
    Protected Result = #False, Pack, *Mem, USize, Size
    Protected fExt.s = LCase(GetExtensionPart(FileName))
    
    If FileSize(PackFile) => 0
      
      Pack = OpenPack(#PB_Any, PackFile, Plugin)
      
      If Pack
        If ExaminePack(Pack)
          While NextPackEntry(Pack)
            If PackEntryType(Pack) = #PB_Packer_File
              If PackEntryName(Pack) = FileName
                USize = PackEntrySize(Pack, #PB_Packer_UncompressedSize)
                *Mem = AllocateMemory(USize)
                If *Mem
                  Size = UncompressPackMemory(Pack, *Mem, MemorySize(*Mem))
                  If Size = USize
                    CompilerIf Defined(CatchImageEx, #PB_Procedure)
                      If FindString(fExt, "png")
                        Result = CatchImageEx(Image, *Mem, MemorySize(*Mem), 32)
                      Else
                        Result = CatchImageEx(Image, *Mem, MemorySize(*Mem), 24)
                      EndIf
                    CompilerElse
                      Result = CatchImage(Image, *Mem, USize)
                    CompilerEndIf
                  Else
                    CompilerIf #PB_Compiler_Debugger
                      Debug "Could not unpack correct!"
                    CompilerEndIf
                  EndIf
                  FreeMemory(*Mem)
                Else
                  CompilerIf #PB_Compiler_Debugger
                    Debug "Memory could not initialize!"
                  CompilerEndIf
                EndIf
                Break
              EndIf
            EndIf
          Wend
        EndIf
        ClosePack(Pack)
      EndIf
      
      If Image = #PB_Any : Image = Result : EndIf
      If Not IsImage(Image)
        Result = #False
        CompilerIf #PB_Compiler_Debugger
          Debug "No image initialized !"
        CompilerEndIf
      EndIf
      
    Else
      CompilerIf #PB_Compiler_Debugger : Debug "Packfile not found !" : CompilerEndIf
    EndIf
    
    ProcedureReturn Result
    
  EndProcedure
CompilerEndIf

;-Example
CompilerIf #PB_Compiler_IsMainFile
  UseZipPacker()
  
  CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
    UsePNGImageDecoder()
  CompilerEndIf
  
  Define.s ZipFile = #PB_Compiler_Home + "themes/SilkTheme.zip", File = "add.png" ; << PB-Theme
  Define.i Image, Window, Button
  
  Image = CatchPackImage(#PB_Any, ZipFile, File)
  
  If IsImage(Image)
    
    Window = OpenWindow(#PB_Any, 0, 0, 80, 80, "Test", #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
    If IsWindow(Window)
      Button = ButtonImageGadget(#PB_Any, 40, 20, 40, 40, ImageID(Image))
      Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
    EndIf
  EndIf
CompilerEndIf
