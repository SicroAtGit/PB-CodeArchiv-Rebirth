;   Description: Gets informations from executable file
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
    EndIf
    FreeMemory(*Buffer)
    
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
    EndIf
    FreeMemory(*Buffer)
    
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
              RetVal$ = "Unkown by the system"
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
              RetVal$ = "Unkown by the system"
          EndSelect
        Case #VFT_STATIC_LIB
          RetVal$ = "Static-link Library"
        Case #VFT_UNKNOWN
          RetVal$ = "Unkown by the system"
        Case #VFT_VXD
          RetVal$ = "Virtual Device"
      EndSelect
    EndIf
    FreeMemory(*Buffer)
    
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
        ; Manche Programme haben einen falschen TranslationCode, zu dem es kein Informationen-Block gibt.
        ; Ich habe die Erfahrung gemacht, dass in diesem Fall immer ein Block mit diesem TranslationCode vorhanden ist:
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
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  Define File$ = "notepad.exe"
  
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
CompilerEndIf
