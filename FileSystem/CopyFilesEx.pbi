;   Description: Similar CopyDirectory, but with the support to obtain information about the progress and to cancel the operation
;            OS: Windows, Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?f=8&t=27814
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014-2016 ts-soft (Thomas Schulz)
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

;======================================================================
; Module:          CopyDirEx.pbi
;
; Author:          Thomas (ts-soft) Schulz
; Date:            Jan 31, 2016
; Version:         1.5
; Target Compiler: PureBasic 5.2+
; Target OS:       All
;======================================================================
; History:
; Version 1.5
; + small update for windows attributes (special windows 10)

; Version 1.4
; + small update to example

; Version 1.3
; + some optimization
; + more accurate progress

; Version 1.2
; + empty dirs missing, resolved
; + bug with attributes of dirs, resolved

DeclareModule CopyDirEx
  
  EnableExplicit
  
  Prototype.i CopyDirExCB(File.s, Dir.s, Sum.i, Procent.i)
  
  Declare CopyDirectoryEx(SourceDirectory.s,
                          DestinationDirectory.s,
                          Pattern.s = "",
                          BufferSize.l = 4096,
                          CustomEvent.l = #PB_Event_FirstCustomValue, ; This event is fired after Copying finished or canceld (SignalStop).
                          Callback.i = 0)                             ; See Prototype CopyDirExCB.
                                                                      ; Result = Thread (result from CreateThread()).
  Declare SignalStop()                                                ; send a signal to stop copying after actual file!
  
EndDeclareModule

