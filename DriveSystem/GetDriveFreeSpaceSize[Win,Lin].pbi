;   Description: Adds support to get the free space size of drives
;            OS: Windows, Linux
; English-Forum: http://www.purebasic.fr/english/viewtopic.php?p=466070#p466070
;  French-Forum: 
;  German-Forum: http://www.purebasic.fr/german/viewtopic.php?p=278150#p278150
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2010 remi_meier
; Copyright (c) 2015 uwekel
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

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows And #PB_Compiler_OS <> #PB_OS_Linux
  CompilerError "Supported OS are only: Windows, Linux"
CompilerEndIf

CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  ; http://chabba.de/Linux/System/System_FreeDiscSpace.pb
  ; https://linux.die.net/man/2/statvfs

  ImportC ""
    statvfs.l(path.p-utf8, *puffer_0)
  EndImport

  Structure STATVFS
    f_bsize.i  ; file system block size
    f_frsize.i ; fragment size
    f_blocks.i ; size of fs in f_frsize units
    f_bfree.i  ; number of free blocks
    f_bavail.i ; number of free blocks for unprivileged users
    f_files.i  ; number of inodes
    f_ffree.i  ; number of free inodes
    f_favail.i ; number of free inodes for unprivileged users
    f_fsid.i   ; file system ID

    CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
      __f_unused.l
    CompilerEndIf

    f_flag.i    ; mount flags
    f_namemax.i ; maximum filename length
    __f_spare.l[6]
  EndStructure

  Enumeration
    #ST_RDONLY = 1
    #ST_NOSUID = 2
  EndEnumeration

CompilerEndIf

Procedure.q GetDriveFreeSpaceSize(Drive$)
  
  Protected.q BytesFreeToCaller

  CompilerSelect #PB_Compiler_OS

    CompilerCase #PB_OS_Windows
      
      Protected Result
      
      ; https://msdn.microsoft.com/de-de/library/windows/desktop/aa364937(v=vs.85).aspx
      If Left(Drive$, 2) = "\\" ; Network path?
        Drive$ = Left(Drive$, 2)
        Result = GetDiskFreeSpaceEx_(Drive$, @BytesFreeToCaller, 0, 0)
      Else
        If Right(Drive$, 1) <> "\" : Drive$ + "\" : EndIf
        Result = GetDiskFreeSpaceEx_(Drive$, @BytesFreeToCaller, 0, 0)
      EndIf

      If Result
        ProcedureReturn BytesFreeToCaller
      EndIf

    CompilerCase #PB_OS_Linux
      
      Protected Stats.STATVFS
      
      If statvfs(Drive$, @Stats) = 0
        
        If Stats\f_flag & #ST_RDONLY ; User can only read the free space
          ProcedureReturn 0
        EndIf
        BytesFreeToCaller = stats\f_bavail * stats\f_bsize
        ProcedureReturn BytesFreeToCaller
        
      EndIf

  CompilerEndSelect
  
EndProcedure

;-Example
CompilerIf #PB_Compiler_IsMainFile
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows : Debug "Bytes free: " + Str(GetDriveFreeSpaceSize("C:"))
    CompilerCase #PB_OS_Linux   : Debug "Bytes free: " + Str(GetDriveFreeSpaceSize("/"))
  CompilerEndSelect
  
CompilerEndIf
