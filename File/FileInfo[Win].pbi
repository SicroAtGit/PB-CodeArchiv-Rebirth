;   Description: Gets information from executable file
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=30000
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017-2018 Sicro
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

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
  CompilerError "Supported OS are only: Windows"
CompilerEndIf

DeclareModule FileInfo
  EnableExplicit
  
  Declare$  GetFixedProductVersion(File$)
  Declare$  GetFixedFileVersion(File$)
  Declare$  GetFixedFileType(File$)
  Declare$  GetProductVersion(File$)
  Declare$  GetFileVersion(File$)
  Declare$  GetProductName(File$)
  Declare$  GetFileDescription(File$)
  Declare$  GetFileComments(File$)
  Declare$  GetFileCompanyName(File$)
  Declare$  GetFileInternalName(File$)
  Declare$  GetFileLegalCopyright(File$)
  Declare$  GetFileLegalTrademarks(File$)
  Declare$  GetFileOriginalFilename(File$)
  Declare.i GetFileBitSystem(File$)
  Declare.i GetIcon(File$, IconSize, StretchIcon=#False)
EndDeclareModule

Module FileInfo
  Procedure.i LocalizeFixedDataStructure(File$, *Buffer.Integer, *Pointer.Integer)
    Protected.i NeededBufferSize, PointerLen
    
    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn #False: EndIf
    
    *Buffer\i = AllocateMemory(NeededBufferSize)
    
    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer\i)
    VerQueryValue_(*Buffer\i, "\", @*Pointer\i, @PointerLen)
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure$ GetFixedProductVersion(File$)
    Protected *Buffer, *Pointer.VS_FIXEDFILEINFO
    Protected RetVal$
    
    If LocalizeFixedDataStructure(File$, @*Buffer, @*Pointer)
      RetVal$ = Str(*Pointer\dwProductVersionMS >> 16 & $FFFF) + "." +
                Str(*Pointer\dwProductVersionMS & $FFFF) + "." +
                Str(*Pointer\dwProductVersionLS >> 16 & $FFFF) + "." +
                Str(*Pointer\dwProductVersionLS & $FFFF)
      
      FreeMemory(*Buffer)
    EndIf
    
    ProcedureReturn RetVal$
  EndProcedure
  
  Procedure$ GetFixedFileVersion(File$)
    Protected *Buffer, *Pointer.VS_FIXEDFILEINFO
    Protected RetVal$
    
    If LocalizeFixedDataStructure(File$, @*Buffer, @*Pointer)
      RetVal$ = Str(*Pointer\dwFileVersionMS >> 16 & $FFFF) + "." +
                Str(*Pointer\dwFileVersionMS & $FFFF) + "." +
                Str(*Pointer\dwFileVersionLS >> 16 & $FFFF) + "." +
                Str(*Pointer\dwFileVersionLS & $FFFF)
      
      FreeMemory(*Buffer)
    EndIf
    
    ProcedureReturn RetVal$
  EndProcedure
  
  Procedure$ GetFixedFileType(File$)
    Protected *Buffer, *Pointer.VS_FIXEDFILEINFO
    Protected RetVal$
    
    If LocalizeFixedDataStructure(File$, @*Buffer, @*Pointer)
      Select *Pointer\dwFileType
        Case #VFT_APP
          RetVal$ = "Application"
        Case #VFT_DLL
          RetVal$ = "DLL"
        Case #VFT_DRV
          Select *Pointer\dwFileSubtype
            Case #VFT2_DRV_COMM
              RetVal$ = "Communications Driver"
            Case #VFT2_DRV_DISPLAY
              RetVal$ = "Display Driver"
            Case #VFT2_DRV_INSTALLABLE
              RetVal$ = "Installable Driver"
            Case #VFT2_DRV_KEYBOARD
              RetVal$ = "Keyboard Driver"
            Case #VFT2_DRV_LANGUAGE
              RetVal$ = "Language Driver"
            Case #VFT2_DRV_MOUSE
              RetVal$ = "Mouse Driver"
            Case #VFT2_DRV_NETWORK
              RetVal$ = "Network Driver"
            Case #VFT2_DRV_PRINTER
              RetVal$ = "Printer Driver"
            Case #VFT2_DRV_SOUND
              RetVal$ = "Sound Driver"
            Case #VFT2_DRV_SYSTEM
              RetVal$ = "System Driver"
              ;Case #VFT2_DRV_VERSIONED_PRINTER
              ; RetVal = "Versioned Printer Driver"
            Case #VFT2_UNKNOWN
              RetVal$ = "Unknown by the system"
          EndSelect
        Case #VFT_FONT
          Select *Pointer\dwFileSubtype
            Case #VFT2_FONT_RASTER
              RetVal$ = "Raster Font"
            Case #VFT2_FONT_TRUETYPE
              RetVal$ = "TrueType Font"
            Case #VFT2_FONT_VECTOR
              RetVal$ = "Vector Font"
            Case #VFT2_UNKNOWN
              RetVal$ = "Unknown by the system"
          EndSelect
        Case #VFT_STATIC_LIB
          RetVal$ = "Static-link Library"
        Case #VFT_UNKNOWN
          RetVal$ = "Unknown by the system"
        Case #VFT_VXD
          RetVal$ = "Virtual Device"
      EndSelect
      
      FreeMemory(*Buffer)
    EndIf
    
    ProcedureReturn RetVal$
  EndProcedure
  
  Procedure$ GetStringFileInfo(File$, Field$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer
    Protected   TranslationCode$, RetVal$
    Protected NewList TranslationCode_Fallbacks$()
    
    AddElement(TranslationCode_Fallbacks$()) : TranslationCode_Fallbacks$() = "040904B0" ; US English + CP_UNICODE
    AddElement(TranslationCode_Fallbacks$()) : TranslationCode_Fallbacks$() = "040904E4" ; US English + CP_USASCII
    AddElement(TranslationCode_Fallbacks$()) : TranslationCode_Fallbacks$() = "04090000" ; US English + unknown codepage
    
    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf
    
    *Buffer = AllocateMemory(NeededBufferSize)
    
    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\\VarFileInfo\\Translation", @*Pointer, @PointerLen)
    If *Pointer
      TranslationCode$ = RSet(Hex(PeekW(*Pointer)), 4, "0") + RSet(Hex(PeekW(*Pointer + 2)), 4, "0")
      If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode$ + "\\" + Field$, @*Pointer, @PointerLen)
        RetVal$ = Trim(PeekS(*Pointer))
      Else
        ; Some programs have an incorrect translation code for which there is no information block.
        ; I have made the experience that in this case there is always a block with one of these translation codes:
        ForEach TranslationCode_Fallbacks$()
          If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode_Fallbacks$() + "\\" + Field$, @*Pointer, @PointerLen)
            RetVal$ = Trim(PeekS(*Pointer))
            If RetVal$ <> "" : Break : EndIf
          EndIf
        Next
      EndIf
    EndIf
    FreeMemory(*Buffer)
    
    ProcedureReturn RetVal$
  EndProcedure
  
  Procedure$ GetProductVersion(File$)
    ProcedureReturn GetStringFileInfo(File$, "ProductVersion")
  EndProcedure
  
  Procedure$ GetFileVersion(File$)
    ProcedureReturn GetStringFileInfo(File$, "FileVersion")
  EndProcedure
  
  Procedure$ GetProductName(File$)
    ProcedureReturn GetStringFileInfo(File$, "ProductName")
  EndProcedure
  
  Procedure$ GetFileDescription(File$)
    ProcedureReturn GetStringFileInfo(File$, "FileDescription")
  EndProcedure
  
  Procedure$ GetFileComments(File$)
    ProcedureReturn GetStringFileInfo(File$, "Comments")
  EndProcedure
  
  Procedure$ GetFileCompanyName(File$)
    ProcedureReturn GetStringFileInfo(File$, "CompanyName")
  EndProcedure
  
  Procedure$ GetFileInternalName(File$)
    ProcedureReturn GetStringFileInfo(File$, "InternalName")
  EndProcedure
  
  Procedure$ GetFileLegalCopyright(File$)
    ProcedureReturn GetStringFileInfo(File$, "LegalCopyright")
  EndProcedure
  
  Procedure$ GetFileLegalTrademarks(File$)
    ProcedureReturn GetStringFileInfo(File$, "LegalTrademarks")
  EndProcedure
  
  Procedure$ GetFileOriginalFilename(File$)
    ProcedureReturn GetStringFileInfo(File$, "OriginalFilename")
  EndProcedure
  
  Procedure.i GetFileBitSystem(File$)
    #SCS_64BIT_BINARY = 6
    Protected.l BinaryType
    
    GetBinaryType_(@File$, @BinaryType)
    Select BinaryType
      Case #SCS_32BIT_BINARY : ProcedureReturn 32
      Case #SCS_64BIT_BINARY : ProcedureReturn 64
      Case #SCS_WOW_BINARY   : ProcedureReturn 16
    EndSelect
  EndProcedure
  
  DataSection
    IID_IImageList:
    Data.l $46EB5926
    Data.w $582E, $4017
    Data.b $9F, $DF, $E8, $99, $8D, $AA, $09, $50
  EndDataSection
  
  Procedure.i SHGetImageList(iImageList.i, riid.i, *ppvObj)
    Protected Library, Result
    
    Library = OpenLibrary(#PB_Any, "shell32.dll")
    If Library
      Result = CallFunction(Library, "SHGetImageList", iImageList.i, riid.i, *ppvObj)
      CloseLibrary(Library)
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i GetIcon(File$, IconSize, StretchIcon=#False)
    Protected FileInfo.SHFILEINFO, ImageList.IImageList
    Protected IconHandle, Image, IconSizeType, RealIconWidth, RealIconHeight
    
    If FileSize(File$) < 0
      ProcedureReturn 0
    EndIf
    
    Select IconSize
        
      Case 1 To 16
        IconSizeType = #SHIL_SMALL
        ; These images are the Shell standard small icon size of 16x16, but
        ; the size can be customized by the user.
        
      Case 17 To 32
        IconSizeType = #SHIL_LARGE
        ; The image size is normally 32x32 pixels. However, if the use large
        ; icons option is selected from the Effects section of the Appearance
        ; tab in Display Properties, the image is 48x48 pixels.
        
      Case 33 To 48
        IconSizeType = #SHIL_EXTRALARGE
        ; These images are the Shell standard extra-large icon size. This is
        ; typically 48x48, but the size can be customized by the user.
        
      Case 49 To 8192
        ; Because it is possible to stretch the icons, the maximum image size
        ; supported by the operating systems is also included here.
        If OSVersion() >= #PB_OS_Windows_Vista
          IconSizeType = #SHIL_JUMBO
          ; Windows Vista and later. The image is normally 256x256 pixels.
        Else
          IconSizeType = #SHIL_EXTRALARGE
          ; Because the operating system does not support such large icons,
          ; use the maximum supported icon size type as a fallback.
        EndIf
        
      Default
        ProcedureReturn 0
        
    EndSelect
    
    ; Get the index of the system image list icon
    SHGetFileInfo_(@File$, 0, @FileInfo, SizeOf(FileInfo), #SHGFI_SYSICONINDEX)
    
    ; Get an image list that contains icons of the required size
    If SHGetImageList(IconSizeType, ?IID_IImageList, @ImageList) = #S_OK
      
      ; Get the icon at the specified index position
      ImageList\GetIcon(FileInfo\iIcon, #ILD_TRANSPARENT, @IconHandle)
      If IconHandle
        
        ; Create a PB image and draw the icon into it
        Image = CreateImage(#PB_Any, IconSize, IconSize, 32, #PB_Image_Transparent)
        If Image
          If StartDrawing(ImageOutput(Image))
            If StretchIcon
              ; If there is no icon in the file that corresponds to the
              ; required size, the image is stretched to the required size
              ; in this mode.
              DrawImage(IconHandle, 0, 0, IconSize, IconSize)
            Else
              ; If there is no icon in the file that corresponds to the
              ; required size, the image is positioned centered in this mode.
              ImageList\GetIconSize(@RealIconWidth, @RealIconHeight)
              If (IconSize < RealIconWidth) Or (IconSize < RealIconHeight)
                ; If the obtained icon is larger than required, the icon will
                ; be downsized to the required size.
                DrawImage(IconHandle, 0, 0, IconSize, IconSize)
              Else
                DrawImage(IconHandle, IconSize/2-RealIconWidth/2, IconSize/2-RealIconHeight/2)
              EndIf
            EndIf
            DestroyIcon_(IconHandle)
            StopDrawing()
          EndIf
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Image
  EndProcedure
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  Define File$ = "C:\WINDOWS\system32\notepad.exe"
  
  Debug "FileComments:         " + FileInfo::GetFileComments(File$)
  Debug "FileCompanyName:      " + FileInfo::GetFileCompanyName(File$)
  Debug "FileDescription:      " + FileInfo::GetFileDescription(File$)
  Debug "FileInternalName:     " + FileInfo::GetFileInternalName(File$)
  Debug "FileLegalCopyright:   " + FileInfo::GetFileLegalCopyright(File$)
  Debug "FileLegalTrademarks:  " + FileInfo::GetFileLegalTrademarks(File$)
  Debug "FileOriginalFilename: " + FileInfo::GetFileOriginalFilename(File$)
  Debug "FileVersion:          " + FileInfo::GetFileVersion(File$)
  Debug "FixedFileType:        " + FileInfo::GetFixedFileType(File$)
  Debug "FixedFileVersion:     " + FileInfo::GetFixedFileVersion(File$)
  Debug "FixedProductVersion:  " + FileInfo::GetFixedProductVersion(File$)
  Debug "ProductName:          " + FileInfo::GetProductName(File$)
  Debug "ProductVersion:       " + FileInfo::GetProductVersion(File$)
  Debug "FileBitSystem:        " + FileInfo::GetFileBitSystem(File$)
  
  Define Image = FileInfo::GetIcon(File$, 32)
  If Image
    If OpenWindow(0, #PB_Ignore, #PB_Ignore, 100, 100, "Icon Extraction", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
      ImageGadget(0, 0, 0, WindowWidth(0), WindowHeight(0), ImageID(Image))
      While WaitWindowEvent() <> #PB_Event_CloseWindow : Wend
    EndIf
  Else
    Debug "GetIcon: Error"
  EndIf
CompilerEndIf
