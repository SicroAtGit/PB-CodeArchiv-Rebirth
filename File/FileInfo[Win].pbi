;   Description: Gets informations from executable file
;            OS: Windows
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=30000
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2017 Sicro
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

  Declare$ GetFixedProductVersion(File$)
  Declare$ GetFixedFileVersion(File$)
  Declare$ GetFixedFileType(File$)
  Declare$ GetProductVersion(File$)
  Declare$ GetFileVersion(File$)
  Declare$ GetProductName(File$)
  Declare$ GetFileDescription(File$)
  Declare$ GetFileComments(File$)
  Declare$ GetFileCompanyName(File$)
  Declare$ GetFileInternalName(File$)
  Declare$ GetFileLegalCopyright(File$)
  Declare$ GetFileLegalTrademarks(File$)
  Declare$ GetFileOriginalFilename(File$)
EndDeclareModule

Module FileInfo
  Procedure$ GetFixedProductVersion(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer.VS_FIXEDFILEINFO
    Protected   RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\", @*Pointer, @PointerLen)
    If *Pointer
      RetVal$ = Str(*Pointer\dwProductVersionMS >> 16 & $FFFF) + "." +
               Str(*Pointer\dwProductVersionMS & $FFFF) + "." +
               Str(*Pointer\dwProductVersionLS >> 16 & $FFFF) + "." +
               Str(*Pointer\dwProductVersionLS & $FFFF)
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn RetVal$
  EndProcedure

  Procedure$ GetFixedFileVersion(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer.VS_FIXEDFILEINFO
    Protected   RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\", @*Pointer, @PointerLen)
    If *Pointer
      RetVal$ = Str(*Pointer\dwFileVersionMS >> 16 & $FFFF) + "." +
               Str(*Pointer\dwFileVersionMS & $FFFF) + "." +
               Str(*Pointer\dwFileVersionLS >> 16 & $FFFF) + "." +
               Str(*Pointer\dwFileVersionLS & $FFFF)
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn RetVal$
  EndProcedure

  Procedure$ GetFixedFileType(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer.VS_FIXEDFILEINFO
    Protected   RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\", @*Pointer, @PointerLen)
    If *Pointer
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

  Procedure$ GetProductVersion(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer
    Protected   TranslationCode$, RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\\VarFileInfo\\Translation", @*Pointer, @PointerLen)
    If *Pointer
      TranslationCode$ = RSet(Hex(PeekW(*Pointer)), 4, "0") + RSet(Hex(PeekW(*Pointer + 2)), 4, "0")
      If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode$ + "\\ProductVersion", @*Pointer, @PointerLen)
        RetVal$ = PeekS(*Pointer)
      Else
        ; Manche Programme haben einen falschen TranslationCode, zu dem es kein Informationen-Block gibt.
        ; Ich habe die Erfahrung gemacht, dass in diesem Fall immer ein Block mit diesem TranslationCode vorhanden ist:
        If VerQueryValue_(*Buffer, "\\StringFileInfo\\040904E4\\ProductVersion", @*Pointer, @PointerLen)
          RetVal$ = PeekS(*Pointer)
        EndIf
      EndIf
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn Trim(RetVal$)
  EndProcedure

  Procedure$ GetFileVersion(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer
    Protected   TranslationCode$, RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\\VarFileInfo\\Translation", @*Pointer, @PointerLen)
    If *Pointer
      TranslationCode$ = RSet(Hex(PeekW(*Pointer)), 4, "0") + RSet(Hex(PeekW(*Pointer + 2)), 4, "0")
      If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode$ + "\\FileVersion", @*Pointer, @PointerLen)
        RetVal$ = PeekS(*Pointer)
      Else
        ; Manche Programme haben einen falschen TranslationCode, zu dem es kein Informationen-Block gibt.
        ; Ich habe die Erfahrung gemacht, dass in diesem Fall immer ein Block mit diesem TranslationCode vorhanden ist:
        If VerQueryValue_(*Buffer, "\\StringFileInfo\\040904E4\\FileVersion", @*Pointer, @PointerLen)
          RetVal$ = PeekS(*Pointer)
        EndIf
      EndIf
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn Trim(RetVal$)
  EndProcedure

  Procedure$ GetProductName(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer
    Protected   TranslationCode$, RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\\VarFileInfo\\Translation", @*Pointer, @PointerLen)
    If *Pointer
      TranslationCode$ = RSet(Hex(PeekW(*Pointer)), 4, "0") + RSet(Hex(PeekW(*Pointer + 2)), 4, "0")
      If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode$ + "\\ProductName", @*Pointer, @PointerLen)
        RetVal$ = PeekS(*Pointer)
      Else
        ; Manche Programme haben einen falschen TranslationCode, zu dem es kein Informationen-Block gibt.
        ; Ich habe die Erfahrung gemacht, dass in diesem Fall immer ein Block mit diesem TranslationCode vorhanden ist:
        If VerQueryValue_(*Buffer, "\\StringFileInfo\\040904E4\\ProductName", @*Pointer, @PointerLen)
          RetVal$ = PeekS(*Pointer)
        EndIf
      EndIf
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn Trim(RetVal$)
  EndProcedure

  Procedure$ GetFileDescription(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer
    Protected   TranslationCode$, RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\\VarFileInfo\\Translation", @*Pointer, @PointerLen)
    If *Pointer
      TranslationCode$ = RSet(Hex(PeekW(*Pointer)), 4, "0") + RSet(Hex(PeekW(*Pointer + 2)), 4, "0")
      If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode$ + "\\FileDescription", @*Pointer, @PointerLen)
        RetVal$ = PeekS(*Pointer)
      Else
        ; Manche Programme haben einen falschen TranslationCode, zu dem es kein Informationen-Block gibt.
        ; Ich habe die Erfahrung gemacht, dass in diesem Fall immer ein Block mit diesem TranslationCode vorhanden ist:
        If VerQueryValue_(*Buffer, "\\StringFileInfo\\040904E4\\FileDescription", @*Pointer, @PointerLen)
          RetVal$ = PeekS(*Pointer)
        EndIf
      EndIf
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn Trim(RetVal$)
  EndProcedure

  Procedure$ GetFileComments(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer
    Protected   TranslationCode$, RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\\VarFileInfo\\Translation", @*Pointer, @PointerLen)
    If *Pointer
      TranslationCode$ = RSet(Hex(PeekW(*Pointer)), 4, "0") + RSet(Hex(PeekW(*Pointer + 2)), 4, "0")
      If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode$ + "\\Comments", @*Pointer, @PointerLen)
        RetVal$ = PeekS(*Pointer)
      Else
        ; Manche Programme haben einen falschen TranslationCode, zu dem es kein Informationen-Block gibt.
        ; Ich habe die Erfahrung gemacht, dass in diesem Fall immer ein Block mit diesem TranslationCode vorhanden ist:
        If VerQueryValue_(*Buffer, "\\StringFileInfo\\040904E4\\Comments", @*Pointer, @PointerLen)
          RetVal$ = PeekS(*Pointer)
        EndIf
      EndIf
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn Trim(RetVal$)
  EndProcedure

  Procedure$ GetFileCompanyName(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer
    Protected   TranslationCode$, RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\\VarFileInfo\\Translation", @*Pointer, @PointerLen)
    If *Pointer
      TranslationCode$ = RSet(Hex(PeekW(*Pointer)), 4, "0") + RSet(Hex(PeekW(*Pointer + 2)), 4, "0")
      If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode$ + "\\CompanyName", @*Pointer, @PointerLen)
        RetVal$ = PeekS(*Pointer)
      Else
        ; Manche Programme haben einen falschen TranslationCode, zu dem es kein Informationen-Block gibt.
        ; Ich habe die Erfahrung gemacht, dass in diesem Fall immer ein Block mit diesem TranslationCode vorhanden ist:
        If VerQueryValue_(*Buffer, "\\StringFileInfo\\040904E4\\CompanyName", @*Pointer, @PointerLen)
          RetVal$ = PeekS(*Pointer)
        EndIf
      EndIf
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn Trim(RetVal$)
  EndProcedure

  Procedure$ GetFileInternalName(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer
    Protected   TranslationCode$, RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\\VarFileInfo\\Translation", @*Pointer, @PointerLen)
    If *Pointer
      TranslationCode$ = RSet(Hex(PeekW(*Pointer)), 4, "0") + RSet(Hex(PeekW(*Pointer + 2)), 4, "0")
      If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode$ + "\\InternalName", @*Pointer, @PointerLen)
        RetVal$ = PeekS(*Pointer)
      Else
        ; Manche Programme haben einen falschen TranslationCode, zu dem es kein Informationen-Block gibt.
        ; Ich habe die Erfahrung gemacht, dass in diesem Fall immer ein Block mit diesem TranslationCode vorhanden ist:
        If VerQueryValue_(*Buffer, "\\StringFileInfo\\040904E4\\InternalName", @*Pointer, @PointerLen)
          RetVal$ = PeekS(*Pointer)
        EndIf
      EndIf
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn Trim(RetVal$)
  EndProcedure

  Procedure$ GetFileLegalCopyright(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer
    Protected   TranslationCode$, RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\\VarFileInfo\\Translation", @*Pointer, @PointerLen)
    If *Pointer
      TranslationCode$ = RSet(Hex(PeekW(*Pointer)), 4, "0") + RSet(Hex(PeekW(*Pointer + 2)), 4, "0")
      If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode$ + "\\LegalCopyright", @*Pointer, @PointerLen)
        RetVal$ = PeekS(*Pointer)
      Else
        ; Manche Programme haben einen falschen TranslationCode, zu dem es kein Informationen-Block gibt.
        ; Ich habe die Erfahrung gemacht, dass in diesem Fall immer ein Block mit diesem TranslationCode vorhanden ist:
        If VerQueryValue_(*Buffer, "\\StringFileInfo\\040904E4\\LegalCopyright", @*Pointer, @PointerLen)
          RetVal$ = PeekS(*Pointer)
        EndIf
      EndIf
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn Trim(RetVal$)
  EndProcedure

  Procedure$ GetFileLegalTrademarks(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer
    Protected   TranslationCode$, RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\\VarFileInfo\\Translation", @*Pointer, @PointerLen)
    If *Pointer
      TranslationCode$ = RSet(Hex(PeekW(*Pointer)), 4, "0") + RSet(Hex(PeekW(*Pointer + 2)), 4, "0")
      If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode$ + "\\LegalTrademarks", @*Pointer, @PointerLen)
        RetVal$ = PeekS(*Pointer)
      Else
        ; Manche Programme haben einen falschen TranslationCode, zu dem es kein Informationen-Block gibt.
        ; Ich habe die Erfahrung gemacht, dass in diesem Fall immer ein Block mit diesem TranslationCode vorhanden ist:
        If VerQueryValue_(*Buffer, "\\StringFileInfo\\040904E4\\LegalTrademarks", @*Pointer, @PointerLen)
          RetVal$ = PeekS(*Pointer)
        EndIf
      EndIf
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn Trim(RetVal$)
  EndProcedure

  Procedure$ GetFileOriginalFilename(File$)
    Protected.i NeededBufferSize, PointerLen
    Protected   *Buffer, *Pointer
    Protected   TranslationCode$, RetVal$

    NeededBufferSize = GetFileVersionInfoSize_(@File$, 0)
    If NeededBufferSize < 1: ProcedureReturn "": EndIf

    *Buffer = AllocateMemory(NeededBufferSize)

    GetFileVersionInfo_(@File$, 0, NeededBufferSize, *Buffer)
    VerQueryValue_(*Buffer, "\\VarFileInfo\\Translation", @*Pointer, @PointerLen)
    If *Pointer
      TranslationCode$ = RSet(Hex(PeekW(*Pointer)), 4, "0") + RSet(Hex(PeekW(*Pointer + 2)), 4, "0")
      If VerQueryValue_(*Buffer, "\\StringFileInfo\\" + TranslationCode$ + "\\OriginalFilename", @*Pointer, @PointerLen)
        RetVal$ = PeekS(*Pointer)
      Else
        ; Manche Programme haben einen falschen TranslationCode, zu dem es kein Informationen-Block gibt.
        ; Ich habe die Erfahrung gemacht, dass in diesem Fall immer ein Block mit diesem TranslationCode vorhanden ist:
        If VerQueryValue_(*Buffer, "\\StringFileInfo\\040904E4\\OriginalFilename", @*Pointer, @PointerLen)
          RetVal$ = PeekS(*Pointer)
        EndIf
      EndIf
    EndIf
    FreeMemory(*Buffer)

    ProcedureReturn Trim(RetVal$)
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
CompilerEndIf
