;   Description: Adds directory entries to a list
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
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

; Thanks goes to "useful" from the English forum for the inspiration to use a callback:
; http://www.purebasic.fr/english/viewtopic.php?f=12&t=68172

EnumerationBinary 
  #ListDirectoryEntries_Mode_ListDirectories
  #ListDirectoryEntries_Mode_ListFiles
  #ListDirectoryEntries_Mode_ListAll = #ListDirectoryEntries_Mode_ListDirectories | #ListDirectoryEntries_Mode_ListFiles
EndEnumeration

Prototype ProtoListDirectoryEntriesCallback(EntryPath$, Directory)

Procedure ListDirectoryEntries(Path$, Callback.ProtoListDirectoryEntriesCallback, FileExtensions$="", EnableRecursiveScan=#True, Mode=#ListDirectoryEntries_Mode_ListAll)

  Protected Directory
  Protected EntryName$
  Protected EntryExtension$
  Protected Slash$

  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows: Slash$ = "\"
    CompilerDefault:           : Slash$ = "/"
  CompilerEndSelect

  If Right(Path$, 1) <> Slash$
    Path$ + Slash$
  EndIf
  
  FileExtensions$ = "," + FileExtensions$ + ","

  Directory = ExamineDirectory(#PB_Any, Path$, "*")
  If Directory
    While NextDirectoryEntry(Directory)

      EntryName$ = DirectoryEntryName(Directory)

      Select DirectoryEntryType(Directory)

        Case #PB_DirectoryEntry_File

          If Mode & #ListDirectoryEntries_Mode_ListFiles
            If FileExtensions$ <> ",,"
              EntryExtension$ = GetExtensionPart(EntryName$)
              If EntryExtension$ = ""
                Continue
              EndIf
              If Not FindString(FileExtensions$, "," + EntryExtension$ + ",")
                Continue
              EndIf
            EndIf
            Callback(Path$ + EntryName$, Directory)
          EndIf

        Case #PB_DirectoryEntry_Directory

          If EntryName$ <> "." And EntryName$ <> ".."
            If Mode & #ListDirectoryEntries_Mode_ListDirectories
              Callback(Path$ + EntryName$ + Slash$, Directory)
            EndIf

            If EnableRecursiveScan
              ListDirectoryEntries(Path$ + EntryName$, Callback, FileExtensions$, EnableRecursiveScan, Mode)
            EndIf

          EndIf

      EndSelect

    Wend
    FinishDirectory(Directory)
  EndIf

EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  Procedure Callback(EntryPath$, Directory)
    Debug "Path:           " + EntryPath$
    Select DirectoryEntryType(Directory)
      Case #PB_DirectoryEntry_File      : Debug "Filename:       " + DirectoryEntryName(Directory)
      Case #PB_DirectoryEntry_Directory : Debug "Directory name: " + DirectoryEntryName(Directory)
    EndSelect
    Debug "--------------"
  EndProcedure
  
  ListDirectoryEntries(GetUserDirectory(#PB_Directory_Documents), @Callback())
  ;ListDirectoryEntries(GetUserDirectory(#PB_Directory_Documents), @Callback(), "pdf,txt", #True, #ListDirectoryEntries_Mode_ListFiles)
  ;ListDirectoryEntries(GetUserDirectory(#PB_Directory_Documents), @Callback(), "", #True, #ListDirectoryEntries_Mode_ListDirectories)
  ;ListDirectoryEntries(GetUserDirectory(#PB_Directory_Documents), @Callback(), "", #False, #ListDirectoryEntries_Mode_ListFiles)
  
CompilerEndIf
