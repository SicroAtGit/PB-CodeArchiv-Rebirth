;   Description: Determines all mounted drives
;            OS: Linux, Mac
; English-Forum: 
;  French-Forum: 
;  German-Forum: 
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2019 Sicro
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

Structure DrivesListStruc
  fsType$ ; devtmpfs, tmpfs, ext4, vfat
  avail$  ; 1,6G, 300M
  size$   ; 1,6G, 300M
  source$ ; /dev/sda1, C:\
  target$ ; /, /tmp, /boot/efi, /run/media/username/USBSTICK, C:\
EndStructure

CompilerIf #PB_Compiler_OS = #PB_OS_Linux Or #PB_Compiler_OS = #PB_OS_MacOS
  
  Procedure GetDrivesInfo(List drives.DrivesListStruc())
    
    Protected program, isListHeaderSkipped, regEx
    Protected programString$
    
    program = RunProgram("df", "-h --output=fstype,avail,size,source,target",
                         "", #PB_Program_Open | #PB_Program_Read)
    If Not program
      ProcedureReturn #False
    EndIf
    
    regEx = CreateRegularExpression(#PB_Any, "(?<fstype>[^\s]+)\s+" +
                                             "(?<avail>[^\s]+)\s+" +
                                             "(?<size>[^\s]+)\s+" +
                                             "(?<source>[^\s]+)\s+" +
                                             "(?<target>.*)")
    If Not regEx
      ProcedureReturn #False
    EndIf
    
    While ProgramRunning(program)
      If AvailableProgramOutput(program)
        programString$ = ReadProgramString(program)
        If Not isListHeaderSkipped
          isListHeaderSkipped = #True
          Continue
        EndIf
        If ExamineRegularExpression(regEx, programString$) And
           NextRegularExpressionMatch(regEx) And
           AddElement(drives())
          
          drives()\fsType$ = RegularExpressionNamedGroup(regEx, "fstype")
          drives()\avail$  = RegularExpressionNamedGroup(regEx, "avail")
          drives()\size$   = RegularExpressionNamedGroup(regEx, "size")
          drives()\source$ = RegularExpressionNamedGroup(regEx, "source")
          drives()\target$ = RegularExpressionNamedGroup(regEx, "target")
        EndIf
      EndIf
    Wend
    
    CloseProgram(program)
    FreeRegularExpression(regEx)
    
    ProcedureReturn #True
    
  EndProcedure
  
CompilerElse
  
  Procedure$ FormatBytesNumber(bytes.q)
    
    Select bytes
        
      Case 0 To 1024 - 1
        ProcedureReturn Str(bytes)
        
      Case 1024 To 1024 * 1024 - 1
        ProcedureReturn StrF(bytes / 1024, 1) + "K"
        
      Case 1024 * 1024 To 1024 * 1024 * 1024 - 1
        ProcedureReturn StrF(bytes / 1024 / 1024, 1) + "M"
        
      Case 1024 * 1024 * 1024 To 1024 * 1024 * 1024 * 1024 - 1
        ProcedureReturn StrF(bytes / 1024 / 1024 / 1024, 1) + "G"
        
      Case 1024 * 1024 * 1024 * 1024 To 1024 * 1024 * 1024 * 1024 * 1024 - 1
        ProcedureReturn StrF(bytes / 1024 / 1024 / 1024 / 1024, 1) + "T"
        
    EndSelect
    
  EndProcedure
  
  Procedure GetDrivesInfo(List drives.DrivesListStruc())
    
    Protected   drive$, fsType$, driveName$
    Protected.q avail, size
    
    For i = 'A' To 'Z'
      
      drive$ = Chr(i) + ":\"
      
      fsType$ = Space(#MAX_PATH)
      
      If Not GetVolumeInformation_(drive$, #Null, #Null, #Null, #Null, #Null, @fsType$, #MAX_PATH)
        Continue
      EndIf
      GetDiskFreeSpaceEx_(drive$, @avail, @size, #Null)
      
      If AddElement(drives())
        drives()\fsType$ = fsType$
        drives()\avail$  = FormatBytesNumber(avail)
        drives()\size$   = FormatBytesNumber(size)
        drives()\source$ = drive$
        drives()\target$ = drive$
      EndIf
      
    Next
    
    ProcedureReturn #True
    
  EndProcedure
  
CompilerEndIf

;-Example
CompilerIf #PB_Compiler_IsMainFile
  NewList drivesList.DrivesListStruc()
  
  If GetDrivesInfo(drivesList())
    ForEach drivesList()
      
      ; Skip unreal drives
      Select drivesList()\fsType$
        Case "devtmpfs", "tmpfs"
          Continue
      EndSelect
      
      Debug "Source: " + drivesList()\source$
      Debug "Target: " + drivesList()\target$
      Debug "fsType: " + drivesList()\fsType$
      Debug "Avail:  " + drivesList()\avail$
      Debug "Size:   " + drivesList()\size$
      Debug "----------------------------"
      
    Next
  EndIf
CompilerEndIf
