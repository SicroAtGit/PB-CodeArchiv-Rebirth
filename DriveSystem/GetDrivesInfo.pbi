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
  target$ ; /, /tmp, /boot/efi, /run/media/alex/USBSTICK
EndStructure

Procedure GetDrivesInfo(List drives.DrivesListStruc())
  
  Protected program, isListHeaderSkipped, regEx
  Protected programString$
  
  program = RunProgram("df", "--human-readable" +
                             " --output=fstype,avail,size,target", "",
                       #PB_Program_Open | #PB_Program_Read)
  If Not program
    ProcedureReturn #False
  EndIf
  
  regEx = CreateRegularExpression(#PB_Any, "(?<fstype>[^\s]+)\s+" +
                                           "(?<avail>[^\s]+)\s+" +
                                           "(?<size>[^\s]+)\s+" +
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
        drives()\target$ = RegularExpressionNamedGroup(regEx, "target")
      EndIf 
    EndIf
  Wend
  
  CloseProgram(program)
  FreeRegularExpression(regEx)
  
  ProcedureReturn #True
  
EndProcedure

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
      
      Debug drivesList()\target$ + " (" +
            drivesList()\fsType$ + ", " +
            drivesList()\avail$ + " of " +
            drivesList()\size$ + ")"
    Next
  EndIf
CompilerEndIf