Module CopyDirEx
  
  CompilerIf Not #PB_Compiler_Thread
    CompilerError "CopyDirEx requires ThreadSafe Compileroption!"
  CompilerEndIf
  
  Structure RecursiveFiles
    Directory.s
    Name.s
    Attributes.l
    Date.l[3]
    Size.q
    Type.b
  EndStructure
  
  Structure CopyThreadPara
    SourceDirectory.s
    DestinationDirectory.s
    BufferSize.l
    CustomEvent.l
    Callback.i
    cFiles.i
  EndStructure
  
  Global NewList RecursiveFiles.RecursiveFiles()
  Global Mutex = CreateMutex()
  Global Semaphore = CreateSemaphore()
  Global slash.s
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      slash = "\"
    CompilerDefault
      slash = "/"
  CompilerEndSelect
  
  ; private functions
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #FILE_ATTRIBUTE_DEVICE              =     64 ;(0x40)
      #FILE_ATTRIBUTE_INTEGRITY_STREAM    =  32768 ;(0x8000)
      #FILE_ATTRIBUTE_NOT_CONTENT_INDEXED  =   8192;(0x2000)
      #FILE_ATTRIBUTE_NO_SCRUB_DATA        = 131072;(0x20000)
      #FILE_ATTRIBUTE_VIRTUAL              =  65536;(0x10000)
      #FILE_ATTRIBUTE_DONTSETFLAGS = ~(#FILE_ATTRIBUTE_DIRECTORY|
                                       #FILE_ATTRIBUTE_SPARSE_FILE|
                                       #FILE_ATTRIBUTE_OFFLINE|
                                       #FILE_ATTRIBUTE_NOT_CONTENT_INDEXED|
                                       #FILE_ATTRIBUTE_VIRTUAL|
                                       0)
      Macro SetFileAttributesEx(Name, Attribs)
        SetFileAttributes(Name, Attribs & #FILE_ATTRIBUTE_DONTSETFLAGS)
      EndMacro
    CompilerDefault
      Macro SetFileAttributesEx(Name, Attribs)
        SetFileAttributes(Name, Attribs)
      EndMacro
  CompilerEndSelect
  
  Procedure CreateDirectoryEx(DirectoryName.s, FileAttribute = #PB_Default)
    Protected i, c, tmp.s
    
    If Right(DirectoryName, 1) = slash
      DirectoryName = Left(DirectoryName, Len(DirectoryName) -1)
    EndIf
    c = CountString(DirectoryName, slash) + 1
    For i = 1 To c
      tmp + StringField(DirectoryName, i, slash)
      If FileSize(tmp) <> -2
        CreateDirectory(tmp)
      EndIf
      tmp + slash
    Next
    If FileAttribute <> #PB_Default
      SetFileAttributesEx(DirectoryName, FileAttribute)
    EndIf
    If FileSize(DirectoryName) = -2
      ProcedureReturn #True
    EndIf
  EndProcedure
  
  Procedure ExamineRecursiveDirectory(DirectoryName.s, Pattern.s, Directory.s = "")
    Protected Dir, Name.s, n
    Static cFiles.i
    
    If Directory = ""
      ClearList(RecursiveFiles())
      cFiles = 0
    EndIf
    If Right(DirectoryName,1) <> slash : DirectoryName + slash : EndIf
    Dir = ExamineDirectory(#PB_Any, DirectoryName, "")
    If Dir
      While NextDirectoryEntry(Dir)
        Name = DirectoryEntryName(Dir)
        If Name <> ".." And Name <> "."
          If DirectoryEntryType(Dir) = #PB_DirectoryEntry_Directory
            AddElement(RecursiveFiles())
            With RecursiveFiles()
              \Directory = Directory
              \Name = Name
              \Attributes = DirectoryEntryAttributes(Dir)
              For n = 0 To 2
                \Date[n] = DirectoryEntryDate(Dir, n)
              Next n
              \Size = DirectoryEntrySize(Dir)
              \Type = DirectoryEntryType(Dir)
            EndWith
            ExamineRecursiveDirectory(DirectoryName + Name, Pattern, Directory + Name + slash)
          EndIf
        EndIf
      Wend
      FinishDirectory(Dir)
    EndIf
    Dir = ExamineDirectory(#PB_Any, DirectoryName, Pattern)
    If Dir
      While NextDirectoryEntry(Dir)
        Name = DirectoryEntryName(Dir)
        If DirectoryEntryType(Dir) = #PB_DirectoryEntry_File
          AddElement(RecursiveFiles())
          cFiles + 1
          With RecursiveFiles()
            \Directory = Directory
            \Name = Name
            \Attributes = DirectoryEntryAttributes(Dir)
            For n = 0 To 2
              \Date[n] = DirectoryEntryDate(Dir, n)
            Next n
            \Size = DirectoryEntrySize(Dir)
            \Type = DirectoryEntryType(Dir)
          EndWith
        EndIf
      Wend
      FinishDirectory(Dir)
    EndIf
    If Directory = ""
      ResetList(RecursiveFiles())
    EndIf
    ProcedureReturn cFiles
  EndProcedure
  
  Procedure.q CopyFileBuffer(sourceID.i, destID.i, buffersize.i)
    Protected *mem, result.q
    
    *mem = AllocateMemory(buffersize)
    
    If *mem And IsFile(sourceID) And IsFile(destID)
      If Loc(sourceID) + buffersize < Lof(sourceID)
        ReadData(sourceID, *mem, buffersize)
        WriteData(destID, *mem, buffersize)
        result = Loc(destID)
      Else
        buffersize = Lof(sourceID) - Loc(destID)
        If buffersize
          ReadData(sourceID, *mem, buffersize)
          WriteData(destID, *mem, buffersize)
        EndIf
        CloseFile(sourceID)
        CloseFile(destID)
        result = 0
      EndIf
    EndIf
    If MemorySize(*mem) > 0
      FreeMemory(*mem)
    EndIf
    ProcedureReturn result
  EndProcedure
  
  Procedure CopyThread(*ctp.CopyThreadPara)
    Protected sourceID.i, destID.i, bufferSize.l = *ctp\BufferSize, position.q, Size.q, Procent.i, Sum.i, count.i = 0
    Protected CustomEvent.i = *ctp\CustomEvent, DestDir.s = *ctp\DestinationDirectory, SourceDir.s = *ctp\SourceDirectory
    Protected Callback.CopyDirExCB = *ctp\Callback, cFiles = *ctp\cFiles
    
    If Right(DestDir, 1) <> slash : DestDir + slash : EndIf
    If Right(SourceDir, 1) <> slash : SourceDir + slash : EndIf
    
    LockMutex(Mutex)
    
    If ListSize(RecursiveFiles())
      If CreateDirectoryEx(DestDir)
        With RecursiveFiles()
          ForEach RecursiveFiles()
            If TrySemaphore(Semaphore)
              UnlockMutex(Mutex)
              PostEvent(CustomEvent)
              Break
            EndIf
            If \Type = #PB_DirectoryEntry_Directory
              CreateDirectoryEx(DestDir + \Directory + \Name, \Attributes)
              Continue
            Else
              If FileSize(DestDir + \Directory) <> -2
                CreateDirectoryEx(DestDir + \Directory)
              EndIf
              sourceID = ReadFile(#PB_Any, SourceDir + \Directory + \Name)
              If IsFile(sourceID) = #False : count + 1 : Continue : EndIf ; lesen fehlgeschlagen, fortsetzen mit nächstem File.
              FileBuffersSize(sourceID, bufferSize)
              Size = Lof(sourceID)
              destID = CreateFile(#PB_Any, DestDir + \Directory + \Name)
              If IsFile(destID) = #False : CloseFile(sourceID) : count + 1 : Continue : EndIf ; erstellen fehlgeschlagen, fortsetzen mit nächstem File.
              FileBuffersSize(destID, bufferSize)
              Sum = Int((100 * count) / cFiles) + 1
              count + 1
            EndIf
            Repeat
              position = CopyFileBuffer(sourceID, destID, bufferSize)
              Procent = Int((100 * position) / Size) + 1
              
              If position = 0 : Procent = 100 : EndIf
              
              If Callback
                Callback(\Name, \Directory, Sum, Procent)
              EndIf
            Until position = 0
            
            SetFileAttributesEx(DestDir + \Directory + \Name, \Attributes)
            SetFileDate(DestDir + \Directory + \Name, 0, \Date[0])
            SetFileDate(DestDir + \Directory + \Name, 1, \Date[1])
            SetFileDate(DestDir + \Directory + \Name, 2, \Date[2])
            
          Next
          If Callback
            Callback("", "", 100, 100)
          EndIf
        EndWith
      EndIf
    EndIf
    UnlockMutex(Mutex)
    PostEvent(CustomEvent)
  EndProcedure
  
  ; public functions
  Procedure CopyDirectoryEx(SourceDirectory.s, DestinationDirectory.s, Pattern.s = "", BufferSize.l = 4096, CustomEvent.l = #PB_Event_FirstCustomValue, Callback.i = 0)
    Static CopyThreadPara.CopyThreadPara
    Protected Thread, cFiles
    
    If BufferSize = #PB_Default : BufferSize = 4096 : EndIf
    If BufferSize < 1024 : BufferSize = 1024 : EndIf
    
    LockMutex(Mutex)
    cFiles = ExamineRecursiveDirectory(SourceDirectory, Pattern)
    If Not ListSize(RecursiveFiles())
      Debug "ERROR: can't examine SourceDirectory!"
      UnlockMutex(Mutex)
      ProcedureReturn #False
    EndIf
    
    UnlockMutex(Mutex)
    
    With CopyThreadPara
      \SourceDirectory = SourceDirectory
      \DestinationDirectory = DestinationDirectory
      \BufferSize = BufferSize
      \CustomEvent = CustomEvent
      \Callback = Callback
      \cFiles = cFiles
    EndWith
    
    Thread = CreateThread(@CopyThread(), @CopyThreadPara)
    ProcedureReturn Thread
  EndProcedure
  
  Procedure SignalStop()
    SignalSemaphore(Semaphore)
  EndProcedure
EndModule

;-Example
CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  Enumeration #PB_Event_FirstCustomValue
    #ProgressFinish
  EndEnumeration
  
  Global.s DestDir = GetTemporaryDirectory() + "purebasic"
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      DestDir + "\"
    CompilerDefault
      DestDir + "/"
  CompilerEndSelect
  
  Procedure Callback(File.s, Dir.s, Sum.i, Procent.i)
    Static tmpFile.s
    Static tmpDir.s
    
    If tmpFile <> File And IsGadget(0)
      tmpFile = File
      SetGadgetText(0, "Copy File: " + File)
    EndIf
    If tmpDir <> Dir And IsGadget(1)
      tmpDir = DestDir + Dir
      SetGadgetText(1, "To: " + DestDir + Dir)
    EndIf
    If IsGadget(2)
      SetGadgetState(2, Sum)
    EndIf
    If IsGadget(3)
      SetGadgetState(3, Procent)
    EndIf
  EndProcedure
  
  Procedure OpenProgress()
    OpenWindow(0, 0, 0, 500, 160, "Progress CopyDirEx", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    TextGadget(0, 10, 10, 480, 30, "")
    TextGadget(1, 10, 40, 480, 30, "")
    ProgressBarGadget(2, 10, 65, 480, 20, 0, 100)
    ProgressBarGadget(3, 10, 95, 480, 20, 0, 100)
    ButtonGadget(4, 150, 125, 160, 30, "cancel")
  EndProcedure
  
  OpenProgress()
  
  Define cancel = #False
  Define Thread = CopyDirEx::CopyDirectoryEx(#PB_Compiler_Home, DestDir, "", 4096, #ProgressFinish, @Callback())
  
  If IsThread(Thread)
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow
          CopyDirEx::SignalStop()
          HideWindow(0, #True)
          cancel = #True
          
        Case #PB_Event_Gadget
          If EventGadget() = 4 ; cancel
            CopyDirEx::SignalStop()
            cancel = #True
          EndIf
          
        Case #ProgressFinish
          If cancel
            MessageRequester("Progress CopyDirEx", "Copying canceled!")
          Else
            MessageRequester("Progress CopyDirEx", "Copying finished!")
          EndIf
          Break
      EndSelect
    ForEver
  EndIf
CompilerEndIf
